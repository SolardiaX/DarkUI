local E, C, L = select(2, ...):unpack()

if not C.loot.enable then return end

----------------------------------------------------------------------------------------
--    GroupLoot based on teksLoot(by Tekkub)
----------------------------------------------------------------------------------------

local _G = _G
local CreateFrame = CreateFrame
local IsShiftKeyDown, IsModifiedClick, IsControlKeyDown = IsShiftKeyDown, IsModifiedClick, IsControlKeyDown
local DressUpItemLink, GetItemInfo, GetItemQualityColor = DressUpItemLink, GetItemInfo, GetItemQualityColor
local RollOnLoot, GetLootRollTimeLeft = RollOnLoot, GetLootRollTimeLeft
local GetLootRollItemInfo, GetLootRollItemLink = GetLootRollItemInfo, GetLootRollItemLink
local SetDesaturation = SetDesaturation
local ChatEdit_GetActiveWindow = ChatEdit_GetActiveWindow
local ChatEdit_InsertLink, ChatFrame_OpenChat = ChatEdit_InsertLink, ChatFrame_OpenChat
local ResetCursor, ShowInspectCursor = ResetCursor, ShowInspectCursor
local GameTooltip_ShowCompareItem = GameTooltip_ShowCompareItem
local C_LootHistory_GetItem, C_LootHistory_GetPlayerInfo = C_LootHistory.GetItem, C_LootHistory.GetPlayerInfo
local next, ipairs, tinsert, unpack, format, random = next, ipairs, tinsert, unpack, format, math.random
local STANDARD_TEXT_FONT = STANDARD_TEXT_FONT
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local NEED, GREED, PASS, ROLL_DISENCHANT = NEED, GREED, PASS, ROLL_DISENCHANT
local UIParent = UIParent
local WorldFrame = WorldFrame
local GameTooltip, ShoppingTooltip1, ShoppingTooltip2 = GameTooltip, ShoppingTooltip1, ShoppingTooltip2

local cfg = C.loot

local pos = "TOP"
local frames = {}
local cancelled_rolls = {}
local rolltypes = {[1] = "need", [2] = "greed", [3] = "disenchant", [4] = "transmog", [0] = "pass"}

local function ClickRoll(frame)
    if not frame.parent.rollID then return end
    RollOnLoot(frame.parent.rollID, frame.rolltype)
end

local function HideTip() GameTooltip:Hide() end
local function HideTip2()
    GameTooltip:Hide()
    ResetCursor()
end

local function SetTip(frame)
    GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")
    GameTooltip:SetText(frame.tiptext)
    if not frame:IsEnabled() then
        GameTooltip:AddLine(frame.errtext, 1, 0.2, 0.2, 1)
    end
    for name, roll in pairs(frame.parent.rolls) do
        if roll == rolltypes[frame.rolltype] then
            GameTooltip:AddLine(name, 1, 1, 1)
        end
    end
    GameTooltip:Show()
end

local function SetItemTip(frame)
    if not frame.link then return end
    GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")
    GameTooltip:SetHyperlink(frame.link)
    if IsShiftKeyDown() then GameTooltip_ShowCompareItem() end
    if IsModifiedClick("DRESSUP") then ShowInspectCursor() else ResetCursor() end
end

local function ItemOnUpdate(frame)
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

local function LootClick(frame)
    if IsControlKeyDown() then
        DressUpItemLink(frame.link)
    elseif IsShiftKeyDown() then
        local _, item = GetItemInfo(frame.link)
        if ChatEdit_GetActiveWindow() then
            ChatEdit_InsertLink(item)
        else
            ChatFrame_OpenChat(item)
        end
    end
end

local function OnEvent(frame, event, rollID)
    if event == "CANCEL_ALL_LOOT_ROLLS" then
        frame.rollID = nil
        frame.time = nil
        frame:Hide()
    else
        cancelled_rolls[rollID] = true
        if frame.rollID ~= rollID then return end

        frame.rollID = nil
        frame.time = nil
        frame:Hide()
    end
end

local function StatusUpdate(frame)
    if not frame.parent.rollID then return end
    local t = GetLootRollTimeLeft(frame.parent.rollID)
    local perc = t / frame.parent.time
    frame.spark:SetPoint("CENTER", frame, "LEFT", perc * frame:GetWidth(), 0)
    frame:SetValue(t)
end

