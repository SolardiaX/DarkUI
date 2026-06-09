local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Inspect
------------------------------------------------------------------------
local module = E:Module("Tooltip"):Sub("Inspect")

local cfg = C.tooltip

local format, strfind, strmatch, max = format, strfind, strmatch, math.max
local select = select
local GetTime = GetTime
local CanInspect = CanInspect
local NotifyInspect = NotifyInspect
local ClearInspectPlayer = ClearInspectPlayer
local UnitGUID = UnitGUID
local UnitTokenFromGUID = UnitTokenFromGUID
local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local UnitIsPlayer = UnitIsPlayer
local UnitIsVisible = UnitIsVisible
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitOnTaxi = UnitOnTaxi
local GetInventoryItemLink = GetInventoryItemLink
local GetInventoryItemTexture = GetInventoryItemTexture
local GetAverageItemLevel = GetAverageItemLevel
local InCombatLockdown = InCombatLockdown
local IsShiftKeyDown = IsShiftKeyDown
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local GetInspectSpecialization = GetInspectSpecialization
local GetSpecializationInfoByID = GetSpecializationInfoByID

local STAT_AVERAGE_ITEM_LEVEL = STAT_AVERAGE_ITEM_LEVEL
local ITEM_LEVEL = ITEM_LEVEL

------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------
local ITEM_LEVEL_PATTERN = "^" .. gsub(ITEM_LEVEL, "%%d", "")
local CACHE_TIMEOUT = 900
local INSPECT_FREQ = 0.5
local LEVEL_PREFIX = STAT_AVERAGE_ITEM_LEVEL .. ": "
local SPEC_PREFIX = SPECIALIZATION .. ": "
local SLOTS = { 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17 }

local TWO_HANDERS = {
    INVTYPE_2HWEAPON = true,
    INVTYPE_RANGED = true,
    INVTYPE_RANGEDRIGHT = true,
}

------------------------------------------------------------------------
-- State
------------------------------------------------------------------------
local cache = {}
local currentUnit, currentGUID
local updater

------------------------------------------------------------------------
-- Item Level
------------------------------------------------------------------------
local function getSlotItemLevel(unit, slot)
    local data = C_TooltipInfo.GetInventoryItem(unit, slot)
    if not data then return nil end
    for i = 2, 5 do
        local lineData = data.lines[i]
        if not lineData then break end
        local text = lineData.leftText
        if text and strfind(text, ITEM_LEVEL_PATTERN) then
            return tonumber(strmatch(text, "(%d+)%)?$"))
        end
    end
    return nil
end

local function calcAverageItemLevel(unit)
    if UnitIsUnit(unit, "player") then
        return select(2, GetAverageItemLevel())
    end

    local total = 0
    local weapon = { 0, 0 }
    local haveWeapon, twohand = 0, 0

    for _, slot in ipairs(SLOTS) do
        if GetInventoryItemTexture(unit, slot) then
            local ilvl = getSlotItemLevel(unit, slot)
            if not ilvl then return nil end

            if slot < 16 then
                total = total + ilvl
            else
                local link = GetInventoryItemLink(unit, slot)
                if link then
                    local _, _, _, equipLoc = C_Item.GetItemInfoInstant(link)
                    weapon[slot - 15] = ilvl
                    haveWeapon = haveWeapon + 1
                    if equipLoc and TWO_HANDERS[equipLoc] then
                        twohand = twohand + 1
                    end
                end
            end
        end
    end

    if twohand > 0 and haveWeapon == 1 then
        total = total + max(weapon[1], weapon[2]) * 2
    else
        total = total + weapon[1] + weapon[2]
    end

    return total / 16
end

local function colorDiff(playerIlvl, targetIlvl)
    local diff = targetIlvl - playerIlvl
    if diff >= 10 then
        return 1, 0.1, 0.1
    elseif diff >= 5 then
        return 1, 0.5, 0.25
    elseif diff >= -5 then
        return 1, 1, 0
    elseif diff >= -10 then
        return 0.25, 0.75, 0.25
    else
        return 0.7, 0.7, 0.7
    end
end

local function setupItemLevel(level)
    if not GameTooltip:IsShown() then return end
    if not currentGUID or UnitGUID("mouseover") ~= currentGUID then return end

    local levelLine
    for i = 2, GameTooltip:NumLines() do
        local line = _G["GameTooltipTextLeft" .. i]
        local text = line and line:GetText()
        if text and canaccessvalue(text) and strfind(text, LEVEL_PREFIX) then
            levelLine = line
            break
        end
    end

    local text
    if level then
        local _, playerIlvl = GetAverageItemLevel()
        local r, g, b = colorDiff(playerIlvl, level)
        text = format("%s|cff%02x%02x%02x%.1f|r", LEVEL_PREFIX, r * 255, g * 255, b * 255, level)
    else
        text = LEVEL_PREFIX .. "|cff9a9a9a...|r"
    end

    if levelLine then
        levelLine:SetText(text)
    else
        GameTooltip:AddLine(text)
    end
    GameTooltip:Show()
end

------------------------------------------------------------------------
-- Specialization
------------------------------------------------------------------------
local function getUnitSpec(unit)
    if UnitIsUnit(unit, "player") then
        local specIndex = GetSpecialization()
        if not specIndex then return nil end
        local _, name, _, icon = GetSpecializationInfo(specIndex)
        return name, icon
    end

    local specID = GetInspectSpecialization(unit)
    if not specID or specID == 0 then return nil end
    local _, name, _, icon = GetSpecializationInfoByID(specID)
    return name, icon
