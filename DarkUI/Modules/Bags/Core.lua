local E, C, L, DB = select(2, ...):unpack()
local cargBags = select(2, ...).cargBags

------------------------------------------------------------------------
-- Bags Core
------------------------------------------------------------------------

local module = E:Module("Bags")
local cfg = C.bags

local GetContainerNumSlots = C_Container.GetContainerNumSlots

local cbNivaya = cargBags:GetImplementation("Nivaya")

------------------------------------------------------------------------
-- Options Defaults
------------------------------------------------------------------------

local optDefaults = {
    scale = 1,
    NewItems = true,
    Restack = true,
    Equipment = true,
    Consumables = true,
    TradeGoods = true,
    Quest = true,
    Collection = true,
    Junk = true,
    ItemSets = false,
    AOE = true,
    Decor = true,
    Legacy = false,
    FilterBank = true,
    CompressEmpty = true,
    Unlocked = true,
    SortBags = true,
    SortBank = true,
    BankCustomBags = true,
    BagPos = { "RIGHT", -160, -160 },
    BankPos = { "TOPLEFT", 20, -20 },
}

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg or not cfg.enable then
        return
    end

    self:LoadDefaults()

    self.filterEnabled.Equipment = self.opts.Equipment
    self.filterEnabled.Consumables = self.opts.Consumables
    self.filterEnabled.TradeGoods = self.opts.TradeGoods
    self.filterEnabled.Quest = self.opts.Quest
    self.filterEnabled.Collection = self.opts.Collection
    self.filterEnabled.Junk = self.opts.Junk
    self.filterEnabled.ItemSets = self.opts.ItemSets
    self.filterEnabled.AOE = self.opts.AOE
    self.filterEnabled.Decor = self.opts.Decor
    self.filterEnabled.Legacy = self.opts.Legacy

    self:CreateContainers(cbNivaya)
    cbNivaya:CreateAnchors()
    cbNivaya:Init()

    -- Pre-populate knownItems so fNewItems doesn't catch everything on first open
    if not next(self.knownItems) then
        for bag = 0, 5 do
            local numSlots = GetContainerNumSlots(bag)
            for slot = 1, numSlots do
                local item = cbNivaya:GetItemInfo(bag, slot)
                if item.id then
                    self.knownItems[item.id] = (self.knownItems[item.id] or 0) + (item.count or 1)
                end
            end
        end
    end

    -- Delayed re-classify when item data arrives
    local updater = CreateFrame("Frame")
    updater:Hide()
    updater:SetScript("OnUpdate", function(self, elapsed)
        self.delay = self.delay - elapsed
        if self.delay < 0 then
            module:ResetItemClass()
            self:Hide()
        end
    end)

    local f = CreateFrame("Frame")
    f:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    f:SetScript("OnEvent", function()
        if cbNivaya:IsShown() then
            updater.delay = 1
            updater:Show()
        end
    end)
end

function module:LoadDefaults()
    if not DB:GetStats("cBnivCfg") then
        DB:SetStats("cBnivCfg", {})
    end
    if not DB:GetStats("cBniv_CatInfo") then
        DB:SetStats("cBniv_CatInfo", {})
    end
    if not DB:GetStats("cB_KnownItems", true) then
        DB:SetStats("cB_KnownItems", {}, true)
    end
    if not DB:GetStats("cBniv", true) then
        DB:SetStats("cBniv", { BagPos = optDefaults.BagPos, BankPos = optDefaults.BankPos }, true)
    end

    local opts = DB:GetStats("cBnivCfg")
    for k, v in pairs(optDefaults) do
        if type(opts[k]) == "nil" then
            opts[k] = v
        end
    end

    self.opts = opts
    self.knownItems = DB:GetStats("cB_KnownItems", true)
    self.charOpts = DB:GetStats("cBniv", true)
    self.catInfo = DB:GetStats("cBniv_CatInfo") or {}
end

------------------------------------------------------------------------
-- Container Creation
------------------------------------------------------------------------

