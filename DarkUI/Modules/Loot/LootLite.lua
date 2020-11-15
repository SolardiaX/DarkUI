local E, C, L = select(2, ...):unpack()

if not C.loot.enable then return end

----------------------------------------------------------------------------------------
--	Loot frame(addon by Haste)
----------------------------------------------------------------------------------------

local CreateFrame = CreateFrame
local CloseLoot, IsFishingLoot, LootSlotHasItem = CloseLoot, IsFishingLoot, LootSlotHasItem
local UnitIsFriend, UnitIsDead, UnitName = UnitIsFriend, UnitIsDead, UnitName
local GetCVar, GetCursorPosition, GetNumLootItems = GetCVar, GetCursorPosition, GetNumLootItems
local GetLootSlotType, GetLootSlotInfo = GetLootSlotType, GetLootSlotInfo
local CurrencyContainerUtil = CurrencyContainerUtil
local StaticPopup_Hide, UIDropDownMenu_Refresh = StaticPopup_Hide, UIDropDownMenu_Refresh
local ToggleDropDownMenu, GroupLootDropDown = ToggleDropDownMenu, GroupLootDropDown
local IsAltKeyDown, IsControlKeyDown, IsModifiedClick = IsAltKeyDown, IsControlKeyDown, IsModifiedClick
local CursorUpdate, ResetCursor, CursorOnUpdate = CursorUpdate, ResetCursor, CursorOnUpdate
local HandleModifiedItemClick, GetLootSlotLink, LootSlot = HandleModifiedItemClick, GetLootSlotLink, LootSlot
local unpack, tinsert, pairs, max = unpack, tinsert, pairs, math.max
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local LOOT_SLOT_MONEY, LOOT = LOOT_SLOT_MONEY, LOOT
local EMPTY = EMPTY
local UIParent = UIParent
local LootFrame = LootFrame
local GameTooltip = GameTooltip
local UISpecialFrames = UISpecialFrames

local cfg = C.loot

local addon = CreateFrame("Button", "LootLite", UIParent)
addon.slots = {}

addon:RegisterForClicks("AnyUp")
addon:SetPoint(unpack(cfg.pos))
addon:SetClampedToScreen(true)
addon:SetFrameStrata("DIALOG")
addon:SetToplevel(true)
addon:SetFrameLevel(10)
addon:SetTemplate("Blur")
addon:CreateShadow()
addon:Hide()

addon:SetScript("OnEvent", function(self, event, ...) self[event](self, event, ...) end)

function addon:LOOT_OPENED(_, ...)
    self:Show()

    local autoLoot = ...
    if not self:IsShown() then
        CloseLoot(not autoLoot)
    end

    if IsFishingLoot() then
        self.title:SetText(L.LOOT_FISH)
    elseif not UnitIsFriend("player", "target") and UnitIsDead("target") then
        self.title:SetText(UnitName("target"))
    else
        self.title:SetText(LOOT)
    end

    -- Blizzard uses strings here
    if GetCVar("lootUnderMouse") == "1" then
        local x, y = GetCursorPosition()
        x = x / self:GetEffectiveScale()
        y = y / self:GetEffectiveScale()

        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", x - 40, y + 20)
        self:GetCenter()
        self:Raise()
    end

    local m = 0
    local items = GetNumLootItems()
    if items > 0 then
        for i = 1, items do
            local slot = addon.slots[i] or addon.CreateSlot(i)
            local texture, item, quantity, currencyID, quality, _, isQuestItem, questId, isActive = GetLootSlotInfo(i)

            if currencyID then
                item, texture, quantity, quality = CurrencyContainerUtil.GetCurrencyContainerInfo(currencyID, quantity, item, texture, quality)
            end

            if texture then
                local color = ITEM_QUALITY_COLORS[quality]
                local r, g, b = color.r, color.g, color.b

                if GetLootSlotType(i) == LOOT_SLOT_MONEY then
                    item = item:gsub("\n", ", ")
                end

                if quantity and quantity > 1 then
                    slot.count:SetText(quantity)
                    slot.count:Show()
                else
                    slot.count:Hide()
                end

                if questId and not isActive then
                    slot.quest:Show()
                else
                    slot.quest:Hide()
                end

                if color or questId or isQuestItem then
                    if questId or isQuestItem then
                        r, g, b = 1, 1, 0.2
                    end

                    slot.iconFrame:SetBackdropBorderColor(r, g, b)
                    --slot.iconFrame:SetBackdropColor(r, g, b)
                    slot.drop:SetVertexColor(r, g, b)
                end
                slot.drop:Show()

                slot.isQuestItem = isQuestItem
                slot.quality = quality

                slot.name:SetText(item)
                if color then
                    slot.name:SetTextColor(r, g, b)
                end
                slot.icon:SetTexture(texture)

                if quality then
                    m = max(m, quality)
                end

                slot:Enable()
                slot:Show()
            end
        end
    else
        local slot = addon.slots[1] or addon.CreateSlot(1)
        local color = ITEM_QUALITY_COLORS[0]

        slot.name:SetText(EMPTY)
        slot.name:SetTextColor(color.r, color.g, color.b)
        slot.icon:SetTexture("Interface\\Icons\\INV_Misc_Herb_AncientLichen")

        slot.count:Hide()
        slot.drop:Hide()
        slot:Disable()
        slot:Show()
    end
    self:AnchorSlots()

    local color = ITEM_QUALITY_COLORS[m]
    self:SetBackdropBorderColor(color.r, color.g, color.b, 0.8)

    self:SetWidth(cfg.width)
    self.title:SetWidth(cfg.width - 45)
    self.title:SetHeight(C.media.standard_font[2])
