local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Real Links
------------------------------------------------------------------------

local module = E:Module("Chat"):Sub("RealLinks")

local C_Item_GetItemInfo = C_Item.GetItemInfo
local C_Item_GetItemQualityColor = C_Item.GetItemQualityColor
local C_CurrencyInfo_GetCurrencyLink = C_CurrencyInfo.GetCurrencyLink
local gsub, gmatch = gsub, gmatch

local queuedMessages = {}

local function getLinkColor(data)
    local linkType, arg1, arg2, arg3 = string.split(":", data)
    if linkType == "item" then
        local _, _, quality = C_Item_GetItemInfo(arg1)
        if quality then
            local _, _, _, color = C_Item_GetItemQualityColor(quality)
            return "|c" .. color
        else
            return nil, true
        end
    elseif linkType == "quest" then
        if arg2 then
            return ConvertRGBtoColorString(GetQuestDifficultyColor(arg2))
        else
            return "|cffffd100"
        end
    elseif linkType == "currency" then
        local link = C_CurrencyInfo_GetCurrencyLink(arg1)
        if link then
            return gsub(link, 0, 10)
        else
            return "|cffffffff"
        end
    elseif linkType == "battlepet" then
        if arg3 ~= -1 then
            local _, _, _, color = C_Item_GetItemQualityColor(arg3)
            return "|c" .. color
        else
            return "|cffffd200"
        end
    elseif linkType == "garrfollower" then
        local _, _, _, color = C_Item_GetItemQualityColor(arg2)
        return "|c" .. color
    elseif linkType == "spell" then
        return "|cff71d5ff"
    elseif linkType == "achievement" or linkType == "garrmission" then
        return "|cffffff00"
    elseif linkType == "trade" or linkType == "enchant" then
        return "|cffffd000"
    elseif linkType == "instancelock" then
        return "|cffff8000"
    elseif linkType == "glyph" or linkType == "journal" then
        return "|cff66bbff"
    elseif linkType == "talent" or linkType == "battlePetAbil" or linkType == "garrfollowerability" then
        return "|cff4e96f7"
    elseif linkType == "levelup" then
        return "|cffff4e00"
    else
        return "|cffffff00"
    end
end

local function messageFilter(self, event, message, ...)
    if issecretvalue(message) then return end
    for link, data in gmatch(message, "(|H(.-)|h.-|h)") do
        local color, queue = getLinkColor(data)
        if queue then
            tinsert(queuedMessages, { self, event, message, ... })
            return true
        elseif color then
            local matchLink = "|H" .. data .. "|h.-|h"
            message = gsub(message, matchLink, color .. link .. "|r", 1)
        end
    end

    return false, message, ...
end

function module:OnInit()
    local handler = CreateFrame("Frame")
    handler:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    handler:SetScript("OnEvent", function()
        if #queuedMessages > 0 then
            for i = 1, #queuedMessages do
                local data = queuedMessages[i]
                if data and type(data) == "table" then
                    local frame = data[1]
                    if frame and frame.GetScript then
                        local onEvent = frame:GetScript("OnEvent")
                        if type(onEvent) == "function" then
                            onEvent(unpack(data))
                        end
                    end
                    queuedMessages[i] = nil
                end
            end

            for i = #queuedMessages, 1, -1 do
                if queuedMessages[i] == nil then
                    table.remove(queuedMessages, i)
                end
            end
        end
    end)

    ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", messageFilter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", messageFilter)
end
