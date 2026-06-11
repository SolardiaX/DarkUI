local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Slot Item Level
------------------------------------------------------------------------

local module = E:Module("Misc"):Sub("SlotItemLevel")

local cfg = C.misc

local gsub, strfind, strmatch, strsplit = gsub, strfind, strmatch, strsplit
local tonumber, format = tonumber, format
local GetInventoryItemLink = GetInventoryItemLink

local itemLevelPattern = "^" .. gsub(ITEM_LEVEL, "%%d", "")
local equipped = {}

local fontObject = CreateFont("DarkUI_iLvLFont")
fontObject:SetFontObject("SystemFont_Outline_Small")

local function getRealItemLevel(slotId, unit)
    local data = C_TooltipInfo.GetInventoryItem(unit, slotId)
    if not data then return nil end

    for i = 2, #data.lines do
        local lineData = data.lines[i]
        local text = lineData and lineData.leftText
        if text then
            if strfind(text, itemLevelPattern) then
                local level = strmatch(text, "(%d+)%)?$")
                if level and tonumber(level) > 0 then
                    return level
                end
            end
        end
    end
end

local function updateItems(unit, frame)
    for i = 1, 17 do
        if i ~= 4 then -- skip shirt
            local itemLink = GetInventoryItemLink(unit, i)
            local needsUpdate = (unit ~= "player") or (equipped[i] ~= itemLink) or (frame[i] and frame[i]:GetText() == nil)

            if needsUpdate then
                if unit == "player" then equipped[i] = itemLink end

                local realItemLevel = getRealItemLevel(i, unit) or ""
                if realItemLevel ~= "" and tonumber(realItemLevel) == 1 then
                    realItemLevel = ""
                end

                local color = "|cffFFFF00"
                if itemLink and realItemLevel ~= "" and tonumber(realItemLevel) > 0 then
                    local _, _, enchant = strsplit(":", itemLink)
                    if i == INVSLOT_BACK or i == INVSLOT_CHEST or i == INVSLOT_MAINHAND
                        or i == INVSLOT_FINGER1 or i == INVSLOT_FINGER2
                        or i == INVSLOT_WRIST or i == INVSLOT_FEET or i == INVSLOT_LEGS then
                        if enchant and enchant == "" then
                            color = "|cffFF0000"
                        end
                    end
                end

                if frame[i] then
                    frame[i]:SetText(color .. realItemLevel)
                end
            end
        end
    end
end

local playerSlots = {
    [1] = "CharacterHeadSlot",
    [2] = "CharacterNeckSlot",
    [3] = "CharacterShoulderSlot",
    [5] = "CharacterChestSlot",
    [6] = "CharacterWaistSlot",
    [7] = "CharacterLegsSlot",
    [8] = "CharacterFeetSlot",
    [9] = "CharacterWristSlot",
    [10] = "CharacterHandsSlot",
    [11] = "CharacterFinger0Slot",
    [12] = "CharacterFinger1Slot",
    [13] = "CharacterTrinket0Slot",
    [14] = "CharacterTrinket1Slot",
    [15] = "CharacterBackSlot",
    [16] = "CharacterMainHandSlot",
    [17] = "CharacterSecondaryHandSlot",
}

local inspectSlots = {
    [1] = "InspectHeadSlot",
    [2] = "InspectNeckSlot",
    [3] = "InspectShoulderSlot",
    [5] = "InspectChestSlot",
    [6] = "InspectWaistSlot",
    [7] = "InspectLegsSlot",
    [8] = "InspectFeetSlot",
    [9] = "InspectWristSlot",
    [10] = "InspectHandsSlot",
    [11] = "InspectFinger0Slot",
    [12] = "InspectFinger1Slot",
    [13] = "InspectTrinket0Slot",
    [14] = "InspectTrinket1Slot",
    [15] = "InspectBackSlot",
    [16] = "InspectMainHandSlot",
    [17] = "InspectSecondaryHandSlot",
}

