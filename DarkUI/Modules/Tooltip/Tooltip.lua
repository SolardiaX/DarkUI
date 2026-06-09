local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Tooltip
------------------------------------------------------------------------
local module = E:Module("Tooltip")

local cfg = C.tooltip

local _G = _G
local CreateFrame = CreateFrame
local select, unpack, wipe = select, unpack, wipe
local hooksecurefunc = hooksecurefunc

local UnitFactionGroup = UnitFactionGroup
local UnitIsAFK, UnitIsDND, UnitSex = UnitIsAFK, UnitIsDND, UnitSex
local InCombatLockdown, IsShiftKeyDown = InCombatLockdown, IsShiftKeyDown
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
local GetCVar = GetCVar

local C_PetBattles_GetNumAuras = C_PetBattles.GetNumAuras
local C_PetBattles_GetAuraInfo = C_PetBattles.GetAuraInfo

local LEVEL, FACTION_HORDE, FACTION_ALLIANCE = LEVEL, FACTION_HORDE, FACTION_ALLIANCE
local UNKNOWN, RANK, PVP_ENABLED = UNKNOWN, RANK, PVP_ENABLED
local RAID_CLASS_COLORS, CUSTOM_CLASS_COLORS = RAID_CLASS_COLORS, CUSTOM_CLASS_COLORS
local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE
local LOCALIZED_CLASS_NAMES_FEMALE = LOCALIZED_CLASS_NAMES_FEMALE
local ENCOUNTER_JOURNAL_ENCOUNTER = ENCOUNTER_JOURNAL_ENCOUNTER
local FRIENDS_LIST_REALM = FRIENDS_LIST_REALM
local STATUS_TEXT_TARGET, UNIT_YOU = STATUS_TEXT_TARGET, UNIT_YOU

------------------------------------------------------------------------
-- Tooltip lists
------------------------------------------------------------------------
local defaultTooltips = {
    GameTooltip,
    EmbeddedItemTooltip,
    ItemRefTooltip,
    ItemRefShoppingTooltip1,
    ItemRefShoppingTooltip2,
    ShoppingTooltip1,
    ShoppingTooltip2,
    AutoCompleteBox,
    FriendsTooltip,
    QueueStatusFrame,
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
}

------------------------------------------------------------------------
-- Styling
------------------------------------------------------------------------
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

            tt.__backdrop:SetPoint("TOPLEFT")
            tt.__backdrop:SetPoint("BOTTOMRIGHT")

            tt.__gradient:SetPoint("TOPLEFT", 2, -2)
            tt.__gradient:SetPoint("BOTTOMRIGHT", tt, "TOPRIGHT", -2, -32)

            tt.styled = true
        end

        local frameName = tt:GetName()
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

