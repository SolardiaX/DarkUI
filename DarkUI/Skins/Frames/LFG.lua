local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- LFD / RaidFinder / Ready Dialogs / Role Buttons
-- Ported from AuroraClassic FrameXML/LFGFrame.lua (2026-06)
-- Note: Aurora noise overlay dropped; DarkUI backdrop already carries texture.
------------------------------------------------------------------------

local _G = _G
local select = select
local hooksecurefunc = hooksecurefunc

local function styleRewardButton(button)
    if not button or button.__styled then return end

    local buttonName = button:GetName()
    local icon = _G[buttonName .. "IconTexture"]
    local shortageBorder = _G[buttonName .. "ShortageBorder"]
    local count = _G[buttonName .. "Count"]
    local nameFrame = _G[buttonName .. "NameFrame"]
    local border = button.IconBorder

    button.bg = S:ReskinIcon(icon)
    button.backdrop = nil -- dedup: icon bg consumed .backdrop; release slot for row bg
    local bg = button:CreateBackdrop()
    bg:SetBackdropColor(0, 0, 0, 0.25)
    bg:SetPoint("TOPLEFT", button.bg, "TOPRIGHT", 1, 0)
    bg:SetPoint("BOTTOMRIGHT", button.bg, "BOTTOMRIGHT", 105, 0)

    if shortageBorder then shortageBorder:SetAlpha(0) end
    if count then count:SetDrawLayer("OVERLAY") end
    if nameFrame then nameFrame:SetAlpha(0) end
    if border then S:ReskinIconBorder(border) end

    button.__styled = true
end

local function reskinDialogReward(button)
    if button.__styled then return end

    local border = _G[button:GetName() .. "Border"]
    button.texture:SetTexCoord(unpack(C.media.texCoord))
    border:SetColorTexture(0, 0, 0)
    border:SetDrawLayer("BACKGROUND")
    border:SetOutside(button.texture)
    button.__styled = true
end

local function styleRewardRole(roleIcon)
    if roleIcon and roleIcon:IsShown() then S:ReskinSmallRole(roleIcon.texture, roleIcon.role) end
end

