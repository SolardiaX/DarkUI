local E, C, L = select(2, ...):unpack()

if not C.tooltip.enable then return end

----------------------------------------------------------------------------------------
--  Based on aTooltip(by ALZA)
----------------------------------------------------------------------------------------

local _G = _G
local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded
local UnitFactionGroup = UnitFactionGroup
local UnitIsAFK, UnitIsDND, UnitSex = UnitIsAFK, UnitIsDND, UnitSex
local InCombatLockdown, IsShiftKeyDown, GetMouseFocus = InCombatLockdown, IsShiftKeyDown, GetMouseFocus
local GetCreatureDifficultyColor, UnitCreatureType, UnitClassification = GetCreatureDifficultyColor, UnitCreatureType, UnitClassification
local UnitIsBattlePetCompanion = UnitIsBattlePetCompanion
local UnitIsPlayer, UnitName, UnitPVPName, UnitClass, UnitRace, UnitLevel = UnitIsPlayer, UnitName, UnitPVPName, UnitClass, UnitRace, UnitLevel
local GetRaidTargetIndex, GetGuildInfo = GetRaidTargetIndex, GetGuildInfo
local GetNumSubgroupMembers, GetNumGroupMembers = GetNumSubgroupMembers, GetNumGroupMembers
local UnitIsUnit, UnitIsTapDenied, UnitIsDead, UnitReaction = UnitIsUnit, UnitIsTapDenied, UnitIsDead, UnitReaction
local UnitHealth, UnitHealthMax = UnitHealth, UnitHealthMax
local UnitIsInMyGuild, UnitExists = UnitIsInMyGuild, UnitExists
local UnitIsEnemy, UnitIsFriend = UnitIsEnemy, UnitIsFriend
local UnitPower, UnitPowerType, UnitPowerMax = UnitPower, UnitPowerType, UnitPowerMax
local GetCVar = GetCVar
local select, unpack, wipe = select, unpack, wipe
local hooksecurefunc = hooksecurefunc
local LEVEL, FACTION_HORDE, FACTION_ALLIANCE, UNKNOWN, RANK = LEVEL, FACTION_HORDE, FACTION_ALLIANCE, UNKNOWN, RANK
local RAID_CLASS_COLORS, CUSTOM_CLASS_COLORS = RAID_CLASS_COLORS, CUSTOM_CLASS_COLORS
local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE
local LOCALIZED_CLASS_NAMES_FEMALE = LOCALIZED_CLASS_NAMES_FEMALE
local ENCOUNTER_JOURNAL_ENCOUNTER = ENCOUNTER_JOURNAL_ENCOUNTER
local FRIENDS_LIST_REALM = FRIENDS_LIST_REALM
local STATUS_TEXT_TARGET, UNIT_YOU = STATUS_TEXT_TARGET, UNIT_YOU
local UIParent = UIParent
local GameTooltip = GameTooltip
local GameTooltipText = GameTooltipText
local GameTooltipTextSmall = GameTooltipTextSmall
local GameTooltipHeaderText = GameTooltipHeaderText
local GameTooltipStatusBar = GameTooltipStatusBar

local cfg = C.tooltip

local StoryTooltip = QuestScrollFrame.StoryTooltip
StoryTooltip:SetFrameLevel(4)

local tooltips = {
    -- Tooltip
    "ChatMenu",
    "EmoteMenu",
    "LanguageMenu",
    "VoiceMacroMenu",
    "GameTooltip",
    "EmbeddedItemTooltip",
    "ItemRefTooltip",
    "AutoCompleteBox",
    "FriendsTooltip",
    "GeneralDockManagerOverflowButtonList",
    "ReputationParagonTooltip",
    "NamePlateTooltip",
    "QueueStatusFrame",
    "FloatingGarrisonFollowerTooltip",
    "FloatingGarrisonFollowerAbilityTooltip",
    "FloatingGarrisonMissionTooltip",
    "GarrisonFollowerAbilityTooltip",
    "GarrisonFollowerTooltip",
    "FloatingGarrisonShipyardFollowerTooltip",
    "GarrisonShipyardFollowerTooltip",
    "BattlePetTooltip",
    "PetBattlePrimaryAbilityTooltip",
    "PetBattlePrimaryUnitTooltip",
    "FloatingBattlePetTooltip",
    "FloatingPetBattleAbilityTooltip",
    "IMECandidatesFrame",
    -- Special
    QuestScrollFrame.StoryTooltip,
    QuestScrollFrame.WarCampaignTooltip,
    -- Addons
    "AtlasLootTooltip",
    "QuestGuru_QuestWatchTooltip",
    "LibDBIconTooltip"
}