------------------------------------------------------------------------
-- Unit color
------------------------------------------------------------------------
local function getUnitColor(unit)
    if not unit then return 1, 1, 1 end
    local r, g, b

    if UnitIsPlayer(unit) or (UnitInPartyIsAI and UnitInPartyIsAI(unit)) then
        local _, class = UnitClass(unit)
        local color = class and (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
        if color then
            r, g, b = color.r, color.g, color.b
        end
    elseif UnitIsTapDenied(unit) or UnitIsDead(unit) then
        r, g, b = 0.6, 0.6, 0.6
    else
        local reaction = UnitReaction(unit, "player")
        if reaction and C.oUF_colors.reaction[reaction] then
            local c = C.oUF_colors.reaction[reaction]
            r, g, b = c[1], c[2], c[3]
        end
    end

    return r or 1, g or 1, b or 1
end

------------------------------------------------------------------------
-- Unit tooltip handler
------------------------------------------------------------------------
local function onTooltipSetUnit(self)
    if self ~= GameTooltip or self:IsForbidden() then return end
    local lines = self:NumLines()

    local data = self:GetTooltipData()
    local guid = data and data.guid
    if guid and not canaccessvalue(guid) then return end
    local unit = guid and UnitTokenFromGUID(guid)

    if not unit then
        if UnitExists("mouseover") then
            unit = "mouseover"
        else
            return
        end
    end

    if not canaccessvalue(unit) then return end

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
    _G["GameTooltipTextLeft1"]:SetFormattedText("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, name or "")
    if realm and canaccessvalue(realm) and realm ~= "" and cfg.realm then
        self:AddLine(FRIENDS_LIST_REALM .. "|cffffffff" .. realm .. "|r")
    end

    if isPlayer then
        if UnitIsAFK(unit) then
            self:AppendText((" %s"):format("|cffE7E716" .. L.CHAT_AFK .. "|r"))
        elseif UnitIsDND(unit) then
            self:AppendText((" %s"):format("|cffFF0000" .. L.CHAT_DND .. "|r"))
        end
        if englishRace and (englishRace == "Pandaren" or englishRace == "Dracthyr" or englishRace == "EarthenDwarf") and faction ~= nil and faction ~= playerFaction then
            local hex = "cffff3333"
            if faction == "Alliance" then
                hex = "cff69ccf0"
            end
            self:AppendText((" [|%s%s|r]"):format(hex, faction:sub(1, 2)))
        end

        local guildName, guildRank = GetGuildInfo(unit)
        if guildName then
            _G["GameTooltipTextLeft2"]:SetFormattedText("%s", guildName)
            if UnitIsInMyGuild(unit) then
                _G["GameTooltipTextLeft2"]:SetTextColor(1, 1, 0)
            else
                _G["GameTooltipTextLeft2"]:SetTextColor(0, 1, 1)
            end
            if cfg.rank then
                self:AddLine(RANK .. ": |cffffffff" .. guildRank .. "|r")
            end
        end

        local n = guildName and 3 or 2
        if GetCVar("colorblindMode") == "1" then
            n = n + 1
            local class = UnitClass(unit)
            _G["GameTooltipTextLeft" .. n]:SetFormattedText("|cff%02x%02x%02x%s|r %s %s", levelColor.r * 255, levelColor.g * 255, levelColor.b * 255, level, race or UNKNOWN, class or "")
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
            local line = _G["GameTooltipTextLeft" .. i]
            local text = line and line:GetText()
            if text and canaccessvalue(text) and text:find(unitRace) then
                pattern = pattern .. " %s %s (%s)"
                _G["GameTooltipTextLeft" .. i]:SetText((pattern):format(level, unitRace, unitClass):trim())
                break
            end
        end
    else
        for i = 2, lines do
            local line = _G["GameTooltipTextLeft" .. i]
            if not line or not line:GetText() or UnitIsBattlePetCompanion(unit) then return end
            local text = line:GetText()
            if not canaccessvalue(text) then break end
            if (level and text:find("^" .. LEVEL)) or (creatureType and text:find("^" .. creatureType)) then
                line:SetFormattedText("|cff%02x%02x%02x%s%s|r %s", levelColor.r * 255, levelColor.g * 255, levelColor.b * 255, level, classification, creatureType or "")
                break
            end
        end
    end

    for i = 2, lines do
        local line = _G["GameTooltipTextLeft" .. i]
        if not line or not line:GetText() then return end
        local text = line:GetText()
        if text and canaccessvalue(text) and (text == FACTION_HORDE or text == FACTION_ALLIANCE or text == PVP_ENABLED) then
            line:SetText()
        end
    end

    if cfg.target and UnitExists(unit .. "target") then
        local tr, tg, tb = getUnitColor(unit .. "target")

        if UnitIsEnemy("player", unit .. "target") then
            tr, tg, tb = unpack(C.oUF_colors.reaction[1])
        elseif not UnitIsFriend("player", unit .. "target") then
            tr, tg, tb = unpack(C.oUF_colors.reaction[4])
        end

        local text
        if C_Secrets and C_Secrets.ShouldUnitComparisonBeSecret and not C_Secrets.ShouldUnitComparisonBeSecret("player", unit .. "target") and UnitIsUnit("player", unit .. "target") then
            text = "|cfffed100" .. STATUS_TEXT_TARGET .. ":|r " .. "|cffff0000> " .. UNIT_YOU .. " <|r"
        else
            text = "|cfffed100" .. STATUS_TEXT_TARGET .. ":|r " .. UnitName(unit .. "target")
        end

        self:AddLine(text, tr, tg, tb)
    end

    if cfg.raid_icon then
        local raidIndex = GetRaidTargetIndex(unit)
        if raidIndex then
            module.ricon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. raidIndex)
        else
            module.ricon:SetTexture(0)
        end
    end

    -- Setup inline health bar
    GameTooltipStatusBar:Hide()

    if not UnitIsDeadOrGhost(unit) then
        self:AddLine(" ")
        local numLines = self:NumLines()

        if not module.hpBar then
            local bar = CreateFrame("StatusBar", "DarkUI_TooltipHPBar", GameTooltip, "BackdropTemplate")
            bar:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                tiled = false, edgeSize = 1, insets = { left = -1, right = -1, top = -1, bottom = -1 }
            })
            bar:SetBackdropColor(0, 0, 0, 0.5)
            bar:SetBackdropBorderColor(0, 0, 0, 0.5)
            bar:SetStatusBarTexture(C.media.texture.status)
            bar:SetHeight(6)

            bar.text = bar:CreateFontString(nil, "OVERLAY", "Tooltip_Small")
            bar.text:SetFont(STANDARD_TEXT_FONT, 9, "THINOUTLINE")
            bar.text:SetAllPoints()
            bar.text:SetJustifyH("CENTER")

            module.hpBar = bar
        end

        local bar = module.hpBar
        local r, g, b = getUnitColor(unit)
        bar:SetStatusBarColor(r, g, b)
        bar:SetMinMaxValues(0, UnitHealthMax(unit))
        bar:SetValue(UnitHealth(unit))
        bar.text:SetText(E:AbbreviateNumber(UnitHealth(unit)))
        bar:ClearAllPoints()
        bar:SetPoint("LEFT", "GameTooltipTextLeft" .. numLines, "LEFT", 0, -4)
        bar:SetPoint("RIGHT", self, "RIGHT", -9, 0)
        bar:Show()

        self:SetMinimumWidth(140)
        module.hpUnit = unit
    end
