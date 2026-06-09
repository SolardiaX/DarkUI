local E, C, L = select(2, ...):unpack()
local cargBags = select(2, ...).cargBags

------------------------------------------------------------------------
-- Bags Core
------------------------------------------------------------------------

local module = E:Module("Bags")
local cfg = C.bags

local CHAR_BANK_TYPE = Enum.BankType.Character or 0
local ACCOUNT_BANK_TYPE = Enum.BankType.Account or 2

local GetContainerNumSlots = C_Container.GetContainerNumSlots
local GetContainerItemLink = C_Container.GetContainerItemLink

local cbNivaya = cargBags:GetImplementation("Nivaya")

------------------------------------------------------------------------
-- Options Defaults
------------------------------------------------------------------------

local optDefaults = {
    scale = 1,
    NewItems = true,
    Restack = true,
    TradeGoods = true,
    Armor = true,
    Gem = true,
    Junk = true,
    ItemSets = true,
    Consumables = true,
    Quest = true,
    FilterBank = true,
    CompressEmpty = true,
    Unlocked = true,
    SortBags = true,
    SortBank = true,
    BankCustomBags = true,
    BagPos = { "BOTTOMRIGHT", -99, 26 },
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

    self.filterEnabled.Armor = self.opts.Armor
    self.filterEnabled.Gem = self.opts.Gem
    self.filterEnabled.TradeGoods = self.opts.TradeGoods
    self.filterEnabled.Junk = self.opts.Junk
    self.filterEnabled.ItemSets = self.opts.ItemSets
    self.filterEnabled.Consumables = self.opts.Consumables
    self.filterEnabled.Quest = self.opts.Quest

    self:CreateContainers(cbNivaya)
    cbNivaya:CreateAnchors()
    cbNivaya:Init()

    self:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        self:OnEnterWorld()
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end)
end

function module:LoadDefaults()
    if not SavedStats then
        SavedStats = {}
    end
    if not SavedStatsPerChar then
        SavedStatsPerChar = {}
    end

    if not SavedStats.cBnivCfg then
        SavedStats.cBnivCfg = {}
    end
    if not SavedStats.cBniv_CatInfo then
        SavedStats.cBniv_CatInfo = {}
    end
    if not SavedStatsPerChar.cB_KnownItems then
        SavedStatsPerChar.cB_KnownItems = {}
    end
    if not SavedStatsPerChar.cBniv then
        SavedStatsPerChar.cBniv = { BagPos = optDefaults.BagPos, BankPos = optDefaults.BankPos }
    end

    for k, v in pairs(optDefaults) do
        if type(SavedStats.cBnivCfg[k]) == "nil" then
            SavedStats.cBnivCfg[k] = v
        end
    end

    self.opts = SavedStats.cBnivCfg
    self.knownItems = SavedStatsPerChar.cB_KnownItems
    self.charOpts = SavedStatsPerChar.cBniv
    self.catInfo = SavedStats.cBniv_CatInfo or {}
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
    bags.bankSets = CC:New("cBniv_BankSets")
    bags.bankArmor = CC:New("cBniv_BankArmor")
    bags.bankGem = CC:New("cBniv_BankGem")
    bags.bankConsumables = CC:New("cBniv_BankCons")
    bags.bankBattlePet = CC:New("cBniv_BankPet")
    bags.bankQuest = CC:New("cBniv_BankQuest")
    bags.bankTrade = CC:New("cBniv_BankTrade")
    bags.bankJunk = CC:New("cBniv_BankJunk")
    bags.bankAccount = CC:New("cBniv_BankAccount")
    bags.bankReagent = CC:New("cBniv_BankReagent")
    bags.bank = CC:New("cBniv_Bank")

    bags.bankSets:SetMultipleFilters(true, filters.fBank, filters.fBankFilter, filters.fItemSets)
    bags.bankArmor:SetExtendedFilter(filters.fItemClass, "BankArmor")
    bags.bankGem:SetExtendedFilter(filters.fItemClass, "BankGem")
    bags.bankConsumables:SetExtendedFilter(filters.fItemClass, "BankConsumables")
    bags.bankBattlePet:SetExtendedFilter(filters.fItemClass, "BankBattlePet")
    bags.bankQuest:SetExtendedFilter(filters.fItemClass, "BankQuest")
    bags.bankTrade:SetExtendedFilter(filters.fItemClass, "BankTradeGoods")
    bags.bankJunk:SetExtendedFilter(filters.fItemClass, "BankJunk")
    bags.bankReagent:SetMultipleFilters(true, filters.fBankReagent, filters.fHideEmpty)
    bags.bankAccount:SetMultipleFilters(true, filters.fBankAccount, filters.fHideEmpty)
    bags.bank:SetMultipleFilters(true, filters.fBank, filters.fHideEmpty)

    -- Inventory containers
    bags.bagItemSets = CC:New("cBniv_ItemSets")
    bags.bagStuff = CC:New("cBniv_Stuff")
    bags.bagJunk = CC:New("cBniv_Junk")
    bags.bagNew = CC:New("cBniv_NewItems")
    bags.armor = CC:New("cBniv_Armor")
    bags.gem = CC:New("cBniv_Gem")
    bags.quest = CC:New("cBniv_Quest")
    bags.consumables = CC:New("cBniv_Consumables")
    bags.battlepet = CC:New("cBniv_BattlePet")
    bags.tradegoods = CC:New("cBniv_TradeGoods")
    bags.main = CC:New("cBniv_Bag")

    bags.bagItemSets:SetFilter(filters.fItemSets, true)
    bags.bagStuff:SetExtendedFilter(filters.fItemClass, "Stuff")
    bags.bagJunk:SetExtendedFilter(filters.fItemClass, "Junk")
    bags.bagNew:SetFilter(filters.fNewItems, true)
    bags.armor:SetExtendedFilter(filters.fItemClass, "Armor")
    bags.gem:SetExtendedFilter(filters.fItemClass, "Gem")
    bags.quest:SetExtendedFilter(filters.fItemClass, "Quest")
    bags.consumables:SetExtendedFilter(filters.fItemClass, "Consumables")
    bags.battlepet:SetExtendedFilter(filters.fItemClass, "BattlePet")
    bags.tradegoods:SetExtendedFilter(filters.fItemClass, "TradeGoods")
    bags.main:SetMultipleFilters(true, filters.fBags, filters.fHideEmpty)

    bags.main:SetPoint(unpack(self.opts.BagPos))
    bags.bank:SetPoint(unpack(self.opts.BankPos))
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

    -- Bank anchors
    CreateAnchorInfo(bags.bank, bags.bankArmor, "Right")
    CreateAnchorInfo(bags.bankArmor, bags.bankSets, "Bottom")
    CreateAnchorInfo(bags.bankSets, bags.bankGem, "Bottom")
    CreateAnchorInfo(bags.bankGem, bags.bankTrade, "Bottom")
    CreateAnchorInfo(bags.bankTrade, bags.bankAccount, "Bottom")

    CreateAnchorInfo(bags.bank, bags.bankReagent, "Bottom")
    CreateAnchorInfo(bags.bankReagent, bags.bankConsumables, "Bottom")
    CreateAnchorInfo(bags.bankConsumables, bags.bankQuest, "Bottom")
    CreateAnchorInfo(bags.bankQuest, bags.bankBattlePet, "Bottom")
    CreateAnchorInfo(bags.bankBattlePet, bags.bankJunk, "Bottom")

    -- Bag anchors
    CreateAnchorInfo(bags.main, bags.bagItemSets, "Left")
    CreateAnchorInfo(bags.bagItemSets, bags.armor, "Top")
    CreateAnchorInfo(bags.armor, bags.gem, "Top")
    CreateAnchorInfo(bags.gem, bags.battlepet, "Top")
    CreateAnchorInfo(bags.battlepet, bags.bagStuff, "Top")
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
                v:SetPoint("BOTTOM", t, "TOP", 0, 12)
            elseif h and u == "Top" then
                v:SetPoint("BOTTOM", t, "BOTTOM")
            elseif not h and u == "Bottom" then
                v:SetPoint("TOP", t, "BOTTOM", 0, -14)
            elseif h and u == "Bottom" then
                v:SetPoint("TOP", t, "TOP")
            elseif u == "Left" then
                v:SetPoint("BOTTOMRIGHT", t, "BOTTOMLEFT", -12, 0)
            elseif u == "Right" then
                v:SetPoint("TOPLEFT", t, "TOPRIGHT", 12, 0)
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
        bags.armor,
        bags.bagNew,
        bags.bagItemSets,
        bags.gem,
        bags.quest,
        bags.consumables,
        bags.battlepet,
        bags.tradegoods,
        bags.bagStuff,
        bags.bagJunk
    )
