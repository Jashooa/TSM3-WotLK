-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- create a local reference to the TradeSkillMaster_Accounting table and register a new module
local TSM = select(2, ...)
local TrackStartAuction = TSM:NewModule("TrackStartAuction", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Accounting") -- loads the localization table
local private = { pendingAuctions = {}}



-- ============================================================================
-- Module Functions
-- ============================================================================

function TrackStartAuction:OnEnable()
    TrackStartAuction:RawHook("StartAuction", private.StartAuctionWatch, true)
    TrackStartAuction:RegisterEvent("AUCTION_MULTISELL_UPDATE", private.EventHandler)
end



-- ============================================================================
-- Auction Functions
-- ============================================================================
local itemStringMulti, bidMulti, buyoutMulti, durationMulti, stackSizeMulti
function private.StartAuctionWatch(bid, buyout, duration, stackSize, numStacks)
    local itemName = GetAuctionSellItemInfo()
    if itemName and stackSize then
        local itemString = TSM.db.global.itemStrings[itemName] or TSMAPI.Item:GetStringFromName(itemName)

        itemStringMulti, bidMulti, buyoutMulti, durationMulti, stackSizeMulti = itemString, bid, buyout, duration, stackSize
        private.AddPendingAuction(itemString, bid, buyout, duration, stackSize, 1)
    end
    TrackStartAuction.hooks["StartAuction"](bid, buyout, duration, stackSize, numStacks)
end

function private.AddPendingAuction(itemString, bid, buyout, duration, stackSize, numStacks)
    local pendingAuction = {}
    pendingAuction.itemString = itemString
    pendingAuction.bid = bid
    pendingAuction.buyout = buyout
    pendingAuction.duration = duration
    pendingAuction.stackSize = stackSize
    pendingAuction.numStacks = numStacks
    table.insert(private.pendingAuctions, pendingAuction)

    if #private.pendingAuctions == 1 then
        TrackStartAuction:RegisterEvent("CHAT_MSG_SYSTEM", private.EventHandler)
        TrackStartAuction:RegisterEvent("UI_ERROR_MESSAGE", private.EventHandler)
    end
end

function private.RemovePendingAuction()
    if #private.pendingAuctions == 0 then return end

    local post = private.pendingAuctions[1]
    table.remove(private.pendingAuctions, 1)

    if #private.pendingAuctions == 0 then
        TrackStartAuction:UnregisterEvent("CHAT_MSG_SYSTEM")
        TrackStartAuction:UnregisterEvent("UI_ERROR_MESSAGE")
        itemStringMulti, bidMulti, buyoutMulti, durationMulti, stackSizeMulti = nil
    end

    return post
end

function private.OnAuctionCreated()
    local post = private.RemovePendingAuction()

    if post and post.itemString then
        TSM.Data:InsertActiveAuction(post.itemString, post.bid, post.buyout, post.duration, post.stackSize, post.numStacks)
    elseif post and not post.itemString then
    end
end

function private.OnAuctionFailed()
    private.RemovePendingAuction()
end

function private.OnMultiSell(current, total)
    if current > 1 then
        private.AddPendingAuction(itemStringMulti, bidMulti, buyoutMulti, durationMulti, stackSizeMulti, 1)
    end
end

function private.EventHandler(event, message, ...)
	local ERR_MESSAGES_NO_RETRY = {ERR_AUCTION_REPAIR_ITEM, ERR_AUCTION_LIMITED_DURATION_ITEM, ERR_AUCTION_USED_CHARGES, ERR_AUCTION_WRAPPED_ITEM, ERR_AUCTION_BAG}
    local ERR_MESSAGES = {ERR_ITEM_NOT_FOUND, ERR_AUCTION_DATABASE_ERROR,}

    if event == "CHAT_MSG_SYSTEM" and message == ERR_AUCTION_STARTED and private.pendingAuctions then
        private.OnAuctionCreated()
    elseif event == "UI_ERROR_MESSAGE" and (tContains(ERR_MESSAGES, message) or tContains(ERR_MESSAGES_NO_RETRY, message)) then
        private.OnAuctionFailed()
    elseif event == "AUCTION_MULTISELL_UPDATE" then
        private.OnMultiSell(message, ...)
    end
end