function module:CreateContainers(cbNivaya)
    local CC = cbNivaya:GetContainerClass()
    local filters = self.filters
    local bags = {}
    self.bags = bags

    -- Bank containers
    bags.bankEquipment = CC:New("cBniv_BankEquipment")
    bags.bankSets = CC:New("cBniv_BankSets")
    bags.bankConsumables = CC:New("cBniv_BankCons")
    bags.bankQuest = CC:New("cBniv_BankQuest")
    bags.bankTrade = CC:New("cBniv_BankTrade")
    bags.bankCollection = CC:New("cBniv_BankCollection")
    bags.bankJunk = CC:New("cBniv_BankJunk")
    bags.bankAccount = CC:New("cBniv_BankAccount")
    bags.bankReagent = CC:New("cBniv_BankReagent")
    bags.bank = CC:New("cBniv_Bank")

    bags.bankEquipment:SetExtendedFilter(filters.fItemClass, "BankEquipment")
    bags.bankSets:SetMultipleFilters(true, filters.fBank, filters.fBankFilter, filters.fItemSets)
    bags.bankConsumables:SetExtendedFilter(filters.fItemClass, "BankConsumables")
    bags.bankQuest:SetExtendedFilter(filters.fItemClass, "BankQuest")
    bags.bankTrade:SetExtendedFilter(filters.fItemClass, "BankTradeGoods")
    bags.bankCollection:SetExtendedFilter(filters.fItemClass, "BankCollection")
    bags.bankJunk:SetExtendedFilter(filters.fItemClass, "BankJunk")
    bags.bankReagent:SetMultipleFilters(true, filters.fBankReagent, filters.fHideEmpty)
    bags.bankAccount:SetMultipleFilters(true, filters.fBankAccount, filters.fHideEmpty)
    bags.bank:SetMultipleFilters(true, filters.fBank, filters.fHideEmpty)

    -- Inventory containers
    bags.bagItemSets = CC:New("cBniv_ItemSets")
    bags.bagJunk = CC:New("cBniv_Junk")
    bags.bagNew = CC:New("cBniv_NewItems")
    bags.equipment = CC:New("cBniv_Equipment")
    bags.quest = CC:New("cBniv_Quest")
    bags.consumables = CC:New("cBniv_Consumables")
    bags.collection = CC:New("cBniv_Collection")
    bags.tradegoods = CC:New("cBniv_TradeGoods")
    bags.aoe = CC:New("cBniv_AOE")
    bags.decor = CC:New("cBniv_Decor")
    bags.legacy = CC:New("cBniv_Legacy")
    bags.main = CC:New("cBniv_Bag")

    bags.bagItemSets:SetFilter(filters.fItemSets, true)
    bags.bagJunk:SetExtendedFilter(filters.fItemClass, "Junk")
    bags.bagNew:SetFilter(filters.fNewItems, true)
    bags.equipment:SetExtendedFilter(filters.fItemClass, "Equipment")
    bags.quest:SetExtendedFilter(filters.fItemClass, "Quest")
    bags.consumables:SetExtendedFilter(filters.fItemClass, "Consumables")
    bags.collection:SetExtendedFilter(filters.fItemClass, "Collection")
    bags.tradegoods:SetExtendedFilter(filters.fItemClass, "TradeGoods")
    bags.aoe:SetExtendedFilter(filters.fItemClass, "AOE")
    bags.decor:SetExtendedFilter(filters.fItemClass, "Decor")
    bags.legacy:SetExtendedFilter(filters.fItemClass, "Legacy")
    bags.main:SetMultipleFilters(true, filters.fBags, filters.fHideEmpty)

    bags.main:SetPoint(unpack(self.charOpts.BagPos or self.opts.BagPos))
    bags.bank:SetPoint(unpack(self.charOpts.BankPos or self.opts.BankPos))

    -- All containers default hidden (shown by OnOpen / OnBankOpened)
    for _, bag in pairs(bags) do
        bag:Hide()
    end
end

------------------------------------------------------------------------
-- Anchors
------------------------------------------------------------------------

function cbNivaya:CreateAnchors()
    local bags = module.bags

    local function CreateAnchorInfo(src, tar, dir)
        tar.AnchorTo = src
        tar.AnchorDir = dir
        if src then
            if not src.AnchorTargets then
                src.AnchorTargets = {}
            end
            src.AnchorTargets[tar] = true
        end
    end

    for _, v in pairs(bags) do
        if v.name ~= "cBniv_Bag" and v.name ~= "cBniv_Bank" then
            v:ClearAllPoints()
        end
        v.AnchorTo = nil
        v.AnchorDir = nil
        v.AnchorTargets = nil
    end

    -- Main anchors
    CreateAnchorInfo(nil, bags.main, "Bottom")
    CreateAnchorInfo(nil, bags.bank, "Bottom")

    -- Bank left column
    CreateAnchorInfo(bags.bank, bags.bankReagent, "Bottom")
    CreateAnchorInfo(bags.bankReagent, bags.bankConsumables, "Bottom")
    CreateAnchorInfo(bags.bankConsumables, bags.bankTrade, "Bottom")
    CreateAnchorInfo(bags.bankTrade, bags.bankQuest, "Bottom")

    -- Bank middle column
    CreateAnchorInfo(bags.bank, bags.bankEquipment, "Right")
    CreateAnchorInfo(bags.bankEquipment, bags.bankSets, "Bottom")
    CreateAnchorInfo(bags.bankSets, bags.bankCollection, "Bottom")
    CreateAnchorInfo(bags.bankCollection, bags.bankJunk, "Bottom")

    -- Bank right (Account independent)
    CreateAnchorInfo(bags.bankEquipment, bags.bankAccount, "Right")

    -- Bag anchors
    CreateAnchorInfo(bags.main, bags.bagItemSets, "Left")
    CreateAnchorInfo(bags.bagItemSets, bags.equipment, "Top")
    CreateAnchorInfo(bags.equipment, bags.collection, "Top")
    CreateAnchorInfo(bags.collection, bags.aoe, "Top")
    CreateAnchorInfo(bags.aoe, bags.decor, "Top")
    CreateAnchorInfo(bags.decor, bags.legacy, "Top")

    CreateAnchorInfo(bags.main, bags.tradegoods, "Top")
    CreateAnchorInfo(bags.tradegoods, bags.consumables, "Top")
    CreateAnchorInfo(bags.consumables, bags.quest, "Top")
    CreateAnchorInfo(bags.quest, bags.bagJunk, "Top")
    CreateAnchorInfo(bags.bagJunk, bags.bagNew, "Top")

    for _, v in pairs(bags) do
        cbNivaya:UpdateAnchors(v)
    end
