local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Item Text Frame (readable items / books / letters)
-- Ported from AuroraClassic FrameXML/ItemTextFrame.lua (2026-06)
-- Note: Aurora's SetTextColor("P", ...) idiom dropped — just sets white;
--       B.Dummy replaced with E.Dummy.
------------------------------------------------------------------------

function S:ItemText()
    if not (C.skins.enable and C.skins.misc) then return end

    InboxFrameBg:Hide()
    ItemTextPrevPageButton:GetRegions():Hide()
    ItemTextNextPageButton:GetRegions():Hide()
    ItemTextMaterialTopLeft:SetAlpha(0)
    ItemTextMaterialTopRight:SetAlpha(0)
    ItemTextMaterialBotLeft:SetAlpha(0)
    ItemTextMaterialBotRight:SetAlpha(0)

    S:ReskinPortraitFrame(ItemTextFrame)
    S:ReskinTrimScrollBar(ItemTextScrollFrame.ScrollBar)
    S:ReskinArrow(ItemTextPrevPageButton, "left")
    S:ReskinArrow(ItemTextNextPageButton, "right")
    ItemTextFramePageBg:SetAlpha(0)
    -- ItemTextPageText is a SimpleHTML: SetTextColor takes (textType, r, g, b)
    ItemTextPageText:SetTextColor("P", 1, 1, 1)
    ItemTextPageText:SetTextColor("H1", 1, 1, 1)
    ItemTextPageText:SetTextColor("H2", 1, 1, 1)
    ItemTextPageText:SetTextColor("H3", 1, 1, 1)
    ItemTextPageText.SetTextColor = E.Dummy
end

S:AddCallback("ItemText")