end
addon:RegisterEvent("LOOT_OPENED")

function addon:LOOT_SLOT_CLEARED(_, slot)
    if not self:IsShown() then
        return
    end

    addon.slots[slot]:Hide()
    self:AnchorSlots()
end
addon:RegisterEvent("LOOT_SLOT_CLEARED")

function addon:LOOT_CLOSED()
    StaticPopup_Hide("LOOT_BIND")
    self:Hide()

    for _, v in pairs(addon.slots) do
        v:Hide()
    end
end
addon:RegisterEvent("LOOT_CLOSED")

function addon:OPEN_MASTER_LOOT_LIST()
    ToggleDropDownMenu(nil, nil, GroupLootDropDown, LootFrame.selectedLootButton, 0, 0)
end
addon:RegisterEvent("OPEN_MASTER_LOOT_LIST")

function addon:UPDATE_MASTER_LOOT_LIST()
    UIDropDownMenu_Refresh(GroupLootDropDown)
end
addon:RegisterEvent("UPDATE_MASTER_LOOT_LIST")

local title = addon:CreateFontString(nil, "OVERLAY")
title:SetFont(unpack(C.media.standard_font))
title:SetShadowOffset(1, -1)
title:SetJustifyH("LEFT")
title:SetPoint("TOPLEFT", addon, "TOPLEFT", 8, -7)
addon.title = title

addon:SetScript("OnMouseDown", function(self, button)
    if IsAltKeyDown() then
        self:StartMoving()
    elseif IsControlKeyDown() and button == "RightButton" then
        self:SetPoint(unpack(cfg.pos))
    end
end)

addon:SetScript("OnMouseUp", function(self)
    self:StopMovingOrSizing()
end)

addon:SetScript("OnHide", function()
    StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
    CloseLoot()
end)

local close = CreateFrame("Button", "LootCloseButton", addon, "UIPanelCloseButton")
close:SkinCloseButton(addon)
close:SetSize(18, 18)
close:SetScript("OnClick", function() CloseLoot() end)

local OnEnter = function(self)
    local slot = self:GetID()
    if LootSlotHasItem(slot) then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetLootItem(slot)
        CursorUpdate(self)
    end

    self.drop:Show()
    if self.isQuestItem then
        self.drop:SetVertexColor(0.8, 0.8, 0.2)
    else
        self.drop:SetVertexColor(1, 1, 0)
    end
end

local OnLeave = function(self)
    local color = ITEM_QUALITY_COLORS[self.quality]
    if self.isQuestItem then
        self.drop:SetVertexColor(1, 1, 0.2)
    elseif color then
        self.drop:SetVertexColor(color.r, color.g, color.b)
    end

    GameTooltip:Hide()
    ResetCursor()
end

