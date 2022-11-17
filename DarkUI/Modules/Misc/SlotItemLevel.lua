local E, C, L = select(2, ...):unpack()

if not C.misc.slot_itemlevel then return end

----------------------------------------------------------------------------------------
--	Item level on slot buttons in Character/InspectFrame(iLevel by Sanex)
----------------------------------------------------------------------------------------

local _G = getfenv(0)
local equiped = {} -- Table to store equiped items

local f = CreateFrame("Frame", nil, _G.PaperDollFrame) -- iLvel number frame
local g -- iLvel number for Inspect frame
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
local fontObject = CreateFont("iLvLFont")
fontObject:SetFontObject("SystemFont_Outline_Small")

-- Tooltip and scanning by Phanx @ http://www.wowinterface.com/forums/showthread.php?p=271406
local S_ITEM_LEVEL = "^" .. gsub(ITEM_LEVEL, "%%d", "(%%d+)")

local scanner = CreateFrame("GameTooltip", "SlotScanningTooltip", nil, "GameTooltipTemplate")
scanner:SetOwner(UIParent, "ANCHOR_NONE")

local scannerName = scanner:GetName()

local function _getRealItemLevel(slotId, unit)
    local hasItem = scanner:SetInventoryItem(unit, slotId)
    if not hasItem then return nil end -- With this we don't get ilvl for offhand if we equip 2h weapon
    local realItemLevel

    local line = _G[scannerName .. "TextLeft2"]
    if line then
        local msg = line:GetText()
        if msg and string.find(msg, S_ITEM_LEVEL) then
            local itemLevel = string.match(msg, S_ITEM_LEVEL)
            if itemLevel and (tonumber(itemLevel) > 0) then
                realItemLevel = itemLevel
            end
        else
            -- Check line 3, some artifacts have the ilevel there
            line = _G[scannerName .. "TextLeft3"]
            if line then
                local msg = line:GetText()
                if msg and string.find(msg, S_ITEM_LEVEL) then
                    local itemLevel = string.match(msg, S_ITEM_LEVEL)
                    if itemLevel and (tonumber(itemLevel) > 0) then
                        realItemLevel = itemLevel
                    end
                end
            end
        end
    end

    return realItemLevel
end

local function checkSpecID(unit)
    local i = 0
    local specID
    if unit == "player" then
        specID = GetSpecializationInfo(GetSpecialization())
    else
        specID = GetInspectSpecialization("target")
    end
    if specID then
        if specID == 250 or specID == 251 or specID == 252 or specID == 66 or specID == 70 or specID == 71 or specID == 72 or specID == 73 then
            i = INVSLOT_HAND
        elseif specID == 577 or specID == 581 or specID == 103 or specID == 104 or specID == 253 or specID == 254 or specID == 255
            or specID == 268 or specID == 269 or specID == 259 or specID == 260 or specID == 261 or specID == 263 then
            i = INVSLOT_FEET
        else
            i = INVSLOT_WRIST
        end
    end
    return i
end
local function _updateItems(unit, frame)
    local itemSlot = checkSpecID(unit)
    for i = 1, 17 do -- Only check changed player items or items without ilvl text, skip the shirt (4) and always update Inspects
        local itemLink = GetInventoryItemLink(unit, i)
        if i ~= 4 and ((frame == f and (equiped[i] ~= itemLink or frame[i]:GetText() == nil or itemLink == nil and frame[i]:GetText() ~= "")) or frame == g) then
            if frame == f then
                equiped[i] = itemLink
            end

            local realItemLevel = _getRealItemLevel(i, unit)
            realItemLevel = realItemLevel or ""
            if realItemLevel and tonumber(realItemLevel) == 1 then
                realItemLevel = ""
            end
            local color = "|cffFFFF00"
            if itemLink and (i == 15 or i == 5 or i == 16 or i == 11 or i == 12 or i == itemSlot) and (realItemLevel ~= "" and tonumber(realItemLevel) > 197) then
                local _, _, enchant = strsplit(":", itemLink)
                if enchant and enchant == "" then
                    color = "|cffFF0000"
                end
            end

            frame[i]:SetText(color..realItemLevel)
        end
    end
