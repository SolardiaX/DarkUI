local E, C, L = select(2, ...):unpack()

if not C.map.worldmap.enable and not C.map.worldmap.rewardIcon then return end

----------------------------------------------------------------------------------------
-- Reward Quest Item Icon (Based on BetterWorldQuests)
----------------------------------------------------------------------------------------
local module = E:Module("Map"):Sub("WorldMapRewardIcon")

local HBD = LibStub('HereBeDragons-2.0')

local PARENT_MAPS = {
    -- list of all continents and their sub-zones that have world quests
    [2274] = { -- Khaz Algar
        [2248] = true, -- Isle of Dorn
        [2215] = true, -- Hallowfall
        [2214] = true, -- The Ringing Deeps
        [2255] = true, -- Azj-Kahet
        [2256] = true, -- Azj-Kahet - Lower
        [2213] = true, -- City of Threads
        [2216] = true, -- City of Threads - Lower
    },
    [1978] = { -- Dragon Isles
        [2022] = true, -- The Walking Shores
        [2023] = true, -- Ohn'ahran Plains
        [2024] = true, -- The Azure Span
        [2025] = true, -- Thaldraszus
        [2151] = true, -- The Forbidden Reach
    },
    [1550] = { -- Shadowlands
        [1525] = true, -- Revendreth
        [1533] = true, -- Bastion
        [1536] = true, -- Maldraxxus
        [1565] = true, -- Ardenwald
        [1543] = true, -- The Maw
    },
    [619] = { -- Broken Isles
        [630] = true, -- Azsuna
        [641] = true, -- Val'sharah
        [650] = true, -- Highmountain
        [634] = true, -- Stormheim
        [680] = true, -- Suramar
        [627] = true, -- Dalaran
        [790] = true, -- Eye of Azshara (world version)
        [646] = true, -- Broken Shore
    },
    [424] = { -- Pandaria
        [1530] = true, -- Vale of Eternal Blossoms (BfA)
    },
    [875] = { -- Zandalar
        [862] = true, -- Zuldazar
        [864] = true, -- Vol'Dun
        [863] = true, -- Nazmir
    },
    [876] = { -- Kul Tiras
        [895] = true, -- Tiragarde Sound
        [896] = true, -- Drustvar
        [942] = true, -- Stormsong Valley
    },
    [13] = { -- Eastern Kingdoms
        [14] = true, -- Arathi Highlands (Warfronts)
    },
    [12] = { -- Kalimdor
        [62] = true, -- Darkshore (Warfronts)
        [1527] = true, -- Uldum (BfA)
    },
    [947] = { -- Azeroth
        [13] = true, -- Eastern Kingdoms
        [12] = true, -- Kalimdor
        [619] = true, -- Broken Isles
        [875] = true, -- Zandalar
        [876] = true, -- Kul Tiras
        [424] = true, -- Pandaria
        [1978] = true, -- Dragon Isles
        [2274] = true, -- Khaz Algar
    },
}

local FACTION_ASSAULT_ATLAS = UnitFactionGroup('player') == 'Horde' and 'worldquest-icon-horde' or 'worldquest-icon-alliance'
local disabled = false
local mapScale, parentScale, zoomFactor = 1.25, 1, 0.5

local function IsParentMap(mapID)
    return not not PARENT_MAPS[mapID]
end

local function IsChildMap(parentMapID, mapID)
	local mapInfo = C_Map.GetMapInfo(mapID)
	return parentMapID and mapID and mapInfo and mapInfo.parentMapID and mapInfo.parentMapID == parentMapID
end

local function TranslatePosition(position, fromMapID, toMapID)
	local continentID, worldPos = C_Map.GetWorldPosFromMapPos(fromMapID, position)
	local _, newPos = C_Map.GetMapPosFromWorldPos(continentID, worldPos, toMapID)
	return newPos
end

-- create a new data provider that will display the world quests on zones from the list above,
-- based on WorldMap_WorldQuestDataProviderMixin
local DataProvider = CreateFromMixins(WorldMap_WorldQuestDataProviderMixin)
DataProvider:SetMatchWorldMapFilters(true)
DataProvider:SetUsesSpellEffect(true)
DataProvider:SetCheckBounties(true)

function DataProvider:GetPinTemplate()
    -- we use our own copy of the WorldMap_WorldQuestPinTemplate template to avoid interference
    return 'BetterWorldQuestPinTemplate'
end

