local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Format
------------------------------------------------------------------------

local module = E:Module("CombatText")
local cfg = C.combat.combatText

local format = string.format
local abs = math.abs
local floor = math.floor

local ICON_SIZE = 12
local GOLD_ICON = format("|TInterface\\MoneyFrame\\UI-GoldIcon:%d:%d:2:0|t", ICON_SIZE, ICON_SIZE)
local SILVER_ICON = format("|TInterface\\MoneyFrame\\UI-SilverIcon:%d:%d:2:0|t", ICON_SIZE, ICON_SIZE)
local COPPER_ICON = format("|TInterface\\MoneyFrame\\UI-CopperIcon:%d:%d:2:0|t", ICON_SIZE, ICON_SIZE)

local SCHOOL_COLORS = {
    [1] = "FFFFFF",
    [2] = "F9F1A1",
    [3] = "F7EBCB",
    [4] = "EE7D80",
    [5] = "F7C3BF",
    [6] = "EFB065",
    [8] = "A1DB65",
    [9] = "B2CACD",
    [10] = "C0E88B",
    [12] = "EF8B48",
    [16] = "76CAED",
    [17] = "ADDBE3",
    [18] = "8BE8DF",
    [20] = "4392AA",
    [24] = "5BB28E",
    [28] = "56DBAE",
    [32] = "5B4A98",
    [33] = "D3CCF2",
    [34] = "A159B2",
    [36] = "BE5587",
    [40] = "95CC54",
    [48] = "33519B",
    [64] = "F4A8E4",
    [65] = "F0DEED",
    [66] = "F4E492",
    [68] = "E55C80",
    [72] = "BC69F7",
    [80] = "5252CC",
    [96] = "733799",
    [106] = "5EA0CC",
    [124] = "92F919",
    [126] = "78EFFF",
    [127] = "3F2766",
}

local MISS_TYPE_TEXT = {
    MISS = L.COMBAT_CT_MISS,
    DODGE = L.COMBAT_CT_DODGE,
    PARRY = L.COMBAT_CT_PARRY,
    BLOCK = L.COMBAT_CT_BLOCK,
    ABSORB = L.COMBAT_CT_ABSORB,
    RESIST = L.COMBAT_CT_RESIST,
    IMMUNE = L.COMBAT_CT_IMMUNE,
    DEFLECT = L.COMBAT_CT_DEFLECT,
    REFLECT = L.COMBAT_CT_REFLECT,
    EVADE = L.COMBAT_CT_EVADE,
}