local shoppingtips = {
    "ShoppingTooltip1",
    "ShoppingTooltip2",
    "ShoppingTooltip3",
    "ItemRefShoppingTooltip1",
    "ItemRefShoppingTooltip2",
    "ItemRefShoppingTooltip3",
    "WorldMapCompareTooltip1",
    "WorldMapCompareTooltip2",
    "WorldMapCompareTooltip3"
}

local backdropColor = C.media.backdrop_color -- { 0.08, 0.08, 0.1, 0.92 }
local backdropBorderColor = C.media.border_color -- { 0, 0, 0, 1 }

local backdrop = {
    bgFile   = C.media.texture.blank,
    edgeFile = C.media.texture.shadow,
    tile     = false,
    tileEdge = true,
    tileSize = 16,
    edgeSize = 2,
    insets   = { left = 2, right = 2, top = 2, bottom = 2 },
}

local styler = CreateFrame("Frame", nil, UIParent)
styler.rTips = {}

local function __GetBackdrop() return backdrop end
local function __GetBackdropColor() return unpack(backdropColor) end
local function __GetBackdropBorderColor() return unpack(backdropBorderColor)end

-- style from FreebTip
local function hook(f)
    f:HookScript("OnShow", function(tt)
        if tt:IsForbidden() then return end

        if not tt.styled then
            if tt.NineSlice then tt.NineSlice:SetAlpha(0) end
		    if tt.SetBackdrop then tt:SetBackdrop(nil) end
            if tt.BackdropFrame then tt.BackdropFrame:SetBackdrop(nil) end
            
    		tt:DisableDrawLayer("BACKGROUND")
            
            tt.bg = CreateFrame("Frame", nil, tt, "BackdropTemplate")
            tt.bg:SetPoint("TOPLEFT")
            tt.bg:SetPoint("BOTTOMRIGHT")
            tt.bg:SetFrameLevel(tt:GetFrameLevel())
            tt.bg:SetTemplate("Blur")
            tt.bg:SetBackdropBorderColor(unpack(backdropBorderColor))

            tt.GetBackdrop = __GetBackdrop
			tt.GetBackdropColor = __GetBackdropColor
			tt.GetBackdropBorderColor = __GetBackdropBorderColor

            tt.styled = true
        end

        local frameName = tt and tt:GetName()
        if not frameName then return end

        if tt.shopping and not tt.ftipFontSet then
            _G[frameName .. "TextLeft1"]:SetFontObject(GameTooltipTextSmall)
            _G[frameName .. "TextRight1"]:SetFontObject(GameTooltipText)
            _G[frameName .. "TextLeft2"]:SetFontObject(GameTooltipHeaderText)
            _G[frameName .. "TextRight2"]:SetFontObject(GameTooltipTextSmall)
            _G[frameName .. "TextLeft3"]:SetFontObject(GameTooltipTextSmall)
            _G[frameName .. "TextRight3"]:SetFontObject(GameTooltipTextSmall)

            tt.ftipFontSet = true
        end
    end)
end

styler:RegisterEvent("ADDON_LOADED")
styler:RegisterEvent("PLAYER_LOGIN")
styler:SetScript("OnEvent", function(self, event, addon)
    if IsAddOnLoaded("Aurora") then return end

    if event == "PLAYER_LOGIN" then
        for _, tip in ipairs(tooltips) do
            local tt = type(tip) == "table" and tip or _G[tip]
            if tt then hook(tt) end
        end
        for _, tip in ipairs(shoppingtips) do
            local tt = type(tip) == "table" and tip or _G[tip]
            if tt then
                tt.shopping = true
                hook(tt)
            end
        end
    elseif event == "ADDON_LOADED" and self.rTips[addon] then
        self.rTips[addon]()
        self.rTips[addon] = nil
    end
end)

