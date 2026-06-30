local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB

------------------------------------------------------------------------
-- Player Spells (Talents + Spellbook)
-- Ported from AuroraClassic AddOns/Blizzard_PlayerSpells.lua (2026-06)
-- Aurora noise overlay dropped; DarkUI backdrop carries the texture.
------------------------------------------------------------------------

local _G = _G
local select = select
local hooksecurefunc = hooksecurefunc

local function reskinTalentFrameDialog(dialog)
    dialog:StripTextures()
    S:SetBD(dialog)
    if dialog.AcceptButton then S:Reskin(dialog.AcceptButton) end
    if dialog.CancelButton then S:Reskin(dialog.CancelButton) end
    if dialog.DeleteButton then S:Reskin(dialog.DeleteButton) end

    S:ReskinEditBox(dialog.NameControl.EditBox)
    dialog.NameControl.EditBox.__bg:SetPoint("TOPLEFT", -5, -10)
    dialog.NameControl.EditBox.__bg:SetPoint("BOTTOMRIGHT", 5, 10)
end

function S:PlayerSpells()
    if not (C.skins.enable and C.skins.talent) then return end

    local frame = _G.PlayerSpellsFrame

    S:ReskinPortraitFrame(frame)
    S:Reskin(frame.TalentsFrame.ApplyButton)
    S:ReskinDropDown(frame.TalentsFrame.LoadSystem.Dropdown)
    S:Reskin(frame.TalentsFrame.InspectCopyButton)
    S:ReskinMinMax(frame.MaximizeMinimizeButton)

    frame.TalentsFrame.BlackBG:SetAlpha(0.5)
    frame.TalentsFrame.Background:SetAlpha(0.5)
    frame.TalentsFrame.BottomBar:SetAlpha(0.5)

    S:ReskinEditBox(frame.TalentsFrame.SearchBox)
    frame.TalentsFrame.SearchBox.__bg:SetPoint("TOPLEFT", -4, -5)
    frame.TalentsFrame.SearchBox.__bg:SetPoint("BOTTOMRIGHT", 0, 5)

    for i = 1, 3 do
        local tab = select(i, frame.TabSystem:GetChildren())
        S:ReskinTab(tab)
    end

    hooksecurefunc(frame.SpecFrame, "UpdateSpecFrame", function(self)
        for specContentFrame in self.SpecContentFramePool:EnumerateActive() do
            if not specContentFrame.__styled then
                S:Reskin(specContentFrame.ActivateButton)

                local role = GetSpecializationRole(specContentFrame.specIndex)
                if role then S:ReskinSmallRole(specContentFrame.RoleIcon, role) end

                if specContentFrame.SpellButtonPool then
                    for button in specContentFrame.SpellButtonPool:EnumerateActive() do
                        button.Ring:Hide()
                        S:ReskinIcon(button.Icon)

                        local texture = button.spellID and C_Spell.GetSpellTexture(button.spellID)
                        if texture then button.Icon:SetTexture(texture) end
                    end
                end

                specContentFrame.__styled = true
            end
        end
    end)

    local importDialog = _G.ClassTalentLoadoutImportDialog
    if importDialog then
        reskinTalentFrameDialog(importDialog)
        importDialog.ImportControl.InputContainer:StripTextures()
        local inputBg = importDialog.ImportControl.InputContainer:CreateBackdrop()
        inputBg:SetBackdropColor(0, 0, 0, 0.25)
    end

    local createDialog = _G.ClassTalentLoadoutCreateDialog
    if createDialog then reskinTalentFrameDialog(createDialog) end

    local editDialog = _G.ClassTalentLoadoutEditDialog
    if editDialog then
        reskinTalentFrameDialog(editDialog)

        local editbox = editDialog.LoadoutName
        if editbox then
            S:ReskinEditBox(editbox)
            editbox.__bg:SetPoint("TOPLEFT", -5, -5)
            editbox.__bg:SetPoint("BOTTOMRIGHT", 5, 5)
        end

        local check = editDialog.UsesSharedActionBars
        if check then
            S:ReskinCheck(check.CheckButton)
            check.CheckButton.bg:SetInside(nil, 6, 6)
        end
    end

    local heroDialog = _G.HeroTalentsSelectionDialog
    if heroDialog then
        heroDialog:StripTextures()
        S:SetBD(heroDialog, 1)
        S:ReskinClose(heroDialog.CloseButton)

        hooksecurefunc(heroDialog, "ShowDialog", function(self)
            for specFrame in self.SpecContentFramePool:EnumerateActive() do
                if not specFrame.__styled then
                    S:Reskin(specFrame.ActivateButton)
                    S:Reskin(specFrame.ApplyChangesButton)
                    specFrame.__styled = true
                end
            end
        end)
    end

    local spellBook = _G.PlayerSpellsFrame.SpellBookFrame
    if spellBook then
        spellBook.BookBGLeft:SetAlpha(0.5)
        spellBook.BookBGRight:SetAlpha(0.5)
        spellBook.BookBGHalved:SetAlpha(0.5)
        spellBook.Bookmark:SetAlpha(0.5)
        spellBook.BookCornerFlipbook:Hide()

        for i = 1, 3 do
            local tab = select(i, spellBook.CategoryTabSystem:GetChildren())
            S:ReskinTab(tab)
        end
        S:ReskinArrow(spellBook.PagedSpellsFrame.PagingControls.PrevPageButton, "left")
        S:ReskinArrow(spellBook.PagedSpellsFrame.PagingControls.NextPageButton, "right")
        spellBook.PagedSpellsFrame.PagingControls.PageText:SetTextColor(1, 1, 1)
        S:ReskinEditBox(spellBook.SearchBox)
        spellBook.SearchBox.__bg:SetPoint("TOPLEFT", -5, -3)
        spellBook.SearchBox.__bg:SetPoint("BOTTOMRIGHT", 2, 3)

        hooksecurefunc(spellBook.PagedSpellsFrame, "DisplayViewsForCurrentPage", function(self)
            for _, frame in self:EnumerateFrames() do
                if not frame.__styled then
                    if frame.Text then frame.Text:SetTextColor(1, 0.8, 0) end
                    if frame.Name then frame.Name:SetTextColor(1, 1, 1) end
                    if frame.SubName then frame.SubName:SetTextColor(0.7, 0.7, 0.7) end

                    frame.__styled = true
                end
            end
        end)

        local button = spellBook.AssistedCombatRotationSpellFrame and spellBook.AssistedCombatRotationSpellFrame.Button
        if button then
            button.Border:Hide()
            button:SetPushedTexture(0)
            button:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
            S:ReskinIcon(button.Icon)
        end
    end
end

S:AddCallbackForAddon("Blizzard_PlayerSpells", "PlayerSpells")
