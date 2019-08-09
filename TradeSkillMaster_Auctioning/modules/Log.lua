-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Auctioning                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctioning          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local Log = TSM:NewModule("Log", "AceEvent-3.0")

local records = {}

local RED = "|cffff2211"
local ORANGE = "|cffff8811"
local GREEN = "|cff22ff22"
local CYAN = "|cff99ffff"

local info = {
	post = {
		invalid = {"Item/Group is invalid (see chat).", RED, true},
		notEnough = {"Not enough items in bags.", ORANGE, true},
		maxExpires = {"Above max expires.", ORANGE, true},
		belowMinPrice = {"Cheapest auction below min price.", ORANGE},
		tooManyPosted = {"Maximum amount already posted.", CYAN},
		postingNormal = {"Posting at normal price.", GREEN},
		postingResetMin = {"Below min price. Posting at min price.", GREEN},
		postingResetMax = {"Below min price. Posting at max price.", GREEN},
		postingResetNormal = {"Below min price. Posting at normal price.", GREEN},
		aboveMaxMin = {"Above max price. Posting at min price.", GREEN},
		aboveMaxMax = {"Above max price. Posting at max price.", GREEN},
		aboveMaxNormal = {"Above max price. Posting at normal price.", GREEN},
		aboveMaxNoPost = {"Above max price. Not posting.", ORANGE},
		postingPlayer = {"Posting at your current price.", GREEN},
		postingWhitelist = {"Posting at whitelisted player's price.", GREEN},
		notPostingWhitelist = {"Lowest auction by whitelisted player.", ORANGE},
		postingUndercut = {"Undercutting competition.", GREEN},
		invalidSeller = {"Invalid seller data returned by server.", RED},
		undercuttingBlacklist = {"Undercutting blacklisted player.", GREEN},
	},
	cancel = {
		invalid = {"Item/Group is invalid (see chat).", RED, true},
		bid = {"Auction has been bid on.", CYAN, true},
		atReset = {"Not canceling auction at reset price.", GREEN},
		reset = {"Canceling to repost at reset price.", CYAN},
		belowMinPrice = {"Not canceling auction below min price.", ORANGE},
		undercut = {"You've been undercut.", RED},
		whitelistUndercut = {"Undercut by whitelisted player.", RED},
		atNormal = {"At normal price and not undercut.", GREEN},
		atAboveMax = {"At above max price and not undercut.", GREEN},
		repost = {"Canceling to repost at higher price.", CYAN},
		notUndercut = {"Your auction has not been undercut.", GREEN},
		cancelAll = {"Canceling all auctions.", CYAN, true},
		notLowest = {"Canceling auction which you've undercut.", CYAN},
		invalidSeller = {"Invalid seller data returned by server.", RED},
		atWhitelist = {"Posted at whitelisted player's price.", GREEN},
		keepPosted = {"Keeping undercut auctions posted.", CYAN},
	},
}

function Log:GetInfo(mode, reason)
	return info[mode][reason] and info[mode][reason][1]
end

function Log:GetColor(mode, reason)
	return mode and reason and info[mode] and info[mode][reason] and info[mode][reason][2]
end

function Log:AddLogRecord(itemString, mode, action, reason, operation, buyout)
	local info = Log:GetInfo(mode, reason)
	TSMAPI:Assert(itemString and operation, "Assertion Failed: "..tostring(itemString))
	local record = {itemString=itemString, info=info, action=action, mode=mode, reason=reason, operation=operation, buyout=buyout}
	tinsert(records, record)
end

function Log:GetInfoForItem(itemString)
	for _, record in ipairs(records) do
		if record.itemString == itemString then
			return record.info
		end
	end
end

function Log:GetData()
	return records
end

function Log:Clear()
	wipe(records)
end

function Log:IsNoScanReason(mode, reason)
	return mode and reason and info[mode] and info[mode][reason] and info[mode][reason][3]
end