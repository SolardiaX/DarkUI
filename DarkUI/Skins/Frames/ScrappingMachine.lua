local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB

------------------------------------------------------------------------
-- Scrapping Machine UI
-- Ported from AuroraClassic AddOns/Blizzard_ScrappingMachineUI.lua (2026-06)
-- Dropped: Aurora noise-overlay CreateTex (DarkUI backdrop carries texture)
------------------------------------------------------------------------

local hooksecurefunc = hooksecurefunc

function S:ScrappingMachine()
    if not (C.skins.enable and C.skins.scrapping) then return end

    S:ReskinPortraitFrame(ScrappingMachineFrame)
    S:Reskin(ScrappingMachineFrame.ScrapButton)

    local ItemSlots = ScrappingMachineFrame.ItemSlots
    ItemSlots:StripTextures()

    hooksecurefunc(ScrappingMachineFrame, "UpdateScrapButtonState", function(self)
        for button in self.ItemSlots.scrapButtons:EnumerateActive() do
            if not button.bg then
                button:StripTextures()
                button.Icon:SetTexCoord(unpack(DB.TexCoord))
                button.bg = button.Icon:CreateBackdrop()
                S:ReskinIconBorder(button.IconBorder)
                local hl = button:GetHighlightTexture()
                hl:SetColorTexture(1, 1, 1, 0.25)
                hl:SetAllPoints(button.Icon)
            end
        end
    end)
end

S:AddCallbackForAddon("Blizzard_ScrappingMachineUI", "ScrappingMachine")
