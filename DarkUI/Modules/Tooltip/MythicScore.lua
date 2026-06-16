local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Mythic+ Score
------------------------------------------------------------------------

local module = E:Module("Tooltip"):Sub("MythicScore")
local cfg = C.tooltip

local format = format
local UnitIsPlayer = UnitIsPlayer
local UnitExists = UnitExists
local UnitTokenFromGUID = UnitTokenFromGUID
local C_PlayerInfo_GetPlayerMythicPlusRatingSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary
local C_ChallengeMode_GetDungeonScoreRarityColor = C_ChallengeMode.GetDungeonScoreRarityColor

local function onTooltipSetUnit(self)
    if self ~= GameTooltip or self:IsForbidden() then return end

    local data = self:GetTooltipData()
    local guid = data and data.guid
    if not guid or not canaccessvalue(guid) then return end

    local unit = UnitTokenFromGUID(guid) or (UnitExists("mouseover") and "mouseover")
    if not unit or not UnitIsPlayer(unit) then return end

    local summary = C_PlayerInfo_GetPlayerMythicPlusRatingSummary(unit)
    local score = summary and summary.currentSeasonScore
    if not score or score <= 0 then return end

    local color = C_ChallengeMode_GetDungeonScoreRarityColor(score) or HIGHLIGHT_FONT_COLOR
    self:AddDoubleLine(L.TOOLTIP_MYTHIC_SCORE .. ":", color:WrapTextInColorCode(score))
end

function module:OnInit()
    if not cfg.enable or not cfg.mythic_score then return end

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, onTooltipSetUnit)
end
