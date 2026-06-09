local E, C, L = select(2, ...):unpack()
local cargBags = select(2, ...).cargBags

------------------------------------------------------------------------
-- Bag Style
------------------------------------------------------------------------

local module = E:Module("Bags")
local cfg = C.bags

local CHAR_BANK_TYPE = Enum.BankType.Character or 0
local ACCOUNT_BANK_TYPE = Enum.BankType.Account or 2

local ipairs, unpack = ipairs, unpack
local strfind = string.find

local itemSlotSize = cfg.itemSlotSize or 32

local Textures = {
    Search = C.media.path .. "bag_search",
    BagToggle = C.media.path .. "bag_toggle",
    ResetNew = C.media.path .. "bag_reset",
    Restack = C.media.path .. "bag_restack",
    Deposit = C.media.path .. "bag_deposit",
}

local FONT_STANDARD = { STANDARD_TEXT_FONT, 12, "OUTLINE" }

------------------------------------------------------------------------
-- Container Class
------------------------------------------------------------------------

local cbNivaya = cargBags:GetImplementation("Nivaya")
local MyContainer = cbNivaya:GetContainerClass()

------------------------------------------------------------------------
-- Sort
------------------------------------------------------------------------

local QuickSort
do
    local func = function(v1, v2)
        if v1 == nil or v2 == nil then
            return v1 and true or false
        end
        if v1[1] == -1 or v2[1] == -1 then
            return v1[1] > v2[1]
        elseif v1[2] ~= v2[2] then
            if v1[2] and v2[2] then
                return v1[2] > v2[2]
            else
                return v1[2] and true or false
            end
        elseif v1[1] ~= v2[1] then
            return v1[1] > v2[1]
        else
            return v1[4] > v2[4]
        end
    end
    QuickSort = function(tbl)
        table.sort(tbl, func)
    end
end

------------------------------------------------------------------------
-- Container Layout
------------------------------------------------------------------------

function MyContainer:OnContentsChanged()
    local col, row = 0, 0
    local yPosOffs = self.Caption and 24 or 4
    local isEmpty = true

    local tName = self.name
    local tBankBags = strfind(tName, "Bank")
    local tBank = tBankBags or (tName == "cBniv_Bank")
    local tReagent = (tName == "cBniv_BankReagent")
    local tAccount = (tName == "cBniv_BankAccount")

    local buttonIDs = {}
    for i, button in pairs(self.buttons) do
        local slotId, bagId = button:GetSlotAndBagID()
        local item = cbNivaya:GetItemInfo(bagId, slotId)
        if item.link then
            buttonIDs[i] = { item.id, item.quality, button, item.count }
        else
            buttonIDs[i] = { -1, -2, button, -1 }
        end
    end

    local opts = module.opts
    if (tBank or tReagent) and opts.SortBank or (not (tBank or tReagent) and opts.SortBags) then
        QuickSort(buttonIDs)
    end

    for _, v in ipairs(buttonIDs) do
        local button = v[3]
        button:ClearAllPoints()

        local xPos = col * (itemSlotSize + 2) + 4
        local yPos = (-1 * row * (itemSlotSize + 2)) - yPosOffs

        button:SetPoint("TOPLEFT", self, "TOPLEFT", xPos, yPos)
        if col >= self.Columns - 1 then
            col = 0
            row = row + 1
        else
            col = col + 1
        end
        isEmpty = false
    end

    if opts.CompressEmpty then
        local xPos = col * (itemSlotSize + 2) + 2
        local yPos = (-1 * row * (itemSlotSize + 2)) - yPosOffs

        local tDrop = self.DropTarget
        if tDrop then
            tDrop:ClearAllPoints()
            tDrop:SetPoint("TOPLEFT", self, "TOPLEFT", xPos, yPos)
            if col >= self.Columns - 1 then
                col = 0
                row = row + 1
            else
                col = col + 1
            end
        end
    end

    self.ContainerHeight = (row + (col > 0 and 1 or 0)) * (itemSlotSize + 2)

    if self.UpdateDimensions then
        self:UpdateDimensions()
    end
    self:SetWidth((itemSlotSize + 2) * self.Columns + 2)

    local t = (tName == "cBniv_Bag") or (tName == "cBniv_Bank") or (tName == "cBniv_BankReagent") or (tName == "cBniv_BankAccount")
    local bags = module.bags
    if not bags or not bags.bank or not bags.main then
        return
    end
    local bankShown = bags.bank:IsShown()

    if (not tBankBags and bags.main:IsShown() and not t) or (tBankBags and bankShown) then
        if isEmpty then
            self:Hide()
            if bankShown then
                bags.bank:Show()
                bags.bankReagent:Show()
                bags.bankAccount:Show()
            end
        else
            self:Show()
        end
    end

    module.bagHidden[tName] = (not t) and isEmpty or false
    cbNivaya:UpdateAnchors(self)