local OnClick = function(self)
    if IsModifiedClick() then
        HandleModifiedItemClick(GetLootSlotLink(self:GetID()))
    else
        StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")

        LootFrame.selectedLootButton = self
        LootFrame.selectedSlot = self:GetID()
        LootFrame.selectedQuality = self.quality
        LootFrame.selectedItemName = self.name:GetText()

        LootSlot(self:GetID())
    end
end

local OnUpdate = function(self)
    if GameTooltip:IsOwned(self) then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetLootItem(self:GetID())
        CursorOnUpdate(self)
    end
end

function addon.CreateSlot(id)
    local frame = CreateFrame("Button", "addonSlot" .. id, addon, "BackdropTemplate")
    frame:SetPoint("LEFT", 8, 0)
    frame:SetPoint("RIGHT", -8, 0)
    frame:SetHeight(cfg.icon_size)
    frame:SetID(id)
    --frame:SetTemplate("Border")

    frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    frame:SetScript("OnEnter", OnEnter)
    frame:SetScript("OnLeave", OnLeave)
    frame:SetScript("OnClick", OnClick)
    frame:SetScript("OnUpdate", OnUpdate)

    local iconFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    iconFrame:SetSize(cfg.icon_size, cfg.icon_size)
    iconFrame:ClearAllPoints()
    iconFrame:SetPoint("LEFT", frame, 0, 0)
    iconFrame:SetTemplate("Default")
    frame.iconFrame = iconFrame

    local icon = iconFrame:CreateTexture(nil, "ARTWORK")
    icon:SetAlpha(.8)
    icon:SetTexCoord(.07, .93, .07, .93)
    icon:SetPoint("TOPLEFT", 2, -2)
    icon:SetPoint("BOTTOMRIGHT", -2, 2)
    frame.icon = icon

    local quest = iconFrame:CreateTexture(nil, "OVERLAY")
    quest:SetTexture("Interface\\Minimap\\ObjectIcons")
    quest:SetTexCoord(1 / 8, 2 / 8, 1 / 8, 2 / 8)
    quest:SetSize(cfg.icon_size * 0.8, cfg.icon_size * 0.8)
    quest:SetPoint("BOTTOMLEFT", -cfg.icon_size * 0.15, 0)
    frame.quest = quest

    local count = iconFrame:CreateFontString(nil, "OVERLAY")
    count:SetJustifyH("RIGHT")
    count:SetPoint("BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", 1, 1)
    count:SetFont(unpack(C.media.standard_font))
    count:SetShadowOffset(1, -1)
    count:SetText(1)
    frame.count = count

    local name = frame:CreateFontString(nil, "OVERLAY")
    name:SetJustifyH("LEFT")
    name:SetNonSpaceWrap(true)
    name:SetFont(unpack(C.media.standard_font))
    name:SetShadowOffset(0.8, -0.8)
    name:SetShadowColor(0, 0, 0, 1)
    name:ClearAllPoints()
    name:SetPoint("RIGHT", frame)
    name:SetPoint("LEFT", icon, "RIGHT", 10, 0)
    name:SetWidth(cfg.width - cfg.icon_size - 25)
    frame.name = name

    local drop = frame:CreateTexture(nil, "ARTWORK")
    drop:SetTexture(C.media.texture.status_s)
    drop:SetPoint("TOPLEFT", icon, "TOPRIGHT", 4, -2)
    drop:SetPoint("BOTTOMRIGHT", frame, 0, 2)
    drop:SetAlpha(.5)
    frame.drop = drop

    addon.slots[id] = frame
    return frame
end

function addon:AnchorSlots()
    local frameSize = cfg.icon_size
    local shownSlots = 0

    local prevShown
    for i = 1, #addon.slots do
        local frame = addon.slots[i]
        if frame:IsShown() then
            frame:ClearAllPoints()
            frame:SetPoint("LEFT", 8, 0)
            frame:SetPoint("RIGHT", -8, 0)
            if not prevShown then
                frame:SetPoint("TOPLEFT", self, 8, -25)
            else
                frame:SetPoint("TOP", prevShown, "BOTTOM", 0, -3)
            end

            frame:SetHeight(frameSize)
            shownSlots = shownSlots + 1
            prevShown = frame
        end
    end

    self:SetHeight((shownSlots * (frameSize + 3)) + 30)
end

-- Kill the default loot frame
LootFrame:UnregisterAllEvents()

-- Escape the dungeon
tinsert(UISpecialFrames, "addon")

