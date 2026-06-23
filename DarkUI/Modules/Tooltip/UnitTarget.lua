local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Unit Target
------------------------------------------------------------------------

local module = E:Module("Tooltip"):Sub("UnitTarget")
local cfg = C.tooltip

local format, unpack = format, unpack
local UnitExists = UnitExists
local UnitName = UnitName
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitIsEnemy = UnitIsEnemy
local UnitIsFriend = UnitIsFriend
local UnitClass = UnitClass
local UnitReaction = UnitReaction
local UnitTokenFromGUID = UnitTokenFromGUID

local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS

local function getTargetColor(unitTarget)
    if UnitIsEnemy("player", unitTarget) then
        return unpack(C.oUF_colors.reaction[1])
    elseif not UnitIsFriend("player", unitTarget) then
        return unpack(C.oUF_colors.reaction[4])
    elseif UnitIsPlayer(unitTarget) then
        local _, class = UnitClass(unitTarget)
        local color = class and (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
        if color then return color.r, color.g, color.b end
    else
        local reaction = UnitReaction(unitTarget, "player")
        if reaction and C.oUF_colors.reaction[reaction] then
            local c = C.oUF_colors.reaction[reaction]
            return c[1], c[2], c[3]
        end
    end
    return 1, 1, 1
end

local function onTooltipSetUnit(self)
    if self ~= GameTooltip or self:IsForbidden() then return end

    local data = self:GetTooltipData()
    local guid = data and data.guid
    if not guid or not canaccessvalue(guid) then return end

    local unit = UnitTokenFromGUID(guid) or (UnitExists("mouseover") and "mouseover")
    if not unit or UnitIsUnit(unit, "player") then return end

    local unitTarget = unit .. "target"
    if not UnitExists(unitTarget) then return end

    local tr, tg, tb = getTargetColor(unitTarget)

    local text
    if
        C_Secrets
        and C_Secrets.ShouldUnitComparisonBeSecret
        and not C_Secrets.ShouldUnitComparisonBeSecret("player", unitTarget)
        and UnitIsUnit("player", unitTarget)
    then
        text = "|cfffed100" .. STATUS_TEXT_TARGET .. ":|r |cffff0000> " .. UNIT_YOU .. " <|r"
    else
        text = "|cfffed100" .. STATUS_TEXT_TARGET .. ":|r " .. (UnitName(unitTarget) or UNKNOWN)
    end

    self:AddLine(text, tr, tg, tb)
end

function module:OnInit()
    if not cfg.enable or not cfg.unit_target then return end

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, onTooltipSetUnit)
end