end

------------------------------------------------------------------------
-- Buttons
------------------------------------------------------------------------

local function restackItems(self)
    local tBag = (self.name == "cBniv_Bag")
    local tBank = (self.name == "cBniv_Bank")
    if tBank then
        C_Container.SortBankBags()
    elseif tBag then
        C_Container.SortBags()
    end
end

local function resetNewItems()
    module:ResetNewItems()
end

local function UpdateDimensions(self)
    local height = 0
    if self.BagBar and self.BagBar:IsShown() then
        height = height + 40
    end
    if self.Space then
        height = height + 16
    end
    if self.bagToggle then
        height = height + 24
    end
    if self.Caption then
        height = height + self.Caption:GetStringHeight() + 16
    end
    self:SetHeight(self.ContainerHeight + height)
end

local function SetFrameMovable(f, v)
    f:SetMovable(true)
    f:SetUserPlaced(true)
    f:RegisterForDrag("LeftButton")
    if v then
        f:SetScript("OnDragStart", function()
            f:StartMoving()
        end)
        f:SetScript("OnDragStop", function()
            f:StopMovingOrSizing()
            local orig, _, tar, x, y = f:GetPoint()
            x = E:Round(x or 0)
            y = E:Round(y or 0)
            if f.name == "cBniv_Bag" then
                SavedStatsPerChar.cBniv.BagPos = { orig, "UIParent", tar, x, y }
            else
                SavedStatsPerChar.cBniv.BankPos = { orig, "UIParent", tar, x, y }
            end
        end)
    else
        f:SetScript("OnDragStart", nil)
        f:SetScript("OnDragStop", nil)
    end
end

------------------------------------------------------------------------
-- Icon Button Helpers
------------------------------------------------------------------------

local classColor
local function IconButton_OnEnter(self)
    self.mouseover = true
    if not classColor then
        classColor = { GetClassColor(select(2, UnitClass("player"))) }
    end
    self.icon:SetVertexColor(classColor[1], classColor[2], classColor[3])
    if self.tooltip then
        self.tooltip:Show()
    end
end

local function IconButton_OnLeave(self)
    self.mouseover = false
    self.icon:SetVertexColor(0.8, 0.8, 0.8)
    if self.tooltip then
        self.tooltip:Hide()
    end
end

local function createIconButton(name, parent, texture, point, hint, isBag)
    local button = CreateFrame("Button", nil, parent)
    button:SetWidth(24)
    button:SetHeight(24)
    button:SetNormalTexture(0)
    button:SetPushedTexture(0)
    button:SetHighlightTexture("Interface\\ChatFrame\\ChatFrameBackground")
    button:GetHighlightTexture():SetVertexColor(1, 1, 1, 0.25)
    button:GetHighlightTexture():SetInside()

    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetPoint(point, button, point, point == "BOTTOMLEFT" and 2 or -2, 2)
    button.icon:SetWidth(22)
    button.icon:SetHeight(22)
    button.icon:SetTexture(texture)
    button.icon:SetVertexColor(0.8, 0.8, 0.8)

    button.tooltip = button:CreateFontString()
    button.tooltip:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", isBag and -76 or -59, 4.5)
    button.tooltip:SetFont(unpack(FONT_STANDARD))
    button.tooltip:SetJustifyH("RIGHT")
    button.tooltip:SetText(hint)
    button.tooltip:SetTextColor(0.8, 0.8, 0.8)
    button.tooltip:Hide()

    button.tag = name
    button:SetScript("OnEnter", function()
        IconButton_OnEnter(button)
    end)
    button:SetScript("OnLeave", function()
        IconButton_OnLeave(button)
    end)
    button.mouseover = false

    return button
