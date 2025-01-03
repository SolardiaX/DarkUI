﻿local E, C, L = select(2, ...):unpack()

if not C.aura.auraWatch.enable then return end

----------------------------------------------------------------------------------------
--    AuraWatch (Modified from NDUI)
----------------------------------------------------------------------------------------
local module = E:Module("Aura"):Sub("AuraWatch")

local LBG = LibStub("LibButtonGlow-1.0", true)

local CreateFrame = CreateFrame
local InCombatLockdown, UnitBuff, UnitDebuff, GetPlayerInfoByGUID, UnitInRaid, UnitInParty = InCombatLockdown, UnitBuff, UnitDebuff, GetPlayerInfoByGUID, UnitInRaid, UnitInParty
local GetTime = GetTime
local GetSpellName = C_Spell.GetSpellName
local GetSpellTexture = C_Spell.GetSpellTexture
local GetSpellCooldown = C_Spell.GetSpellCooldown
local GetSpellCharges = C_Spell.GetSpellCharges
local GetTotemInfo, IsPlayerSpell = GetTotemInfo, IsPlayerSpell
local C_UnitAuras_GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex
local GetItemCooldown, GetItemInfo, GetInventoryItemLink, GetInventoryItemCooldown = GetItemCooldown, GetItemInfo, GetInventoryItemLink, GetInventoryItemCooldown
local GameTooltip_Hide = GameTooltip_Hide
local PlaySound = PlaySound
local RegisterStateDriver = RegisterStateDriver
local pairs, select, tinsert, tremove, wipe = pairs, select, table.insert, table.remove, table.wipe
local unpack = unpack
local UIParent = _G.UIParent
local GameTooltip = _G.GameTooltip

local maxFrames = 12 -- Max Tracked Auras
local AuraList, FrameList, UnitIDTable, IntTable, IntCD, myTable, cooldownTable = {}, {}, {}, {}, {}, {}, {}
local updater = CreateFrame("Frame")

local bit_bor = bit.bor

local MyPetFlags = bit_bor(COMBATLOG_OBJECT_AFFILIATION_MINE, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PET)
local PartyPetFlags = bit_bor(COMBATLOG_OBJECT_AFFILIATION_PARTY, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PET)
local RaidPetFlags = bit_bor(COMBATLOG_OBJECT_AFFILIATION_RAID, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PET)

-- DataConvert
local function DataAnalyze(v)
    local newTable = {}
    if type(v[1]) == "number" then
        newTable.IntID = v[1]
        newTable.Duration = v[2]
        if v[3] == "OnCastSuccess" then
            newTable.OnSuccess = true
        elseif v[3] == "UnitCastSucceed" then
            newTable.CastSucceed = true
        end
        newTable.UnitID = v[4]
        newTable.ItemID = v[5]
    else
        newTable[v[1]] = v[2]
        newTable.UnitID = v[3]
        newTable.Caster = v[4]
        newTable.Stack = v[5]
        newTable.Value = v[6]
        newTable.Timeless = v[7]
        newTable.Combat = v[8]
        newTable.Text = v[9]
        newTable.Flash = v[10]
    end

    return newTable
end

local function InsertData(index, target)
    if SavedStatsPerChar["AuraWatch"]["Switcher"][index] then
        wipe(target)
    end
    for spellID, v in pairs(myTable[index]) do
        local value = target[spellID]
        if value and value.AuraID == v.AuraID then
            value = nil
        end
        target[spellID] = v
    end
end

local function ConvertTable()
    for i = 1, 10 do
        myTable[i] = {}
        if i < 10 then
            local value = SavedStatsPerChar["AuraWatch"]["AuraWatchList"][i]
            if value and next(value) then
                for spellID, v in pairs(value) do
                    myTable[i][spellID] = DataAnalyze(v)
                end
            end

        else
            if next(SavedStatsPerChar["AuraWatch"]["InternalCD"]) then
                for spellID, v in pairs(SavedStatsPerChar["AuraWatch"]["InternalCD"]) do
                    myTable[i][spellID] = DataAnalyze(v)
                end
            end
        end
    end

    for _, v in pairs(C.aura.auraWatch[E.myClass]) do
        if v.Name == "Player Aura" then
            InsertData(1, v.List)
        elseif v.Name == "Target Aura" then
            InsertData(3, v.List)
        elseif v.Name == "Special Aura" then
            InsertData(2, v.List)
        elseif v.Name == "Focus Aura" then
            InsertData(5, v.List)
        elseif v.Name == "Spell Cooldown" then
            InsertData(6, v.List)
        end
    end

    for i, v in pairs(C.aura.auraWatch["ALL"]) do
        if v.Name == "Enchant Aura" then
            InsertData(7, v.List)
        elseif v.Name == "Raid Buff" then
            InsertData(8, v.List)
        elseif v.Name == "Raid Debuff" then
            InsertData(9, v.List)
        elseif v.Name == "Warning" then
            InsertData(4, v.List)
        elseif v.Name == "InternalCD" then
            InsertData(10, v.List)
            IntCD = v
            tremove(C.aura.auraWatch["ALL"], i)
        end
    end
