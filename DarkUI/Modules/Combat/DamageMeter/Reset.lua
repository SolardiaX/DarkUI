local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- DamageMeter Reset (auto / quick combat session reset)
------------------------------------------------------------------------

local module = E:Module("Combat"):Sub("DamageMeter")

local C_DamageMeter = C_DamageMeter
local C_Timer_After = C_Timer.After
local IsInInstance = IsInInstance
local StaticPopup_Show = StaticPopup_Show
local StaticPopup_Hide = StaticPopup_Hide
local IsControlKeyDown = IsControlKeyDown

local POPUP_TEXT = L.COMBAT_DMETER_POPUP_TEXT
local POPUP_BTN_YES = L.COMBAT_DMETER_POPUP_BTN_YES
local POPUP_BTN_NO = L.COMBAT_DMETER_POPUP_BTN_NO
local MSG_PREFIX = L.COMBAT_DMETER_MSG_PREFIX
local MSG_RESET = L.COMBAT_DMETER_MSG_RESET
local SRC_UNKNOWN = L.COMBAT_DMETER_SRC_UNKNOWN
local SRC_AUTO = L.COMBAT_DMETER_SRC_AUTO
local SRC_ENTER_INST = L.COMBAT_DMETER_SRC_ENTER_INST
local SRC_QUICK = L.COMBAT_DMETER_SRC_QUICK
local SRC_MPLUS = L.COMBAT_DMETER_SRC_MPLUS
local SRC_BOSS = L.COMBAT_DMETER_SRC_BOSS
local SRC_COMBAT = L.COMBAT_DMETER_SRC_COMBAT

local cfg

local clickHookCache = setmetatable({}, { __mode = "k" })
local eventFrame

------------------------------------------------------------------------
-- Reset Logic
------------------------------------------------------------------------

local function printMsg(msg)
    if cfg.resetNotice then
        print(MSG_PREFIX .. msg)
    end
end

local function execReset(source)
    if not (C_DamageMeter and C_DamageMeter.ResetAllCombatSessions) then
        if _G.DamageMeter and _G.DamageMeter.ResetAllCombatSessions then
            _G.DamageMeter:ResetAllCombatSessions()
            printMsg(string.format(MSG_RESET, source or SRC_UNKNOWN))
        end
        return
    end
    StaticPopup_Hide("DARKUI_DMETER_RESET_CONFIRM")
    local success = pcall(C_DamageMeter.ResetAllCombatSessions)
    if success then
        printMsg(string.format(MSG_RESET, source or SRC_AUTO))
    end
end

local function scheduleReset(source)
    C_Timer_After(0.5, function()
        execReset(source)
    end)
end

------------------------------------------------------------------------
-- Quick Reset Click Hook
------------------------------------------------------------------------

local function onMeterClick(self, button)
    if cfg.quickReset and button == "LeftButton" and IsControlKeyDown() then
        execReset(SRC_QUICK)
    end
end

local function installClickHooks()
    module:ForEachWindow(function(window)
        if not clickHookCache[window] then
            window:EnableMouse(true)
            window:HookScript("OnMouseUp", onMeterClick)
            clickHookCache[window] = true
        end
    end)
end

------------------------------------------------------------------------
-- Events
------------------------------------------------------------------------

local function onEvent(self, event, ...)
    local mode = cfg.resetMode
    if event == "PLAYER_ENTERING_WORLD" then
        local isLogin, isReload = ...
        if isLogin or isReload then
            return
        end
        local inInstance, instanceType = IsInInstance()
        if inInstance and (instanceType == "party" or instanceType == "raid") then
            if mode == "smart" then
                StaticPopup_Show("DARKUI_DMETER_RESET_CONFIRM")
            elseif mode == "instance" then
                scheduleReset(SRC_ENTER_INST)
            end
        end
    elseif event == "CHALLENGE_MODE_START" then
        if mode == "smart" or mode == "mplus" then
            scheduleReset(SRC_MPLUS)
        end
    elseif event == "ENCOUNTER_START" then
        if mode == "boss" then
            scheduleReset(SRC_BOSS)
        end
    elseif event == "PLAYER_REGEN_DISABLED" then
        if mode == "combat" then
            scheduleReset(SRC_COMBAT)
        end
    end
end

------------------------------------------------------------------------
-- Reset Module
------------------------------------------------------------------------

module.Reset = {}

module.Reset.ExecReset = execReset

function module.Reset:Init()
    cfg = module.cfg

    StaticPopupDialogs["DARKUI_DMETER_RESET_CONFIRM"] = {
        text = POPUP_TEXT,
        button1 = POPUP_BTN_YES,
        button2 = POPUP_BTN_NO,
        OnAccept = function()
            execReset(SRC_ENTER_INST)
        end,
        OnShow = function(self)
            self:ClearAllPoints()
            self:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
        end,
        timeout = 60,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    if not C_AddOns.IsAddOnLoaded("Blizzard_DamageMeter") then
        return
    end

    installClickHooks()

    if not eventFrame then
        eventFrame = CreateFrame("Frame")
        module.Reset.eventFrame = eventFrame
    end

    local mode = cfg.resetMode
    eventFrame:UnregisterAllEvents()
    if mode == "never" then
        return
    end

    if mode == "smart" or mode == "instance" then
        eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    end
    if mode == "smart" or mode == "mplus" then
        eventFrame:RegisterEvent("CHALLENGE_MODE_START")
    end
    if mode == "boss" then
        eventFrame:RegisterEvent("ENCOUNTER_START")
    end
    if mode == "combat" then
        eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    end

    eventFrame:SetScript("OnEvent", onEvent)
end
