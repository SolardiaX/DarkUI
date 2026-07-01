local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Ready Check + Role Poll Popup
-- Ported from AuroraClassic FrameXML/ReadyCheck.lua (2026-06)
------------------------------------------------------------------------

function S:ReadyCheck()
    if not (C.skins.enable and C.skins.misc) then return end

    -- Ready check
    ReadyCheckListenerFrame:StripTextures()
    S:CreateBackground(ReadyCheckListenerFrame, nil, 30, -1, 1, -1)
    ReadyCheckPortrait:SetAlpha(0)

    S:ReskinButton(ReadyCheckFrameYesButton)
    S:ReskinButton(ReadyCheckFrameNoButton)

    -- Role poll
    RolePollPopup:StripTextures()
    S:CreateBackground(RolePollPopup)
    S:ReskinButton(RolePollPopupAcceptButton)
    S:ReskinClose(RolePollPopupCloseButton)

    S:ReskinRole(RolePollPopupRoleButtonTank)
    S:ReskinRole(RolePollPopupRoleButtonHealer)
    S:ReskinRole(RolePollPopupRoleButtonDPS)
end

S:AddCallback("ReadyCheck")