end

------------------------------------------------------------------------
-- Free Slot Helper
------------------------------------------------------------------------

local function GetFirstFreeSlot(bagtype)
    local containerIDs
    if bagtype == "bag" then
        containerIDs = { 0, 1, 2, 3, 4 }
    elseif bagtype == "bankReagent" then
        containerIDs = { 5 }
    elseif bagtype == "bank" then
        containerIDs = { 6, 7, 8, 9, 10, 11 }
    elseif bagtype == "bankAccount" then
        containerIDs = { 12, 13, 14, 15, 16 }
    end
    if not containerIDs then
        return false
    end

    for _, i in next, containerIDs do
        local t = GetContainerNumFreeSlots(i)
        if t > 0 then
            local numSlots = GetContainerNumSlots(i)
            for j = 1, numSlots do
                if not GetContainerItemLink(i, j) then
                    return i, j
                end
            end
        end
    end
    return false
end

------------------------------------------------------------------------
-- Container OnCreate
------------------------------------------------------------------------

function MyContainer:OnCreate(name, settings)
    self.Settings = settings or {}
    self.name = name

    local tBag = name == "cBniv_Bag"
    local tBank = name == "cBniv_Bank"
    local tReagent = name == "cBniv_BankReagent"
    local tAccount = name == "cBniv_BankAccount"
    local tBankBags = strfind(name, "Bank")

    self:EnableMouse(true)
    self.UpdateDimensions = UpdateDimensions
    self:SetFrameStrata("HIGH")
    tinsert(UISpecialFrames, self:GetName())

    if tBag or tBank then
        SetFrameMovable(self, module.opts.Unlocked)
    end

    self.Columns = (tBankBags and cfg.columns.bank) or cfg.columns.bag
    self.ContainerHeight = 0
    self:UpdateDimensions()
    self:SetWidth((itemSlotSize + 2) * self.Columns + 2)

    -- Background
    local background = CreateFrame("Frame", nil, self)
    background:SetFrameStrata("HIGH")
    background:SetFrameLevel(1)
    background:SetPoint("TOPLEFT", -4, 4)
    background:SetPoint("BOTTOMRIGHT", 4, -4)
    E:ApplyBackdrop(background, false)

    -- Caption
    local caption = background:CreateFontString(nil, "OVERLAY", nil)
    caption:SetFont(unpack(FONT_STANDARD))
    local t = L["BAG_CAPTIONS_" .. self.name:upper():sub(7)] or (tBankBags and self.name:sub(5))
    if not t then
        t = self.name
    end
    caption:SetText(t)
    caption:SetPoint("TOPLEFT", 7.5, -7.5)
    self.Caption = caption

    if tBag or tBank then
        self.closeBtn = createIconButton("Close", self, "Interface\\RAIDFRAME\\ReadyCheck-NotReady", "BOTTOMRIGHT", "", tBag)
        self.closeBtn:SetSize(16, 16)
        self.closeBtn.icon:ClearAllPoints()
        self.closeBtn.icon:SetAllPoints()
        self.closeBtn:ClearAllPoints()
        self.closeBtn:SetPoint("TOPRIGHT", self, "TOPRIGHT", -2, -2)
        self.closeBtn:SetScript("OnClick", function()
            if cbNivaya:AtBank() then
                C_Bank.CloseBankFrame()
            else
                CloseAllBags()
            end
        end)
    end

    if tBag or tBank then
        local tS = tBag and "backpack+bags" or "bank"
        local tI = tBag and 5 or 7

        local bagButtons = self:SpawnPlugin("BagBar", tS)
        bagButtons:SetSize(bagButtons:LayoutButtons("grid", tI))
        bagButtons.highlightFunction = function(button, match)
            button:SetAlpha(match and 1 or 0.1)
        end
        bagButtons.isGlobal = true
        bagButtons:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, tBag and 32 or 20)
        bagButtons:Hide()
        self.BagBar = bagButtons

        self.bagToggle = createIconButton("Bags", self, Textures.BagToggle, "BOTTOMRIGHT", L.BAG_HINT_TOGGLE, tBag)
        self.bagToggle:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
        self.bagToggle:SetScript("OnClick", function()
            if self.BagBar:IsShown() then
                self.BagBar:Hide()
            else
                self.BagBar:Show()
            end
            self:UpdateDimensions()
        end)

        if tBag and module.opts.NewItems then
            self.resetBtn = createIconButton("ResetNew", self, Textures.ResetNew, "BOTTOMRIGHT", L.BAG_HINT_RESET_NEW, tBag)
            self.resetBtn:SetPoint("BOTTOMRIGHT", self.bagToggle, "BOTTOMLEFT", 0, 0)
            self.resetBtn:SetScript("OnClick", function()
                resetNewItems()
            end)
        end

        if module.opts.Restack then
            self.restackBtn = createIconButton("Restack", self, Textures.Restack, "BOTTOMRIGHT", L.BAG_HINT_RESTACK, tBag)
            if self.resetBtn then
                self.restackBtn:SetPoint("BOTTOMRIGHT", self.resetBtn, "BOTTOMLEFT", 0, 0)
            else
                self.restackBtn:SetPoint("BOTTOMRIGHT", self.bagToggle, "BOTTOMLEFT", 0, 0)
            end
            self.restackBtn:SetScript("OnClick", function()
                restackItems(self)
            end)
        end

        if tBank then
            self.reagentBtn = createIconButton("Deposit", self, Textures.Deposit, "BOTTOMRIGHT", REAGENTBANK_DEPOSIT, tBag)
            if self.restackBtn then
                self.reagentBtn:SetPoint("BOTTOMRIGHT", self.restackBtn, "BOTTOMLEFT", 0, 0)
            else
                self.reagentBtn:SetPoint("BOTTOMRIGHT", self.bagToggle, "BOTTOMLEFT", 0, 0)
            end
            self.reagentBtn:SetScript("OnClick", function()
                C_Bank.AutoDepositItemsIntoBank(CHAR_BANK_TYPE)
            end)
        end

        local btnTable = { self.bagToggle }
        if self.restackBtn then
            tinsert(btnTable, self.restackBtn)
        end
        if tBag and self.resetBtn then
            tinsert(btnTable, self.resetBtn)
        end
        if tBank and self.reagentBtn then
            tinsert(btnTable, self.reagentBtn)
        end
        local ttPos = -(#btnTable * 24 + 16)
        if tBank then
            ttPos = ttPos + 3
        end
        for _, v in pairs(btnTable) do
            v.tooltip:ClearAllPoints()
            v.tooltip:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", ttPos, 5.5)
        end
    end

    if tAccount then
        local bagWarband = self:SpawnPlugin("BagWarband", "accountbank")
        bagWarband:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 2)
        bagWarband:SetSize(bagWarband:LayoutButtons("grid", 5))
        bagWarband.highlightFunction = function(button, match)
            button:SetAlpha(match and 1 or 0.1)
        end
        self.BagBar = bagWarband

        self.depositBtn = createIconButton("SendAccount", self, Textures.Deposit, "BOTTOMRIGHT", ACCOUNT_BANK_DEPOSIT_BUTTON_LABEL, false)
        self.depositBtn:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
        self.depositBtn:SetScript("OnClick", function()
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
            C_Bank.AutoDepositItemsIntoBank(ACCOUNT_BANK_TYPE)
        end)
        self.depositBtn.tooltip:ClearAllPoints()
        self.depositBtn.tooltip:SetPoint("RIGHT", self.depositBtn, "LEFT", -5, 0)

        local checkbox = CreateFrame("CheckButton", nil, self, "InterfaceOptionsCheckButtonTemplate")
        checkbox:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 2, 2)
        checkbox:SetChecked(GetCVarBool("bankAutoDepositReagents"))
        checkbox:SetScript("OnClick", function(cb)
            SetCVar("bankAutoDepositReagents", cb:GetChecked())
        end)
        E:ReskinCheckBox(checkbox)

        checkbox.fs = checkbox:CreateFontText(14, "", false, "LEFT", 30, 0)
        checkbox.fs:SetText(L.BAG_HINT_ACOUNT_DEPOSIT_INCLUDE_REAGENTS)
    end

    -- Drop target
    if tBag or tBank or tReagent or tAccount then
        self.DropTarget = CreateFrame("ItemButton", self.name .. "DropTarget", self)
        local dtNT = _G[self.DropTarget:GetName() .. "NormalTexture"]
        if dtNT then
            dtNT:SetTexture(nil)
        end

        local function DropTargetProcessItem()
            local bID, sID = GetFirstFreeSlot((tBag and "bag") or (tBank and "bank") or (tReagent and "bankReagent") or (tAccount and "bankAccount") or false)
            if bID then
                PickupContainerItem(bID, sID)
            end
        end

        self.DropTarget:SetScript("OnMouseUp", DropTargetProcessItem)
        self.DropTarget:SetScript("OnReceiveDrag", DropTargetProcessItem)
        self.DropTarget:SetSize(itemSlotSize, itemSlotSize)

        self.DropTarget:CreateBackdrop()
        self.DropTarget.__backdrop:SetAllPoints()
        self.DropTarget.__backdrop:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            tile = false,
            tileSize = 16,
            edgeSize = 1,
        })
        self.DropTarget.__backdrop:SetBackdropColor(1, 1, 1, 0.1)
        self.DropTarget.__backdrop:SetBackdropBorderColor(0, 0, 0, 1)

        local freeSlot = self:SpawnPlugin("TagDisplay", "[space]", self.DropTarget)
        freeSlot.__type = (tBag and "Bag") or (tBank and "Bank") or (tReagent and "BankReagent") or (tAccount and "BankAccount")
        freeSlot:SetPoint("BOTTOMRIGHT", self.DropTarget, "BOTTOMRIGHT", 1.5, 1.5)
        freeSlot:SetFont(unpack(FONT_STANDARD))
        freeSlot:SetJustifyH("RIGHT")
        freeSlot:SetShadowColor(0, 0, 0, 0)
        self.NumFreeSlots = freeSlot

        if module.opts.CompressEmpty then
            self.DropTarget:Show()
        else
            self.DropTarget:Hide()
        end
    end

    if tBag then
        local infoFrame = CreateFrame("Button", nil, self)
        infoFrame:SetPoint("BOTTOMLEFT", 5, -6)
        infoFrame:SetPoint("BOTTOMRIGHT", -86, -6)
        infoFrame:SetHeight(32)

        local search = self:SpawnPlugin("SearchBar", infoFrame)
        search.isGlobal = true
        search.highlightFunction = function(button, match)
            button:SetAlpha(match and 1 or 0.1)
        end

        local searchIcon = background:CreateTexture(nil, "ARTWORK")
        searchIcon:SetTexture(Textures.Search)
        searchIcon:SetVertexColor(0.8, 0.8, 0.8)
        searchIcon:SetPoint("BOTTOMLEFT", infoFrame, "BOTTOMLEFT", -3, 8)
        searchIcon:SetWidth(16)
        searchIcon:SetHeight(16)

        local money = self:SpawnPlugin("TagDisplay", "[money]", self)
        money:SetPoint("TOPRIGHT", self, -32, -2)
        money:SetFont(unpack(FONT_STANDARD))
        money:SetJustifyH("RIGHT")
        money:SetShadowColor(0, 0, 0, 0)
    end

    self:SetScale(module.opts.scale)
    return self
