﻿local E, C, L = select(2, ...):unpack()

if C.tooltip.enable ~= true or C.tooltip.mount ~= true then return end

----------------------------------------------------------------------------------------
--    Show source of mount
----------------------------------------------------------------------------------------
local module = E:Module("Tooltip"):Sub("MountSource")

local C_MountJournal = C_MountJournal
local C_UnitAuras = C_UnitAuras
local GameTooltip = GameTooltip
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local hooksecurefunc = hooksecurefunc
local ipairs, select = ipairs, select
local COLLECTED, NOT_COLLECTED = COLLECTED, NOT_COLLECTED

local MountCache = {}

module:RegisterEvent("PLAYER_LOGIN", function()
    for _, mountID in ipairs(C_MountJournal.GetMountIDs()) do
        MountCache[select(2, C_MountJournal.GetMountInfoByID(mountID))] = mountID
    end
end)

hooksecurefunc(GameTooltip, "SetUnitBuffByAuraInstanceID", function(self, ...)
    if not UnitIsPlayer(...) or UnitIsUnit(..., "player") then return end
    local aura = C_UnitAuras.GetAuraDataByAuraInstanceID(...)
    local id = aura and aura.spellId

    if id and MountCache[id] then
        local text = NOT_COLLECTED
        local r, g, b = 1, 0, 0
        local collected = select(11, C_MountJournal.GetMountInfoByID(MountCache[id]))

        if collected then
            text = COLLECTED
            r, g, b = 0, 1, 0
        end

        self:AddLine(" ")
        self:AddLine(text, r, g, b)

        local sourceText = select(3, C_MountJournal.GetMountInfoExtraByID(MountCache[id]))
        self:AddLine(sourceText, 1, 1, 1)
        self:AddLine(" ")
        self:Show()
    end
end)