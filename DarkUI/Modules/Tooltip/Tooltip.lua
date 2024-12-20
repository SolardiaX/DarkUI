﻿local E, C, L = select(2, ...):unpack()

if not C.tooltip.enable then return end

----------------------------------------------------------------------------------------
--  Based on aTooltip(by ALZA)
----------------------------------------------------------------------------------------
local module = E:Module("Tooltip")

local _G = _G
local CreateFrame = CreateFrame
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local PowerBarColor = PowerBarColor
local UnitFactionGroup = UnitFactionGroup
local UnitIsAFK, UnitIsDND, UnitSex = UnitIsAFK, UnitIsDND, UnitSex
local InCombatLockdown, IsShiftKeyDown = InCombatLockdown, IsShiftKeyDown
local GetMouseFoci = GetMouseFoci
local GetCreatureDifficultyColor = GetCreatureDifficultyColor
local GetRaidTargetIndex, GetGuildInfo = GetRaidTargetIndex, GetGuildInfo
local GetNumSubgroupMembers, GetNumGroupMembers = GetNumSubgroupMembers, GetNumGroupMembers
local UnitCreatureType, UnitClassification = UnitCreatureType, UnitClassification
local UnitIsBattlePetCompanion = UnitIsBattlePetCompanion
local UnitIsPlayer, UnitName, UnitPVPName, UnitClass, UnitRace, UnitLevel = UnitIsPlayer, UnitName, UnitPVPName, UnitClass, UnitRace, UnitLevel
local UnitIsUnit, UnitIsTapDenied, UnitIsDead, UnitReaction = UnitIsUnit, UnitIsTapDenied, UnitIsDead, UnitReaction
local UnitHealth, UnitHealthMax = UnitHealth, UnitHealthMax
local UnitIsInMyGuild, UnitExists = UnitIsInMyGuild, UnitExists
local UnitIsEnemy, UnitIsFriend = UnitIsEnemy, UnitIsFriend
local UnitPower, UnitPowerType, UnitPowerMax = UnitPower, UnitPowerType, UnitPowerMax
local C_PetBattles_GetNumAuras = C_PetBattles.GetNumAuras
local C_PetBattles_GetAuraInfo = C_PetBattles.GetAuraInfo
local UIParent = UIParent
local GameTooltip = GameTooltip
local GameTooltipText = GameTooltipText
local GameTooltipTextSmall = GameTooltipTextSmall
local GameTooltipHeaderText = GameTooltipHeaderText
local GameTooltipStatusBar = GameTooltipStatusBar
local GetCVar = GetCVar
local select, unpack, wipe = select, unpack, wipe
local hooksecurefunc = hooksecurefunc
local LEVEL, FACTION_HORDE, FACTION_ALLIANCE, UNKNOWN, RANK, PVP_ENABLED = LEVEL, FACTION_HORDE, FACTION_ALLIANCE, UNKNOWN, RANK, PVP_ENABLED
local RAID_CLASS_COLORS, CUSTOM_CLASS_COLORS = RAID_CLASS_COLORS, CUSTOM_CLASS_COLORS
local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE
local LOCALIZED_CLASS_NAMES_FEMALE = LOCALIZED_CLASS_NAMES_FEMALE
local ENCOUNTER_JOURNAL_ENCOUNTER = ENCOUNTER_JOURNAL_ENCOUNTER
local FRIENDS_LIST_REALM = FRIENDS_LIST_REALM
local STATUS_TEXT_TARGET, UNIT_YOU = STATUS_TEXT_TARGET, UNIT_YOU

local cfg = C.tooltip

