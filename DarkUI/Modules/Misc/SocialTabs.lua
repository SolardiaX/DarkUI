local E, C, L = select(2, ...):unpack()

if not C.misc.socialtabs.enable then return end

----------------------------------------------------------------------------------------
--	SoicalTabs
----------------------------------------------------------------------------------------

local cfg = C.misc.socialtabs

local playerLevel = UnitLevel("player")
local playerFacion = UnitFactionGroup("player")

local hookAtLoad = { "FriendsFrame", "PVEFrame", "RaidBrowserFrame" }

SocialTabs = CreateFrame("Frame")

local VisibleFrames = {}
local TabRefArray = {}

local function HideOtherFrames(fname)
    -- keep other frames open if CTRL modifier is pressed
    if IsControlKeyDown() then return end
    for k, v in pairs(VisibleFrames) do
        if ((k ~= fname) and (v)) then
            HideUIPanel(_G[k])
        end
    end
end

local function SetTabCheckedState(fname, isChecked)
    for k, v in pairs(TabRefArray) do
        if (v) then TabRefArray[k][fname]:SetChecked(isChecked) end
    end
end

local function SetTabEnabledState(fname, isEnabled)
    for k, v in pairs(TabRefArray) do
        if (v) then
            if isEnabled then
                TabRefArray[k][fname]:Enable()
                SetDesaturation(TabRefArray[k][fname]:GetNormalTexture(), false)
                TabRefArray[k][fname]:SetAlpha(1)
            else
                TabRefArray[k][fname]:Disable()
                TabRefArray[k][fname]:SetAlpha(0.5)
                SetDesaturation(TabRefArray[k][fname]:GetNormalTexture(), true)
            end
        end
    end
end

local function SetTabVisibleState(fname, isVisible)
    for k, v in pairs(TabRefArray) do
        if (v) then
            if isVisible then
                TabRefArray[k][fname]:Show()
            else
                TabRefArray[k][fname]:Hide()
            end
        end
    end
end

local function UpdateGuildTabIcons()
    -- guild button texture update
    for k, v in pairs(TabRefArray) do
        if (v['GuildFrame']) then
            if GetGuildTabardFiles() then
                v['GuildFrame']:SetNormalTexture("Interface\\SpellBook\\GuildSpellbooktabBG")
                v['GuildFrame'].TabardEmblem:Show()
                v['GuildFrame'].TabardIconFrame:Show()
                SetLargeGuildTabardTextures("player", v['GuildFrame'].TabardEmblem, v['GuildFrame']:GetNormalTexture(), v['GuildFrame'].TabardIconFrame)
            else
                v['GuildFrame']:SetNormalTexture("Interface\\GuildFrame\\GuildLogo-NoLogo")
            end
        end
    end
end

local function CheckTabCriteria(checktype)
    if (checktype == 'guild') then
        -- player_guild_update

        -- guild button update
        SetTabEnabledState("GuildFrame", IsInGuild())
        SetTabVisibleState("LookingForGuildFrame", (cfg.lfguild or (not IsInGuild())))
        UpdateGuildTabIcons()
    elseif (checktype == "faction") then
        -- panda destiny!1 we need to check if factionGroup changed
        local newFaction = UnitFactionGroup("player")
        if (newFaction ~= playerFacion) then
            playerFacion = newFaction

            if (playerFacion ~= "Neutral") then
                SetTabEnabledState("GuildFrame", IsInGuild())
                SetTabVisibleState("LookingForGuildFrame", (cfg.lfguild or (not IsInGuild())))
                SetTabEnabledState("PVEFrame", playerLevel >= SHOW_LFD_LEVEL)
                SetTabEnabledState("PVPUIFrame", playerLevel >= SHOW_PVP_LEVEL)
            end
        end
    elseif (checktype == 'level') then
        local newLevel = UnitLevel("player")

        if ((playerLevel < SHOW_LFD_LEVEL) and (newLevel >= SHOW_LFD_LEVEL)) then
            SetTabEnabledState("PVEFrame", true)
        end

        if ((playerLevel < SHOW_PVP_LEVEL) and (newLevel >= SHOW_PVP_LEVEL)) then
            SetTabEnabledState("PVPUIFrame", true)
        end
    end
