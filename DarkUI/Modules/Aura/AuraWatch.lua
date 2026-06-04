local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
-- AuraWatch
----------------------------------------------------------------------------------------
local module = E:Module("Aura"):Sub("AuraWatch")

local cfg = C.aura.auraWatch

local GetTime = GetTime
local pairs, ipairs, next, wipe, tinsert, tremove = pairs, ipairs, next, wipe, tinsert, tremove
local select, format, floor, unpack = select, format, floor, unpack
local CreateFrame = CreateFrame
local C_Spell_GetSpellName = C_Spell.GetSpellName
local C_Spell_GetSpellTexture = C_Spell.GetSpellTexture
local C_Spell_GetSpellCooldown = C_Spell.GetSpellCooldown
local C_Spell_GetSpellCharges = C_Spell.GetSpellCharges
local C_UnitAuras_GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex
local GetInventoryItemCooldown = GetInventoryItemCooldown
local GetTotemInfo = GetTotemInfo
local IsPlayerSpell = IsPlayerSpell
local GameTooltip = GameTooltip

local MAX_FRAMES = 12

local AuraList = {}
local FrameList = {}
local UnitIDTable = {}
local cooldownTable = {}
local IntCD
local IntTable = {}

----------------------------------------------------------------------------------------
-- Data Conversion
----------------------------------------------------------------------------------------

local function convertAuraList(source)
    local result = {}
    for _, entry in ipairs(source) do
        local id = entry.AuraID or entry.SpellID or entry.ItemID or entry.SlotID or entry.TotemID or entry.IntID
        if id then
            result[id] = entry
        end
    end
    return result
end

local function buildAuraList()
    local watchList = E.AuraWatchList
    if not watchList then
        return
    end

    local myClass = E.myClass
    local groups = cfg.groups

    for i, group in ipairs(groups) do
        AuraList[i] = {
            Name = group.name,
            Direction = group.dir,
            Interval = group.interval,
            Mode = group.mode,
            IconSize = group.size,
            BarWidth = group.barWidth,
            Pos = group.pos,
            List = {},
        }

        if watchList["ALL"] and watchList["ALL"][group.name] then
            local converted = convertAuraList(watchList["ALL"][group.name])
            for id, data in pairs(converted) do
                AuraList[i].List[id] = data
            end
        end

        if myClass and watchList[myClass] and watchList[myClass][group.name] then
            local converted = convertAuraList(watchList[myClass][group.name])
            for id, data in pairs(converted) do
                AuraList[i].List[id] = data
            end
        end
    end
end

local function buildUnitIDTable()
    wipe(UnitIDTable)
    for _, group in ipairs(AuraList) do
        for _, data in pairs(group.List) do
            if data.UnitID then
                UnitIDTable[data.UnitID] = true
            end
        end
    end
    UnitIDTable["player"] = true
end

local function buildCooldownTable()
    wipe(cooldownTable)
    for key, group in ipairs(AuraList) do
        for id, data in pairs(group.List) do
            if data.SpellID or data.ItemID or data.SlotID or data.TotemID then
                if not cooldownTable[key] then
                    cooldownTable[key] = {}
                end
                cooldownTable[key][id] = data
            end
        end
    end
end

----------------------------------------------------------------------------------------
-- Frame Creation
----------------------------------------------------------------------------------------

local LCG = LibStub("LibCustomGlow-1.0", true)

local function tooltipOnEnter(self)
    GameTooltip:ClearLines()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 3)
    if self.type == 1 then
        GameTooltip:SetSpellByID(self.spellID)
    elseif self.type == 2 then
        GameTooltip:SetItemByID(self.spellID)
    elseif self.type == 3 then
        GameTooltip:SetInventoryItem("player", self.spellID)
    elseif self.type == 4 then
        GameTooltip:SetUnitAura(self.unit, self.index, self.filter)
    elseif self.type == 5 then
        GameTooltip:SetTotem(self.spellID)
    end
    GameTooltip:Show()
end

local function tooltipOnLeave()
    GameTooltip:Hide()
end

