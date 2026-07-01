local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB
local cr, cg, cb = DB.r, DB.g, DB.b

------------------------------------------------------------------------
-- Class Trainer UI
-- Ported from AuroraClassic AddOns/Blizzard_TrainerUI.lua (2026-06)
-- Aurora noise overlay dropped; DarkUI backdrop carries the texture.
-- Note: B.CreateBDFrame(f, alpha) → f:CreateBackdrop() + SetBackdropColor.
------------------------------------------------------------------------

local _G = _G
local select = select
local hooksecurefunc = hooksecurefunc

function S:Trainer()
    if not (C.skins.enable and C.skins.trainer) then return end

    S:ReskinPortraitFrame(_G.ClassTrainerFrame)
    _G.ClassTrainerStatusBarSkillRank:ClearAllPoints()
    _G.ClassTrainerStatusBarSkillRank:SetPoint("CENTER", _G.ClassTrainerStatusBar, "CENTER", 0, 0)

    local icbg = S:ReskinIcon(_G.ClassTrainerFrameSkillStepButtonIcon)
    _G.ClassTrainerFrameSkillStepButton.backdrop = nil -- dedup: icon bg took .backdrop; free slot for row bg
    local bg = _G.ClassTrainerFrameSkillStepButton:CreateBackdrop()
    bg:SetBackdropColor(0, 0, 0, 0.25)
    bg:SetPoint("TOPLEFT", icbg, "TOPRIGHT", 1, 0)
    bg:SetPoint("BOTTOMRIGHT", icbg, "BOTTOMRIGHT", 270, 0)

    _G.ClassTrainerFrameSkillStepButton:SetNormalTexture(0)
    _G.ClassTrainerFrameSkillStepButton:SetHighlightTexture(0)
    _G.ClassTrainerFrameSkillStepButton.disabledBG:SetTexture(0)
    _G.ClassTrainerFrameSkillStepButton.selectedTex:SetInside(bg)
    _G.ClassTrainerFrameSkillStepButton.selectedTex:SetColorTexture(cr, cg, cb, 0.25)

    _G.ClassTrainerStatusBar:StripTextures()
    _G.ClassTrainerStatusBar:SetPoint("TOPLEFT", _G.ClassTrainerFrame, "TOPLEFT", 64, -35)
    _G.ClassTrainerStatusBar:SetStatusBarTexture(DB.bdTex)
    local statusBg = _G.ClassTrainerStatusBar:CreateBackdrop()
    statusBg:SetBackdropColor(0, 0, 0, 0.25)

    _G.ClassTrainerStatusBar:GetStatusBarTexture():SetGradient("VERTICAL", CreateColor(0.1, 0.3, 0.9, 1), CreateColor(0.2, 0.4, 1, 1))
    S:ReskinTrimScroll(_G.ClassTrainerFrame.ScrollBar)

    hooksecurefunc(_G.ClassTrainerFrame.ScrollBox, "Update", function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local button = select(i, self.ScrollTarget:GetChildren())
            if not button.__styled then
                local buttonIconBg = S:ReskinIcon(button.icon)
                button.backdrop = nil -- dedup: icon bg took .backdrop; free slot for row bg
                local buttonBg = button:CreateBackdrop()
                buttonBg:SetBackdropColor(0, 0, 0, 0.25)
                buttonBg:SetPoint("TOPLEFT", buttonIconBg, "TOPRIGHT", 1, 0)
                buttonBg:SetPoint("BOTTOMRIGHT", buttonIconBg, "BOTTOMRIGHT", 253, 0)

                button.name:SetParent(buttonBg)
                button.name:SetPoint("TOPLEFT", button.icon, "TOPRIGHT", 6, -2)
                button.subText:SetParent(buttonBg)
                button.money:SetParent(buttonBg)
                button.money:SetPoint("TOPRIGHT", button, "TOPRIGHT", 5, -8)
                button:SetNormalTexture(0)
                button:SetHighlightTexture(0)
                button.disabledBG:SetTexture(0)
                button.selectedTex:SetInside(buttonBg)
                button.selectedTex:SetColorTexture(cr, cg, cb, 0.25)

                button.__styled = true
            end
        end
    end)

    S:Reskin(_G.ClassTrainerTrainButton)
    S:ReskinFilterButton(_G.ClassTrainerFrame.FilterDropdown)
end

S:AddCallbackForAddon("Blizzard_TrainerUI", "Trainer")
