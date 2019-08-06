-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_AuctionDB                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctiondb           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local Data = TSM:NewModule("Data")

-- weight for the market value from X days ago (where X is the index of the table)
local WEIGHTS = {[0] = 132, [1] = 125, [2] = 100, [3] = 75, [4] = 45, [5] = 34, [6] = 33,
	[7] = 38, [8] = 28, [9] = 21, [10] = 15, [11] = 10, [12] = 7, [13] = 5, [14] = 4}
local MIN_PERCENTILE = 0.15 -- consider at least the lowest 15% of auctions
local MAX_PERCENTILE = 0.30 -- consider at most the lowest 30% of auctions
local MAX_JUMP = 1.2 -- between the min and max percentiles, any increase in price over 120% will trigger a discard of remaining auctions
local SECONDS_PER_DAY = 60 * 60 * 24

function Data:GetDay(t)
    t = t or time()
    return floor(t / (SECONDS_PER_DAY))
end

local function GetMarketValue(scans)
    local day = Data:GetDay()
    local totalAmount, totalWeight = 0, 0

    for i = 0, 14 do
        local dayScans = scans[day-i]
        if dayScans then
            local dayMarketValue
            if type(dayScans) == "table" then
                dayMarketValue = dayScans.average
            else
                dayMarketValue = dayScans
            end
            if dayMarketValue then
                totalAmount = totalAmount + (WEIGHTS[i] * dayMarketValue)
                totalWeight = totalWeight + WEIGHTS[i]
            end
        end
    end
    for i in ipairs(scans) do
        if i < day - 14 then
            scans[i] = nil
        end
    end

    return totalWeight > 0 and floor(totalAmount / totalWeight + 0.5) or 0
end

local function UpdateMarketValue(itemData)
    local day = Data:GetDay()

    local scans = CopyTable(itemData.scans)
    itemData.scans = {}

    for i = 0, 14 do
        if i <= TSM.MAX_AVG_DAY then
            if type(scans[day-i]) == "number" then
                scans[day-i] = {average=scans[day-i], count=1}
            end
            itemData.scans[day-i] = scans[day-i] and CopyTable(scans[day-i])
        else
            local dayScans = scans[day-i]
            if type(dayScans) == "table" then
                itemData.scans[day-i] = dayScans.average
            elseif dayScans then
                itemData.scans[day-i] = dayScans
            end
        end
    end
    itemData.marketValue = GetMarketValue(itemData.scans)
end

local function CalculateMarketValue(buyouts, numRecords)
	local totalNum, totalBuyout = 0, 0
	local numBuyouts = #buyouts

	for i=1, numBuyouts do
		for j=1, buyouts[i].count do
			local gi = totalNum + 1
			if gi ~= 1 and gi > numRecords*MIN_PERCENTILE and (gi > numRecords*MAX_PERCENTILE or buyouts[i].value >= MAX_JUMP*buyouts[max(i-1, 1)].value) then
				break
			end

			totalBuyout = totalBuyout + buyouts[i].value
			totalNum = totalNum + 1;
		end
	end

	local uncorrectedMean = totalBuyout / totalNum
	local varience = 0

	local totalLeft = totalNum
	for i=1, numBuyouts do
		local count = min(buyouts[i].count, totalLeft)
		varience = varience + count*(buyouts[i].value-uncorrectedMean)^2
		totalLeft = totalLeft - count
		if totalLeft <= 0 then break end
	end

	local stdDev = sqrt(varience/totalNum)
	local correctedTotalNum, correctedTotalBuyout = 1, uncorrectedMean

	local totalLeft = totalNum
	for i=1, numBuyouts do
		local count = min(buyouts[i].count, totalLeft)
		if abs(uncorrectedMean - buyouts[i].value) < 1.5*stdDev then
			correctedTotalNum = correctedTotalNum + count
			correctedTotalBuyout = correctedTotalBuyout + buyouts[i].value*count
		end
		totalLeft = totalLeft - count
		if totalLeft <= 0 then break end
	end

	local correctedMean = floor(correctedTotalBuyout / correctedTotalNum + 0.5)

	return correctedMean
end

function Data:ProcessScanDataThread(self, scanData, itemList)
	local scanTime = time()
	TSM.db.realm.lastPartialScan = scanTime

	local scannedItems = nil
	if itemList then
		scannedItems = {}
		for _, itemString in ipairs(itemList) do
			scannedItems[itemString] = true
		end
	else
		TSM.db.realm.lastCompleteScan = scanTime
	end

	-- clear min buyotus / num auctions and update last scan time for items we should have scanned
	for itemString, data in pairs(TSM.realmData) do
		if not scannedItems or scannedItems[itemString] then
			data.minBuyout = nil
			data.numAuctions = nil
			data.lastScan = scanTime
			self:Yield()
		end
	end

	-- process new data
    TSM.updatedRealmData = true
    local day = Data:GetDay()
	for itemString, data in pairs(scanData) do
		itemString = TSMAPI.Item:ToBaseItemString(itemString)
        TSM.realmData[itemString] = TSM.realmData[itemString] or {scans={}}

        local marketValue = CalculateMarketValue(data.buyouts, data.buyoutsQuantity)
        local scans = TSM.realmData[itemString].scans
        scans[day] = scans[day] or {average=0, count=0}
        scans[day].average = scans[day].average or 0
        scans[day].count = scans[day].count or 0
        scans[day].average = floor((scans[day].average * scans[day].count + marketValue) / (scans[day].count + 1) + 0.5)
        scans[day].count = scans[day].count + 1

        TSM.realmData[itemString].minBuyout = data.minBuyout
        TSM.realmData[itemString].numAuctions = data.numAuctions
        TSM.realmData[itemString].lastScan = scanTime
        UpdateMarketValue(TSM.realmData[itemString])
		self:Yield()
	end
end