local defaultTooltips = {
    ChatMenu,
    EmoteMenu,
    LanguageMenu,
    VoiceMacroMenu,
    GameTooltip,
    EmbeddedItemTooltip,
    ItemRefTooltip,
    ItemRefShoppingTooltip1,
    ItemRefShoppingTooltip2,
    ShoppingTooltip1,
    ShoppingTooltip2,
    AutoCompleteBox,
    FriendsTooltip,
    QuestScrollFrame.StoryTooltip,
    QuestScrollFrame.CampaignTooltip,
    GeneralDockManagerOverflowButtonList,
    ReputationParagonTooltip,
    NamePlateTooltip,
    QueueStatusFrame,
    FloatingGarrisonFollowerTooltip,
    FloatingGarrisonFollowerAbilityTooltip,
    FloatingGarrisonMissionTooltip,
    GarrisonFollowerAbilityTooltip,
    GarrisonFollowerTooltip,
    FloatingGarrisonShipyardFollowerTooltip,
    GarrisonShipyardFollowerTooltip,
    BattlePetTooltip,
    PetBattlePrimaryAbilityTooltip,
    PetBattlePrimaryUnitTooltip,
    FloatingBattlePetTooltip,
    FloatingPetBattleAbilityTooltip,
    IMECandidatesFrame,
    QuickKeybindTooltip,
    GameSmallHeaderTooltip,
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

module.rTips = {}

-- style from FreebTip
local function styleTooltip(tip)
    if not tip then return end
    
    tip:HookScript("OnShow", function(tt)
        if tt:IsForbidden() then return end

        if not tt.styled then
            if tt.NineSlice then tt.NineSlice:SetAlpha(0) end
            if tt.SetBackdrop then tt:SetBackdrop(nil) end
            if tt.BackdropFrame then tt.BackdropFrame:SetBackdrop(nil) end
            
            tt:DisableDrawLayer("BACKGROUND")
            
            E:ApplyBackdrop(tt, true)

            tt.backdrop:SetPoint("TOPLEFT")
            tt.backdrop:SetPoint("BOTTOMRIGHT")

            tt.gradient:SetPoint("TOPLEFT", 2, -2)
            tt.gradient:SetPoint("BOTTOMRIGHT", tt, "TOPRIGHT", -2, -32)

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

local function getUnitColor(unit)
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

local targetedList = {}
local ClassColors = {}

for class, color in next, RAID_CLASS_COLORS do
    ClassColors[class] = ("|cff%.2x%.2x%.2x"):format(color.r * 255, color.g * 255, color.b * 255)
end

local function addTargetedBy(from)
    local numParty, numRaid = GetNumSubgroupMembers(), GetNumGroupMembers()
    if numParty > 0 or numRaid > 0 then
        for i = 1, (numRaid > 0 and numRaid or numParty) do
            local unit = (numRaid > 0 and "raid" .. i or "party" .. i)
            if UnitIsUnit(unit .. "target", from) and not UnitIsUnit(unit, "player") then
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

        statusBar:SetStatusBarTexture(C.media.texture.status) --("Interface\\TargetingFrame\\UI-StatusBar")
        statusBar.text = statusBar.text or statusBar:CreateFontString(name .. "Text", 'OVERLAY', 'Tooltip_Small')
        statusBar.text:SetFont(STATUS_TEXT_TARGET, 9, "THINOUTLINE")
        statusBar.text:SetAllPoints()
        statusBar.text:SetJustifyH('CENTER')
    end

    _G[name .. "Text"]:SetText(text and text or "")
    _G[name .. "Text"]:Show()
    statusBar:SetSize(128, 6)
    statusBar:SetStatusBarColor(r, g, b, a)
    statusBar:SetMinMaxValues(min, max)
    statusBar:SetValue(value)
    statusBar:ClearAllPoints()
    statusBar:SetPoint("LEFT", self:GetName() .. "TextLeft" .. numLines, "LEFT", 0, -4)
    statusBar:SetPoint("RIGHT", self, "RIGHT", -9, 0)
    statusBar:Show()

    self:SetMinimumWidth(140)
end

local function GameTooltip_HideStatusBar(self, name)
    local name = self:GetName() .. "StatusBar_" .. name
    local statusBar = _G[name]

    if statusBar then
        statusBar:Hide()
    end
end

local function onTooltipSetUnit(self)
    if self ~= GameTooltip or self:IsForbidden() then return end
    local lines = self:NumLines()
    -- local unit = (select(2, self:GetUnit())) or (GetMouseFoci()[1] and GetMouseFoci()[1].GetAttribute and GetMouseFoci()[1]:GetAttribute("unit")) or (UnitExists("mouseover") and "mouseover") or nil
    local data = self:GetTooltipData()
	local guid = data and data.guid
	local unit = guid and UnitTokenFromGUID(guid)

    if not unit then return end

    local name, realm = UnitName(unit)
    local race, englishRace = UnitRace(unit)
    local level = UnitLevel(unit)
    local levelColor = GetCreatureDifficultyColor(level)
    local classification = UnitClassification(unit)
    local creatureType = UnitCreatureType(unit)
    local _, faction = UnitFactionGroup(unit)
    local _, playerFaction = UnitFactionGroup("player")
    local titleName = UnitPVPName(unit)
    local isPlayer = UnitIsPlayer(unit)

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

    if isPlayer and titleName and cfg.title then
        name = titleName
    end
  
    local r, g, b = getUnitColor(unit)
    _G["GameTooltipTextLeft1"]:SetFormattedText("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, name or gameTooltipTextLeft1:GetText() or "")
    if realm and realm ~= "" and cfg.realm then
        self:AddLine(FRIENDS_LIST_REALM .. "|cffffffff" .. realm .. "|r")
    end

    if isPlayer then
        if UnitIsAFK(unit) then
            self:AppendText((" %s"):format("|cffE7E716" .. L.CHAT_AFK .. "|r"))
        elseif UnitIsDND(unit) then
            self:AppendText((" %s"):format("|cffFF0000" .. L.CHAT_DND .. "|r"))
        end
        if isPlayer and englishRace == "Pandaren" and faction ~= nil and faction ~= playerFaction then
            local hex = "cffff3333"
            if faction == "Alliance" then
                hex = "cff69ccf0"
            end
            self:AppendText((" [|%s%s|r]"):format(hex, faction:sub(1, 2)))
        end

        local guildName, guildRank = GetGuildInfo(unit)
        if guildName then
            _G["GameTooltipTextLeft"..2]:SetFormattedText("%s", guildName)
            if UnitIsInMyGuild(unit) then
                _G["GameTooltipTextLeft"..2]:SetTextColor(1, 1, 0)
            else
                _G["GameTooltipTextLeft"..2]:SetTextColor(0, 1, 1)
            end
            if cfg.rank == true then
                self:AddLine(RANK..": |cffffffff"..guildRank.."|r")
            end
        end

        local n = guildName and 3 or 2
        -- thx TipTac for the fix above with color blind enabled
        if GetCVar("colorblindMode") == "1" then
            n = n + 1
            local class = UnitClass(unit)
            _G["GameTooltipTextLeft"..n]:SetFormattedText("|cff%02x%02x%02x%s|r %s %s", levelColor.r * 255, levelColor.g * 255, levelColor.b * 255, level, race or UNKNOWN, class or "")
        else
            _G["GameTooltipTextLeft" .. n]:SetFormattedText("|cff%02x%02x%02x%s|r %s", levelColor.r * 255, levelColor.g * 255, levelColor.b * 255, level, race or UNKNOWN)
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

    for i = 2, lines do
        local line = _G["GameTooltipTextLeft" .. i]
        if not line or not line:GetText() then return end
        if line and line:GetText() and (line:GetText() == FACTION_HORDE or line:GetText() == FACTION_ALLIANCE or line:GetText() == PVP_ENABLED) then
            line:SetText()
        end
    end

    if cfg.target == true and UnitExists(unit .. "target") then
        local r, g, b = getUnitColor(unit .. "target")
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
            module.ricon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. raidIndex)
        else
            module.ricon:SetTexture(0)
        end
    end

    if cfg.who_targetting == true then
        addTargetedBy(unit)
    end

    GameTooltipStatusBar:Hide()

    local minv, maxv = UnitHealth(unit), UnitHealthMax(unit)

    if level and maxv > 0 then
        local hp = E:ShortValue(minv)
        local r, g, b = getUnitColor(unit)
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

function module:CreateAnchor()
    local anchor = CreateFrame("Frame", "DarkUI_TooltipAnchor", UIParent)
    anchor:SetSize(200, 40)
    anchor:SetPoint(unpack(cfg.position))

    local function setGameTooltipAnchor(tooltip, parent)
        if cfg.cursor == true then
            tooltip:SetOwner(parent, "ANCHOR_CURSOR_RIGHT", 20, 20)
        else
            tooltip:SetOwner(parent, "ANCHOR_NONE")
            tooltip:ClearAllPoints()
            tooltip:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 0, 0)
            tooltip.default = 1
        end
    end
    
    hooksecurefunc("GameTooltip_SetDefaultAnchor", setGameTooltipAnchor)

    self.anchor = anchor
end

function module:CreateRaidIcon()
    -- Raid icon
    if not cfg.raid_icon then return end

    local ricon = GameTooltip:CreateTexture("GameTooltipRaidIcon", "OVERLAY")
    ricon:SetHeight(18)
    ricon:SetWidth(18)
    ricon:SetPoint("CENTER", GameTooltip, "TOP", 0, 0)

    GameTooltip:HookScript("OnHide", function() ricon:SetTexture(nil) end)

    self.ricon = ricon
end

function module:CreateHealthValue()
    if not cfg.health_value then return end

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

module:RegisterEvent("ADDON_LOADED PLAYER_LOGIN PLAYER_ENTERING_WORLD", function(self, event, addon)
    if C_AddOns.IsAddOnLoaded("Aurora") then return end

    if event == "ADDON_LOADED" and self.rTips[addon] then
        self.rTips[addon]()
        self.rTips[addon] = nil
    elseif event == "PLAYER_LOGIN" then
        for _, tip in pairs(defaultTooltips) do
            local tt = type(tip) == "table" and tip or _G[tip]
            if tt then styleTooltip(tt) end
        end
        for _, tip in pairs(shoppingtips) do
            local tt = type(tip) == "table" and tip or _G[tip]
            if tt then
                tt.shopping = true
                styleTooltip(tt)
            end
        end
        self:CreateAnchor()
        self:CreateRaidIcon()
        self:CreateHealthValue()

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
        end

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

        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, onTooltipSetUnit)

        local OnGameTooltipHide = function(self)
            GameTooltip_ClearMoney(self)
            GameTooltip_ClearStatusBars(self)
        
            GameTooltip_HideStatusBar(self, 'hp')
            GameTooltip_HideStatusBar(self, 'power')
        end
        
        GameTooltip:HookScript("OnTooltipCleared", OnGameTooltipHide)
    elseif event == "PLAYER_ENTERING_WORLD" then
        local menuManagerProxy = Menu.GetManager()

        local function skinMenu(menuFrame)
            if menuFrame.styled then return end

            menuFrame:DisableDrawLayer("BACKGROUND")
            menuFrame:StripTextures()
            menuFrame:CreateBackdrop()
            menuFrame.backdrop:CreateShadow()

            menuFrame.styled = true
        end
    
        local function setupMenu()
            local menuFrame = menuManagerProxy:GetOpenMenu()
            if menuFrame then
                skinMenu(menuFrame)
            end
        end

        hooksecurefunc(menuManagerProxy, "OpenMenu", setupMenu)
        hooksecurefunc(menuManagerProxy, "OpenContextMenu", setupMenu)
    end
end)


