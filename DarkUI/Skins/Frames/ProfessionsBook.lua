local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB

------------------------------------------------------------------------
-- Professions Book (secondary profession panel)
-- Ported from AuroraClassic AddOns/Blizzard_ProfessionsBook.lua (2026-06)
-- Aurora noise overlay dropped; DarkUI backdrop carries the texture.
-- Note: GetProfessionInfo() is pre-12.0 API; kept as-is (still present).
------------------------------------------------------------------------

local _G = _G
local pairs = pairs
local hooksecurefunc = hooksecurefunc

local function replaceHighlight(button) button.highlightTexture:SetColorTexture(1, 1, 1, 0.25) end

local function handleSkillButton(button)
    if not button then return end
    button:SetCheckedTexture(0)
    button:SetPushedTexture(0)
    button.IconTexture:SetInside()
    button.bg = S:ReskinIcon(button.IconTexture)
    button.highlightTexture:SetInside(button.bg)
    hooksecurefunc(button, "UpdateButton", replaceHighlight)

    local nameFrame = _G[button:GetName() .. "NameFrame"]
    if nameFrame then nameFrame:Hide() end
end

function S:ProfessionsBook()
    if not (C.skins.enable and C.skins.tradeskill) then return end

    S:ReskinPortraitFrame(_G.ProfessionsBookFrame)

    local professions = {
        "PrimaryProfession1",
        "PrimaryProfession2",
        "SecondaryProfession1",
        "SecondaryProfession2",
        "SecondaryProfession3",
    }

    for i, name in pairs(professions) do
        local bu = _G[name]
        bu.professionName:SetTextColor(1, 1, 1)
        bu.missingHeader:SetTextColor(1, 1, 1)
        bu.missingText:SetTextColor(1, 1, 1)

        bu.statusBar:StripTextures()
        bu.statusBar:SetHeight(10)
        bu.statusBar:SetStatusBarTexture(DB.bdTex)
        bu.statusBar:GetStatusBarTexture():SetGradient("VERTICAL", CreateColor(0, 0.6, 0, 1), CreateColor(0, 0.8, 0, 1))
        bu.statusBar.rankText:SetPoint("CENTER")
        local statusBg = bu.statusBar:CreateBackdrop()
        statusBg:SetBackdropColor(0, 0, 0, 0.25)
        if i > 2 then
            bu.statusBar:ClearAllPoints()
            bu.statusBar:SetPoint("BOTTOMLEFT", 16, 3)
        end

        handleSkillButton(bu.SpellButton1)
        handleSkillButton(bu.SpellButton2)
    end

    for i = 1, 2 do
        local bu = _G["PrimaryProfession" .. i]
        _G["PrimaryProfession" .. i .. "IconBorder"]:Hide()

        bu.professionName:ClearAllPoints()
        bu.professionName:SetPoint("TOPLEFT", 100, -4)
        bu.icon:SetAlpha(1)
        bu.icon:SetDesaturated(false)
        S:ReskinIcon(bu.icon)

        local bg = bu:CreateBackdrop()
        bg:SetBackdropColor(0, 0, 0, 0.25)
        bg:SetPoint("TOPLEFT")
        bg:SetPoint("BOTTOMRIGHT", 0, -5)
    end

    hooksecurefunc("FormatProfession", function(frame, index)
        if index then
            local _, texture = GetProfessionInfo(index)

            if frame.icon and texture then frame.icon:SetTexture(texture) end
        end
    end)

    local sec1Bg = _G.SecondaryProfession1:CreateBackdrop()
    sec1Bg:SetBackdropColor(0, 0, 0, 0.25)
    local sec2Bg = _G.SecondaryProfession2:CreateBackdrop()
    sec2Bg:SetBackdropColor(0, 0, 0, 0.25)
    local sec3Bg = _G.SecondaryProfession3:CreateBackdrop()
    sec3Bg:SetBackdropColor(0, 0, 0, 0.25)
end

S:AddCallbackForAddon("Blizzard_ProfessionsBook", "ProfessionsBook")