local function enableTooltip(frame)
    frame:EnableMouse(true)
    frame.HL = frame:CreateTexture(nil, "HIGHLIGHT")
    frame.HL:SetColorTexture(1, 1, 1, 0.25)
    frame.HL:SetAllPoints(frame.Icon)
    frame:SetScript("OnEnter", tooltipOnEnter)
    frame:SetScript("OnLeave", tooltipOnLeave)
end

local function buildIcon(parent, size)
    size = size * (cfg.iconScale or 1)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(size, size)
    frame:Hide()

    E:ApplyOverlayBorder(frame, 2)

    frame.Icon = frame:CreateTexture(nil, "ARTWORK")
    frame.Icon:SetPoint("TOPLEFT", frame, 2, -2)
    frame.Icon:SetPoint("BOTTOMRIGHT", frame, -2, 2)
    frame.Icon:SetTexCoord(unpack(C.media.texCoord))
    frame.Icon:SetDrawLayer("BACKGROUND", -8)

    frame.Cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    frame.Cooldown:SetAllPoints(frame.Icon)
    frame.Cooldown:SetReverse(true)

    local parentFrame = CreateFrame("Frame", nil, frame)
    parentFrame:SetAllPoints()
    parentFrame:SetFrameLevel(frame:GetFrameLevel() + 6)

    frame.Spellname = parentFrame:CreateFontText(13, "", false, "TOP", 0, 5)
    frame.Count = parentFrame:CreateFontText(size * 0.55, "", false, "BOTTOMRIGHT", 6, -3)

    frame.glowFrame = CreateFrame("Frame", nil, frame)
    frame.glowFrame:SetAllPoints(frame.Icon)

    if not cfg.clickThrough then
        enableTooltip(frame)
    end

    return frame
end

local function buildBar(parent, size, barWidth)
    barWidth = barWidth or 150
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(size, size)
    frame:Hide()

    E:ApplyOverlayBorder(frame, 2)

    frame.Icon = frame:CreateTexture(nil, "ARTWORK")
    frame.Icon:SetPoint("TOPLEFT", frame, 2, -2)
    frame.Icon:SetPoint("BOTTOMRIGHT", frame, -2, 2)
    frame.Icon:SetTexCoord(unpack(C.media.texCoord))
    frame.Icon:SetDrawLayer("BACKGROUND", -8)

    frame.Statusbar = CreateFrame("StatusBar", nil, frame)
    frame.Statusbar:SetSize(barWidth, size / 2.5)
    frame.Statusbar:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 5, 0)
    frame.Statusbar:SetMinMaxValues(0, 1)
    frame.Statusbar:SetValue(0)
    frame.Statusbar:SetStatusBarTexture(C.media.texture.status)
    frame.Statusbar:SetStatusBarColor(E.myColor.r, E.myColor.g, E.myColor.b)
    frame.Statusbar:SetTemplate("Default")
    frame.Statusbar:CreateShadow()

    frame.Statusbar.Spark = frame.Statusbar:CreateTexture(nil, "OVERLAY")
    frame.Statusbar.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
    frame.Statusbar.Spark:SetBlendMode("ADD")
    frame.Statusbar.Spark:SetAlpha(0.8)
    frame.Statusbar.Spark:SetPoint("TOPLEFT", frame.Statusbar:GetStatusBarTexture(), "TOPRIGHT", -10, 10)
    frame.Statusbar.Spark:SetPoint("BOTTOMRIGHT", frame.Statusbar:GetStatusBarTexture(), "BOTTOMRIGHT", 10, -10)

    frame.Count = frame:CreateFontText(14, "", false, "BOTTOMRIGHT", 3, -1)
    frame.Time = frame.Statusbar:CreateFontText(14, "", false, "RIGHT", 0, 8)
    frame.Spellname = frame.Statusbar:CreateFontText(14, "", false, "LEFT", 2, 8)
    frame.Spellname:SetWidth(frame.Statusbar:GetWidth() * 0.6)
    frame.Spellname:SetJustifyH("LEFT")

    frame.glowFrame = CreateFrame("Frame", nil, frame)
    frame.glowFrame:SetAllPoints(frame.Icon)

    if not cfg.clickThrough then
        enableTooltip(frame)
    end

    return frame
end

----------------------------------------------------------------------------------------
-- Frame Positioning
----------------------------------------------------------------------------------------