local anchor = CreateFrame("Frame", "TooltipAnchor", UIParent)
anchor:SetSize(200, 40)
anchor:SetPoint(unpack(cfg.position))

-- Hide PVP text
PVP_ENABLED = ""

-- Statusbar
local function GameTooltip_HideStatusBar(self, name)
    local name = self:GetName() .. "StatusBar_" .. name
    local statusBar = _G[name]

    if statusBar then
        statusBar:Hide()
    end
end

local function GameTooltip_ShowStatusBar(self, name, min, max, value, text, r, g, b, a)
    self:AddLine(" ")
    local numLines = self:NumLines()
    local name = self:GetName() .. "StatusBar_" .. name
    local statusBar = _G[name]

    if not statusBar then
        statusBar = CreateFrame("StatusBar", name, self, "BackdropTemplate")

        statusBar:SetBackdrop({
                                  bgFile   = 'Interface\\Buttons\\WHITE8x8',
                                  edgeFile = 'Interface\\Buttons\\WHITE8x8',
                                  tiled    = false, edgeSize = 1, insets = { left = -1, right = -1, top = -1, bottom = -1 }
                              })
        statusBar:SetBackdropColor(0, 0, 0, 0.5)
        statusBar:SetBackdropBorderColor(0, 0, 0, 0.5)

        statusBar:SetStatusBarTexture(C.media.texture.status)
        statusBar.text = statusBar.text or statusBar:CreateFontString(name .. "Text", 'OVERLAY', 'Tooltip_Small')
        statusBar.text:SetFont(STATUS_TEXT_TARGET, 9, "THINOUTLINE")
        statusBar.text:SetAllPoints()
        statusBar.text:SetJustifyH('CENTER')
    end

    _G[name .. "Text"]:SetText(text and text or "")
    _G[name .. "Text"]:Show()
    statusBar:SetSize(128, 10)
    statusBar:SetStatusBarColor(r, g, b, a)
    statusBar:SetMinMaxValues(min, max)
    statusBar:SetValue(value)
    statusBar:ClearAllPoints()
    statusBar:SetPoint("LEFT", self:GetName() .. "TextLeft" .. numLines, "LEFT", 0, -4)
    statusBar:SetPoint("RIGHT", self, "RIGHT", -9, 0)
    statusBar:Show()

    self:SetMinimumWidth(140)
end

-- Raid icon
local ricon = GameTooltip:CreateTexture("GameTooltipRaidIcon", "OVERLAY")
ricon:SetHeight(18)
ricon:SetWidth(18)
ricon:SetPoint("BOTTOM", GameTooltip, "TOP", 0, 5)

GameTooltip:HookScript("OnHide", function() ricon:SetTexture(nil) end)
-- Add "Targeted By" line
local targetedList = {}
local ClassColors = {}
local token
for class, color in next, RAID_CLASS_COLORS do
    ClassColors[class] = ("|cff%.2x%.2x%.2x"):format(color.r * 255, color.g * 255, color.b * 255)
end

