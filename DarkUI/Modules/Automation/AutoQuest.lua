local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Auto Quest (based on QuickQuest by p3lim)
------------------------------------------------------------------------

local module = E:Module("Automation"):Sub("AutoQuest")
E:Module("Automation"):SetConfigKey("automation")

local cfg = C.automation

------------------------------------------------------------------------
-- Blocklist Data
------------------------------------------------------------------------

local BLOCKLIST_NPCS = {
    [88570] = true, -- Fate-Twister Tiklal
    [87391] = true, -- Fate-Twister Seress
    [103792] = true, -- Griftah
    [143925] = true, -- Dark Iron Mole Machine
    [121602] = true, -- Manapoof (Dalaran)
    [147666] = true, -- Manapoof (Boralus)
    [147642] = true, -- Manapoof (Dazar'alor)
    [86945] = true, -- Aeda Brightdawn
    [86933] = true, -- Vivianne
    [86927] = true, -- Delvar Ironfist
    [86934] = true, -- Defender Illona
    [86682] = true, -- Tormmok
    [86964] = true, -- Leorajh
    [86946] = true, -- Talonpriest Ishaal
    [95139] = true, -- Sassy Imp
    [95141] = true,
    [95142] = true,
    [95143] = true,
    [95144] = true,
    [95145] = true,
    [95146] = true,
    [95200] = true,
    [95201] = true,
    [78495] = true, -- Shadow Hunter Ukambe
    [81152] = true, -- Scout Valdez
    [111243] = true, -- Archmage Lan'dalock
    [141584] = true, -- Zurvan
    [142063] = true, -- Tezran
    [193110] = true, -- Khadin
}

local BLOCKLIST_ITEMS = {
    [79343] = true, -- Inscribed Tiger Staff
    [79340] = true, -- Inscribed Crane Staff
    [79341] = true, -- Inscribed Serpent Staff
    [71635] = true, -- Imbued Crystal
    [71636] = true, -- Monstrous Egg
    [71637] = true, -- Mysterious Grimoire
    [71638] = true, -- Ornate Weapon
    [71715] = true, -- A Treatise on Strategy
    [71951] = true, -- Banner of the Fallen
    [71952] = true, -- Captured Insignia
    [71953] = true, -- Fallen Adventurer's Journal
    [71716] = true, -- Soothsayer's Runes
    [79264] = true, -- Ruby Shard
    [79265] = true, -- Blue Feather
    [79266] = true, -- Jade Cat
    [79267] = true, -- Lovely Apple
    [79268] = true, -- Marsh Lily
    [88604] = true, -- Nat's Fishing Journal
}

local BLOCKLIST_QUESTS = {
    -- 6.0 coins
    [36054] = true, [37454] = true, [37455] = true,
    [36055] = true, [37452] = true, [37453] = true,
    [36056] = true, [37456] = true, [37457] = true,
    [36057] = true,
    -- 7.0 coins
    [43892] = true, [43893] = true, [43894] = true,
    [43895] = true, [43896] = true, [43897] = true,
    [47851] = true, [47864] = true, [47865] = true,
    -- 8.0 coins
    [52834] = true, [52838] = true, [52835] = true,
    [52839] = true, [52837] = true, [52840] = true,
    -- 7.0 valuable resources
    [48910] = true, [48634] = true, [48911] = true,
    [48635] = true, [48799] = true,
    -- 8.0 emissaries
    [54451] = true, [53982] = true, [54453] = true,
    [54454] = true, [54455] = true, [54456] = true,
    [54457] = true, [54458] = true, [54460] = true,
    [54461] = true, [54462] = true, [55348] = true,
    [55976] = true,
    -- 9.0
    [64541] = true,
    -- 10.0
    [70183] = true, [70184] = true, [70186] = true,
    [70187] = true, [70190] = true, [70188] = true,
    [70189] = true, [70191] = true, [70192] = true,
    [70193] = true, [70194] = true,
    [75164] = true, [75165] = true, [75166] = true, [75167] = true,
    -- 12.0 bonus rolls
    [95279] = true, [95304] = true, [95290] = true,
}

local DARKMOON_GOSSIP = {
    [40007] = true, -- Horde
    [40457] = true, -- Alliance
}

local QUEST_GOSSIP = {
    [109275] = true, -- Soridormi
    [120619] = true, -- Big Dig
    [120620] = true, -- Big Dig
    [120555] = true, -- Awakening The Machine
    [120733] = true, -- Theater Troupe
    [40563] = true, -- whack
    [28701] = true, -- cannon
    [31202] = true, -- shoot
    [39245] = true, -- tonk
    [40224] = true, -- ring toss
    [43060] = true, -- firebird
    [52651] = true, -- dance
    [41759] = true, -- pet battle 1
    [42668] = true, -- pet battle 2
    [40872] = true, -- cannon return
}

local IGNORE_GOSSIP = {
    [122442] = true, -- leave dungeon in remix
    [44733] = true,
    [125350] = true, -- siren isle
    [125351] = true,
    [131324] = true, -- winter veil hillsbrad
    [131325] = true,
}

local ITEM_CASH_REWARDS = {
    [45724] = 1e5, -- Champion's Purse
    [64491] = 2e6, -- Royal Reward
    [138127] = 15, [138129] = 11, [138131] = 24,
    [138123] = 15, [138125] = 16, [138133] = 27,
}

------------------------------------------------------------------------
-- Utilities
------------------------------------------------------------------------

local NPC_ID_PATTERN = "%w+%-.-%-.-%-.-%-.-%-(.-)%-"

local function getNPCID(unit)
    local guid = UnitGUID(unit or "npc")
    if not guid then return nil end
    if issecretvalue and issecretvalue(guid) then return nil end
    local id = tonumber(guid:match(NPC_ID_PATTERN))
    if id and issecretvalue and issecretvalue(id) then return nil end
    return id
end

local paused
local ignoredQuests = {}
local popups = {}
local questQueue = {}

local function isQuestIgnored(questID, _, override)
    if ignoredQuests[questID] then return true end
    if C_QuestLog.IsWorldQuest(questID) then return true end

    if override then return false end

    if C_QuestLog.IsQuestTrivial(questID) and not C_Minimap.IsTrackingHiddenQuests() then
        return true
    end

    if C_QuestLog.IsQuestFlaggedCompletedOnAccount(questID) and not C_Minimap.IsTrackingAccountCompletedQuests() then
        return true
    end

    if BLOCKLIST_QUESTS[questID] then return true end

    return false
end

local function waitForQuestData(questID, callback)
    questQueue[questID] = callback
    C_QuestLog.RequestLoadQuestByID(questID)
end

local function waitForItemData(itemID, callback)
    Item:CreateFromItemID(itemID):ContinueOnItemLoad(callback)
end

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg or not cfg.auto_quest then return end

    -- QUEST_DATA_LOAD_RESULT
    self:RegisterEvent("QUEST_DATA_LOAD_RESULT", function(_, questID)
        if questQueue[questID] then
            questQueue[questID]()
            questQueue[questID] = nil
        end
    end)

    -- GOSSIP_SHOW: auto-select single gossip options
    self:RegisterEvent("GOSSIP_SHOW", function()
        if paused then return end
        if BLOCKLIST_NPCS[getNPCID()] then return end

        if C_PlayerInteractionManager.IsInteractingWithNpcOfType(Enum.PlayerInteractionType.TaxiNode) then
            return
        end

        local gossipQuests = {}
        local gossipSkips = {}

        local gossip = C_GossipInfo.GetOptions()
        for _, info in next, gossip do
            if DARKMOON_GOSSIP[info.gossipOptionID] then
                C_GossipInfo.SelectOption(info.gossipOptionID, "", true)
                return
            elseif QUEST_GOSSIP[info.gossipOptionID] then
                tinsert(gossipQuests, info.gossipOptionID)
            elseif FlagsUtil.IsSet(info.flags, Enum.GossipOptionRecFlags.QuestLabelPrepend) then
                tinsert(gossipQuests, info.gossipOptionID)
            elseif info.name:sub(1, 11) == "|cFFFF0000<" then
                tinsert(gossipSkips, info.gossipOptionID)
            end
        end

        if #gossipSkips == 1 then
            C_GossipInfo.SelectOption(gossipSkips[1])
            return
        elseif #gossipQuests == 1 then
            C_GossipInfo.SelectOption(gossipQuests[1])
            return
        end

        if (C_GossipInfo.GetNumActiveQuests() + C_GossipInfo.GetNumAvailableQuests()) > 0 then
            return
        end

        if #gossip ~= 1 then return end
        if not gossip[1].gossipOptionID then return end
        if IGNORE_GOSSIP[gossip[1].gossipOptionID] then return end

        local _, instanceType = GetInstanceInfo()
        if instanceType == "raid" then
            if GetNumGroupMembers() <= 1 then
                C_GossipInfo.SelectOption(gossip[1].gossipOptionID)
            end
        else
            C_GossipInfo.SelectOption(gossip[1].gossipOptionID)
        end
    end)

    -- GOSSIP_SHOW: handle quest accept/complete via gossip
    local function handleGossipQuests()
        if paused then return end
        if BLOCKLIST_NPCS[getNPCID()] then return end

        for _, questInfo in next, C_GossipInfo.GetActiveQuests() do
            if not questInfo.questLevel or questInfo.questLevel == 0 then
                waitForQuestData(questInfo.questID, handleGossipQuests)
            elseif isQuestIgnored(questInfo.questID) then
                -- skip
            elseif questInfo.isComplete then
                C_GossipInfo.SelectActiveQuest(questInfo.questID)
            end
        end

        for _, questInfo in next, C_GossipInfo.GetAvailableQuests() do
            if questInfo.questID == 82449 then
                C_GossipInfo.SelectAvailableQuest(questInfo.questID)
            elseif not questInfo.questLevel or questInfo.questLevel == 0 then
                waitForQuestData(questInfo.questID, handleGossipQuests)
            elseif questInfo.isRepeatable then
                -- skip
            elseif not isQuestIgnored(questInfo.questID) then
                C_GossipInfo.SelectAvailableQuest(questInfo.questID)
            end
        end
    end
    self:RegisterEvent("GOSSIP_SHOW", handleGossipQuests)

    -- QUEST_GREETING: NPC quest list (no gossip)
    local function handleQuestList()
        if paused then return end
        if BLOCKLIST_NPCS[getNPCID()] then return end

        for index = 1, GetNumActiveQuests() do
            local questID = GetActiveQuestID(index)
            local _, isComplete = GetActiveTitle(index)
            if isComplete and not isQuestIgnored(questID) then
                SelectActiveQuest(index)
            end
        end

        for index = 1, GetNumAvailableQuests() do
            local _, _, isRepeatable, _, questID = GetAvailableQuestInfo(index)
            local questLevel = GetAvailableLevel(index)
            if not questLevel or questLevel == 0 then
                waitForQuestData(questID, handleQuestList)
            elseif isQuestIgnored(questID) then
                -- skip
            elseif isRepeatable then
                -- skip
            else
                SelectAvailableQuest(index)
            end
        end
    end
    self:RegisterEvent("QUEST_GREETING", handleQuestList)

    -- QUEST_DETAIL: auto-accept
    local function handleQuestDetail()
        if paused then return end

        local questID = GetQuestID()
        if not questID or questID == 0 then return end

        local questLevel = C_QuestLog.GetQuestDifficultyLevel(questID)
        if not questLevel or questLevel == 0 then
            waitForQuestData(questID, handleQuestDetail)
            return
        end

        if QuestGetAutoAccept() then
            AcknowledgeAutoAcceptQuest()
            RemoveAutoQuestPopUp(questID)
        elseif QuestIsFromAreaTrigger() then
            AcceptQuest()
        elseif not isQuestIgnored(questID, nil, popups[questID]) then
            AcceptQuest()
        end

        if popups[questID] then
            RemoveAutoQuestPopUp(questID)
        end
    end
    self:RegisterEvent("QUEST_DETAIL", handleQuestDetail)

    -- QUEST_PROGRESS: auto-complete prerequisites
    self:RegisterEvent("QUEST_PROGRESS", function()
        if paused then return end
        if not IsQuestCompletable() then return end

        local questID = GetQuestID()
        if ignoredQuests[questID] then return end

        for index = 1, GetNumQuestItems() do
            local _, _, _, _, _, itemID = GetQuestItemInfo("required", index)
            if itemID and BLOCKLIST_ITEMS[itemID] then
                ignoredQuests[questID] = true
                return
            end
        end

        CompleteQuest()
    end)

    -- QUEST_COMPLETE: auto-select reward
    self:RegisterEvent("QUEST_COMPLETE", function()
        if paused then return end

        local numChoices = GetNumQuestChoices()
        if numChoices <= 1 and not isQuestIgnored(GetQuestID()) then
            GetQuestReward(1)
            return
        end

        local highestValue, highestValueIndex = 0, nil
        local function selectBest()
            for index = 1, numChoices do
                local _, _, _, _, _, itemID = GetQuestItemInfo("choice", index)
                local isCached, _, _, _, _, _, _, _, _, _, itemValue = C_Item.GetItemInfo(itemID)
                if not isCached then
                    waitForItemData(itemID, selectBest)
                    return
                end
                itemValue = ITEM_CASH_REWARDS[itemID] or itemValue
                if itemValue > highestValue then
                    highestValue = itemValue
                    highestValueIndex = index
                end
            end

            if highestValueIndex then
                local rewardButtons = QuestInfoRewardsFrame and QuestInfoRewardsFrame.RewardButtons
                if rewardButtons and rewardButtons[highestValueIndex] then
                    QuestInfoItem_OnClick(rewardButtons[highestValueIndex])
                end
            end
        end
        selectBest()
    end)

    -- QUEST_LOG_UPDATE: handle auto-quest popups
    local function handleQuestPopup()
        if paused then return end
        if WorldMapFrame:IsShown() then return end
        if QuestFrame:IsShown() then return end

        local numPopups = GetNumAutoQuestPopUps()
        if numPopups == 0 then return end
        if UnitIsDeadOrGhost("player") then return end

        for index = 1, numPopups do
            local questID, questType = GetAutoQuestPopUp(index)
            if questID then
                popups[questID] = true
                if questType == "OFFER" then
                    ShowQuestOffer(questID)
                elseif questType == "COMPLETE" then
                    ShowQuestComplete(questID)
                end
            else
                waitForQuestData(questID, handleQuestPopup)
            end
        end
    end
    self:RegisterEvent("QUEST_LOG_UPDATE", handleQuestPopup)

    -- QUEST_ACCEPT_CONFIRM: shared quests requiring confirmation
    self:RegisterEvent("QUEST_ACCEPT_CONFIRM", function()
        if paused then return end
        ConfirmAcceptQuest()
    end)

    -- MODIFIER_STATE_CHANGED: pause key (SHIFT)
    self:RegisterEvent("MODIFIER_STATE_CHANGED", function(_, _, key, state)
        if string.sub(key, 2) == "SHIFT" then
            paused = state == 1
        end
    end)
end
