local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- GroupLoot
------------------------------------------------------------------------
local module = E:Module("Loot"):Sub("GroupLoot")

local cfg = C.loot

local IsShiftKeyDown, IsModifiedClick, IsControlKeyDown = IsShiftKeyDown, IsModifiedClick, IsControlKeyDown
local GetLootRollTimeLeft = GetLootRollTimeLeft
local ResetCursor, ShowInspectCursor = ResetCursor, ShowInspectCursor
local GameTooltip_ShowCompareItem = GameTooltip_ShowCompareItem

local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local STANDARD_TEXT_FONT = STANDARD_TEXT_FONT
local GameTooltip = GameTooltip
local ShoppingTooltip1, ShoppingTooltip2 = ShoppingTooltip1, ShoppingTooltip2

local POS = "TOP"
local anchor
local frames = {}
local cancelledRolls = {}
local rollTypes = { [1] = "need", [2] = "greed", [3] = "disenchant", [4] = "transmog", [0] = "pass" }

------------------------------------------------------------------------
-- Roll button callbacks
------------------------------------------------------------------------
local function clickRoll(frame)
    if not frame.parent.rollID then return end
    RollOnLoot(frame.parent.rollID, frame.rolltype)
end

local function hideTip() GameTooltip:Hide() end

local function hideTipCursor()
    GameTooltip:Hide()
    ResetCursor()
end

local function setTip(frame)
    GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")
    GameTooltip:SetText(frame.tiptext)
    if not frame:IsEnabled() then GameTooltip:AddLine(frame.errtext, 1, 0.2, 0.2, 1) end
    for name, roll in pairs(frame.parent.rolls) do
        if roll == rollTypes[frame.rolltype] then GameTooltip:AddLine(name, 1, 1, 1) end
    end
    GameTooltip:Show()
end

local function setItemTip(frame)
    if not frame.link then return end
    GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")
    GameTooltip:SetHyperlink(frame.link)
    if IsShiftKeyDown() then GameTooltip_ShowCompareItem() end
    if IsModifiedClick("DRESSUP") then
        ShowInspectCursor()
    else
        ResetCursor()
    end
end

local function itemOnUpdate(frame)
    if GameTooltip:IsOwned(frame) then
        if IsShiftKeyDown() then
            GameTooltip_ShowCompareItem()
        else
            ShoppingTooltip1:Hide()
            ShoppingTooltip2:Hide()
        end

        if IsControlKeyDown() then
            ShowInspectCursor()
        else
            ResetCursor()
        end
    end
end

local function lootClick(frame)
    if IsControlKeyDown() then
        DressUpItemLink(frame.link)
    elseif IsShiftKeyDown() then
        local _, item = C_Item.GetItemInfo(frame.link)
        if ChatFrameUtil.GetActiveWindow() then
            ChatFrameUtil.InsertLink(item)
        else
            ChatFrameUtil.OpenChat(item)
        end
    end
end

------------------------------------------------------------------------
-- Roll frame events
------------------------------------------------------------------------
local function onEvent(frame, event, rollID)
    if event == "CANCEL_ALL_LOOT_ROLLS" then
        frame.rollID = nil
        frame.time = nil
        frame:Hide()
    else
        cancelledRolls[rollID] = true
        if frame.rollID ~= rollID then return end

        frame.rollID = nil
        frame.time = nil
        frame:Hide()
    end
end

local function statusUpdate(frame)
    if not frame.parent.rollID then return end
    local t = GetLootRollTimeLeft(frame.parent.rollID)
    local perc = t / frame.parent.time
    frame.spark:SetPoint("CENTER", frame, "LEFT", perc * frame:GetWidth(), 0)
    frame:SetValue(t)
end

------------------------------------------------------------------------
-- Create roll button
------------------------------------------------------------------------
local function createRollButton(parent, ntex, ptex, htex, rolltype, tiptext, ...)
    local f = CreateFrame("Button", nil, parent)
    f:SetPoint(...)
    f:SetSize(28, 28)
    f:SetNormalTexture(ntex)
    if ptex then f:SetPushedTexture(ptex) end
    f:SetHighlightTexture(htex)
    f.rolltype = rolltype
    f.parent = parent
    f.tiptext = tiptext
    f:SetScript("OnEnter", setTip)
    f:SetScript("OnLeave", hideTip)
    f:SetScript("OnClick", clickRoll)
    f:SetMotionScriptsWhileDisabled(true)

    local txt = f:CreateFontString(nil, nil)
    txt:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINEMONOCHROME")
    txt:SetShadowOffset(1, -1)
    txt:SetPoint("CENTER", 0, rolltype == 2 and 1 or rolltype == 0 and -1.2 or 0)

    return f, txt
end