local function CreateRollButton(parent, ntex, ptex, htex, rolltype, tiptext, ...)
    local f = CreateFrame("Button", nil, parent)
    f:SetPoint(...)
    f:SetSize(28, 28)
    f:SetNormalTexture(ntex)
    if ptex then f:SetPushedTexture(ptex) end
    f:SetHighlightTexture(htex)
    f.rolltype = rolltype
    f.parent = parent
    f.tiptext = tiptext
    f:SetScript("OnEnter", SetTip)
    f:SetScript("OnLeave", HideTip)
    f:SetScript("OnClick", ClickRoll)
    f:SetMotionScriptsWhileDisabled(true)
    local txt = f:CreateFontString(nil, nil)
    txt:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINEMONOCHROME")
    txt:SetShadowOffset(1, -1)
    txt:SetPoint("CENTER", 0, rolltype == 2 and 1 or rolltype == 0 and -1.2 or 0)
    return f, txt
end

local function CreateRollFrame()
    local frame = CreateFrame("Frame", nil, UIParent)
    -- frame:CreateBackdrop()
    frame:SetSize(280, 24)
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(10)
    frame:SetScript("OnEvent", OnEvent)
    frame:RegisterEvent("CANCEL_LOOT_ROLL")
    frame:RegisterEvent("CANCEL_ALL_LOOT_ROLLS")
    frame:RegisterEvent("MAIN_SPEC_NEED_ROLL")
    frame:Hide()

    local button = CreateFrame("Button", nil, frame)
    button:SetPoint("BOTTOMLEFT",frame,"BOTTOMLEFT", 0, 0)
    button:SetSize(24, 24)
    button:SetScript("OnEnter", SetItemTip)
    button:SetScript("OnLeave", HideTip2)
    button:SetScript("OnUpdate", ItemOnUpdate)
    button:SetScript("OnClick", LootClick)
    button:CreateBackdrop("Transparent")
    button:CreateShadow()
    E:ApplyOverlayBorder(button)

    frame.button = button

    button.icon = button:CreateTexture(nil, "OVERLAY")
    button.icon:SetAllPoints()
    button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    local status = CreateFrame("StatusBar", nil, frame)
    status:SetSize(280, 6)
    status:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 4, 0)
    status:SetScript("OnUpdate", StatusUpdate)
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

    local need, needText = CreateRollButton(frame, "lootroll-toast-icon-need-up", "lootroll-toast-icon-need-highlight", "lootroll-toast-icon-need-down", 1, NEED, "LEFT", frame.button, "RIGHT", 8, -1)
    local greed, greedText = CreateRollButton(frame, "lootroll-toast-icon-greed-up", "lootroll-toast-icon-greed-highlight", "lootroll-toast-icon-greed-down", 2, GREED, "LEFT", need, "RIGHT", 0, 1)
    local transmog, transmogText = CreateRollButton(frame, "lootroll-toast-icon-transmog-up", "lootroll-toast-icon-transmog-highlight", "lootroll-toast-icon-transmog-down", 4, TRANSMOGRIFY, "LEFT", need, "RIGHT", -1, 1)
    local de, deText = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-DE-Up", "Interface\\Buttons\\UI-GroupLoot-DE-Highlight", "Interface\\Buttons\\UI-GroupLoot-DE-Down", 3, ROLL_DISENCHANT, "LEFT", greed, "RIGHT", -2, -2)
    local pass, passText = CreateRollButton(frame, "lootroll-toast-icon-pass-up", "lootroll-toast-icon-pass-highlight", "lootroll-toast-icon-pass-down", 0, PASS, "LEFT", de or greed, "RIGHT", 0, 2.2)
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

