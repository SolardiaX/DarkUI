local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
--  Variable of DarkUI
----------------------------------------------------------------------------------------
local module = E:Module("Variable")

local _G = _G
local SetCVar = SetCVar
local SetCVarBitfield = SetCVarBitfield
local InCombatLockdown = InCombatLockdown
local StaticPopup_Show = StaticPopup_Show
local ToggleChatColorNamesByClassGroup = ToggleChatColorNamesByClassGroup
local hooksecurefunc = hooksecurefunc


local function disableTutorial()
    TutorialFrameAlertButton:Kill()
    local function AcknowledgeTips()
        if InCombatLockdown() then return end
        for frame in _G.HelpTip.framePool:EnumerateActive() do
            frame:Acknowledge()
        end
    end
    AcknowledgeTips()
    hooksecurefunc(_G.HelpTip, "Show", AcknowledgeTips)
end

local function applyCVar()
    if C.chat.enable then
        SetCVar("chatStyle", "im")
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

    if C.combat.combattext.enable then
        if C.combat.combattext.incoming then
            SetCVar("enableFloatingCombatText", 1)
        else
            SetCVar("enableFloatingCombatText", 0)
        end
    end
end

module:RegisterEvent("ADDON_LOADED", function(self, event, name)
    if name ~= E.addonName then return end

    self:UnregisterEvent("ADDON_LOADED")

    if SavedStats == nil then SavedStats = { version = E.version } end
    if SavedStats.version ~= E.version then SavedStats.version = E.version end
    
    if SavedStatsPerChar == nil then SavedStatsPerChar = {} end

    if not SavedStatsPerChar.inited or SavedStatsPerChar.version ~= E.version then
        local cfgScale = C.general.uiScale

        if cfgScale > 1.28 then cfgScale = 1.28 end

        SetCVar("screenshotQuality", 8)
        SetCVar("cameraDistanceMaxZoomFactor", 2.6)
        SetCVar("showTutorials", 0)
        SetCVar("gameTip", "0")
        SetCVar("UberTooltips", 1)
        SetCVar("chatMouseScroll", 1)
        SetCVar("removeChatDelay", 1)
        SetCVar("WholeChatWindowClickable", 0)
        SetCVar("WhisperMode", "inline")
        SetCVar("colorblindMode", 0)
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
        
        -- force use keyUp to trigger actionbar buttion
        -- SetCVar("ActionButtonUseKeyDown", 0)
        -- Hide blizz options
        SetCVar("multiBarRightVerticalLayout", 0)

        SetCVar("useUiScale", 1)
        -- Set our uiScale
        if tonumber(GetCVar("uiScale")) ~= tonumber(cfgScale) then SetCVar("uiScale", cfgScale) end
        if cfgScale then UIParent:SetScale(cfgScale) end

        TutorialFrameAlertButton:Kill()
        
        SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME, true)
        SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PET_JOURNAL, true)
        SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_BUILDING, true)

        -- Enable classcolor automatically on login and on each character without doing /configure each time
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

        -- Set to default layout of Blizzard Edit Mode
        -- C_EditMode.SetActiveLayout(1)

        SavedStatsPerChar.version = E.version

        if not SavedStatsPerChar.inited then
            StaticPopup_Show("INSTALLUI_CONFIRM")
        end
    end

    disableTutorial()
    applyCVar()

    print("|cffffff00" .. L.WELCOME_LINE .. E.version .. " " .. E.locale .. ", " .. E.myName .. ".|r")
end)

StaticPopupDialogs["INSTALLUI_CONFIRM"] = {
    text         = L.POPUP_INSTALLUI,
    button1      = ACCEPT,
    button2      = CANCEL,
    OnAccept     = function() SavedStatsPerChar.inited = true; ReloadUI(); end,
    whileDead    = 1,
    timeout      = 0,
    hideOnEscape = 1,
}

StaticPopupDialogs["RESETUI_CONFIRM"] = {
    text         = L.POPUP_RESETUI,
    button1      = ACCEPT,
    button2      = CANCEL,
    OnAccept     = function() SavedStats = nil; SavedStatsPerChar = nil; SavedOptions = nil; SavedOptionsPerChar = nil; ReloadUI(); end,
    whileDead    = 1,
    timeout      = 0,
    hideOnEscape = 1,
}

SLASH_RESETUI1 = "/resetui"
SlashCmdList.RESETUI = function() StaticPopup_Show("RESETUI_CONFIRM") end
