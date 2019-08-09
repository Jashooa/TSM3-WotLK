-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Auctioning                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctioning          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local Options = TSM:NewModule("Options", "AceEvent-3.0", "AceHook-3.0")
local AceGUI = LibStub("AceGUI-3.0") -- load the AceGUI libraries
local private = {}



-- ============================================================================
-- Module Options
-- ============================================================================

function Options:Load(container)
	local tg = AceGUI:Create("TSMTabGroup")
	tg:SetLayout("Fill")
	tg:SetFullHeight(true)
	tg:SetFullWidth(true)
	tg:SetTabs({{value=1, text="General"}, {value=2, text="Whitelist"}})
	tg:SetCallback("OnGroupSelected", function(self, _, value)
		self:ReleaseChildren()
		if value == 1 then
			private:DrawGeneralSettings(self)
		elseif value == 2 then
			private:DrawWhitelistSettings(self)
		end
	end)
	container:AddChild(tg)
	tg:SelectTab(1)
end

function private:DrawGeneralSettings(container)
	local page = {
		{
			type = "ScrollFrame",
			layout = "list",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = "General Options",
					children = {
						{
							type = "CheckBox",
							label = "Cancel Auctions with Bids",
							settingInfo = { TSM.db.global, "cancelWithBid" },
							tooltip = "Will cancel auctions even if they have a bid on them, you will take an additional gold cost if you cancel an auction with bid.",
						},
						{
							type = "CheckBox",
							label = "Round Normal Price",
							settingInfo = { TSM.db.global, "roundNormalPrice" },
							tooltip = "If checked, whenever you post an item at its normal price, the buyout will be rounded up to the nearest gold.",
						},
						{
							type = "CheckBox",
							label = "Disable Invalid Price Warnings",
							settingInfo = { TSM.db.global, "disableInvalidMsg" },
							relativeWidth = 1,
							tooltip = "If checked, TSM will not print out a chat message when you have an invalid price for an item. However, it will still show as invalid in the log.",
						},
						{
							type = "Dropdown",
							label = "Scan Complete Sound",
							list = TSMAPI:GetSounds(),
							settingInfo = { TSM.db.global, "scanCompleteSound" },
							tooltip = "Play the selected sound when a post / cancel scan is complete and items are ready to be posted / canceled (the gray bar is all the way across).",
						},
						{
							type = "Button",
							text = "Test Selected Sound",
							callback = function() TSMAPI:DoPlaySound(TSM.db.global.scanCompleteSound) end,
						},
						{
							type = "Dropdown",
							label = "Confirm Complete Sound",
							list = TSMAPI:GetSounds(),
							settingInfo = { TSM.db.global, "confirmCompleteSound" },
							tooltip = "Play the selected sound when all posts / cancels are confirmed for a post / cancel scan.",
						},
						{
							type = "Button",
							text = "Test Selected Sound",
							callback = function() TSMAPI:DoPlaySound(TSM.db.global.confirmCompleteSound) end,
						},
					},
				},
			},
		},
	}

	TSMAPI.GUI:BuildOptions(container, page)
end

