local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable then return end

----------------------------------------------------------------------------------------
--	MultiBarRight (modified from ShestakUI)
----------------------------------------------------------------------------------------
local _G = _G
local CreateFrame = CreateFrame
local RegisterStateDriver = RegisterStateDriver
local tinsert, unpack = tinsert, unpack
local UIParent = _G.UIParent

local cfg = C.actionbar.bars.bar4
local num = NUM_ACTIONBAR_BUTTONS

local bar = CreateFrame("Frame", "DarkUI_ActionBar4Holder", UIParent, "SecureHandlerStateTemplate")
bar:SetPoint(unpack(cfg.pos))
bar:SetWidth(cfg.button.size)
bar:SetHeight(num * cfg.button.size + (num - 1) * cfg.button.space)
bar.buttonList = {}

_G.MultiBarRight:SetParent(bar)

for i = 1, num do
    local button = _G["MultiBarRightButton" .. i]
    tinsert(bar.buttonList, button) --add the button object to the list

    button:SetSize(cfg.button.size, cfg.button.size)
    button:ClearAllPoints()

    if i == 1 then
        button:SetPoint("TOPRIGHT", bar, "TOPRIGHT", 0, 0)
    else
        local previous = _G["MultiBarRightButton" .. i - 1]
        button:SetPoint("TOP", previous, "BOTTOM", 0, -cfg.button.space)
    end
end

RegisterStateDriver(bar, "visibility", "[vehicleui][petbattle][overridebar] hide; show")

--create the mouseover functionality
if cfg.fader_mouseover then
    E:ButtonBarFader(bar, bar.buttonList, cfg.fader_mouseover.fadeIn, cfg.fader_mouseover.fadeOut)
end

--create the combat fader
if cfg.fader_combat then
    E:CombatFrameFader(bar, cfg.fader_combat.fadeIn, cfg.fader_combat.fadeOut)
end
