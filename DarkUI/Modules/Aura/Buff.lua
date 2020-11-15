local E, C, L = select(2, ...):unpack()

if not C.aura.style.enable then return end

----------------------------------------------------------------------------------------
--	Aura styles (modified from Elv)
----------------------------------------------------------------------------------------

local _G = _G
local CreateFrame = CreateFrame
local UnitDebuff = UnitDebuff
local DebuffTypeColor = DebuffTypeColor
local ConsolidatedBuffs = ConsolidatedBuffs
local SetCVar = SetCVar
local hooksecurefunc = hooksecurefunc
local unpack, mod = unpack, mod
local TemporaryEnchantFrame, BuffFrame = TemporaryEnchantFrame, BuffFrame
local GetWeaponEnchantInfo = GetWeaponEnchantInfo
local UnitHasVehicleUI = UnitHasVehicleUI
local TempEnchant1, TempEnchant2 = TempEnchant1, TempEnchant2

local cfg = C.aura.style

local PositionTempEnchant = function()
    TemporaryEnchantFrame:ClearAllPoints()
    TemporaryEnchantFrame:SetPoint(unpack(cfg.buff_pos))
end

local StyleAura = function(name, index, t, color)
    local bn = name .. index
    local buff = _G[bn]
    local icon = _G[bn .. "Icon"]
    local duration = _G[bn .. "Duration"]
    local count = _G[bn .. "Count"]

    if not buff or (buff and buff.styled) then return end

    --button
    buff:SetSize(cfg[t .. "_size"], cfg[t .. "_size"])

    --icon
    icon:SetTexCoord(.08, .92, .08, .92)
    icon:SetPoint("TOPLEFT", buff, cfg.icon_padding, -cfg.icon_padding)
    icon:SetPoint("BOTTOMRIGHT", buff, -cfg.icon_padding, cfg.icon_padding)
    icon:SetDrawLayer("BACKGROUND", -8)
    buff.icon = icon

    --border
    buff:CreateTextureBorder()

    if t == "enchant" then buff.border:SetVertexColor(0.7, 0, 1) end
    if t == "debuff" then buff.border:SetVertexColor(color.r * 0.6, color.g * 0.6, color.b * 0.6, 1) end

    --duration
    duration:ClearAllPoints()
    duration:SetPoint(unpack(cfg.dur_pos))
    duration:SetFont(unpack(cfg.dur_font_style))

    --count
    count:ClearAllPoints()
    count:SetPoint(unpack(cfg.count_pos))
    count:SetFont(unpack(cfg.count_font_style))

    --shadow
    buff:CreateShadow()

    buff.styled = true
end

local OverrideBuffAnchors = function()
    local buttonName = "BuffButton"
    local previousBuff, aboveBuff
    local numBuffs = 0
    local numAuraRows = 0
    local slack = BuffFrame.numEnchants
    local mainhand, _, _, offhand = GetWeaponEnchantInfo()
    local BUFF_ACTUAL_DISPLAY = BUFF_ACTUAL_DISPLAY

    for index = 1, BUFF_ACTUAL_DISPLAY do
        StyleAura(buttonName, index, "buff", nil)

        local buff = _G[buttonName .. index]
        numBuffs = numBuffs + 1
        index = numBuffs + slack
        buff:ClearAllPoints()

        if (index > 1) and (mod(index, cfg.row_num) == 1) then
            numAuraRows = numAuraRows + 1
            buff:SetPoint("TOP", aboveBuff, "BOTTOM", 0, -cfg.spacing * 2)
            aboveBuff = buff
        elseif index == 1 then
            numAuraRows = 1
            buff:SetPoint(unpack(cfg.buff_pos))
        else
            if numBuffs == 1 then
                if mainhand and offhand and not UnitHasVehicleUI("player") then
                    buff:SetPoint("RIGHT", TempEnchant2, "LEFT", -cfg.spacing * 2, 0)
                elseif ((mainhand and not offhand) or (offhand and not mainhand)) and not UnitHasVehicleUI("player") then
                    buff:SetPoint("RIGHT", TempEnchant1, "LEFT", -cfg.spacing * 2, 0)
                else
                    buff:SetPoint(unpack(cfg.buff_pos))
                end
            else
                buff:SetPoint("RIGHT", previousBuff, "LEFT", -cfg.spacing, 0)
            end
        end
        previousBuff = buff
    end
end

local OverrideDebuffAnchors = function(buttonName, i)
    local color
    local dtype = select(4, UnitDebuff("player", i))
    local buff = _G[buttonName .. i]

    if (dtype ~= nil) then
        color = DebuffTypeColor[dtype]
    else
        color = DebuffTypeColor["none"]
    end

    color = color or DebuffTypeColor["none"]

    if not buff.styled then StyleAura(buttonName, i, "debuff", color) end

    buff:ClearAllPoints()
    if i == 1 then
        buff:SetPoint(unpack(cfg.debuff_pos))
    else
        buff:SetPoint("RIGHT", _G[buttonName .. (i - 1)], "LEFT", -cfg.spacing, 0)
    end
end

local OverrideTempEnchantAnchors = function()
    local previousBuff
    local NUM_TEMP_ENCHANT_FRAMES = NUM_TEMP_ENCHANT_FRAMES
    for i = 1, NUM_TEMP_ENCHANT_FRAMES do
        local te = _G["TempEnchant" .. i]
        if te then
            if (i == 1) then
                te:SetPoint("TOPRIGHT", TemporaryEnchantFrame, "TOPRIGHT", 0, 0)
            else
                te:SetPoint("RIGHT", previousBuff, "LEFT", -cfg.spacing, 0)
            end
            previousBuff = te
        end
    end
end

local function UpdateFlash(self, _)
    self:SetAlpha(1)
end

local Initialize = function()
    --position buff & temp enchant frames
    PositionTempEnchant()

    --stylize temp enchant frames
    for i = 1, NUM_TEMP_ENCHANT_FRAMES do
        StyleAura("TempEnchant", i, "enchant", nil)
    end

    OverrideTempEnchantAnchors()

    --getting rid of consolidate buff frame
    if ConsolidatedBuffs then
        ConsolidatedBuffs:UnregisterAllEvents()
        ConsolidatedBuffs:HookScript("OnShow", function(s)
            s:Hide()
            PositionTempEnchant()
        end)
        ConsolidatedBuffs:HookScript("OnHide", function(s)
            PositionTempEnchant()
        end)
        ConsolidatedBuffs:Hide()
    end
end

-- hooking our modifications
hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", OverrideBuffAnchors)
hooksecurefunc("DebuffButton_UpdateAnchors", OverrideDebuffAnchors)
hooksecurefunc("AuraButton_OnUpdate", UpdateFlash)

local f = CreateFrame("Frame")
f:RegisterEvent("VARIABLES_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self, event, ...)
    if event == "VARIABLES_LOADED" then
        if cfg.disable_timers then cfg.disable_timers = 0 else cfg.disable_timers = 1 end
        SetCVar("buffDurations", cfg.disable_timers)    -- enabling buff durations
    else
        Initialize()
    end
end)