end

local function BuildAuraList()
    AuraList = C.aura.auraWatch["ALL"] or {}
    for class in pairs(C.aura.auraWatch) do
        if class == E.myClass then
            for _, value in pairs(C.aura.auraWatch[class]) do
                tinsert(AuraList, value)
            end
        end
    end
    --wipe(C.aura.auraWatch)
end

local function BuildUnitIDTable()
    for _, VALUE in pairs(AuraList) do
        for _, value in pairs(VALUE.List) do
            local Flag = true
            for _, v in pairs(UnitIDTable) do
                if value.UnitID == v then Flag = false end
            end
            if Flag then tinsert(UnitIDTable, value.UnitID) end
        end
    end
end

local function BuildCooldownTable()
    wipe(cooldownTable)

    for KEY, VALUE in pairs(AuraList) do
        for spellID, value in pairs(VALUE.List) do
        if value.SpellID and IsPlayerSpell(value.SpellID) or value.ItemID or value.SlotID or value.TotemID then
                if not cooldownTable[KEY] then cooldownTable[KEY] = {} end
                cooldownTable[KEY][spellID] = true
            end
        end
    end
end

local function MakeMoveHandle(frame, text, value, anchor)
    local MoveHandle = CreateFrame("Frame", nil, UIParent)
    MoveHandle:SetWidth(frame:GetWidth())
    MoveHandle:SetHeight(frame:GetHeight())
    MoveHandle:SetFrameStrata("HIGH")
    MoveHandle:CreateBackdrop()
    MoveHandle:CreateFontText(12, text)
    if not SavedStatsPerChar["AuraWatch"]["Position"][value] then
        MoveHandle:SetPoint(unpack(anchor))
    else
        MoveHandle:SetPoint(unpack(SavedStatsPerChar["AuraWatch"]["Position"][value]))
    end
    MoveHandle:EnableMouse(true)
    MoveHandle:SetMovable(true)
    MoveHandle:RegisterForDrag("LeftButton")
    MoveHandle:SetScript("OnDragStart", function() MoveHandle:StartMoving() end)
    MoveHandle:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local AnchorF, _, AnchorT, X, Y = self:GetPoint()
        SavedStatsPerChar["AuraWatch"]["Position"][value] = { AnchorF, "UIParent", AnchorT, X, Y }
    end)
    MoveHandle:Hide()
    frame:SetPoint("CENTER", MoveHandle)
    return MoveHandle
end

local function tooltipOnEnter(self)
    GameTooltip:ClearLines()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 3)
    if self.type == 1 then
        GameTooltip:SetSpellByID(self.spellID)
    elseif self.type == 2 then
        GameTooltip:SetHyperlink(select(2, GetItemInfo(self.spellID)))
    elseif self.type == 3 then
        GameTooltip:SetInventoryItem("player", self.spellID)
    elseif self.type == 4 then
        GameTooltip:SetUnitAura(self.unit, self.index, self.filter)
    elseif self.type == 5 then
        GameTooltip:SetTotem(self.spellID)
    end
    GameTooltip:Show()
end

local function enableTooltip(self)
    self:EnableMouse(true)
    self.HL = self:CreateTexture(nil, "HIGHLIGHT")
    self.HL:SetColorTexture(1, 1, 1, .25)
    self.HL:SetAllPoints(self.Icon)
    self:SetScript("OnEnter", tooltipOnEnter)
    self:SetScript("OnLeave", GameTooltip_Hide)
end