local function setupAnchor(key, frameTable, group)
    local dir = group.Direction
    local interval = group.Interval
    local size = group.IconSize

    if group.Mode == "BAR" and dir == "CENTER" then
        dir = "UP"
    end

    for i, frame in ipairs(frameTable) do
        frame:ClearAllPoints()
        if i == 1 then
            frame:SetPoint("CENTER", frame.MoveHandle or frame:GetParent())
        elseif dir == "RIGHT" or dir == "CENTER" then
            frame:SetPoint("LEFT", frameTable[i - 1], "RIGHT", interval, 0)
        elseif dir == "LEFT" then
            frame:SetPoint("RIGHT", frameTable[i - 1], "LEFT", -interval, 0)
        elseif dir == "UP" then
            frame:SetPoint("BOTTOM", frameTable[i - 1], "TOP", 0, interval)
        elseif dir == "DOWN" then
            frame:SetPoint("TOP", frameTable[i - 1], "BOTTOM", 0, -interval)
        end
    end
end

local function buildFrames()
    for key, group in ipairs(AuraList) do
        local frameTable = {}
        local parent = CreateFrame("Frame", "DarkUI_AuraWatch" .. key, UIParent)
        parent:SetSize(1, 1)
        parent:SetPoint(unpack(group.Pos))

        for i = 1, MAX_FRAMES do
            local frame
            if group.Mode == "BAR" then
                frame = buildBar(parent, group.IconSize, group.BarWidth)
            else
                frame = buildIcon(parent, group.IconSize)
            end
            frame.ID = i

            if i == 1 then
                frame.MoveHandle = parent
            end

            tinsert(frameTable, frame)
        end

        FrameList[key] = frameTable
        setupAnchor(key, frameTable, group)
    end

    for key, group in ipairs(AuraList) do
        if group.Name == "InternalCD" then
            IntCD = { key = key, group = group }
            break
        end
    end
end

----------------------------------------------------------------------------------------
-- Timer Update
----------------------------------------------------------------------------------------

local function formatTimer(remain)
    if remain < 0 then
        return "N/A"
    elseif remain < 60 then
        return format("%.1f", remain)
    else
        return format("%d:%02d", remain / 60, remain % 60)
    end
end

local function timerOnUpdate(self, elapsed)
    local remain = self.expire - GetTime()
    if remain <= 0 then
        self.expire = nil
        self:SetScript("OnUpdate", nil)
        self:Hide()
        return
    end

    if self.Time then
        self.Time:SetText(formatTimer(remain))
    end
    if self.Statusbar then
        self.Statusbar:SetValue(remain / self.duration)
    end
end

----------------------------------------------------------------------------------------
-- Aura Setup
----------------------------------------------------------------------------------------

local function setupAura(frame, icon, count, duration, expire, spellName, flash)
    frame.Icon:SetTexture(icon)
    frame.Spellname:SetText(spellName or "")

    if count and count > 1 then
        frame.Count:SetText(count)
    else
        frame.Count:SetText("")
    end

    if duration and duration > 0 and expire then
        if frame.Cooldown then
            frame.Cooldown:SetCooldown(expire - duration, duration)
        end
        if frame.Statusbar then
            frame.duration = duration
            frame.expire = expire
            frame.Statusbar:SetValue((expire - GetTime()) / duration)
            frame:SetScript("OnUpdate", timerOnUpdate)
        end
        if frame.Time then
            frame.Time:SetText(formatTimer(expire - GetTime()))
        end
    else
        if frame.Cooldown then
            frame.Cooldown:Clear()
        end
        if frame.Time then
            frame.Time:SetText("")
        end
        if frame.Statusbar then
            frame.Statusbar:SetValue(1)
        end
    end

    frame:Show()

    if flash and frame.glowFrame and LCG then
        LCG.PixelGlow_Start(frame.glowFrame)
    elseif frame.glowFrame and LCG then
        LCG.PixelGlow_Stop(frame.glowFrame)
    end
end

----------------------------------------------------------------------------------------
-- Update Cycle
----------------------------------------------------------------------------------------

local frameIndices = {}

