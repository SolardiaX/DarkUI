local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB

------------------------------------------------------------------------
-- Inspect UI
-- Ported from AuroraClassic AddOns/Blizzard_InspectUI.lua (2026-06)
------------------------------------------------------------------------

local _G = _G
local hooksecurefunc = hooksecurefunc

function S:Inspect()
    if not (C.skins.enable and C.skins.inspect) then return end

    InspectModelFrame:StripTextures()
    InspectGuildFrameBG:Hide()
    S:Reskin(InspectPaperDollFrame.ViewButton)
    InspectPaperDollFrame.ViewButton:ClearAllPoints()
    InspectPaperDollFrame.ViewButton:SetPoint("TOP", InspectFrame, 0, -45)
    InspectPVPFrame.BG:Hide()
    S:Reskin(InspectPaperDollItemsFrame.InspectTalents)

    -- Character
    local slots = {
        "Head",
        "Neck",
        "Shoulder",
        "Shirt",
        "Chest",
        "Waist",
        "Legs",
        "Feet",
        "Wrist",
        "Hands",
        "Finger0",
        "Finger1",
        "Trinket0",
        "Trinket1",
        "Back",
        "MainHand",
        "SecondaryHand",
        "Tabard",
    }

    for i = 1, #slots do
        local slot = _G["Inspect" .. slots[i] .. "Slot"]
        slot:StripTextures()
        slot.icon:SetTexCoords()
        slot.icon:SetInside()
        slot.bg = S:ReskinIcon(slot.icon)
        slot:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
        S:ReskinIconBorder(slot.IconBorder)
        slot.IconOverlay:SetAtlas("CosmeticIconFrame")
        slot.IconOverlay:SetInside()
    end

    local function UpdateCosmetic(self)
        local unit = InspectFrame.unit
        local itemLink = unit and GetInventoryItemLink(unit, self:GetID())
        self.IconOverlay:SetShown(itemLink and C_Item.IsCosmeticItem(itemLink))
    end

    hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(button)
        button.icon:SetShown(button.hasItem)
        UpdateCosmetic(button)
    end)

    for i = 1, 4 do
        local tab = _G["InspectFrameTab" .. i]
        if tab then
            S:ReskinTab(tab)
            if i ~= 1 then
                tab:ClearAllPoints()
                tab:SetPoint("LEFT", _G["InspectFrameTab" .. i - 1], "RIGHT", -15, 0)
            end
        end
    end

    S:ReskinPortraitFrame(InspectFrame)

    --[=[
    -- Talents (disabled in 10.0 in AuroraClassic source; kept commented out)
    ]=]
end

S:AddCallbackForAddon("Blizzard_InspectUI", "Inspect")