end

------------------------------------------------------------------------
-- Bag Button (bag bar slots)
------------------------------------------------------------------------

local BagButton = cbNivaya:GetBagButtonClass()

function BagButton:OnCreate()
    self:SetNormalTexture(0)
    self:SetPushedTexture(0)
    self:SetHighlightTexture("Interface\\ChatFrame\\ChatFrameBackground")
    self:GetHighlightTexture():SetVertexColor(1, 1, 1, 0.25)
    self:GetHighlightTexture():SetInside()

    self:SetSize(itemSlotSize, itemSlotSize)
    self:CreateBackdrop()
    self.__backdrop:SetBackdropColor(0.3, 0.3, 0.3, 0.3)
    self.Icon:SetInside()
    self.Icon:SetTexCoord(unpack(C.media.texCoord))
end

function BagButton:OnUpdateButton()
    self.__backdrop:SetBackdropBorderColor(0, 0, 0)

    local id = GetInventoryItemID("player", (self.GetInventorySlot and self:GetInventorySlot()) or self.invID)
    if not id then
        return
    end
    local _, _, quality = C_Item.GetItemInfo(id)
    if not quality or quality <= 1 then
        return
    end
    local color = C.media.qualityColors[quality]
    if not self.hidden and not self.notBought and color then
        self.__backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
    end