local EVENT_TYPE_FORMATS = {
    OUTBOUND_DAMAGE = {
        variables = { "amount", "skillName" },
        components = {
            {
                type = "icon",
                value = "skillIcons",
                alpha = {
                    type = "conditional",
                    default = 1,
                    conditions = {
                        { variable = "isAutoAttack", value = 0 },
                        { variable = "isRangedAutoAttack", value = 0 },
                    },
                },
            },
            {
                type = "variable",
                value = "amount",
                color = {
                    type = "conditional",
                    default = "FFFF00",
                    conditions = {
                        { variable = "isAutoAttack", value = "FFFFFF" },
                        { variable = "isRangedAutoAttack", value = "FFFFFF" },
                    },
                },
                useSchoolColor = false,
            },
        },
        eligibleQueues = { "OUTBOUND" },
    },
    OUTBOUND_PET_DAMAGE = {
        variables = { "amount", "skillName" },
        components = {
            {
                type = "icon",
                value = "skillIcons",
                alpha = {
                    type = "conditional",
                    default = 1,
                    conditions = {
                        { variable = "isAutoAttack", value = 0 },
                        { variable = "isRangedAutoAttack", value = 0 },
                    },
                },
            },
            { type = "text", value = L.COMBAT_CT_PET, color = "0000FF" },
            { type = "variable", value = "amount", color = "FFFFFF", useSchoolColor = false },
        },
        eligibleQueues = { "OUTBOUND" },
    },
    OUTBOUND_HEAL = {
        variables = { "amount", "skillName" },
        components = {
            { type = "icon", value = "skillIcons" },
            { type = "text", value = "+", color = "00FF00" },
            { type = "variable", value = "amount", color = "00FF00", useSchoolColor = false },
        },
        eligibleQueues = { "OUTBOUND" },
    },
    OUTBOUND_MISS = {
        variables = { "missType" },
        components = {
            { type = "icon", value = "skillIcons" },
            { type = "variable", value = "missType", color = "CCCCCC", useSchoolColor = false },
        },
        eligibleQueues = { "OUTBOUND" },
    },
    INBOUND_WOUND = {
        variables = { "amount" },
        components = {
            { type = "text", value = "-", color = "FF0000" },
            { type = "variable", value = "amount", color = "FFFFFF", useSchoolColor = true },
        },
        eligibleQueues = { "INBOUND" },
    },
    INBOUND_HEAL = {
        variables = { "amount" },
        components = {
            { type = "text", value = "+", color = "00FF00" },
            { type = "variable", value = "amount", color = "FFFFFF", useSchoolColor = true },
        },
        eligibleQueues = { "INBOUND" },
    },
    INBOUND_MISS = {
        components = { { type = "text", value = L.COMBAT_CT_MISS, color = "0000FF" } },
        eligibleQueues = { "INBOUND" },
    },
    INBOUND_PARRY = {
        components = { { type = "text", value = L.COMBAT_CT_PARRY, color = "0000FF" } },
        eligibleQueues = { "INBOUND" },
    },
    INBOUND_DODGE = {
        components = { { type = "text", value = L.COMBAT_CT_DODGE, color = "0000FF" } },
        eligibleQueues = { "INBOUND" },
    },
    INBOUND_BLOCK = {
        components = { { type = "text", value = L.COMBAT_CT_BLOCK, color = "0000FF" } },
        eligibleQueues = { "INBOUND" },
    },
    INBOUND_ABSORB = {
        components = { { type = "text", value = L.COMBAT_CT_ABSORB, color = "0000FF" } },
        eligibleQueues = { "INBOUND" },
    },
    INBOUND_RESIST = {
        components = { { type = "text", value = L.COMBAT_CT_RESIST, color = "0000FF" } },
        eligibleQueues = { "INBOUND" },
    },
    INBOUND_IMMUNE = {
        components = { { type = "text", value = L.COMBAT_CT_IMMUNE, color = "0000FF" } },
        eligibleQueues = { "INBOUND" },
    },
    ENTER_COMBAT = {
        components = { { type = "text", value = L.COMBAT_CT_ENTER_COMBAT, color = "FFFFFF" } },
        eligibleQueues = { "NOTIFICATION" },
    },
    EXIT_COMBAT = {
        components = { { type = "text", value = L.COMBAT_CT_EXIT_COMBAT, color = "FFFFFF" } },
        eligibleQueues = { "NOTIFICATION" },
    },
    AURA_ADDED = {
        variables = { "skillName" },
        components = {
            { type = "icon", value = "skillIcon" },
            { type = "text", value = "[", color = "FFFF00" },
            { type = "variable", value = "skillName", color = "FFFF00" },
            { type = "text", value = "]", color = "FFFF00" },
        },
        eligibleQueues = { "NOTIFICATION" },
    },
    AURA_REMOVED = {
        variables = { "skillName" },
        components = {
            { type = "icon", value = "skillIcon" },
            { type = "text", value = "-[", color = "FFFF00" },
            { type = "variable", value = "skillName", color = "FFFF00" },
            { type = "text", value = "]", color = "FFFF00" },
        },
        eligibleQueues = { "NOTIFICATION" },
    },
    SELF_SPELL_ACTIVE = {
        variables = { "skillName" },
        components = {
            { type = "variable", value = "skillName", color = "FFFF00" },
            { type = "text", value = "!", color = "FFFF00" },
        },
        eligibleQueues = { "NOTIFICATION" },
    },
    SELF_ITEM_LOOTED = {
        variables = { "amount", "itemName", "totalAmount" },
        components = {
            { type = "text", value = "+", color = "FFFF00" },
            { type = "variable", value = "amount", color = "FFFF00" },
            { type = "text", value = " ", color = "FFFFFF" },
            { type = "variable", value = "itemName", color = "FFFF00" },
            { type = "text", value = " (", color = "FFFF00" },
            { type = "variable", value = "totalAmount", color = "FFFF00" },
            { type = "text", value = ")", color = "FFFF00" },
        },
        eligibleQueues = { "STATIC" },
    },
    SELF_MONEY_LOOTED = {
        variables = { "gold", "silver", "copper" },
        components = {
            { type = "text", value = "+", color = "FFFF00" },
            { type = "money" },
        },
        eligibleQueues = { "STATIC" },
    },
    SELF_CURRENCY_GAINED = {
        variables = { "quantityChange", "currencyName", "totalAmount" },
        components = {
            { type = "text", value = "+", color = "FFFF00" },
            { type = "variable", value = "quantityChange", color = "FFFF00" },
            { type = "text", value = " ", color = "FFFFFF" },
            { type = "variable", value = "currencyName", color = "FFFFFF" },
            { type = "text", value = " (", color = "FFFF00" },
            { type = "variable", value = "totalAmount", color = "FFFF00" },
            { type = "text", value = ")", color = "FFFF00" },
        },
        eligibleQueues = { "STATIC" },
    },
}

local ITEM_QUALITY_COLORS = {
    [0] = "9D9D9D",
    [1] = "FFFFFF",
    [2] = "1EFF00",
    [3] = "0070DD",
    [4] = "A335EE",
    [5] = "FF8000",
    [6] = "E6CC80",
    [7] = "00CCFF",
    [8] = "00CCFF",
}

