local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- ItemLevel
------------------------------------------------------------------------
local module = E:Module("Tooltip"):Sub("ItemLevel")

local cfg = C.tooltip

local format, strfind, strmatch, max = format, strfind, strmatch, math.max
local select, wipe = select, wipe
local GetTime = GetTime
local CanInspect = CanInspect
local NotifyInspect = NotifyInspect
local ClearInspectPlayer = ClearInspectPlayer
local UnitGUID = UnitGUID
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

local STAT_AVERAGE_ITEM_LEVEL = STAT_AVERAGE_ITEM_LEVEL
local ITEM_LEVEL = ITEM_LEVEL

------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------
local ITEM_LEVEL_PATTERN = "^" .. gsub(ITEM_LEVEL, "%%d", "")
local CACHE_TIMEOUT = 900
local INSPECT_FREQ = 0.5
local LEVEL_PREFIX = STAT_AVERAGE_ITEM_LEVEL .. ": "
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
-- Helpers
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
-- Inspect flow
------------------------------------------------------------------------
local function onInspectReady(_, _, guid)
    if not canaccessvalue(guid) then return end
    if guid ~= currentGUID then return end

    local level = calcAverageItemLevel(currentUnit)
    if level then
        if not cache[guid] then cache[guid] = {} end
        cache[guid].level = level
        cache[guid].getTime = GetTime()
        setupItemLevel(level)
    else
        updater:Show()
    end

    module:UnregisterEvent("INSPECT_READY")
end

local function onInventoryChanged(_, _, unit)
    if InCombatLockdown() then return end
    if not currentUnit or not currentGUID then return end
    local guid = UnitGUID(unit)
    if not canaccessvalue(guid) then return end
    if guid == currentGUID then
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

local function inspectUnit(unit)
    if UnitIsUnit(unit, "player") then
        local level = calcAverageItemLevel("player")
        if level then setupItemLevel(level) end
        return
    end

    if not UnitIsPlayer(unit) or not CanInspect(unit) then return end

    local guid = currentGUID
    local cached = cache[guid]

    if cached and cached.level then
        setupItemLevel(cached.level)
        if not IsShiftKeyDown() and (GetTime() - cached.getTime < CACHE_TIMEOUT) then
            return
        end
    else
        setupItemLevel(nil)
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

    local _, unitID = self:GetUnit()
    if not unitID or not UnitIsPlayer(unitID) then return end

    local guid = UnitGUID(unitID)
    if not canaccessvalue(guid) then return end

    currentUnit = unitID
    currentGUID = guid
    if not cache[guid] then cache[guid] = {} end

    inspectUnit(unitID)
end

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------
function module:OnInit()
    if not cfg.average_lvl then return end

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

    self:RegisterEvent("UNIT_INVENTORY_CHANGED", onInventoryChanged)
end