local function AddTargetedBy()
    local numParty, numRaid = GetNumSubgroupMembers(), GetNumGroupMembers()
    if numParty > 0 or numRaid > 0 then
        for i = 1, (numRaid > 0 and numRaid or numParty) do
            local unit = (numRaid > 0 and "raid" .. i or "party" .. i)
            if UnitIsUnit(unit .. "target", token) and not UnitIsUnit(unit, "player") then
                local _, class = UnitClass(unit)
                targetedList[#targetedList + 1] = ClassColors[class]
                targetedList[#targetedList + 1] = UnitName(unit)
                targetedList[#targetedList + 1] = "|r, "
            end
        end
        if #targetedList > 0 then
            targetedList[#targetedList] = nil
            GameTooltip:AddLine(" ", nil, nil, nil, 1)
            local line = _G["GameTooltipTextLeft" .. GameTooltip:NumLines()]
            if not line then return end
            line:SetFormattedText(L.TOOLTIP_WHO_TARGET .. " (|cffffffff%d|r): %s", (#targetedList + 1) / 3, table.concat(targetedList))
            wipe(targetedList)
        end
    end
end

----------------------------------------------------------------------------------------
--  Unit tooltip styling
----------------------------------------------------------------------------------------
function GameTooltip_UnitColor(unit)
    if not unit then return end
    local r, g, b

    if UnitIsPlayer(unit) then
        local _, class = UnitClass(unit)
        local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
        if color then
            r, g, b = color.r, color.g, color.b
        else
            r, g, b = 1, 1, 1
        end
    elseif UnitIsTapDenied(unit) or UnitIsDead(unit) then
        r, g, b = 0.6, 0.6, 0.6
    else
        local reaction = C.oUF_colors.reaction[UnitReaction(unit, "player")]
        if reaction then
            r, g, b = reaction[1], reaction[2], reaction[3]
        else
            r, g, b = 1, 1, 1
        end
    end

    return r, g, b
end

local function GameTooltipDefault(tooltip, parent)
    if cfg.cursor == true then
        tooltip:SetOwner(parent, "ANCHOR_CURSOR_RIGHT", 20, 20)
    else
        tooltip:SetOwner(parent, "ANCHOR_NONE")
        tooltip:ClearAllPoints()
        tooltip:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 0, 0)
        tooltip.default = 1
    end
end
hooksecurefunc("GameTooltip_SetDefaultAnchor", GameTooltipDefault)

if cfg.shift_modifer == true then
    GameTooltip:SetScript("OnShow", function(self)
        if IsShiftKeyDown() then
            self:Show()
        else
            if not HoverBind.enabled then
                self:Hide()
            end
        end
    end)
else
    if cfg.cursor == true then
        hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self, parent)
            if InCombatLockdown() and cfg.hide_combat and not IsShiftKeyDown() then
                self:Hide()
            else
                self:SetOwner(parent, "ANCHOR_CURSOR_RIGHT", 20, 20)
            end
        end)
    else
        hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self)
            if InCombatLockdown() and cfg.hide_combat and not IsShiftKeyDown() then
                self:Hide()
            else
                self:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 0, 0)
            end
        end)
    end
end

if cfg.health_value == true then
    GameTooltipStatusBar:SetScript("OnValueChanged", function(self, value)
        if not value then return end
        local min, max = self:GetMinMaxValues()
        if (value < min) or (value > max) then return end
        self:SetStatusBarColor(0, 1, 0)
        local _, unit = GameTooltip:GetUnit()
        if unit then
            min, max = UnitHealth(unit), UnitHealthMax(unit)
            if not self.text then
                self.text = self:CreateFontString(nil, "OVERLAY", "Tooltip_Med")
                self.text:SetPoint("CENTER", GameTooltipStatusBar, 0, 1.5)
            end
            self.text:Show()
            local hp = E:ShortValue(min) .. " / " .. E:ShortValue(max)
            self.text:SetText(hp)
        end
    end)
end

