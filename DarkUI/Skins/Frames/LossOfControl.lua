local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB

------------------------------------------------------------------------
-- Loss of Control Frame (FrameXML, always loaded)
-- Ported from AuroraClassic FrameXML/LossOfControlFrame.lua (2026-06)
-- Note: Aurora noise overlay dropped; DarkUI backdrop carries texture.
------------------------------------------------------------------------

function S:LossOfControl()
    if not (C.skins.enable and C.skins.misc) then return end

    local styled
    hooksecurefunc(LossOfControlFrame, "SetUpDisplay", function(self)
        if not styled then
            S:ReskinIcon(self.Icon, true)

            styled = true
        end
    end)
end

S:AddCallback("LossOfControl")
