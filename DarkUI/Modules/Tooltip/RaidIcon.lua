local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Raid Icon
------------------------------------------------------------------------

local module = E:Module("Tooltip"):Sub("RaidIcon")
local cfg = C.tooltip

local GetRaidTargetIndex = GetRaidTargetIndex
local UnitExists = UnitExists
local UnitTokenFromGUID = UnitTokenFromGUID

local ricon

local function onTooltipSetUnit(self)
    if self ~= GameTooltip or self:IsForbidden() then return end

    local data = self:GetTooltipData()
    local guid = data and data.guid
    if not guid or not canaccessvalue(guid) then return end

    local unit = UnitTokenFromGUID(guid) or (UnitExists("mouseover") and "mouseover")
    if not unit then
        ricon:SetTexture(nil)
        return
    end

    local raidIndex = GetRaidTargetIndex(unit)
    if raidIndex and not issecretvalue(raidIndex) then
        ricon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. raidIndex)
    else
        ricon:SetTexture(nil)
    end
end

function module:OnInit()
    if not cfg.enable or not cfg.raid_icon then return end

    ricon = GameTooltip:CreateTexture("GameTooltipRaidIcon", "OVERLAY")
    ricon:SetSize(18, 18)
    ricon:SetPoint("CENTER", GameTooltip, "TOP", 0, 0)

    GameTooltip:HookScript("OnHide", function()
        ricon:SetTexture(nil)
    end)

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, onTooltipSetUnit)
end