function DataProvider:ShouldOverrideShowQuest()
    -- just nop so we don't hit the default
end

function DataProvider:ShouldShowQuest(questInfo)
	local mapID = self:GetMap():GetMapID()
	if mapID == 947 then
		-- TODO: change option to only show when there's few?
		return showAzeroth
	end

	if WorldQuestDataProviderMixin.ShouldShowQuest(self, questInfo) then -- super
		return true
	end

	local mapInfo = C_Map.GetMapInfo(mapID)
	if mapInfo.mapType == Enum.UIMapType.Continent then
		return true
	end

	return IsChildMap(mapID, questInfo.mapID)
end

BetterWorldQuestPinMixin = CreateFromMixins(WorldMap_WorldQuestPinMixin)
function BetterWorldQuestPinMixin:OnLoad()
    WorldQuestPinMixin.OnLoad(self)

    -- recreate WorldQuestPinTemplate regions
    local TrackedCheck = self:CreateTexture(nil, 'OVERLAY', nil, 7)
    TrackedCheck:SetPoint('BOTTOM', self, 'BOTTOMRIGHT', 0, -2)
    TrackedCheck:SetAtlas('worldquest-emissary-tracker-checkmark', true)
    TrackedCheck:Hide()
    self.TrackedCheck = TrackedCheck

    local TimeLowFrame = CreateFrame('Frame', nil, self)
    TimeLowFrame:SetPoint('CENTER', 9, -9)
    TimeLowFrame:SetSize(22, 22)
    TimeLowFrame:Hide()
    self.TimeLowFrame = TimeLowFrame

    local TimeLowIcon = TimeLowFrame:CreateTexture(nil, 'OVERLAY')
    TimeLowIcon:SetAllPoints()
    TimeLowIcon:SetAtlas('worldquest-icon-clock')
    TimeLowFrame.Icon = TimeLowIcon

    -- add our own widgets
    local Reward = self:CreateTexture(nil, 'OVERLAY')
    Reward:SetPoint('CENTER', self.PushedTexture)
    Reward:SetSize(self:GetWidth() - 4, self:GetHeight() - 4)
    Reward:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    self.Reward = Reward

    local RewardMask = self:CreateMaskTexture()
    RewardMask:SetTexture([[Interface\CharacterFrame\TempPortraitAlphaMask]])
    RewardMask:SetAllPoints(Reward)
    Reward:AddMaskTexture(RewardMask)

    local Indicator = self:CreateTexture(nil, 'OVERLAY', nil, 2)
    Indicator:SetPoint('CENTER', self, 'TOPLEFT', 4, -4)
    self.Indicator = Indicator

    local Reputation = self:CreateTexture(nil, 'OVERLAY', nil, 2)
    Reputation:SetPoint('CENTER', self, 'BOTTOM', 0, 2)
    Reputation:SetSize(10, 10)
    Reputation:SetAtlas('socialqueuing-icon-eye')
    Reputation:Hide()
    self.Reputation = Reputation

    local Bounty = self:CreateTexture(nil, 'OVERLAY', nil, 3)
    Bounty:SetAtlas('QuestNormal', true)
    Bounty:SetScale(0.65)
    Bounty:SetPoint('LEFT', self, 'RIGHT', -(Bounty:GetWidth() / 2), 0)
    self.Bounty = Bounty
end

