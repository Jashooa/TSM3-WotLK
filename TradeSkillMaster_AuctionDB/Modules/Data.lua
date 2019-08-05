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

local function GetDay(t)
    t = t or time()
    return floor(t / (SECONDS_PER_DAY))
end

local function ConvertScansToAverage(scans)
    if not scans then return end

    if not scans.average then
        local total, num = 0, 0
        for _, value in ipairs(scans) do
            total = total + value
            num = num + 1
        end
        scans.average = floor(total / num + 0.5)
        scans.count = num
    end
    return scans
end

local function GetMarketValue(scans)
    local day = GetDay()
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
    local day = GetDay()

    local scans = CopyTable(itemData.scans)
    itemData.scans = {}

    for i = 0, 14 do
        local dayScans = scans[day-i]
        if i <= TSM.MAX_AVG_DAY then
            if type(dayScans) == "number" then
                dayScans = {average=dayScans, count=1}
            end
            itemData.scans[day-i] = dayScans and CopyTable(dayScans)
        else
            if type(dayScans) == "table" then
                itemData.scans[day-i] = dayScans.average
            elseif dayScans then
                itemData.scans[day-i] = dayScans
            end
        end
    end
    itemData.marketValue = GetMarketValue(itemData.scans)
end

local function CalculateMarketValue(buyouts)
	local totalNum, totalBuyout = 0, 0
	local numRecords = #buyouts

	for i=1, numRecords do
		totalNum = i - 1
		if i ~= 1 and i > numRecords*MIN_PERCENTILE and (i > numRecords*MAX_PERCENTILE or buyouts[i] >= MAX_JUMP*buyouts[i-1]) then
			break
		end

		totalBuyout = totalBuyout + buyouts[i]
		if i == numRecords then
			totalNum = i
		end
	end

	local uncorrectedMean = totalBuyout / totalNum
	local varience = 0

	for i=1, totalNum do
		varience = varience + (buyouts[i]-uncorrectedMean)^2
	end

	local stdDev = sqrt(varience/totalNum)
	local correctedTotalNum, correctedTotalBuyout = 1, uncorrectedMean

	for i=1, totalNum do
		if abs(uncorrectedMean - buyouts[i]) < 1.5*stdDev then
			correctedTotalNum = correctedTotalNum + 1
			correctedTotalBuyout = correctedTotalBuyout + buyouts[i]
		end
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
    local day = GetDay()
	for itemString, data in pairs(scanData) do
		itemString = TSMAPI.Item:ToBaseItemString(itemString)
        TSM.realmData[itemString] = TSM.realmData[itemString] or {scans={}}

        local marketValue = CalculateMarketValue(data.buyouts)
        local scans = TSM.realmData[itemString].scans
        scans[day] = scans[day] or {average=0, count=0}
        scans[day].average = scans[day].average or 0
        scans[day].count = scans[day].count or 0
        if #scans[day] > 0 then
            scans[day] = ConvertScansToAverage(scans[day])
        end
        scans[day].average = floor((scans[day].average * scans[day].count + marketValue) / (scans[day].count + 1) + 0.5)
        scans[day].count = scans[day].count + 1

        TSM.realmData[itemString].minBuyout = data.minBuyout
        TSM.realmData[itemString].numAuctions = data.numAuctions
        TSM.realmData[itemString].lastScan = scanTime
        UpdateMarketValue(TSM.realmData[itemString])
		self:Yield()
	end
end
