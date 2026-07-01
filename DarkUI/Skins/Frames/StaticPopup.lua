local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local cr, cg, cb = E.myColor.r, E.myColor.g, E.myColor.b

------------------------------------------------------------------------
-- Static Popup Dialogs + Pet Battle Queue + Player Report Frame
-- Ported from AuroraClassic FrameXML/StaticPopup.lua (2026-06)
------------------------------------------------------------------------

local _G = _G
local hooksecurefunc = hooksecurefunc

local STATICPOPUP_NUMDIALOGS = STATICPOPUP_NUMDIALOGS or 4

local function colorMinimize(f)
    if f:IsEnabled() then f.minimize:SetVertexColor(cr, cg, cb) end
end

local function clearMinimize(f) f.minimize:SetVertexColor(1, 1, 1) end

local function updateMinorButtonState(button)
    if button:GetChecked() then
        button.bg:SetBackdropColor(1, 0.8, 0, 0.25)
    else
        button.bg:SetBackdropColor(0, 0, 0, 0.25)
    end
end

function S:StaticPopup()
    if not (C.skins.enable and C.skins.misc) then return end

    for i = 1, 4 do
        local frame = _G["StaticPopup" .. i]
        local itemFrame = frame.ItemFrame
        local bu = itemFrame.Item
        local icon = _G["StaticPopup" .. i .. "IconTexture"]
        local close = _G["StaticPopup" .. i .. "CloseButton"]

        local gold = _G["StaticPopup" .. i .. "MoneyInputFrameGold"]
        local silver = _G["StaticPopup" .. i .. "MoneyInputFrameSilver"]
        local copper = _G["StaticPopup" .. i .. "MoneyInputFrameCopper"]

        if itemFrame.NameFrame then itemFrame.NameFrame:Hide() end

        if bu then
            bu:SetNormalTexture(0)
            bu:SetHighlightTexture(0)
            bu:SetPushedTexture(0)
            bu.bg = S:ReskinIcon(icon)
            S:ReskinIconBorder(bu.IconBorder)

            -- release slot so the row backdrop below doesn't clobber icon backdrop
            bu.backdrop = nil
            local bg = bu:CreateBackdrop()
            bg:SetPoint("TOPLEFT", bu.bg, "TOPRIGHT", 2, 0)
            bg:SetPoint("BOTTOMRIGHT", bu.bg, 115, 0)
        end

        silver:SetPoint("LEFT", gold, "RIGHT", 1, 0)
        copper:SetPoint("LEFT", silver, "RIGHT", 1, 0)

        frame:StripTextures()
        for j = 1, 4 do
            S:ReskinButton(_G["StaticPopup" .. i .. "Button" .. j])
        end
        S:CreateBackground(frame)
        S:ReskinClose(close)

        -- minimize line shown when closeButtonIsHide is set
        close.minimize = close:CreateTexture(nil, "OVERLAY")
        close.minimize:SetSize(9, E.mult)
        close.minimize:SetPoint("CENTER")
        close.minimize:SetTexture(C.media.texture.blank)
        close.minimize:SetVertexColor(1, 1, 1)
        close:HookScript("OnEnter", colorMinimize)
        close:HookScript("OnLeave", clearMinimize)

        S:ReskinEditBox(frame.EditBox)
        if frame.EditBox.NineSlice then frame.EditBox.NineSlice:SetAlpha(0) end
        S:ReskinEditBox(gold)
        S:ReskinEditBox(silver)
        S:ReskinEditBox(copper)
    end

    hooksecurefunc("StaticPopup_Show", function(which, _, _, data)
        local info = StaticPopupDialogs[which]
        if not info then return end

        local dialog = StaticPopup_FindVisible(which, data)

        if not dialog then
            local index = info.preferredIndex or 1
            for i = index, STATICPOPUP_NUMDIALOGS do
                local frame = _G["StaticPopup" .. i]
                if not frame:IsShown() then
                    dialog = frame
                    break
                end
            end

            if not dialog and info.preferredIndex then
                for i = 1, info.preferredIndex do
                    local frame = _G["StaticPopup" .. i]
                    if not frame:IsShown() then
                        dialog = frame
                        break
                    end
                end
            end
        end

        if not dialog then return end

        if info.closeButton then
            local closeButton = _G[dialog:GetName() .. "CloseButton"]

            closeButton:SetNormalTexture(0)
            closeButton:SetPushedTexture(0)

            -- DarkUI StyleCloseButton stores the X icon as .__tex (not .__texture)
            if info.closeButtonIsHide then
                if closeButton.__tex then closeButton.__tex:Hide() end
                closeButton.minimize:Show()
            else
                if closeButton.__tex then closeButton.__tex:Show() end
                closeButton.minimize:Hide()
            end
        end
    end)

    -- Pet battle queue popup
    S:CreateBackground(PetBattleQueueReadyFrame)
    PetBattleQueueReadyFrame.Art:CreateBackdrop()
    PetBattleQueueReadyFrame.Border:Hide()
    S:ReskinButton(PetBattleQueueReadyFrame.AcceptButton)
    S:ReskinButton(PetBattleQueueReadyFrame.DeclineButton)

    -- PlayerReportFrame
    ReportFrame:StripTextures()
    S:CreateBackground(ReportFrame)
    S:ReskinClose(ReportFrame.CloseButton)
    S:ReskinButton(ReportFrame.ReportButton)
    S:ReskinDropDown(ReportFrame.ReportingMajorCategoryDropdown)
    S:ReskinEditBox(ReportFrame.Comment)

    hooksecurefunc(ReportFrame, "AnchorMinorCategory", function(self)
        if self.MinorCategoryButtonPool then
            for button in self.MinorCategoryButtonPool:EnumerateActive() do
                if not button.__styled then
                    button:StripTextures()
                    button.backdrop = nil
                    button.bg = button:CreateBackdrop()
                    button:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
                    button:HookScript("OnClick", updateMinorButtonState)

                    button.__styled = true
                end

                updateMinorButtonState(button)
            end
        end
    end)
end

S:AddCallback("StaticPopup")