function private:DrawWhitelistSettings(container)
	local function AddPlayer(self, _, value)
		value = string.trim(strlower(value or ""))
		if value == "" then return TSM:Print("No name entered.") end

		if TSM.db.factionrealm.whitelist[value] then
			TSM:Printf("The player \"%s\" is already on your whitelist.", TSM.db.factionrealm.whitelist[value])
			return
		end

		for player in pairs(TSM.db.factionrealm.player) do
			if strlower(player) == value then
				TSM:Printf("You do not need to add \"%s\", alts are whitelisted automatically.", player)
				return
			end
		end

		TSM.db.factionrealm.whitelist[strlower(value)] = value
		container:Reload()
	end

	local page = {
		{
			-- scroll frame to contain everything
			type = "ScrollFrame",
			layout = "List",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = "Help",
					children = {
						{
							type = "Label",
							relativeWidth = 1,
							fontObject = GameFontNormal,
							text = "Whitelists allow you to set other players besides you and your alts that you do not want to undercut; however, if somebody on your whitelist matches your buyout but lists a lower bid it will still consider them undercutting.",
						},
						{
							type = "CheckBox",
							label = "Match Whitelist Players",
							settingInfo = { TSM.db.global, "matchWhitelist" },
							tooltip = "If enabled, instead of not posting when a whitelisted player has an auction posted, Auctioning will match their price.",
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = "Add player",
					children = {
						{
							type = "EditBox",
							label = "Player Name",
							relativeWidth = 1,
							callback = AddPlayer,
							tooltip = "Add a new player to your whitelist.",
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = "Whitelist",
					children = {},
				},
			},
		},
	}

	for name in pairs(TSM.db.factionrealm.whitelist) do
		tinsert(page[1].children[3].children,
			{
				type = "Label",
				text = TSM.db.factionrealm.whitelist[name],
				fontObject = GameFontNormal,
			})
		tinsert(page[1].children[3].children,
			{
				type = "Button",
				text = "Delete",
				relativeWidth = 0.3,
				callback = function(self)
					TSM.db.factionrealm.whitelist[name] = nil
					container:Reload()
				end,
			})
	end

	if #(page[1].children[3].children) == 0 then
		tinsert(page[1].children[3].children,
			{
				type = "Label",
				text = "You do not have any players on your whitelist yet.",
				fontObject = GameFontNormal,
				relativeWidth = 1,
			})
	end

	TSMAPI.GUI:BuildOptions(container, page)
end



-- ============================================================================
-- Operation Options
-- ============================================================================

function Options:GetOperationOptionsInfo()
	local description = "Auctioning operations contain settings for posting, canceling, and resetting items in a group. Type the name of the new operation into the box below and hit 'enter' to create a new Auctioning operation."
	local tabInfo = {
		{text = "General", callback = private.DrawOperationGeneral},
		{text = "Post", callback = private.DrawOperationPost},
		{text = CANCEL, callback = private.DrawOperationCancel},
		{text = "Reset", callback = private.DrawOperationReset},
	}
	local relationshipInfo = {
		{
			label = "General Settings",
			{ key = "matchStackSize", label = "Match Stack Size" },
			{ key = "ignoreLowDuration", label = "Ignore Low Duration Auctions" },
			{ key = "blacklist", label = "Blacklisted Players" },
		},
		{
			label = "Post Settings",
			{ key = "duration", label = "Duration" },
			{ key = "postCap", label = "Post Cap" },
			{ key = "stackSize", label = "Stack Size" },
			{ key = "stackSizeIsCap", label = "Allow Partial Stack" },
			{ key = "keepQuantity", label = "Keep Quantity" },
			{ key = "keepQtySources", label = "Sources to Include in Keep Quantity" },
			{ key = "maxExpires", label = "Max Expires" },
			{ key = "bidPercent", label = "Bid Percent" },
			{ key = "undercut", label = "Undercut Amount" },
			{ key = "minPrice", label = "Minimum Price" },
			{ key = "priceReset", label = "When Below Minimum" },
			{ key = "maxPrice", label = "Maximum Price" },
			{ key = "aboveMax", label = "When Above Maximum" },
			{ key = "normalPrice", label = "Normal Price" },
		},
		{
			label = "Cancel Settings",
			{ key = "cancelUndercut", label = "Cancel Undercut Auctions" },
			{ key = "keepPosted", label = "Keep Posted" },
			{ key = "cancelRepost", label = "Cancel to Repost Higher" },
			{ key = "cancelRepostThreshold", label = "Repost Higher Threshold" },
		},
		{
			label = "Reset Settings",
			{ key = "resetEnabled", label = "Enable Reset Scan" },
			{ key = "resetMaxQuantity", label = "Max Quantity to Buy" },
			{ key = "resetMaxInventory", label = "Max Inventory Quantity" },
			{ key = "resetMaxCost", label = "Max Reset Cost" },
			{ key = "resetMinProfit", label = "Min Reset Profit" },
			{ key = "resetResolution", label = "Price Resolution" },
			{ key = "resetMaxItemCost", label = "Max Cost Per Item" },
		},
	}
	return description, tabInfo, relationshipInfo
end

function private.DrawOperationGeneral(container, operationName)
	local operation = TSM.operations[operationName]
	local durationList = { [0] = "<none>" }
	for i = 1, 3 do -- go up to long duration
		durationList[i] = format("%s (%s)", _G["AUCTION_TIME_LEFT" .. i], _G["AUCTION_TIME_LEFT" .. i .. "_DETAIL"])
	end

	local page = {
		{
			type = "ScrollFrame",
			layout = "list",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = "General Operation Options",
					children = {
						{
							type = "CheckBox",
							label = "Match Stack Size",
							settingInfo = { operation, "matchStackSize" },
							disabled = operation.relationships.matchStackSize,
							tooltip = "If checked, Auctioning will ignore all auctions that are posted at a different stack size than your auctions. For example, if there are stacks of 1, 5, and 20 up and you're posting in stacks of 1, it'll ignore all stacks of 5 and 20.",
						},
						{
							type = "Dropdown",
							label = "Ignore Low Duration Auctions",
							settingInfo = { operation, "ignoreLowDuration" },
							list = durationList,
							disabled = operation.relationships.ignoreLowDuration,
							tooltip = "Any auctions at or below the selected duration will be ignored. Selecting \"<none>\" will cause no auctions to be ignored based on duration.",
						},
						{
							type = "EditBox",
							label = "Blacklisted Players",
							settingInfo = { operation, "blacklist" },
							relativeWidth = 1,
							disabled = operation.relationships.blacklist,
							tooltip = "This is a comma-separated list of players which you'd like to blacklist. This means that Auctioning will ignore your minimum price if the cheapest auction is posted by somebody on your blacklist and undercut them no matter what price they are posting at.",
						},
					},
				},
			},
		},
	}

	TSMAPI.GUI:BuildOptions(container, page)