-- Icon mode
local function BuildICON(iconSize)
    iconSize = iconSize * C.aura.auraWatch.iconScale

    local frame = CreateFrame("Frame", nil, E.PetBattleFrameHider)
    frame:SetSize(iconSize, iconSize)
    frame:Hide()

    E:ApplyOverlayBorder(frame, 2)

    frame.Icon = frame:CreateTexture(nil, "ARTWORK")
    frame.Icon:SetPoint("TOPLEFT", frame, 2, -2)
    frame.Icon:SetPoint("BOTTOMRIGHT", frame, -2, 2)
    frame.Icon:SetTexCoord(unpack(C.media.texCoord))
    frame.Icon:SetDrawLayer("BACKGROUND", -8)

    frame.Cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    frame.Cooldown:SetPoint("CENTER", 0, 0)
    frame.Cooldown:SetReverse(true)

    local parentFrame = CreateFrame("Frame", nil, frame)
    parentFrame:SetAllPoints()
    parentFrame:SetFrameLevel(frame:GetFrameLevel() + 6)
    frame.Spellname = parentFrame:CreateFontText(13, "", false, "TOP", 0, 5)
    frame.Count = parentFrame:CreateFontText(iconSize * .55, "", false, "BOTTOMRIGHT", 6, -3)
    
    frame:CreateBackground(4)
    frame.bg:SetSize(iconSize + 8, iconSize + 8)

    if not C.aura.auraWatch.clickThrough then enableTooltip(frame) end

    return frame
end

-- Bar mode
local function BuildBAR(barWidth, iconSize)
    local frame = CreateFrame("Frame", nil, E.PetBattleFrameHider)
    frame:SetSize(iconSize, iconSize)
    E:ApplyOverlayBorder(frame, 2)

    frame.Icon = frame:CreateTexture(nil, "ARTWORK")
    frame.Icon:SetPoint("TOPLEFT", frame, 2, -2)
    frame.Icon:SetPoint("BOTTOMRIGHT", frame, -2, 2)
    frame.Icon:SetTexCoord(unpack(C.media.texCoord))
    frame.Icon:SetDrawLayer("BACKGROUND", -8)

    frame.Statusbar = CreateFrame("StatusBar", nil, frame)
    frame.Statusbar:SetSize(barWidth, iconSize / 2.5)
    frame.Statusbar:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 5, 0)
    frame.Statusbar:SetMinMaxValues(0, 1)
    frame.Statusbar:SetValue(0)
    frame.Statusbar:SetStatusBarTexture(C.media.texture.gradient)
    frame.Statusbar:SetStatusBarColor(E.myColor.r, E.myColor.g, E.myColor.b)
    frame.Statusbar:SetTemplate("Default")
    frame.Statusbar:CreateShadow()

    frame.Statusbar.Spark = frame.Statusbar:CreateTexture(nil, "OVERLAY")
    frame.Statusbar.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
    frame.Statusbar.Spark:SetBlendMode("ADD")
    frame.Statusbar.Spark:SetAlpha(.8)
    frame.Statusbar.Spark:SetPoint("TOPLEFT", frame.Statusbar:GetStatusBarTexture(), "TOPRIGHT", -10, 10)
    frame.Statusbar.Spark:SetPoint("BOTTOMRIGHT", frame.Statusbar:GetStatusBarTexture(), "BOTTOMRIGHT", 10, -10)

    frame.Count = frame:CreateFontText(14, "", false, "BOTTOMRIGHT", 3, -1)
    frame.Time = frame.Statusbar:CreateFontText(14, "", false, "RIGHT", 0, 8)
    frame.Spellname = frame.Statusbar:CreateFontText(14, "", false, "LEFT", 2, 8)
    frame.Spellname:SetWidth(frame.Statusbar:GetWidth() * .6)
    frame.Spellname:SetJustifyH("LEFT")
    frame.Spellname:SetJustifyH("LEFT")
    if not C.aura.auraWatch.clickThrough then enableTooltip(frame) end

    frame:Hide()
    return frame
end

-- List and anchor
local function BuildAura()
    for key, value in pairs(AuraList) do
        local frameTable = {}
        for i = 1, maxFrames do
            if value.Mode== "ICON" then
                local frame = BuildICON(value.IconSize)
                if i == 1 then frame.MoveHandle = MakeMoveHandle(frame, value.Name, key, value.Pos) end
                tinsert(frameTable, frame)
            elseif value.Mode == "BAR" then
                local frame = BuildBAR(value.BarWidth, value.IconSize)
                if i == 1 then frame.MoveHandle = MakeMoveHandle(frame, value.Name, key, value.Pos) end
                tinsert(frameTable, frame)
            end
        end
        frameTable.Index = 1
        tinsert(FrameList, frameTable)
    end