----------------------------------------------------------------------------------------
--    Fix compare tooltips(by Blizzard)(../FrameXML/GameTooltip.lua)
----------------------------------------------------------------------------------------
hooksecurefunc(TooltipComparisonManager, "AnchorShoppingTooltips", function(self, primaryShown, secondaryItemShown)
    local tooltip = self.tooltip;
    local shoppingTooltip1 = tooltip.shoppingTooltips[1];
    local shoppingTooltip2 = tooltip.shoppingTooltips[2];
    local point = shoppingTooltip1:GetPoint(2)
    if secondaryItemShown then
        if point == "TOP" then
            shoppingTooltip1:ClearAllPoints()
            shoppingTooltip2:ClearAllPoints()
            shoppingTooltip1:SetPoint("TOPLEFT", self.anchorFrame, "TOPRIGHT", 3, -10)
            shoppingTooltip2:SetPoint("TOPLEFT", shoppingTooltip1, "TOPRIGHT", 3, 0)
        elseif point == "RIGHT" then
            shoppingTooltip1:ClearAllPoints()
            shoppingTooltip2:ClearAllPoints()
            shoppingTooltip1:SetPoint("TOPRIGHT", self.anchorFrame, "TOPLEFT", -3, -10)
            shoppingTooltip2:SetPoint("TOPRIGHT", shoppingTooltip1, "TOPLEFT", -3, 0)
        end
    else
        if point == "LEFT" then
            shoppingTooltip1:ClearAllPoints()
            shoppingTooltip1:SetPoint("TOPLEFT", self.anchorFrame, "TOPRIGHT", 3, -10)
        elseif point == "RIGHT" then
            shoppingTooltip1:ClearAllPoints()
            shoppingTooltip1:SetPoint("TOPRIGHT", self.anchorFrame, "TOPLEFT", -3, -10)
        end
    end
end)