end

function private.DrawOperationPost(container, operationName)
	local operation = TSM.operations[operationName]
	local page = {
		{
			type = "ScrollFrame",
			layout = "list",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = "Auction Settings",
					children = {
						{
							type = "Dropdown",
							label = "Duration",
							settingInfo = { operation, "duration" },
							list = { [12] = AUCTION_DURATION_ONE, [24] = AUCTION_DURATION_TWO, [48] = AUCTION_DURATION_THREE },
							disabled = operation.relationships.duration,
							tooltip = "How long auctions should be up for.",
						},
						{
							type = "Slider",
							label = "Post Cap",
							settingInfo = { operation, "postCap" },
							disabled = operation.relationships.postCap,
							min = 0,
							max = 200,
							step = 1,
							tooltip = "How many auctions at the lowest price tier can be up at any one time. Setting this to 0 disables posting for any groups this operation is applied to.",
						},
						{
							type = "Slider",
							label = "Stack Size",
							settingInfo = { operation, "stackSize" },
							disabled = operation.relationships.stackSize,
							min = 1,
							max = 200,
							step = 1,
							tooltip = "How many items should be in a single auction, 20 will mean they are posted in stacks of 20.",
						},
						{
							type = "CheckBox",
							label = "Allow Partial Stack",
							settingInfo = { operation, "stackSizeIsCap" },
							disabled = operation.relationships.stackSizeIsCap,
							tooltip = "If enabled, a partial stack will be posted if you don't have enough for a full stack. This has no effect if the stack size is 1.",
						},
						{
							type = "HeadingLine",
						},
						{
							type = "Slider",
							label = "Keep Quantity",
							settingInfo = { operation, "keepQuantity" },
							disabled = operation.relationships.keepQuantity,
							min = 0,
							max = 5000,
							step = 1,
							tooltip = "How many items you want to keep in your bags (and additional sources) and not have Auctioning post.",
						},
						{
							type = "Dropdown",
							label = "Sources to Include in Keep Quantity",
							disabled = operation.relationships.keepQtySources,
							relativeWidth = 0.5,
							list = {bank=BANK, guild=GUILD},
							value = operation.keepQtySources,
							multiselect = true,
							callback = function(_, _, key, value)
								operation.keepQtySources[key] = value
							end,
						},
						{
							type = "HeadingLine",
						},
						{
							type = "Slider",
							label = "Max Expires",
							settingInfo = { operation, "maxExpires" },
							disabled = operation.relationships.maxExpires or not TSMAPI:HasModule("Accounting"),
							min = 0,
							max = 5000,
							step = 1,
							tooltip = "Items will not be posted after they have expired this number of times in a row. A value of 0 will disable this feature.",
						},
					},
				},
				{
					type = "Spacer",
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = "Posting Price Settings",
					children = {
						{
							type = "Slider",
							label = "Bid Percent",
							settingInfo = { operation, "bidPercent" },
							isPercent = true,
							min = 0.01,
							max = 1,
							step = 0.01,
							disabled = operation.relationships.bidPercent,
							tooltip = "Percentage of the buyout as bid, if you set this to 90% then a 100g buyout will have a 90g bid.",
						},
						{
							type = "EditBox",
							label = "Undercut Amount",
							settingInfo = { operation, "undercut" },
							acceptCustom = true,
							disabled = operation.relationships.undercut,
							tooltip = "How much to undercut other auctions by. Format is in \"#g#s#c\". For example, \"50g30s\" means 50 gold, 30 silver, and no copper.",
						},
						{
							type = "HeadingLine",
						},
						{
							type = "EditBox",
							label = "Minimum Price",
							settingInfo = { operation, "minPrice" },
							acceptCustom = true,
							disabled = operation.relationships.minPrice,
							tooltip = "The lowest price you want an item to be posted for. Auctioning will not undercut auctions below this price.",
						},
						{
							type = "Dropdown",
							label = "When Below Minimum",
							list = { ["none"] = "Don't Post Items", ["minPrice"] = "Post at Minimum Price", ["maxPrice"] = "Post at Maximum Price", ["normalPrice"] = "Post at Normal Price", ["ignore"] = "Ignore Auctions Below Min" },
							settingInfo = { operation, "priceReset" },
							disabled = operation.relationships.priceReset,
							tooltip = "This dropdown determines what Auctioning will do when the market for an item goes below your minimum price. You can not post the items, post at one of your configured prices, or have Auctioning ignore all the auctions below your minimum price (and likely undercut the lowest auction above your mimimum price).",
						},
						{
							type = "EditBox",
							label = "Maximum Price",
							settingInfo = { operation, "maxPrice" },
							acceptCustom = true,
							disabled = operation.relationships.maxPrice,
							tooltip = "The maximum price you want an item to be posted for. Auctioning will not undercut auctions above this price.",
						},
						{
							type = "Dropdown",
							label = "When Above Maximum",
							list = { ["none"] = "Don't Post Items", ["minPrice"] = "Post at Minimum Price", ["maxPrice"] = "Post at Maximum Price", ["normalPrice"] = "Post at Normal Price" },
							settingInfo = { operation, "aboveMax" },
							disabled = operation.relationships.aboveMax,
							tooltip = "This dropdown determines what Auctioning will do when the market for an item goes above your maximum price. You can post the items at one of your configured prices.",
						},
						{
							type = "EditBox",
							label = "Normal Price",
							settingInfo = { operation, "normalPrice" },
							acceptCustom = true,
							disabled = operation.relationships.normalPrice,
							tooltip = "Price to post at if there are none of an item currently on the AH.",
						},
					},
				},
			},
		},
	}

	TSMAPI.GUI:BuildOptions(container, page)
