local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Loot
------------------------------------------------------------------------
local module = E:Module("Loot")
module:SetConfigKey("loot")

local cfg = C.loot

local LootSlotHasItem = LootSlotHasItem
local GetLootSlotLink, LootSlot = GetLootSlotLink, LootSlot
local GetLootSlotType, GetLootSlotInfo = GetLootSlotType, GetLootSlotInfo
local GetNumLootItems = GetNumLootItems
local IsModifiedClick, HandleModifiedItemClick = IsModifiedClick, HandleModifiedItemClick
local CursorUpdate, ResetCursor, CursorOnUpdate = CursorUpdate, ResetCursor, CursorOnUpdate
local format = format

local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local GameTooltip = GameTooltip

------------------------------------------------------------------------
-- Loot frame & slots
------------------------------------------------------------------------
local lootFrame
local slots = {}

------------------------------------------------------------------------
-- Slot callbacks
------------------------------------------------------------------------
local function slotOnEnter(self)
    local id = self:GetID()
    if LootSlotHasItem(id) then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetLootItem(id)
        CursorUpdate(self)
    end

    self.drop:Show()
    if self.isQuestItem then
        self.drop:SetVertexColor(0.8, 0.8, 0.2)
    else
        self.drop:SetVertexColor(1, 1, 0)
    end
end

local function slotOnLeave(self)
    local color = ITEM_QUALITY_COLORS[self.quality]
    if self.isQuestItem then
        self.drop:SetVertexColor(1, 1, 0.2)
    elseif color then
        self.drop:SetVertexColor(color.r, color.g, color.b)
    end

    GameTooltip:Hide()
    ResetCursor()
end

local function slotOnClick(self)
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

local function slotOnUpdate(self)
    if GameTooltip:IsOwned(self) then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetLootItem(self:GetID())
        CursorOnUpdate(self)
    end
end

------------------------------------------------------------------------
-- Create slot
------------------------------------------------------------------------
local function createSlot(id)
    local frame = CreateFrame("Button", "DarkUILootSlot" .. id, lootFrame)
    frame:SetPoint("LEFT", 8, 0)
    frame:SetPoint("RIGHT", -8, 0)
    frame:SetHeight(cfg.icon_size)
    frame:SetID(id)

    frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    frame:SetScript("OnEnter", slotOnEnter)
    frame:SetScript("OnLeave", slotOnLeave)
    frame:SetScript("OnClick", slotOnClick)
    frame:SetScript("OnUpdate", slotOnUpdate)

    local iconFrame = CreateFrame("Frame", nil, frame)
    iconFrame:SetSize(cfg.icon_size, cfg.icon_size)
    iconFrame:SetPoint("LEFT", frame, 0, 0)
    iconFrame:SetTemplate("Default")
    frame.iconFrame = iconFrame

    local icon = iconFrame:CreateTexture(nil, "ARTWORK")
    icon:SetAlpha(0.8)
    icon:SetTexCoord(unpack(C.media.texCoord))
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
    name:SetPoint("RIGHT", frame)
    name:SetPoint("LEFT", icon, "RIGHT", 10, 0)
    name:SetWidth(cfg.width - cfg.icon_size - 25)
    frame.name = name

    local drop = frame:CreateTexture(nil, "ARTWORK")
    drop:SetTexture(C.media.texture.status_s)
    drop:SetPoint("TOPLEFT", icon, "TOPRIGHT", 4, -2)
    drop:SetPoint("BOTTOMRIGHT", frame, 0, 2)
    drop:SetAlpha(0.5)
    frame.drop = drop

    frame:CreateBackdrop()

    slots[id] = frame
    return frame
end

------------------------------------------------------------------------
-- Anchor slots
------------------------------------------------------------------------
local function anchorSlots()
    local frameSize = cfg.icon_size
    local shownSlots = 0
    local prevShown

    for i = 1, #slots do
        local frame = slots[i]
        if frame:IsShown() then
            frame:ClearAllPoints()
            frame:SetPoint("LEFT", 8, 0)
            frame:SetPoint("RIGHT", -8, 0)
            if not prevShown then
                frame:SetPoint("TOPLEFT", lootFrame, 8, -25)
            else
                frame:SetPoint("TOP", prevShown, "BOTTOM", 0, -3)
            end

            frame:SetHeight(frameSize)
            shownSlots = shownSlots + 1
            prevShown = frame
        end
    end

    lootFrame:SetHeight((shownSlots * (frameSize + 3)) + 30)