end

function cbNivaya:OnClose()
    local bags = module.bags
    hideBags(
        bags.main,
        bags.armor,
        bags.bagNew,
        bags.bagItemSets,
        bags.gem,
        bags.quest,
        bags.consumables,
        bags.battlepet,
        bags.tradegoods,
        bags.bagStuff,
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
        bags.bankArmor,
        bags.bankGem,
        bags.bankQuest,
        bags.bankTrade,
        bags.bankConsumables,
        bags.bankBattlePet,
        bags.bankJunk,
        bags.bankAccount
    )
end

function cbNivaya:OnBankClosed()
    local bags = module.bags
    hideBags(
        bags.bank,
        bags.bankSets,
        bags.bankReagent,
        bags.bankArmor,
        bags.bankGem,
        bags.bankQuest,
        bags.bankTrade,
        bags.bankConsumables,
        bags.bankBattlePet,
        bags.bankJunk,
        bags.bankAccount
    )
    BankFrame.BankPanel:Hide()
end

------------------------------------------------------------------------
-- Enter World
------------------------------------------------------------------------

function module:OnEnterWorld()
    local buttonCollector = {}

    for bagId = 0, 16 do
        local slots = GetContainerNumSlots(bagId)
        for slotId = 1, slots do
            local button = cbNivaya.buttonClass:New(bagId, slotId)
            buttonCollector[#buttonCollector + 1] = button
            cbNivaya:SetButton(bagId, slotId, nil)
        end
    end

    for _, button in pairs(buttonCollector) do
        if button.container then
            button.container:RemoveButton(button)
        end
        button:Free()
    end

    cbNivaya:UpdateBags()
    self:ResetNewItems()
end

------------------------------------------------------------------------
-- Utilities
------------------------------------------------------------------------

function module:ResetNewItems()
    local knownItems = self.knownItems
    for bag = 0, 5 do
        local numSlots = GetContainerNumSlots(bag)
        for slot = 1, numSlots do
            local item = cbNivaya:GetItemInfo(bag, slot)
            if item.id then
                if knownItems[item.id] then
                    knownItems[item.id] = knownItems[item.id] + (item.count or 0)
                else
                    knownItems[item.id] = item.count or 1
                end
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
