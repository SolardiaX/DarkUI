local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable then return end

----------------------------------------------------------------------------------------
--	MultiBar (modified from ShestakUI)
----------------------------------------------------------------------------------------

local _G = _G
local CreateFrame = CreateFrame
local RegisterStateDriver = RegisterStateDriver
local unpack = unpack
local UIParent = _G.UIParent
local num = NUM_ACTIONBAR_BUTTONS

local function createBar(index)
    local cfg = C.actionbar.bars["bar" .. index]

    local bar = CreateFrame("Frame", "DarkUI_ActionBar" .. index, UIParent, "SecureHandlerStateTemplate")
    bar:SetHeight(cfg.button.size)
    bar:SetWidth(num * cfg.button.size + (num - 1) * cfg.button.space)
    bar:SetPoint(unpack(cfg.pos))
    bar:SetFrameStrata("MEDIUM")
    bar.buttonList = {}

    -- _G["MultiBar"..(index-1)]:SetShown(true)
    _G["MultiBar"..(index-1)]:SetParent(bar)
    _G["MultiBar"..(index-1)]:EnableMouse(false)
    _G["MultiBar"..(index-1)].QuickKeybindGlow:SetTexture("")

    for i = 1, num do
        local button = _G["MultiBar"..(index-1).."Button"..i]
        tinsert(bar.buttonList, button)

        button:SetSize(cfg.button.size, cfg.button.size)
        button:ClearAllPoints()
        button:SetAttribute("showgrid", 1)

        if i == 1 then
            button:SetPoint("BOTTOMLEFT", bar, 3, 0)
        else
            local previous = _G["MultiBar"..(index-1).."Button"..i-1]
            button:SetPoint("LEFT", previous, "RIGHT", cfg.button.space, 0)
        end
    end

    bar.frameVisibility = "[vehicleui] hide; show"
    RegisterStateDriver(bar, "visibility", bar.frameVisibility)

    --create the mouseover functionality
    if cfg.fader_mouseover then
        E:ButtonBarFader(bar, bar.buttonList, cfg.fader_mouseover.fadeIn, cfg.fader_mouseover.fadeOut)
    end

    --create the combat fader
    if cfg.fader_combat then
        E:CombatFrameFader(bar, cfg.fader_combat.fadeIn, cfg.fader_combat.fadeOut)
    end
end

local host = CreateFrame("Frame")
host:RegisterEvent("PLAYER_ENTERING_WORLD")
host:SetScript("OnEvent", function()
    createBar(6)
    createBar(7)
    createBar(8)
end)