end

local function SetupAnchor()
    for key, VALUE in pairs(FrameList) do
        local value = AuraList[key]
        if not value then return end
        local direction, interval = value.Direction, value.Interval
        -- check whether using CENTER direction
        if value.Mode == "BAR" and direction == "CENTER" then
            direction = "UP" -- sorry, no "CENTER" for bars mode
        end
        if not hasCentralize then
            hasCentralize = direction == "CENTER"
        end

        local previous
        for i = 1, #VALUE do
            local frame = VALUE[i]
            if i == 1 then
                frame:SetPoint("CENTER", frame.MoveHandle)
                frame.__direction = direction
                frame.__interval = interval
            elseif (value.Name == "Target Aura" or value.Name == "Enchant Aura") and i == 7 and direction ~= "CENTER" then
                frame:SetPoint("BOTTOM", VALUE[1], "TOP", 0, interval)
            else
                if direction == "RIGHT" or direction == "CENTER" then
                    frame:SetPoint("LEFT", previous, "RIGHT", interval, 0)
                elseif direction == "LEFT" then
                    frame:SetPoint("RIGHT", previous, "LEFT", -interval, 0)
                elseif direction == "UP" then
                    frame:SetPoint("BOTTOM", previous, "TOP", 0, interval)
                elseif direction == "DOWN" then
                    frame:SetPoint("TOP", previous, "BOTTOM", 0, -interval)
                end
            end
            previous = frame
        end
    end
end

local function InitSetup()
    ConvertTable()
    BuildAuraList()
    BuildUnitIDTable()
    BuildCooldownTable()
    BuildAura()
    SetupAnchor()
end

-- Update timer
function module:AuraWatch_UpdateTimer()
    if self.expires then
        self.elapsed = self.expires - GetTime()
    else
        self.elapsed = self.start + self.duration - GetTime()
    end
    
    local timer = self.elapsed
    if timer < 0 then
        if self.Time then self.Time:SetText("N/A") end
        self.Statusbar:SetMinMaxValues(0, 1)
        self.Statusbar:SetValue(0)
        self.Statusbar.Spark:Hide()
    elseif timer < 60 then
        if self.Time then self.Time:SetFormattedText("%.1f", timer) end
        self.Statusbar:SetMinMaxValues(0, self.duration)
        self.Statusbar:SetValue(timer)
        self.Statusbar.Spark:Show()
    else
        if self.Time then self.Time:SetFormattedText("%d:%.2d", timer / 60, timer % 60) end
        self.Statusbar:SetMinMaxValues(0, self.duration)
        self.Statusbar:SetValue(timer)
        self.Statusbar.Spark:Show()
    end
end

-- Update cooldown
function module:AuraWatch_SetupCD(index, name, icon, start, duration, _, type, id, charges)
    local frames = FrameList[index]
    local frame = frames[frames.Index]
    if frame then frame:Show() end
    if frame.Icon then frame.Icon:SetTexture(icon) end
    if frame.Cooldown then
        frame.Cooldown:SetReverse(false)
        frame.Cooldown:SetCooldown(start, duration)
        frame.Cooldown:Show()
    end
    if frame.Count then frame.Count:SetText(charges) end
    if frame.Spellname then frame.Spellname:SetText(name) end
    if frame.Statusbar then
        frame.duration = duration
        frame.start = start
        frame.elapsed = 0
        frame:SetScript("OnUpdate", module.AuraWatch_UpdateTimer)
    end
    frame.type = type
    frame.spellID = id

    frames.Index = (frames.Index + 1 > maxFrames) and maxFrames or frames.Index + 1
end

