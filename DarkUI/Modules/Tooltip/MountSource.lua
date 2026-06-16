local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Mount Source
------------------------------------------------------------------------

local module = E:Module("Tooltip"):Sub("MountSource")

local cfg = C.tooltip

local MountCache = {}

local function buildMountCache()
    for _, mountID in ipairs(C_MountJournal.GetMountIDs()) do
        MountCache[select(2, C_MountJournal.GetMountInfoByID(mountID))] = mountID
    end
end

local function onSetUnitBuff(self, ...)
    if not UnitIsPlayer(...) or UnitIsUnit(..., "player") then return end
    local aura = C_UnitAuras.GetAuraDataByAuraInstanceID(...)
    local id = aura and aura.spellId
    if not id or issecretvalue(id) then return end

    if MountCache[id] then
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
end

function module:OnInit()
    if not cfg.enable or not cfg.mount then return end

    self:RegisterEvent("PLAYER_LOGIN", buildMountCache)
    hooksecurefunc(GameTooltip, "SetUnitBuffByAuraInstanceID", onSetUnitBuff)
end
