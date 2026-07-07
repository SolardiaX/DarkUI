local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Move Blizzard Frames
------------------------------------------------------------------------

local module = E:Module("Blizzard"):Sub("MoveBlizzFrames")

local cfg = C.blizzard

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg.custom_position then return end

    local frames = {
        "CharacterFrame",
        "ChannelFrame",
        "TaxiFrame",
        "QuestFrame",
        "PVEFrame",
        "AddonList",
        "QuestLogPopupDetailFrame",
        "MerchantFrame",
        "TradeFrame",
        "MailFrame",
        "LootFrame",
        "FriendsFrame",
        "CinematicFrame",
        "TabardFrame",
        "PetStableFrame",
        "BankFrame",
        "PetitionFrame",
        "HelpFrame",
        "GossipFrame",
        "DressUpFrame",
        "GuildRegistrarFrame",
        "ChatConfigFrame",
        "RaidBrowserFrame",
        -- WorldMapFrame must never be made movable: it is a protected frame, and an
        -- insecure SetScript/StartMoving taints the map's secure pin refresh
        -- (SetPassThroughButtons blocked in combat). See Modules/Map/WorldMap.lua.
        "GameMenuFrame",
        "GuildInviteFrame",
        "ItemTextFrame",
        "OpenMailFrame",
        "StackSplitFrame",
        "StaticPopup1",
        "StaticPopup2",
        "SettingsPanel",
        "ProfessionsFrame",
    }

    for _, name in pairs(frames) do
        local frame = _G[name]
        if frame then
            frame:EnableMouse(true)
            frame:SetMovable(true)
            frame:SetClampedToScreen(true)
            frame:RegisterForDrag("LeftButton")
            frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
            frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
        end
    end

    local addonFrames = {
        ["Blizzard_AchievementUI"] = { "AchievementFrame" },
        ["Blizzard_ArchaeologyUI"] = { "ArchaeologyFrame" },
        ["Blizzard_AuctionHouseUI"] = { "AuctionHouseFrame" },
        ["Blizzard_BarberShopUI"] = { "BarberShopFrame" },
        ["Blizzard_BindingUI"] = { "KeyBindingFrame" },
        ["Blizzard_BlackMarketUI"] = { "BlackMarketFrame" },
        ["Blizzard_Calendar"] = { "CalendarCreateEventFrame", "CalendarFrame", "CalendarViewEventFrame", "CalendarViewHolidayFrame" },
        ["Blizzard_ChallengesUI"] = { "ChallengesLeaderboardFrame" },
        ["Blizzard_Collections"] = { "CollectionsJournal", "WardrobeFrame" },
        ["Blizzard_Communities"] = { "CommunitiesFrame" },
        ["Blizzard_EncounterJournal"] = { "EncounterJournal" },
        ["Blizzard_GarrisonUI"] = { "GarrisonLandingPage", "GarrisonMissionFrame" },
        ["Blizzard_GuildBankUI"] = { "GuildBankFrame" },
        ["Blizzard_GuildControlUI"] = { "GuildControlUI" },
        ["Blizzard_InspectUI"] = { "InspectFrame" },
        ["Blizzard_ItemSocketingUI"] = { "ItemSocketingFrame" },
        ["Blizzard_ItemUpgradeUI"] = { "ItemUpgradeFrame" },
        ["Blizzard_MacroUI"] = { "MacroFrame" },
        ["Blizzard_OrderHallUI"] = { "OrderHallMissionFrame" },
        ["Blizzard_PlayerSpells"] = { "PlayerSpellsFrame" },
        ["Blizzard_Professions"] = { "ProfessionsFrame" },
        ["Blizzard_ProfessionsBook"] = { "ProfessionsBookFrame" },
        ["Blizzard_QuestChoice"] = { "QuestChoiceFrame" },
        ["Blizzard_TalkingHeadUI"] = { "TalkingHeadFrame" },
        ["Blizzard_TrainerUI"] = { "ClassTrainerFrame" },
    }

    local function makeMovable(name)
        local frame = _G[name]
        if frame and not InCombatLockdown() then
            frame:EnableMouse(true)
            frame:SetMovable(true)
            frame:SetClampedToScreen(true)
            frame:RegisterForDrag("LeftButton")
            frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
            frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
        end
    end

    self:RegisterEvent("ADDON_LOADED", function(_, _, addon)
        if addon == "Blizzard_EncounterJournal" then
            local ej = _G.EncounterJournal
            if ej and ej.suggestFrame then
                local function fixRewardTooltip(rewardFrame)
                    if rewardFrame.data then _G.EncounterJournalTooltip:ClearAllPoints() end
                    AdventureJournal_Reward_OnEnter(rewardFrame)
                end
                ej.suggestFrame.Suggestion1.reward:HookScript("OnEnter", fixRewardTooltip)
                ej.suggestFrame.Suggestion2.reward:HookScript("OnEnter", fixRewardTooltip)
                ej.suggestFrame.Suggestion3.reward:HookScript("OnEnter", fixRewardTooltip)
            end
        elseif addon == "Blizzard_Communities" then
            local dialog = _G.CommunitiesFrame and _G.CommunitiesFrame.NotificationSettingsDialog
            if dialog then
                dialog:ClearAllPoints()
                dialog:SetAllPoints()
            end
        end

        if addonFrames[addon] then
            for _, name in pairs(addonFrames[addon]) do
                makeMovable(name)
            end
        end
    end)
end