end

local function _createStrings()
    local function _stringFactory(parent)
        local s = f:CreateFontString(nil, "OVERLAY", "iLvLFont")
        s:SetPoint("TOP", parent, "TOP", 0, -2)
        return s
    end
    f:SetFrameLevel(_G.CharacterHeadSlot:GetFrameLevel())
    f[1] = _stringFactory(_G.CharacterHeadSlot)
    f[2] = _stringFactory(_G.CharacterNeckSlot)
    f[3] = _stringFactory(_G.CharacterShoulderSlot)
    f[15] = _stringFactory(_G.CharacterBackSlot)
    f[5] = _stringFactory(_G.CharacterChestSlot)
    f[9] = _stringFactory(_G.CharacterWristSlot)
    f[10] = _stringFactory(_G.CharacterHandsSlot)
    f[6] = _stringFactory(_G.CharacterWaistSlot)
    f[7] = _stringFactory(_G.CharacterLegsSlot)
    f[8] = _stringFactory(_G.CharacterFeetSlot)
    f[11] = _stringFactory(_G.CharacterFinger0Slot)
    f[12] = _stringFactory(_G.CharacterFinger1Slot)
    f[13] = _stringFactory(_G.CharacterTrinket0Slot)
    f[14] = _stringFactory(_G.CharacterTrinket1Slot)
    f[16] = _stringFactory(_G.CharacterMainHandSlot)
    f[17] = _stringFactory(_G.CharacterSecondaryHandSlot)
    f:Hide()
end

local function _createGStrings()
    local function _stringFactory(parent)
        local s = g:CreateFontString(nil, "OVERLAY", "iLvLFont")
        s:SetPoint("TOP", parent, "TOP", 0, -2)

        return s
    end

    g:SetFrameLevel(_G.InspectHeadSlot:GetFrameLevel())

    g[1] = _stringFactory(_G.InspectHeadSlot)
    g[2] = _stringFactory(_G.InspectNeckSlot)
    g[3] = _stringFactory(_G.InspectShoulderSlot)
    g[15] = _stringFactory(_G.InspectBackSlot)
    g[5] = _stringFactory(_G.InspectChestSlot)
    g[9] = _stringFactory(_G.InspectWristSlot)

    g[10] = _stringFactory(_G.InspectHandsSlot)
    g[6] = _stringFactory(_G.InspectWaistSlot)
    g[7] = _stringFactory(_G.InspectLegsSlot)
    g[8] = _stringFactory(_G.InspectFeetSlot)
    g[11] = _stringFactory(_G.InspectFinger0Slot)
    g[12] = _stringFactory(_G.InspectFinger1Slot)
    g[13] = _stringFactory(_G.InspectTrinket0Slot)
    g[14] = _stringFactory(_G.InspectTrinket1Slot)

    g[16] = _stringFactory(_G.InspectMainHandSlot)
    g[17] = _stringFactory(_G.InspectSecondaryHandSlot)

    g:Hide()
end