function S:LFGFrame()
    if not (C.skins.enable and C.skins.lfg) then return end

    -- LFDFrame
    hooksecurefunc("LFGDungeonListButton_SetDungeon", function(button)
        if not button.expandOrCollapseButton.__styled then
            S:ReskinCheck(button.enableButton)
            S:ReskinCollapse(button.expandOrCollapseButton)

            button.expandOrCollapseButton.__styled = true
        end

        button.enableButton:GetCheckedTexture():SetAtlas("checkmark-minimal")
        local disabledTexture = button.enableButton:GetDisabledCheckedTexture()
        disabledTexture:SetAtlas("checkmark-minimal")
        disabledTexture:SetDesaturated(true)
    end)

    _G.LFDParentFrame:StripTextures()
    _G.LFDQueueFrameBackground:Hide()
    S:CreateBackground(_G.LFDRoleCheckPopup)
    _G.LFDRoleCheckPopup.Border:Hide()
    S:ReskinButton(_G.LFDRoleCheckPopupAcceptButton)
    S:ReskinButton(_G.LFDRoleCheckPopupDeclineButton)
    S:ReskinTrimScrollBar(_G.LFDQueueFrameSpecific.ScrollBar)
    S:ReskinTrimScrollBar(_G.LFDQueueFrameRandomScrollFrame.ScrollBar)
    S:ReskinDropDown(_G.LFDQueueFrameTypeDropdown)
    S:ReskinButton(_G.LFDQueueFrameFindGroupButton)
    S:ReskinButton(_G.LFDQueueFramePartyBackfillBackfillButton)
    S:ReskinButton(_G.LFDQueueFramePartyBackfillNoBackfillButton)
    S:ReskinButton(_G.LFDQueueFrameNoLFDWhileLFRLeaveQueueButton)
    styleRewardButton(_G.LFDQueueFrameRandomScrollFrameChildFrameMoneyReward)

    -- LFGFrame
    hooksecurefunc("LFGRewardsFrame_SetItemButton", function(parentFrame, _, index)
        styleRewardButton(parentFrame.MoneyReward)

        local button = _G[parentFrame:GetName() .. "Item" .. index]
        styleRewardButton(button)
        styleRewardRole(button.roleIcon1)
        styleRewardRole(button.roleIcon2)
    end)

    hooksecurefunc("LFGDungeonReadyDialogReward_SetMisc", function(button)
        reskinDialogReward(button)
        button.texture:SetTexture("Interface\\Icons\\inv_misc_coin_02")
    end)

    hooksecurefunc("LFGDungeonReadyDialogReward_SetReward", function(button, dungeonID, rewardIndex, rewardType, rewardArg)
        reskinDialogReward(button)

        local texturePath
        if rewardType == "reward" then
            texturePath = select(2, GetLFGDungeonRewardInfo(dungeonID, rewardIndex))
        elseif rewardType == "shortage" then
            texturePath = select(2, GetLFGDungeonShortageRewardInfo(dungeonID, rewardArg, rewardIndex))
        end
        if texturePath then button.texture:SetTexture(texturePath) end
    end)

    _G.LFGDungeonReadyDialog:StripTextures(0)
    S:CreateBackground(_G.LFGDungeonReadyDialog)
    _G.LFGInvitePopup:StripTextures()
    S:CreateBackground(_G.LFGInvitePopup)
    _G.LFGDungeonReadyStatus:StripTextures()
    S:CreateBackground(_G.LFGDungeonReadyStatus)

    S:ReskinButton(_G.LFGDungeonReadyDialogEnterDungeonButton)
    S:ReskinButton(_G.LFGDungeonReadyDialogLeaveQueueButton)
    S:ReskinButton(_G.LFGInvitePopupAcceptButton)
    S:ReskinButton(_G.LFGInvitePopupDeclineButton)
    S:ReskinClose(_G.LFGDungeonReadyDialogCloseButton)
    S:ReskinClose(_G.LFGDungeonReadyStatusCloseButton)

    local roleButtons = {
        -- tank
        _G.LFDQueueFrameRoleButtonTank,
        _G.LFDRoleCheckPopupRoleButtonTank,
        _G.RaidFinderQueueFrameRoleButtonTank,
        _G.LFGInvitePopupRoleButtonTank,
        _G.LFGListApplicationDialog.TankButton,
        _G.LFGDungeonReadyStatusGroupedTank,
        -- healer
        _G.LFDQueueFrameRoleButtonHealer,
        _G.LFDRoleCheckPopupRoleButtonHealer,
        _G.RaidFinderQueueFrameRoleButtonHealer,
        _G.LFGInvitePopupRoleButtonHealer,
        _G.LFGListApplicationDialog.HealerButton,
        _G.LFGDungeonReadyStatusGroupedHealer,
        -- dps
        _G.LFDQueueFrameRoleButtonDPS,
        _G.LFDRoleCheckPopupRoleButtonDPS,
        _G.RaidFinderQueueFrameRoleButtonDPS,
        _G.LFGInvitePopupRoleButtonDPS,
        _G.LFGListApplicationDialog.DamagerButton,
        _G.LFGDungeonReadyStatusGroupedDamager,
        -- leader
        _G.LFDQueueFrameRoleButtonLeader,
        _G.RaidFinderQueueFrameRoleButtonLeader,
        _G.LFGDungeonReadyStatusRolelessReady,
    }
    for _, roleButton in pairs(roleButtons) do
        S:ReskinRole(roleButton)
    end

    hooksecurefunc("SetCheckButtonIsRadio", function(button)
        button:SetNormalTexture(0)
        button:SetHighlightTexture(C.media.texture.blank)
        button:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
        button:GetCheckedTexture():SetTexCoord(0, 1, 0, 1)
        button:SetPushedTexture(0)
        button:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
        button:GetDisabledCheckedTexture():SetTexCoord(0, 1, 0, 1)
    end)

    -- RaidFinder
    _G.RaidFinderFrameBottomInset:Hide()
    _G.RaidFinderFrameRoleBackground:Hide()
    _G.RaidFinderFrameRoleInset:Hide()
    _G.RaidFinderQueueFrameBackground:Hide()
    -- this fixes right border of second reward being cut off
    _G.RaidFinderQueueFrameScrollFrame:SetWidth(_G.RaidFinderQueueFrameScrollFrame:GetWidth() + 1)

    S:ReskinTrimScrollBar(_G.RaidFinderQueueFrameScrollFrame.ScrollBar)
    S:ReskinDropDown(_G.RaidFinderQueueFrameSelectionDropdown)
    S:ReskinButton(_G.RaidFinderFrameFindRaidButton)
    S:ReskinButton(_G.RaidFinderQueueFrameIneligibleFrameLeaveQueueButton)
    S:ReskinButton(_G.RaidFinderQueueFramePartyBackfillBackfillButton)
    S:ReskinButton(_G.RaidFinderQueueFramePartyBackfillNoBackfillButton)
    styleRewardButton(_G.RaidFinderQueueFrameScrollFrameChildFrameMoneyReward)
end

S:AddCallback("LFGFrame")
