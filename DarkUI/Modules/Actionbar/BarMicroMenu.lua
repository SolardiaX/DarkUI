local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable or not C.actionbar.bars.micromenu then return end

----------------------------------------------------------------------------------------
--	MicroMenu Bars (modified from ShestakUI)
----------------------------------------------------------------------------------------
local module = E:Module("Actionbar"):Sub("MicroMenu")

local _G = _G
local CreateFrame = CreateFrame
local RegisterStateDriver = RegisterStateDriver
local UpdateMicroButtonsParent = UpdateMicroButtonsParent
local unpack, tinsert, pairs = unpack, tinsert, pairs
local UIParent = _G.UIParent

local cfg = C.actionbar.bars.micromenu

local buttonList = { 
    "CharacterMicroButton",
    "SpellbookMicroButton",
    "TalentMicroButton",
    "AchievementMicroButton",
    "QuestLogMicroButton",
    "GuildMicroButton",
    "LFDMicroButton",
    "EJMicroButton",
    "CollectionsMicroButton",
    "StoreMicroButton",
    "MainMenuMicroButton",
    "HelpMicroButton",
}

local num = #buttonList

function module:OnInit()
    local bar = CreateFrame("Frame", "DarkUI_MicroMenuBarHolder", UIParent, "SecureHandlerStateTemplate")
    bar:SetWidth(num * cfg.button.size + (num - 1) * cfg.button.space)
    bar:SetHeight(cfg.button.size)
    bar:SetPoint(unpack(cfg.pos))
    bar:SetScale(cfg.scale)
    bar.buttonList = {}

    -- UpdateMicroButtonsParent(bar)

    --move the buttons into position and reparent them
    local previous
    for i, b in pairs(buttonList) do
        local button = _G[b]

        button:CreateBackdrop()
        button.backdrop:CreateShadow()

        button:SetParent(bar)
        button.SetParent = E.Dummy

        button:ClearAllPoints()

        if i == 1 then
            button:SetPoint("LEFT", bar, "LEFT", 0, 0)
        else
            button:SetPoint("LEFT", previous, "RIGHT", cfg.button.space + 4, 0)
        end

        tinsert(bar.buttonList, button) --add the button object to the list
        previous = button
    end

    --show/hide the frame on a given state driver
    RegisterStateDriver(bar, "visibility", "[petbattle] hide; show")

    --create the mouseover functionality
    if cfg.fader_mouseover then
        E:ButtonBarFader(bar, bar.buttonList, cfg.fader_mouseover.fadeIn, cfg.fader_mouseover.fadeOut)
    end

    HelpOpenWebTicketButton:Kill()
    MainMenuMicroButton.MainMenuBarPerformanceBar:Kill()
    MainMenuMicroButton:SetScript("OnUpdate", nil)
end