end

function private.DrawOperationCancel(container, operationName)
	local operation = TSM.operations[operationName]
	local page = {
		{
			type = "ScrollFrame",
			layout = "list",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = "Cancel Settings",
					children = {
						{
							type = "CheckBox",
							label = "Cancel Undercut Auctions",
							settingInfo = { operation, "cancelUndercut" },
							callback = function() container:Reload() end,
							disabled = operation.relationships.cancelUndercut,
							tooltip = "If checked, a cancel scan will cancel any auctions which have been undercut and are still above your minimum price.",
						},
						{
							type = "Slider",
							label = "Keep Posted",
							settingInfo = { operation, "keepPosted" },
							disabled = not operation.cancelUndercut or operation.relationships.keepPosted,
							min = 0,
							max = 500,
							step = 1,
							tooltip = "This number of undercut auctions will be kept on the auction house (not canceled) when doing a cancel scan.",
						},
						{
							type = "CheckBox",
							label = "Cancel to Repost Higher",
							settingInfo = { operation, "cancelRepost" },
							callback = function() container:Reload() end,
							disabled = operation.relationships.cancelRepost,
							tooltip = "If checked, a cancel scan will cancel any auctions which can be reposted for a higher price.",
						},
						{
							type = "EditBox",
							label = "Repost Higher Threshold",
							settingInfo = { operation, "cancelRepostThreshold" },
							disabled = not operation.cancelRepost or operation.relationships.cancelRepostThreshold,
							acceptCustom = true,
							tooltip = "If an item can't be posted for at least this amount higher than its current value, it won't be canceled to repost higher.",
						},
					},
				},
			},
		},
	}

	TSMAPI.GUI:BuildOptions(container, page)