------------------------------------------------------------------------
-- Create roll frame
------------------------------------------------------------------------
local function createRollFrame()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(280, 24)
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(10)
    frame:SetScript("OnEvent", onEvent)
    frame:RegisterEvent("CANCEL_LOOT_ROLL")
    frame:RegisterEvent("CANCEL_ALL_LOOT_ROLLS")
    frame:Hide()

    local button = CreateFrame("Button", nil, frame)
    button:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
    button:SetSize(24, 24)
    button:SetScript("OnEnter", setItemTip)
    button:SetScript("OnLeave", hideTipCursor)
    button:SetScript("OnUpdate", itemOnUpdate)
    button:SetScript("OnClick", lootClick)
    button:CreateBackdrop()
    button:CreateShadow()
    frame.button = button

    button.icon = button:CreateTexture(nil, "OVERLAY")
    button.icon:SetAllPoints()
    button.icon:SetTexCoord(unpack(C.media.texCoord))

    local status = CreateFrame("StatusBar", nil, frame)
    status:SetSize(280, 6)
    status:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 4, 0)
    status:SetScript("OnUpdate", statusUpdate)
    status:SetFrameLevel(status:GetFrameLevel() - 1)
    status:SetTemplate("Default")
    status:SetStatusBarTexture(C.media.texture.gradient)
    status:SetStatusBarColor(0.8, 0.8, 0.8, 0.9)
    status:CreateShadow()
    status.parent = frame
    frame.status = status

    local spark = frame:CreateTexture(nil, "OVERLAY")
    spark:SetWidth(14)
    spark:SetHeight(25)
    spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
    spark:SetBlendMode("ADD")
    status.spark = spark

    local need, needText = createRollButton(
        frame,
        "lootroll-toast-icon-need-up",
        "lootroll-toast-icon-need-highlight",
        "lootroll-toast-icon-need-down",
        1,
        NEED,
        "LEFT",
        frame.button,
        "RIGHT",
        8,
        -1
    )
    local greed, greedText = createRollButton(
        frame,
        "lootroll-toast-icon-greed-up",
        "lootroll-toast-icon-greed-highlight",
        "lootroll-toast-icon-greed-down",
        2,
        GREED,
        "LEFT",
        need,
        "RIGHT",
        0,
        1
    )
    local transmog, transmogText = createRollButton(
        frame,
        "lootroll-toast-icon-transmog-up",
        "lootroll-toast-icon-transmog-highlight",
        "lootroll-toast-icon-transmog-down",
        4,
        TRANSMOGRIFY,
        "LEFT",
        need,
        "RIGHT",
        -1,
        1
    )
    local de, deText = createRollButton(
        frame,
        "Interface\\Buttons\\UI-GroupLoot-DE-Up",
        "Interface\\Buttons\\UI-GroupLoot-DE-Highlight",
        "Interface\\Buttons\\UI-GroupLoot-DE-Down",
        3,
        ROLL_DISENCHANT,
        "LEFT",
        greed,
        "RIGHT",
        -2,
        -2
    )
    local pass, passText = createRollButton(
        frame,
        "lootroll-toast-icon-pass-up",
        "lootroll-toast-icon-pass-highlight",
        "lootroll-toast-icon-pass-down",
        0,
        PASS,
        "LEFT",
        de or greed,
        "RIGHT",
        0,
        2.2
    )
    frame.need, frame.greed, frame.disenchant, frame.transmog = need, greed, de, transmog

    local bind = frame:CreateFontString()
    bind:SetPoint("LEFT", pass, "RIGHT", 3, 1)
    bind:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
    bind:SetShadowOffset(1, -1)
    frame.fsbind = bind

    local loot = frame:CreateFontString(nil, "ARTWORK")
    loot:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
    loot:SetShadowOffset(1, -1)
    loot:SetPoint("LEFT", bind, "RIGHT", 0, 0)
    loot:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
    loot:SetSize(200, 10)
    loot:SetJustifyH("LEFT")
    frame.fsloot = loot

    frame.rolls = {}

    return frame
end