function module:AuraWatch_UpdateCD()
    for KEY, VALUE in pairs(cooldownTable) do
        for spellID in pairs(VALUE) do
            local group = AuraList[KEY]
            local value = group.List[spellID]
            if value then
                if value.SpellID then
                    local name, icon = GetSpellName(value.SpellID), GetSpellTexture(value.SpellID)

                    local cooldownInfo = C_Spell.GetSpellCooldown(value.SpellID)
                    local start = cooldownInfo and cooldownInfo.startTime
                    local duration = cooldownInfo and cooldownInfo.duration

                    local chargeInfo = C_Spell.GetSpellCharges(spellID)
                    local charges = chargeInfo and chargeInfo.currentCharges
                    local maxCharges = chargeInfo and chargeInfo.maxCharges
                    local chargeStart = chargeInfo and chargeInfo.cooldownStartTime
                    local chargeDuration = chargeInfo and chargeInfo.cooldownDuration
                    
                    if group.Mode == "ICON" then name = nil end
                    if charges and maxCharges and maxCharges > 1 and charges < maxCharges then
                        module:AuraWatch_SetupCD(KEY, name, icon, chargeStart, chargeDuration, true, 1, value.SpellID, charges)
                    elseif start and duration > 1.5 then
                        module:AuraWatch_SetupCD(KEY, name, icon, start, duration, true, 1, value.SpellID)
                    end
                elseif value.ItemID then
                    local start, duration = GetItemCooldown(value.ItemID)
                    if start and duration > 1.5 then
                        local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(value.ItemID)
                        if group.Mode == "ICON" then name = nil end
                        module:AuraWatch_SetupCD(KEY, name, icon, start, duration, false, 2, value.ItemID)
                    end
                elseif value.SlotID then
                    local link = GetInventoryItemLink("player", value.SlotID)
                    if link then
                        local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(link)
                        local start, duration = GetInventoryItemCooldown("player", value.SlotID)
                        if duration > 1.5 then
                            if group.Mode == "ICON" then name = nil end
                            module:AuraWatch_SetupCD(KEY, name, icon, start, duration, false, 3, value.SlotID)
                        end
                    end
                elseif value.TotemID then
                    local haveTotem, name, start, duration, icon = GetTotemInfo(value.TotemID)
                    if haveTotem then
                        if group.Mode == "ICON" then name = nil end
                        module:AuraWatch_SetupCD(KEY, name, icon, start, duration, false, 1, value.TotemID)
                    end
                end
            end
        end
    end
end

-- UpdateAura
function module:AuraWatch_SetupAura(KEY, unit, index, filter, name, icon, count, duration, expires, spellID, flash)
    if not KEY then return end

    local frames = FrameList[KEY]
    local frame = frames[frames.Index]
    if frame then frame:Show() end
    if frame.Icon then frame.Icon:SetTexture(icon) end
    if frame.Count then frame.Count:SetText(count > 1 and count or "") end
    if frame.Cooldown then
        frame.Cooldown:SetReverse(true)
        frame.Cooldown:SetCooldown(expires - duration, duration)
    end
    if frame.Spellname then frame.Spellname:SetText(name) end
    if frame.Statusbar then
        frame.duration = duration
        frame.expires = expires
        frame.elapsed = 0
        frame:SetScript("OnUpdate", module.AuraWatch_UpdateTimer)
    end
    if frame.bg then
        if flash then
            LBG.ShowOverlayGlow(frame.bg)
        else
            LBG.HideOverlayGlow(frame.bg)
        end
    end
    frame.type = 4
    frame.unit = unit
    frame.index = index
    frame.filter = filter
    frame.spellID = spellID

    frames.Index = (frames.Index + 1 > maxFrames) and maxFrames or frames.Index + 1
end

function module:AuraWatch_UpdateAura(unit, index, filter, name, icon, count, duration, expires, caster, spellID, number, inCombat)
    for KEY, VALUE in pairs(AuraList) do
        local value = VALUE.List[spellID]
        if value and value.AuraID and value.UnitID == unit then
            if value.Combat and not inCombat then return end
            if value.Caster and value.Caster ~= caster then return end
            if value.Stack and count and value.Stack > count then return end
            if value.Value and number then
                if VALUE.Mode == "ICON" then
                    name = E:ShortValue(number)
                elseif VALUE.Mode == "BAR" then
                    name = name..":"..E:ShortValue(number)
                end
            else
                if VALUE.Mode == "ICON" then
                    name = value.Text or nil
                elseif VALUE.Mode == "BAR" then
                    name = name
                end
            end
            if value.Timeless then duration, expires = 0, 0 end
            module:AuraWatch_SetupAura(KEY, unit, index, filter, name, icon, count, duration, expires, spellID, value.Flash)
            return
        end
    end
