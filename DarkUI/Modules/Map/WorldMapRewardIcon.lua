local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- World Map Reward Icon
------------------------------------------------------------------------
local module = E:Module("Map"):Sub("WorldMapRewardIcon")

local cfg = C.map.worldmap

local FACTION_ASSAULT_ATLAS = UnitFactionGroup("player") == "Horde" and "worldquest-icon-horde" or "worldquest-icon-alliance"
local SPECIAL_ASSIGNMENT_WIDGET_SET = 1108

local MAP_SCALE = 1.25
local PARENT_SCALE = 1
local ZOOM_FACTOR = 0.5

------------------------------------------------------------------------
-- Continent / Child Map Utilities
------------------------------------------------------------------------

local CONTINENTS = {
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
        [790] = true, -- Eye of Azshara
        [646] = true, -- Broken Shore
    },
    [424] = { -- Pandaria
        [1530] = true, -- Vale of Eternal Blossoms
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
        [14] = true, -- Arathi Highlands
    },
    [12] = { -- Kalimdor
        [62] = true, -- Darkshore
        [1527] = true, -- Uldum
    },
    [947] = { -- Azeroth
        [13] = true,
        [12] = true,
        [619] = true,
        [875] = true,
        [876] = true,
        [424] = true,
        [1978] = true,
        [2274] = true,
    },
}

local function isParentMap(mapID) return not not CONTINENTS[mapID] end

local function isChildMap(parentMapID, mapID)
    local mapInfo = C_Map.GetMapInfo(mapID)
    return parentMapID and mapID and mapInfo and mapInfo.parentMapID and mapInfo.parentMapID == parentMapID
end

local function translatePosition(position, fromMapID, toMapID)
    local continentID, worldPos = C_Map.GetWorldPosFromMapPos(fromMapID, position)
    local _, newPos = C_Map.GetMapPosFromWorldPos(continentID, worldPos, toMapID)
    return newPos
end

------------------------------------------------------------------------
-- Pin Mixin
------------------------------------------------------------------------

DarkUIWorldQuestPinMixin = CreateFromMixins(WorldMap_WorldQuestPinMixin)

function DarkUIWorldQuestPinMixin:OnLoad()
    WorldMap_WorldQuestPinMixin.OnLoad(self)

    local TrackedCheck = self:CreateTexture(nil, "OVERLAY", nil, 7)
    TrackedCheck:SetPoint("BOTTOM", self, "BOTTOMRIGHT", 0, -2)
    TrackedCheck:SetAtlas("worldquest-emissary-tracker-checkmark", true)
    TrackedCheck:Hide()
    self.TrackedCheck = TrackedCheck

    local TimeLowFrame = CreateFrame("Frame", nil, self)
    TimeLowFrame:SetPoint("CENTER", 9, -9)
    TimeLowFrame:SetSize(22, 22)
    TimeLowFrame:Hide()
    self.TimeLowFrame = TimeLowFrame

    local TimeLowIcon = TimeLowFrame:CreateTexture(nil, "OVERLAY")
    TimeLowIcon:SetAllPoints()
    TimeLowIcon:SetAtlas("worldquest-icon-clock")
    TimeLowFrame.Icon = TimeLowIcon

    local Reward = self:CreateTexture(nil, "OVERLAY")
    Reward:SetPoint("CENTER", self.PushedTexture)
    Reward:SetSize(self:GetWidth() - 4, self:GetHeight() - 4)
    Reward:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    self.Reward = Reward

    local RewardMask = self:CreateMaskTexture()
    RewardMask:SetTexture([[Interface\CharacterFrame\TempPortraitAlphaMask]])
    RewardMask:SetAllPoints(Reward)
    Reward:AddMaskTexture(RewardMask)

    local Indicator = self:CreateTexture(nil, "OVERLAY", nil, 2)
    Indicator:SetPoint("CENTER", self, "TOPLEFT", 4, -4)
    self.Indicator = Indicator

    local Reputation = self:CreateTexture(nil, "OVERLAY", nil, 2)
    Reputation:SetPoint("CENTER", self, "BOTTOM", 0, 2)
    Reputation:SetSize(10, 10)
    Reputation:SetAtlas("socialqueuing-icon-eye")
    Reputation:Hide()
    self.Reputation = Reputation

    local Bounty = self:CreateTexture(nil, "OVERLAY", nil, 3)
    Bounty:SetAtlas("QuestNormal", true)
    Bounty:SetScale(0.65)
    Bounty:SetPoint("LEFT", self, "RIGHT", -(Bounty:GetWidth() / 2), 0)
    self.Bounty = Bounty
