-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_AuctionDB                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctiondb           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster_AuctionDB Locale - enUS
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/tradeskillmaster_auctiondb/localization/

local isDebug = false
--[===[@debug@
isDebug = true
--@end-debug@]===]
local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_AuctionDB", "enUS", true, isDebug)
if not L then return end

L["A full auction house scan will scan every item on the auction house but is far slower than a GetAll scan. Expect this scan to take several minutes or longer."] = true
L["A full scan is a slow, manual scan of the entire auction house."] = true
L["A 'GetAll' scan is an extremely fast way to manually scan the entire AH, but may run into bugs on Blizzard's end such as disconnection issues. It also has a 15 minute cooldown."] = true
L["A GetAll scan is the fastest in-game method for scanning every item on the auction house. However, there are many possible bugs on Blizzard's end with it including the chance for it to disconnect you from the game. Also, it has a 15 minute cooldown."] = true
L["AuctionDB - Historical Price"] = true
L["AuctionDB - Market Value"] = true
L["AuctionDB - Minimum Buyout"] = true
L["Can't run a GetAll scan right now."] = true
L["|cffff0000WARNING:|r TSM_AuctionDB doesn't currently have any pricing data for your realm. Either download the TSM Desktop Application from |cff99ffffhttp://tradeskillmaster.com|r to automatically update TSM_AuctionDB's data, or run a manual scan in-game."] = true
L["Class"] = true
L["%d auctions"] = true
L["Display Grey Items in Search"] = true
L["Display historical price in the tooltip."] = true
L["Display market value in tooltip."] = true
L["Display min buyout in tooltip."] = true
L["Done Scanning"] = true
L["Download the FREE TSM desktop application which will automatically update your TSM_AuctionDB prices using Blizzard's online APIs (and does MUCH more). Visit %s for more info and never scan the AH again! This is the best way to update your AuctionDB prices."] = true
L["General Options"] = true
L["Historical Price"] = true
L["Historical Price:"] = true
L["Historical Price x%s:"] = true
L["If checked, AuctionDB will add a tab to the AH to allow for in-game scans. If you are using the TSM app exclusively for your scans, you may want to hide it by unchecking this option. This option requires a reload to take effect."] = true
L["If checked, poor quality items will be shown in AuctionDB search data."] = true
L["If checked, the lowest buyout value seen in the last scan of the item will be displayed."] = true
L["If checked, the market value of the item will be displayed"] = true
L["If checked, the historical price of the item will be displayed."] = true
L["If you have created TSM groups, they will be listed here for selection."] = true
L["Last Scanned"] = true
L["Last updated from in-game scan %s ago."] = true
L["Last updated from the TSM Application %s ago."] = true
L["Last Update Time"] = true
L["Market Value"] = true
L["Market Value:"] = true
L["Market Value x%s:"] = true
L["Min Buyout"] = true
L["Min Buyout:"] = true
L["Min Buyout x%s:"] = true
L["Name"] = true
L["No scans found."] = true
L["None"] = true
L["Not Ready"] = true
L["Not Scanned"] = true
L["Options"] = true
L["Preparing Filters..."] = true
L["Processing data..."] = true
L["Rarity"] = true
L["Ready"] = true
L["Run Full Scan"] = true
L["Run GetAll Scan"] = true
L["Running query..."] = true
L["%s ago"] = true
L["Scanning %d / %d (Page %d / %d)"] = true
L["Scanning page %s/%s"] = true
L["Scanning page %s/%s - Approximately %s remaining"] = true
L["Scanning results..."] = true
L["Scanning the auction house in game is no longer necessary!"] = true
L["Scan Selected Groups"] = true
L["Search"] = true
L["Shift-Right-Click to clear all data for this item from AuctionDB."] = true
L["Show AuctionDB AH Tab (Requires Reload)"] = true
L["SubClass"] = true
L["The scan did not run successfully due to issues on Blizzard's end. Using the TSM desktop application for your scans is recommended."] = true
L["This button will scan just the items in the groups you have selected."] = true
L["This will do a slow auction house scan of every item in the selected groups and update their AuctionDB prices. This may take several minutes."] = true
L["You can use this page to lookup an item or group of items in the AuctionDB database. Note that this does not perform a live search of the AH."] = true
L["You must select at least one group before starting the group scan."] = true
