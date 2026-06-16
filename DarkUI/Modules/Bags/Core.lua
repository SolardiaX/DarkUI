local E, C, L, DB = select(2, ...):unpack()
local cargBags = select(2, ...).cargBags

------------------------------------------------------------------------
-- Bags Core
------------------------------------------------------------------------

local module = E:Module("Bags")
local cfg = C.bags

local ipairs = ipairs
local GetContainerNumSlots = C_Container.GetContainerNumSlots

------------------------------------------------------------------------
-- State
------------------------------------------------------------------------

module.ContainerGroups = { Bag = {}, Bank = {}, Account = {} }
module.customItems = nil
module.customNames = nil

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg or not cfg.enable then
        return
    end

    self:LoadDefaults()

    -- Create Implementation
    local Backpack = cargBags:NewImplementation("Nivaya")
    Backpack:RegisterBlizzard()
    Backpack:HookScript("OnShow", function()
        PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
    end)
    Backpack:HookScript("OnHide", function()
        PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
    end)

    self.Bags = Backpack

    -- Get classes and set them up
    local MyContainer, MyButton = self:GetClasses(Backpack)
    self:SetupContainerClass(MyContainer, Backpack)
    self:SetupItemButtonClass(MyButton)
    self:SetupBagButtonClass(Backpack)

    -- Get filters
    local filters = self:GetFilters()
    local f = {}
    self.frames = f

    -- Helper to create sub-containers
    local function addNewContainer(bagType, index, name, filter)
        local container = MyContainer:New(name, { BagType = bagType, Index = index })
        container:SetFilter(filter, true)
        self.ContainerGroups[bagType][index] = container
    end

    function Backpack:OnInit()
        -- Bag sub-containers
        for i = 1, 5 do
            addNewContainer("Bag", i, "BagCustom" .. i, filters["bagCustom" .. i])
        end
        addNewContainer("Bag", 6, "BagReagent", filters.onlyBagReagent)
        addNewContainer("Bag", 7, "AzeriteItem", filters.bagAzeriteItem)
        addNewContainer("Bag", 8, "Equipment", filters.bagEquipment)
        addNewContainer("Bag", 9, "EquipSet", filters.bagEquipSet)
        addNewContainer("Bag", 10, "BagAOE", filters.bagAOE)
        addNewContainer("Bag", 11, "BagCollection", filters.bagCollection)
        addNewContainer("Bag", 12, "BagDecor", filters.bagDecor)
        addNewContainer("Bag", 13, "BagGoods", filters.bagGoods)
        addNewContainer("Bag", 14, "BagAnima", filters.bagAnima)
        addNewContainer("Bag", 15, "BagStone", filters.bagStone)
        addNewContainer("Bag", 16, "Consumable", filters.bagConsumable)
        addNewContainer("Bag", 17, "BagQuest", filters.bagQuest)
        addNewContainer("Bag", 18, "BagLegacy", filters.bagLegacy)
        addNewContainer("Bag", 19, "BagLower", filters.bagLower)
        addNewContainer("Bag", 20, "Junk", filters.bagsJunk)

        -- Main bag panel
        f.main = MyContainer:New("Bag", { Bags = "bags", BagType = "Bag" })
        f.main:SetFilter(filters.onlyBags, true)
        f.main:SetPoint(unpack(module:GetSavedPosition("Bag", { "BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -50, 100 })))

        -- Bank sub-containers
        for i = 1, 5 do
            addNewContainer("Bank", i, "BankCustom" .. i, filters["bankCustom" .. i])
        end
        addNewContainer("Bank", 6, "BankAzeriteItem", filters.bankAzeriteItem)
        addNewContainer("Bank", 7, "BankEquipment", filters.bankEquipment)
        addNewContainer("Bank", 8, "BankEquipSet", filters.bankEquipSet)
        addNewContainer("Bank", 9, "BankAOE", filters.bankAOE)
        addNewContainer("Bank", 10, "BankCollection", filters.bankCollection)
        addNewContainer("Bank", 11, "BankDecor", filters.bankDecor)
        addNewContainer("Bank", 12, "BankGoods", filters.bankGoods)
        addNewContainer("Bank", 13, "BankAnima", filters.bankAnima)
        addNewContainer("Bank", 14, "BankConsumable", filters.bankConsumable)
        addNewContainer("Bank", 15, "BankQuest", filters.bankQuest)
        addNewContainer("Bank", 16, "BankLegacy", filters.bankLegacy)
        addNewContainer("Bank", 17, "BankLower", filters.bankLower)
        addNewContainer("Bank", 18, "BankJunk", filters.bankJunk)

        -- Main bank panel
        f.bank = MyContainer:New("Bank", { Bags = "bank", BagType = "Bank" })
        f.bank:SetFilter(filters.onlyBank, true)
        f.bank:SetPoint(unpack(module:GetSavedPosition("Bank", { "BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 25, 50 })))
        f.bank:Hide()

        -- Account bank sub-containers
        for i = 1, 5 do
            addNewContainer("Account", i, "AccountCustom" .. i, filters["accountCustom" .. i])
        end
        addNewContainer("Account", 6, "AccountEquipment", filters.accountEquipment)
        addNewContainer("Account", 7, "AccountAOE", filters.accountAOE)
        addNewContainer("Account", 8, "AccountGoods", filters.accountGoods)
        addNewContainer("Account", 9, "AccountConsumable", filters.accountConsumable)
        addNewContainer("Account", 10, "AccountLegacy", filters.accountLegacy)

        -- Main account bank panel
        f.accountbank = MyContainer:New("Account", { Bags = "accountbank", BagType = "Account" })
        f.accountbank:SetFilter(filters.accountBank, true)
        f.accountbank:SetPoint(unpack(module:GetSavedPosition("Bank", { "BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 25, 50 })))
        f.accountbank:Hide()

        -- Parent sub-containers to their main panel
        for bagType, groups in pairs(module.ContainerGroups) do
            for _, container in ipairs(groups) do
                local parent = Backpack.contByName[bagType]
                if parent then
                    container:SetParent(parent)
                end
            end
        end
    end

    function Backpack:OnOpen()
        f.main:Show()
    end

    function Backpack:OnClose()
        f.main:Hide()
    end

    function Backpack:OnBankOpened()
        BankFrame:Show()
        BankFrame.BankPanel:Show()
        f.bank:Show()

        -- Force update bank bags (bankType may not be set yet during first open)
        for id = 6, 11 do
            Backpack:UpdateBag(id)
        end
        for id = 12, 16 do
            Backpack:UpdateBag(id)
        end
    end

    function Backpack:OnBankClosed()
        BankFrame.BankPanel:Hide()
        f.bank:Hide()
        f.accountbank:Hide()
    end
end

------------------------------------------------------------------------
-- DB Helpers
------------------------------------------------------------------------

function module:LoadDefaults()
    if not DB:GetStats("cBniv_CustomItems") then
        DB:SetStats("cBniv_CustomItems", {})
    end
    if not DB:GetStats("cBniv_CustomNames") then
        DB:SetStats("cBniv_CustomNames", {})
    end
    if not DB:GetStats("cBniv_Positions", true) then
        DB:SetStats("cBniv_Positions", {}, true)
    end

    self.customItems = DB:GetStats("cBniv_CustomItems")
    self.customNames = DB:GetStats("cBniv_CustomNames")
    self.positions = DB:GetStats("cBniv_Positions", true)
end

function module:GetSavedPosition(name, default)
    local saved = self.positions and self.positions[name]
    return saved or default
end

------------------------------------------------------------------------
-- Anchor Layout
------------------------------------------------------------------------

local anchorCache = {}

local function checkReagentBag(name)
    return not (name == "BagReagent" and GetContainerNumSlots(5) == 0)
end

function module:UpdateBagsAnchor(parent, bags)
    wipe(anchorCache)

    local index = 1
    local perRow = cfg.bagsPerRow or 10
    anchorCache[index] = parent
    local topmost = nil

    for i = 1, #bags do
        local bag = bags[i]
        if bag and bag:GetHeight() > 45 and checkReagentBag(bag.name) then
            bag:Show()
            index = index + 1

            bag:ClearAllPoints()
            if (index - 1) % perRow == 0 then
                bag:SetPoint("BOTTOMRIGHT", anchorCache[index - perRow], "BOTTOMLEFT", -5, 0)
            else
                bag:SetPoint("BOTTOMLEFT", anchorCache[index - 1], "TOPLEFT", 0, 5)
            end
            anchorCache[index] = bag
            topmost = bag
        elseif bag then
            bag:Hide()
        end
    end

    -- Update unified background to cover topmost sub-container
    if parent.bgFrame then
        parent.bgFrame:ClearAllPoints()
        parent.bgFrame:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", -4, -4)
        parent.bgFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 4, -4)
        if topmost then
            parent.bgFrame:SetPoint("TOPLEFT", topmost, "TOPLEFT", -4, 4)
            parent.bgFrame:SetPoint("TOPRIGHT", topmost, "TOPRIGHT", 4, 4)
        else
            parent.bgFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", -4, 4)
            parent.bgFrame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 4, 4)
        end
    end
end

function module:UpdateBankAnchor(parent, bags)
    wipe(anchorCache)

    local index = 1
    local perRow = cfg.bankPerRow or 10
    anchorCache[index] = parent
    local topmost = nil

    for i = 1, #bags do
        local bag = bags[i]
        if bag and bag:GetHeight() > 45 then
            bag:Show()
            index = index + 1

            bag:ClearAllPoints()
            if index <= perRow then
                bag:SetPoint("BOTTOMLEFT", anchorCache[index - 1], "TOPLEFT", 0, 5)
            elseif index == perRow + 1 then
                bag:SetPoint("TOPLEFT", anchorCache[index - 1], "TOPRIGHT", 5, 0)
            elseif (index - 1) % perRow == 0 then
                bag:SetPoint("TOPLEFT", anchorCache[index - perRow], "TOPRIGHT", 5, 0)
            else
                bag:SetPoint("TOPLEFT", anchorCache[index - 1], "BOTTOMLEFT", 0, -5)
            end
            anchorCache[index] = bag
            topmost = bag
        elseif bag then
            bag:Hide()
        end
    end

    -- Update unified background
    if parent.bgFrame then
        parent.bgFrame:ClearAllPoints()
        parent.bgFrame:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", -4, -4)
        parent.bgFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 4, -4)
        if topmost then
            parent.bgFrame:SetPoint("TOPLEFT", topmost, "TOPLEFT", -4, 4)
            parent.bgFrame:SetPoint("TOPRIGHT", topmost, "TOPRIGHT", 4, 4)
        else
            parent.bgFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", -4, 4)
            parent.bgFrame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 4, 4)
        end
    end
end

function module:UpdateAllAnchors()
    local f = self.frames
    if not f then
        return
    end
    if f.main and f.main:IsShown() then
        self:UpdateBagsAnchor(f.main, self.ContainerGroups["Bag"])
    end
    if f.bank and f.bank:IsShown() then
        self:UpdateBankAnchor(f.bank, self.ContainerGroups["Bank"])
    end
    if f.accountbank and f.accountbank:IsShown() then
        self:UpdateBankAnchor(f.accountbank, self.ContainerGroups["Account"])
    end
end

function module:GetContainerColumns(bagType)
    if bagType == "Bag" then
        return cfg.bagsWidth
    elseif bagType == "Bank" then
        return cfg.bankWidth
    elseif bagType == "Account" then
        return cfg.accountWidth
    end
    return cfg.bagsWidth
end

------------------------------------------------------------------------
-- Utilities
------------------------------------------------------------------------

function module:UpdateAllBags()
    if self.Bags and self.Bags:IsShown() then
        for i = 0, 16 do
            self.Bags:UpdateBag(i)
        end
    end
end

function module:ResetNewItems()
    -- Trigger C_NewItems clear
    for bag = 0, 4 do
        local numSlots = GetContainerNumSlots(bag)
        for slot = 1, numSlots do
            C_NewItems.RemoveNewItem(bag, slot)
        end
    end
    self:UpdateAllBags()
end
