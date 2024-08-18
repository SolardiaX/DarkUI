local E, C, L = select(2, ...):unpack()

if not C.automation.auto_quest then return end

----------------------------------------------------------------------------------------
--    Quest automation(QuickQuest by p3lim)
----------------------------------------------------------------------------------------
local module = E:Module("Automation"):Sub("AutoQuest")


local QuickQuestDB = {
    general = {
        share = false,
        skipgossip = true,
        skipgossipwhen = 2,
        paydarkmoonfaire = true,
        pausekey = 'SHIFT',
        pausekeyreverse = false,
    },
    blocklist = {
        items = {
            -- Inscription weapons
            [79343] = true, -- Inscribed Tiger Staff
            [79340] = true, -- Inscribed Crane Staff
            [79341] = true, -- Inscribed Serpent Staff

            -- Darkmoon Faire artifacts
            [71635] = true, -- Imbued Crystal
            [71636] = true, -- Monstrous Egg
            [71637] = true, -- Mysterious Grimoire
            [71638] = true, -- Ornate Weapon
            [71715] = true, -- A Treatise on Strategy
            [71951] = true, -- Banner of the Fallen
            [71952] = true, -- Captured Insignia
            [71953] = true, -- Fallen Adventurer's Journal
            [71716] = true, -- Soothsayer's Runes

            -- Tiller Gifts
            [79264] = true, -- Ruby Shard
            [79265] = true, -- Blue Feather
            [79266] = true, -- Jade Cat
            [79267] = true, -- Lovely Apple
            [79268] = true, -- Marsh Lily

            -- Garrison scouting missives
            [122424] = true, -- Scouting Missive: Broken Precipice
            [122423] = true, -- Scouting Missive: Broken Precipice
            [122418] = true, -- Scouting Missive: Darktide Roost
            [122417] = true, -- Scouting Missive: Darktide Roost
            [122400] = true, -- Scouting Missive: Everbloom Wilds
            [122404] = true, -- Scouting Missive: Everbloom Wilds
            [122420] = true, -- Scouting Missive: Gorian Proving Grounds
            [122419] = true, -- Scouting Missive: Gorian Proving Grounds
            [122402] = true, -- Scouting Missive: Iron Siegeworks
            [122406] = true, -- Scouting Missive: Iron Siegeworks
            [122413] = true, -- Scouting Missive: Lost Veil Anzu
            [122414] = true, -- Scouting Missive: Lost Veil Anzu
            [122403] = true, -- Scouting Missive: Magnarok
            [122399] = true, -- Scouting Missive: Magnarok
            [122421] = true, -- Scouting Missive: Mok'gol Watchpost
            [122422] = true, -- Scouting Missive: Mok'gol Watchpost
            [122411] = true, -- Scouting Missive: Pillars of Fate
            [122409] = true, -- Scouting Missive: Pillars of Fate
            [122412] = true, -- Scouting Missive: Shattrath Harbor
            [122410] = true, -- Scouting Missive: Shattrath Harbor
            [122408] = true, -- Scouting Missive: Skettis
            [122407] = true, -- Scouting Missive: Skettis
            [122416] = true, -- Scouting Missive: Socrethar's Rise
            [122415] = true, -- Scouting Missive: Socrethar's Rise
            [122405] = true, -- Scouting Missive: Stonefury Cliffs
            [122401] = true, -- Scouting Missive: Stonefury Cliffs

            -- Misc
            [88604] = true, -- Nat's Fishing Journal
        },
        npcs = {
            -- misc
            [103792] = true, -- Griftah (his quests are scams)
            [143925] = true, -- Dark Iron Mole Machine (Dark Iron Dwarf racial)
            [121602] = true, -- Manapoof in Dalaran
            [147666] = true, -- Manapoof in Boralus
            [147642] = true, -- Manapoof in Dazar'alor

            -- Bodyguards
            [86945] = true, -- Aeda Brightdawn (Horde)
            [86933] = true, -- Vivianne (Horde)
            [86927] = true, -- Delvar Ironfist (Alliance)
            [86934] = true, -- Defender Illona (Alliance)
            [86682] = true, -- Tormmok
            [86964] = true, -- Leorajh
            [86946] = true, -- Talonpriest Ishaal

            -- Sassy Imps
            [95139] = true,
            [95141] = true,
            [95142] = true,
            [95143] = true,
            [95144] = true,
            [95145] = true,
            [95146] = true,
            [95200] = true,
            [95201] = true,
            -- accidental resource waste
            [87391] = true, -- Fate-Twister Seress (gold, currencies)
            [88570] = true, -- Fate-Twister Tiklal (gold, currencies)
            [78495] = true, -- Shadow Hunter Ukambe (garrison missives)
            [81152] = true, -- Scout Valdez (garrison missives)
            [111243] = true, -- Archmage Lan'dalock (gold, currencies)
            [141584] = true, -- Zurvan (gold, currencies)
            [142063] = true, -- Tezran (gold, currencies)
            [193110] = true, -- Khadin (Dragon Shard of Knowledge)
        },
        quests = {
            -- 6.0 coins
            [36054] = true, -- Sealing Fate: Gold
            [37454] = true, -- Sealing Fate: Piles of Gold
            [37455] = true, -- Sealing Fate: Immense Fortune of Gold
            [36055] = true, -- Sealing Fate: Apexis Crystals
            [37452] = true, -- Sealing Fate: Heap of Apexis Crystals
            [37453] = true, -- Sealing Fate: Mountain of Apexis Crystals
            [36056] = true, -- Sealing Fate: Garrison Resources
            [37456] = true, -- Sealing Fate: Stockpiled Garrison Resources
            [37457] = true, -- Sealing Fate: Tremendous Garrison Resources
            [36057] = true, -- Sealing Fate: Honor
            -- 7.0 coins
            [43892] = true, -- Sealing Fate: Order Resources
            [43893] = true, -- Sealing Fate: Stashed Order Resources
            [43894] = true, -- Sealing Fate: Extraneous Order Resources
            [43895] = true, -- Sealing Fate: Gold
            [43896] = true, -- Sealing Fate: Piles of Gold
            [43897] = true, -- Sealing Fate: Immense Fortune of Gold
            [47851] = true, -- Sealing Fate: Marks of Honor
            [47864] = true, -- Sealing Fate: Additional Marks of Honor
            [47865] = true, -- Sealing Fate: Piles of Marks of Honor
            -- 8.0 coins
            [52834] = true, -- Seal of Wartorn Fate: Gold
            [52838] = true, -- Seal of Wartorn Fate: Piles of Gold
            [52835] = true, -- Seal of Wartorn Fate: Marks of Honor
            [52839] = true, -- Seal of Wartorn Fate: Additional Marks of Honor
            [52837] = true, -- Seal of Wartorn Fate: War Resources
            [52840] = true, -- Seal of Wartorn Fate: Stashed War Resources
            -- 7.0 valuable resources
            [48910] = true, -- Supplying Krokuun
            [48634] = true, -- Further Supplying Krokuun
            [48911] = true, -- Void Inoculation
            [48635] = true, -- More Void Inoculation
            [48799] = true, -- Fuel for a Doomed World
            -- 8.0 emissaries
            [54451] = true, -- Baubles from the Seekers
            [53982] = true, -- Supplies From The Unshackled
            [54453] = true, -- Supplies from Magni
            [54454] = true, -- Supplies from 7th Legion
            [54455] = true, -- Supplies from Honorbound
            [54456] = true, -- Supplies from Order of Embers
            [54457] = true, -- Supplies from Storm Wake
            [54458] = true, -- Supplies from Proudmoore Admiralty
            [54460] = true, -- Supplies from Talanji's Expedition
            [54461] = true, -- Supplies from Voldunai Supplies
            [54462] = true, -- Supplies from Zandalari Empire
            [55348] = true, -- Supplies from the Rustbolt Resistance
            [55976] = true, -- Supplies From the Waveblade Ankoan
            -- 9.0 valuable resources
            [64541] = true, -- The Cost of Death (Ve'nari)
            -- 10.0 valuable resources
            [70183] = true, -- Specialized Secrets: Alchemy (Khadin)
            [70184] = true, -- Specialized Secrets: Blacksmithing (Khadin)
            [70186] = true, -- Specialized Secrets: Enchanting (Khadin)
            [70187] = true, -- Specialized Secrets: Engineering (Khadin)
            [70190] = true, -- Specialized Secrets: Herbalism (Khadin)
            [70188] = true, -- Specialized Secrets: Inscription (Khadin)
            [70189] = true, -- Specialized Secrets: Jewelcrafting (Khadin)
            [70191] = true, -- Specialized Secrets: Leatherworking (Khadin)
            [70192] = true, -- Specialized Secrets: Mining (Khadin)
            [70193] = true, -- Specialized Secrets: Skinning (Khadin)
            [70194] = true, -- Specialized Secrets: Tailoring (Khadin)
            [75164] = true, -- In Need of Primal Foci
            [75165] = true, -- In Need of Concentrated Primal Foci
            [75166] = true, -- In Need of Many Primal Foci
            [75167] = true, -- In Need of Many Concentrated Primal Foci
        },
    },
}

local NPC_ID_PATTERN = '%w+%-.-%-.-%-.-%-.-%-(.-)%-'
local function GetNPCID(unit)
    local npcGUID = UnitGUID(unit or 'npc')
    if npcGUID then
        return tonumber(npcGUID:match(NPC_ID_PATTERN))
    end
end


local paused


local ignoredQuests = {}
local ITEM_CASH_REWARDS = {
    -- some items have hidden values, like pouches
    [45724] = 1e5, -- Champion's Purse, 10 gold
    [64491] = 2e6, -- Royal Reward, 200 gold

    -- items from the Sixtrigger brothers quest chain in Stormheim
    [138127] = 15, -- Mysterious Coin, 15 copper
    [138129] = 11, -- Swatch of Priceless Silk, 11 copper
    [138131] = 24, -- Magical Sprouting Beans, 24 copper
    [138123] = 15, -- Shiny Gold Nugget, 15 copper
    [138125] = 16, -- Crystal Clear Gemstone, 16 copper
    [138133] = 27, -- Elixir of Endless Wonder, 27 copper
}

local DARKMOON_GOSSIP = {
    [40007] = true, -- Darkmoon Faire Mystic Mage (Horde)
    [40457] = true, -- Darkmoon Faire Mystic Mage (Alliance)
}

local QUEST_GOSSIP = {
    -- usually only addeed if they're repeatable
    [109275] = true, -- Soridormi - begin time rift
    [120619] = true, -- Big Dig task
    [120620] = true, -- Big Dig task

    -- Darkmoon Faire
    [40563] = true, -- whack
    [28701] = true, -- cannon
    [31202] = true, -- shoot
    [39245] = true, -- tonk
    [40224] = true, -- ring toss
    [43060] = true, -- firebird
    [52651] = true, -- dance
    [41759] = true, -- pet battle 1
    [42668] = true, -- pet battle 2
    [40872] = true, -- cannon return (Teleportologist Fozlebub)
}

local IGNORE_GOSSIP = {
    -- when we don't want to automate gossip because it's counter-intuitive
    [122442] = true, -- leave the dungeon in remix
}

local function IsQuestIgnored(questID)
    if ignoredQuests[questID] then
        return true
    end
    if C_QuestLog.IsWorldQuest(questID) then
        return true
    end
    if C_QuestLog.IsQuestTrivial(questID) and not C_Minimap.IsTrackingHiddenQuests() then
        return true
    end
    local questTitle = tonumber(questID) and C_QuestLog.GetTitleForQuestID(questID) or ''
    for key in next, QuickQuestDB.blocklist.quests do
        if key == questID or questTitle:lower():find(tostring(key):lower()) then
            return true
        end
    end
    return false
end

module:RegisterEvent('GOSSIP_SHOW', function()
    -- triggered when the player interacts with an NPC that presents dialogue
    if paused then
        return
    end

    local npcID = GetNPCID()
    if QuickQuestDB.blocklist.npcs[npcID] then
        return
    end

    if C_PlayerInteractionManager.IsInteractingWithNpcOfType(Enum.PlayerInteractionType.TaxiNode) then
    -- don't annoy taxi addons
        return
    end
    local gossip = C_GossipInfo.GetOptions()
    for _, info in next, gossip do
        if DARKMOON_GOSSIP[info.gossipOptionID] and QuickQuestDB.general.paydarkmoonfaire then
            C_GossipInfo.SelectOption(info.gossipOptionID, '', true)
        elseif QUEST_GOSSIP[info.gossipOptionID] and QuickQuestDB.general.skipgossip then
            C_GossipInfo.SelectOption(info.gossipOptionID)
        elseif FlagsUtil.IsSet(info.flags, Enum.GossipOptionRecFlags.QuestLabelPrepend) and QuickQuestDB.general.skipgossip then
            C_GossipInfo.SelectOption(info.gossipOptionID)
        end
    end

    if (C_GossipInfo.GetNumActiveQuests() + C_GossipInfo.GetNumAvailableQuests()) > 0 then
        -- don't automate misc gossip if the NPC is a quest giver
        return
    end

    if #gossip ~= 1 then
        -- more than 1 option
        return
    end
    if not gossip[1].gossipOptionID then
        -- intentionally blocked gossip
        return
    end

    if IGNORE_GOSSIP[gossip[1].gossipOptionID] then
        return
    end

    local _, instanceType = GetInstanceInfo()
    if instanceType == 'raid' and QuickQuestDB.general.skipgossipwhen > 1 then
        if GetNumGroupMembers() <= 1 or QuickQuestDB.general.skipgossipwhen == 3 then
            C_GossipInfo.SelectOption(gossip[1].gossipOptionID)
        end
    elseif instanceType ~= 'raid' then
            C_GossipInfo.SelectOption(gossip[1].gossipOptionID)
    end
end)

local questQueue = {}
module:RegisterEvent('QUEST_DATA_LOAD_RESULT', function(questID)
    -- TODO: deal with unsuccessful queries
    if questQueue[questID] then
        questQueue[questID]()
        questQueue[questID] = nil
    end
end)

local function WaitForQuestData(questID, callback)
    questQueue[questID] = callback
    C_QuestLog.RequestLoadQuestByID(questID)
end

local function WaitForItemData(itemID, callback)
    Item:CreateFromItemID(itemID):ContinueOnItemLoad(callback)
end

module:RegisterEvent('GOSSIP_SHOW', function()
    -- triggered when the player interacts with an NPC that presents dialogue
    local handleGossipShow = function()
        if paused then
            return
        end
    
        if QuickQuestDB.blocklist.npcs[GetNPCID()] then
            return
        end
    
        for _, questInfo in next, C_GossipInfo.GetActiveQuests() do
            if not questInfo.questLevel or questInfo.questLevel == 0 then
                -- not cached yet
                WaitForQuestData(questInfo.questID, handleGossipShow)
            elseif IsQuestIgnored(questInfo.questID) then
                -- ignore
            elseif questInfo.isComplete then
                C_GossipInfo.SelectActiveQuest(questInfo.questID)
            end
        end
    
        for _, questInfo in next, C_GossipInfo.GetAvailableQuests() do
            if not questInfo.questLevel or questInfo.questLevel == 0 then
                -- not cached yet
                WaitForQuestData(questInfo.questID, handleGossipShow)
            elseif questInfo.isRepeatable then
                -- ignore
            elseif not IsQuestIgnored(questInfo.questID) then
                C_GossipInfo.SelectAvailableQuest(questInfo.questID)
            end
        end
    end

    handleGossipShow()
end)

module:RegisterEvent('QUEST_GREETING', function()
    -- triggered when the player interacts with an NPC that hands in/out quests
    local handleQuestList = function()
        if paused then
            return
        end

        if QuickQuestDB.blocklist.npcs[GetNPCID()] then
            return
        end

        for index = 1, GetNumActiveQuests() do
            local questID = GetActiveQuestID(index)
            local title, isComplete = GetActiveTitle(index)
            if isComplete and not IsQuestIgnored(questID) then
                SelectActiveQuest(index)
            end
        end

        for index = 1, GetNumAvailableQuests() do
            local _, _, isRepeatable, _, questID = GetAvailableQuestInfo(index)
            local questLevel = GetAvailableLevel(index)
            if not questLevel or questLevel == 0 then
                -- not cached yet, invalid isTrivial flag
                WaitForQuestData(questID, handleQuestList)
            elseif IsQuestIgnored(questID) then
                -- ignore
            elseif isRepeatable then
                -- ignore
            else
                SelectAvailableQuest(index)
            end
        end
    end

    handleQuestList()
end)

module:RegisterEvent('QUEST_DETAIL', function(_, _, questItemID)
    -- triggered when the information about an available quest is available
    local handleQuestDetail = function()
        if paused then
            return
        end

        local questID = GetQuestID()
        if not questID or questID == 0 then
            return
        end

        local questLevel = C_QuestLog.GetQuestDifficultyLevel(questID)
        if not questLevel or questLevel == 0 then
            WaitForQuestData(questID, handleQuestDetail)
            return
        end

        if QuestGetAutoAccept() then
            -- these kinds of quests are already accepted, the popup only exists to notify the user
            AcknowledgeAutoAcceptQuest()
            RemoveAutoQuestPopUp(questID)
        elseif QuestIsFromAreaTrigger() then
            -- when not triggered in combination with QuestGetAutoAccept-style quests this is just
            -- a normal quest popup, as if it was shared by an unknown player, so we'll just accept it
            AcceptQuest()
        elseif not IsQuestIgnored(questID) then
            AcceptQuest()
        end
    end

    handleQuestDetail()
end)

module:RegisterEvent('QUEST_PROGRESS', function()
    -- triggered when an active quest is selected during turn-in
    if paused then
        return
    end

    if not IsQuestCompletable() then
        return
    end

    local questID = GetQuestID()
    if ignoredQuests[questID] then
        return
    end

    -- make sure the quest doesn't contain an ignored item
    for index = 1, GetNumQuestItems() do
        local _, _, _, _, _, itemID = GetQuestItemInfo('required', index)
        if itemID then
            if QuickQuestDB.blocklist.items[itemID] then
                -- ignore this quest to prevent it from being selected again
                ignoredQuests[questID] = true
                return
            end
        end
    end

    CompleteQuest()
end)

module:RegisterEvent('QUEST_COMPLETE', function()
    -- triggered when an active quest is ready to be completed
    if paused then
        return
    end

    if GetNumQuestChoices() <= 1 then
        -- complete the quest by accepting the first item
        GetQuestReward(1)
    end
end)

module:RegisterEvent('QUEST_COMPLETE', function()
    local handleQuestComplete = function()
        -- triggered when an active quest is ready to be completed
        local numItemRewards = GetNumQuestChoices()
        if numItemRewards <= 1 then
            -- no point iterating over a single item or none at all
            return
        end

        local highestValue, highestValueIndex = 0, nil

        -- iterate through the item rewards and automatically select the one worth the most
        for index = 1, numItemRewards do
            local _, _, _, _, _, itemID = GetQuestItemInfo('choice', index)
            local isCached, _, _, _, _, _, _, _, _, _, itemValue = C_Item.GetItemInfo(itemID)
            if not isCached then
                WaitForItemData(itemID, handleQuestComplete)
            else
                itemValue = ITEM_CASH_REWARDS[itemID] or itemValue

                if itemValue > highestValue then
                    highestValue = itemValue
                    highestValueIndex = index
                end
            end
        end

        if highestValueIndex then
            -- "intrusive" action
            QuestInfoItem_OnClick(QuestInfoRewardsFrame.RewardButtons[highestValueIndex])
        end
    end

    handleQuestComplete()
end)

module:RegisterEvent('QUEST_LOG_UPDATE', function()
    -- triggered when the player's quest log has been altered
    if paused then
        return
    end

    if WorldMapFrame:IsShown() then
        -- https://github.com/p3lim-wow/QuickQuest/issues/45
        return
    end

    if QuestFrame:IsShown() then
        -- don't try to deal with quests while we already deal with one
        return
    end

    local numPopups = GetNumAutoQuestPopUps()
    if numPopups == 0 then
        return
    end

    if UnitIsDeadOrGhost('player') then
        -- can't accept quests while dead
        module:Register('PLAYER_REGEN_ENABLED', 'QUEST_LOG_UPDATE')
        return
    end
    module:UnregisterEvent('PLAYER_REGEN_ENABLED')
    module:UnregisterEvent('QUEST_LOG_UPDATE')

    for index = 1, numPopups do
        local questID, questType = GetAutoQuestPopUp(index)
        if questType == 'OFFER' then
            ShowQuestOffer(questID)
        elseif questType == 'COMPLETE' then
            ShowQuestComplete(questID)
        end
    end
end)

module:RegisterEvent('QUEST_ACCEPT_CONFIRM', function()
    -- triggered when a quest is shared in the party, but requires confirmation (like escorts)
    if paused then
        return
    end

    ConfirmAcceptQuest()
end)

module:RegisterEvent('QUEST_ACCEPTED', function(_, _, questID)
    -- triggered when a quest has been accepted by the player
    if QuickQuestDB.general.share then
        local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID)
        if questLogIndex then
            QuestLogPushQuest(questLogIndex)
        end
    end
end)

module:RegisterEvent('MODIFIER_STATE_CHANGED', function(_, _, key, state)
    -- triggered when the player clicks any modifier keys on the keyboard
    if string.sub(key, 2) == QuickQuestDB.general.pausekey then
        -- change the paused state
        if QuickQuestDB.general.pausekeyreverse then
            paused = state ~= 1
        else
            paused = state == 1
        end
    end
end)

module:RegisterEvent('PLAYER_LOGIN', function()
    -- triggered when the game has completed the login process
    if QuickQuestDB.general.pausekeyreverse then
        -- default to a paused state
        paused = true
    end
end)