local function createStrings(parent, slotTable)
    local frame = CreateFrame("Frame", nil, parent)
    for slotID, slotName in pairs(slotTable) do
        local slot = _G[slotName]
        if slot then
            frame:SetFrameLevel(slot:GetFrameLevel())
            local s = frame:CreateFontString(nil, "OVERLAY", "DarkUI_iLvLFont")
            s:SetPoint("TOP", slot, "TOP", 0, -2)
            frame[slotID] = s
        end
    end
    frame:Hide()
    return frame
end

------------------------------------------------------------------------
-- Flyout item levels
------------------------------------------------------------------------

local itemDB = {}
local function getFlyoutItemLevel(link, bag, slot)
    if itemDB[link] then return itemDB[link] end
    local level
    if bag and type(bag) == "string" then
        level = C_Item.GetCurrentItemLevel(ItemLocation:CreateFromEquipmentSlot(slot))
    else
        level = C_Item.GetCurrentItemLevel(ItemLocation:CreateFromBagAndSlot(bag, slot))
    end
    level = tonumber(level)
    itemDB[link] = level
    return level
end

local function setupFlyoutLevel(button, bag, slot)
    if not button.iLvl then
        button.iLvl = button:CreateFontString(nil, "OVERLAY", "DarkUI_iLvLFont")
        button.iLvl:SetPoint("TOP", 0, -2)
    end
    local link, level
    if bag then
        link = C_Container.GetContainerItemLink(bag, slot)
        if link then level = getFlyoutItemLevel(link, bag, slot) end
    else
        link = GetInventoryItemLink("player", slot)
        if link then level = getFlyoutItemLevel(link, "player", slot) end
    end
    level = level or ""
    if level ~= "" and tonumber(level) == 1 then level = "" end
    button.iLvl:SetText("|cffFFFF00" .. level)
end

------------------------------------------------------------------------

function module:OnInit()
    if not cfg.slot_itemlevel then return end

    local playerFrame = createStrings(PaperDollFrame, playerSlots)

    PaperDollFrame:HookScript("OnShow", function()
        updateItems("player", playerFrame)
        playerFrame:Show()
    end)
    PaperDollFrame:HookScript("OnHide", function()
        playerFrame:Hide()
    end)

    self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", function(_, _, slot)
        if not PaperDollFrame:IsShown() then return end
        if slot == 16 then
            equipped[16] = nil
            equipped[17] = nil
        end
        updateItems("player", playerFrame)
    end)

    -- Inspect frame (LoD)
    local function setupInspect()
        local inspectFrame = createStrings(InspectPaperDollFrame, inspectSlots)

        InspectPaperDollFrame:HookScript("OnShow", function()
            updateItems("target", inspectFrame)
            inspectFrame:Show()
        end)
        InspectPaperDollFrame:HookScript("OnHide", function()
            inspectFrame:Hide()
        end)

        module:RegisterEvent("INSPECT_READY", function()
            if InspectPaperDollFrame and InspectPaperDollFrame:IsShown() then
                updateItems("target", inspectFrame)
            end
        end)
    end

    if C_AddOns.IsAddOnLoaded("Blizzard_InspectUI") then
        setupInspect()
    else
        self:RegisterEvent("ADDON_LOADED", function(_, _, addon)
            if addon == "Blizzard_InspectUI" then
                setupInspect()
            end
        end)
    end

    -- Flyout item levels
    hooksecurefunc("EquipmentFlyout_DisplayButton", function(button)
        local location = button.location
        if not location or location >= EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION then
            if button.iLvl then button.iLvl:SetText("") end
            return
        end
        local _, _, bags, voidStorage, slot, bag = EquipmentManager_UnpackLocation(location)
        if voidStorage then return end
        if bags then
            setupFlyoutLevel(button, bag, slot)
        else
            setupFlyoutLevel(button, nil, slot)
        end
    end)
end