----------------------------------------------------------------------------------------
--    Fix GameTooltipMoneyFrame font size
----------------------------------------------------------------------------------------
hooksecurefunc("SetTooltipMoney", function()
    for i = 1, 2 do
        if _G["GameTooltipMoneyFrame"..i] then
            _G["GameTooltipMoneyFrame"..i.."PrefixText"]:SetFontObject("GameTooltipText")
            _G["GameTooltipMoneyFrame"..i.."SuffixText"]:SetFontObject("GameTooltipText")
            _G["GameTooltipMoneyFrame"..i.."GoldButton"]:SetNormalFontObject("GameTooltipText")
            _G["GameTooltipMoneyFrame"..i.."SilverButton"]:SetNormalFontObject("GameTooltipText")
            _G["GameTooltipMoneyFrame"..i.."CopperButton"]:SetNormalFontObject("GameTooltipText")
        end
    end
    for i = 1, 2 do
        if _G["ShoppingTooltip1MoneyFrame"..i] then
            _G["ShoppingTooltip1MoneyFrame"..i.."PrefixText"]:SetFontObject("GameTooltipText")
            _G["ShoppingTooltip1MoneyFrame"..i.."SuffixText"]:SetFontObject("GameTooltipText")
            _G["ShoppingTooltip1MoneyFrame"..i.."GoldButton"]:SetNormalFontObject("GameTooltipText")
            _G["ShoppingTooltip1MoneyFrame"..i.."SilverButton"]:SetNormalFontObject("GameTooltipText")
            _G["ShoppingTooltip1MoneyFrame"..i.."CopperButton"]:SetNormalFontObject("GameTooltipText")
        end
    end
end)

