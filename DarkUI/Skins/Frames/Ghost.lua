local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB
local cr, cg, cb = DB.r, DB.g, DB.b

------------------------------------------------------------------------
-- Ghost (Release Spirit) Frame
-- Ported from AuroraClassic FrameXML/GhostFrame.lua (2026-06)
-- Note: B.CreateGradient(bg) → bg:CreateGradient() (DarkUI metatable atom)
------------------------------------------------------------------------

local select = select

function S:Ghost()
    if not (C.skins.enable and C.skins.misc) then return end

    for i = 1, 6 do
        select(i, GhostFrame:GetRegions()):Hide()
    end
    S:ReskinIcon(GhostFrameContentsFrameIcon)

    local bg = S:SetBD(GhostFrame, 0)
    bg:CreateGradient()
    GhostFrame:SetHighlightTexture(DB.bdTex)
    GhostFrame:GetHighlightTexture():SetVertexColor(cr, cg, cb, 0.25)
end

S:AddCallback("Ghost")
