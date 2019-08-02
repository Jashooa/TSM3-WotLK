-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_AuctionDB                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctiondb           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local Config = TSM:NewModule("Config")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_AuctionDB") -- loads the localization table

local DEFAULT_FILTERS = { name = nil, rarity = nil, class = nil, subClass = nil }

-- ============================================================================
-- Module Options
-- ============================================================================

function Config:Load(container)
	local tg = AceGUI:Create("TSMTabGroup")
	tg:SetLayout("Fill")
	tg:SetFullHeight(true)
	tg:SetFullWidth(true)
	tg:SetTabs({{value=1, text=L["Options"]}, {value=2, text=L["Search"]}})
	tg:SetCallback("OnGroupSelected", function(self, _, value)
		self:ReleaseChildren()
		if value == 1 then
			Config:LoadOptions(self)
		elseif value == 2 then
			Config:LoadSearch(self)
		end
	end)
	container:AddChild(tg)
	tg:SelectTab(1)
end

function Config:LoadOptions(container)
	local lastScanInfo
	if TSM.db.realm.lastCompleteScan > 0 then
		lastScanInfo = format(L["Last updated from in-game scan %s ago."], SecondsToTime(time() - TSM.db.realm.lastCompleteScan))
	else
		lastScanInfo = L["No scans found."]
	end
	local page = {
		{
			type = "ScrollFrame",
			layout = "Flow",
			children = {
				{
					type = "InlineGroup",
					title = L["Last Update Time"],
					layout = "Flow",
					children = {
						{
							type = "Label",
							text = lastScanInfo,
							relativeWidth = 1,
						},
					},
				},
				{
					type = "InlineGroup",
					title = L["General Options"],
					layout = "Flow",
					children = {
						{
							type = "CheckBox",
							label = L["Show AuctionDB AH Tab (Requires Reload)"],
							settingInfo = { TSM.db.global, "showAHTab" },
							relativeWidth = 1,
							tooltip = L["If checked, AuctionDB will add a tab to the AH to allow for in-game scans. If you are using the TSM app exclusively for your scans, you may want to hide it by unchecking this option. This option requires a reload to take effect."],
                        },
						{
							type = "CheckBox",
							label = L["Display Grey Items in Search"],
                            settingInfo = { TSM.db.global, "displayGreys" },
                            relativeWidth = 1,
							tooltip = L["If checked, poor quality items will be shown in AuctionDB search data."],
						},
					},
                },
			},
		},
	}

	TSMAPI.GUI:BuildOptions(container, page)
end

function Config:IsItemFiltered(itemString, filters)
	local name = TSMAPI.Item:GetName(itemString)
    local quality = TSMAPI.Item:GetQuality(itemString) or -1
    local class = TSMAPI.Item:GetClassId(itemString)
    local subClass = TSMAPI.Item:GetSubClassId(itemString)
	if not name then return true end

    if filters.name and not strfind(strlower(name), strlower(filters.name)) then
		return true
	end

    if filters.rarity and filters.rarity ~= quality then
		return true
	end

    if not TSM.db.global.displayGreys and quality == 0 and not filters.rarity then
		return true
    end

    if filters.class and filters.class ~= class and not filters.subClass then
        return true
    end

    if (filters.class and filters.class ~= class) or (filters.subClass and filters.subClass ~= subClass) then
        return true
    end
end

function Config:GetSearchSTData(filters)
    local stData = {}
    for itemString, data in pairs(TSM.realmData) do
        if not Config:IsItemFiltered(itemString, filters) then
            local timeDiff = data.lastScan and SecondsToTime(time() - data.lastScan)
            local name = TSMAPI.Item:GetName(itemString) or itemString
            local row = {
                cols = {
                    {
                        value = TSMAPI.Item:GetLink(itemString) or name,
                        sortArg = name,
                    },
                    {
                        value = TSMAPI:MoneyToString(data.minBuyout) or "---",
                        sortArg = data.minBuyout or 0,
                    },
                    {
                        value = TSMAPI:MoneyToString(data.marketValue) or "---",
                        sortArg = data.marketValue or 0,
                    },
                    {
                        value = (timeDiff and TSMAPI.Design:GetInlineColor("link2") .. format(L["%s ago"], timeDiff) .. "|r" or TSMAPI.Design:GetInlineColor("link2") .. "---|r"),
                        sortArg = data.lastScan and (time() - data.lastScan) or 0,
                    },
                },
                itemString = itemString,
            }
            tinsert(stData, row)
        end
    end
	return stData
end

