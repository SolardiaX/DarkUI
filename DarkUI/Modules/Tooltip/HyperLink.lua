local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Chat Hyperlink Hover Tooltip
------------------------------------------------------------------------

local module = E:Module("Tooltip"):Sub("HyperLink")
local cfg = C.tooltip

local BattlePetToolTip_Show = BattlePetToolTip_Show
local GameTooltip = GameTooltip
local BattlePetTooltip = BattlePetTooltip
local strsplit, tonumber = strsplit, tonumber

local orig1, orig2 = {}, {}
local linktypes = {
    item = true,
    enchant = true,
    spell = true,
    quest = true,
    unit = true,
    talent = true,
    achievement = true,
    glyph = true,
    instancelock = true,
    currency = true,
}

local function onHyperlinkEnter(frame, link, ...)
    local linktype = link:match("^([^:]+)")
    if linktype and linktype == "battlepet" then
        GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT", -3, 0)
        GameTooltip:Show()
        local _, speciesID, level, breedQuality, maxHealth, power, speed = strsplit(":", link)
        BattlePetToolTip_Show(tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed))
    elseif linktype and linktypes[linktype] then
        GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT", -3, 0)
        GameTooltip:SetHyperlink(link)
        GameTooltip:Show()
    end

    if orig1[frame] then return orig1[frame](frame, link, ...) end
end

local function onHyperlinkLeave(frame, link, ...)
    if BattlePetTooltip:IsShown() then
        BattlePetTooltip:Hide()
    else
        GameTooltip:Hide()
    end

    if orig2[frame] then return orig2[frame](frame, link, ...) end
end

function module:OnInit()
    if not cfg.enable then return end
    if C_AddOns.IsAddOnLoaded("tekKompare") then return end

    local maxWindows = Constants and Constants.ChatFrameConstants and Constants.ChatFrameConstants.MaxChatWindows or 10
    for i = 1, maxWindows do
        local frame = _G["ChatFrame" .. i]
        if frame then
            orig1[frame] = frame:GetScript("OnHyperlinkEnter")
            frame:SetScript("OnHyperlinkEnter", onHyperlinkEnter)

            orig2[frame] = frame:GetScript("OnHyperlinkLeave")
            frame:SetScript("OnHyperlinkLeave", onHyperlinkLeave)
        end
    end
end
