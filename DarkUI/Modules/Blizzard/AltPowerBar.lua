local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Alt Power Bar
------------------------------------------------------------------------

local module = E:Module("Blizzard"):Sub("AltPowerBar")

local cfg = C.blizzard

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg.custom_position then return end

    PlayerPowerBarAlt:UnregisterEvent("UNIT_POWER_BAR_SHOW")
    PlayerPowerBarAlt:UnregisterEvent("UNIT_POWER_BAR_HIDE")
    PlayerPowerBarAlt:UnregisterEvent("PLAYER_ENTERING_WORLD")

    local bar = CreateFrame("Frame", "DarkUI_AltPowerBar", UIParent)
    bar:SetSize(200, 16)
    bar:SetTemplate("Default")
    bar:SetPoint(unpack(cfg.alt_powerbar_pos))
    bar:SetFrameStrata("HIGH")
    bar:EnableMouse(true)
    bar:SetMovable(true)
    bar:SetUserPlaced(true)
    bar:CreateBorder()

    bar:SetScript("OnMouseDown", function(_, button)
        if IsAltKeyDown() or IsShiftKeyDown() then
            bar:ClearAllPoints()
            bar:StartMoving()
        elseif IsControlKeyDown() and button == "RightButton" then
            bar:ClearAllPoints()
            bar:SetPoint(unpack(cfg.alt_powerbar_pos))
        end
    end)
    bar:SetScript("OnMouseUp", function()
        bar:StopMovingOrSizing()
    end)

    bar:RegisterEvent("UNIT_POWER_UPDATE")
    bar:RegisterEvent("UNIT_POWER_BAR_SHOW")
    bar:RegisterEvent("UNIT_POWER_BAR_HIDE")
    bar:RegisterEvent("PLAYER_ENTERING_WORLD")
    bar:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_ENTERING_WORLD" then
            bar:SetPoint(unpack(cfg.alt_powerbar_pos))
            self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        end
        if GetUnitPowerBarInfo("player") then
            self:Show()
        else
            self:Hide()
        end
    end)

    bar:SetScript("OnEnter", function(self)
        local name, tooltip = GetUnitPowerBarStrings("player")
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -5)
        GameTooltip:AddLine(name, 1, 1, 1)
        GameTooltip:AddLine(tooltip, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    bar:SetScript("OnLeave", GameTooltip_Hide)

    local status = CreateFrame("StatusBar", "DarkUI_AltPowerBarStatus", bar)
    status:SetFrameLevel(bar:GetFrameLevel() + 1)
    status:SetStatusBarTexture(C.media.texture.status)
    status:SetMinMaxValues(0, 100)
    status:SetPoint("TOPLEFT", bar, 2, -2)
    status:SetPoint("BOTTOMRIGHT", bar, -2, 2)

    status.bg = status:CreateTexture(nil, "BACKGROUND")
    status.bg:SetAllPoints(status)
    status.bg:SetTexture(C.media.texture.status)

    status.text = bar:CreateFontString(nil, "OVERLAY")
    status.text:SetFont(unpack(C.media.standard_font))
    status.text:SetPoint("CENTER", bar, 0, 0)

    local gradient = C_CurveUtil.CreateColorCurve()
    gradient:AddPoint(0.0, CreateColor(0.8, 0.2, 0.1))
    gradient:AddPoint(0.5, CreateColor(1, 0.8, 0.1))
    gradient:AddPoint(1.0, CreateColor(0.2, 0.8, 0.1))

    local elapsed = 1
    status:SetScript("OnUpdate", function(self, dt)
        if not bar:IsShown() then return end
        elapsed = elapsed + dt
        if elapsed < 1 then return end
        elapsed = 0

        local cur = UnitPower("player", ALTERNATE_POWER_INDEX)
        local max = UnitPowerMax("player", ALTERNATE_POWER_INDEX)
        local _, r, g, b = GetUnitPowerBarTextureInfo("player", 2, 0)
        if not r or (r == 1 and g == 1 and b == 1) then
            local color = UnitPowerPercent("player", ALTERNATE_POWER_INDEX, true, gradient)
            if color then
                r, g, b = color:GetRGB()
            else
                r, g, b = 0.2, 0.8, 0.1
            end
        end
        self:SetMinMaxValues(0, max)
        self:SetValue(cur)
        self.text:SetText(cur .. "/" .. max)
        self:GetStatusBarTexture():SetVertexColor(r, g, b)
        self.bg:SetVertexColor(r, g, b, 0.25)
    end)

    if PlayerPowerBarAlt then
        PlayerPowerBarAlt:ClearAllPoints()
        PlayerPowerBarAlt:SetPoint("TOP", UIParent, "TOP", 0, -200)
    end
end
