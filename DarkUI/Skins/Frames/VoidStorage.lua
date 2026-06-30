local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB

------------------------------------------------------------------------
-- Void Storage UI
-- Ported from AuroraClassic AddOns/Blizzard_VoidStorageUI.lua (2026-06)
-- Dropped: Aurora noise-overlay CreateTex (DarkUI backdrop carries texture)
------------------------------------------------------------------------

local _G = _G
local select, hooksecurefunc = select, hooksecurefunc

function S:VoidStorage()
    if not (C.skins.enable and C.skins.voidStorage) then return end

    S:SetBD(VoidStorageFrame, nil, 20, 0, 0, 20)
    VoidStoragePurchaseFrame:CreateBackdrop()
    VoidStorageBorderFrame:StripTextures()
    VoidStorageDepositFrame:StripTextures()
    VoidStorageWithdrawFrame:StripTextures()
    VoidStorageCostFrame:StripTextures()
    VoidStorageStorageFrame:StripTextures()
    VoidStorageFrameMarbleBg:Hide()
    VoidStorageFrameLines:Hide()
    select(2, VoidStorageFrame:GetRegions()):Hide()

    local function reskinIcons(bu, quality)
        if not bu.bg then
            bu:SetPushedTexture(0)
            bu:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
            bu.IconBorder:SetAlpha(0)
            bu.bg = bu:CreateBackdrop()
            bu.bg:SetBackdropColor(0.3, 0.3, 0.3, 0.3)
            local bg, icon, _, search = bu:GetRegions()
            bg:Hide()
            icon:SetTexCoord(unpack(DB.TexCoord))
            search:SetAllPoints(bu.bg)
        end

        local color = DB.QualityColors[quality or 1]
        bu.bg:SetBackdropBorderColor(color.r, color.g, color.b)
    end

    local function hookItemsUpdate(doDeposit, doContents)
        if doDeposit then
            for i = 1, 9 do
                local quality = select(3, GetVoidTransferDepositInfo(i))
                local bu = _G["VoidStorageDepositButton" .. i]
                reskinIcons(bu, quality)
            end
        end

        if doContents then
            for i = 1, 9 do
                local quality = select(3, GetVoidTransferWithdrawalInfo(i))
                local bu = _G["VoidStorageWithdrawButton" .. i]
                reskinIcons(bu, quality)
            end

            for i = 1, 80 do
                local quality = select(6, GetVoidItemInfo(VoidStorageFrame.page, i))
                local bu = _G["VoidStorageStorageButton" .. i]
                reskinIcons(bu, quality)
            end
        end
    end
    hooksecurefunc("VoidStorage_ItemsUpdate", hookItemsUpdate)

    for i = 1, 2 do
        local tab = VoidStorageFrame["Page" .. i]
        tab:GetRegions():Hide()
        tab:SetCheckedTexture(DB.pushedTex)
        tab:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
        tab:GetNormalTexture():SetTexCoord(unpack(DB.TexCoord))
        tab:CreateBackdrop()
    end

    VoidStorageFrame.Page1:ClearAllPoints()
    VoidStorageFrame.Page1:SetPoint("LEFT", VoidStorageFrame, "TOPRIGHT", 2, -60)

    S:Reskin(VoidStoragePurchaseButton)
    S:Reskin(VoidStorageTransferButton)
    S:ReskinClose(VoidStorageBorderFrame.CloseButton)
    S:ReskinInput(VoidItemSearchBox)
end

S:AddCallbackForAddon("Blizzard_VoidStorageUI", "VoidStorage")
