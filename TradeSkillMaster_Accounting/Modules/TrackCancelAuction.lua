-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- create a local reference to the TradeSkillMaster_Accounting table and register a new module
local TSM = select(2, ...)
local TrackCancelAuction = TSM:NewModule("TrackCancelAuction", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Accounting") -- loads the localization table
local private = { pendingCancels = {}}



-- ============================================================================
-- Module Functions
-- ============================================================================

function TrackCancelAuction:OnEnable()
    TrackCancelAuction:RawHook("CancelAuction", private.CancelAuctionWatch, true)
end



-- ============================================================================
-- Auction Functions
-- ============================================================================

function private.CancelAuctionWatch(index)
    local itemName, _, stackSize, _, _, _, _, _, buyout = GetAuctionItemInfo("owner", index)
    if itemName and stackSize then
        local itemString = TSM.db.global.itemStrings[itemName] or TSMAPI.Item:GetStringFromName(itemName)
        private.AddPendingCancel(itemString, buyout, stackSize)
    end
    TrackCancelAuction.hooks["CancelAuction"](index)
end

function private.AddPendingCancel(itemString, buyout, stackSize)
    local pendingCancel = {}
    pendingCancel.itemString = itemString
    pendingCancel.buyout = buyout
    pendingCancel.stackSize = stackSize
    table.insert(private.pendingCancels, pendingCancel)

    if #private.pendingCancels == 1 then
        TrackCancelAuction:RegisterEvent("CHAT_MSG_SYSTEM", private.EventHandler)
        TrackCancelAuction:RegisterEvent("UI_ERROR_MESSAGE", private.EventHandler)
    end
end

function private.RemovePendingCancel()
    if #private.pendingCancels == 0 then return end

    local post = private.pendingCancels[1]
    table.remove(private.pendingCancels, 1)

    if #private.pendingCancels == 0 then
        TrackCancelAuction:UnregisterEvent("CHAT_MSG_SYSTEM")
        TrackCancelAuction:UnregisterEvent("UI_ERROR_MESSAGE")
    end

    return post
end

function private.OnAuctionCancelled(self)
    local post = private.RemovePendingCancel()


    if post and post.itemString then
        TSM.Data:RemoveActiveAuction(post.itemString, post.buyout, post.stackSize)
    elseif post and not post.itemString then
    end
end

function private.OnCancelFailed()
    private.RemovePendingCancel()
end

function private.EventHandler(event, message)
    if event == "CHAT_MSG_SYSTEM" and message == ERR_AUCTION_REMOVED and private.pendingCancels then
        private.OnAuctionCancelled()
    elseif event == "UI_ERROR_MESSAGE" and message == ERR_ITEM_NOT_FOUND then
        private.OnCancelFailed()
    end
end