------------------------------------------------------------------------
-- Get available frame
------------------------------------------------------------------------
local function getFrame()
    for _, f in ipairs(frames) do
        if not f.rollID then return f end
    end

    local f = createRollFrame()
    if POS == "TOP" then
        if next(frames) then
            f:SetPoint("TOPRIGHT", frames[#frames], "BOTTOMRIGHT", 0, -7)
        else
            f:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", -2, -2)
        end
    else
        if next(frames) then
            f:SetPoint("BOTTOMRIGHT", frames[#frames], "TOPRIGHT", 0, 7)
        else
            f:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", -2, -2)
        end
    end
    tinsert(frames, f)
    return f
end

------------------------------------------------------------------------
-- START_LOOT_ROLL handler
------------------------------------------------------------------------
local function startLootRoll(rollID, time)
    if cancelledRolls[rollID] then return end

    local f = getFrame()
    f.rollID = rollID
    f.time = time
    for i in pairs(f.rolls) do
        f.rolls[i] = nil
    end

    local texture, name, _, quality, bop, canNeed, canGreed, canDisenchant, reasonNeed, reasonGreed, reasonDisenchant, deSkillRequired, canTransmog =
        GetLootRollItemInfo(rollID)
    f.button.icon:SetTexture(texture)
    f.button.link = GetLootRollItemLink(rollID)

    if canNeed then
        f.need:Enable()
        f.need:SetAlpha(1)
        f.need:GetNormalTexture():SetDesaturated(false)
    else
        f.need:Disable()
        f.need:SetAlpha(0.2)
        f.need:GetNormalTexture():SetDesaturated(true)
        f.need.errtext = _G["LOOT_ROLL_INELIGIBLE_REASON" .. reasonNeed]
    end

    if canTransmog then
        f.transmog:Show()
        f.greed:Hide()
    else
        f.transmog:Hide()
        f.greed:Show()
        if canGreed then
            f.greed:Enable()
            f.greed:SetAlpha(1)
            f.greed:GetNormalTexture():SetDesaturated(false)
        else
            f.greed:Disable()
            f.greed:SetAlpha(0.2)
            f.greed:GetNormalTexture():SetDesaturated(true)
            f.greed.errtext = _G["LOOT_ROLL_INELIGIBLE_REASON" .. reasonGreed]
        end
    end

    if canDisenchant then
        f.disenchant:Enable()
        f.disenchant:SetAlpha(1)
        f.disenchant:GetNormalTexture():SetDesaturated(false)
    else
        f.disenchant:Disable()
        f.disenchant:SetAlpha(0.2)
        f.disenchant:GetNormalTexture():SetDesaturated(true)
        f.disenchant.errtext = format(_G["LOOT_ROLL_INELIGIBLE_REASON" .. reasonDisenchant], deSkillRequired)
    end

    f.fsbind:SetText(bop and "BoP" or "BoE")
    f.fsbind:SetVertexColor(bop and 1 or 0.3, bop and 0.3 or 1, bop and 0.1 or 0.3)

    local color = ITEM_QUALITY_COLORS[quality]
    f.fsloot:SetText(name)
    f.fsloot:SetVertexColor(color.r, color.g, color.b)

    f.status:SetStatusBarColor(color.r, color.g, color.b, 0.7)
    f.status:SetMinMaxValues(0, time)
    f.status:SetValue(time)

    if f.button.backdrop then f.button.backdrop:SetBackdropBorderColor(color.r, color.g, color.b, 0.7) end

    f:Show()
end

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------
function module:OnInit()
    if not cfg.enable then return end

    anchor = CreateFrame("Frame", "DarkUILootRollAnchor", UIParent)
    anchor:SetSize(313, 26)
    anchor:SetPoint(unpack(cfg.group_loot_pos))

    anchor:RegisterEvent("PLAYER_LOGIN")
    anchor:SetScript("OnEvent", function(self)
        self:UnregisterEvent("PLAYER_LOGIN")
        self:RegisterEvent("START_LOOT_ROLL")

        UIParent:UnregisterEvent("START_LOOT_ROLL")
        UIParent:UnregisterEvent("CANCEL_LOOT_ROLL")

        self:SetScript("OnEvent", function(_, _, ...) startLootRoll(...) end)
    end)

    SlashCmdList.TESTROLL = function()
        local f = getFrame()
        local items = { 32837, 34196, 33820, 84004 }

        if f:IsShown() then
            f:Hide()
        else
            local item = items[math.random(1, #items)]
            local name, _, quality, _, _, _, _, _, _, texture = C_Item.GetItemInfo(item)
            if not name then return end

            local r, g, b = C_Item.GetItemQualityColor(quality or 1)

            f.button.icon:SetTexture(texture)
            f.button.icon:SetTexCoord(unpack(C.media.texCoord))

            f.fsloot:SetText(name)
            f.fsloot:SetVertexColor(r, g, b)

            f.status:SetMinMaxValues(0, 100)
            f.status:SetValue(math.random(50, 90))
            f.status:SetStatusBarColor(r, g, b, 0.7)

            if f.button.backdrop then f.button.backdrop:SetBackdropBorderColor(r, g, b, 0.7) end

            f.button.link = "item:" .. item .. ":0:0:0:0:0:0:0"
            local greed = math.random(0, 1)
            if greed == 0 then
                f.transmog:Show()
                f.greed:Hide()
            else
                f.transmog:Hide()
                f.greed:Show()
            end

            f:Show()
        end
    end
    SLASH_TESTROLL1 = "/testroll"
end
