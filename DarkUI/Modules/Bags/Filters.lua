local _, ns = ...
local E, C, L = ns:unpack()
local cargBags = ns.cargBags

if not C.bags.enable then return end

----------------------------------------------------------------------------------------
--    Filters of Bags (modified from cargBags_Nivaya)
----------------------------------------------------------------------------------------

local NumBagContainer = 5
local BankContainerStartID = NumBagContainer + 1
local MaxNumContainer = 12
local AccountBankContainer = 13
local AccountBankContainerMaxNum = 17

local cbNivaya = cargBags:NewImplementation("Nivaya")
cbNivaya:RegisterBlizzard()
cbNivaya:HookScript("OnShow", function() PlaySound(SOUNDKIT.IG_BACKPACK_OPEN) end)
cbNivaya:HookScript("OnHide", function() PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE) end)
function cbNivaya:UpdateBags() for i = -3, MaxNumContainer do cbNivaya:UpdateBag(i) end end

cB_Filters = {}
cBniv_CatInfo = {}
cB_ItemClass = {}

cB_existsBankBag = { Armor = true, Gem = true, Quest = true, TradeGoods = true, Consumables = true, ArtifactPower = true, BattlePet = true, Junk = true }
cB_filterEnabled = { Armor = true, Gem = true, Quest = true, TradeGoods = true, Consumables = true, Keyring = true, Junk = true, Stuff = true, ItemSets = true, ArtifactPower = true, BattlePet = true }

--------------------
--Basic filters
--------------------
cB_Filters.fBags = function(item) return item.bagId >= 0 and item.bagId <= NumBagContainer end
cB_Filters.fBank = function(item) return item.bagId == -1 or item.bagId >= BankContainerStartID and item.bagId <= MaxNumContainer end
cB_Filters.fBankReagent = function(item) return item.bagId == -3 end
cB_Filters.fBankFilter = function() return _G.SavedStats.cBnivCfg.FilterBank end
cB_Filters.fHideEmpty = function(item) if _G.SavedStats.cBnivCfg.CompressEmpty then return item.link ~= nil else return true end end

