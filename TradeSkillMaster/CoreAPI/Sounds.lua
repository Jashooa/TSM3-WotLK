-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--          http://www.curse.com/addons/wow/tradeskillmaster_warehousing          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- This file contains sound-related APIs

local TSM = select(2, ...)
local SOUNDS = {
	[TSM.NO_SOUND_KEY] = "|cff99ffff".."No Sound".."|r",
	["AuctionWindowOpen"] = "Auction Window Open",
	["AuctionWindowClose"] = "Auction Window Close",
	["alarmclockwarning3"] = "Alarm Clock",
	["UI_AutoQuestComplete"] = "Auto Quest Complete",
	["HumanExploration"] = "Exploration",
	["TSM_CASH_REGISTER"] = "Cash Register",
	["Fishing Reel in"] = "Fishing Reel In",
	["LevelUp"] = "Level Up",
	["MapPing"] = "Map Ping",
	["MONEYFRAMEOPEN"] = "Money Frame Open",
	["IgPlayerInviteAccept"] = "Player Invite Accept",
	["QUESTADDED"] = "Quest Added",
	["QUESTCOMPLETED"] = "Quest Completed",
	["UI_QuestObjectivesComplete"] = "Quest Objectives Complete",
	["RaidWarning"] = "Raid Warning",
	["ReadyCheck"] = "Ready Check",
	["UnwrapGift"] = "Unwrap Gift",
}



-- ============================================================================
-- TSMAPI Functions
-- ============================================================================

function TSMAPI:GetNoSoundKey()
	return TSM.NO_SOUND_KEY
end

function TSMAPI:GetSounds()
	return SOUNDS
end

function TSMAPI:DoPlaySound(soundKey)
	if soundKey == TSM.NO_SOUND_KEY then
		-- do nothing
	elseif soundKey == "TSM_CASH_REGISTER" then
		PlaySoundFile("Interface\\Addons\\TradeSkillMaster\\Media\\register.mp3", "Master")
		FlashClientIcon()
	else
		PlaySound(soundKey, "Master")
		FlashClientIcon()
	end
end