local function GetFrame()
    for _, f in ipairs(frames) do
        if not f.rollID then return f end
    end

    local f = CreateRollFrame()
    if pos == "TOP" then
        if next(frames) then
            f:SetPoint("TOPRIGHT", frames[#frames], "BOTTOMRIGHT", 0, -7)
    else
            f:SetPoint("TOPRIGHT", LootRollAnchor, "TOPRIGHT", -2, -2)
    end
    else
        if next(frames) then
            f:SetPoint("BOTTOMRIGHT", frames[#frames], "TOPRIGHT", 0, 7)
        else
            f:SetPoint("TOPRIGHT", LootRollAnchor, "TOPRIGHT", -2, -2)
        end
    end
    table.insert(frames, f)
    return f
end
local function START_LOOT_ROLL(rollID, time)
    if cancelled_rolls[rollID] then return end

    local f = GetFrame()
    f.rollID = rollID
    f.time = time
    for i in pairs(f.rolls) do f.rolls[i] = nil end

    local texture, name, _, quality, bop, canNeed, canGreed, canDisenchant, reasonNeed, reasonGreed, reasonDisenchant, deSkillRequired, canTransmog = GetLootRollItemInfo(rollID)
    f.button.icon:SetTexture(texture)
    f.button.link = GetLootRollItemLink(rollID)

    --if C.automation.auto_greed and E.level == MAX_PLAYER_LEVEL and quality == 2 and not bop then return end

    if canNeed then
        f.need:Enable()
        f.need:SetAlpha(1)
        SetDesaturation(f.need:GetNormalTexture(), false)
    else
        f.need:Disable()
        f.need:SetAlpha(0.2)
        SetDesaturation(f.need:GetNormalTexture(), true)
        f.need.errtext = _G["LOOT_ROLL_INELIGIBLE_REASON"..reasonNeed]
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
            SetDesaturation(f.greed:GetNormalTexture(), false)
        else
            f.greed:Disable()
            f.greed:SetAlpha(0.2)
            SetDesaturation(f.greed:GetNormalTexture(), true)
            f.greed.errtext = _G["LOOT_ROLL_INELIGIBLE_REASON"..reasonGreed]
        end
    end

    if canDisenchant then
        f.disenchant:Enable()
        f.disenchant:SetAlpha(1)
        SetDesaturation(f.disenchant:GetNormalTexture(), false)
    else
        f.disenchant:Disable()
        f.disenchant:SetAlpha(0.2)
        SetDesaturation(f.disenchant:GetNormalTexture(), true)
        f.disenchant.errtext = format(_G["LOOT_ROLL_INELIGIBLE_REASON"..reasonDisenchant], deSkillRequired)
    end

    f.fsbind:SetText(bop and "BoP" or "BoE")
    f.fsbind:SetVertexColor(bop and 1 or 0.3, bop and 0.3 or 1, bop and 0.1 or 0.3)

    local color = ITEM_QUALITY_COLORS[quality]
    f.fsloot:SetText(name)
    f.fsloot:SetVertexColor(color.r, color.g, color.b)

    f.status:SetStatusBarColor(color.r, color.g, color.b, 0.7)
    f.status:SetMinMaxValues(0, time)
    f.status:SetValue(time)

    f.button.backdrop:SetBackdropBorderColor(color.r, color.g, color.b, 0.7)

    f:SetPoint("CENTER", WorldFrame, "CENTER")
    f:Show()
end

local function LOOT_HISTORY_ROLL_CHANGED(rollindex, playerindex)
    local _, _, rolltype = C_LootHistory_GetPlayerInfo(rollindex, playerindex)
    UpdateRoll(rollindex, rolltype)
end

local LootRollAnchor = CreateFrame("Frame", "LootRollAnchor", UIParent)
LootRollAnchor:SetSize(313, 26)

_G.LootRollAnchor = LootRollAnchor

LootRollAnchor:RegisterEvent("PLAYER_LOGIN")
LootRollAnchor:SetScript(
        "OnEvent",
        function()
            LootRollAnchor:UnregisterEvent("PLAYER_LOGIN")
            LootRollAnchor:RegisterEvent("START_LOOT_ROLL")

            UIParent:UnregisterEvent("START_LOOT_ROLL")
            UIParent:UnregisterEvent("CANCEL_LOOT_ROLL")

            LootRollAnchor:SetScript(
                    "OnEvent",
                    function(_, event, ...)
                        if event == "LOOT_HISTORY_ROLL_CHANGED" then
                            return LOOT_HISTORY_ROLL_CHANGED(...)
                        else
                            return START_LOOT_ROLL(...)
                        end
                    end
            )

            LootRollAnchor:SetPoint(unpack(cfg.group_loot_pos))
        end
)

SlashCmdList.TESTROLL = function()
    local f = GetFrame()
    local items = {32837, 34196, 33820, 84004}

    if f:IsShown() then
        f:Hide()
    else
        local item = items[random(1, #items)]
        local name, _, quality, _, _, _, _, _, _, texture = GetItemInfo(item)
        local r, g, b = GetItemQualityColor(quality or 1)

        f.button.icon:SetTexture(texture)
        f.button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

        f.fsloot:SetText(name)
        f.fsloot:SetVertexColor(r, g, b)

        f.status:SetMinMaxValues(0, 100)
        f.status:SetValue(random(50, 90))
        f.status:SetStatusBarColor(r, g, b, 0.7)

        f.button.backdrop:SetBackdropBorderColor(r, g, b, 0.7)

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