end

function module:UpdateAuraWatchByFilter(unit, filter, inCombat)
    local index = 1

    while true do
        local auraData = C_UnitAuras_GetAuraDataByIndex(unit, index, filter)
        if not auraData then break end
        module:AuraWatch_UpdateAura(unit, index, filter, auraData.name, auraData.icon, auraData.applications, auraData.duration, auraData.expirationTime, auraData.sourceUnit, auraData.spellId, (auraData.points[1] == 0 and tonumber(auraData.points[2]) or tonumber(auraData.points[1])), inCombat)

        index = index + 1
    end
end

function module:UpdateAuraWatch(unit, inCombat)
    module:UpdateAuraWatchByFilter(unit, "HELPFUL", inCombat)
    module:UpdateAuraWatchByFilter(unit, "HARMFUL", inCombat)
end

-- Update InternalCD
function module:AuraWatch_SortBars()
    if not IntCD.MoveHandle then
        IntCD.MoveHandle = MakeMoveHandle(IntTable[1], IntCD.Name, "InternalCD", IntCD.Pos)
    end

    for i = 1, #IntTable do
        IntTable[i]:ClearAllPoints()
        if i == 1 then
            IntTable[i]:SetPoint("CENTER", IntCD.MoveHandle)
        elseif IntCD.Direction == "RIGHT" then
            IntTable[i]:SetPoint("LEFT", IntTable[i - 1], "RIGHT", IntCD.Interval, 0)
        elseif IntCD.Direction == "LEFT" then
            IntTable[i]:SetPoint("RIGHT", IntTable[i - 1], "LEFT", -IntCD.Interval, 0)
        elseif IntCD.Direction == "UP" then
            IntTable[i]:SetPoint("BOTTOM", IntTable[i - 1], "TOP", 0, IntCD.Interval)
        elseif IntCD.Direction == "DOWN" then
            IntTable[i]:SetPoint("TOP", IntTable[i - 1], "BOTTOM", 0, -IntCD.Interval)
        end
        IntTable[i].ID = i
    end
end

function module:AuraWatch_IntTimer(elapsed)
    self.elapsed = self.elapsed + elapsed
    local timer = self.duration - self.elapsed
    if timer < 0 then
        self:SetScript("OnUpdate", nil)
        self:Hide()
        tremove(IntTable, self.ID)
        module:AuraWatch_SortBars()
    elseif timer < 60 then
        if self.Time then
            self.Time:SetFormattedText("%.1f", timer)
        end
        self.Statusbar:SetValue(timer)
        self.Statusbar.Spark:Show()
    else
        if self.Time then
            self.Time:SetFormattedText("%d:%.2d", timer / 60, timer % 60)
        end
        self.Statusbar:SetValue(timer)
        self.Statusbar.Spark:Show()
    end
end

function module:AuraWatch_SetupInt(intID, itemID, duration, unitID, guid, sourceName)
    if not E.PetBattleFrameHider:IsShown() then return end
    local frame = BuildBAR(IntCD.BarWidth, IntCD.IconSize)
    if frame then
        frame:Show()
        tinsert(IntTable, frame)
        module:AuraWatch_SortBars()
    end
    local name, icon, _, class
    if itemID then
        name, _, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)
        frame.type = 2
        frame.spellID = itemID
    else
        name, icon = GetSpellName(intID), GetSpellTexture(intID)
        frame.type = 1
        frame.spellID = intID
    end
    if unitID:lower() == "all" then
        class = select(2, GetPlayerInfoByGUID(guid))
        name = "*" .. sourceName
    else
        class = E.myClass
    end
    if frame.Icon then
        frame.Icon:SetTexture(icon)
    end
    if frame.Count then
        frame.Count:SetText(nil)
    end
    if frame.Cooldown then
        frame.Cooldown:SetReverse(true)
        frame.Cooldown:SetCooldown(GetTime(), duration)
    end
    if frame.Spellname then
        frame.Spellname:SetText(name)
    end
    if frame.Statusbar then
        frame.Statusbar:SetStatusBarColor(E.myColor.r, E.myColor.g, E.myColor.b)
        frame.Statusbar:SetMinMaxValues(0, duration)
        frame.elapsed = 0
        frame.duration = duration
        frame:SetScript("OnUpdate", module.AuraWatch_IntTimer)
    end