------------------------------------
-- General Classification (cached)
------------------------------------
cB_Filters.fItemClass = function(item, container)
    if not item.id or not item.name then return false end    -- incomplete data (itemID or itemName missing), return (item that aren't loaded yet will get classified on the next successful call)
    if not cB_ItemClass[item.id] or item.bagId == -2 then cbNivaya:ClassifyItem(item) end
    
    local t, bag = cB_ItemClass[item.id]
    local isBankBag = item.bagId == -1 or (item.bagId >= BankContainerStartID and item.bagId <= MaxNumContainer)
    if isBankBag then
        bag = (cB_existsBankBag[t] and _G.SavedStats.cBnivCfg.FilterBank and cB_filterEnabled[t]) and "Bank"..t or "Bank"
    else
        bag = (t ~= "NoClass" and cB_filterEnabled[t]) and t or "Bag"
    end

    return bag == container
end

function cbNivaya:ClassifyItem(item)
    -- keyring
    if item.bagId == -2 then cB_ItemClass[item.id] = "Keyring"; return true end

    -- user assigned containers
    local tC = cBniv_CatInfo[item.id]
    if tC then cB_ItemClass[item.id] = tC; return true end

    -- junk
    if (item.quality == 0) then cB_ItemClass[item.id] = "Junk"; return true end

    -- type based filters
    if item.type then
        if        (item.type == L.BAG_ARMOR) or (item.type == L.BAG_WEAPON)    then cB_ItemClass[item.id] = "Armor"; return true
        elseif    (item.type == L.BAG_GEM)                                    then cB_ItemClass[item.id] = "Gem"; return true
        elseif    (item.type == L.BAG_QUEST)                                    then cB_ItemClass[item.id] = "Quest"; return true
        elseif    (item.type == L.BAG_TRADES)                                    then cB_ItemClass[item.id] = "TradeGoods"; return true
        elseif    (item.type == L.BAG_CONSUMABLES)                            then cB_ItemClass[item.id] = "Consumables"; return true
        elseif    (item.type == L.BAG_ARTIFACT_POWER)                            then cB_ItemClass[item.id] = "ArtifactPower"; return true
        elseif    (item.type == L.BAG_BATTLEPET)                                then cB_ItemClass[item.id] = "BattlePet"; return true
        end
    end
    
    cB_ItemClass[item.id] = "NoClass"
end

------------------------------------------
-- New Items filter and related functions
------------------------------------------
cB_Filters.fNewItems = function(item)
    if not _G.SavedStats.cBnivCfg.NewItems then return false end
    if not ((item.bagId >= 0) and (item.bagId <= NumBagContainer)) then return false end
    if not item.link then return false end
    if not  _G.SavedStatsPerChar.cB_KnownItems[item.id] then return true end
    local t = GetItemCount(item.id)    --cbNivaya:getItemCount(item.id)
    return (t >  _G.SavedStatsPerChar.cB_KnownItems[item.id]) and true or false
end

-----------------------------------------
-- Item Set filter and related functions
-----------------------------------------
local item2setIR = {} -- ItemRack
local item2setOF = {} -- Outfitter
local IR = C_AddOns.IsAddOnLoaded('ItemRack')
local OF = C_AddOns.IsAddOnLoaded('Outfitter')

cB_Filters.fItemSets = function(item)
    --print("fItemSets", item, item.isInSet)
    if not cB_filterEnabled["ItemSets"] then return false end
    if not item.link then return false end
    local tC = cBniv_CatInfo[item.name]
    if tC then return (tC == "ItemSets") and true or false end
    -- Check ItemRack sets:
    if IR then
        if item2setIR[ItemRack.GetIRString(item.link)] then return true end
    end
    -- Check Outfitter sets:
    if OF then
        --local _,_,itemStr = string.find(item.link, "^|c%x+|H(.+)|h%[.*%]")
        --if item2setOF[itemStr] then return true end
        --if item2setOF[item.link] then return true end
        if OFisInitialized then
            if Outfitter:GetOutfitsUsingItem(Outfitter_GetItemInfoFromLink(item.link)) then return true end
        end
    end
    -- Check Equipment Manager sets:
    if cargBags.itemKeys["isItemSet"](item) then return true end
   return false
end

-- ItemRack related
local function cacheSetsIR()
    for k in pairs(item2setIR) do item2setIR[k] = nil end
    local IRsets = ItemRackUser.Sets
    for i in next, IRsets do
        if not string.find(i, "^~") then 
            for _,item in pairs(IRsets[i].equip) do
                if item then item2setIR[item] = true end
            end
        end
    end
    cbNivaya:UpdateBags()
end

if IR then
    local hooked = false
    cacheSetsIR()
    local function ItemRackOpt_CreateHooks()
        if hooked then return end
        --local IRsaveSet = ItemRackOpt.SaveSet
        --function ItemRackOpt.SaveSet(...) IRsaveSet(...); cacheSetsIR() end
        --local IRdeleteSet = ItemRackOpt.DeleteSet
        --function ItemRackOpt.DeleteSet(...) IRdeleteSet(...); cacheSetsIR() end
        hooksecurefunc(ItemRackOpt, "SaveSet", cacheSetsIR)
        hooksecurefunc(ItemRackOpt, "DeleteSet", cacheSetsIR)
        hooked = true
    end
    --local IRtoggleOpts = ItemRack.ToggleOptions
    --function ItemRack.ToggleOptions(...) IRtoggleOpts(...) ItemRackOpt_CreateHooks() end
    hooksecurefunc(ItemRack, "ToggleOptions", ItemRackOpt_CreateHooks)
end

-- Outfitter related
if OF then
    local function cacheSetsOF()
        cbNivaya:UpdateBags()
    end
    
    local function checkOFinit()
        OFisInitialized = Outfitter:IsInitialized()
    end
    
    Outfitter_RegisterOutfitEvent("ADD_OUTFIT", cacheSetsOF)
    Outfitter_RegisterOutfitEvent("DELETE_OUTFIT", cacheSetsOF)
    Outfitter_RegisterOutfitEvent("EDIT_OUTFIT", cacheSetsOF)
    if Outfitter:IsInitialized() then
        checkOFinit()
        cacheSetsOF()
    else
        Outfitter_RegisterOutfitEvent('OUTFITTER_INIT', function() checkOFinit() cacheSetsOF() end)
    end
end
