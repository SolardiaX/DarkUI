local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB

------------------------------------------------------------------------
-- Death Recap UI
-- Ported from AuroraClassic AddOns/Blizzard_DeathRecap.lua (2026-06)
-- Note: Aurora noise overlay dropped; DarkUI backdrop carries texture.
------------------------------------------------------------------------

local hooksecurefunc = hooksecurefunc

function S:DeathRecap()
    if not (C.skins.enable and C.skins.deathRecap) then return end

    local DeathRecapFrame = DeathRecapFrame

    DeathRecapFrame:DisableDrawLayer("BORDER")
    DeathRecapFrame.Background:Hide()
    DeathRecapFrame.BackgroundInnerGlow:Hide()
    DeathRecapFrame.Divider:Hide()

    S:SetBD(DeathRecapFrame)
    S:Reskin(DeathRecapFrame.CloseButton)
    S:ReskinClose(DeathRecapFrame.CloseXButton)

    local function updateEntry(button)
        local recap = button.SpellInfo
        if not recap or recap.__styled then return end

        if recap.Icon then S:ReskinIcon(recap.Icon) end
        recap.IconBorder:Hide()
        recap.__styled = true
    end

    S:ReskinTrimScroll(DeathRecapFrame.ScrollBar)
    hooksecurefunc(DeathRecapFrame.ScrollBox, "Update", function(self) self:ForEachFrame(updateEntry) end)
end

S:AddCallbackForAddon("Blizzard_DeathRecap", "DeathRecap")