end

local function Tab_OnClick(self)
    if (self.ToggleFrame == "GuildFrame") then
        GuildFrame_LoadUI()
    end

    if (self.ToggleFrame == "LookingForGuildFrame") then
        LookingForGuildFrame_LoadUI()
    end

    local frame = _G[self.ToggleFrame]

    if (frame:IsShown()) then
        HideUIPanel(frame)
    elseif (self.ToggleFrame == "PVEFrame") then
        ToggleLFDParentFrame()
    elseif (self.ToggleFrame == "FriendsFrame") then
        ToggleGuildFrame()
        ToggleFriendsFrame()
    else
        ShowUIPanel(frame)
    end
end

SocialTabs.createTab = function(pf, fname, prevtab)
    local pname = pf and pf:GetName() or "SocialTabs"
    local tframe = CreateFrame("CheckButton", pname .. '_st_' .. fname, pf, "SpellBookSkillLineTabTemplate")
    tframe:SkinCheckBox()
    tframe:Show()

    if prevtab then
        tframe:SetPoint("TOPLEFT", prevtab, "BOTTOMLEFT", 0, -15)
    else
        tframe:SetPoint("TOPLEFT", pf, "TOPRIGHT", 2, -35)
    end

    tframe:SetFrameStrata("LOW")
    tframe.ToggleFrame = fname
    tframe:SetScript("OnClick", Tab_OnClick)

    return tframe
end

