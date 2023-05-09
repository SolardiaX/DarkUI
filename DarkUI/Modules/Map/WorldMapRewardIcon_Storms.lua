local E, C, L = select(2, ...):unpack()

if not C.map.worldmap.enable and not C.map.worldmap.rewardIcon then return end

----------------------------------------------------------------------------------------
-- Reward Quest Item Icon (Based on BetterWorldQuests)
----------------------------------------------------------------------------------------
local module = E:Module("Map"):Sub("WorldMapRewardIcon")
local HBD = LibStub('HereBeDragons-2.0')

local DRAGON_ISLES_MAPS = {
	[2022] = true, -- The Walking Shores
	[2023] = true, -- Ohn'ahran Plains
	[2024] = true, -- The Azure Span
	[2025] = true, -- Thaldraszus
}

local function startsWith(str, start)
	return string.sub(str, 1, string.len(start)) == start
end

local function updatePOIs(self)
	local map = self:GetMap()
	local mapID = map:GetMapID()
	if mapID == 1978 then -- Dragon Isles
		for childMapID in next, DRAGON_ISLES_MAPS do
			for _, poiID in next, C_AreaPoiInfo.GetAreaPOIForMap(childMapID) do
				local info = C_AreaPoiInfo.GetAreaPOIInfo(childMapID, poiID)
				if info and startsWith(info.atlasName, 'ElementalStorm') then
					local x, y = info.position:GetXY()
					info.dataProvider = self
					info.position:SetXY(HBD:TranslateZoneCoordinates(x, y, childMapID, mapID))
					map:AcquirePin(self:GetPinTemplate(), info)
				end
			end
		end
	end
end

module:RegisterEvent("PLAYER_LOGIN", function()
	for provider in next, WorldMapFrame.dataProviders do
		if provider.GetPinTemplate and provider:GetPinTemplate() == 'AreaPOIPinTemplate' then
			hooksecurefunc(provider, 'RefreshAllData', updatePOIs)
		end
	end
end)