end

module.bagHidden = {}

function cbNivaya:UpdateAnchors(src)
    if not src.AnchorTargets then
        return
    end
    for v in pairs(src.AnchorTargets) do
        local t, u = v.AnchorTo, v.AnchorDir
        if t then
            local h = module.bagHidden[t.name]
            v:ClearAllPoints()

            if not h and u == "Top" then
                v:SetPoint("BOTTOM", t, "TOP", 0, 18)
            elseif h and u == "Top" then
                v:SetPoint("BOTTOM", t, "BOTTOM")
            elseif not h and u == "Bottom" then
                v:SetPoint("TOP", t, "BOTTOM", 0, -18)
            elseif h and u == "Bottom" then
                v:SetPoint("TOP", t, "TOP")
            elseif u == "Left" then
                v:SetPoint("BOTTOMRIGHT", t, "BOTTOMLEFT", -18, 0)
            elseif u == "Right" then
                v:SetPoint("TOPLEFT", t, "TOPRIGHT", 18, 0)
            end
        end
    end
end

------------------------------------------------------------------------
-- Show / Hide
------------------------------------------------------------------------

local function showBags(impl, ...)
    for i = 1, select("#", ...) do
        local bag = select(i, ...)
        if not module.bagHidden[bag.name] then
            bag:Show()
        end
    end
end

local function hideBags(...)
    for i = 1, select("#", ...) do
        select(i, ...):Hide()
    end
end

function cbNivaya:OnOpen()
    local bags = module.bags
    bags.main:Show()
    showBags(
        self,
        bags.equipment,
        bags.bagNew,
        bags.bagItemSets,
        bags.collection,
        bags.quest,
        bags.consumables,
        bags.tradegoods,
        bags.aoe,
        bags.decor,
        bags.legacy,
        bags.bagJunk
    )
end

function cbNivaya:OnClose()
    local bags = module.bags
    hideBags(
        bags.main,
        bags.equipment,
        bags.bagNew,
        bags.bagItemSets,
        bags.collection,
        bags.quest,
        bags.consumables,
        bags.tradegoods,
        bags.aoe,
        bags.decor,
        bags.legacy,
        bags.bagJunk
    )
end

function cbNivaya:OnBankOpened()
    BankFrame:Show()
    BankFrame.BankPanel:Show()

    local bags = module.bags
    bags.bank:Show()
    showBags(
        self,
        bags.bankSets,
        bags.bankReagent,
        bags.bankEquipment,
        bags.bankQuest,
        bags.bankTrade,
        bags.bankConsumables,
        bags.bankCollection,
        bags.bankJunk,
        bags.bankAccount
    )

    for id = 5, 16 do
        self:UpdateBag(id)
    end
end

function cbNivaya:OnBankClosed()
    local bags = module.bags
    hideBags(
        bags.bank,
        bags.bankSets,
        bags.bankReagent,
        bags.bankEquipment,
        bags.bankQuest,
        bags.bankTrade,
        bags.bankConsumables,
        bags.bankCollection,
        bags.bankJunk,
        bags.bankAccount
    )
    BankFrame.BankPanel:Hide()
end

------------------------------------------------------------------------
-- Utilities
------------------------------------------------------------------------

function module:ResetNewItems()
    local knownItems = self.knownItems
    wipe(knownItems)

    for bag = 0, 5 do
        local numSlots = GetContainerNumSlots(bag)
        for slot = 1, numSlots do
            local item = cbNivaya:GetItemInfo(bag, slot)
            if item.id then
                knownItems[item.id] = (knownItems[item.id] or 0) + (item.count or 1)
            end
        end
    end
    cbNivaya:UpdateBags()
end

function module:ResetItemClass()
    for k, v in pairs(self.itemClass) do
        if v == "NoClass" then
            self.itemClass[k] = nil
        end
    end
    cbNivaya:UpdateBags()
end
