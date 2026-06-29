local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Tooltip
------------------------------------------------------------------------
local module = E:Module("Tooltip")

local cfg = C.tooltip

local _G = _G
local CreateFrame = CreateFrame
local select, unpack = select, unpack
local hooksecurefunc = hooksecurefunc

local UnitFactionGroup = UnitFactionGroup
local UnitIsAFK, UnitIsDND = UnitIsAFK, UnitIsDND
local InCombatLockdown, IsShiftKeyDown = InCombatLockdown, IsShiftKeyDown
local GetCreatureDifficultyColor = GetCreatureDifficultyColor
local GetGuildInfo = GetGuildInfo
local UnitCreatureType, UnitClassification = UnitCreatureType, UnitClassification
local UnitIsBattlePetCompanion = UnitIsBattlePetCompanion
local UnitIsPlayer, UnitName, UnitPVPName, UnitClass, UnitRace, UnitLevel = UnitIsPlayer, UnitName, UnitPVPName, UnitClass, UnitRace, UnitLevel
local UnitIsUnit, UnitIsTapDenied, UnitIsDead, UnitReaction = UnitIsUnit, UnitIsTapDenied, UnitIsDead, UnitReaction
local UnitIsInMyGuild, UnitExists = UnitIsInMyGuild, UnitExists
local GetCVar = C_CVar.GetCVar

local C_PetBattles_GetNumAuras = C_PetBattles.GetNumAuras
local C_PetBattles_GetAuraInfo = C_PetBattles.GetAuraInfo

local LEVEL, FACTION_HORDE, FACTION_ALLIANCE = LEVEL, FACTION_HORDE, FACTION_ALLIANCE
local UNKNOWN, RANK, PVP_ENABLED = UNKNOWN, RANK, PVP_ENABLED
local RAID_CLASS_COLORS, CUSTOM_CLASS_COLORS = RAID_CLASS_COLORS, CUSTOM_CLASS_COLORS
local ENCOUNTER_JOURNAL_ENCOUNTER = ENCOUNTER_JOURNAL_ENCOUNTER
local FRIENDS_LIST_REALM = FRIENDS_LIST_REALM

local LEVEL_PATTERN = strlower(TOOLTIP_UNIT_LEVEL:gsub("%%s", ""))

local function getLevelLine(tooltip)
    for i = 2, tooltip:NumLines() do
        local line = _G["GameTooltipTextLeft" .. i]
        if not line then break end
        local text = line:GetText()
        if not text or not canaccessvalue(text) then break end
        if strfind(strlower(text), LEVEL_PATTERN) then return line, i end
    end
end

------------------------------------------------------------------------
-- Tooltip lists
------------------------------------------------------------------------
module.InfoColor = "|cff99ccff"

