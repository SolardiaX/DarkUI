--[[
	cargBags: An inventory framework addon for World of Warcraft

	Copyright (C) 2010  Constantin "Cargor" Schomburg <xconstruct@gmail.com>

	cargBags is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	cargBags is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with cargBags; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

DESCRIPTION
	Item keys for the Blizz equipment sets

DEPENDENCIES
	mixins-add/itemkeys/basic.lua
]]
local parent, ns = ...
local cargBags = ns.cargBags

local isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

if isClassic then return end

local ItemKeys = cargBags.itemKeys

local setItems

local GetNumEquipmentSets = C_EquipmentSet.GetNumEquipmentSets
local GetEquipmentSetInfo = C_EquipmentSet.GetEquipmentSetInfo
local GetEquipmentSetItemIDs = C_EquipmentSet.GetItemIDs

local function initUpdater()

	local updateSets
	function updateSets()
		setItems = setItems or {}
		for k in pairs(setItems) do setItems[k] = nil end

		for setID = 0, GetNumEquipmentSets() do
			local items = GetEquipmentSetItemIDs(setID)

			if items then
				for slot, id in pairs(items) do
					setItems[id] = setID
				end
			end
		end
	end

	local updater = CreateFrame("Frame")
	updater:RegisterEvent("EQUIPMENT_SETS_CHANGED")
	updater:RegisterEvent("PLAYER_ALIVE")
	updater:SetScript("OnEvent", function()
		updateSets()
		cargBags:FireEvent("BAG_UPDATE")
	end)

	updateSets()
end

ItemKeys["setID"] = function(i)
	if(not setItems) then initUpdater() end
	return setItems[i.id]
end

ItemKeys["set"] = function(i)
	local setID = i.setID
	return setID and GetEquipmentSetInfo(setID)
end