end

function DarkUIWorldQuestPinMixin:RefreshVisuals()
    WorldMap_WorldQuestPinMixin.RefreshVisuals(self)

    self.Bounty:Hide()
    self.Reward:Hide()
    self.Reputation:Hide()
    self.Indicator:Hide()
    self.Display.Icon:Hide()

    local mapID = self:GetMap():GetMapID()
    if mapID == 947 then
        self:SetScalingLimits(1, PARENT_SCALE / 2, (PARENT_SCALE / 2) + ZOOM_FACTOR)
    elseif isParentMap(mapID) then
        self:SetScalingLimits(1, PARENT_SCALE, PARENT_SCALE + ZOOM_FACTOR)
    else
        self:SetScalingLimits(1, MAP_SCALE, MAP_SCALE + ZOOM_FACTOR)
    end

    if self:IsSelected() then
        self.NormalTexture:SetAtlas("worldquest-questmarker-epic-supertracked", true)
    else
        self.NormalTexture:SetAtlas("worldquest-questmarker-epic", true)
    end

    local questID = self.questID
    local currencyRewards = C_QuestLog.GetQuestRewardCurrencies(questID)
    if GetNumQuestLogRewards(questID) > 0 then
        local _, texture, _, _, _, itemID = GetQuestLogRewardInfo(1, questID)
        if C_Item.IsAnimaItemByID(itemID) then texture = 3528287 end
        self.Reward:SetTexture(texture)
        self.Reward:Show()
    elseif #currencyRewards > 0 then
        self.Reward:SetTexture(currencyRewards[1].texture)
        self.Reward:Show()
    elseif GetQuestLogRewardMoney(questID) > 0 then
        self.Reward:SetTexture([[Interface\Icons\INV_MISC_COIN_01]])
        self.Reward:Show()
    else
        self.Display.Icon:Show()
    end

    local questInfo = C_QuestLog.GetQuestTagInfo(questID)
    if questInfo then
        if questInfo.worldQuestType == Enum.QuestTagType.PvP then
            self.Indicator:SetAtlas("Warfronts-BaseMapIcons-Empty-Barracks-Minimap")
            self.Indicator:SetSize(18, 18)
            self.Indicator:Show()
        elseif questInfo.worldQuestType == Enum.QuestTagType.PetBattle then
            self.Indicator:SetAtlas("WildBattlePetCapturable")
            self.Indicator:SetSize(10, 10)
            self.Indicator:Show()
        elseif questInfo.worldQuestType == Enum.QuestTagType.Profession then
            self.Indicator:SetAtlas(WORLD_QUEST_ICONS_BY_PROFESSION[questInfo.tradeskillLineID])
            self.Indicator:SetSize(10, 10)
            self.Indicator:Show()
        elseif questInfo.worldQuestType == Enum.QuestTagType.Dungeon then
            self.Indicator:SetAtlas("Dungeon")
            self.Indicator:SetSize(20, 20)
            self.Indicator:Show()
        elseif questInfo.worldQuestType == Enum.QuestTagType.Raid then
            self.Indicator:SetAtlas("Raid")
            self.Indicator:SetSize(20, 20)
            self.Indicator:Show()
        elseif questInfo.worldQuestType == Enum.QuestTagType.Invasion then
            self.Indicator:SetAtlas("worldquest-icon-burninglegion")
            self.Indicator:SetSize(10, 10)
            self.Indicator:Show()
        elseif questInfo.worldQuestType == Enum.QuestTagType.FactionAssault then
            self.Indicator:SetAtlas(FACTION_ASSAULT_ATLAS)
            self.Indicator:SetSize(10, 10)
            self.Indicator:Show()
        end
    end

    local bountyQuestID = self.dataProvider:GetBountyInfo()
    if bountyQuestID and C_QuestLog.IsQuestCriteriaForBounty(questID, bountyQuestID) then self.Bounty:Show() end

    local _, factionID = C_TaskQuest.GetQuestInfoByQuestID(questID)
    if factionID then
        local factionInfo = C_Reputation.GetFactionDataByID(factionID)
        if factionInfo and factionInfo.isWatched then self.Reputation:Show() end
    end
end

function DarkUIWorldQuestPinMixin:AddIconWidgets() end

------------------------------------------------------------------------
-- World Quest Provider Override
------------------------------------------------------------------------