module.whiteTooltips = {
    [GameTooltip] = true,
    [ItemRefTooltip] = true,
    [ItemRefShoppingTooltip1] = true,
    [ItemRefShoppingTooltip2] = true,
    [ShoppingTooltip1] = true,
    [ShoppingTooltip2] = true,
}

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

        if not tt.__styled then
            if tt.NineSlice then tt.NineSlice:SetAlpha(0) end
            if tt.SetBackdrop then tt:SetBackdrop(nil) end
            if tt.BackdropFrame then tt.BackdropFrame:SetBackdrop(nil) end

            tt:DisableDrawLayer("BACKGROUND")

            tt:CreateBackdrop("default", 2, true)
            -- tt.backdrop:CreateGradient()
            tt.backdrop:CreateShadow()
            tt.backdrop:SetBackdropEdge("regular")

            local header = tt.CompareHeader
            if header then
                header:StripTextures()
                header:CreateBackdrop("default")
                header.backdrop:CreateGradient()
                header.backdrop:SetBackdropEdge("pixel", nil, 2)
            end

            tt.__styled = true
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
    local levelIsSecret = issecretvalue(level)
    local levelColor = not levelIsSecret and GetCreatureDifficultyColor(level) or nil
    local classification = UnitClassification(unit)
    local creatureType = UnitCreatureType(unit)
    local _, faction = UnitFactionGroup(unit)
    local _, playerFaction = UnitFactionGroup("player")
    local titleName = UnitPVPName(unit)
    local isPlayer = UnitIsPlayer(unit)

    if levelIsSecret then level = nil end
    if issecretvalue(creatureType) then creatureType = nil end

    if level and level == -1 then
        if classification == "worldboss" then
            level = "|cffff0000|r" .. ENCOUNTER_JOURNAL_ENCOUNTER
        else
            level = "|cffff0000??|r"
        end
    end

    if classification == "rareelite" then
        classification = " R+"
    elseif classification == "rare" then
        classification = " R"
    elseif classification == "elite" then
        classification = "+"
    else
        classification = ""
    end

    if isPlayer and titleName and cfg.title then name = titleName end

    local r, g, b = getUnitColor(unit)
    _G["GameTooltipTextLeft1"]:SetFormattedText("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, name or "")
    if realm and canaccessvalue(realm) and realm ~= "" and cfg.realm then self:AddLine(FRIENDS_LIST_REALM .. "|cffffffff" .. realm .. "|r") end

    if isPlayer then
        -- AFK/DND status can be a secret boolean on restricted units; guard the test.
        local afk, dnd = UnitIsAFK(unit), UnitIsDND(unit)
        if canaccessvalue(afk) and afk then
            self:AppendText((" %s"):format("|cffE7E716" .. L.CHAT_AFK .. "|r"))
        elseif canaccessvalue(dnd) and dnd then
            self:AppendText((" %s"):format("|cffFF0000" .. L.CHAT_DND .. "|r"))
        end
        if
            englishRace
            and canaccessvalue(englishRace)
            and faction
            and canaccessvalue(faction)
            and (englishRace == "Pandaren" or englishRace == "Dracthyr" or englishRace == "EarthenDwarf" or englishRace == "Harronir")
            and faction ~= playerFaction
        then
            local hex = "cffff3333"
            if faction == "Alliance" then hex = "cff69ccf0" end
            self:AppendText((" [|%s%s|r]"):format(hex, faction:sub(1, 2)))
        end

        local guildName, guildRank = GetGuildInfo(unit)
        if guildName then
            _G["GameTooltipTextLeft2"]:SetFormattedText("%s", guildName)
            local inGuild = UnitIsInMyGuild(unit)
            if canaccessvalue(inGuild) and inGuild then
                _G["GameTooltipTextLeft2"]:SetTextColor(1, 1, 0)
            else
                _G["GameTooltipTextLeft2"]:SetTextColor(0, 1, 1)
            end
            if cfg.rank then self:AddLine(RANK .. ": |cffffffff" .. guildRank .. "|r") end
        end

        if levelColor then
            local levelLine = getLevelLine(self)
            if levelLine then
                if GetCVar("colorblindMode") == "1" then
                    local class = UnitClass(unit)
                    levelLine:SetFormattedText(
                        "|cff%02x%02x%02x%s|r %s %s",
                        levelColor.r * 255,
                        levelColor.g * 255,
                        levelColor.b * 255,
                        level,
                        race or UNKNOWN,
                        class or ""
                    )
                else
                    levelLine:SetFormattedText("|cff%02x%02x%02x%s|r %s", levelColor.r * 255, levelColor.g * 255, levelColor.b * 255, level, race or UNKNOWN)
                end
            end
        end
    else
        if levelColor then
            local isBattlePet = UnitIsBattlePetCompanion(unit)
            isBattlePet = canaccessvalue(isBattlePet) and isBattlePet
            for i = 2, lines do
                local line = _G["GameTooltipTextLeft" .. i]
                if not line or not line:GetText() or isBattlePet then break end
                local text = line:GetText()
                if not canaccessvalue(text) then break end
                if (level and text:find("^" .. LEVEL)) or (creatureType and text:find("^" .. creatureType)) then
                    line:SetFormattedText(
                        "|cff%02x%02x%02x%s%s|r %s",
                        levelColor.r * 255,
                        levelColor.g * 255,
                        levelColor.b * 255,
                        level,
                        classification,
                        creatureType or ""
                    )
                    break
                end
            end
        end
    end

    for i = 2, lines do
        local line = _G["GameTooltipTextLeft" .. i]
        if not line or not line:GetText() then return end
        local text = line:GetText()
        if text and canaccessvalue(text) and (text == FACTION_HORDE or text == FACTION_ALLIANCE or text == PVP_ENABLED or text == UNIT_POPUP_RIGHT_CLICK) then
            line:SetText()
        end
    end

    -- Setup inline health bar
    local deadOrGhost = UnitIsDeadOrGhost(unit)
    if canaccessvalue(deadOrGhost) and not deadOrGhost then
        local bar = GameTooltip.StatusBar
        if bar then
            local r, g, b = getUnitColor(unit)
            bar:SetStatusBarColor(r, g, b)
        end
    end
end

------------------------------------------------------------------------
-- Skin helpers (called from OnInit)
------------------------------------------------------------------------
local function skinItemTooltips()
    GameTooltip.ItemTooltip.Icon:SetTexCoord(unpack(C.media.texCoord))

    GameTooltip.ItemTooltip.Icon:CreateBackdrop("default")
    local itemBD = GameTooltip.ItemTooltip.Icon.backdrop
    itemBD:SetPoint("TOPLEFT", GameTooltip.ItemTooltip.Icon, "TOPLEFT", -2, 2)
    itemBD:SetPoint("BOTTOMRIGHT", GameTooltip.ItemTooltip.Icon, "BOTTOMRIGHT", 2, -2)

    hooksecurefunc(GameTooltip.ItemTooltip.IconBorder, "SetVertexColor", function(self, r, g, b)
        if r ~= BAG_ITEM_QUALITY_COLORS[1].r and g ~= BAG_ITEM_QUALITY_COLORS[1].g then itemBD:SetBackdropBorderColor(r, g, b) end
        self:SetTexture("")
    end)

    hooksecurefunc(GameTooltip.ItemTooltip.IconBorder, "Hide", function() itemBD:SetBackdropBorderColor(unpack(C.media.border_color)) end)
    GameTooltip.ItemTooltip.Count:ClearAllPoints()
    GameTooltip.ItemTooltip.Count:SetPoint("BOTTOMRIGHT", GameTooltip.ItemTooltip.Icon, "BOTTOMRIGHT", 1, 0)

    BONUS_OBJECTIVE_REWARD_FORMAT = "|T%1$s:16:16:0:0:64:64:5:59:5:59|t %2$s"
    BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT = "|T%1$s:16:16:0:0:64:64:5:59:5:59|t |cffffffff%2$d|r %3$s"

    local reward = EmbeddedItemTooltip.ItemTooltip
    local icon = reward.Icon
    if icon then
        icon:SetTexCoord(unpack(C.media.texCoord))
        icon:CreateBackdrop("default")
        local rewardBD = icon.backdrop
        rewardBD:SetPoint("TOPLEFT", icon, "TOPLEFT", -2, 2)
        rewardBD:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)

        hooksecurefunc(reward.IconBorder, "SetVertexColor", function(self, r, g, b)
            if r ~= BAG_ITEM_QUALITY_COLORS[1].r and g ~= BAG_ITEM_QUALITY_COLORS[1].g then rewardBD:SetBackdropBorderColor(r, g, b) end
            self:SetTexture("")
        end)
        hooksecurefunc(reward.IconBorder, "Hide", function() rewardBD:SetBackdropBorderColor(unpack(C.media.border_color)) end)
    end

    hooksecurefunc("GameTooltip_ShowProgressBar", function(tt)
        if not tt or tt:IsForbidden() or not tt.progressBarPool then return end
        local frame = tt.progressBarPool:GetNextActive()
        if (not frame or not frame.Bar) or frame.Bar.backdrop then return end
        local bar = frame.Bar
        local label = bar.Label
        if bar then
            bar:StripTextures()
            bar:CreateBackdrop("transparent")
            bar.backdrop:SetBackdropColor(0.1, 0.1, 0.1, 1)
            bar:SetStatusBarTexture(C.media.texture.status)
            label:ClearAllPoints()
            label:SetPoint("CENTER", bar, 0, 0)
            label:SetDrawLayer("OVERLAY")
            label:SetFont(unpack(C.media.standard_font))
        end
    end)