local function preCleanup()
    for key in ipairs(AuraList) do
        frameIndices[key] = 1
    end
end

local function postCleanup()
    for key, frameTable in ipairs(FrameList) do
        local startIdx = frameIndices[key] or 1
        for i = startIdx, MAX_FRAMES do
            local frame = frameTable[i]
            if frame and frame:IsShown() then
                frame:Hide()
                frame.Icon:SetTexture(nil)
                if frame.Spellname then
                    frame.Spellname:SetText("")
                end
                if frame.Count then
                    frame.Count:SetText("")
                end
                if frame.Time then
                    frame.Time:SetText("")
                end
                if frame.glowFrame and LCG then
                    LCG.PixelGlow_Stop(frame.glowFrame)
                end
                frame:SetScript("OnUpdate", nil)
            end
        end
    end
end

local function updateAuraWatchByFilter(unit, filter, inCombat)
    local index = 1
    while true do
        local auraData = C_UnitAuras_GetAuraDataByIndex(unit, index, filter)
        if not auraData then
            break
        end

        local spellID = auraData.spellId
        if spellID and not issecretvalue(spellID) then
            for key, group in ipairs(AuraList) do
                local data = group.List[spellID]
                if data and data.AuraID and data.UnitID == unit then
                    local apps = auraData.applications
                    if issecretvalue(apps) then
                        apps = 0
                    end
                    local shouldShow = true
                    if data.Combat and not inCombat then
                        shouldShow = false
                    elseif data.Caster and data.Caster ~= auraData.sourceUnit then
                        shouldShow = false
                    elseif data.Stack and apps > 0 and data.Stack > apps then
                        shouldShow = false
                    end

                    if shouldShow then
                        local idx = frameIndices[key]
                        if idx and idx <= MAX_FRAMES then
                            local frame = FrameList[key][idx]
                            if frame then
                                local duration = auraData.duration
                                local expire = auraData.expirationTime
                                if data.Timeless or issecretvalue(duration) then
                                    duration = 0
                                    expire = 0
                                end
                                setupAura(frame, auraData.icon, apps, duration, expire, auraData.name, data.Flash)
                                frameIndices[key] = idx + 1
                            end
                        end
                    end
                end
            end
        end

        index = index + 1
    end
end

local function updateAuraWatch(unit, inCombat)
    updateAuraWatchByFilter(unit, "HELPFUL", inCombat)
    updateAuraWatchByFilter(unit, "HARMFUL", inCombat)
end

----------------------------------------------------------------------------------------
-- Cooldown Tracking
----------------------------------------------------------------------------------------

local function updateCD()
    for key, cdList in pairs(cooldownTable) do
        for id, data in pairs(cdList) do
            local start, duration, remaining
            local icon = C_Spell_GetSpellTexture(id)
            local name = C_Spell_GetSpellName(id)

            if data.SpellID then
                if IsPlayerSpell(id) then
                    local cdInfo = C_Spell_GetSpellCooldown(id)
                    if cdInfo and cdInfo.startTime and not issecretvalue(cdInfo.duration) and cdInfo.duration > cfg.minCD then
                        start = cdInfo.startTime
                        duration = cdInfo.duration
                    end
                    local charges = C_Spell_GetSpellCharges(id)
                    if charges and not issecretvalue(charges.currentCharges) and charges.currentCharges < charges.maxCharges then
                        start = charges.cooldownStartTime
                        duration = charges.cooldownDuration
                    end
                end
            elseif data.ItemID then
                local itemStart, itemDuration = C_Item.GetItemCooldown(id)
                if itemStart and itemDuration and not issecretvalue(itemDuration) and itemDuration > cfg.minCD then
                    start = itemStart
                    duration = itemDuration
                end
                icon = C_Item.GetItemIconByID(id)
                local itemInfo = C_Item.GetItemInfo(id)
                name = itemInfo and itemInfo.itemName or name
            elseif data.SlotID then
                local slotStart, slotDuration = GetInventoryItemCooldown("player", id)
                if slotStart and slotDuration and not issecretvalue(slotDuration) and slotDuration > cfg.minCD then
                    start = slotStart
                    duration = slotDuration
                end
                icon = GetInventoryItemTexture("player", id)
            elseif data.TotemID then
                local _, totemName, totemStart, totemDuration, totemIcon = GetTotemInfo(id)
                if totemStart and totemDuration and totemDuration > 0 then
                    start = totemStart
                    duration = totemDuration
                    icon = totemIcon
                    name = totemName
                end
            end

            if start and duration and duration > 0 then
                local expire = start + duration
                if expire > GetTime() then
                    local idx = frameIndices[key]
                    if idx and idx <= MAX_FRAMES then
                        local frame = FrameList[key][idx]
                        if frame then
                            setupAura(frame, icon, nil, duration, expire, name)
                            frameIndices[key] = idx + 1
                        end
                    end
                end
            end
        end
    end
