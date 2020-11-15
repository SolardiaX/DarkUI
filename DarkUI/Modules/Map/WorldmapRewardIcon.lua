local E, C, L = select(2, ...):unpack()

if not C.map.worldmap.enable and not C.map.worldmap.rewardIcon then return end

----------------------------------------------------------------------------------------
-- Reward Quest Item Icon
----------------------------------------------------------------------------------------

local CreateFrame = CreateFrame
local GetItemInfoInstant, GetQuestLogRewardMoney = GetItemInfoInstant, GetQuestLogRewardMoney
local GetNumQuestLogRewardCurrencies = GetNumQuestLogRewardCurrencies
local GetQuestLogRewardCurrencyInfo = GetQuestLogRewardCurrencyInfo
local GetNumQuestLogRewards, GetQuestLogRewardInfo = GetNumQuestLogRewards, GetQuestLogRewardInfo
local GetItemInfo = GetItemInfo
local C_PvP_IsWarModeDesired = C_PvP.IsWarModeDesired
local C_QuestLog_QuestHasWarModeBonus = C_QuestLog.QuestHasWarModeBonus
local C_QuestLog_GetQuestTagInfo = C_QuestLog.GetQuestTagInfo
local C_CurrencyInfo_GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
local Lerp, Saturate = Lerp, Saturate
local select, pairs, tonumber, floor = select, pairs, tonumber, floor
local STANDARD_TEXT_FONT = STANDARD_TEXT_FONT
local WorldMapFrame, FlightMapFrame = WorldMapFrame, FlightMapFrame

local CacheQuestItemReward = {}
local list = {
    [1579] = 2164,
    [1598] = 2163,
    [1600] = 2157,
    [1595] = 2156,
    [1597] = 2103,
    [1596] = 2158,
    [1599] = 2159,
    [1593] = 2160,
    [1594] = 2162,
    [1592] = 2161
}
local SlotToIcon = {
    ["INVTYPE_HEAD"]                        = "transmog-nav-slot-head",
    ["INVTYPE_NECK"]                        = "Warlock-ReadyShard",
    ["INVTYPE_SHOULDER"]                    = "transmog-nav-slot-shoulder",
    ["INVTYPE_CHEST"]                       = "transmog-nav-slot-chest",
    ["INVTYPE_WAIST"]                       = "transmog-nav-slot-waist",
    ["INVTYPE_LEGS"]                        = "transmog-nav-slot-legs",
    ["INVTYPE_FEET"]                        = "transmog-nav-slot-feet",
    ["INVTYPE_WRIST"]                       = "transmog-nav-slot-wrist",
    ["INVTYPE_HAND"]                        = "transmog-nav-slot-hands",
    ["INVTYPE_FINGER"]                      = "Warlock-ReadyShard",
    ["INVTYPE_TRINKET"]                     = "Warlock-ReadyShard",
    ["INVTYPE_CLOAK"]                       = "transmog-nav-slot-back",
    ["INVTYPE_WEAPON"]                      = "transmog-nav-slot-mainhand",
    ["INVTYPE_2HWEAPON"]                    = "transmog-nav-slot-mainhand",
    ["INVTYPE_RANGED"]                      = "transmog-nav-slot-mainhand",
    ["INVTYPE_RANGEDRIGHT"]                 = "transmog-nav-slot-mainhand",
    ["INVTYPE_WEAPONMAINHAND"]              = "transmog-nav-slot-mainhand",
    ["INVTYPE_SHIELD"]                      = "transmog-nav-slot-secondaryhand",
    ["INVTYPE_WEAPONOFFHAND"]               = "transmog-nav-slot-secondaryhand",
    [select(3, GetItemInfoInstant(141265))] = "Warlock-ReadyShard"
}
local GENERAL_MAPS = {
    --1: continent A, 2: azeroth, 3: argus, 4: continent B
    [947] = 2,
    [875] = 1,
    [876] = 1,
    [619] = 4,
    [905] = 3,
    [994] = 3,
    [572] = 4,
    [113] = 4,
    [424] = 4,
    [12]  = 4,
    [13]  = 4,
    [101] = 4
}
local LE = {
    LE_QUEST_TAG_TYPE_INVASION   = LE_QUEST_TAG_TYPE_INVASION,
    LE_QUEST_TAG_TYPE_DUNGEON    = LE_QUEST_TAG_TYPE_DUNGEON,
    LE_QUEST_TAG_TYPE_RAID       = LE_QUEST_TAG_TYPE_RAID,
    LE_WORLD_QUEST_QUALITY_RARE  = LE_WORLD_QUEST_QUALITY_RARE,
    LE_WORLD_QUEST_QUALITY_EPIC  = LE_WORLD_QUEST_QUALITY_EPIC,
    LE_QUEST_TAG_TYPE_PVP        = LE_QUEST_TAG_TYPE_PVP,
    LE_QUEST_TAG_TYPE_PET_BATTLE = LE_QUEST_TAG_TYPE_PET_BATTLE,
    LE_QUEST_TAG_TYPE_PROFESSION = LE_QUEST_TAG_TYPE_PROFESSION,
    LE_ITEM_QUALITY_COMMON       = LE_ITEM_QUALITY_COMMON,
    BAG_ITEM_QUALITY_COLORS      = BAG_ITEM_QUALITY_COLORS,
    ITEM_SPELL_TRIGGER_ONUSE     = ITEM_SPELL_TRIGGER_ONUSE,
    ITEM_BIND_ON_EQUIP           = ITEM_BIND_ON_EQUIP,
    ARTIFACT_POWER               = ARTIFACT_POWER,
    AZERITE                      = C_CurrencyInfo_GetCurrencyInfo(1553),
    ORDER_RESOURCES_NAME_LEGION  = C_CurrencyInfo_GetCurrencyInfo(1220),
    ORDER_RESOURCES_NAME_BFA     = C_CurrencyInfo_GetCurrencyInfo(1560)
}
local function HookOnEnter(self)
    self.pinFrameLevelType = "PIN_FRAME_LEVEL_TOPMOST"
    self:ApplyFrameLevel()