-- Hook single frame to our system >:o
local function STHookFrame(fname)
    --print("STHookFrame:"..fname)
    if not cfg.hookpve and (fname == 'PVEFrame') then
        return
    end

    local frame = _G[fname]
    local prevtab
    local frametabs = {}

    -- Social tab
    frametabs['FriendsFrame'] = SocialTabs.createTab(frame, "FriendsFrame")
    frametabs['FriendsFrame'].tooltip = SOCIAL_BUTTON
    frametabs['FriendsFrame']:SetNormalTexture("Interface\\FriendsFrame\\Battlenet-Portrait")
    prevtab = frametabs['FriendsFrame']

    -- Guild tab
    frametabs['GuildFrame'] = SocialTabs.createTab(frame, "GuildFrame", prevtab)
    frametabs['GuildFrame'].tooltip = GUILD
    if GetGuildTabardFiles() then
        frametabs['GuildFrame']:SetNormalTexture("Interface\\SpellBook\\GuildSpellbooktabBG")
        frametabs['GuildFrame'].TabardEmblem:Show()
        frametabs['GuildFrame'].TabardIconFrame:Show()
        SetLargeGuildTabardTextures("player", frametabs['GuildFrame'].TabardEmblem, frametabs['GuildFrame']:GetNormalTexture(), frametabs['GuildFrame'].TabardIconFrame)
    else
        frametabs['GuildFrame']:SetNormalTexture("Interface\\GuildFrame\\GuildLogo-NoLogo")
    end
    prevtab = frametabs['GuildFrame']

    -- restricted to trial accounts and pandas
    if (IsTrialAccount() or (not IsInGuild()) or (playerFacion == "Neutral")) then
        frametabs['GuildFrame']:SetAlpha(0.5)
        SetDesaturation(frametabs['GuildFrame']:GetNormalTexture(), true)
        frametabs['GuildFrame']:Disable()
    end

    -- PvE tab
    if cfg.hookpve then
        frametabs['PVEFrame'] = SocialTabs.createTab(frame, "PVEFrame", prevtab)
        frametabs['PVEFrame'].tooltip = LOOKING_FOR_DUNGEON
        frametabs['PVEFrame']:SetNormalTexture("Interface\\LFGFrame\\UI-LFG-PORTRAIT")
        if ((playerLevel < SHOW_LFD_LEVEL) or (playerFacion == "Neutral")) then
            frametabs['PVEFrame']:SetAlpha(0.5)
            SetDesaturation(frametabs['PVEFrame']:GetNormalTexture(), true)
            frametabs['PVEFrame']:Disable()
        end
        prevtab = frametabs['PVEFrame']
    end

    -- Raid Browser tab
    frametabs['RaidBrowserFrame'] = SocialTabs.createTab(frame, "RaidBrowserFrame", prevtab)
    frametabs['RaidBrowserFrame'].tooltip = LOOKING_FOR_RAID
    frametabs['RaidBrowserFrame']:SetNormalTexture("Interface\\LFGFrame\\UI-LFR-PORTRAIT")
    prevtab = frametabs['RaidBrowserFrame']

    -- i think if panda neutral who should he see in raid browser? wtf, need to hide it
    if (playerFacion == "Neutral") then
        frametabs['RaidBrowserFrame']:SetAlpha(0.5)
        SetDesaturation(frametabs['RaidBrowserFrame']:GetNormalTexture(), true)
        frametabs['RaidBrowserFrame']:Disable()
    end

    -- LookingForGuild tab
    frametabs['LookingForGuildFrame'] = SocialTabs.createTab(frame, "LookingForGuildFrame", prevtab)
    frametabs['LookingForGuildFrame'].tooltip = LOOKINGFORGUILD
    frametabs['LookingForGuildFrame']:SetNormalTexture("Interface\\GuildFrame\\GuildLogo-NoLogo.blp")

    -- restricted to trial accounts
    if ((IsTrialAccount()) or (playerFacion == "Neutral")) then
        frametabs['LookingForGuildFrame']:SetAlpha(0.5)
        SetDesaturation(frametabs['LookingForGuildFrame']:GetNormalTexture(), true)
        frametabs['LookingForGuildFrame']:Disable()
    end
    if (IsInGuild() and (not cfg.lfguild)) then
        frametabs['LookingForGuildFrame']:Hide()
    end

    if not frame then return end

    -- set scale
    frame:SetScale(cfg.scale)

    if (fname == "RaidBrowserFrame") then
        LFRParentFrameSideTab1:SetPoint("TOPLEFT", LFRParentFrame, "TOPRIGHT", -3, -316)
    end

    TabRefArray[fname] = frametabs

    frame:HookScript("OnShow", function()
        HideOtherFrames(fname)
        VisibleFrames[fname] = true
        SetTabCheckedState(fname, true)
    end)

    frame:HookScript("OnHide", function()
        VisibleFrames[fname] = false
        SetTabCheckedState(fname, false)
    end)
end

-- ADDON_LOADED
local function InitSocialTabs()
    -- register events
    if (not IsTrialAccount()) then
        SocialTabs:RegisterEvent("PLAYER_GUILD_UPDATE")
    end
    -- panda thing
    SocialTabs:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT")
    -- even trial players need some levelup love
    SocialTabs:RegisterEvent("PLAYER_LEVEL_UP")

    -- hooking frames
    for i = 1, #hookAtLoad do
        STHookFrame(hookAtLoad[i])
    end
end

SocialTabs:SetScript("OnEvent", function(self, event, addon)
    if (event == 'ADDON_LOADED') then
        -- Init SocialTabs
        if (addon == "DarkUI") then
            InitSocialTabs()
            -- Hook Guild window
        elseif (addon == "Blizzard_GuildUI") then
            STHookFrame("GuildFrame")
            -- Hook LookingForGuild window
        elseif (addon == "Blizzard_LookingForGuildUI") then
            STHookFrame("LookingForGuildFrame")
        end
    elseif (event == 'PLAYER_GUILD_UPDATE') then
        CheckTabCriteria("guild")
    elseif (event == 'PLAYER_LEVEL_UP') then
        CheckTabCriteria("level")
    elseif (event == 'NEUTRAL_FACTION_SELECT_RESULT') then
        CheckTabCriteria("faction")
    end
end)

SocialTabs:RegisterEvent("ADDON_LOADED")