end

local function setupSpec(name, icon)
    if not GameTooltip:IsShown() then return end
    if not currentGUID or UnitGUID("mouseover") ~= currentGUID then return end

    local specLine
    for i = 2, GameTooltip:NumLines() do
        local line = _G["GameTooltipTextLeft" .. i]
        local text = line and line:GetText()
        if text and canaccessvalue(text) and text:find(SPEC_PREFIX) then
            specLine = line
            break
        end
    end

    local text
    if name then
        if icon then
            text = format("%s|T%d:0:0:0:0:64:64:4:60:4:60|t %s", SPEC_PREFIX, icon, name)
        else
            text = SPEC_PREFIX .. name
        end
    else
        text = SPEC_PREFIX .. "|cff9a9a9a...|r"
    end

    if specLine then
        specLine:SetText(text)
    else
        GameTooltip:AddLine(text)
    end
    GameTooltip:Show()
end

------------------------------------------------------------------------
-- Inspect flow
------------------------------------------------------------------------
local function onInspectReady(_, _, guid)
    if not canaccessvalue(guid) then return end
    if guid ~= currentGUID then return end

    local db = cache[guid]
    if not db then db = {}; cache[guid] = db end

    if cfg.talents then
        local name, icon = getUnitSpec(currentUnit)
        if name then
            db.specName = name
            db.specIcon = icon
            setupSpec(name, icon)
        end
    end

    if cfg.average_lvl then
        local level = calcAverageItemLevel(currentUnit)
        if level then
            db.level = level
            db.getTime = GetTime()
            setupItemLevel(level)
        else
            updater:Show()
            return
        end
    end

    db.getTime = db.getTime or GetTime()
    module:UnregisterEvent("INSPECT_READY")
end

local function onInventoryChanged(_, _, unit)
    if InCombatLockdown() then return end
    if not currentUnit or not currentGUID then return end
    local guid = UnitGUID(unit)
    if not canaccessvalue(guid) then return end
    if guid == currentGUID and cfg.average_lvl then
        local level = calcAverageItemLevel(unit)
        if level then
            if not cache[guid] then cache[guid] = {} end
            cache[guid].level = level
            cache[guid].getTime = GetTime()
            setupItemLevel(level)
        end
    end
end

local function inspectOnUpdate(self, elapsed)
    self.elapsed = (self.elapsed or INSPECT_FREQ) + elapsed
    if self.elapsed > INSPECT_FREQ then
        self.elapsed = 0
        self:Hide()
        ClearInspectPlayer()

        if currentUnit and currentGUID then
            local guid = UnitGUID(currentUnit)
            if canaccessvalue(guid) and guid == currentGUID then
                module:RegisterEvent("INSPECT_READY", onInspectReady)
                NotifyInspect(currentUnit)
            end
        end
    end
end

------------------------------------------------------------------------
-- Unit inspect entry
------------------------------------------------------------------------
local function inspectUnit(unit)
    if UnitIsUnit(unit, "player") then
        if cfg.talents then
            local name, icon = getUnitSpec("player")
            if name then setupSpec(name, icon) end
        end
        if cfg.average_lvl then
            local level = calcAverageItemLevel("player")
            if level then setupItemLevel(level) end
        end
        return
    end

    if not UnitIsPlayer(unit) or not CanInspect(unit) then return end

    local db = cache[currentGUID]

    if cfg.talents then
        if db and db.specName then
            setupSpec(db.specName, db.specIcon)
        else
            setupSpec(nil)
        end
    end

    if cfg.average_lvl then
        if db and db.level then
            setupItemLevel(db.level)
        else
            setupItemLevel(nil)
        end
    end

    if db and db.getTime and not IsShiftKeyDown() and (GetTime() - db.getTime < CACHE_TIMEOUT) then
        return
    end

    if not UnitIsVisible(unit) or UnitIsDeadOrGhost("player") or UnitOnTaxi("player") then return end
    if InspectFrame and InspectFrame:IsShown() then return end

    updater:Show()
end

------------------------------------------------------------------------
-- Tooltip hook
------------------------------------------------------------------------
local function onTooltipSetUnit(self)
    if self ~= GameTooltip then return end

    local data = self:GetTooltipData()
    local guid = data and data.guid
    if not guid or not canaccessvalue(guid) then return end

    local unit = UnitTokenFromGUID(guid) or (UnitExists("mouseover") and "mouseover")
    if not unit or not UnitIsPlayer(unit) then return end

    currentUnit = unit
    currentGUID = guid
    if not cache[guid] then cache[guid] = {} end

    inspectUnit(unit)
end


------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------
function module:OnInit()
    if not cfg.average_lvl and not cfg.talents then return end

    updater = CreateFrame("Frame")
    updater:SetScript("OnUpdate", inspectOnUpdate)
    updater:Hide()

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, onTooltipSetUnit)

    GameTooltip:HookScript("OnTooltipCleared", function()
        currentUnit = nil
        currentGUID = nil
        updater:Hide()
        module:UnregisterEvent("INSPECT_READY")
    end)

    if cfg.average_lvl then
        self:RegisterEvent("UNIT_INVENTORY_CHANGED", onInventoryChanged)
    end
end
