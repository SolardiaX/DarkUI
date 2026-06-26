local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Guild invite frame
-- Ported from ElvUI Mainline/Skins/Guild.lua
------------------------------------------------------------------------

local _G = _G

function S:GuildInviteFrame()
    if not (C.skins.enable and C.skins.guild) then return end

    local GuildInviteFrame = _G.GuildInviteFrame
    GuildInviteFrame:StripTextures()
    GuildInviteFrame:SetTemplate("Transparent")
    GuildInviteFrame.Points:ClearAllPoints()
    GuildInviteFrame.Points:Point("TOP", GuildInviteFrame, "CENTER", 15, -25)

    S:HandleButton(_G.GuildInviteFrameJoinButton)
    S:HandleButton(_G.GuildInviteFrameDeclineButton)

    GuildInviteFrame:Height(225)
    GuildInviteFrame:HookScript("OnEvent", function() GuildInviteFrame:Height(225) end)

    _G.GuildInviteFrameWarningText:Kill()
end

S:AddCallback("GuildInviteFrame")