local OnTooltipSetUnit = function(self)
    local lines = self:NumLines()
    local unit = (select(2, self:GetUnit())) or (GetMouseFocus() and GetMouseFocus().GetAttribute and GetMouseFocus():GetAttribute("unit")) or (UnitExists("mouseover") and "mouseover") or nil

    if not unit then return end

    local name, realm = UnitName(unit)
    local race, englishRace = UnitRace(unit)
    local level = UnitLevel(unit)
    local levelColor = GetCreatureDifficultyColor(level)
    local classification = UnitClassification(unit)
    local creatureType = UnitCreatureType(unit)
    local _, faction = UnitFactionGroup(unit)
    local _, playerFaction = UnitFactionGroup("player")

    if level and level == -1 then
        if classification == "worldboss" then
            level = "|cffff0000|r" .. ENCOUNTER_JOURNAL_ENCOUNTER
        else
            level = "|cffff0000??|r"
        end
    end

    if classification == "rareelite" then classification = " R+"
    elseif classification == "rare" then classification = " R"
    elseif classification == "elite" then classification = "+"
    else classification = "" end

    if UnitPVPName(unit) and cfg.title then
        name = UnitPVPName(unit)
    end

    _G["GameTooltipTextLeft1"]:SetText(name)
    if realm and realm ~= "" and cfg.realm then
        self:AddLine(FRIENDS_LIST_REALM .. "|cffffffff" .. realm .. "|r")
    end

    if UnitIsPlayer(unit) then
        if UnitIsAFK(unit) then
            self:AppendText((" %s"):format("|cffE7E716" .. L.CHAT_AFK .. "|r"))
        elseif UnitIsDND(unit) then
            self:AppendText((" %s"):format("|cffFF0000" .. L.CHAT_DND .. "|r"))
        end
        if UnitIsPlayer(unit) and englishRace == "Pandaren" and faction ~= nil and faction ~= playerFaction then
            local hex = "cffff3333"
            if faction == "Alliance" then
                hex = "cff69ccf0"
            end
            self:AppendText((" [|%s%s|r]"):format(hex, faction:sub(1, 2)))
        end

        if GetGuildInfo(unit) then
            _G["GameTooltipTextLeft2"]:SetFormattedText("%s", GetGuildInfo(unit))
            if UnitIsInMyGuild(unit) then
                _G["GameTooltipTextLeft2"]:SetTextColor(1, 1, 0)
            else
                _G["GameTooltipTextLeft2"]:SetTextColor(0, 1, 1)
            end
        end

        local n = GetGuildInfo(unit) and 3 or 2
        -- thx TipTac for the fix above with color blind enabled
        if GetCVar("colorblindMode") == "1" then n = n + 1 end
        _G["GameTooltipTextLeft" .. n]:SetFormattedText("|cff%02x%02x%02x%s|r %s", levelColor.r * 255, levelColor.g * 255, levelColor.b * 255, level, race or UNKNOWN)

        for i = n + 1, lines do
            local line = _G["GameTooltipTextLeft" .. i]
            if not line or not line:GetText() then return end
            if line and line:GetText() and (line:GetText() == FACTION_HORDE or line:GetText() == FACTION_ALLIANCE) then
                line:SetText()
                break
            end
        end

        local unitRace = UnitRace(unit)
        local _, unitClass = UnitClass(unit)
        if UnitSex(unit) == 2 then
            unitClass = LOCALIZED_CLASS_NAMES_MALE[unitClass]
        else
            unitClass = LOCALIZED_CLASS_NAMES_FEMALE[unitClass]
        end

        local pattern = ""
        for i = 2, GameTooltip:NumLines() do
            if _G["GameTooltipTextLeft" .. i] and _G["GameTooltipTextLeft" .. i]:GetText() and _G["GameTooltipTextLeft" .. i]:GetText():find(unitRace) then
                pattern = pattern .. " %s %s (%s)"
                _G["GameTooltipTextLeft" .. i]:SetText((pattern):format(level, unitRace, unitClass):trim())
                break
            end
        end
    else
        for i = 2, lines do
            local line = _G["GameTooltipTextLeft" .. i]
            if not line or not line:GetText() or UnitIsBattlePetCompanion(unit) then return end
            if (level and line:GetText():find("^" .. LEVEL)) or (creatureType and line:GetText():find("^" .. creatureType)) then
                line:SetFormattedText("|cff%02x%02x%02x%s%s|r %s", levelColor.r * 255, levelColor.g * 255, levelColor.b * 255, level, classification, creatureType or "")
                break
            end
        end
    end

    if cfg.target == true and UnitExists(unit .. "target") then
        local r, g, b = GameTooltip_UnitColor(unit .. "target")
        local text = ""

        if UnitIsEnemy("player", unit .. "target") then
            r, g, b = unpack(C.oUF_colors.reaction[1])
        elseif not UnitIsFriend("player", unit .. "target") then
            r, g, b = unpack(C.oUF_colors.reaction[4])
        end

        if UnitName(unit .. "target") == UnitName("player") then
            text = "|cfffed100" .. STATUS_TEXT_TARGET .. ":|r " .. "|cffff0000> " .. UNIT_YOU .. " <|r"
        else
            text = "|cfffed100" .. STATUS_TEXT_TARGET .. ":|r " .. UnitName(unit .. "target")
        end

        self:AddLine(text, r, g, b)
    end

    if cfg.raid_icon == true then
        local raidIndex = GetRaidTargetIndex(unit)
        if raidIndex then
            ricon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. raidIndex)
        end
    end

    if cfg.who_targetting == true then
        token = unit
        AddTargetedBy()
    end

    --  guild rank
    if cfg.rank == true then
        if UnitIsPlayer(unit) then
            local guildName, guildRank = GetGuildInfo(unit)
            if guildName then
                self:AddLine(RANK .. ": |cffffffff" .. guildRank .. "|r")
            end
        end
    end

    -- statusbars
    GameTooltipStatusBar:Hide()

    local minv, maxv = UnitHealth(unit), UnitHealthMax(unit)

    if level and maxv > 0 then
        local hp = E:ShortValue(minv)
        local r, g, b = GameTooltip_UnitColor(unit)
        GameTooltip_ShowStatusBar(self, 'hp', 0, maxv, minv, minv > 0 and hp or "", r, g, b, 1)
    end

    if select(1, UnitPowerType(unit)) == 0 then
        local minv, maxv = UnitPower(unit), UnitPowerMax(unit)
        if cfg.show_power and maxv > 0 then
            local pp = E:ShortValue(minv)
            local color = PowerBarColor[UnitPowerType(unit)]
            GameTooltip_ShowStatusBar(self, 'power', 0, maxv, minv, minv > 0 and pp or "", color.r, color.g, color.b, 1)
        end
    end
