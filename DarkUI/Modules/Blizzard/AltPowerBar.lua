local _, ns = ...
local E, C, L, M = ns:unpack()
local oUF = ns.oUF or oUF

if not C.blizzard.custom_position then return end

----------------------------------------------------------------------------------------
--	Skin AltPowerBar(by Tukz)
----------------------------------------------------------------------------------------

local CreateFrame = CreateFrame
local IsAltKeyDown, IsControlKeyDown, IsShiftKeyDown = IsAltKeyDown, IsControlKeyDown, IsShiftKeyDown
local UnitAlternatePowerInfo = UnitAlternatePowerInfo
local UnitPower, UnitPowerMax = UnitPower, UnitPowerMax
local UnitAlternatePowerTextureInfo = UnitAlternatePowerTextureInfo
local GameTooltip_Hide = GameTooltip_Hide
local unpack, select = unpack, select
local UIParent, PlayerPowerBarAlt, GameTooltip = UIParent, PlayerPowerBarAlt, GameTooltip
local ALTERNATE_POWER_INDEX = ALTERNATE_POWER_INDEX

local bar_border = C.media.path .. C.general.style .. "\\" .. "tex_bar_border"

-- Get rid of old AltPowerBar
PlayerPowerBarAlt:UnregisterEvent("UNIT_POWER_BAR_SHOW")
PlayerPowerBarAlt:UnregisterEvent("UNIT_POWER_BAR_HIDE")
PlayerPowerBarAlt:UnregisterEvent("PLAYER_ENTERING_WORLD")

-- AltPowerBar
local bar = CreateFrame("Frame", "UIAltPowerBar", UIParent)
bar:SetSize(198, 12)
bar:SetPoint(unpack(C.blizzard.alt_powerbar_pos))

-- Make moveable
bar:EnableMouse(true)
bar:SetMovable(true)
bar:SetUserPlaced(true)
bar:SetFrameStrata("HIGH")
bar:SetScript("OnMouseDown", function(_, button)
    if IsAltKeyDown() or IsShiftKeyDown() then
        bar:ClearAllPoints()
        bar:StartMoving()
    elseif IsControlKeyDown() and button == "RightButton" then
        bar:ClearAllPoints()
        bar:SetPoint(unpack(C.blizzard.alt_powerbar_pos))
    end
end)
bar:SetScript("OnMouseUp", function()
    bar:StopMovingOrSizing()
end)

-- Event handling
bar:RegisterEvent("UNIT_POWER_UPDATE")
bar:RegisterEvent("UNIT_POWER_BAR_SHOW")
bar:RegisterEvent("UNIT_POWER_BAR_HIDE")
bar:RegisterEvent("PLAYER_ENTERING_WORLD")
bar:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        bar:SetPoint(unpack(C.blizzard.alt_powerbar_pos))
    end
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    if GetUnitPowerBarInfo("player") then
        self:Show()
    else
        self:Hide()
    end
end)

-- Tooltip
bar:SetScript("OnEnter", function(self)
    local name, tooltip = GetUnitPowerBarStrings("player")

    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -5)
    GameTooltip:AddLine(name, 1, 1, 1)
    GameTooltip:AddLine(tooltip, nil, nil, nil, true)

    GameTooltip:Show()
end)
bar:SetScript("OnLeave", GameTooltip_Hide)

-- StatusBar
local status = CreateFrame("StatusBar", "UIAltPowerBarStatus", bar)
status:SetFrameLevel(bar:GetFrameLevel() + 1)
status:SetStatusBarTexture(C.media.texture.status)
status:SetMinMaxValues(0, 100)
status:SetPoint("TOPLEFT", bar, "TOPLEFT", 2, -2)
status:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -2, 2)

status.bg = status:CreateTexture(nil, "BACKGROUND")
status.bg:SetAllPoints(status)
status.bg:SetTexture(C.media.texture.status)

status.border = status:CreateTexture(nil, "BORDER")
status.border:SetPoint("CENTER", status, 0, -1)
status.border:SetTexture(bar_border)

status.text = status:CreateFontString(nil, "OVERLAY")
status.text:SetFont(unpack(C.media.standard_font))
status.text:SetPoint("CENTER", bar, "CENTER", 0, 0)

-- Update Function
local update = 1
status:SetScript("OnUpdate", function(self, elapsed)
    if not bar:IsShown() then return end
    update = update + elapsed

    if update >= 1 then
        local cur = UnitPower("player", ALTERNATE_POWER_INDEX)
        local max = UnitPowerMax("player", ALTERNATE_POWER_INDEX)
        local texture, r, g, b = GetUnitPowerBarTextureInfo("player", 2, 0)
		if not texture or (r == 1 and g == 1 and b == 1) then
            r, g, b = oUF:ColorGradient(cur, max, 0.8, 0.2, 0.1, 1, 0.8, 0.1, 0.33, 0.59, 0.33)
        end
        self:SetMinMaxValues(0, max)
        self:SetValue(cur)
        self.text:SetText(cur.."/"..max)
        self:SetStatusBarColor(r, g, b)
        self.bg:SetVertexColor(r, g, b, 0.25)
        update = 0
    end
end)