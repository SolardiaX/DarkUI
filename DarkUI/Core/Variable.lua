local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Variables & CVar Initialization
------------------------------------------------------------------------

local module = E:Module("Variable")

local SetCVar = SetCVar
local SetCVarBitfield = SetCVarBitfield
local InCombatLockdown = InCombatLockdown
local ToggleChatColorNamesByClassGroup = ToggleChatColorNamesByClassGroup
local hooksecurefunc = hooksecurefunc

------------------------------------------------------------------------
-- Disable tutorials / helptips
------------------------------------------------------------------------

local function disableTutorials()
    if TutorialFrameAlertButton then
        TutorialFrameAlertButton:Kill()
    end

    local function acknowledgeTips()
        if InCombatLockdown() then
            return
        end
        if HelpTip and HelpTip.framePool then
            for frame in HelpTip.framePool:EnumerateActive() do
                frame:Acknowledge()
            end
        end
    end

    acknowledgeTips()
    if HelpTip then
        hooksecurefunc(HelpTip, "Show", acknowledgeTips)
    end
end

------------------------------------------------------------------------
-- Conditional CVars (applied every login)
------------------------------------------------------------------------

local function applyCVars()
    if C.chat.enable then
        SetCVar("chatStyle", "classic")
    end

    if C.unitframe.enable then
        SetCVar("showPartyBackground", 0)
    end

    if C.actionbar.bars.enable then
        if not InCombatLockdown() then
            SetCVar("multiBarRightVerticalLayout", 0)
        end
    end

    if C.nameplate.enable then
        SetCVar("ShowClassColorInNameplate", 1)
    end

    if C.map.minimap.enable then
        SetCVar("minimapTrackingShowAll", 1)
    end

    if C.actionbar.bars.enable and C.actionbar.bars.bags.enable then
        C_Container.SetSortBagsRightToLeft(true)
        C_Container.SetInsertItemsLeftToRight(false)
    end
end

------------------------------------------------------------------------
-- First-time initialization (once per version per character)
------------------------------------------------------------------------

local function firstTimeSetup()
    SetCVar("screenshotQuality", 8)
    SetCVar("cameraDistanceMaxZoomFactor", 2.6)
    SetCVar("showTutorials", 0)
    SetCVar("UberTooltips", 1)
    SetCVar("chatMouseScroll", 1)
    SetCVar("removeChatDelay", 1)
    SetCVar("lootUnderMouse", 1)
    SetCVar("autoLootDefault", 1)
    SetCVar("RotateMinimap", 0)
    SetCVar("autoQuestProgress", 1)
    SetCVar("scriptErrors", 1)
    SetCVar("taintLog", 0)
    SetCVar("buffDurations", 1)
    SetCVar("autoOpenLootHistory", 0)
    SetCVar("lossOfControl", 0)
    SetCVar("alwaysCompareItems", 1)
    SetCVar("autoSelfCast", 1)
    SetCVar("ShowClassColorInNameplate", 1)
    SetCVar("threatWarning", 3)
    SetCVar("lockActionBars", 1)
    SetCVar("countdownForCooldowns", 0)
    SetCVar("alwaysShowActionBars", 1)
    SetCVar("fstack_preferParentKeys", 0)

    SetCVar("nameplateShowSelf", 0)
    SetCVar("nameplateResourceOnTarget", 0)
    SetCVar("nameplateMotion", 1)
    SetCVar("nameplateShowAll", 1)
    SetCVar("nameplateShowEnemies", 1)
    SetCVar("multiBarRightVerticalLayout", 0)

    SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME, true)
    SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PET_JOURNAL, true)

    ToggleChatColorNamesByClassGroup(true, "SAY")
    ToggleChatColorNamesByClassGroup(true, "EMOTE")
    ToggleChatColorNamesByClassGroup(true, "YELL")
    ToggleChatColorNamesByClassGroup(true, "GUILD")
    ToggleChatColorNamesByClassGroup(true, "OFFICER")
    ToggleChatColorNamesByClassGroup(true, "GUILD_ACHIEVEMENT")
    ToggleChatColorNamesByClassGroup(true, "ACHIEVEMENT")
    ToggleChatColorNamesByClassGroup(true, "WHISPER")
    ToggleChatColorNamesByClassGroup(true, "PARTY")
    ToggleChatColorNamesByClassGroup(true, "PARTY_LEADER")
    ToggleChatColorNamesByClassGroup(true, "RAID")
    ToggleChatColorNamesByClassGroup(true, "RAID_LEADER")
    ToggleChatColorNamesByClassGroup(true, "RAID_WARNING")
    ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT")
    ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT_LEADER")
    ToggleChatColorNamesByClassGroup(true, "CHANNEL1")
    ToggleChatColorNamesByClassGroup(true, "CHANNEL2")
    ToggleChatColorNamesByClassGroup(true, "CHANNEL3")
    ToggleChatColorNamesByClassGroup(true, "CHANNEL4")
    ToggleChatColorNamesByClassGroup(true, "CHANNEL5")
end

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not SavedStatsPerChar.inited or SavedStatsPerChar.version ~= E.version then
        firstTimeSetup()
        SavedStatsPerChar.version = E.version

        if not SavedStatsPerChar.inited then
            StaticPopup_Show("INSTALLUI_CONFIRM")
        end
    end

    disableTutorials()
    applyCVars()

    print("|cffffff00" .. L.WELCOME_LINE .. E.version .. " " .. E.locale .. ", " .. E.myName .. ".|r")
end

------------------------------------------------------------------------
-- Static Popups
------------------------------------------------------------------------

StaticPopupDialogs["INSTALLUI_CONFIRM"] = {
    text = L.POPUP_INSTALLUI,
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function()
        SavedStatsPerChar.inited = true
        ReloadUI()
    end,
    whileDead = true,
    timeout = 0,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["RESETUI_CONFIRM"] = {
    text = L.POPUP_RESETUI,
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function()
        SavedConfig = nil
        SavedConfigPerChar = nil
        SavedStats = nil
        SavedStatsPerChar = nil
        ReloadUI()
    end,
    whileDead = true,
    timeout = 0,
    hideOnEscape = true,
    preferredIndex = 3,
}

SLASH_RESETUI1 = "/resetui"
SlashCmdList.RESETUI = function()
    StaticPopup_Show("RESETUI_CONFIRM")
end