end

GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)

local OnGameTooltipHide = function(self)
    GameTooltip_ClearMoney(self)
    GameTooltip_ClearStatusBars(self)

    GameTooltip_HideStatusBar(self, 'hp')
    GameTooltip_HideStatusBar(self, 'power')
end

GameTooltip:HookScript("OnTooltipCleared", OnGameTooltipHide)

----------------------------------------------------------------------------------------
--  Hide tooltips in combat for action bars, pet bar and stance bar
----------------------------------------------------------------------------------------
if cfg.hidebuttons == true then
    local CombatHideActionButtonsTooltip = function(self)
        if not IsShiftKeyDown() then
            self:Hide()
        end
    end

    hooksecurefunc(GameTooltip, "SetAction", CombatHideActionButtonsTooltip)
    hooksecurefunc(GameTooltip, "SetPetAction", CombatHideActionButtonsTooltip)
    hooksecurefunc(GameTooltip, "SetShapeshift", CombatHideActionButtonsTooltip)
end

----------------------------------------------------------------------------------------
--  Fix compare tooltips(by Blizzard)(../FrameXML/GameTooltip.lua)
----------------------------------------------------------------------------------------
hooksecurefunc("GameTooltip_AnchorComparisonTooltips", function(_, anchorFrame, shoppingTooltip1, shoppingTooltip2, _, secondaryItemShown)
    local point = shoppingTooltip1:GetPoint(2)
    if secondaryItemShown then
        if point == "TOP" then
            shoppingTooltip1:ClearAllPoints()
            shoppingTooltip2:ClearAllPoints()
            shoppingTooltip1:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT", 3, -10)
            shoppingTooltip2:SetPoint("TOPLEFT", shoppingTooltip1, "TOPRIGHT", 3, 0)
        elseif point == "RIGHT" then
            shoppingTooltip1:ClearAllPoints()
            shoppingTooltip2:ClearAllPoints()
            shoppingTooltip1:SetPoint("TOPRIGHT", anchorFrame, "TOPLEFT", -3, -10)
            shoppingTooltip2:SetPoint("TOPRIGHT", shoppingTooltip1, "TOPLEFT", -3, 0)
        end
    else
        if point == "LEFT" then
            shoppingTooltip1:ClearAllPoints()
            shoppingTooltip1:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT", 3, -10)
        elseif point == "RIGHT" then
            shoppingTooltip1:ClearAllPoints()
            shoppingTooltip1:SetPoint("TOPRIGHT", anchorFrame, "TOPLEFT", -3, -10)
        end
    end
end)

