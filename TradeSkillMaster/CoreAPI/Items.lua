-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- This file contains APIs related to items (itemLinks/itemStrings/etc)

local TSM = select(2, ...)
local Items = TSM:NewModule("Items", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = {itemInfo={}, scanTooltip=nil, soulboundCache={}}
local STATIC_DATA = {classLookup={}, classIdLookup={}, inventorySlotIdLookup={}}

for classId, class in pairs({GetAuctionItemClasses()}) do
	STATIC_DATA.classIdLookup[strlower(class)] = classId
	STATIC_DATA.classLookup[class] = {}
	STATIC_DATA.classLookup[class]._index = classId
	for subClassId, subClass in pairs({GetAuctionItemSubClasses(classId)}) do
		STATIC_DATA.classLookup[class][subClass] = subClassId
	end
end

do
    local invTypes = {GetAuctionInvTypes(2,1)}
    for i = 1, #invTypes, 2 do
        TSMAPI:Assert(type(invTypes[i]) == "string")
        STATIC_DATA.inventorySlotIdLookup[strlower(_G[invTypes[i]])] = (i + 1) / 2
    end
end

local GET_ITEM_INFO_KEYS = {
	name = 1,
	link = 2,
	quality = 3,
	itemLevel = 4,
    minLevel = 5,
    class = 6,
    subClass = 7,
	maxStack = 8,
	equipSlot = 9,
	texture = 10,
	vendorPrice = 11
}


-- ============================================================================
-- TSMAPI gloabl constants
-- ============================================================================

TSMAPI.Item.CLASS_WEAPON = 1
TSMAPI.Item.CLASS_ARMOR = 2
TSMAPI.Item.CLASS_CONTAINER = 3
TSMAPI.Item.CLASS_CONSUMABLE = 4
TSMAPI.Item.CLASS_GLYPH = 5
TSMAPI.Item.CLASS_TRADEGOODS = 6
TSMAPI.Item.CLASS_AMMO = 7
TSMAPI.Item.CLASS_QUIVER = 8
TSMAPI.Item.CLASS_RECIPE = 9
TSMAPI.Item.CLASS_GEM = 10
TSMAPI.Item.CLASS_MISCELLANEOUS = 11
TSMAPI.Item.CLASS_QUESTITEM = 12

TSMAPI.Item.TRADEGOODS_SUBCLASS_ELEMENTAL = 1
TSMAPI.Item.TRADEGOODS_SUBCLASS_CLOTH = 2
TSMAPI.Item.TRADEGOODS_SUBCLASS_LEATHER = 3
TSMAPI.Item.TRADEGOODS_SUBCLASS_METAL_AND_STONE = 4
TSMAPI.Item.TRADEGOODS_SUBCLASS_MEAT = 5
TSMAPI.Item.TRADEGOODS_SUBCLASS_HERB = 6
TSMAPI.Item.TRADEGOODS_SUBCLASS_ENCHANTING = 7
TSMAPI.Item.TRADEGOODS_SUBCLASS_JEWELCRAFTING = 8
TSMAPI.Item.TRADEGOODS_SUBCLASS_PARTS = 9
TSMAPI.Item.TRADEGOODS_SUBCLASS_DEVICES = 10
TSMAPI.Item.TRADEGOODS_SUBCLASS_EXPLOSIVES = 11
TSMAPI.Item.TRADEGOODS_SUBCLASS_MATERIALS = 12
TSMAPI.Item.TRADEGOODS_SUBCLASS_OTHER = 13
TSMAPI.Item.TRADEGOODS_SUBCLASS_ARMOR_ENCHANTMENT = 14
TSMAPI.Item.TRADEGOODS_SUBCLASS_WEAPON_ENCHANTMENT = 15



-- ============================================================================
-- TSMAPI Functions
-- ============================================================================

function TSMAPI.Item:ToItemString(item)
	if not item then return end
	TSMAPI:Assert(type(item) == "number" or type(item) == "string", tostring(item))
	local result = nil

	if tonumber(item) then
		-- assume this is an itemId
		return "i:"..item
	else
		item = item:trim()
	end

	-- test if it's already (likely) an item string
    if strmatch(item, "^i:([0-9%-:]+)$") then
        item = gsub(gsub(item, ":0$", ""), ":0$", "") -- remove extra zeroes
		return item
	end

	result = strmatch(item, "^\124cff[0-9a-z]+\124[Hh](.+)\124h%[.+%]\124h\124r$")
	if result then
		-- it was a full item link which we've extracted the itemString from
		item = result
    end

	-- test if it's a shorter item string (without bonuses)
	result = strjoin(":", strmatch(item, "(i)tem:([0-9%-]+):[0-9%-]+:[0-9%-]+:[0-9%-]+:[0-9%-]+:[0-9%-]+:([0-9%-]+)"))
    if result and result ~= "" then
        result = gsub(gsub(result, ":0$", ""), ":0$", "") -- remove extra zeroes
		return result
	end
end

function TSMAPI.Item:ToBaseItemString(itemString, doGroupLookup)
	-- make sure it's a valid itemString
	itemString = TSMAPI.Item:ToItemString(itemString)
	if not itemString then return end

	local baseItemString = strmatch(itemString, "(i:%d+)")

	if not doGroupLookup or (TSM.db.profile.items[baseItemString] and not TSM.db.profile.items[itemString]) then
		-- either we're not doing a group lookup, or the base item is in a group and the specific item is not, so return the base item
		return baseItemString
	end
	return itemString
end

--- Attempts to get the itemID from a given itemLink/itemString.
-- @param itemLink The link or itemString for the item.
-- @return Returns the itemID as the first parameter. On error, will return nil as the first parameter and an error message as the second.
function TSMAPI.Item:ToItemID(itemString)
	itemString = TSMAPI.Item:ToItemString(itemString)
	if type(itemString) ~= "string" then return end
	return tonumber(strmatch(itemString, "^i:(%d+)"))
end

function TSMAPI.Item:IsSoulbound(...)
	local numArgs = select('#', ...)
	if numArgs == 0 then return end
	local bag, slot, itemString, ignoreBOA
	local firstArg = ...
	if type(firstArg) == "string" then
		TSMAPI:Assert(numArgs <= 2, "Too many arguments provided with itemString")
		itemString, ignoreBOA = ...
		itemString = TSMAPI.Item:ToItemString(itemString)
	elseif type(firstArg) == "number" then
		bag, slot, ignoreBOA = ...
		TSMAPI:Assert(slot, "Second argument must be slot within bag")
		TSMAPI:Assert(numArgs <= 3, "Too many arguments provided with bag / slot")
	else
		TSMAPI:Assert(false, "Invalid arguments")
	end
	if itemString then
		if not private.soulboundCache[itemString] then
			private.soulboundCache[itemString] = { result = nil, resultIgnoreBOA = nil }
		end
		if ignoreBOA and private.soulboundCache[itemString].resultIgnoreBOA ~= nil then
			return private.soulboundCache[itemString].resultIgnoreBOA
		elseif not ignoreBOA and private.soulboundCache[itemString].result ~= nil then
			return private.soulboundCache[itemString].result
		end
	end

	local scanTooltip = private.GetScanTooltip()
	local result = false
	if itemString then
		-- it's an itemString
		scanTooltip:SetHyperlink(private.ToWoWItemString(itemString))
	elseif bag and slot then
		local itemID = GetContainerItemID(bag, slot)
		local maxCharges
        if itemID then
            scanTooltip:SetItemByID(itemID)
			maxCharges = private:GetTooltipCharges(scanTooltip)
		end
		if bag == -1 then
			scanTooltip:SetInventoryItem("player", slot + 39)
		else
			scanTooltip:SetBagItem(bag, slot)
		end
		if maxCharges then
			if private:GetTooltipCharges(scanTooltip) ~= maxCharges then
				result = true
			end
		end
	else
		TSMAPI:Assert(false) -- should never get here
	end
	if result then
		return result
	end

	local numLines = scanTooltip:NumLines()
	for id=1, numLines do
		local text = private.GetTooltipText(_G[scanTooltip:GetName().."TextLeft"..id])
		if text then
			if (text == ITEM_BIND_ON_PICKUP and id < 4) or text == ITEM_SOULBOUND or text == ITEM_BIND_QUEST then
				result = true
			elseif not ignoreBOA and (text == ITEM_ACCOUNTBOUND or text == ITEM_BIND_TO_ACCOUNT or text == ITEM_BIND_TO_BNETACCOUNT or text == ITEM_BNETACCOUNTBOUND) then
				result = true
			end
		end
	end

	if not result and numLines <= 1 then
		-- the tooltip didn't fully load
		return nil
	elseif itemString then
		if ignoreBOA then
			private.soulboundCache[itemString].resultIgnoreBOA = result
		elseif not ignoreBOA then
			private.soulboundCache[itemString].result = result
		end
	end

	return result
end

function TSMAPI.Item:IsCraftingReagent(itemLink)
	-- workaround for recipes having the item info and crafting reagent in the tooltip
	if TSMAPI.Item:GetClassId(itemLink) == TSMAPI.Item.CLASS_RECIPE then
		return false
	end

	local scanTooltip = private.GetScanTooltip()
	scanTooltip:SetHyperlink(itemLink)

	local result = nil
	for id = 1, scanTooltip:NumLines() do
		local text = private.GetTooltipText(_G[scanTooltip:GetName().."TextLeft"..id])
		if text and (text == PROFESSIONS_USED_IN_COOKING) then
			result = true
			break
		end
	end
	return result
end

function TSMAPI.Item:GetVendorCost(itemString)
	return itemString and TSM.db.global.vendorItems[itemString]
end

function TSMAPI.Item:IsDisenchantable(itemString)
	if not itemString or TSM.STATIC_DATA.notDisenchantable[itemString] then return end
    local quality = TSMAPI.Item:GetQuality(itemString) or 0
    local classId = TSMAPI.Item:GetClassId(itemString)
	return quality >= ITEM_QUALITY_UNCOMMON and (classId == TSMAPI.Item.CLASS_ARMOR or classId == TSMAPI.Item.CLASS_WEAPON)
end

function TSMAPI.Item:GetItemClasses()
	return {GetAuctionItemClasses()}
end

function TSMAPI.Item:GetItemSubClasses(classId)
	return {GetAuctionItemSubClasses(classId)}
end

function TSMAPI.Item:GetItemClassInfo(classId)
    return select(classId, GetAuctionItemClasses())
end

function TSMAPI.Item:GetItemSubClassInfo(classId, subClassId)
    return select(subClassId, GetAuctionItemSubClasses(classId))
end

function TSMAPI.Item:GetClassIdFromClassString(class)
	return STATIC_DATA.classIdLookup[strlower(class)]
end

function TSMAPI.Item:GetSubClassIdFromSubClassString(subClass, classId)
	if not classId then return end
	local class = TSMAPI.Item:GetItemClassInfo(classId)
	if not STATIC_DATA.classLookup[class] then return end
	for str, index in pairs(STATIC_DATA.classLookup[class]) do
		if strlower(str) == strlower(subClass) then
			return index
		end
	end
end

function TSMAPI.Item:GetInventorySlotIdFromInventorySlotString(slot)
	return STATIC_DATA.inventorySlotIdLookup[strlower(slot)]
end



-- ============================================================================
-- Module Functions
-- ============================================================================

function Items:OnEnable()
	Items:RegisterEvent("MERCHANT_SHOW", "ScanMerchant")
	local itemString = next(TSM.db.global.vendorItems)
	if itemString and TSMAPI.Item:ToItemString(itemString) ~= itemString then
		-- they just upgraded to TSM3, so wipe the table
		wipe(TSM.db.global.vendorItems)
	end

	for itemString, cost in pairs(TSM.STATIC_DATA.preloadedVendorCosts) do
		TSM.db.global.vendorItems[itemString] = TSM.db.global.vendorItems[itemString] or cost
    end
end

function Items:ScanMerchant(event)
	for i=1, GetMerchantNumItems() do
		local itemString = TSMAPI.Item:ToItemString(GetMerchantItemLink(i))
		if itemString then
			local price, quantity, _, _, _, extendedCost = select(3, GetMerchantItemInfo(i))
			if price > 0 and not extendedCost then
				TSM.db.global.vendorItems[itemString] = TSMAPI.Util:Round(price / quantity)
			else
				TSM.db.global.vendorItems[itemString] = nil
			end
		end
	end
	if event then
		TSMAPI.Delay:AfterTime("scanMerchantDelay", 1, Items.ScanMerchant)
	end
end



-- ============================================================================
-- Item Cache Helper Functions
-- ============================================================================

function private.GetCachedItemInfo(itemString)
	if not itemString then return end
    if not private.itemInfo[itemString] then
        if strmatch(itemString, "^i:") then
            local _, itemId, rand = (":"):split(itemString)
            if rand then
                private.StoreGetItemInfoResult(itemString, GetItemInfo(strjoin(":", "item", itemId, 0, 0, 0, 0, 0, rand)))
            else
                private.StoreGetItemInfoResult(itemString, GetItemInfo(itemId))
            end
        else
            TSMAPI:Assert(false, format("Invalid item string: '%s'", tostring(itemString)))
        end
	end
	return private.itemInfo[itemString]
end

function private.StoreGetItemInfoResult(itemString, ...)
	TSMAPI:Assert(type(itemString) == "string")
    if select('#', ...) == 0 then return end
    private.itemInfo[itemString] = {}
    for key, index in pairs(GET_ITEM_INFO_KEYS) do
        private.itemInfo[itemString][key] = select(index, ...)
    end
    private.itemInfo[itemString]._getInfoResult = true
end

function private.GetItemInfoKey(itemString, key)
	TSMAPI:Assert(GET_ITEM_INFO_KEYS[key])
	itemString = TSMAPI.Item:ToItemString(itemString)
	if not itemString then return end

	local info = private.GetCachedItemInfo(itemString)
	return info and info[key]
end

function TSMAPI.Item:FetchInfo(itemString)
    private.GetCachedItemInfo(TSMAPI.Item:ToItemString(itemString))
end

function TSMAPI.Item:HasInfo(info)
	if type(info) == "string" then
		return TSMAPI.Item:GetName(info)
	elseif type(info) == "table" then
		TSMAPI:Assert(#info > 0)
		local result = true
		-- don't stop when we find one that doesn't have info so that we
		-- still query the info from the server for every item
		for _, itemString in ipairs(info) do
			if not TSMAPI.Item:HasInfo(itemString) then
				result = false
			end
		end
		return result
	else
		TSMAPI:Assert(false, "Invalid argument")
	end
end

function TSMAPI.Item:GetName(itemString)
	local origItemString = itemString
	itemString = TSMAPI.Item:ToItemString(itemString)
	if not itemString then return end
	local baseItemString = TSMAPI.Item:ToBaseItemString(itemString)
	local info = private.GetCachedItemInfo(baseItemString)
	if info and itemString ~= baseItemString and not info._getInfoResult then
		tinsert(private.pendingItems, baseItemString)
	end
	local name = nil
	if (info and itemString == baseItemString) then
		-- This is either a pet or base item, just return what we have.
		name = info.name
	elseif info and info._getInfoResult then
		-- we have the base item info, so should be able to call GetItemInfo() for this version of the item
		name = GetItemInfo(private.ToWoWItemString(itemString))
	end
	if not name then
		-- if we got passed an item link or this is a base item and we have the item link, we can maybe extract the name from it
		name = strmatch(origItemString, "^\124cff[0-9a-z]+\124[Hh].+\124h%[(.+)%]\124h\124r$")
		if name == "" then
			name = nil
		end
		if not name and itemString == baseItemString and info and info.link then
			name = strmatch(info.link, "^\124cff[0-9a-z]+\124[Hh].+\124h%[(.+)%]\124h\124r$")
			if name == "" then
				name = nil
			end
		end
		if name == "Unknown Item" then
			name = nil
		end
	end
	return name
end

function TSMAPI.Item:GeneralizeLink(itemLink)
	local itemString = TSMAPI.Item:ToItemString(itemLink)
	if not itemString then return end
	if not strmatch(itemString, "i:[0-9]+:[0-9%-]+:[0-9]+") then
		-- swap out the itemString part of the link
		local leader, quality, _, name, trailer, trailer2, extra = ("\124"):split(itemLink)
		if trailer2 and not extra then
			return strjoin("\124", leader, quality, "H"..private.ToWoWItemString(itemString), name, trailer, trailer2)
		end
	end
	return TSMAPI.Item:GetLink(itemString)
end

function TSMAPI.Item:GetLink(itemString)
	itemString = TSMAPI.Item:ToItemString(itemString)
	if not itemString then return "?" end
	local baseItemString = TSMAPI.Item:ToBaseItemString(itemString)
	local info = private.GetCachedItemInfo(baseItemString)
	if info and itemString ~= baseItemString and not info._getInfoResult then
		tinsert(private.pendingItems, baseItemString)
	end
	local name, link = nil, nil
	if info then
		if itemString == baseItemString then
			link = info.link
			name = info.name
		elseif info._getInfoResult and strmatch(itemString, "^i:") then
			link = select(2, GetItemInfo(private.ToWoWItemString(itemString)))
		end
	end
	if link then
        return link
    elseif strmatch(itemString, "i:") then
		name = name or "Unknown Item"
		local color = "|cffff0000"
		if info and info.quality and info.quality >= 0 and ITEM_QUALITY_COLORS[info.quality] and (itemString == baseItemString or not strmatch(itemString, "i:[0-9]+:[0-9%-]+:[0-9]+")) then
			color = ITEM_QUALITY_COLORS[info.quality].hex
		end
		itemString = private.ToWoWItemString(itemString)
		return color.."|H"..itemString.."|h["..name.."]|h|r"
	end
	return "?"
end

function TSMAPI.Item:GetQuality(itemString)
	itemString = TSMAPI.Item:ToItemString(itemString)
	if not itemString then return end
	return private.GetItemInfoKey(itemString, "quality")
end

function TSMAPI.Item:GetItemLevel(itemString)
	itemString = TSMAPI.Item:ToItemString(itemString)
	if not itemString then return end
	return private.GetItemInfoKey(itemString, "itemLevel")
end

function TSMAPI.Item:GetMinLevel(itemString)
	itemString = TSMAPI.Item:ToItemString(itemString)
	if not itemString then return end
	return private.GetItemInfoKey(itemString, "minLevel")
end

function TSMAPI.Item:GetMaxStack(itemString)
	itemString = TSMAPI.Item:ToItemString(itemString)
	if not itemString then return end
	return private.GetItemInfoKey(itemString, "maxStack")
end

function TSMAPI.Item:GetEquipSlot(itemString)
	itemString = TSMAPI.Item:ToItemString(itemString)
	if not itemString then return end
	return private.GetItemInfoKey(itemString, "equipSlot")
end

function TSMAPI.Item:GetTexture(itemString)
	itemString = TSMAPI.Item:ToItemString(itemString)
	if not itemString then return end
	return private.GetItemInfoKey(itemString, "texture")
end

function TSMAPI.Item:GetVendorPrice(itemString)
	itemString = TSMAPI.Item:ToItemString(itemString)
	if not itemString then return end
	return private.GetItemInfoKey(itemString, "vendorPrice")
end

function TSMAPI.Item:GetClassId(itemString)
	itemString = TSMAPI.Item:ToItemString(itemString)
	if not itemString then return end
	return TSMAPI.Item:GetClassIdFromClassString(private.GetItemInfoKey(itemString, "class"))
end

function TSMAPI.Item:GetSubClassId(itemString)
	itemString = TSMAPI.Item:ToItemString(itemString)
	if not itemString then return end
	return TSMAPI.Item:GetSubClassIdFromSubClassString(private.GetItemInfoKey(itemString, "subClass"), TSMAPI.Item:GetClassId(itemString))
end

function TSMAPI.Item:GetStringFromName(itemName)
    TSMAPI:Assert(type(itemName) == "string")
    local itemLink = select(2, GetItemInfo(itemName))
    local itemString = ISMAPI.Item:ToItemString(itemLink)
    if not itemString then return end
    private.GetCachedItemInfo(itemString)

    return itemString
end


-- ============================================================================
-- Helper Functions
-- ============================================================================

function private.GetScanTooltip()
	if not TSMScanTooltip then
		CreateFrame("GameTooltip", "TSMScanTooltip", UIParent, "GameTooltipTemplate")
	end
	TSMScanTooltip:Show()
	TSMScanTooltip:SetClampedToScreen(false)
    TSMScanTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", 1000000, 100000)
    TSMScanTooltip.SetItemByID = function(self, itemID)
        if type(itemID) ~= "number" then return end
        self:SetHyperlink("item:"..tostring(itemID))
    end
	return TSMScanTooltip
end

function private:GetTooltipCharges(scanTooltip)
	for id = 1, scanTooltip:NumLines() do
		local text = private.GetTooltipText(_G[scanTooltip:GetName().."TextLeft"..id])
		local maxCharges = text and strmatch(text, "^([0-9]+) Charges?$")
		if maxCharges then
			return maxCharges
		end
	end
end

function private.GetTooltipText(text)
	local textStr = (text and text:GetText() or ""):trim()
	if textStr == "" then return end

	local r, g, b = text:GetTextColor()
	return textStr, floor(r * 256), floor(g * 256), floor(b * 256)
end

function private.ToWoWItemString(itemString)
    local _, itemId, rand = (":"):split(itemString)
	local level = UnitLevel("player")
	return "item:"..itemId..":0:0:0:0:0:"..(rand or "0")..":0:"..level
end
