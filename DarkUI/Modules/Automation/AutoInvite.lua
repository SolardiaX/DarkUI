local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Auto Invite
------------------------------------------------------------------------

local module = E:Module("Automation"):Sub("AutoInvite")

local cfg = C.automation

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg.accept_invite then return end

    local function checkFriend(inviterGUID)
        if not inviterGUID then return false end
        if C_BattleNet.GetAccountInfoByGUID(inviterGUID) then return true end
        if C_FriendList.IsFriend(inviterGUID) then return true end
        if IsGuildMember(inviterGUID) then return true end
        return false
    end

    self:RegisterEvent("PARTY_INVITE_REQUEST", function(_, _, name, _, _, _, _, _, inviterGUID)
        if QueueStatusButton:IsShown() or GetNumGroupMembers() > 0 then return end
        if checkFriend(inviterGUID) then
            AcceptGroup()
            for i = 1, STATICPOPUP_NUMDIALOGS do
                local frame = _G["StaticPopup" .. i]
                if frame:IsVisible() and (frame.which == "PARTY_INVITE" or frame.which == "PARTY_INVITE_XREALM") then
                    frame.inviteAccepted = 1
                    StaticPopup_Hide(frame.which)
                    return
                end
            end
        end
    end)

    self:RegisterEvent("CHAT_MSG_WHISPER", function(_, _, arg1, arg2)
        if not cfg.invite_keyword then return end
        if (not UnitExists("party1") or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player"))
            and arg1:lower():match(cfg.invite_keyword)
            and not QueueStatusButton:IsShown() then
            C_PartyInfo.InviteUnit(arg2)
        end
    end)

    self:RegisterEvent("CHAT_MSG_BN_WHISPER", function(_, _, arg1, _, _, _, _, _, _, _, _, _, _, bnetIDAccount)
        if not cfg.invite_keyword then return end
        if (not UnitExists("party1") or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player"))
            and arg1:lower():match(cfg.invite_keyword)
            and not QueueStatusButton:IsShown() then
            local accountInfo = C_BattleNet.GetAccountInfoByID(bnetIDAccount)
            if accountInfo and accountInfo.gameAccountInfo then
                BNInviteFriend(accountInfo.gameAccountInfo.gameAccountID)
            end
        end
    end)
end