local function setupWorldQuestProvider()
    local provider
    for dp in next, WorldMapFrame.dataProviders do
        if not dp.GetPinTemplates and type(dp.GetPinTemplate) == "function" then
            if dp:GetPinTemplate() == "WorldMap_WorldQuestPinTemplate" then
                provider = dp
                break
            end
        end
    end

    if not provider then return end

    provider.GetPinTemplate = function() return "DarkUIWorldQuestPinTemplate" end

    provider.ShouldOverrideShowQuest = function() end

    local originalShouldShowQuest = provider.ShouldShowQuest or WorldQuestDataProviderMixin.ShouldShowQuest
    provider.ShouldShowQuest = function(self, questInfo)
        local mapID = self:GetMap():GetMapID()

        if originalShouldShowQuest(self, questInfo) then return true end

        local mapInfo = C_Map.GetMapInfo(mapID)
        if mapInfo.mapType == Enum.UIMapType.Continent then return true end

        return isChildMap(mapID, questInfo.mapID)
    end

    module:RegisterEvent("MODIFIER_STATE_CHANGED", function()
        if WorldMapFrame:IsShown() then
            for pin in WorldMapFrame:EnumeratePinsByTemplate("DarkUIWorldQuestPinTemplate") do
                pin:SetShown(not IsAltKeyDown())
            end
        end
    end)

    WorldMapFrame:HookScript("OnHide", function()
        for pin in WorldMapFrame:EnumeratePinsByTemplate("DarkUIWorldQuestPinTemplate") do
            pin:SetShown(true)
        end
    end)
end

------------------------------------------------------------------------
-- POI Provider (Special Assignments on Continent)
------------------------------------------------------------------------

local function setupPOIProvider()
    local provider = CreateFromMixins(AreaPOIDataProviderMixin)

    function provider:GetPinTemplate() return "DarkUIWorldQuestPOITemplate" end

    function provider:RefreshAllData()
        self:RemoveAllData()

        local map = self:GetMap()
        local mapID = map:GetMapID()

        if mapID == 947 then return end

        if isParentMap(mapID) then
            for _, mapInfo in next, C_Map.GetMapChildrenInfo(mapID, Enum.UIMapType.Zone, true) do
                if mapInfo.flags == 6 or mapInfo.flags == 4 then
                    for _, poiID in next, GetAreaPOIsForPlayerByMapIDCached(mapInfo.mapID) do
                        local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(mapInfo.mapID, poiID)
                        if poiInfo and poiInfo.tooltipWidgetSet == SPECIAL_ASSIGNMENT_WIDGET_SET then
                            poiInfo.dataProvider = self
                            poiInfo.position = translatePosition(poiInfo.position, mapInfo.mapID, mapID)
                            if poiInfo.position then map:AcquirePin(self:GetPinTemplate(), poiInfo) end
                        end
                    end
                end
            end
        end
    end

    WorldMapFrame:AddDataProvider(provider)
end

------------------------------------------------------------------------
-- Event Provider (Area Events on Continent)
------------------------------------------------------------------------

local function setupEventProvider()
    local provider = CreateFromMixins(AreaPOIEventDataProviderMixin)

    function provider:GetPinTemplate() return "DarkUIWorldQuestEventTemplate" end

    function provider:RefreshAllData()
        self:RemoveAllData()

        local map = self:GetMap()
        local mapID = map:GetMapID()

        if mapID == 947 then return end

        if isParentMap(mapID) then
            for _, mapInfo in next, C_Map.GetMapChildrenInfo(mapID, Enum.UIMapType.Zone, true) do
                if mapInfo.flags == 6 or mapInfo.flags == 4 then
                    for _, poiID in next, C_AreaPoiInfo.GetEventsForMap(mapInfo.mapID) do
                        local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(mapInfo.mapID, poiID)
                        if poiInfo then
                            poiInfo.dataProvider = self
                            poiInfo.position = translatePosition(poiInfo.position, mapInfo.mapID, mapID)
                            if poiInfo.position then map:AcquirePin(self:GetPinTemplate(), poiInfo) end
                        end
                    end
                end
            end
        end
    end

    WorldMapFrame:AddDataProvider(provider)
end

------------------------------------------------------------------------
-- Module Init
------------------------------------------------------------------------

function module:OnInit()
    if not cfg or not cfg.enable then return end
    if C_AddOns.IsAddOnLoaded("BetterWorldQuests") then return end

    setupWorldQuestProvider()
    setupPOIProvider()
    setupEventProvider()
end