end

----------------------------------------------------------------------------------------
-- InternalCD Tracking
----------------------------------------------------------------------------------------

local function startInternalCD(intData, spellID)
    if not IntCD then
        return
    end

    local icon = C_Spell_GetSpellTexture(spellID)
    local name = C_Spell_GetSpellName(spellID)
    local duration = intData.Duration
    local expire = GetTime() + duration

    for _, entry in ipairs(IntTable) do
        if entry.spellID == spellID then
            entry.expire = expire
            entry.duration = duration
            return
        end
    end

    local key = IntCD.key
    local group = IntCD.group
    local frame
    if group.Mode == "BAR" then
        frame = buildBar(FrameList[key][1]:GetParent(), group.IconSize, group.BarWidth)
    else
        frame = buildIcon(FrameList[key][1]:GetParent(), group.IconSize)
    end

    setupAura(frame, icon, nil, duration, expire, name)
    tinsert(IntTable, { frame = frame, spellID = spellID, expire = expire, duration = duration })
    module:SortIntBars()
end

function module:SortIntBars()
    if not IntCD then
        return
    end

    local now = GetTime()
    for i = #IntTable, 1, -1 do
        if IntTable[i].expire <= now then
            IntTable[i].frame:Hide()
            tremove(IntTable, i)
        end
    end

    local group = IntCD.group
    local dir = group.Direction
    local interval = group.Interval
    local anchor = FrameList[IntCD.key][1]:GetParent()

    for i, entry in ipairs(IntTable) do
        entry.frame:ClearAllPoints()
        if i == 1 then
            entry.frame:SetPoint("CENTER", anchor)
        elseif dir == "UP" then
            entry.frame:SetPoint("BOTTOM", IntTable[i - 1].frame, "TOP", 0, interval)
        elseif dir == "DOWN" then
            entry.frame:SetPoint("TOP", IntTable[i - 1].frame, "BOTTOM", 0, -interval)
        elseif dir == "RIGHT" then
            entry.frame:SetPoint("LEFT", IntTable[i - 1].frame, "RIGHT", interval, 0)
        elseif dir == "LEFT" then
            entry.frame:SetPoint("RIGHT", IntTable[i - 1].frame, "LEFT", -interval, 0)
        end
    end
end

local function updateInt(event, unit, _, spellID)
    if not IntCD then
        return
    end
    if event ~= "UNIT_SPELLCAST_SUCCEEDED" then
        return
    end

    local intList = IntCD.group.List
    local intData = intList[spellID]
    if not intData then
        return
    end

    if intData.OnSuccess then
        local validUnit = (intData.UnitID == "all") and (unit == "player" or UnitInRaid(unit) or UnitInParty(unit)) or (unit == (intData.UnitID or "player"))
        if validUnit then
            startInternalCD(intData, spellID)
        end
    end
end

----------------------------------------------------------------------------------------
-- Event Handler
----------------------------------------------------------------------------------------

local initialized = false