local function OnEvent(self, event, ...)
    if event == "ADDON_LOADED" and (...) == "Blizzard_InspectUI" then
        self:UnregisterEvent(event)
        if not InspectFrameiLvL and not C.tooltip.average_lvl then
            local text = InspectModelFrame:CreateFontString("InspectFrameiLvL", "OVERLAY", "SystemFont_Outline_Small")
            text:SetPoint("BOTTOM", 5, 20)
            text:Hide()
            InspectPaperDollFrame:HookScript("OnShow", function()
                local avgilvl = C_PaperDollInfo.GetInspectItemLevel("target")
                if avgilvl and tonumber(avgilvl) > 0 then
                    text:SetText("|cFFFFFF00"..avgilvl)
                    text:Show()
                end
            end)
            InspectPaperDollFrame:HookScript("OnHide", function()
                text:Hide()
            end)
        end

        g = CreateFrame("Frame", nil, _G.InspectPaperDollFrame) -- iLevel number frame for Inspect
        _createGStrings()
        _createGStrings = nil

        _G.InspectPaperDollFrame:HookScript("OnShow", function()
            g:SetFrameLevel(_G.InspectHeadSlot:GetFrameLevel())
            f:RegisterEvent("INSPECT_READY")
            f:RegisterEvent("UNIT_INVENTORY_CHANGED")
            _updateItems("target", g)
            g:Show()
        end)

        _G.InspectPaperDollFrame:HookScript("OnHide", function()
            f:UnregisterEvent("INSPECT_READY")
            f:UnregisterEvent("UNIT_INVENTORY_CHANGED")
            g:Hide()
        end)
    elseif event == "PLAYER_LOGIN" then
        self:UnregisterEvent(event)

        _createStrings()
        _createStrings = nil
        _G.PaperDollFrame:HookScript("OnShow", function()
            f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
            f:RegisterEvent("ARTIFACT_UPDATE")
            f:RegisterEvent("SOCKET_INFO_UPDATE")
            f:RegisterEvent("COMBAT_RATING_UPDATE")
            _updateItems("player", f)
            f:Show()
        end)
        _G.PaperDollFrame:HookScript("OnHide", function()
            f:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
            f:UnregisterEvent("ARTIFACT_UPDATE")
            f:UnregisterEvent("SOCKET_INFO_UPDATE")
            f:UnregisterEvent("COMBAT_RATING_UPDATE")
            f:Hide()
        end)
    elseif event == "PLAYER_EQUIPMENT_CHANGED" or event == "ARTIFACT_UPDATE" or event == "SOCKET_INFO_UPDATE" or event == "COMBAT_RATING_UPDATE" then
        if (...) == 16 then
            equiped[16] = nil
            equiped[17] = nil
        end
        _updateItems("player", f)
    elseif event == "INSPECT_READY" or event == "UNIT_INVENTORY_CHANGED" then
        _updateItems("target", g)
    end
end
f:SetScript("OnEvent", OnEvent)

----------------------------------------------------------------------------------------
--	Item level on flyout buttons (by Merathilis)
----------------------------------------------------------------------------------------
local ItemDB = {}
local function _getRealItemLevel(link, bag, slot)
    if ItemDB[link] then return ItemDB[link] end
    local realItemLevel
    if bag and type(bag) == "string" then
        realItemLevel = C_Item.GetCurrentItemLevel(ItemLocation:CreateFromEquipmentSlot(slot))
    else
        realItemLevel = C_Item.GetCurrentItemLevel(ItemLocation:CreateFromBagAndSlot(bag, slot))
    end
    ItemDB[link] = tonumber(realItemLevel)
    return realItemLevel
end

local function SetupFlyoutLevel(button, bag, slot)
    if not button.iLvl then
        button.iLvl = button:CreateFontString(nil, "OVERLAY", "iLvLFont")
        button.iLvl:SetPoint("TOP", 0, -2)
    end
    local link, level
    if bag then
        link = C_Container.GetContainerItemLink(bag, slot)
        level = _getRealItemLevel(link, bag, slot)
    else
        link = GetInventoryItemLink("player", slot)
        level = _getRealItemLevel(link, "player", slot)
    end
    if level then
        button.iLvl:SetText("|cFFFFFF00"..level)
    end
end

hooksecurefunc("EquipmentFlyout_DisplayButton", function(button)
    local location = button.location
    if not location or location >= EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION then
        if button.iLvl then button.iLvl:SetText("") end
        return
    end
    local _, _, bags, voidStorage, slot, bag = EquipmentManager_UnpackLocation(location)
    if voidStorage then return end
    if bags then
        SetupFlyoutLevel(button, bag, slot)
    else
        SetupFlyoutLevel(button, nil, slot)
    end
end)