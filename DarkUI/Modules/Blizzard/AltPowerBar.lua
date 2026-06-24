local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Alt Power Bar
------------------------------------------------------------------------

local module = E:Module("Blizzard"):Sub("AltPowerBar")

local cfg = C.blizzard

local pcall = pcall
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local GetUnitPowerBarInfo = GetUnitPowerBarInfo

local SMOOTH = Enum and Enum.StatusBarInterpolation and Enum.StatusBarInterpolation.ExponentialEaseOut

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg.custom_position then return end

    if PlayerPowerBarAlt then
        PlayerPowerBarAlt:UnregisterAllEvents()
        PlayerPowerBarAlt:Hide()
    end

    local bar = CreateFrame("StatusBar", "DarkUI_AltPowerBar", UIParent)
    bar:SetSize(200, 16)
    bar:SetPoint(unpack(cfg.alt_powerbar_pos))
    bar:SetFrameStrata("HIGH")
    bar:SetStatusBarTexture(C.media.texture.status)
    bar:SetMinMaxValues(0, 100)
    bar:SetTemplate("Default")
    bar:CreateBorder()
    bar:EnableMouse(true)
    bar:SetMovable(true)
    bar:SetUserPlaced(true)

    bar.bg = bar:CreateTexture(nil, "BACKGROUND")
    bar.bg:SetAllPoints()
    bar.bg:SetTexture(C.media.texture.status)

    bar.text = bar:CreateFontString(nil, "OVERLAY")
    bar.text:SetFont(unpack(C.media.standard_font))
    bar.text:SetPoint("CENTER")

    bar:SetScript("OnMouseDown", function(_, button)
        if IsAltKeyDown() or IsShiftKeyDown() then
            bar:ClearAllPoints()
            bar:StartMoving()
        elseif IsControlKeyDown() and button == "RightButton" then
            bar:ClearAllPoints()
            bar:SetPoint(unpack(cfg.alt_powerbar_pos))
        end
    end)
    bar:SetScript("OnMouseUp", function() bar:StopMovingOrSizing() end)

    local gradient = C_CurveUtil.CreateColorCurve()
    gradient:AddPoint(0.0, CreateColor(0.8, 0.2, 0.1))
    gradient:AddPoint(0.5, CreateColor(1, 0.8, 0.1))
    gradient:AddPoint(1.0, CreateColor(0.2, 0.8, 0.1))

    local function updateBar()
        local barInfo = GetUnitPowerBarInfo("player")
        if not barInfo then
            bar:Hide()
            return
        end

        bar:Show()

        local cur = UnitPower("player", ALTERNATE_POWER_INDEX)
        local max = UnitPowerMax("player", ALTERNATE_POWER_INDEX)

        bar:SetMinMaxValues(barInfo.minPower, max)
        bar:SetValue(cur, SMOOTH)
        bar.text:SetText(cur .. "/" .. max)

        local r, g, b
        local ok, color = pcall(UnitPowerPercent, "player", ALTERNATE_POWER_INDEX, true, gradient)
        if ok and color then
            r, g, b = color:GetRGB()
        else
            r, g, b = 0.2, 0.8, 0.1
        end

        bar:GetStatusBarTexture():SetVertexColor(r, g, b)
        bar.bg:SetVertexColor(r, g, b, 0.25)
    end

    bar:RegisterEvent("UNIT_POWER_UPDATE")
    bar:RegisterEvent("UNIT_POWER_BAR_SHOW")
    bar:RegisterEvent("UNIT_POWER_BAR_HIDE")
    bar:RegisterEvent("PLAYER_ENTERING_WORLD")
    bar:SetScript("OnEvent", function(_, _, unit)
        if unit and unit ~= "player" then return end
        updateBar()
    end)

    bar:SetScript("OnEnter", function(self)
        if GameTooltip:IsForbidden() then return end
        local name, tooltip = GetUnitPowerBarStrings("player")
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -5)
        GameTooltip:AddLine(name, 1, 1, 1)
        GameTooltip:AddLine(tooltip, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    bar:SetScript("OnLeave", GameTooltip_Hide)

    updateBar()
end
