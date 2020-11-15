local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable and not C.actionbar.bars.bags.enable then return end

----------------------------------------------------------------------------------------
--	PetActionBar (modified from ShestakUI)
----------------------------------------------------------------------------------------

local _G = _G
local CreateFrame = CreateFrame
local RegisterStateDriver = RegisterStateDriver
local unpack, tinsert = unpack, tinsert
local UIParent = _G.UIParent

local cfg = C.actionbar.bars.bags

local buttonList = { "MainMenuBarBackpackButton",
                     "CharacterBag0Slot",
                     "CharacterBag1Slot",
                     "CharacterBag2Slot",
                     "CharacterBag3Slot", }

local num = #buttonList

local bar = CreateFrame("Frame", "DarkUI_BagsHolder", UIParent, "SecureHandlerStateTemplate")
bar:SetWidth(num * cfg.button.size + (num - 1) * cfg.button.space)
bar:SetHeight(cfg.button.size)
bar:SetPoint(unpack(cfg.pos))
bar:SetScale(cfg.scale)
bar.buttonList = {}

--move the buttons into position and reparent them
local previous
for i, b in pairs(buttonList) do
    local button = _G[b]
    button:SetParent(bar)
    button.SetParent = E.dummy
    tinsert(bar.buttonList, button) --add the button object to the list

    button:SetSize(cfg.button.size, cfg.button.size)
    button:ClearAllPoints()

    if i == 1 then
        button:SetPoint("LEFT", bar, "LEFT", 0, 0)
    else
        button:SetPoint("LEFT", previous, "RIGHT", cfg.button.space, 0)
    end

    previous = button
end


--show/hide the frame on a given state driver
RegisterStateDriver(bar, "visibility", "[petbattle] hide; show")

if cfg.fader_mouseover then
    E:ButtonBarFader(bar, bar.buttonList, cfg.fader_mouseover.fadeIn, cfg.fader_mouseover.fadeOut)
end