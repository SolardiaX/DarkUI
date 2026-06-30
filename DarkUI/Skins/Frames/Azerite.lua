local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB
local cr, cg, cb = DB.r, DB.g, DB.b

------------------------------------------------------------------------
-- Azerite Empowered / Essence / Respec / Item Interaction UIs
-- Ported from AuroraClassic AddOns/Blizzard_AzeriteUI.lua (2026-06)
-- Note: Aurora noise overlay dropped; DarkUI backdrop carries texture.
-- Note: B.SetCurrenciesHook has no S: equivalent — branch dropped with TODO.
------------------------------------------------------------------------

local function updateEssenceButton(button)
    if not button.bg then
        local bg = button:CreateBackdrop()
        bg:SetPoint("TOPLEFT", 1, 0)
        bg:SetPoint("BOTTOMRIGHT", 0, 2)

        if button.Icon then
            S:ReskinIcon(button.Icon)
            button.PendingGlow:SetTexture("")
            local hl = button:GetHighlightTexture()
            hl:SetColorTexture(cr, cg, cb, 0.25)
            hl:SetInside(bg)
            button.Background:SetAlpha(0)
        end
        if button.ExpandedIcon then
            button:DisableDrawLayer("BACKGROUND")
            button:DisableDrawLayer("BORDER")
        end

        button.bg = bg
    end

    if button:IsShown() then
        if button.PendingGlow and button.PendingGlow:IsShown() then
            button.bg:SetBackdropBorderColor(1, 0.8, 0)
        else
            button.bg:SetBackdropBorderColor(0, 0, 0)
        end
    end
end

local function reskinReforgeUI(frame, index)
    frame:StripTextures(index)
    frame.Background:CreateBackdrop()
    S:SetBD(frame)
    S:ReskinClose(frame.CloseButton)
    S:ReskinIcon(frame.ItemSlot.Icon)

    local buttonFrame = frame.ButtonFrame
    buttonFrame:StripTextures()
    buttonFrame.MoneyFrameEdge:SetAlpha(0)
    local bg = buttonFrame:CreateBackdrop()
    bg:SetPoint("TOPLEFT", buttonFrame.MoneyFrameEdge, "TOPLEFT", 3, 0)
    bg:SetPoint("BOTTOMRIGHT", buttonFrame.MoneyFrameEdge, "BOTTOMRIGHT", 0, 2)
    if buttonFrame.AzeriteRespecButton then S:Reskin(buttonFrame.AzeriteRespecButton) end
    if buttonFrame.ActionButton then S:Reskin(buttonFrame.ActionButton) end
    if buttonFrame.Currency then S:ReskinIcon(buttonFrame.Currency.Icon) end

    -- TODO: frame.DescriptionCurrencies SetCurrencies hook — B.SetCurrenciesHook has no S: equivalent
end

function S:AzeriteUI()
    if not (C.skins.enable and C.skins.azerite) then return end

    S:ReskinPortraitFrame(AzeriteEmpoweredItemUI)
    AzeriteEmpoweredItemUIBg:Hide()
    AzeriteEmpoweredItemUI.ClipFrame.BackgroundFrame.Bg:Hide()
end

S:AddCallbackForAddon("Blizzard_AzeriteUI", "AzeriteUI")

function S:AzeriteEssenceUI()
    if not (C.skins.enable and C.skins.azerite) then return end

    S:ReskinPortraitFrame(AzeriteEssenceUI)
    AzeriteEssenceUI.PowerLevelBadgeFrame:StripTextures()
    S:ReskinTrimScroll(AzeriteEssenceUI.EssenceList.ScrollBar)

    for _, milestoneFrame in pairs(AzeriteEssenceUI.Milestones) do
        if milestoneFrame.LockedState then
            milestoneFrame.LockedState.UnlockLevelText:SetTextColor(0.6, 0.8, 1)
            milestoneFrame.LockedState.UnlockLevelText.SetTextColor = E.Dummy
        end
    end

    hooksecurefunc(AzeriteEssenceUI.EssenceList.ScrollBox, "Update", function(self) self:ForEachFrame(updateEssenceButton) end)
end

S:AddCallbackForAddon("Blizzard_AzeriteEssenceUI", "AzeriteEssenceUI")

function S:AzeriteRespecUI()
    if not (C.skins.enable and C.skins.azerite) then return end

    reskinReforgeUI(AzeriteRespecFrame, 15)
end

S:AddCallbackForAddon("Blizzard_AzeriteRespecUI", "AzeriteRespecUI")

function S:ItemInteractionUI()
    if not (C.skins.enable and C.skins.azerite) then return end

    reskinReforgeUI(ItemInteractionFrame)
end

S:AddCallbackForAddon("Blizzard_ItemInteractionUI", "ItemInteractionUI")
