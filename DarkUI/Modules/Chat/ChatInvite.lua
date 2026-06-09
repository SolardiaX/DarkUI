local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Alt Click Invite
------------------------------------------------------------------------

local module = E:Module("Chat"):Sub("ChatInvite")

function module:OnInit()
    if not C.chat.alt_invite then
        return
    end

    hooksecurefunc("SetItemRef", function(link)
        if IsAltKeyDown() then
            local chatFrameEditBox = ChatEdit_ChooseBoxForSend()
            local player = link:match("^player:([^:]+)")
            local bplayer = link:match("^BNplayer:([^:]+)")
            if player then
                C_PartyInfo.InviteUnit(player)
            elseif bplayer then
                local _, value = strmatch(link, "(%a+):(.+)")
                local _, bnID = strmatch(value, "([^:]*):([^:]*):")
                if not bnID then
                    return
                end
                local accountInfo = C_BattleNet.GetAccountInfoByID(bnID)
                if accountInfo.gameAccountInfo.clientProgram == BNET_CLIENT_WOW and CanCooperateWithGameAccount(accountInfo) then
                    BNInviteFriend(accountInfo.gameAccountInfo.gameAccountID)
                end
            end
            ChatEdit_OnEscapePressed(chatFrameEditBox)
        end
    end)
end