----------------------------------------------------------------------------------------
--	Skin GameTooltip.ItemTooltip and EmbeddedItemTooltip
----------------------------------------------------------------------------------------
--GameTooltip.ItemTooltip.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
GameTooltip.ItemTooltip.Icon:SetTexCoord(unpack(C.media.texCoord))

hooksecurefunc(GameTooltip.ItemTooltip.IconBorder, "SetVertexColor", function(self, r, g, b)
    if r ~= 0.65882 and g ~= 0.65882 and b ~= 0.65882 then
        self:GetParent().backdrop:SetBackdropBorderColor(r, g, b)
    end
    self:SetTexture("")
end)

hooksecurefunc(GameTooltip.ItemTooltip.IconBorder, "Hide", function(self)
    self:GetParent().backdrop:SetBackdropBorderColor(unpack(C.media.border_color))
end)

GameTooltip.ItemTooltip:CreateBackdrop("Default")
GameTooltip.ItemTooltip.backdrop:SetPoint("TOPLEFT", GameTooltip.ItemTooltip.Icon, "TOPLEFT", -2, 2)
GameTooltip.ItemTooltip.backdrop:SetPoint("BOTTOMRIGHT", GameTooltip.ItemTooltip.Icon, "BOTTOMRIGHT", 2, -2)
GameTooltip.ItemTooltip.Count:ClearAllPoints()
GameTooltip.ItemTooltip.Count:SetPoint("BOTTOMRIGHT", GameTooltip.ItemTooltip.Icon, "BOTTOMRIGHT", 1, 0)

BONUS_OBJECTIVE_REWARD_FORMAT = "|T%1$s:16:16:0:0:64:64:5:59:5:59|t %2$s"
BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT = "|T%1$s:16:16:0:0:64:64:5:59:5:59|t |cffffffff%2$d|r %3$s"

local reward = EmbeddedItemTooltip.ItemTooltip
local icon = reward.Icon
if icon then
    --icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    icon:SetTexCoord(unpack(C.media.texCoord))
    reward:CreateBackdrop("Default")
    reward.backdrop:SetPoint("TOPLEFT", icon, "TOPLEFT", -2, 2)
    reward.backdrop:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)

    hooksecurefunc(reward.IconBorder, "SetVertexColor", function(self, r, g, b)
        if r ~= 0.65882 and g ~= 0.65882 and b ~= 0.65882 then
            self:GetParent().backdrop:SetBackdropBorderColor(r, g, b)
        end
        self:SetTexture("")
    end)
    hooksecurefunc(reward.IconBorder, "Hide", function(self)
        self:GetParent().backdrop:SetBackdropBorderColor(unpack(C.media.border_color))
    end)
end

hooksecurefunc("GameTooltip_ShowProgressBar", function(tt)
    if not tt or tt:IsForbidden() or not tt.progressBarPool then return end
    local frame = tt.progressBarPool:GetNextActive()
    if (not frame or not frame.Bar) or frame.Bar.backdrop then return end
    local bar = frame.Bar
    local label = bar.Label
    if bar then
        bar:StripTextures()
        bar:CreateBackdrop("Transparent")
        bar.backdrop:SetBackdropColor(0.1, 0.1, 0.1, 1)
        bar:SetStatusBarTexture(C.media.texture.status)
        label:ClearAllPoints()
        label:SetPoint("CENTER", bar, 0, 0)
        label:SetDrawLayer("OVERLAY")
        label:SetFont(unpack(C.media.standard_font))
    end
end)

----------------------------------------------------------------------------------------
--	Skin More Tooltips (modified from NDUI)
----------------------------------------------------------------------------------------