end

------------------------------------------------------------------------
-- Skin helpers (called from OnInit)
------------------------------------------------------------------------
local function skinItemTooltips()
    GameTooltip.ItemTooltip.Icon:SetTexCoord(unpack(C.media.texCoord))

    GameTooltip.ItemTooltip.Icon:CreateBackdrop("Default")
    local itemBD = GameTooltip.ItemTooltip.Icon.__backdrop
    itemBD:SetPoint("TOPLEFT", GameTooltip.ItemTooltip.Icon, "TOPLEFT", -2, 2)
    itemBD:SetPoint("BOTTOMRIGHT", GameTooltip.ItemTooltip.Icon, "BOTTOMRIGHT", 2, -2)

    hooksecurefunc(GameTooltip.ItemTooltip.IconBorder, "SetVertexColor", function(self, r, g, b)
        if r ~= BAG_ITEM_QUALITY_COLORS[1].r and g ~= BAG_ITEM_QUALITY_COLORS[1].g then
            itemBD:SetBackdropBorderColor(r, g, b)
        end
        self:SetTexture("")
    end)

    hooksecurefunc(GameTooltip.ItemTooltip.IconBorder, "Hide", function()
        itemBD:SetBackdropBorderColor(unpack(C.media.border_color))
    end)
    GameTooltip.ItemTooltip.Count:ClearAllPoints()
    GameTooltip.ItemTooltip.Count:SetPoint("BOTTOMRIGHT", GameTooltip.ItemTooltip.Icon, "BOTTOMRIGHT", 1, 0)

    BONUS_OBJECTIVE_REWARD_FORMAT = "|T%1$s:16:16:0:0:64:64:5:59:5:59|t %2$s"
    BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT = "|T%1$s:16:16:0:0:64:64:5:59:5:59|t |cffffffff%2$d|r %3$s"

    local reward = EmbeddedItemTooltip.ItemTooltip
    local icon = reward.Icon
    if icon then
        icon:SetTexCoord(unpack(C.media.texCoord))
        icon:CreateBackdrop("Default")
        local rewardBD = icon.__backdrop
        rewardBD:SetPoint("TOPLEFT", icon, "TOPLEFT", -2, 2)
        rewardBD:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)

        hooksecurefunc(reward.IconBorder, "SetVertexColor", function(self, r, g, b)
            if r ~= BAG_ITEM_QUALITY_COLORS[1].r and g ~= BAG_ITEM_QUALITY_COLORS[1].g then
                rewardBD:SetBackdropBorderColor(r, g, b)
            end
            self:SetTexture("")
        end)
        hooksecurefunc(reward.IconBorder, "Hide", function()
            rewardBD:SetBackdropBorderColor(unpack(C.media.border_color))
        end)
    end

    hooksecurefunc("GameTooltip_ShowProgressBar", function(tt)
        if not tt or tt:IsForbidden() or not tt.progressBarPool then return end
        local frame = tt.progressBarPool:GetNextActive()
        if (not frame or not frame.Bar) or frame.Bar.__backdrop then return end
        local bar = frame.Bar
        local label = bar.Label
        if bar then
            bar:StripTextures()
            bar:CreateBackdrop("Transparent")
            bar.__backdrop:SetBackdropColor(0.1, 0.1, 0.1, 1)
            bar:SetStatusBarTexture(C.media.texture.status)
            label:ClearAllPoints()
            label:SetPoint("CENTER", bar, 0, 0)
            label:SetDrawLayer("OVERLAY")
            label:SetFont(unpack(C.media.standard_font))
        end
    end)
