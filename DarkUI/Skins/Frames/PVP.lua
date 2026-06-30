local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB
local cr, cg, cb = DB.r, DB.g, DB.b

------------------------------------------------------------------------
-- PVP UI (Queue / Honor / Conquest)
-- Ported from AuroraClassic AddOns/Blizzard_PVPUI.lua (2026-06)
-- Note: Aurora noise overlay dropped; DarkUI backdrop already carries texture.
------------------------------------------------------------------------

local _G = _G
local select, pairs, ipairs = select, pairs, ipairs
local hooksecurefunc = hooksecurefunc

local function reskinPvPFrame(frame)
    frame:DisableDrawLayer("BACKGROUND")
    frame:DisableDrawLayer("BORDER")
    S:ReskinRole(frame.RoleList.TankIcon, "TANK")
    S:ReskinRole(frame.RoleList.HealerIcon, "HEALER")
    S:ReskinRole(frame.RoleList.DPSIcon, "DPS")

    local bar = frame.ConquestBar
    bar:StripTextures()
    bar:CreateBackdrop()
    bar.backdrop:SetBackdropColor(0, 0, 0, 0.25)
    bar:SetStatusBarTexture(DB.bdTex)
    bar:GetStatusBarTexture():SetGradient("VERTICAL", CreateColor(1, 0.8, 0, 1), CreateColor(0.6, 0.4, 0, 1))

    local reward = bar.Reward
    reward.Ring:Hide()
    reward.CircleMask:Hide()
    S:ReskinIcon(reward.Icon)
    if reward.CheckMark then reward.CheckMark:SetAtlas("checkmark-minimal") end
end

local function conquestFrameButton_OnEnter(self)
    ConquestTooltip:ClearAllPoints()
    ConquestTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 1, 0)
end