end

local function fixTooltipMoney()
    -- WoW 12.0: money amounts are secret values, and Blizzard's MoneyFrame_Update
    -- does width arithmetic on them that crashes under addon taint (e.g. when our
    -- loot/tooltip code triggers GameTooltip:SetLootItem). Replace SetTooltipMoney
    -- with a coin-text line so all money formatting stays inside the secure
    -- C_CurrencyInfo function and never touches a tainted MoneyFrame widget.
    function SetTooltipMoney(frame, money, _, prefixText, suffixText)
        frame:AddLine((prefixText or "") .. " " .. C_CurrencyInfo.GetCoinTextureString(money) .. " " .. (suffixText or ""), 1, 1, 1)
    end
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
                if frame and frame.Icon then frame.Icon:SetTexCoord(unpack(C.media.texCoord)) end
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
    if ConquestTooltip then styleTooltip(ConquestTooltip) end
end

module.rTips["Blizzard_Calendar"] = function()
    if CalendarContextMenu then styleTooltip(CalendarContextMenu) end
    if CalendarInviteStatusContextMenu then styleTooltip(CalendarInviteStatusContextMenu) end
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

    -- Tooltip fonts
    local font, fontSize, fontOutline = unpack(C.media.standard_font)
    GameTooltipHeaderText:SetFont(font, fontSize, fontOutline)
    GameTooltipText:SetFont(font, fontSize - 2, fontOutline)
    GameTooltipTextSmall:SetFont(font, fontSize - 4, fontOutline)

    -- Skin item tooltips and hooks
    skinItemTooltips()
    fixTooltipMoney()

    -- Re-apply our backdrop after Blizzard sets Azerite/Corrupted item styles
    hooksecurefunc("SharedTooltip_SetBackdropStyle", function(tt)
        if tt and not tt:IsForbidden() and tt.__styled and tt.backdrop then tt.backdrop:Show() end
    end)

    -- Anchor
    local anchor = CreateFrame("Frame", "DarkUI_TooltipAnchor", UIParent)
    anchor:SetSize(200, 40)
    anchor:SetPoint(unpack(cfg.position))

    hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
        if tooltip:IsForbidden() then return end
        if not parent or parent:IsForbidden() then return end
        if cfg.hide_combat and InCombatLockdown() and not IsShiftKeyDown() then
            tooltip:Hide()
            return
        end
        if cfg.hideforactionbar and parent and parent.action and not IsShiftKeyDown() then
            tooltip:Hide()
            return
        end
        if cfg.cursor then
            tooltip:SetOwner(parent, "ANCHOR_CURSOR_RIGHT", 20, 20)
        else
            tooltip:SetOwner(parent, "ANCHOR_NONE")
            tooltip:ClearAllPoints()
            tooltip:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 0, 0)
            tooltip.default = 1
        end
    end)

    -- Shift modifier
    if cfg.shift_modifer then
        GameTooltip:HookScript("OnShow", function(tt)
            if not IsShiftKeyDown() and not (HoverBind and HoverBind.enabled) then tt:Hide() end
        end)
    end

    -- Restyle native StatusBar
    local statusBar = GameTooltip.StatusBar
    if statusBar then
        GameTooltipStatusBar:SetScript("OnValueChanged", nil)
        statusBar:ClearAllPoints()
        statusBar:SetPoint("BOTTOMLEFT", GameTooltip, "TOPLEFT", 2, 8)
        statusBar:SetPoint("BOTTOMRIGHT", GameTooltip, "TOPRIGHT", -2, 8)
        statusBar:SetStatusBarTexture(C.media.texture.status)
        statusBar:SetHeight(5)

        statusBar:CreateBackdrop("default", 2)
        statusBar.backdrop:SetBackdropEdge("pixel")

        if cfg.health_value then
            statusBar.text = statusBar:CreateFontString(nil, "OVERLAY")
            statusBar.text:SetFont(STANDARD_TEXT_FONT, 12, "THINOUTLINE")
            statusBar.text:SetAllPoints()
            statusBar.text:SetJustifyH("CENTER")
        end

        hooksecurefunc(statusBar, "UpdateUnitHealth", function(self)
            if not self.text then return end
            local data = GameTooltip:GetTooltipData()
            local guid = data and data.guid
            local unit = guid and canaccessvalue(guid) and UnitTokenFromGUID(guid)
            if not unit then unit = UnitExists("mouseover") and "mouseover" end
            if unit then
                local ok, value = pcall(UnitHealth, unit)
                if ok and value then
                    self.text:SetText(E:AbbreviateNumber(value))
                else
                    self.text:SetText("")
                end
            else
                self.text:SetText("")
            end
        end)
    end

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, onTooltipSetUnit)

    -- Cleanup on hide
    GameTooltip:HookScript("OnTooltipCleared", function(tt)
        GameTooltip_ClearMoney(tt)
        GameTooltip_ClearStatusBars(tt)
    end)

    -- Menu skin (guard via external table — frame pool wipes custom fields)
    local menuManagerProxy = Menu.GetManager()
    local menuBackdrops = {}
    local function skinMenu(menuFrame)
        menuFrame:DisableDrawLayer("BACKGROUND")
        menuFrame:StripTextures()

        local bd = menuBackdrops[menuFrame]
        if not bd then
            bd = menuFrame:CreateBackdrop("Default", 8, true)
            bd:CreateShadow()
            bd:SetBackdropEdge("regular")
            menuBackdrops[menuFrame] = bd
        else
            menuFrame.backdrop = bd
        end

        local lvl = menuFrame:GetFrameLevel() - 1
        bd:SetFrameLevel(lvl < 0 and 0 or lvl)
    end
    local function setupMenu(manager, _, menuDescription)
        local menuFrame = manager:GetOpenMenu()
        if menuFrame then
            skinMenu(menuFrame)
            menuDescription:AddMenuAcquiredCallback(skinMenu)
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
