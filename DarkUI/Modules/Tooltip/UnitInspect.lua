local E, C, L = select(2, ...):unpack()

if C.tooltip.enable ~= true or (C.tooltip.talents ~= true and C.tooltip.average_lvl ~= true) then return end

----------------------------------------------------------------------------------------
--	Target Inspect (based on TipTacTalents by Aezay)
----------------------------------------------------------------------------------------

local LibFroznFunctions = LibStub:GetLibrary("LibFroznFunctions-1.0")

local GetMouseFocus = GetMouseFocus
local UnitGUID = UnitGUID
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid

local GameTooltip = GameTooltip
local LFF_AVERAGE_ITEM_LEVEL_AVAILABLE = LFF_AVERAGE_ITEM_LEVEL_AVAILABLE
local LFF_AVERAGE_ITEM_LEVEL_NA = LFF_AVERAGE_ITEM_LEVEL_NA
local LFF_AVERAGE_ITEM_LEVEL_NONE = LFF_AVERAGE_ITEM_LEVEL_NONE
local LFF_TALENTS_AVAILABLE = LFF_TALENTS_AVAILABLE
local LFF_TALENTS_NA = LFF_TALENTS_NA
local LFF_TALENTS_NONE = LFF_TALENTS_NONE

local TT_TEXT_TALENTS_PREFIX = SPECIALIZATION or TALENTS
local TT_TEXT_AIL_PREFIX = STAT_AVERAGE_ITEM_LEVEL
local TT_TEXT_LOADING = SEARCH_LOADING_TEXT
local TT_TEXT_OUT_OF_RANGE = ERR_SPELL_OUT_OF_RANGE:sub(1, -2)
local TT_TEXT_NONE = NONE_KEY

local TT_COLOR_TEXT = HIGHLIGHT_FONT_COLOR
local TT_COLOR_POINTS_SPENT = LIGHTYELLOW_FONT_COLOR

local cfg = C.tooltip

local ttLineIndexTalents, ttLineIndexAverageItemLevel

local function GTT_UpdateTooltip(unitCacheRecord)
    -- exit if unit from unit cache record doesn't match the current displaying unit
    local _, unitID = LibFroznFunctions:GetUnitFromTooltip(GameTooltip)
    
    if not unitID then
        return
    end
    
    local unitGUID = UnitGUID(unitID)
    
    if unitGUID ~= unitCacheRecord.guid then
        return
    end
    
    -- update tooltip with the unit cache record
    
    -- talents
    if cfg.talents and unitCacheRecord.talents then
        local specText
        
        -- talents available but no inspect data
        if unitCacheRecord.talents == LFF_TALENTS_AVAILABLE then
            if unitCacheRecord.canInspect then
                specText = TT_TEXT_LOADING
            else
                specText = TT_TEXT_OUT_OF_RANGE
            end
        
        -- no talents available
        elseif unitCacheRecord.talents == LFF_TALENTS_NA then
            specText = nil
        
        -- no talents found
        elseif unitCacheRecord.talents == LFF_TALENTS_NONE then
            specText = TT_TEXT_NONE
        
        -- talents found
        else
            specText = ""
            local spacer, color
            local specNameAdded = false
            
            if cfg.talents and unitCacheRecord.talents.name then
                spacer = (specText ~= "") and " " or ""

                local classColor = LibFroznFunctions:GetClassColor(unitCacheRecord.classFile, "PRIEST")
                specText = specText .. spacer .. classColor:WrapTextInColorCode(unitCacheRecord.talents.name)
                
                specNameAdded = true
            end
        end
        
        -- show spec text
        if specText then
            local tipLineTextTalents = LibFroznFunctions:FormatText("{prefix}: {specText}", {
                ["prefix"] = TT_TEXT_TALENTS_PREFIX,
                ["specText"] = TT_COLOR_TEXT:WrapTextInColorCode(specText)
            })
            
            if ttLineIndexTalents then
                _G["GameTooltipTextLeft" .. ttLineIndexTalents]:SetText(tipLineTextTalents)
            else
                GameTooltip:AddLine(tipLineTextTalents)
                ttLineIndexTalents = GameTooltip:NumLines()
            end
        end
    end
    
    -- average item level
    if cfg.average_lvl and unitCacheRecord.averageItemLevel then
        local ailText
        
        -- average item level available or no item data
        if unitCacheRecord.averageItemLevel == LFF_AVERAGE_ITEM_LEVEL_AVAILABLE then
            if unitCacheRecord.canInspect then
                ailText = TT_TEXT_LOADING
            else
                ailText = TT_TEXT_OUT_OF_RANGE
            end
        
        -- no average item level available
        elseif unitCacheRecord.averageItemLevel == LFF_AVERAGE_ITEM_LEVEL_NA then
            ailText = nil
        
        -- no average item level found
        elseif unitCacheRecord.averageItemLevel == LFF_AVERAGE_ITEM_LEVEL_NONE then
            ailText = TT_TEXT_NONE
        
        -- average item level found
        else
            ailText = unitCacheRecord.averageItemLevel.qualityColor:WrapTextInColorCode(unitCacheRecord.averageItemLevel.value)
        end
        
        -- show ail test
        if ailText then
            local tipLineTextAverageItemLevel = LibFroznFunctions:FormatText("{prefix}: {averageItemLevel}", {
                ["prefix"] = TT_TEXT_AIL_PREFIX,
                ["averageItemLevel"] = TT_COLOR_TEXT:WrapTextInColorCode(ailText)
            })
            
            if ttLineIndexAverageItemLevel then
                _G["GameTooltipTextLeft" .. ttLineIndexAverageItemLevel]:SetText(tipLineTextAverageItemLevel)
            else
                GameTooltip:AddLine(tipLineTextAverageItemLevel)
                ttLineIndexAverageItemLevel = GameTooltip:NumLines()
            end
        end
    end

    if GameTooltip:IsVisible() then
        GameTooltip:Show()
    end
end

local function GTT_OnTooltipSetUnit(self, ...)
    -- get the unit id -- check the UnitFrame unit if this tip is from a concated unit, such as "targettarget".
    local _, unitID = LibFroznFunctions:GetUnitFromTooltip(self)
    
    if not unitID then
        local mouseFocus = GetMouseFocus()
        if (mouseFocus) and (mouseFocus.unit) then
            unitID = mouseFocus.unit
        end
    end
    
    -- no unit id
    if not unitID then
        return
    end
    
    -- check if only talents for people in your party/raid should be shown
    if cfg.talentOnlyInParty and (not UnitInParty(unitID) and not UnitInRaid(unitID)) then
        return
    end
    
    -- invalidate line indexes
    ttLineIndexTalents = nil
    ttLineIndexAverageItemLevel = nil
    
    -- inspect unit
    local unitCacheRecord = LibFroznFunctions:InspectUnit(unitID, GTT_UpdateTooltip, true)
    
    if (unitCacheRecord) then
        GTT_UpdateTooltip(unitCacheRecord)
    end
end

LibFroznFunctions:GameTooltipHookScriptOnTooltipSetUnit(GTT_OnTooltipSetUnit)