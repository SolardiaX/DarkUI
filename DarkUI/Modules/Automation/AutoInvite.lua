local E, C, L = select(2, ...):unpack()

if not C.automation.accept_invite then return end

----------------------------------------------------------------------------------------
--	Accept invites from guild members or friend list(by ALZA)
----------------------------------------------------------------------------------------
local module = E:Module("Automation"):Sub("AutoInvite")

local _G = _G
local C_BattleNet_GetAccountInfoByGUID = C_BattleNet.GetAccountInfoByGUID
local C_BattleNet_GetAccountInfoByID = C_BattleNet.GetAccountInfoByID
local C_FriendList_IsFriend = C_FriendList.IsFriend
local C_PartyInfo_InviteUnit, BNInviteFriend = C_PartyInfo.InviteUnit, BNInviteFriend
local IsGuildMember = IsGuildMember
local QueueStatusMinimapButton = QueueStatusMinimapButton
local GetNumGroupMembers = GetNumGroupMembers
local UnitExists, UnitIsGroupLeader, UnitIsGroupAssistant = UnitExists, UnitIsGroupLeader, UnitIsGroupAssistant
local RaidNotice_AddMessage = RaidNotice_AddMessage
local RaidWarningFrame = RaidWarningFrame
local AcceptGroup = AcceptGroup
local StaticPopup_Hide = StaticPopup_Hide

local format, print, select = format, print, select
local STATICPOPUP_NUMDIALOGS = STATICPOPUP_NUMDIALOGS

local function CheckFriend(inviterGUID)
    if C_BattleNet_GetAccountInfoByGUID(inviterGUID) or C_FriendList_IsFriend(inviterGUID) or IsGuildMember(inviterGUID) then
        return true
    end
end

module:RegisterEvent("PARTY_INVITE_REQUEST", function(_, _, name, _, _, _, _, _, inviterGUID)
    if QueueStatusMinimapButton:IsShown() or GetNumGroupMembers() > 0 then return end
    if CheckFriend(inviterGUID) then
        RaidNotice_AddMessage(RaidWarningFrame, L.AUTO_INVITE_INFO .. name, { r = 0.41, g = 0.8, b = 0.94 }, 3)
        print(format("|cffffff00" .. L.AUTO_INVITE_INFO .. name .. ".|r"))
        AcceptGroup()
        for i = 1, STATICPOPUP_NUMDIALOGS do
            local frame = _G["StaticPopup" .. i]
            if frame:IsVisible() and frame.which == "PARTY_INVITE" then
                frame.inviteAccepted = 1
                StaticPopup_Hide("PARTY_INVITE")
                return
            elseif frame:IsVisible() and frame.which == "PARTY_INVITE_XREALM" then
                frame.inviteAccepted = 1
                StaticPopup_Hide("PARTY_INVITE_XREALM")
                return
            end
        end
    end
end)

module:RegisterEvent("CHAT_MSG_WHISPER CHAT_MSG_BN_WHISPER", function(_, event, arg1, arg2, ...)
    if ((not UnitExists("party1") or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and arg1:lower():match(C.automation.invite_keyword)) and not QueueStatusMinimapButton:IsShown() then
        if event == "CHAT_MSG_WHISPER" then
            C_PartyInfo_InviteUnit(arg2)
        elseif event == "CHAT_MSG_BN_WHISPER" then
            local bnetIDAccount = select(11, ...)
            local accountInfo = C_BattleNet_GetAccountInfoByID(bnetIDAccount)
            BNInviteFriend(accountInfo.gameAccountInfo.gameAccountID)
        end
    end
end)
