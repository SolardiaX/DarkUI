local E, C, L = select(2, ...):unpack()

if not C.chat.enable and not C.chat.alt_invite then return end

----------------------------------------------------------------------------------------
--    Alt Click to Invite player
----------------------------------------------------------------------------------------

local IsAltKeyDown = IsAltKeyDown
local InviteToGroup = InviteToGroup
local ChatEdit_ChooseBoxForSend, ChatEdit_OnEscapePressed = ChatEdit_ChooseBoxForSend, ChatEdit_OnEscapePressed
local C_PartyInfo_InviteUnit = C_PartyInfo.InviteUnit
local C_BattleNet_GetAccountInfoByID = C_BattleNet.GetAccountInfoByID
local CanCooperateWithGameAccount = CanCooperateWithGameAccount
local BNInviteFriend = BNInviteFriend
local hooksecurefunc = hooksecurefunc
local strmatch = strmatch
local BNET_CLIENT_WOW = BNET_CLIENT_WOW

local cfg = C.chat

hooksecurefunc("SetItemRef", function(link)
    -- Secure hook to avoid taint
    if IsAltKeyDown() then
        local ChatFrameEditBox = ChatEdit_ChooseBoxForSend()
        local player = link:match("^player:([^:]+)")
        local bplayer = link:match("^BNplayer:([^:]+)")
        if player then
            C_PartyInfo_InviteUnit(player)
        elseif bplayer then
            local _, value = strmatch(link, "(%a+):(.+)")
            local _, bnID = strmatch(value, "([^:]*):([^:]*):")
            if not bnID then return end
            local accountInfo = C_BattleNet_GetAccountInfoByID(bnID)
            if accountInfo.gameAccountInfo.clientProgram == BNET_CLIENT_WOW and CanCooperateWithGameAccount(accountInfo) then
                BNInviteFriend(accountInfo.gameAccountInfo.gameAccountID)
            end
        end
        ChatEdit_OnEscapePressed(ChatFrameEditBox) -- Secure hook opens whisper, so closing it.
    end
end)