end
local function HookOnLeave(self)
    self.pinFrameLevelType = "PIN_FRAME_LEVEL_WORLD_QUEST"
    self:ApplyFrameLevel()
end
local UpdateFrameLevelFunc = function(self)
    if self.obj then
        local lvl = self.obj:GetFrameLevel()
        if self.frLvl ~= lvl then
            self:SetFrameLevel(lvl)
            self.frLvl = lvl
        end
    end
end
local function AddText(table, obj, num, text)
    num = num + 1
    local t = table[num]
    if not t then
        t = CreateFrame("Frame", nil, table.c)
        t:SetSize(1, 1)
        t.t = t:CreateFontString(nil, "OVERLAY", "GameFontWhite")
        t.t:SetPoint("CENTER")
        t:SetScale(table.s)
        t:SetScript("OnUpdate", UpdateFrameLevelFunc)
        table[num] = t
    end
    t.obj = obj:GetParent()
    t.t:SetFont(STANDARD_TEXT_FONT, 21, "OUTLINE")
    t.t:SetTextColor(1, 1, 1, 1)
    t:SetPoint("CENTER", obj, 0, 0)
    t.t:SetText(text)
    if not t:IsShown() then
        t:Show()
    end
    return num
end
local function CreateMapTextOverlay(mapFrame, pinName)
    local mapCanvas = mapFrame:GetCanvas()
    local textsFrame = CreateFrame("Frame", nil, mapCanvas)
    textsFrame:SetPoint("TOPLEFT")
    textsFrame:SetSize(1, 1)
    textsFrame:SetFrameLevel(10000)
    local textsTable = {}
    textsTable.s = 1
    local prevScale
    textsFrame:SetScript(
            "OnUpdate",
            function(_)
                local nowScale = mapCanvas:GetScale()
                if nowScale ~= prevScale then
                    local pins = mapFrame.pinPools[pinName]
                    if pins then
                        local scaleFactor, startScale, endScale
                        for obj, _ in pairs(pins.activeObjects) do
                            scaleFactor = obj.scaleFactor
                            startScale = obj.startScale
                            endScale = obj.endScale
                            break
                        end
                        local scale
                        if startScale and startScale and endScale then
                            local parentScaleFactor = 1.0 / mapFrame:GetCanvasScale()
                            scale = parentScaleFactor * Lerp(startScale, endScale, Saturate(scaleFactor * mapFrame:GetCanvasZoomPercent()))
                        else
                            scale = 1
                        end
                        if scale then
                            scale = scale * mapFrame:GetGlobalPinScale()
                            for i = 1, #textsTable do
                                textsTable[i]:SetScale(scale)
                            end
                        end
                        textsTable.s = scale or 1
                    end
                end
            end
    )
    textsTable.f = textsFrame
    textsTable.c = mapCanvas
    return textsTable
end

local WorldMapFrame_TextTable = CreateMapTextOverlay(WorldMapFrame, "WorldMap_WorldQuestPinTemplate")