end

------------------------------------------------------------------------
-- Announce
------------------------------------------------------------------------
local function announce(channel)
    local nums = GetNumLootItems()
    if nums == 0 or (nums == 1 and GetLootSlotType(1) == Enum.LootSlotType.Money) then
        return
    end

    if UnitIsPlayer("target") or not UnitExists("target") then
        SendChatMessage(">> " .. LOOT .. ":", channel)
    else
        SendChatMessage(">> " .. LOOT .. " - '" .. UnitName("target") .. "':", channel)
    end

    for i = 1, nums do
        if LootSlotHasItem(i) then
            local link = GetLootSlotLink(i)
            if GetLootSlotType(i) ~= Enum.LootSlotType.Money then
                SendChatMessage(format("- %s", link), channel)
            else
                local _, item = GetLootSlotInfo(i)
                item = item:gsub("\n", ", ")
                SendChatMessage(format("- %s", item), channel)
            end
        end
    end
end

local function announceDropdownInit()
    local info = {}

    info.text = L.LOOT_ANNOUNCE
    info.notCheckable = true
    info.isTitle = true
    UIDropDownMenu_AddButton(info)

    info = {}
    info.text = L.LOOT_TO_RAID
    info.value = "raid"
    info.notCheckable = 1
    info.func = function(self)
        announce(self.value)
    end
    UIDropDownMenu_AddButton(info)

    info = {}
    info.text = L.LOOT_TO_GUILD
    info.value = "guild"
    info.notCheckable = 1
    info.func = function(self)
        announce(self.value)
    end
    UIDropDownMenu_AddButton(info)

    info = {}
    info.text = L.LOOT_TO_PARTY
    info.value = "party"
    info.notCheckable = 1
    info.func = function(self)
        announce(self.value)
    end
    UIDropDownMenu_AddButton(info)

    info = {}
    info.text = L.LOOT_TO_SAY
    info.value = "say"
    info.notCheckable = 1
    info.func = function(self)
        announce(self.value)
    end
    UIDropDownMenu_AddButton(info)
end

------------------------------------------------------------------------
-- Events
------------------------------------------------------------------------
local function onLootOpened(_, _, autoLoot)
    lootFrame:Show()

    if not lootFrame:IsShown() then
        CloseLoot(not autoLoot)
    end

    if IsFishingLoot() then
        lootFrame.title:SetText(L.LOOT_FISH)
    elseif not UnitIsFriend("player", "target") and UnitIsDead("target") then
        lootFrame.title:SetText(UnitName("target"))
    else
        lootFrame.title:SetText(LOOT)
    end

    if GetCVar("lootUnderMouse") == "1" then
        local x, y = GetCursorPosition()
        x = x / lootFrame:GetEffectiveScale()
        y = y / lootFrame:GetEffectiveScale()

        lootFrame:ClearAllPoints()
        lootFrame:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", x - 40, y + 20)
        lootFrame:GetCenter()
        lootFrame:Raise()
    end

    local maxQuality = 0
    local items = GetNumLootItems()
    if items > 0 then
        for i = 1, items do
            local slot = slots[i] or createSlot(i)
            local texture, item, quantity, currencyID, quality, _, isQuestItem, questId, isActive = GetLootSlotInfo(i)

            if currencyID then
                item, texture, quantity, quality = CurrencyContainerUtil.GetCurrencyContainerInfo(currencyID, quantity, item, texture, quality)
            end

            local color = ITEM_QUALITY_COLORS[quality] or { r = 1, g = 1, b = 1 }
            local r, g, b = color.r, color.g, color.b

            if GetLootSlotType(i) == Enum.LootSlotType.Money then
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

            if questId or isQuestItem then
                r, g, b = 1, 1, 0.2
            end

            slot.iconFrame:SetBackdropBorderColor(r, g, b)
            slot.drop:SetVertexColor(r, g, b)
            slot.drop:Show()

            slot.isQuestItem = isQuestItem
            slot.quality = quality

            slot.name:SetText(item)
            slot.name:SetTextColor(r, g, b)
            slot.icon:SetTexture(texture)

            if quality then
                maxQuality = math.max(maxQuality, quality)
            end

            if texture then
                slot:Enable()
                slot:Show()
            end
        end
    else
        local slot = slots[1] or createSlot(1)
        local color = ITEM_QUALITY_COLORS[0]

        slot.name:SetText(EMPTY)
        slot.name:SetTextColor(color.r, color.g, color.b)
        slot.icon:SetTexture("Interface\\Icons\\INV_Misc_Herb_AncientLichen")
        slot.quest:Hide()
        slot.count:Hide()
        slot.drop:Hide()
        slot:Disable()
        slot:Hide()
    end
    anchorSlots()

    local color = ITEM_QUALITY_COLORS[maxQuality]
    lootFrame:SetBackdropBorderColor(color.r, color.g, color.b, 0.8)

    lootFrame:SetWidth(cfg.width)
    lootFrame.title:SetWidth(cfg.width - 45)
    lootFrame.title:SetHeight(C.media.standard_font[2])
