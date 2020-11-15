local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable then return end

----------------------------------------------------------------------------------------
--	StanceBar (modified from ShestakUI)
----------------------------------------------------------------------------------------

local _G = _G
local CreateFrame = CreateFrame
local RegisterStateDriver = RegisterStateDriver
local unpack, tinsert = unpack, tinsert
local NUM_POSSESS_SLOTS, NUM_STANCE_SLOTS = NUM_POSSESS_SLOTS, NUM_STANCE_SLOTS
local UIParent = _G.UIParent
local StanceBarFrame = _G.StanceBarFrame
local StanceBarLeft = _G.StanceBarLeft
local StanceBarMiddle = _G.StanceBarMiddle
local StanceBarRight = _G.StanceBarRight
local PossessBarFrame = _G.PossessBarFrame
local PossessBackground1, PossessBackground2 = _G.PossessBackground1, _G.PossessBackground2

local cfg = C.actionbar.bars.barstance

local bar = CreateFrame("Frame", "StanceBarHolder", UIParent, "SecureHandlerStateTemplate")
bar:SetWidth(NUM_STANCE_SLOTS * cfg.button.size + (NUM_STANCE_SLOTS - 1) * cfg.button.space)
bar:SetHeight(cfg.button.size)
bar:SetPoint(unpack(cfg.pos))
bar.buttonList = {}

StanceBarFrame:SetParent(bar)
StanceBarFrame:EnableMouse(false)
StanceBarLeft:SetTexture(nil)
StanceBarMiddle:SetTexture(nil)
StanceBarRight:SetTexture(nil)

for i = 1, NUM_STANCE_SLOTS do
    local button = _G["StanceButton" .. i]
    tinsert(bar.buttonList, button) --add the button object to the list
    button:SetSize(cfg.button.size, cfg.button.size)
    button:ClearAllPoints()
    if i == 1 then
        button:SetPoint("BOTTOMLEFT", bar, 0, 0)
    else
        local previous = _G["StanceButton" .. i - 1]
        button:SetPoint("LEFT", previous, "RIGHT", cfg.button.space, 0)
    end
end

PossessBarFrame:SetParent(bar)
PossessBarFrame:EnableMouse(false)
PossessBackground1:SetTexture(nil)
PossessBackground2:SetTexture(nil)

for i = 1, NUM_POSSESS_SLOTS do
    local button = _G["PossessButton" .. i]
    tinsert(bar.buttonList, button) --add the button object to the list
    button:SetSize(cfg.button.size, cfg.button.size)
    button:ClearAllPoints()
    if i == 1 then
        button:SetPoint("BOTTOMLEFT", bar, 0, 0)
    else
        local previous = _G["PossessButton" .. i - 1]
        button:SetPoint("LEFT", previous, "RIGHT", cfg.button.space, 0)
    end
end

--show/hide the frame on a given state driver
bar.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
RegisterStateDriver(bar, "visibility", bar.frameVisibility)

--create the mouseover functionality
if cfg.fader_mouseover then
    E:ButtonBarFader(bar, bar.buttonList, cfg.fader_mouseover.fadeIn, cfg.fader_mouseover.fadeOut)
end

--create the combat fader
if cfg.fader_combat then
    E:CombatFrameFader(bar, cfg.fader_combat.fadeIn, cfg.fader_combat.fadeOut)
end
