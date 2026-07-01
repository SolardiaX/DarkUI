local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB
local cr, cg, cb = DB.r, DB.g, DB.b

------------------------------------------------------------------------
-- PVE Frame (Group Finder portal / Scenario queue)
-- Ported from AuroraClassic FrameXML/PVEFrame.lua (2026-06)
-- Note: Aurora noise overlay dropped; DarkUI backdrop already carries texture.
------------------------------------------------------------------------

local _G = _G
local hooksecurefunc = hooksecurefunc

function S:PVEFrame()
    if not (C.skins.enable and C.skins.lfg) then return end

    _G.PVEFrameLeftInset:SetAlpha(0)
    _G.PVEFrameBlueBg:SetAlpha(0)
    _G.PVEFrame.shadows:SetAlpha(0)

    _G.PVEFrameTab2:SetPoint("LEFT", _G.PVEFrameTab1, "RIGHT", -5, 0)
    _G.PVEFrameTab3:SetPoint("LEFT", _G.PVEFrameTab2, "RIGHT", -5, 0)

    local iconSize = 56 - 2 * E.mult
    for i = 1, 4 do
        local bu = _G.GroupFinderFrame["groupButton" .. i]
        if bu then
            bu.ring:Hide()
            if bu.CircleMask then bu.CircleMask:Hide() end
            S:Reskin(bu, true)
            bu.bg:SetColorTexture(cr, cg, cb, 0.25)
            bu.bg:SetInside(bu.__bg)

            bu.icon:SetPoint("LEFT", bu, "LEFT", 2, 0)
            bu.icon:SetSize(iconSize, iconSize)
            S:ReskinIcon(bu.icon)
        end
    end

    hooksecurefunc("GroupFinderFrame_SelectGroupButton", function(index)
        for i = 1, 3 do
            local button = _G.GroupFinderFrame["groupButton" .. i]
            if i == index then
                button.bg:Show()
            else
                button.bg:Hide()
            end
        end
    end)

    S:ReskinPortraitFrame(_G.PVEFrame)

    for i = 1, 4 do
        local tab = _G["PVEFrameTab" .. i]
        if tab then
            S:ReskinTab(tab)
            if i ~= 1 then
                tab:ClearAllPoints()
                tab:SetPoint("TOPLEFT", _G["PVEFrameTab" .. (i - 1)], "TOPRIGHT", -5, 0)
            end
        end
    end

    if _G.ScenarioQueueFrame then
        _G.ScenarioFinderFrame:StripTextures()
        _G.ScenarioQueueFrameBackground:SetAlpha(0)
        S:ReskinDropDown(_G.ScenarioQueueFrameTypeDropdown)
        S:Reskin(_G.ScenarioQueueFrameFindGroupButton)
        S:ReskinTrimScroll(_G.ScenarioQueueFrameRandomScrollFrame.ScrollBar)
        if _G.ScenarioQueueFrameRandomScrollFrameScrollBar then _G.ScenarioQueueFrameRandomScrollFrameScrollBar:SetAlpha(0) end
    end
end

S:AddCallback("PVEFrame")
