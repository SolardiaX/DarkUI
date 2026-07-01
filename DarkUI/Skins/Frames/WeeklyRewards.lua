local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Weekly Rewards (Great Vault)
-- Ported from AuroraClassic AddOns/Blizzard_WeeklyRewards.lua (2026-06)
-- Notes:
--   * Aurora noise overlay dropped; DarkUI backdrop supplies texture.
------------------------------------------------------------------------

local _G = _G
local select, gsub, pairs = select, gsub, pairs
local hooksecurefunc = hooksecurefunc

local function updateSelection(frame)
    if not frame.bg then return end

    if frame.SelectedTexture:IsShown() then
        frame.bg:SetBackdropBorderColor(1, 0.8, 0)
    else
        frame.bg:SetBackdropBorderColor(0, 0, 0)
    end
end

local iconColor = C.media.qualityColors[Enum.ItemQuality.Epic or 4]
local function reskinRewardIcon(itemFrame)
    if not itemFrame.bg then
        itemFrame:DisableDrawLayer("BORDER")
        itemFrame.Icon:SetPoint("LEFT", 6, 0)
        itemFrame.bg = S:ReskinIcon(itemFrame.Icon)
        itemFrame.bg:SetBackdropBorderColor(iconColor.r, iconColor.g, iconColor.b)
    end
end

local function fixBg(anim)
    if anim.bg then anim.bg:SetBackdropColor(0, 0, 0, 0.25) end
end

local function reskinActivityFrame(frame, isObject)
    if frame.Border then
        if isObject then
            hooksecurefunc(frame, "SetSelectionState", updateSelection)
            hooksecurefunc(frame.ItemFrame, "SetDisplayedItem", reskinRewardIcon)

            if frame.SheenAnim then
                frame.SheenAnim.bg = frame.ItemFrame:CreateBackdrop()
                frame.SheenAnim:HookScript("OnFinished", fixBg)
            end
        else
            frame.Border:SetTexCoord(0.926, 1, 0, 1)
            frame.Border:SetSize(25, 137)
            frame.Border:SetPoint("LEFT", frame, "RIGHT", 3, 0)
        end
    end
end

local function replaceIconString(self, text)
    if not text then text = self:GetText() end
    if not text or text == "" then return end

    local newText, count = gsub(text, "24:24:0:%-2", "14:14:0:0:64:64:5:59:5:59")
    if count > 0 then self:SetFormattedText("%s", newText) end
end

local function reskinConfirmIcon(frame)
    if frame.bg then return end
    frame.bg = S:ReskinIcon(frame.Icon)
    S:ReskinIconBorder(frame.IconBorder, true)
end

function S:WeeklyRewards()
    if not C.general.skins then return end

    local WeeklyRewardsFrame = _G.WeeklyRewardsFrame

    local bg = S:CreateBackground(WeeklyRewardsFrame)
    S:ReskinClose(WeeklyRewardsFrame.CloseButton)
    WeeklyRewardsFrame.SelectRewardButton:StripTextures()
    S:ReskinButton(WeeklyRewardsFrame.SelectRewardButton)

    WeeklyRewardsFrame.BorderShadow:SetInside(bg)
    WeeklyRewardsFrame.BorderContainer:SetAlpha(0)

    reskinActivityFrame(WeeklyRewardsFrame.RaidFrame)
    reskinActivityFrame(WeeklyRewardsFrame.MythicFrame)
    reskinActivityFrame(WeeklyRewardsFrame.PVPFrame)
    reskinActivityFrame(WeeklyRewardsFrame.WorldFrame)

    for _, frame in pairs(WeeklyRewardsFrame.Activities) do
        reskinActivityFrame(frame, true)
    end

    hooksecurefunc(WeeklyRewardsFrame, "SelectReward", function(self)
        local confirmFrame = self.confirmSelectionFrame
        if confirmFrame then
            if not confirmFrame.__styled then
                reskinConfirmIcon(confirmFrame.ItemFrame)
                _G.WeeklyRewardsFrameNameFrame:Hide()
                confirmFrame.__styled = true
            end

            local alsoItemsFrame = confirmFrame.AlsoItemsFrame
            if alsoItemsFrame.pool then
                for frame in alsoItemsFrame.pool:EnumerateActive() do
                    reskinConfirmIcon(frame)
                end
            end
        end
    end)

    local rewardText = WeeklyRewardsFrame.ConcessionFrame.RewardsFrame.Text
    replaceIconString(rewardText)
    hooksecurefunc(rewardText, "SetText", replaceIconString)

    local dialog = _G.WeeklyRewardExpirationWarningDialog
    if dialog then
        dialog:StripTextures()
        S:CreateBackground(dialog)
    end
end

S:AddCallbackForAddon("Blizzard_WeeklyRewards", "WeeklyRewards")