end

local eventList = {
    ["SPELL_AURA_APPLIED"] = true,
    ["SPELL_AURA_REFRESH"] = true,
}

local function checkPetFlags(sourceFlags, all)
    if sourceFlags == MyPetFlags or (all and (sourceFlags == PartyPetFlags or sourceFlags == RaidPetFlags)) then
        return true
    end
end

function module:IsUnitWeNeed(value, guid, name, flags)
    if not value.UnitID then value.UnitID = "Player" end
    if value.UnitID:lower() == "all" then
        if name and (UnitInRaid(name) or UnitInParty(name) or checkPetFlags(flags, true) or not GetPlayerInfoByGUID(guid)) then
            return true
        end
    elseif value.UnitID:lower() == "player" then
        if name and name == E.myName or checkPetFlags(flags) then
            return true
        end
    end
end

function module:IsAuraTracking(value, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags)
    if value.OnSuccess and eventType == "SPELL_CAST_SUCCESS" and module:IsUnitWeNeed(value, sourceGUID, sourceName, sourceFlags) then
        return true
    elseif not value.OnSuccess and eventList[eventType] and module:IsUnitWeNeed(value, destGUID, destName, destFlags) then
        return true
    end
end

local cache = {}

function module:AuraWatch_UpdateInt(event, ...)
    if not IntCD.List then return end

    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, _, spellID = ...
        local value = IntCD.List[spellID]
        if value and value.CastSucceed and unit then
            local unitID = value.UnitID:lower()
            local guid = UnitGUID(unit)
            local isPassed
            if unitID == "all" and (unit == "player" or strfind(unit, "pet") or UnitInRaid(unit) or UnitInParty(unit) or not GetPlayerInfoByGUID(guid)) then
                isPassed = true
            elseif unitID == "player" and (unit == "player" or unit == "pet") then
                isPassed = true
            end
            if isPassed then
                module:AuraWatch_SetupInt(value.IntID, value.ItemID, value.Duration, value.UnitID, guid, UnitName(unit))
            end
        end
    else
        local timestamp, eventType, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellID = ...
        local value = IntCD.List[spellID]
        if value and cache[timestamp] ~= spellID and module:IsAuraTracking(value, eventType, sourceName, sourceFlags, destName, destFlags) then
            local guid, name = destGUID, destName
            if value.OnSuccess then guid, name = sourceGUID, sourceName end

            module:AuraWatch_SetupInt(value.IntID, value.ItemID, value.Duration, value.UnitID, guid, name)

            cache[timestamp] = spellID
        end

        if #cache > 666 then wipe(cache) end
    end
end

-- CleanUp
function module:AuraWatch_Cleanup()
    for _, value in pairs(FrameList) do
        for i = 1, maxFrames do
            local frame = value[i]
            if not frame:IsShown() then break end
            if frame then
                frame:Hide()
                frame:SetScript("OnUpdate", nil)
            end
            if frame.Icon then frame.Icon:SetTexture(nil) end
            if frame.Count then frame.Count:SetText("") end
            if frame.Spellname then frame.Spellname:SetText("") end
        end
        value.Index = 1
    end
end

function module:AuraWatch_PreCleanup()
    for _, value in pairs(FrameList) do
        value.Index = 1
    end
end

function module:AuraWatch_PostCleanup()
    for _, value in pairs(FrameList) do
        local currentIndex = value.Index == maxFrames and maxFrames + 1 or value.Index
        for i = currentIndex, maxFrames do
            local frame = value[i]
            if not frame:IsShown() then break end
            if frame then
                frame:Hide()
                frame:SetScript("OnUpdate", nil)
            end
            if frame.Icon then frame.Icon:SetTexture(nil) end
            if frame.Count then frame.Count:SetText("") end
            if frame.Spellname then frame.Spellname:SetText("") end
            if frame.bg then LBG.HideOverlayGlow(frame.bg) end
        end
    end
end