styler.rTips[E.addonName] = function()
    -- IME
    _G.IMECandidatesFrame.selection:SetVertexColor(unpack(C.media.backdrop_color))

    -- Pet Tooltip
    _G.PetBattlePrimaryUnitTooltip:HookScript("OnShow", function(self)
        self.Border:SetAlpha(0)
        if not self.iconStyled then
            if self.glow then self.glow:Hide() end
            self.Icon:SetTexCoord(unpack(C.media.texCoord))
            self.iconStyled = true
        end
    end)

    hooksecurefunc("PetBattleUnitTooltip_UpdateForUnit", function(self)
        local nextBuff, nextDebuff = 1, 1
        for i = 1, C_PetBattles_GetNumAuras(self.petOwner, self.petIndex) do
            local _, _, _, isBuff = C_PetBattles_GetAuraInfo(self.petOwner, self.petIndex, i)
            if isBuff and self.Buffs then
                local frame = self.Buffs.frames[nextBuff]
                if frame and frame.Icon then
                    frame.Icon:SetTexCoord(unpack(C.media.texCoord))
                end
                nextBuff = nextBuff + 1
            elseif (not isBuff) and self.Debuffs then
                local frame = self.Debuffs.frames[nextDebuff]
                if frame and frame.Icon then
                    frame.DebuffBorder:Hide()
                    frame.Icon:SetTexCoord(unpack(C.media.texCoord))
                end
                nextDebuff = nextDebuff + 1
            end
        end
    end)

    -- DropdownMenu
    hooksecurefunc("UIDropDownMenu_CreateFrames", function() 
        for _, name in pairs({ "DropDownList", "L_DropDownList", "Lib_DropDownList" }) do
            for i = 1, UIDROPDOWNMENU_MAXLEVELS do
                local menu = _G[name .. i .. "MenuBackdrop"]
                if menu and not menu.menustyled then 
                    hook(menu) 
                    menu.menustyled = true
                end
            end
        end
    end)
end

styler.rTips["Blizzard_DebugTools"] = function()
    hook(FrameStackTooltip)
    hook(EventTraceTooltip)
    FrameStackTooltip:SetScale(UIParent:GetScale())
    EventTraceTooltip:SetParent(UIParent)
    EventTraceTooltip:SetFrameStrata("TOOLTIP")
end

styler.rTips["Blizzard_Collections"] = function()
    hook(PetJournalPrimaryAbilityTooltip)
    hook(PetJournalSecondaryAbilityTooltip)
    PetJournalPrimaryAbilityTooltip.Delimiter1:SetHeight(1)
    PetJournalPrimaryAbilityTooltip.Delimiter1:SetColorTexture(0, 0, 0)
    PetJournalPrimaryAbilityTooltip.Delimiter2:SetHeight(1)
    PetJournalPrimaryAbilityTooltip.Delimiter2:SetColorTexture(0, 0, 0)
end

styler.rTips["Blizzard_GarrisonUI"] = function()
    local gt = {
        GarrisonMissionMechanicTooltip,
        GarrisonMissionMechanicFollowerCounterTooltip,
        GarrisonShipyardMapMissionTooltip,
        GarrisonBonusAreaTooltip,
        GarrisonBuildingFrame.BuildingLevelTooltip,
        GarrisonFollowerAbilityWithoutCountersTooltip,
        GarrisonFollowerMissionAbilityWithoutCountersTooltip
    }
    for _, f in pairs(gt) do
        hook(f)
    end
end

styler.rTips["Blizzard_PVPUI"] = function()
    hook(ConquestTooltip)
end

styler.rTips["Blizzard_Contribution"] = function()
    hook(ContributionBuffTooltip)
    ContributionBuffTooltip.Icon:SetTexCoord(unpack(C.media.texCoord))
    ContributionBuffTooltip.Border:SetAlpha(0)
end

styler.rTips["Blizzard_EncounterJournal"] = function()
    hook(EncounterJournalTooltip)
    EncounterJournalTooltip.Item1.icon:SetTexCoord(unpack(C.media.texCoord))
    EncounterJournalTooltip.Item1.IconBorder:SetAlpha(0)
    EncounterJournalTooltip.Item2.icon:SetTexCoord(unpack(C.media.texCoord))
    EncounterJournalTooltip.Item2.IconBorder:SetAlpha(0)
end

styler.rTips["Blizzard_Calendar"] = function()
    hook(CalendarContextMenu)
end

styler.rTips["Blizzard_IslandsQueueUI"] = function()
    local tooltip = IslandsQueueFrameTooltip:GetParent()
    tooltip.IconBorder:SetAlpha(0)
    tooltip.Icon:SetTexCoord(unpack(C.media.texCoord))
    hook(tooltip:GetParent())
end
