local E, C, L, DB = select(2, ...):unpack()

------------------------------------------------------------------------
-- Variables & CVar Initialization
------------------------------------------------------------------------

local module = E:Module("Variable")

local SetCVar = C_CVar.SetCVar
local SetCVarBitfield = SetCVarBitfield
local ToggleChatColorNamesByClassGroup = ToggleChatColorNamesByClassGroup
local hooksecurefunc = hooksecurefunc

------------------------------------------------------------------------
-- Disable tutorials / helptips
------------------------------------------------------------------------

local function disableTutorials()
    if TutorialFrameAlertButton then TutorialFrameAlertButton:Kill() end

    local function acknowledgeTips()
        if InCombatLockdown() then return end
        if HelpTip and HelpTip.framePool then
            for frame in HelpTip.framePool:EnumerateActive() do
                frame:Acknowledge()
            end
        end
    end

    acknowledgeTips()
    if HelpTip then hooksecurefunc(HelpTip, "Show", acknowledgeTips) end
end

------------------------------------------------------------------------
-- Conditional CVars (applied every login)
------------------------------------------------------------------------

-- Moved to respective modules:
-- chatStyle → Chat/ChatFrame.lua
-- showPartyBackground → Unitframe/Player.lua
-- multiBarRightVerticalLayout → Actionbar/Actionbar.lua
-- ShowClassColorInNameplate → Unitframe/Nameplate.lua
-- minimapTrackingShowAll → Map/Minimap.lua
-- C_Container sort → Bags/Core.lua

------------------------------------------------------------------------
-- First-time initialization (once per version per character)
------------------------------------------------------------------------

local function firstTimeSetup()
    SetCVar("screenshotQuality", 8)
    SetCVar("cameraDistanceMaxZoomFactor", 2.6)
    SetCVar("showTutorials", 0)
    SetCVar("UberTooltips", 1)
    SetCVar("removeChatDelay", 1)
    SetCVar("RotateMinimap", 0)
    SetCVar("autoQuestProgress", 1)
    SetCVar("scriptErrors", 1)
    SetCVar("taintLog", 0)
    SetCVar("buffDurations", 1)
    SetCVar("lossOfControl", 0)
    SetCVar("alwaysCompareItems", 1)
    SetCVar("autoSelfCast", 1)
    SetCVar("fstack_preferParentKeys", 0)

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
    if not DB:GetStats("inited", true) or DB:GetStats("version", true) ~= E.version then
        firstTimeSetup()
        DB:SetStats("version", E.version, true)

        if not DB:GetStats("inited", true) then StaticPopup_Show("INSTALLUI_CONFIRM") end
    end

    disableTutorials()

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
        DB:SetStats("inited", true, true)
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
SlashCmdList.RESETUI = function() StaticPopup_Show("RESETUI_CONFIRM") end