end

local function onLootSlotCleared(_, _, slot)
    if not lootFrame:IsShown() then
        return
    end

    if slots[slot] then
        slots[slot]:Hide()
    end
    anchorSlots()
end

local function onLootClosed()
    StaticPopup_Hide("LOOT_BIND")
    lootFrame:Hide()

    for _, v in pairs(slots) do
        v:Hide()
    end
end

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------
function module:OnInit()
    if not cfg.enable then return end

    lootFrame = CreateFrame("Button", "DarkUILootFrame", UIParent)
    lootFrame:SetPoint(unpack(cfg.pos))
    lootFrame:SetClampedToScreen(true)
    lootFrame:SetFrameStrata("DIALOG")
    lootFrame:SetToplevel(true)
    lootFrame:SetFrameLevel(10)
    lootFrame:SetTemplate("Blur", 2)
    lootFrame:CreateShadow()
    lootFrame:SetMovable(true)
    lootFrame:RegisterForClicks("AnyUp")
    lootFrame:Hide()

    local title = lootFrame:CreateFontString(nil, "OVERLAY")
    title:SetFont(unpack(C.media.standard_font))
    title:SetShadowOffset(1, -1)
    title:SetJustifyH("LEFT")
    title:SetPoint("TOPLEFT", lootFrame, "TOPLEFT", 8, -7)
    lootFrame.title = title

    local close = CreateFrame("Button", nil, lootFrame, "UIPanelCloseButton")
    close:SetScript("OnClick", function()
        CloseLoot()
    end)
    E:ReskinCloseButton(close, lootFrame)

    -- Announce button
    local announceDropdown = CreateFrame("Frame", "DarkUILootAnnounceDD", lootFrame, "UIDropDownMenuTemplate")
    local annBtn = CreateFrame("Button", nil, lootFrame)
    annBtn:SetSize(14, 14)
    annBtn:SetPoint("RIGHT", close, "LEFT", -4, 0)
    annBtn:SetTemplate("Overlay")
    annBtn:SetFrameStrata("DIALOG")
    annBtn:RegisterForClicks("RightButtonUp", "LeftButtonUp")

    local annText = annBtn:CreateFontText(10, ">")
    annText:SetPoint("CENTER", 0, 0)

    annBtn:SetScript("OnClick", function(_, button)
        if button == "RightButton" then
            ToggleDropDownMenu(nil, nil, announceDropdown, annBtn, 0, 0)
        else
            announce(E:CheckChat())
        end
    end)
    annBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(E.myColor.r, E.myColor.g, E.myColor.b)
    end)
    annBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(unpack(C.media.border_color))
    end)

    UIDropDownMenu_Initialize(announceDropdown, announceDropdownInit, "MENU")

    -- Dragging
    lootFrame:SetScript("OnMouseDown", function(self, button)
        if IsAltKeyDown() or IsShiftKeyDown() then
            self:StartMoving()
        elseif IsControlKeyDown() and button == "RightButton" then
            self:ClearAllPoints()
            self:SetPoint(unpack(cfg.pos))
        end
    end)
    lootFrame:SetScript("OnMouseUp", function(self)
        self:StopMovingOrSizing()
    end)
    lootFrame:SetScript("OnHide", function()
        StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
        CloseLoot()
    end)

    -- Kill default
    LootFrame:UnregisterAllEvents()
    tinsert(UISpecialFrames, "DarkUILootFrame")

    -- Events
    self:RegisterEvent("LOOT_OPENED", onLootOpened)
    self:RegisterEvent("LOOT_SLOT_CLEARED", onLootSlotCleared)
    self:RegisterEvent("LOOT_CLOSED", onLootClosed)
end
