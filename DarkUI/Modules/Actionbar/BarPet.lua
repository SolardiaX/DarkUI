local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable then return end

----------------------------------------------------------------------------------------
--	PetActionBar (modified from ShestakUI)
----------------------------------------------------------------------------------------

local _G = _G
local CreateFrame = CreateFrame
local RegisterStateDriver = RegisterStateDriver
local unpack, tinsert = unpack, tinsert
local UIParent = _G.UIParent
local PetActionBarFrame = _G.PetActionBarFrame

local cfg = C.actionbar.bars.barpet
local num = NUM_PET_ACTION_SLOTS

local bar = CreateFrame("Frame", "DarkUI_PetActionBarHolder", UIParent, "SecureHandlerStateTemplate")
bar:SetWidth(num * cfg.button.size + (num - 1) * cfg.button.space)
bar:SetHeight(cfg.button.size)
bar:SetPoint(unpack(cfg.pos))
bar.buttonList = {}

PetActionBarFrame:SetParent(bar)
PetActionBarFrame:EnableMouse(false)

for i = 1, num do
    local button = _G["PetActionButton" .. i]
    tinsert(bar.buttonList, button) --add the button object to the list

    button:SetSize(cfg.button.size, cfg.button.size)
    button:ClearAllPoints()

    if i == 1 then
        button:SetPoint("BOTTOMLEFT", bar, 0, 0)
    else
        local previous = _G["PetActionButton" .. i - 1]
        button:SetPoint("LEFT", previous, "RIGHT", cfg.button.space, 0)
    end
end

RegisterStateDriver(bar, "visibility", "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists] hide; [@pet,exists,nomounted] show; hide")

--create the mouseover functionality
if cfg.fader_mouseover then
    E:ButtonBarFader(bar, bar.buttonList, cfg.fader_mouseover.fadeIn, cfg.fader_mouseover.fadeOut)
end

--create the combat fader
if cfg.fader_combat then
    E:CombatFrameFader(bar, cfg.fader_combat.fadeIn, cfg.fader_combat.fadeOut)
end