end

function private.DrawOperationReset(container, operationName)
	local operation = TSM.operations[operationName]
	local page = {
		{
			type = "ScrollFrame",
			layout = "list",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = "General Reset Settings",
					children = {
						{
							type = "CheckBox",
							label = "Enable Reset Scan",
							relativeWidth = 1,
							settingInfo = { operation, "resetEnabled" },
							callback = function() container:Reload() end,
							disabled = operation.relationships.resetEnabled,
							tooltip = "If checked, groups which the opperation applies to will be included in a reset scan.",
						},
						{
							type = "Slider",
							label = "Max Quantity to Buy",
							settingInfo = { operation, "resetMaxQuantity" },
							disabled = not operation.resetEnabled or operation.relationships.resetMaxQuantity,
							min = 1,
							max = 5000,
							step = 1,
							tooltip = "This is the maximum quantity of an item you want to buy in a single reset scan.",
						},
						{
							type = "Slider",
							label = "Max Inventory Quantity",
							settingInfo = { operation, "resetMaxInventory" },
							disabled = not operation.resetEnabled or operation.relationships.resetMaxInventory,
							min = 1,
							max = 5000,
							step = 1,
							tooltip = "This is the maximum quantity of an item you want to have in your inventory after a reset scan.",
						},
						{
							type = "EditBox",
							label = "Max Reset Cost",
							settingInfo = { operation, "resetMaxCost" },
							disabled = not operation.resetEnabled or operation.relationships.resetMaxCost,
							acceptCustom = true,
							tooltip = "The maximum amount that you want to spend in order to reset a particular item. This is the total amount, not a per-item amount.",
						},
						{
							type = "EditBox",
							label = "Min Reset Profit",
							settingInfo = { operation, "resetMinProfit" },
							disabled = not operation.resetEnabled or operation.relationships.resetMinProfit,
							acceptCustom = true,
							tooltip = "The minimum profit you would want to make from doing a reset. This is a per-item price where profit is the price you reset to minus the average price you spent per item.",
						},
						{
							type = "EditBox",
							label = "Price Resolution",
							settingInfo = { operation, "resetResolution" },
							disabled = not operation.resetEnabled or operation.relationships.resetResolution,
							acceptCustom = true,
							tooltip = "This determines what size range of prices should be considered a single price point for the reset scan. For example, if this is set to 1s, an auction at 20g50s20c and an auction at 20g49s45c will both be considered to be the same price level.",
						},
						{
							type = "EditBox",
							label = "Max Cost Per Item",
							settingInfo = { operation, "resetMaxItemCost" },
							disabled = not operation.resetEnabled or operation.relationships.resetMaxItemCost,
							acceptCustom = true,
							tooltip = "This is the maximum amount you want to pay for a single item when reseting.",
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
					label = "Show Auctioning values in Tooltip",
					settingInfo = { options, "operationPrices" },
					tooltip = "If checked, the minimum, normal and maximum prices of the first operation for the item will be shown in tooltips.",
				},
			},
		},
	}

	TSMAPI.GUI:BuildOptions(container, page)
end