local function WorldQuestList_WQIcons_AddIcons(frame, pinName)
    frame = frame or WorldMapFrame
    local GetCurrentMapAreaID = function() return WorldMapFrame:GetMapID() or 0 end, tonumber
    local pins = frame.pinPools[pinName or "WorldMap_WorldQuestPinTemplate"]
    if pins then
        local isWorldMapFrame = frame == WorldMapFrame
        local isRibbonDisabled = isWorldMapFrame and GENERAL_MAPS[GetCurrentMapAreaID()]
        local tCount = 0
        if isWorldMapFrame then
            if not WorldMapFrame_TextTable.f:IsShown() then
                WorldMapFrame_TextTable.f:Show()
            end
        end
        for obj, _ in pairs(pins.activeObjects) do
            local icon = obj.WQL_rewardIcon
            if obj.questID then
                if not icon then
                    icon = obj:CreateTexture(nil, "ARTWORK")
                    obj.WQL_rewardIcon = icon
                    icon:SetPoint("CENTER", 0, 0)
                    icon:SetSize(43, 43)
                    local iconWMask = obj:CreateTexture(nil, "ARTWORK")
                    obj.WQL_rewardIconWMask = iconWMask
                    iconWMask:SetPoint("CENTER", 0, 0)
                    iconWMask:SetSize(43, 43)
                    iconWMask:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask")
                    local ribbon = obj:CreateTexture(nil, "BACKGROUND")
                    obj.WQL_rewardRibbon = ribbon
                    ribbon:SetPoint("TOP", obj, "BOTTOM", 3, 21)
                    ribbon:SetSize(66, 43)
                    --ribbon:SetAtlas("UI-Frame-Neutral-Ribbon")
                    local iconTopRight = obj:CreateTexture(nil, "OVERLAY")
                    obj.WQL_iconTopRight = iconTopRight
                    iconTopRight:SetPoint("TOPRIGHT", obj, "TOPRIGHT", 0, 0)
                    iconTopRight:SetSize(21, 21)
                    obj:HookScript("OnEnter", HookOnEnter)
                    obj:HookScript("OnLeave", HookOnLeave)
                end
                local _, _, worldQuestType, _, _, _, _ = C_QuestLog_GetQuestTagInfo(obj.questID)
                local iconAtlas, iconTexture, iconVirtual
                local ajustSize, ajustMask = 0
                local amount, amountIcon, amountColor = 0
                -- money
                local money = GetQuestLogRewardMoney(obj.questID)
                if money > 0 then
                    iconAtlas = "Auctioneer"
                    amount = floor(money / 10000 * (C_PvP_IsWarModeDesired() and C_QuestLog_QuestHasWarModeBonus(obj.questID) and 1.1 or 1))
                end
                -- currency
                for i = 1, GetNumQuestLogRewardCurrencies(obj.questID) do
                    local _, texture, numItems, currencyID = GetQuestLogRewardCurrencyInfo(i, obj.questID)
                    if currencyID == 1508 or currencyID == 1533 then
                        --Veiled Argunite, Wakening Essence
                        iconTexture = texture
                        ajustMask = true
                        ajustSize = 8
                        amount = floor(numItems * (C_PvP_IsWarModeDesired() and C_QuestLog_QuestHasWarModeBonus(obj.questID) and 1.1 or 1))
                        break
                    elseif currencyID == 1553 then
                        --azerite
                        --iconAtlas = "Islands-AzeriteChest"
                        iconAtlas = "AzeriteReady"
                        amount = floor(numItems * (C_PvP_IsWarModeDesired() and C_QuestLog_QuestHasWarModeBonus(obj.questID) and 1.1 or 1))
                        ajustSize = 5
                        break
                    elseif currencyID == 1220 or currencyID == 1560 then
                        --OR
                        iconAtlas = "legionmission-icon-currency"
                        ajustSize = 5
                        amount = floor(numItems * (C_PvP_IsWarModeDesired() and C_QuestLog_QuestHasWarModeBonus(obj.questID) and 1.1 or 1))
                        break
                    elseif list[currencyID or 0] then
                        iconAtlas = "poi-workorders"
                        amount = numItems
                        amountIcon = texture
                        break
                    end
                end
                -- item
                if GetNumQuestLogRewards(obj.questID) > 0 then
                    local _, icon, numItems, quality, _, itemID = GetQuestLogRewardInfo(1, obj.questID)
                    if itemID then
                        local itemLevel = select(4, GetItemInfo(itemID))
                        if itemLevel > 130 then
                            iconAtlas = "Banker"
                            amount = 0
                            --iconAtlas = "ChallengeMode-icon-chest"

                            local itemLink = CacheQuestItemReward[obj.questID]
                            local inspectScantip = CreateFrame("GameTooltip", "WorldQuestListInspectScanningTooltip", nil, "GameTooltipTemplate")
                            inspectScantip:SetOwner(UIParent, "ANCHOR_NONE")
                            if not itemLink then
                                inspectScantip:SetQuestLogItem("reward", 1, obj.questID)
                                itemLink = select(2, inspectScantip:GetItem())
                                inspectScantip:ClearLines()

                                CacheQuestItemReward[obj.questID] = itemLink
                            end
                            if itemLink then
                                itemLevel = select(4, GetItemInfo(itemLink))
                                if itemLevel then
                                    amount = itemLevel
                                    if quality and quality > 1 then
                                        --local colorTable = BAG_ITEM_QUALITY_COLORS[quality]
                                        --amountColor = format("|cff%02x%02x%02x",colorTable.r * 255,colorTable.g * 255,colorTable.b * 255)
                                    end
                                end
                            end
                            local itemSubType, inventorySlot = select(3, GetItemInfoInstant(itemID))
                            if inventorySlot and SlotToIcon[inventorySlot] then
                                iconAtlas = SlotToIcon[inventorySlot]
                                ajustSize = iconAtlas == "Warlock-ReadyShard" and 0 or 10
                            elseif itemSubType and SlotToIcon[itemSubType] then
                                iconAtlas = SlotToIcon[itemSubType]
                                ajustSize = iconAtlas == "Warlock-ReadyShard" and 0 or 10
                            end
                        end
                        if itemID == 124124 or itemID == 151568 then
                            iconTexture = icon
                            ajustMask = true
                            ajustSize = 4
                            if numItems then
                                amount = numItems
                            end
                        elseif itemID == 152960 or itemID == 152957 then
                            iconAtlas = "poi-workorders"
                        elseif itemID == 163857 or itemID == 143559 or itemID == 141920 then
                            iconTexture = icon
                            ajustMask = true
                            ajustSize = 4
                        end
                        if worldQuestType == LE.LE_QUEST_TAG_TYPE_PET_BATTLE then
                            iconVirtual = true
                            amountIcon = icon
                            amount = numItems
                        elseif worldQuestType == LE.LE_QUEST_TAG_TYPE_DUNGEON or worldQuestType == LE.LE_QUEST_TAG_TYPE_RAID then
                            iconVirtual = true
                            amountIcon = icon
                            amount = itemLevel or numItems
                        end
                    end
                end
                if worldQuestType == LE.LE_QUEST_TAG_TYPE_DUNGEON then
                    iconAtlas, iconTexture = nil
                elseif worldQuestType == LE.LE_QUEST_TAG_TYPE_RAID then
                    iconAtlas, iconTexture = nil
                end
                if worldQuestType == LE.LE_QUEST_TAG_TYPE_PVP then
                    if obj.WQL_iconTopRight.curr ~= "worldquest-icon-pvp-ffa" then
                        obj.WQL_iconTopRight:SetAtlas("worldquest-icon-pvp-ffa")
                        obj.WQL_iconTopRight.curr = "worldquest-icon-pvp-ffa"
                    end
                elseif worldQuestType == LE.LE_QUEST_TAG_TYPE_PET_BATTLE and (iconTexture or iconAtlas) then
                    if obj.WQL_iconTopRight.curr ~= "worldquest-icon-petbattle" then
                        obj.WQL_iconTopRight:SetAtlas("worldquest-icon-petbattle")
                        obj.WQL_iconTopRight.curr = "worldquest-icon-petbattle"
                    end
                elseif worldQuestType == LE.LE_QUEST_TAG_TYPE_PROFESSION then
                    if obj.WQL_iconTopRight.curr ~= "worldquest-icon-engineering" then
                        obj.WQL_iconTopRight:SetAtlas("worldquest-icon-engineering")
                        obj.WQL_iconTopRight.curr = "worldquest-icon-engineering"
                    end
                elseif worldQuestType == LE.LE_QUEST_TAG_TYPE_INVASION then
                    if obj.WQL_iconTopRight.curr ~= "worldquest-icon-burninglegion" then
                        obj.WQL_iconTopRight:SetAtlas("worldquest-icon-burninglegion")
                        obj.WQL_iconTopRight.curr = "worldquest-icon-burninglegion"
                    end
                else
                    if obj.WQL_iconTopRight.curr then
                        obj.WQL_iconTopRight:SetTexture()
                        obj.WQL_iconTopRight.curr = nil
                    end
                end
                if iconTexture or iconAtlas or iconVirtual then
                    if not iconVirtual then
                        icon:SetSize(43 + ajustSize, 43 + ajustSize)
                        obj.WQL_rewardIconWMask:SetSize(43 + ajustSize, 43 + ajustSize)
                        if iconTexture then
                            if ajustMask then
                                if obj.WQL_rewardIconWMask.curr ~= iconTexture then
                                    obj.WQL_rewardIconWMask:SetTexture(iconTexture)
                                    obj.WQL_rewardIconWMask.curr = iconTexture
                                end
                                if icon.curr then
                                    icon:SetTexture()
                                    icon.curr = nil
                                end
                            else
                                if obj.WQL_rewardIconWMask.curr then
                                    obj.WQL_rewardIconWMask:SetTexture()
                                    obj.WQL_rewardIconWMask.curr = nil
                                end
                                if icon.curr ~= iconTexture then
                                    icon:SetTexture(iconTexture)
                                    icon.curr = iconTexture
                                end
                            end
                        else
                            if obj.WQL_rewardIconWMask.curr then
                                obj.WQL_rewardIconWMask:SetTexture()
                                obj.WQL_rewardIconWMask.curr = nil
                            end
                            if icon.curr ~= iconAtlas then
                                icon:SetAtlas(iconAtlas)
                                icon.curr = iconAtlas
                            end
                        end
                        obj.Texture:SetTexture()
                    end
                    if amount > 0 and not isRibbonDisabled then
                        if not obj.WQL_rewardRibbon:IsShown() then
                            obj.WQL_rewardRibbon:Show()
                        end
                        obj.WQL_rewardRibbon:SetAlpha(1)
                        obj.WQL_rewardRibbon:SetWidth((#tostring(amount) + (amountIcon and 1.5 or 0)) * 21 + 43)
                        obj.TimeLowFrame:SetPoint("CENTER", -21, -8)
                        if isWorldMapFrame then
                            tCount = AddText(
                                    WorldMapFrame_TextTable,
                                    obj.WQL_rewardRibbon,
                                    tCount,
                                    (amountIcon and "|T" .. amountIcon .. ":0|t" or "") .. (amountColor or "") .. amount
                            )
                        end
                    elseif obj.WQL_rewardRibbon:IsShown() then
                        obj.WQL_rewardRibbon:Hide()
                        obj.TimeLowFrame:SetPoint("CENTER", -16, -16)
                    end
                else
                    if obj.WQL_rewardIconWMask.curr then
                        obj.WQL_rewardIconWMask:SetTexture()
                        obj.WQL_rewardIconWMask.curr = nil
                    end
                    if icon.curr then
                        icon:SetTexture()
                        icon.curr = nil
                    end
                    if obj.WQL_rewardRibbon:IsShown() then
                        obj.WQL_rewardRibbon:Hide()
                        obj.TimeLowFrame:SetPoint("CENTER", -16, -16)
                    end
                end
                obj.WQL_questID = obj.questID
            end
        end
        if isWorldMapFrame then
            for i = tCount + 1, #WorldMapFrame_TextTable do
                WorldMapFrame_TextTable[i]:Hide()
            end
        end
        for _, obj in pairs(pins.inactiveObjects) do
            if obj.WQL_rewardIcon then
                if obj.WQL_rewardIconWMask.curr then
                    obj.WQL_rewardIconWMask:SetTexture()
                    obj.WQL_rewardIconWMask.curr = nil
                end
                if obj.WQL_rewardIcon.curr then
                    obj.WQL_rewardIcon:SetTexture()
                    obj.WQL_rewardIcon.curr = nil
                end
                if obj.WQL_iconTopRight.curr then
                    obj.WQL_iconTopRight:SetTexture()
                    obj.WQL_iconTopRight.curr = nil
                end
                obj.WQL_rewardRibbon:Hide()
                obj.TimeLowFrame:SetPoint("CENTER", -16, -16)
            end
            obj.WQL_questID = nil
        end
    elseif frame == WorldMapFrame then
        for i = 1, #WorldMapFrame_TextTable do
            WorldMapFrame_TextTable[i]:Hide()
        end
    end
end

WorldMapFrame:RegisterCallback(
        "WorldQuestsUpdate",
        function()
            WorldQuestList_WQIcons_AddIcons()
            WorldQuestList_WQIcons_AddIcons(FlightMapFrame, "FlightMap_WorldQuestPinTemplate")
        end,
        WorldMapFrame
)