function BetterWorldQuestPinMixin:RefreshVisuals()
    WorldMap_WorldQuestPinMixin.RefreshVisuals(self)

    -- hide optional elements by default
    self.Bounty:Hide()
    self.Reward:Hide()
    self.Reputation:Hide()
    self.Indicator:Hide()
    self.Display.Icon:Hide()

    -- update scale
    local mapID = self:GetMap():GetMapID()
	if mapID == 947 then
		self:SetScalingLimits(1, parentScale / 2, (parentScale / 2) + zoomFactor)
	elseif IsParentMap(mapID) then
		self:SetScalingLimits(1, parentScale, parentScale + zoomFactor)
	else
		self:SetScalingLimits(1, mapScale, mapScale + zoomFactor)
	end

    -- uniform coloring
    if self:IsSelected() then
        self.NormalTexture:SetAtlas('worldquest-questmarker-epic-supertracked', true)
    else
        self.NormalTexture:SetAtlas('worldquest-questmarker-epic', true)
    end

    -- set reward icon
    local questID = self.questID
    local currencyRewards = C_QuestLog.GetQuestRewardCurrencies(questID)
    if GetNumQuestLogRewards(questID) > 0 then
        local _, texture, _, _, _, itemID = GetQuestLogRewardInfo(1, questID)
        if C_Item.IsAnimaItemByID(itemID) then
            texture = 3528287 -- from item "Resonating Anima Core"
        end

        self.Reward:SetTexture(texture)
        self.Reward:Show()
    elseif #currencyRewards > 0 then
        self.Reward:SetTexture(currencyRewards[1].texture)
        self.Reward:Show()
    elseif GetQuestLogRewardMoney(questID) > 0 then
        self.Reward:SetTexture([[Interface\Icons\INV_MISC_COIN_01]])
        self.Reward:Show()
    else
        -- if there are no rewards just show the default icon
        self.Display.Icon:Show()
    end

    -- set world quest type indicator
    local questInfo = C_QuestLog.GetQuestTagInfo(questID)
    if questInfo then
        if questInfo.worldQuestType == Enum.QuestTagType.PvP then
            self.Indicator:SetAtlas('Warfronts-BaseMapIcons-Empty-Barracks-Minimap')
            self.Indicator:SetSize(18, 18)
            self.Indicator:Show()
        elseif questInfo.worldQuestType == Enum.QuestTagType.PetBattle then
            self.Indicator:SetAtlas('WildBattlePetCapturable')
            self.Indicator:SetSize(10, 10)
            self.Indicator:Show()
        elseif questInfo.worldQuestType == Enum.QuestTagType.Profession then
            self.Indicator:SetAtlas(WORLD_QUEST_ICONS_BY_PROFESSION[questInfo.tradeskillLineID])
            self.Indicator:SetSize(10, 10)
            self.Indicator:Show()
        elseif questInfo.worldQuestType == Enum.QuestTagType.Dungeon then
            self.Indicator:SetAtlas('Dungeon')
            self.Indicator:SetSize(20, 20)
            self.Indicator:Show()
        elseif questInfo.worldQuestType == Enum.QuestTagType.Raid then
            self.Indicator:SetAtlas('Raid')
            self.Indicator:SetSize(20, 20)
            self.Indicator:Show()
        elseif questInfo.worldQuestType == Enum.QuestTagType.Invasion then
            self.Indicator:SetAtlas('worldquest-icon-burninglegion')
            self.Indicator:SetSize(10, 10)
            self.Indicator:Show()
        elseif questInfo.worldQuestType == Enum.QuestTagType.FactionAssault then
            self.Indicator:SetAtlas(FACTION_ASSAULT_ATLAS)
            self.Indicator:SetSize(10, 10)
            self.Indicator:Show()
        end
    end

    -- update bounty icon
    local bountyQuestID = self.dataProvider:GetBountyInfo()
    if bountyQuestID and C_QuestLog.IsQuestCriteriaForBounty(questID, bountyQuestID) then
        self.Bounty:Show()
    end

    -- highlight reputation
    local _, factionID = C_TaskQuest.GetQuestInfoByQuestID(questID)
    if factionID then
        local factionInfo = C_Reputation.GetFactionDataByID(factionID)
        if factionInfo and factionInfo.isWatched then
            self.Reputation:Show()
        end
    end
end

function BetterWorldQuestPinMixin:AddIconWidgets()
	-- remove the obnoxious glow behind world bosses
end

function BetterWorldQuestPinMixin:SetPassThroughButtons()
	-- https://github.com/Stanzilla/WoWUIBugs/issues/453
end

local function togglePinsVisibility(state)
    for pin in WorldMapFrame:EnumeratePinsByTemplate(DataProvider:GetPinTemplate()) do
        pin:SetShown(state)
    end
end

function module:OnInit()
    -- remove the default provider
    for dp in next, WorldMapFrame.dataProviders do
        if not dp.GetPinTemplates and type(dp.GetPinTemplate) == 'function' then
            if dp:GetPinTemplate() == 'WorldMap_WorldQuestPinTemplate' then
                WorldMapFrame:RemoveDataProvider(dp)
                break
            end
        end
    end

    WorldMapFrame:AddDataProvider(DataProvider)
    
    module:RegisterEvent('MODIFIER_STATE_CHANGED', function()
        if WorldMapFrame:IsShown() then
            togglePinsVisibility(not IsAltKeyDown())
        end
    end)
    
    WorldMapFrame:HookScript('OnHide', function()
        togglePinsVisibility(true)
    end)
end