local function formatEvent(dataEvent)
    local fmt = EVENT_TYPE_FORMATS[dataEvent.eventType]

    if not fmt and dataEvent.eventType and dataEvent.eventType:find("^SELF_ITEM_LOOTED_") then fmt = EVENT_TYPE_FORMATS["SELF_ITEM_LOOTED"] end

    if not fmt then return end

    local queueName = fmt.eligibleQueues and fmt.eligibleQueues[1]
    if not queueName then return end

    local displayEvent = {}
    displayEvent.eligibleScrollFrames = fmt.eligibleQueues

    local message = ""
    if fmt.components then
        for _, component in ipairs(fmt.components) do
            if component.type == "icon" then
                local alpha = 1
                if component.alpha and component.alpha.type == "conditional" then
                    if component.alpha.conditions then
                        alpha = component.alpha.default or 1
                        for i = #component.alpha.conditions, 1, -1 do
                            local condition = component.alpha.conditions[i]
                            if type(dataEvent[condition.variable]) == "boolean" then
                                alpha = C_CurveUtil.EvaluateColorValueFromBoolean(dataEvent[condition.variable], condition.value, alpha)
                            end
                        end
                    else
                        local val = dataEvent[component.alpha.variable]
                        alpha = C_CurveUtil.EvaluateColorValueFromBoolean(val, component.alpha["true"], component.alpha["false"])
                    end
                end
                displayEvent.iconTexture = dataEvent[component.value]
                displayEvent.iconAlpha = alpha
            else
                local text = nil
                if component.type == "text" then
                    text = component.value
                elseif component.type == "variable" then
                    text = dataEvent[component.value]
                    if component.value == "missType" and text then text = MISS_TYPE_TEXT[text] or text end
                elseif component.type == "money" then
                    local g = dataEvent.gold or 0
                    local s = dataEvent.silver or 0
                    local c = dataEvent.copper or 0
                    local parts = ""
                    if g > 0 then parts = parts .. "|cFFFFD700" .. format("%d", g) .. "|r" .. GOLD_ICON end
                    if s > 0 then parts = parts .. " |cFFC0C0C0" .. format("%d", s) .. "|r" .. SILVER_ICON end
                    if c > 0 or (g == 0 and s == 0) then parts = parts .. " |cFFB87333" .. format("%d", c) .. "|r" .. COPPER_ICON end
                    text = parts
                end

                if text ~= nil then
                    local color = component.color
                    if type(color) == "table" and color.type == "conditional" then
                        if color.conditions then
                            local resultColor = CreateColorFromHexString("FF" .. (color.default or "FFFFFF"))
                            for i = #color.conditions, 1, -1 do
                                local condition = color.conditions[i]
                                local colorTrue = CreateColorFromHexString("FF" .. condition.value)
                                if type(dataEvent[condition.variable]) == "boolean" then
                                    resultColor = C_CurveUtil.EvaluateColorFromBoolean(dataEvent[condition.variable], colorTrue, resultColor)
                                end
                            end
                            text = resultColor:WrapTextInColorCode(text)
                        else
                            local val = dataEvent[color.variable]
                            local colorTrue = CreateColorFromHexString("FF" .. color["true"])
                            local colorFalse = CreateColorFromHexString("FF" .. color["false"])
                            local resultColor = C_CurveUtil.EvaluateColorFromBoolean(val, colorTrue, colorFalse)
                            text = resultColor:WrapTextInColorCode(text)
                        end
                    else
                        if component.useSchoolColor and dataEvent.damageType and SCHOOL_COLORS[dataEvent.damageType] then
                            color = SCHOOL_COLORS[dataEvent.damageType]
                        end
                        if component.value == "itemName" and dataEvent.itemQuality and ITEM_QUALITY_COLORS[dataEvent.itemQuality] then
                            color = ITEM_QUALITY_COLORS[dataEvent.itemQuality]
                        end
                        if color then text = "|cFF" .. color .. text .. "|r" end
                    end
                    message = message .. text
                end
            end
        end
    end

    displayEvent.message = message

    if dataEvent.spellCount and dataEvent.spellCount > 1 then
        if string.find(dataEvent.eventType, "OUTBOUND") then
            local groupAppearance = cfg.group_appearance or "ALL_ICONS"
            if groupAppearance == "FIRST_ICON_PLUS_N" then
                if displayEvent.iconTexture and type(displayEvent.iconTexture) == "table" and #displayEvent.iconTexture > 0 then
                    displayEvent.iconTexture = { displayEvent.iconTexture[1] }
                end
                displayEvent.countText = format("|cFFFFFFFF[+%d]|r", dataEvent.spellCount - 1)
            end
        else
            displayEvent.message = (displayEvent.message or "") .. format("|cFFFFFFFF [%s]|r", dataEvent.spellCount)
        end
    end

    displayEvent.eventType = dataEvent.eventType
    displayEvent.skillID = dataEvent.skillID
    displayEvent.skillName = dataEvent.skillName
    displayEvent.isCrit = dataEvent.isCrit

    module.Display.AnimateEvent(displayEvent)
end

module.Display = module.Display or {}
module.Display.Format = formatEvent
module.Display.SCHOOL_COLORS = SCHOOL_COLORS