end

local function skinCompareTooltips()
    hooksecurefunc(TooltipComparisonManager, "AnchorShoppingTooltips", function(self, _, secondaryItemShown)
        local tooltip = self.tooltip
        local shoppingTooltip1 = tooltip.shoppingTooltips[1]
        local shoppingTooltip2 = tooltip.shoppingTooltips[2]
        local point = shoppingTooltip1:GetPoint(2)
        if not canaccessvalue(point) then return end
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

    hooksecurefunc("SetTooltipMoney", function()
        for i = 1, 2 do
            if _G["GameTooltipMoneyFrame" .. i] then
                _G["GameTooltipMoneyFrame" .. i .. "PrefixText"]:SetFontObject("GameTooltipText")
                _G["GameTooltipMoneyFrame" .. i .. "SuffixText"]:SetFontObject("GameTooltipText")
                _G["GameTooltipMoneyFrame" .. i .. "GoldButton"]:SetNormalFontObject("GameTooltipText")
                _G["GameTooltipMoneyFrame" .. i .. "SilverButton"]:SetNormalFontObject("GameTooltipText")
                _G["GameTooltipMoneyFrame" .. i .. "CopperButton"]:SetNormalFontObject("GameTooltipText")
            end
        end
        for i = 1, 2 do
            if _G["ShoppingTooltip1MoneyFrame" .. i] then
                _G["ShoppingTooltip1MoneyFrame" .. i .. "PrefixText"]:SetFontObject("GameTooltipText")
                _G["ShoppingTooltip1MoneyFrame" .. i .. "SuffixText"]:SetFontObject("GameTooltipText")
                _G["ShoppingTooltip1MoneyFrame" .. i .. "GoldButton"]:SetNormalFontObject("GameTooltipText")
                _G["ShoppingTooltip1MoneyFrame" .. i .. "SilverButton"]:SetNormalFontObject("GameTooltipText")
                _G["ShoppingTooltip1MoneyFrame" .. i .. "CopperButton"]:SetNormalFontObject("GameTooltipText")
            end
        end
    end)
end

------------------------------------------------------------------------
-- Addon-loaded tooltip skins
------------------------------------------------------------------------
module.rTips = {}

module.rTips[E.addonName] = function()
    _G.IMECandidatesFrame.selection:SetVertexColor(unpack(C.media.backdrop_color))

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
end

module.rTips["Blizzard_DebugTools"] = function()
    if FrameStackTooltip then
        styleTooltip(FrameStackTooltip)
        FrameStackTooltip:SetScale(UIParent:GetScale())
    end
end

module.rTips["Blizzard_EventTrace"] = function()
    if EventTraceTooltip then
        styleTooltip(EventTraceTooltip)
        EventTraceTooltip:SetParent(UIParent)
        EventTraceTooltip:SetFrameStrata("TOOLTIP")
    end
end

module.rTips["Blizzard_Collections"] = function()
    if PetJournalPrimaryAbilityTooltip then
        styleTooltip(PetJournalPrimaryAbilityTooltip)
        styleTooltip(PetJournalSecondaryAbilityTooltip)
        PetJournalPrimaryAbilityTooltip.Delimiter1:SetHeight(1)
        PetJournalPrimaryAbilityTooltip.Delimiter1:SetColorTexture(0, 0, 0)
        PetJournalPrimaryAbilityTooltip.Delimiter2:SetHeight(1)
        PetJournalPrimaryAbilityTooltip.Delimiter2:SetColorTexture(0, 0, 0)
    end
end

module.rTips["Blizzard_PVPUI"] = function()
    if ConquestTooltip then
        styleTooltip(ConquestTooltip)
    end
end

module.rTips["Blizzard_Calendar"] = function()
    if CalendarContextMenu then
        styleTooltip(CalendarContextMenu)
    end
    if CalendarInviteStatusContextMenu then
        styleTooltip(CalendarInviteStatusContextMenu)
    end
end

module.rTips["Blizzard_EncounterJournal"] = function()
    if EncounterJournalTooltip then
        styleTooltip(EncounterJournalTooltip)
        EncounterJournalTooltip.Item1.icon:SetTexCoord(unpack(C.media.texCoord))
        EncounterJournalTooltip.Item1.IconBorder:SetAlpha(0)
        EncounterJournalTooltip.Item2.icon:SetTexCoord(unpack(C.media.texCoord))
        EncounterJournalTooltip.Item2.IconBorder:SetAlpha(0)
    end
end

------------------------------------------------------------------------
-- OnInit
------------------------------------------------------------------------
function module:OnInit()
    if not cfg.enable then return end
    if C_AddOns.IsAddOnLoaded("Aurora") then return end

    -- Style default tooltips
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

    -- Skin item tooltips and hooks
    skinItemTooltips()
    skinCompareTooltips()

    -- Anchor
    local anchor = CreateFrame("Frame", "DarkUI_TooltipAnchor", UIParent)
    anchor:SetSize(200, 40)
    anchor:SetPoint(unpack(cfg.position))

    hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
        if cfg.cursor then
            tooltip:SetOwner(parent, "ANCHOR_CURSOR_RIGHT", 20, 20)
        else
            tooltip:SetOwner(parent, "ANCHOR_NONE")
            tooltip:ClearAllPoints()
            tooltip:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 0, 0)
            tooltip.default = 1
        end
    end)

    -- Raid icon
    if cfg.raid_icon then
        local ricon = GameTooltip:CreateTexture("GameTooltipRaidIcon", "OVERLAY")
        ricon:SetSize(18, 18)
        ricon:SetPoint("CENTER", GameTooltip, "TOP", 0, 0)
        GameTooltip:HookScript("OnHide", function() ricon:SetTexture(nil) end)
        module.ricon = ricon
    end

    -- Shift modifier
    if cfg.shift_modifer then
        GameTooltip:SetScript("OnShow", function(tt)
            if IsShiftKeyDown() then
                tt:Show()
            else
                if not HoverBind.enabled then
                    tt:Hide()
                end
            end
        end)
    end

    -- Hide action bar tooltips
    if cfg.hideforactionbar then
        local function combatHideTooltip(tt)
            if not IsShiftKeyDown() then
                tt:Hide()
            end
        end
        hooksecurefunc(GameTooltip, "SetAction", combatHideTooltip)
        hooksecurefunc(GameTooltip, "SetPetAction", combatHideTooltip)
        hooksecurefunc(GameTooltip, "SetShapeshift", combatHideTooltip)
    end

    -- Drive inline health bar via Blizzard's internal status updates
    GameTooltipStatusBar:HookScript("OnValueChanged", function()
        if module.hpBar and module.hpUnit and module.hpBar:IsShown() then
            local unit = module.hpUnit
            module.hpBar:SetMinMaxValues(0, UnitHealthMax(unit))
            module.hpBar:SetValue(UnitHealth(unit))
            module.hpBar.text:SetText(E:AbbreviateNumber(UnitHealth(unit)))
        end
    end)

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, onTooltipSetUnit)

    -- Cleanup on hide
    GameTooltip:HookScript("OnTooltipCleared", function(tt)
        GameTooltip_ClearMoney(tt)
        GameTooltip_ClearStatusBars(tt)

        if module.hpBar then
            module.hpBar:Hide()
        end
        module.hpUnit = nil
    end)

    -- Menu skin
    local menuManagerProxy = Menu.GetManager()
    local function skinMenu(menuFrame)
        if menuFrame.styled then return end
        menuFrame:DisableDrawLayer("BACKGROUND")
        menuFrame:StripTextures()
        menuFrame:CreateBackdrop("Default")
        menuFrame.__backdrop:CreateShadow()
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

    -- Addon-loaded skins
    self:RegisterEvent("ADDON_LOADED", function(_, _, addon)
        if self.rTips[addon] then
            self.rTips[addon]()
            self.rTips[addon] = nil
        end
    end)
end