local function onEvent(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        if not initialized then
            buildAuraList()
            buildUnitIDTable()
            buildCooldownTable()
            buildFrames()
            initialized = true
        end
        -- Fall through to update
    end

    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        updateInt(event, ...)
        return
    end

    if event == "UNIT_AURA" then
        local unit = ...
        if not UnitIDTable[unit] then
            return
        end
    end

    local inCombat = InCombatLockdown()
    preCleanup()
    updateCD()
    for unit in pairs(UnitIDTable) do
        if unit ~= "all" then
            updateAuraWatch(unit, inCombat)
        end
    end
    postCleanup()
    module:SortIntBars()
end

----------------------------------------------------------------------------------------
-- Slash Command (Move / Lock)
----------------------------------------------------------------------------------------

local function makeMover(parent, name)
    local mover = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    mover:SetAllPoints(parent)
    mover:SetBackdrop({ bgFile = [[Interface\Tooltips\UI-Tooltip-Background]] })
    mover:SetBackdropColor(0.1, 0.1, 0.1, 0.7)
    mover:EnableMouse(true)
    mover:SetMovable(true)
    mover:RegisterForDrag("LeftButton")
    mover:SetScript("OnDragStart", function(self)
        self:GetParent():StartMoving()
    end)
    mover:SetScript("OnDragStop", function(self)
        self:GetParent():StopMovingOrSizing()
        self:GetParent():SetUserPlaced(false)
    end)

    mover.text = mover:CreateFontString(nil, "OVERLAY")
    mover.text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
    mover.text:SetPoint("CENTER")
    mover.text:SetText(name)
    mover:Hide()

    parent.mover = mover
    parent:SetMovable(true)
    parent:SetClampedToScreen(true)
end

local function enterMoveMode()
    for key, frameTable in ipairs(FrameList) do
        local group = AuraList[key]
        local parent = frameTable[1].MoveHandle
        if not parent.mover then
            makeMover(parent, group.Name)
        end

        local size = group.IconSize
        local barWidth = group.BarWidth or 150
        if group.Mode == "BAR" then
            parent:SetSize(barWidth + size + 5, (size + group.Interval) * 6)
        else
            parent:SetSize((size + group.Interval) * 6, size)
        end

        parent.mover:Show()

        for i = 1, MAX_FRAMES do
            local frame = frameTable[i]
            if frame then
                frame:SetScript("OnUpdate", nil)
                frame:Hide()
            end
        end
    end

    for _, entry in ipairs(IntTable) do
        entry.frame:Hide()
    end
    wipe(IntTable)

    print("|cff00ff00DarkUI AuraWatch|r: unlocked - drag to reposition, |cffff0000/aurawatch lock|r to save")
end

local function enterTestMode()
    if not initialized then
        buildAuraList()
        buildUnitIDTable()
        buildCooldownTable()
        buildFrames()
        initialized = true
    end

    local testIcon = 136243 -- spell_nature_starfall
    local now = GetTime()

    for key, frameTable in ipairs(FrameList) do
        local group = AuraList[key]
        local count = math.min(6, MAX_FRAMES)
        for i = 1, count do
            local frame = frameTable[i]
            if frame then
                local duration = 30 + i * 10
                local expire = now + duration - i * 5
                setupAura(frame, testIcon, i > 1 and i or nil, duration, expire, "Test " .. i)
            end
        end
    end

    print("|cff00ff00DarkUI AuraWatch|r: test mode - showing sample frames, |cffff0000/aurawatch lock|r to reset")
end

local function enterLockMode()
    for _, frameTable in ipairs(FrameList) do
        local parent = frameTable[1].MoveHandle
        if parent.mover then
            parent.mover:Hide()
        end
        parent:SetSize(1, 1)
    end

    for _, entry in ipairs(IntTable) do
        entry.frame:Hide()
    end
    wipe(IntTable)

    onEvent(nil, "PLAYER_ENTERING_WORLD")
    print("|cff00ff00DarkUI AuraWatch|r: locked")
end

function module:OnInit()
    if not cfg or not cfg.enable then
        return
    end

    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterUnitEvent("UNIT_AURA", "player", "target", "focus", "pet")
    frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
    frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    frame:SetScript("OnEvent", onEvent)

    SlashCmdList.DARKUI_AURAWATCH = function(msg)
        msg = msg and msg:lower() or ""
        if msg == "move" then
            enterMoveMode()
        elseif msg == "lock" then
            enterLockMode()
        elseif msg == "test" then
            enterTestMode()
        else
            print("|cff00ff00DarkUI AuraWatch|r: /aurawatch move | lock | test")
        end
    end
    SLASH_DARKUI_AURAWATCH1 = "/aurawatch"
end