function S:PVPUI()
    if not (C.skins.enable and C.skins.pvp) then return end

    local PVPQueueFrame = _G.PVPQueueFrame
    local HonorFrame = _G.HonorFrame
    local ConquestFrame = _G.ConquestFrame

    -- Category buttons

    local iconSize = 60 - 2 * E.mult
    for i = 1, 4 do
        local bu = PVPQueueFrame["CategoryButton" .. i]
        if bu then
            local icon = bu.Icon
            local cu = bu.CurrencyDisplay

            bu.Ring:Hide()
            if bu.CircleMask then bu.CircleMask:Hide() end
            S:Reskin(bu, true)
            bu.Background:SetInside(bu.__bg)
            bu.Background:SetColorTexture(cr, cg, cb, 0.25)
            bu.Background:SetAlpha(1)

            icon:SetPoint("LEFT", bu, "LEFT")
            icon:SetSize(iconSize, iconSize)
            S:ReskinIcon(icon)

            if cu then
                local ic = cu.Icon

                ic:SetSize(16, 16)
                ic:SetPoint("TOPLEFT", bu.Name, "BOTTOMLEFT", 0, -8)
                cu.Amount:SetPoint("LEFT", ic, "RIGHT", 4, 0)
                S:ReskinIcon(ic)
            end
        end
    end

    PVPQueueFrame.CategoryButton1.Icon:SetTexture("Interface\\Icons\\achievement_bg_winwsg")
    PVPQueueFrame.CategoryButton2.Icon:SetTexture("Interface\\Icons\\achievement_bg_killxenemies_generalsroom")
    PVPQueueFrame.CategoryButton3.Icon:SetTexture("Interface\\Icons\\ability_warrior_offensivestance")

    hooksecurefunc("PVPQueueFrame_SelectButton", function(index)
        for i = 1, 4 do
            local bu = PVPQueueFrame["CategoryButton" .. i]
            if i == index then
                bu.Background:Show()
            else
                bu.Background:Hide()
            end
        end
    end)

    PVPQueueFrame.CategoryButton1.Background:SetAlpha(1)
    PVPQueueFrame.HonorInset:StripTextures()
    PVPQueueFrame.HonorInset.Background:Hide()

    local popup = PVPQueueFrame.NewSeasonPopup
    S:Reskin(popup.Leave)
    popup.Leave.__bg:SetFrameLevel(popup:GetFrameLevel() + 1)
    popup.NewSeason:SetTextColor(1, 0.8, 0)
    popup.SeasonRewardText:SetTextColor(1, 0.8, 0)
    popup.SeasonDescriptionHeader:SetTextColor(1, 1, 1)

    popup:HookScript("OnShow", function(self)
        for _, description in pairs(self.SeasonDescriptions) do
            description:SetTextColor(1, 1, 1)
        end
    end)

    local SeasonRewardFrame = popup.SeasonRewardFrame
    SeasonRewardFrame.CircleMask:Hide()
    SeasonRewardFrame.Ring:Hide()
    local bg = S:ReskinIcon(SeasonRewardFrame.Icon)
    bg:SetFrameLevel(4)

    local seasonReward = PVPQueueFrame.HonorInset.RatedPanel.SeasonRewardFrame
    seasonReward.Ring:Hide()
    seasonReward.CircleMask:Hide()
    S:ReskinIcon(seasonReward.Icon)

    -- Honor frame

    HonorFrame.Inset:Hide()
    reskinPvPFrame(HonorFrame)
    S:Reskin(HonorFrame.QueueButton)
    S:ReskinDropDown(_G.HonorFrameTypeDropdown)
    S:ReskinTrimScroll(HonorFrame.SpecificScrollBar)

    hooksecurefunc(HonorFrame.SpecificScrollBox, "Update", function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local button = select(i, self.ScrollTarget:GetChildren())
            if not button.__styled then
                button.Bg:Hide()
                button.Border:Hide()
                button:SetNormalTexture(0)
                button:SetHighlightTexture(0)

                local bg = button:CreateBackdrop()
                bg:SetBackdropColor(0, 0, 0, 0.25)
                bg:SetPoint("TOPLEFT", 2, 0)
                bg:SetPoint("BOTTOMRIGHT", -1, 2)

                button.SelectedTexture:SetDrawLayer("BACKGROUND")
                button.SelectedTexture:SetColorTexture(cr, cg, cb, 0.25)
                button.SelectedTexture:SetInside(bg)

                S:ReskinIcon(button.Icon)
                button.Icon:SetPoint("TOPLEFT", 5, -3)

                button.__styled = true
            end
        end
    end)

    local bonusFrame = HonorFrame.BonusFrame
    bonusFrame.WorldBattlesTexture:Hide()
    bonusFrame.ShadowOverlay:Hide()

    for _, bonusButton in pairs({ "RandomBGButton", "RandomEpicBGButton", "Arena1Button", "BrawlButton", "BrawlButton2" }) do
        local bu = bonusFrame[bonusButton]
        S:Reskin(bu, true)
        bu.SelectedTexture:SetDrawLayer("BACKGROUND")
        bu.SelectedTexture:SetColorTexture(cr, cg, cb, 0.25)
        bu.SelectedTexture:SetInside(bu.__bg)

        local reward = bu.Reward
        if reward then
            reward.Border:Hide()
            reward.CircleMask:Hide()
            reward.Icon.bg = S:ReskinIcon(reward.Icon)
        end
    end

    -- Conquest Frame

    reskinPvPFrame(ConquestFrame)
    ConquestFrame.Inset:Hide()
    ConquestFrame.RatedBGTexture:Hide()
    ConquestFrame.ShadowOverlay:Hide()
    ConquestFrame.Arena2v2:HookScript("OnEnter", conquestFrameButton_OnEnter)
    ConquestFrame.Arena3v3:HookScript("OnEnter", conquestFrameButton_OnEnter)
    ConquestFrame.RatedBG:HookScript("OnEnter", conquestFrameButton_OnEnter)
    S:Reskin(ConquestFrame.JoinButton)

    local names = { "RatedSoloShuffle", "RatedBGBlitz", "Arena2v2", "Arena3v3", "RatedBG" }
    for _, name in pairs(names) do
        local bu = ConquestFrame[name]
        if bu then
            S:Reskin(bu, true)
            local reward = bu.Reward
            if reward then
                reward.Border:Hide()
                reward.CircleMask:Hide()
                reward.Icon.bg = S:ReskinIcon(reward.Icon)
            end

            bu.SelectedTexture:SetDrawLayer("BACKGROUND")
            bu.SelectedTexture:SetColorTexture(cr, cg, cb, 0.25)
            bu.SelectedTexture:SetInside(bu.__bg)
        end
    end

    -- Item Borders for HonorFrame & ConquestFrame

    hooksecurefunc("PVPUIFrame_ConfigureRewardFrame", function(rewardFrame, _, _, itemRewards, currencyRewards)
        local rewardTexture, rewardQuality = nil, 1

        if currencyRewards then
            for _, reward in ipairs(currencyRewards) do
                local info = C_CurrencyInfo.GetCurrencyInfo(reward.id)
                local name, texture, quality = info.name, info.iconFileID, info.quality
                if quality == _G.Enum.ItemQuality.Artifact then
                    _, rewardTexture, _, rewardQuality = CurrencyContainerUtil.GetCurrencyContainerInfo(reward.id, reward.quantity, name, texture, quality)
                end
            end
        end

        if not rewardTexture and itemRewards then
            local reward = itemRewards[1]
            if reward then
                _, _, rewardQuality, _, _, _, _, _, _, rewardTexture = C_Item.GetItemInfo(reward.id)
            end
        end

        if rewardTexture then
            local icon = rewardFrame.Icon
            icon:SetTexture(rewardTexture)
            if icon.bg then
                local color = DB.QualityColors[rewardQuality]
                icon.bg:SetBackdropBorderColor(color.r, color.g, color.b)
            end
        end
    end)

    -- PlunderstormFrame
    if _G.PlunderstormFrame then
        _G.PlunderstormFrame.Inset:Hide()
        S:Reskin(_G.PlunderstormFrame.StartQueue)

        local panel = PVPQueueFrame.HonorInset.PlunderstormPanel
        if panel then
            S:Reskin(panel.PlunderstoreButton)
            S:ReplaceIconString(panel.PlunderDisplay)
            hooksecurefunc(panel.PlunderDisplay, "SetText", function(self) S:ReplaceIconString(self) end)
        end

        local plunderPopup = _G.PlunderstormFramePopup
        if plunderPopup then
            plunderPopup:StripTextures()
            S:SetBD(plunderPopup)
            S:Reskin(plunderPopup.AcceptButton)
            S:Reskin(plunderPopup.DeclineButton)
        end
    end

    -- TrainingGroundsFrame
    if _G.TrainingGroundsFrame then
        reskinPvPFrame(_G.TrainingGroundsFrame)
        S:ReskinDropDown(_G.TrainingGroundsFrameTypeDropdown)
        S:Reskin(_G.TrainingGroundsFrame.QueueButton)
        _G.TrainingGroundsFrame.Inset:StripTextures()
        _G.TrainingGroundsFrame.BonusTrainingGroundList:StripTextures()
        _G.TrainingGroundsFrame.BonusTrainingGroundList.ShadowOverlay:Hide()

        for _, name in pairs({ "RandomTrainingGroundButton" }) do
            local bu = _G.TrainingGroundsFrame.BonusTrainingGroundList[name]
            if bu then
                S:Reskin(bu, true)
                local reward = bu.Reward
                if reward then
                    reward.Border:Hide()
                    reward.CircleMask:Hide()
                    reward.Icon.bg = S:ReskinIcon(reward.Icon)
                end

                bu.SelectedTexture:SetDrawLayer("BACKGROUND")
                bu.SelectedTexture:SetColorTexture(cr, cg, cb, 0.25)
                bu.SelectedTexture:SetInside(bu.__bg)
            end
        end
    end
end

S:AddCallbackForAddon("Blizzard_PVPUI", "PVPUI")
