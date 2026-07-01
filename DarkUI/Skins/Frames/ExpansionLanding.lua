local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Expansion Landing Page (Dragon Isles / War Within overlay panel)
-- Ported from AuroraClassic AddOns/Blizzard_ExpansionLandingPage.lua (2026-06)
-- Note: Aurora noise overlay dropped; DarkUI backdrop carries texture.
------------------------------------------------------------------------

local select = select

local function SkinFactionCategory(button)
    if button.UnlockedState and not button.__styled then
        button.UnlockedState.WatchFactionButton:SetSize(28, 28)
        S:ReskinCheck(button.UnlockedState.WatchFactionButton)
        button.UnlockedState.WatchFactionButton.Label:SetFontObject(Game18Font)
        button.__styled = true
    end
end

function S:ExpansionLandingPage()
    if not C.general.skins then return end

    local frame = _G.ExpansionLandingPage
    local panel

    frame:HookScript("OnShow", function()
        if not panel then
            if frame.Overlay then
                for i = 1, frame.Overlay:GetNumChildren() do
                    local child = select(i, frame.Overlay:GetChildren())
                    if child.DragonridingPanel then
                        panel = child
                        break
                    end
                end
            end
        end

        if panel and not panel.__styled then
            panel.NineSlice:SetAlpha(0)
            panel.Background:SetAlpha(0)
            S:CreateBackground(panel)

            if panel.DragonridingPanel then S:ReskinButton(panel.DragonridingPanel.SkillsButton) end
            if panel.CloseButton then S:ReskinClose(panel.CloseButton) end
            if panel.MajorFactionList then
                S:ReskinTrimScrollBar(panel.MajorFactionList.ScrollBar)
                panel.MajorFactionList.ScrollBox:ForEachFrame(SkinFactionCategory)
                hooksecurefunc(panel.MajorFactionList.ScrollBox, "Update", function(self) self:ForEachFrame(SkinFactionCategory) end)
            end
            if panel.ScrollFadeOverlay then panel.ScrollFadeOverlay:SetAlpha(0) end

            panel.__styled = true
        end
    end)
end

S:AddCallbackForAddon("Blizzard_ExpansionLandingPage", "ExpansionLandingPage")
