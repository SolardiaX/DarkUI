local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Item Upgrade UI
-- Ported from AuroraClassic AddOns/Blizzard_ItemUpgradeUI.lua (2026-06)
-- Aurora noise overlay dropped (DarkUI backdrop carries texture).
------------------------------------------------------------------------

local _G = _G
local hooksecurefunc = hooksecurefunc

local function reskinCurrencyIcon(self)
    for frame in self.iconPool:EnumerateActive() do
        if not frame.bg then
            frame.bg = S:ReskinIcon(frame.Icon)
            frame.bg:SetFrameLevel(2)
        end
    end
end

function S:ItemUpgrade()
    if not (C.skins.enable and C.skins.itemUpgrade) then return end

    local ItemUpgradeFrame = ItemUpgradeFrame
    S:ReskinPortraitFrame(ItemUpgradeFrame)

    hooksecurefunc(ItemUpgradeFrame, "UpdateUpgradeItemInfo", function(self)
        if self.upgradeInfo then self.UpgradeItemButton:SetPushedTexture(0) end
    end)

    local bg = ItemUpgradeFrame:CreateBackdrop()
    bg:SetPoint("TOPLEFT", 20, -25)
    bg:SetPoint("BOTTOMRIGHT", -20, 375)

    local itemButton = ItemUpgradeFrame.UpgradeItemButton
    itemButton.ButtonFrame:Hide()
    itemButton:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
    itemButton.bg = S:ReskinIcon(itemButton.icon)
    S:ReskinIconBorder(itemButton.IconBorder)

    S:ReskinDropDown(ItemUpgradeFrame.ItemInfo.Dropdown)
    S:ReskinButton(ItemUpgradeFrame.UpgradeButton)
    ItemUpgradeFramePlayerCurrenciesBorder:Hide()

    ItemUpgradeFrameLeftItemPreviewFrame:CreateBackdrop()
    ItemUpgradeFrameLeftItemPreviewFrame.NineSlice:SetAlpha(0)
    ItemUpgradeFrameRightItemPreviewFrame:CreateBackdrop()
    ItemUpgradeFrameRightItemPreviewFrame.NineSlice:SetAlpha(0)

    hooksecurefunc(ItemUpgradeFrame.UpgradeCostFrame, "GetIconFrame", reskinCurrencyIcon)
    hooksecurefunc(ItemUpgradeFrame.PlayerCurrencies, "GetIconFrame", reskinCurrencyIcon)

    -- TODO: no S: facade for ReskinTooltip
end

S:AddCallbackForAddon("Blizzard_ItemUpgradeUI", "ItemUpgrade")
