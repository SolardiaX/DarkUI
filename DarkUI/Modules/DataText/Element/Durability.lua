local E, C, L = select(2, ...):unpack()

if not C.stats.enable or not C.stats.config.Durability.enable then return end

----------------------------------------------------------------------------------------
--	Durability of DataText (modified from ShestakUI)
----------------------------------------------------------------------------------------

local _G = _G
local CreateFrame = CreateFrame
local GetInventoryItemDurability = GetInventoryItemDurability
local GetAverageItemLevel = GetAverageItemLevel
local GetInventoryItemTexture = GetInventoryItemTexture
local C_EquipmentSet_GetNumEquipmentSets = C_EquipmentSet.GetNumEquipmentSets
local C_EquipmentSet_GetEquipmentSetInfo = C_EquipmentSet.GetEquipmentSetInfo
local IsAltKeyDown, IsShiftKeyDown = IsAltKeyDown, IsShiftKeyDown
local InCombatLockdown = InCombatLockdown
local EquipmentManager_EquipSet = EquipmentManager_EquipSet
local EasyMenu = EasyMenu
local ToggleCharacter = ToggleCharacter
local floor, min = math.floor, math.min
local format, gsub, gmatch, select, tinsert = format, gsub, gmatch, select, tinsert
local print = print
local DURABILITY = DURABILITY
local STAT_AVERAGE_ITEM_LEVEL = STAT_AVERAGE_ITEM_LEVEL
local REPAIR_COST = REPAIR_COST
local EQUIPMENT_SETS = EQUIPMENT_SETS
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT
local NONE = NONE
local WorldFrame = WorldFrame
local DurabilityFrame = DurabilityFrame
local GameTooltip = GameTooltip

local t_icon = C.stats.iconsize or 20
local cfg = C.stats.config.Durability
local module = E.datatext

module:Inject("Durability", {
    OnLoad  = function(self)
        CreateFrame("GameTooltip", "LPDURA", nil, "GameTooltipTemplate")
        LPDURA:SetOwner(WorldFrame, "ANCHOR_NONE")
        if cfg.man then DurabilityFrame.Show = DurabilityFrame.Hide end
        module:RegEvents(self, "UPDATE_INVENTORY_DURABILITY MERCHANT_SHOW PLAYER_LOGIN")
    end,
    OnEvent = function(self, event)
        if event == "UPDATE_INVENTORY_DURABILITY" or event == "PLAYER_LOGIN" then
            local dmin = 100
            for id = 1, 18 do
                local dur, dmax = GetInventoryItemDurability(id)
                if dur ~= dmax then dmin = floor(min(dmin, dur / dmax * 100)) end
            end
            self.text:SetText(format(gsub(cfg.fmt, "%[color%]", (module:Gradient(dmin / 100))), dmin))
        end
    end,
    OnEnter = function(self)
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:ClearAllPoints()
        GameTooltip:SetPoint(cfg.tip_anchor, cfg.tip_frame, cfg.tip_x, cfg.tip_y)
        GameTooltip:ClearLines()
        if C.tooltip.average_lvl == true then
            local avgItemLevel, avgItemLevelEquipped = GetAverageItemLevel()
            avgItemLevel = floor(avgItemLevel)
            avgItemLevelEquipped = floor(avgItemLevelEquipped)
            GameTooltip:AddDoubleLine(DURABILITY, STAT_AVERAGE_ITEM_LEVEL .. ": " .. avgItemLevelEquipped .. " / " .. avgItemLevel, module.tthead.r, module.tthead.g, module.tthead.b, module.tthead.r, module.tthead.g, module.tthead.b)
        else
            GameTooltip:AddLine(DURABILITY, module.tthead.r, module.tthead.g, module.tthead.b)
        end
        GameTooltip:AddLine(" ")
        local nodur, totalcost = true, 0
        for slot, string in gmatch("1HEAD3SHOULDER5CHEST6WAIST7LEGS8FEET9WRIST10HANDS16MAINHAND17SECONDARYHAND", "(%d+)([^%d]+)") do
            local dur, dmax = GetInventoryItemDurability(slot)
            local str = _G[string .. "SLOT"]
            if dur ~= dmax then
                local perc = dur ~= 0 and dur / dmax or 0
                local hex = module:Gradient(perc)
                GameTooltip:AddDoubleLine(cfg.gear_icons and format("|T%s:" .. t_icon .. ":" .. t_icon .. ":0:0:64:64:5:59:5:59:%d|t %s", GetInventoryItemTexture(P, slot), t_icon, str) or str, format("|cffaaaaaa%s/%s | %s%s%%", dur, dmax, hex, floor(perc * 100)), 1, 1, 1)
                if E.isBeta then
                    local data = LPDURA:GetTooltipData()
                    repairCost = data and data.repairCost or 0
                    totalcost, nodur = totalcost + repairCost
                else
                    totalcost, nodur = totalcost + select(3, LPDURA:SetInventoryItem("player", slot))
                end
            end
        end
        if nodur ~= true then
            GameTooltip:AddDoubleLine(" ", "--------------", 1, 1, 1, 0.5, 0.5, 0.5)
            GameTooltip:AddDoubleLine(REPAIR_COST, module:FormatGold(1, totalcost), module.ttsubh.r, module.ttsubh.g, module.ttsubh.b, 1, 1, 1)
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(" ", L.DATATEXT_AUTO_REPAIR .. ": " .. (C.automation.auto_repair and "|cff55ff55" .. L.DATATEXT_ON or "|cffff5555" .. L.DATATEXT_OFF), 1, 1, 1, module.ttsubh.r, module.ttsubh.g, module.ttsubh.b)
        GameTooltip:Show()
    end,
    OnClick = function(self, button)
        if C_EquipmentSet_GetNumEquipmentSets() > 0 and button == "LeftButton" and (IsAltKeyDown() or IsShiftKeyDown()) then
            local menulist = { { isTitle = true, notCheckable = 1, text = format(gsub(EQUIPMENT_SETS, ":", ""), "") } }
            if C_EquipmentSet_GetNumEquipmentSets() == 0 then
                tinsert(menulist, { text = NONE, notCheckable = 1, disabled = true })
            else
                for _, eSetID in pairs(C_EquipmentSet_GetNumEquipmentSets()) do
                    local name, icon, setID = C_EquipmentSet_GetEquipmentSetInfo(i - 1)
                    if not icon then icon = 134400 end
                    tinsert(menulist, { text = format("|T%s:" .. t_icon .. ":" .. t_icon .. ":0:0:64:64:5:59:5:59:%d|t %s", icon, t_icon, name), notCheckable = 1, func = function()
                        if InCombatLockdown() then
                            print("|cffffff00" .. ERR_NOT_IN_COMBAT .. "|r")
                            return
                        end
                        EquipmentManager_EquipSet(setID)
                    end })
                end
            end
            EasyMenu(menulist, LSMenus, "cursor", 0, 0, "MENU")
        elseif button == "LeftButton" then
            ToggleCharacter("PaperDollFrame")
        elseif button == "RightButton" then
            C.automation.auto_repair = not C.automation.auto_repair
            E:SetVariable("automation", "auto_repair", C.automation.auto_repair)
            
            self:GetScript("OnEnter")(self)
        end
    end
})