end

------------------------------------------------------------------------
-- Item Button
------------------------------------------------------------------------

local MyButton = cbNivaya:GetItemButtonClass()
MyButton:Scaffold("Default")

function MyButton:OnAdd()
    self:SetScript("OnMouseUp", function(btn, mouseButton)
        if mouseButton == "RightButton" then
            local slotId, bagId = btn:GetSlotAndBagID()
            local tID = C_Container.GetContainerItemID(bagId, slotId)
            if not tID then
                return
            end
            if IsControlKeyDown() and cbNivaya:AtBank() then
                C_Container.UseContainerItem(bagId, slotId, nil, true)
            end
        end
    end)
end

function MyButton:OnCreate()
    self:SetNormalTexture(0)
    self:SetPushedTexture(0)
    self:SetHighlightTexture("Interface\\ChatFrame\\ChatFrameBackground")
    self:GetHighlightTexture():SetVertexColor(1, 1, 1, 0.25)
    self:GetHighlightTexture():SetInside()
    self:SetSize(itemSlotSize - 4, itemSlotSize - 4)
    self:CreateBackdrop()

    self.__backdrop:SetOutside()
    self.__backdrop:SetBackdropColor(0.3, 0.3, 0.3, 0.3)

    self.Icon:SetInside()
    self.Icon:SetTexCoord(unpack(C.media.texCoord))

    self.Count:SetPoint("BOTTOMRIGHT", -1, 1)
    self.Count:SetFont(unpack(C.media.standard_font))

    self.Cooldown:SetInside()
    self.IconOverlay:SetInside()
    self.IconOverlay2:SetInside()

    local parentFrame = CreateFrame("Frame", nil, self)
    parentFrame:SetAllPoints()
    parentFrame:SetFrameLevel(5)

    self.QuestIcon = self:CreateTexture(nil, "ARTWORK")
    self.QuestIcon:SetTexture("Interface\\GossipFrame\\AvailableQuestIcon")
    self.QuestIcon:SetTexCoord(0, 1, 0, 1)
    self.QuestIcon:SetSize(14, itemSlotSize / 2)
    self.QuestIcon:SetPoint("TOPRIGHT", -1, -1)

    self.iLvl = self:CreateFontString(nil, "OVERLAY")
    self.iLvl:SetJustifyH("RIGHT")
    self.iLvl:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, 1)
    self.iLvl:SetFont(unpack(C.media.standard_font))

    self.durability = self:CreateFontString(nil, "OVERLAY")
    self.durability:SetJustifyH("LEFT")
    self.durability:SetPoint("TOPLEFT", self, "TOPLEFT", -1, 1)
    self.durability:SetFont(unpack(C.media.standard_font))

    if C_AddOns.IsAddOnLoaded("CanIMogIt") then
        self.canIMogIt = parentFrame:CreateTexture(nil, "OVERLAY")
        self.canIMogIt:SetSize(13, 13)
        self.canIMogIt:SetPoint(unpack(CanIMogIt.ICON_LOCATIONS[CanIMogItOptions["iconLocation"]]))
    end

    if not self.ProfessionQualityOverlay then
        self.ProfessionQualityOverlay = self:CreateTexture(nil, "OVERLAY")
        self.ProfessionQualityOverlay:SetPoint("TOPLEFT", -3, 2)
    end
