local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Guild Invite Frame
-- Ported from AuroraClassic FrameXML/GuildInviteFrame.lua (2026-06)
------------------------------------------------------------------------

local _G = _G
local select = select

function S:GuildInvite()
    if not (C.skins.enable and C.skins.guild) then return end

    S:CreateBackground(_G.GuildInviteFrame)
    for i = 1, 10 do
        select(i, _G.GuildInviteFrame:GetRegions()):Hide()
    end
    S:ReskinButton(_G.GuildInviteFrameJoinButton)
    S:ReskinButton(_G.GuildInviteFrameDeclineButton)
end

S:AddCallback("GuildInvite")
