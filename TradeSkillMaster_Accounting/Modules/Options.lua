-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- create a local reference to the TradeSkillMaster_Crafting table and register a new module
local TSM = select(2, ...)
local Options = TSM:NewModule("Options")
local AceGUI = LibStub("AceGUI-3.0")
local private = {}



-- ============================================================================
-- Module Options
-- ============================================================================

function Options:Load(container)
	local mvSources = TSMAPI:GetPriceSources()
	local daysOld = 45

	local page = {
		{
			type = "ScrollFrame",
			layout = "List",
			children = {
				{
					type = "InlineGroup",
					title = "General Options",
					layout = "Flow",
					children = {
						{
							type = "Dropdown",
							label = "Time Format",
							settingInfo = {TSM.db.global, "timeFormat"},
							list = { ["ago"] = "_ Hr _ Min ago", ["usdate"] = "MM/DD/YY HH:MM", ["aidate"] = "YY/MM/DD HH:MM", ["eudate"] = "DD/MM/YY HH:MM" },
							tooltip = "Select what format Accounting should use to display times in applicable screens.",
						},
						{
							type = "Dropdown",
							label = "Market Value Source",
							settingInfo = {TSM.db.global, "mvSource"},
							list = mvSources,
							tooltip = "Select where you want Accounting to get market value info from to show in applicable screens.",
						},
						{
							type = "Dropdown",
							label = "Items/Resale Price Format",
							settingInfo = {TSM.db.global, "priceFormat"},
							list = { ["avg"] = "Per Item", ["total"] = "Total Value" },
							tooltip = "Select how you would like prices to be shown in the \"Items\" and \"Resale\" tabs; either average price per item or total value.",
						},
						{
							type = "HeadingLine"
						},
						{
							type = "CheckBox",
							label = "Track Sales/Purchases via Trade",
							settingInfo = { TSM.db.global, "trackTrades" },
							callback = function() container:Reload() end,
							tooltip = "If checked, whenever you buy or sell any quantity of a single item via trade, Accounting will display a popup asking if you want it to record that transaction.",
						},
						{
							type = "CheckBox",
							label = "Don't Prompt to Record Trades",
							settingInfo = { TSM.db.global, "autoTrackTrades" },
							disabled = not TSM.db.global.trackTrades,
							tooltip = "If checked, you won't get a popup confirmation about whether or not to track trades.",
						},
						{
							type = "CheckBox",
							label = "Display Grey Items in Sales",
							settingInfo = { TSM.db.global, "displayGreys" },
							tooltip = "If checked, poor quality items will be shown in sales data. They will still be included in gold earned totals on the summary tab regardless of this setting",
						},
						{
							type = "CheckBox",
							label = "Display Money Transfers",
							settingInfo = { TSM.db.global, "displayTransfers" },
							tooltip = "If checked, Money Transfers will be included in income / expense and summary. Accounting will still track these if disabled but will not show them.",
						},
						{
							type = "CheckBox",
							label = "Use Smart Average for Purchase Price",
							settingInfo = { TSM.db.realm, "smartBuyPrice" },
							tooltip = "If checked, the average purchase price that shows in the tooltip will be the average price for the most recent X you have purchased, where X is the number you have in your bags / bank / guild vault. Otherwise, a simple average of all purchases will be used.",
						},
					},
				},
				{
					type = "InlineGroup",
					title = "Clear Old Data",
					layout = "Flow",
					children = {
						{
							type = "Label",
							text = "You can use the options below to clear old data. It is recommened to occasionally clear your old data to keep Accounting running smoothly. Select the minimum number of days old to be removed in the dropdown, then click the button.\n\nNOTE: There is no confirmation.",
							relativeWidth = 1,
						},
						{
							type = "HeadingLine",
						},
						{
							type = "Dropdown",
							label = "Days:",
							relativeWidth = 0.4,
							list = { "30", "45", "60", "75", "90" },
							value = 2,
							callback = function(_, _, value) daysOld = (tonumber(value) + 1) * 15 end,
							tooltip = "Data older than this many days will be deleted when you click on the button to the right.",
						},
						{
							type = "Button",
							text = "Remove Old Data (No Confirmation)",
							relativeWidth = 0.59,
							callback = function() TSM.ViewerUtil:RemoveOldData(daysOld) end,
							tooltip = "Click this button to permanently remove data older than the number of days selected in the dropdown.",
						},
					},
				},
			},
		},
	}

	TSMAPI.GUI:BuildOptions(container, page)
end



-- ============================================================================
-- Tooltip Options
-- ============================================================================

function Options:LoadTooltipOptions(container, options)
	local page = {
		{
			type = "SimpleGroup",
			layout = "Flow",
			fullHeight = true,
			children = {
				{
					type = "CheckBox",
					label = "Show sale info in item tooltips",
					settingInfo = { options, "sale" },
					tooltip = "If checked, the number you have sold and the average sale price will show up in an item's tooltip.\n\nNote: Vendor sales will not be shown.",
				},
				{
					type = "CheckBox",
					label = "Show expired auctions since last sale in item tooltips",
					settingInfo = { options, "expiredAuctions" },
					relativeWidth = 1,
					tooltip = "If checked, the number of expired auctions since the last sale will show as up as failed auctions in an item's tooltip. if no sales then the total number of expired auctions will be shown.",
				},
				{
					type = "CheckBox",
					label = "Show cancelled auctions since last sale in item tooltips",
					settingInfo = { options, "cancelledAuctions" },
					relativeWidth = 1,
					tooltip = "If checked, the number of cancelled auctions since the last sale will show as up as failed auctions in an item's tooltip. if no sales then the total number of cancelled auctions will be shown.",
				},
				{
					type = "CheckBox",
					label = "Show Sale Rate in item tooltips",
					settingInfo = { options, "saleRate" },
					relativeWidth = 1,
					tooltip = "If checked, the sale rate will be shown in item tooltips. sale rate is calculated as total sold / (total sold + total expired + total cancelled).",
				},
				{
					type = "CheckBox",
					label = "Show purchase info in item tooltips",
					settingInfo = { options, "purchase" },
					tooltip = "If checked, the number you have purchased and the average purchase price will show up in an item's tooltip.\n\nNote: Vendor purchases will not be shown.",
				},
			},
		},
	}

	TSMAPI.GUI:BuildOptions(container, page)
end