-- Event
function module.AuraWatch_OnEvent(_, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        InitSetup()
        if not IntCD.MoveHandle then module:AuraWatch_SetupInt(2825, nil, 0, "player") end
        module:UnregisterEvent(event)
    elseif event == "PLAYER_TALENT_UPDATE" then
        BuildCooldownTable()
    else
        module:AuraWatch_UpdateInt(event, ...)
    end
end

function module:AuraWatch_OnUpdate(elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed > .1 then
        self.elapsed = 0

        module:AuraWatch_Cleanup()
        module:AuraWatch_UpdateCD()

        local inCombat = InCombatLockdown()

        for _, value in pairs(UnitIDTable) do
            module:UpdateAuraWatch(value, inCombat)
        end

        module:AuraWatch_PostCleanup()
    end
end
updater:SetScript("OnUpdate", module.AuraWatch_OnUpdate)

module:RegisterEvent("PLAYER_LOGIN", function(self)
    if not SavedStatsPerChar["AuraWatch"] then
        SavedStatsPerChar["AuraWatch"] = {}

        SavedStatsPerChar["AuraWatch"]["Switcher"] = {}
        SavedStatsPerChar["AuraWatch"]["AuraWatchList"] = {}
        SavedStatsPerChar["AuraWatch"]["InternalCD"] = {}
        SavedStatsPerChar["AuraWatch"]["Position"] = {}
    end

    self:UnregisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("PLAYER_TALENT_UPDATE")
    self:SetScript("OnEvent", self.AuraWatch_OnEvent)
end)

-- Mover
SlashCmdList.AuraWatch = function(msg)
    if msg:lower() == "move" then
        updater:SetScript("OnUpdate", nil)
        for _, value in pairs(FrameList) do
            for i = 1, 6 do
                if value[i] then
                    value[i]:SetScript("OnUpdate", nil)
                    value[i]:Show()
                end
                if value[i].Icon then
                    value[i].Icon:SetColorTexture(0, 0, 0, .25)
                end
                if value[i].Count then
                    value[i].Count:SetText("")
                end
                if value[i].Time then
                    value[i].Time:SetText("59")
                end
                if value[i].Statusbar then
                    value[i].Statusbar:SetValue(1)
                end
                if value[i].Spellname then
                    value[i].Spellname:SetText("")
                end
                if value[i].bg then
                    LBG.HideOverlayGlow(value[i].bg)
                end
            end
            value[1].MoveHandle:Show()
        end
        if IntCD.MoveHandle then
            IntCD.MoveHandle:Show()
            for i = 1, #IntTable do
                if IntTable[i] then
                    IntTable[i]:Hide() end
            end
            wipe(IntTable)
            module:AuraWatch_SetupInt(2825, nil, 0, "player")
            module:AuraWatch_SetupInt(2825, nil, 0, "player")
            module:AuraWatch_SetupInt(2825, nil, 0, "player")
            module:AuraWatch_SetupInt(2825, nil, 0, "player")
            module:AuraWatch_SetupInt(2825, nil, 0, "player")
            module:AuraWatch_SetupInt(2825, nil, 0, "player")
            for i = 1, #IntTable do
                IntTable[i]:SetScript("OnUpdate", nil)
                IntTable[i]:Show()
                IntTable[i].Spellname:SetText("")
                IntTable[i].Time:SetText("59")
                IntTable[i].Statusbar:SetMinMaxValues(0, 1)
                IntTable[i].Statusbar:SetValue(1)
                IntTable[i].Icon:SetColorTexture(0, 0, 0, .25)
            end
        end
    elseif msg:lower() == "lock" then
        module:AuraWatch_Cleanup()
        for _, value in pairs(FrameList) do
            value[1].MoveHandle:Hide()
        end
        updater:SetScript("OnUpdate", module.AuraWatch_OnUpdate)
        if IntCD.MoveHandle then
            IntCD.MoveHandle:Hide()
            for i = 1, #IntTable do
                if IntTable[i] then
                    IntTable[i]:Hide()
                end
            end
            wipe(IntTable)
        end
    elseif msg:lower() == "reset" then
        wipe(SavedStatsPerChar["AuraWatch"])
        ReloadUI()
    else
        print("|cff70C0F5------------------------")
        print("|cff0080ffAuraWatch |cff70C0F5" .. COMMAND .. ":")
        print("|c0000ff00/aw move |cff70C0F5" .. UNLOCK)
        print("|c0000ff00/aw lock |cff70C0F5" .. LOCK)
        print("|c0000ff00/aw reset |cff70C0F5" .. RESET)
        print("|cff70C0F5------------------------")
    end
end
SLASH_AuraWatch1 = "/aw"
