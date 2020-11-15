local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable or not C.actionbar.bars.micromenu then return end

----------------------------------------------------------------------------------------
--	MicroMenu Bars (modified from ShestakUI)
----------------------------------------------------------------------------------------
local _G = _G
local CreateFrame = CreateFrame
local RegisterStateDriver = RegisterStateDriver
local unpack, tinsert, pairs = unpack, tinsert, pairs
local UIParent = _G.UIParent

local cfg = C.actionbar.bars.micromenu

local buttonList = { "CharacterMicroButton",
                     "SpellbookMicroButton",
                     "TalentMicroButton",
                     "AchievementMicroButton",
                     "QuestLogMicroButton",
                     "GuildMicroButton",
                     "LFDMicroButton",
                     "CollectionsMicroButton",
                     "EJMicroButton",
                     "StoreMicroButton",
                     "HelpMicroButton",
                     "MainMenuMicroButton", }

local num = #buttonList

local bar = CreateFrame("Frame", "DarkUI_MicroMenuBarHolder", UIParent, "SecureHandlerStateTemplate")
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

--create the mouseover functionality
if cfg.fader_mouseover then
    E:ButtonBarFader(bar, bar.buttonList, cfg.fader_mouseover.fadeIn, cfg.fader_mouseover.fadeOut)
end