end

------------------------------------------------------------------------
-- Item Level Helpers
------------------------------------------------------------------------

local iLvlClassIDs = {
    [Enum.ItemClass.Armor] = 0,
    [Enum.ItemClass.Weapon] = 0,
}

local function isItemHasLevel(item)
    local index = iLvlClassIDs[item.classID]
    return index and (index == 0 or index == item.subClassID)
end

local function isItemNeedsLevel(item)
    return item.link and item.quality and item.quality > 1 and isItemHasLevel(item)
end

local function getIconOverlayAtlas(item)
    if not item.link then
        return
    end
    if C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(item.link) then
        return "AzeriteIconFrame"
    elseif IsCosmeticItem(item.link) then
        return "CosmeticIconFrame"
    end
end

local function itemColorGradient(perc, ...)
    if perc >= 1 then
        return select(select("#", ...) - 2, ...)
    elseif perc <= 0 then
        return ...
    end
    local num = select("#", ...) / 3
    local segment, relperc = math.modf(perc * (num - 1))
    local r1, g1, b1, r2, g2, b2 = select((segment * 3) + 1, ...)
    return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
end

------------------------------------------------------------------------
-- Item Button Updates
------------------------------------------------------------------------

function MyButton:OnUpdateButton(item)
    self.IconOverlay:SetVertexColor(1, 1, 1)
    self.IconOverlay:Hide()
    self.IconOverlay2:Hide()

    local atlas = getIconOverlayAtlas(item)
    if atlas then
        self.IconOverlay:SetAtlas(atlas)
        self.IconOverlay:Show()
    end

    if self.ProfessionQualityOverlay then
        self.ProfessionQualityOverlay:SetAtlas(nil)
        SetItemCraftingQualityOverlay(self, item.link)
    end

    -- iLvl
    self.iLvl:SetText("")
    local level = item.level
    if level and isItemNeedsLevel(item) then
        local color = C.media.qualityColors[item.quality]
        self.iLvl:SetText(level)
        self.iLvl:SetTextColor(color.r, color.g, color.b)
    end

    -- Durability
    local dCur, dMax = GetContainerItemDurability(item.bagId, item.slotId)
    if dMax and dMax > 0 and dCur < dMax then
        local r, g, b = itemColorGradient(dCur / dMax, 1, 0, 0, 1, 1, 0, 0, 1, 0)
        self.durability:SetText(Round(dCur / dMax * 100) .. "%")
        self.durability:SetTextColor(r, g, b)
    else
        self.durability:SetText("")
    end

    self.__backdrop:SetBackdropColor(0.3, 0.3, 0.3, 0.3)

    if not item.texture and GameTooltip:GetOwner() == self then
        GameTooltip:Hide()
    end

    -- CanIMogIt support
    if self.canIMogIt then
        local text, unmodifiedText = CanIMogIt:GetTooltipText(nil, item.bagId, item.slotId)
        if text and text ~= "" then
            local icon = CanIMogIt.tooltipOverlayIcons[unmodifiedText]
            self.canIMogIt:SetTexture(icon)
            self.canIMogIt:Show()
        else
            self.canIMogIt:Hide()
        end
    end

    -- Pawn support
    if C_AddOns.IsAddOnLoaded("Pawn") and PawnIsContainerItemAnUpgrade and self.UpgradeIcon then
        self.UpgradeIcon:SetShown(PawnIsContainerItemAnUpgrade(item.bagId, item.slotId))
    end
end

function MyButton:OnUpdateQuest(item)
    if item.questID and not item.questActive then
        self.QuestIcon:Show()
    else
        self.QuestIcon:Hide()
    end

    if item.questID or item.isQuestItem then
        self.__backdrop:SetBackdropBorderColor(0.8, 0.8, 0)
    elseif item.quality and item.quality > -1 then
        local color = C.media.qualityColors[item.quality]
        self.__backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
    else
        self.__backdrop:SetBackdropBorderColor(0, 0, 0)
    end
end