----------------------------------------------------------------------------------------
--    Skin GameTooltip.ItemTooltip and EmbeddedItemTooltip
----------------------------------------------------------------------------------------
GameTooltip.ItemTooltip.Icon:SetTexCoord(unpack(C.media.texCoord))

hooksecurefunc(GameTooltip.ItemTooltip.IconBorder, "SetVertexColor", function(self, r, g, b)
    if r ~= BAG_ITEM_QUALITY_COLORS[1].r and g ~= BAG_ITEM_QUALITY_COLORS[1].g then
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
    icon:SetTexCoord(unpack(C.media.texCoord))
    reward:CreateBackdrop("Default")
    reward.backdrop:SetPoint("TOPLEFT", icon, "TOPLEFT", -2, 2)
    reward.backdrop:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)

    hooksecurefunc(reward.IconBorder, "SetVertexColor", function(self, r, g, b)
        if r ~= BAG_ITEM_QUALITY_COLORS[1].r and g ~= BAG_ITEM_QUALITY_COLORS[1].g then
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
--    Skin More Tooltips (modified from NDUI)
----------------------------------------------------------------------------------------

module.rTips[E.addonName] = function()
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
                if menu and not menu.menuStyled then 
                    styleTooltip(menu) 
                    menu.menuStyled = true
                end
            end
        end
    end)
end

module.rTips["Blizzard_DebugTools"] = function()
    styleTooltip(FrameStackTooltip)
    FrameStackTooltip:SetScale(UIParent:GetScale())
end

module.rTips["Blizzard_EventTrace"] = function()
    styleTooltip(EventTraceTooltip)
    EventTraceTooltip:SetParent(UIParent)
    EventTraceTooltip:SetFrameStrata("TOOLTIP")
end

module.rTips["Blizzard_Collections"] = function()
    styleTooltip(PetJournalPrimaryAbilityTooltip)
    styleTooltip(PetJournalSecondaryAbilityTooltip)
    PetJournalPrimaryAbilityTooltip.Delimiter1:SetHeight(1)
    PetJournalPrimaryAbilityTooltip.Delimiter1:SetColorTexture(0, 0, 0)
    PetJournalPrimaryAbilityTooltip.Delimiter2:SetHeight(1)
    PetJournalPrimaryAbilityTooltip.Delimiter2:SetColorTexture(0, 0, 0)
end

module.rTips["Blizzard_GarrisonUI"] = function()
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
        styleTooltip(f)
    end
end

module.rTips["Blizzard_PVPUI"] = function()
    styleTooltip(ConquestTooltip)
end

module.rTips["Blizzard_Contribution"] = function()
    styleTooltip(ContributionBuffTooltip)
    ContributionBuffTooltip.Icon:SetTexCoord(unpack(C.media.texCoord))
    ContributionBuffTooltip.Border:SetAlpha(0)
end

module.rTips["Blizzard_EncounterJournal"] = function()
    styleTooltip(EncounterJournalTooltip)
    EncounterJournalTooltip.Item1.icon:SetTexCoord(unpack(C.media.texCoord))
    EncounterJournalTooltip.Item1.IconBorder:SetAlpha(0)
    EncounterJournalTooltip.Item2.icon:SetTexCoord(unpack(C.media.texCoord))
    EncounterJournalTooltip.Item2.IconBorder:SetAlpha(0)
end

module.rTips["Blizzard_Calendar"] = function()
    styleTooltip(CalendarContextMenu)
    styleTooltip(CalendarInviteStatusContextMenu)
end

module.rTips["Blizzard_IslandsQueueUI"] = function()
    local tooltip = IslandsQueueFrame.WeeklyQuest.QuestReward.Tooltip
    tooltip.IconBorder:SetAlpha(0)
    tooltip.Icon:SetTexCoord(unpack(C.media.texCoord))
    styleTooltip(tooltip:GetParent())
end