function Config:LoadSearch(container)
	local rarityList = {[-1]=L["None"]}
	for i = 0, getn(ITEM_QUALITY_COLORS)-2 do
		rarityList[i] = _G[format("ITEM_QUALITY%d_DESC", i)]
    end

	local classList, subClassList = {[0]=L["None"]}, {[0]={}}
	for i, className in ipairs({ GetAuctionItemClasses() }) do
		classList[i] = className
		subClassList[i] = {}
		for j, subClassName in ipairs({ GetAuctionItemSubClasses(i) }) do
			subClassList[i][j] = subClassName
        end
        subClassList[i][0]=L["None"]
	end

    local filters = CopyTable(DEFAULT_FILTERS)

    local stCols = {
        {
            name = L["Name"],
            width = 0.40,
            headAlign="LEFT",
        },
        {
            name = L["Min Buyout"],
            width = 0.19,
            headAlign="LEFT",
        },
        {
            name = L["Market Value"],
            width = 0.19,
            headAlign="LEFT",
        },
        {
            name = L["Last Scanned"],
            width = 0.22,
            headAlign="LEFT",
        },
        defaultSort = 1,
    }

	local stHandlers = {
        OnClick = function(_, data, _, button)
            if data and IsShiftKeyDown() and button == "RightButton" then
                TSM.realmData[data.itemString] = nil
                TSM:Printf(L["Removed %s from AuctionDB."], TSMAPI.Item:GetLink(data.itemString) or data.itemString)
            end
        end,
        OnEnter = function(_, data, self)
            if not data then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(TSMAPI.Item:ToWoWItemString(data.itemString))
            GameTooltip:AddLine(TSMAPI.Design:GetInlineColor("link2") .. L["Shift-Right-Click to clear all data for this item from AuctionDB."] .. "|r")
            GameTooltip:Show()
        end,
        OnLeave = function()
            GameTooltip:ClearLines()
            GameTooltip:Hide()
        end
    }

	local page = {
		{
			type = "SimpleGroup",
			layout = "TSMFillList",
			children = {
				{
					type = "SimpleGroup",
					layout = "Flow",
					children = {
                        {
                            type = "Label",
                            text = L["You can use this page to lookup an item or group of items in the AuctionDB database. Note that this does not perform a live search of the AH."],
                            relativeWidth = 1,
                        },
                        {
                            type = "HeadingLine",
                        },
						{
							type = "EditBox",
							label = L["Search"],
							relativeWidth = 0.40,
							onTextChanged = true,
							callback = function(_, _, value)
								value = value:trim()
								if value == "" then
									filters.name = nil
								else
									filters.name = TSMAPI.Util:StrEscape(value)
								end
								TSMAPI.GUI:UpdateTSMScrollingTableData("TSM_AUCTIONDB_ST", Config:GetSearchSTData(filters))
							end,
						},
						{
							type = "Dropdown",
							label = L["Rarity"],
							relativeWidth = 0.16,
							list = rarityList,
							value = -1,
							callback = function(_, _, key)
								if key > -1 then
									filters.rarity = key
								else
									filters.rarity = nil
								end
								TSMAPI.GUI:UpdateTSMScrollingTableData("TSM_AUCTIONDB_ST", Config:GetSearchSTData(filters))
							end,
                        },
                        {
                            type = "Dropdown",
                            label = L["Class"],
                            list = classList,
                            value = 0,
                            relativeWidth = 0.22,
                            callback = function(self, _, value)
                                local subClassDropdown = container.children[1].children[1].children[6]
                                if value ~= filters.class then
                                    filters.subClass = nil
                                end
                                if value == 0 then
                                    filters.class = nil
                                    subClassDropdown:SetList({})
                                    subClassDropdown:SetValue(0)
                                    subClassDropdown:SetDisabled(true)
                                else
                                    filters.class = value
                                    subClassDropdown:SetList(subClassList[value])
                                    subClassDropdown:SetValue(0)
                                    subClassDropdown:SetDisabled(false)
                                end
                                TSMAPI.GUI:UpdateTSMScrollingTableData("TSM_AUCTIONDB_ST", Config:GetSearchSTData(filters))
                            end,
                        },
                        {
                            type = "Dropdown",
                            label = L["SubClass"],
                            disabled = true,
                            value = 0,
                            relativeWidth = 0.22,
                            callback = function(_, _, value)
                                if value == 0 then
                                    filters.subClass = nil
                                else
                                    filters.subClass = value
                                end
                                TSMAPI.GUI:UpdateTSMScrollingTableData("TSM_AUCTIONDB_ST", Config:GetSearchSTData(filters))
                            end,
                        },
					},
				},
				{
					type = "ScrollingTable",
					tag = "TSM_AUCTIONDB_ST",
					colInfo = stCols,
					handlers = stHandlers,
					defaultSort = stCols.defaultSort or 1,
					selectionDisabled = true,
				},
			},
		},
	}

	TSMAPI.GUI:BuildOptions(container, page)
	TSMAPI.GUI:UpdateTSMScrollingTableData("TSM_AUCTIONDB_ST", Config:GetSearchSTData(filters))
end



-- ============================================================================
-- Tooltip Options
-- ============================================================================

function Config:LoadTooltipOptions(container, options)
	local page = {
		{
			type = "SimpleGroup",
			layout = "Flow",
			fullHeight = true,
			children = {
				{
					type = "CheckBox",
					label = L["Display min buyout in tooltip."],
					settingInfo = { options, "minBuyout" },
					relativeWidth = 1,
					tooltip = L["If checked, the lowest buyout value seen in the last scan of the item will be displayed."],
				},
				{
					type = "CheckBox",
					label = L["Display market value in tooltip."],
					settingInfo = { options, "marketValue" },
					relativeWidth = 1,
					tooltip = L["If checked, the market value of the item will be displayed"],
				},
			},
		},
	}

	TSMAPI.GUI:BuildOptions(container, page)
end