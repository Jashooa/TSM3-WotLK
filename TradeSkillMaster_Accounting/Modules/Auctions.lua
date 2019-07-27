-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- create a local reference to the TradeSkillMaster_Accounting table and register a new module
local TSM = select(2, ...)
local Auctions = TSM:NewModule("Auctions", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Accounting") -- loads the localization table
local private = {}



-- ============================================================================
-- Module Functions
-- ============================================================================

function Auctions:OnEnable()
    Auctions:RawHook("StartAuction", private.StartAuctionWatch, true)
    Auctions:RawHook("CancelAuction", private.CancelAuctionWatch, true)
end



-- ============================================================================
-- Auction Functions
-- ============================================================================

function private.StartAuctionWatch(bid, buyout, duration, stackSize, numStacks)
    local itemName = GetAuctionSellItemInfo()
    TSMAPI.Threading:Start(private.WatchStartAuctionThread, 0.7, nil, {itemName, bid, buyout, duration, stackSize, numStacks})
    Auctions.hooks["StartAuction"](bid, buyout, duration, stackSize, numStacks)
end

function private.WatchStartAuctionThread(self, auctionInfo)
    local itemName, bid, buyout, duration, stackSize, numStacks = unpack(auctionInfo)
    local itemString = TSM.db.global.itemStrings[itemName] or TSMAPI.Item:GetStringFromName(itemName)
	self:RegisterEvent("CHAT_MSG_SYSTEM", function(_, msg) if numStacks == 1 and msg == ERR_AUCTION_STARTED then self:SendMsgToSelf("AUCTION_POSTED", 1) end end)
	local lastMultipostQuantity = 0
	self:RegisterEvent("AUCTION_MULTISELL_UPDATE", function(_, arg1, arg2)
		if numStacks <= 1 then return end
		if arg1 == arg2 then
			self:SendMsgToSelf("AUCTION_POSTED", arg2)
		else
			lastMultipostQuantity = arg1
		end
	end)
	self:RegisterEvent("AUCTION_MULTISELL_FAILURE", function()
		self:SendMsgToSelf("AUCTION_POSTED", lastMultipostQuantity)
    end)

	while true do
		local args = self:ReceiveMsg()
        local event = tremove(args, 1)
        if event == "AUCTION_POSTED" then
            -- auction was posted so add the records
			local numStacksPosted = unpack(args)
            TSM.Data:InsertActiveAuction(itemString, bid, buyout, duration, stackSize, numStacksPosted)
            break
		else
			error("Unexpected message: " .. tostring(event))
		end
    end
end

function private.CancelAuctionWatch(index)
    local itemName, _, stackSize, _, _, _, _, _, buyout = GetAuctionItemInfo("owner", index)
    TSMAPI.Threading:Start(private.WatchCancelAuctionThread, 0.7, nil, {itemName, buyout, stackSize})
    Auctions.hooks["CancelAuction"](index)
end

function private.WatchCancelAuctionThread(self, auctionInfo)
    local itemName, buyout, stackSize = unpack(auctionInfo)
    local itemString = TSM.db.global.itemStrings[itemName] or TSMAPI.Item:GetStringFromName(itemName)
    self:RegisterEvent("CHAT_MSG_SYSTEM", function(_, msg) if msg == ERR_AUCTION_REMOVED then self:SendMsgToSelf("AUCTION_CANCELED") end end)

    while true do
        local args = self:ReceiveMsg()
        local event = tremove(args, 1)
        if event == "AUCTION_CANCELED" then
            TSM.Data:RemoveActiveAuction(itemString, buyout, stackSize)
        else
            error("Unexpected message: " .. tostring(event))
        end
    end
end
