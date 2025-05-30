local _, ns = ...
local E, C, L = ns:unpack()
local cargBags = ns.cargBags

if not C.bags.enable then return end

----------------------------------------------------------------------------------------
--    Style of Bags (modified from cargBags_Nivaya of RealUI)
----------------------------------------------------------------------------------------

local NumBagContainer = 5
local BankContainerStartID = NumBagContainer + 1
local MaxNumContainer = 12

local LE_ITEM_CLASS_KEY = LE_ITEM_CLASS_KEY or Enum.ItemClass.Key
local UseContainerItem = C_Container and C_Container.UseContainerItem or UseContainerItem
local C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID = C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID
local C_Soulbinds_IsItemConduitByItemInfo = C_Soulbinds.IsItemConduitByItemInfo
local IsControlKeyDown, IsAltKeyDown, IsShiftKeyDown = IsControlKeyDown, IsAltKeyDown, IsShiftKeyDown

local GetContainerItemID = C_Container.GetContainerItemID
local GetContainerNumSlots = C_Container.GetContainerNumSlots
local GetContainerNumFreeSlots = C_Container.GetContainerNumFreeSlots
local GetContainerItemDurability = C_Container.GetContainerItemDurability
local GetContainerItemLink = C_Container.GetContainerItemLink
local SortBags = C_Container.SortBags
local SortBankBags = C_Container.SortBankBags
local SortReagentBankBags = C_Container.SortReagentBankBags
local PickupContainerItem = C_Container.PickupContainerItem

-- Lua Globals --
local _G = _G
local next, ipairs = _G.next, _G.ipairs

local Textures = {
    Search         = C.media.path .. "bag_search",
    BagToggle      = C.media.path .. "bag_toggle",
    ResetNew       = C.media.path .. "bag_reset",
    Restack        = C.media.path .. "bag_restack",
    Deposit        = C.media.path .. "bag_deposit",
}

local cfg = C.bags
local itemSlotSize = cfg.itemSlotSize

cfg.fonts = {
    -- Font to use for bag captions and other strings
    standard = {
        _G.STANDARD_TEXT_FONT, -- Font path
        12, -- Font Size
        "OUTLINE", -- Flags
    }
}
------------------------------------------
-- MyContainer specific
------------------------------------------
local cbNivaya = cargBags:GetImplementation("Nivaya")
local MyContainer = cbNivaya:GetContainerClass()

local function GetClassColor(class)
    if not RAID_CLASS_COLORS[class] then return {1, 1, 1} end
    local classColors = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
    return {classColors.r, classColors.g, classColors.b}
end

local QuickSort;
do
    local func = function(v1, v2)
        if (v1 == nil) or (v2 == nil) then return (v1 and true or false) end
        if v1[1] == -1 or v2[1] == -1 then
            return v1[1] > v2[1] -- empty slots last
        elseif v1[2] ~= v2[2] then
            if v1[2] and v2[2] then
                return v1[2] > v2[2] -- higher quality first
            elseif (v1[2] == nil) or (v2[2] == nil) then
                return (v1[2] and true or false)
            else
                return false
            end
        elseif v1[1] ~= v2[1] then
            return v1[1] > v2[1] -- group identical item ids
            else


            return v1[4] > v2[4] -- full/larger stacks first
        end
    end;
    QuickSort = function(tbl) table.sort(tbl, func) end
end

local BagFrames, BankFrames =  {}, {}
function MyContainer:OnContentsChanged(forced)
    local col, row = 0, 0
    local yPosOffs = self.Caption and 24 or 4
    local isEmpty = true

    local tName = self.name
    local tBankBags = string.find(tName, "Bank")
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

    if ((tBank or tReagent) and _G.SavedStats.cBnivCfg.SortBank) 
        or (not (tBank or tReagent) and _G.SavedStats.cBnivCfg.SortBags) then 
        QuickSort(buttonIDs) 
    end

    for _, v in ipairs(buttonIDs) do
        local button = v[3]
        button:ClearAllPoints()

        local xPos = col * (itemSlotSize + 2) + 4
        local yPos = (-1 * row * (itemSlotSize + 2)) - yPosOffs

        button:SetPoint("TOPLEFT", self, "TOPLEFT", xPos, yPos)
        if(col >= self.Columns-1) then
            col = 0
            row = row + 1
        else
            col = col + 1
        end
        isEmpty = false
    end

    if _G.SavedStats.cBnivCfg.CompressEmpty then
        local xPos = col * (itemSlotSize + 2) + 2
        local yPos = (-1 * row * (itemSlotSize + 2)) - yPosOffs

        local tDrop = self.DropTarget
        if tDrop then
            tDrop:ClearAllPoints()
            tDrop:SetPoint("TOPLEFT", self, "TOPLEFT", xPos, yPos)
            if col >= (self.Columns - 1) then
                col = 0
                row = row + 1
            else
                col = col + 1
            end
        end
    end

    -- This variable stores the size of the item button container
    self.ContainerHeight = (row + (col > 0 and 1 or 0)) * (itemSlotSize + 2)

    if (self.UpdateDimensions) then self:UpdateDimensions() end -- Update the bag's height
    self:SetWidth((itemSlotSize + 2) * self.Columns + 2)
    local t = (tName == "cBniv_Bag") or (tName == "cBniv_Bank") or (tName == "cBniv_BankReagent") or (tName == "cBniv_Keyring") or (tName == "cBniv_BankAccount")
    local tAS = (tName == "cBniv_Ammo") or (tName == "cBniv_Soulshards")
    local bankShown = cB_Bags.bank:IsShown()
    if (not tBankBags and cB_Bags.main:IsShown() and not (t or tAS)) or (tBankBags and bankShown) then 
        if isEmpty then
            self:Hide()
            if bankShown then
                cB_Bags.bank:Show()
                cB_Bags.bankReagent:Show()
                cB_Bags.bankAccount:Show()
            end
        else
            self:Show()
        end 
    end

    cB_BagHidden[tName] = (not t) and isEmpty or false
    cbNivaya:UpdateAnchors(self)
end

-- Restack Items
local function restackItems(self)
    local tBag, tBank = (self.name == "cBniv_Bag"), (self.name == "cBniv_Bank")
    --local loc = tBank and "bank" or "bags"
    if tBank then
        SortBankBags()

        if _G.IsReagentBankUnlocked() then
            -- SortReagentBankBags()
            EventUtil.RegisterOnceFrameEventAndCallback('ITEM_UNLOCKED', function()
                C_Timer.After(0, function()
                    SortReagentBankBags()
                end)
            end)
        end
    elseif tBag then
        SortBags()
    end
end

-- Reset New
local resetNewItems = function(self)
    local cB_KnownItems = _G.SavedStatsPerChar.cB_KnownItems or {}
    if not _G.SavedStatsPerChar.cBniv.clean then
        for item, numItem in next, cB_KnownItems do
            if type(item) == "string" then
                cB_KnownItems[item] = nil
            end
        end
        _G.SavedStatsPerChar.cBniv.clean = true
    end
    for bag = 0, NumBagContainer do
        local tNumSlots = GetContainerNumSlots(bag)
        if tNumSlots > 0 then
            for slot = 1, tNumSlots do
                local item = cbNivaya:GetItemInfo(bag, slot)
                if item.id then
                    if cB_KnownItems[item.id] then
                        cB_KnownItems[item.id] = cB_KnownItems[item.id] + (item.count and item.count or 0)
                    else
                        cB_KnownItems[item.id] = item.count and item.count or 1
                    end
                end
            end 
        end
    end
    _G.SavedStatsPerChar.cB_KnownItems = cB_KnownItems
    cbNivaya:UpdateBags()
end
function cbNivResetNew()
    resetNewItems()
end

local UpdateDimensions = function(self)
    local height = 0            -- Normal margin space
    if (self.BagBar and self.BagBar:IsShown()) then
        height = height + 40    -- Bag button space
    end
    if self.Space then
        height = height + 16    -- additional info display space
    end
    if self.bagToggle then
        local tBag = (self.name == "cBniv_Bag")
        local extraHeight = (tBag and self.hintShown) and (self.hint:GetStringHeight() + 4) or 0
        height = height + 24 + extraHeight
    end
    if self.Caption then
        -- Space for captions
        height = height + self.Caption:GetStringHeight() + 16
    end

    self:SetHeight(self.ContainerHeight + height)
end

local SetFrameMovable = function(f, v)
    f:SetMovable(true)
    f:SetUserPlaced(true)
    f:RegisterForClicks("LeftButtonDown", "LeftButtonUp", "RightButtonDown", "RightButtonUp")
    if v then
        f:SetScript("OnMouseDown", function()
            f:ClearAllPoints()
            f:StartMoving()
        end)
        f:SetScript("OnMouseUp", function()
            f:StopMovingOrSizing()
            local orig, _, tar, x, y = f:GetPoint()
            x = E:Round(x)
            y = E:Round(y)

            if f.name == "cBniv_Bag" then
                _G.SavedStatsPerChar.cBniv.BagPos = {orig, "UIParent", tar, x, y}
            else
                _G.SavedStatsPerChar.cBniv.BankPos = {orig, "UIParent", tar, x, y}
            end            
        end)
    else
        f:SetScript("OnMouseDown", nil)
        f:SetScript("OnMouseUp", nil)
    end
end

local classColor
local function IconButton_OnEnter(self)
    self.mouseover = true
    
    if not classColor then
        classColor = GetClassColor(select(2, UnitClass("player")))
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

local createMoverButton = function(parent, texture, tag)
    local button = _G.CreateFrame("Button", nil, parent)
    button:SetWidth(17)
    button:SetHeight(17)

    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetPoint("TOPRIGHT", button, "TOPRIGHT", -1, -1)
    button.icon:SetWidth(16)
    button.icon:SetHeight(16)
    button.icon:SetTexture(texture)
    button.icon:SetVertexColor(0.8, 0.8, 0.8)

    button.tag = tag
    button:SetScript("OnEnter", function() IconButton_OnEnter(button) end)
    button:SetScript("OnLeave", function() IconButton_OnLeave(button) end)
    button.mouseover = false

    return button
end

local createIconButton = function(name, parent, texture, point, hint, isBag)
    local button = _G.CreateFrame("Button", nil, parent)
    button:SetWidth(24)
    button:SetHeight(24)
    button:SetNormalTexture(0)
    button:SetPushedTexture(0)
    button:SetHighlightTexture("Interface\\ChatFrame\\ChatFrameBackground")
    button:GetHighlightTexture():SetVertexColor(1, 1, 1, .25)
    button:GetHighlightTexture():SetInside()

    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetPoint(point, button, point, point == "BOTTOMLEFT" and 2 or -2, 2)
    button.icon:SetWidth(22)
    button.icon:SetHeight(22)
    button.icon:SetTexture(texture)
    button.icon:SetVertexColor(0.8, 0.8, 0.8)

    button.tooltip = button:CreateFontString()
    button.tooltip:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", isBag and -76 or -59, 4.5)
    button.tooltip:SetFont(_G.unpack(cfg.fonts.standard))
    button.tooltip:SetJustifyH("RIGHT")
    button.tooltip:SetText(hint)
    button.tooltip:SetTextColor(0.8, 0.8, 0.8)
    button.tooltip:Hide()

    button.tag = name
    button:SetScript("OnEnter", function() IconButton_OnEnter(button) end)
    button:SetScript("OnLeave", function() IconButton_OnLeave(button) end)
    button.mouseover = false

    return button
end

local GetFirstFreeSlot = function(bagtype)
    if bagtype == "bag" then
        for i = 0, 4 do
            local t = GetContainerNumFreeSlots(i)
            if t > 0 then
                local tNumSlots = GetContainerNumSlots(i)
                for j = 1,tNumSlots do
                    local tLink = GetContainerItemLink(i,j)
                    if not tLink then return i,j end
                end
            end
        end
    elseif bagtype == "bankReagent" then
        local bagId = -3
        local t = GetContainerNumFreeSlots(bagId)
        if t > 0 then
            local tNumSlots = GetContainerNumSlots(bagId)
            for j = 1,tNumSlots do
                local tLink = GetContainerItemLink(bagId,j)
                if not tLink then return bagId,j end
            end
        end
    elseif bagtype == "bank" then
        local containerIDs = {-1,6,7,8,9,10,11,12}
        for _,i in next, containerIDs do
            local t = GetContainerNumFreeSlots(i)
            if t > 0 then
                local tNumSlots = GetContainerNumSlots(i)
                for j = 1,tNumSlots do
                    local tLink = GetContainerItemLink(i,j)
                    if not tLink then return i,j end
                end
            end
        end
    elseif bagtype == "bankAccount" then
        local containerIDs = {13,14,15,16,17}
        for _,i in next, containerIDs do
            local t = GetContainerNumFreeSlots(i)
            if t > 0 then
                local tNumSlots = GetContainerNumSlots(i)
                for j = 1,tNumSlots do
                    local tLink = GetContainerItemLink(i,j)
                    if not tLink then return i,j end
                end
            end
        end
    end
    return false
end

function MyContainer:OnCreate(name, settings)
    self.Settings = settings or {}
    self.name = name

    local tBag = name == "cBniv_Bag"
    local tBank = name == "cBniv_Bank"
    local tReagent = name == "cBniv_BankReagent"
    local tAccount = name == "cBniv_BankAccount"

    local tBankBags = string.find(name, "Bank")

    table.insert((tBankBags and BankFrames or BagFrames), self)
 
    self:EnableMouse(true)

    self.UpdateDimensions = UpdateDimensions

    self:SetFrameStrata("HIGH")
    tinsert(UISpecialFrames, self:GetName()) -- Close on "Esc"

    if (tBag or tBank) then 
        SetFrameMovable(self, _G.SavedStats.cBnivCfg.Unlocked) 
    end

    self.Columns = (tBankBags and cfg.columns.bank) or cfg.columns.bag
    self.ContainerHeight = 0
    self:UpdateDimensions()
    self:SetWidth((itemSlotSize + 2) * self.Columns + 2)

    -- The frame background
    local background = _G.CreateFrame("Frame", nil, self)
    background:SetFrameStrata("HIGH")
    background:SetFrameLevel(1)
    background:SetPoint("TOPLEFT", -4, 4)
    background:SetPoint("BOTTOMRIGHT", 4, -4)

    E:ApplyBackdrop(background, false)

    -- Caption, close button
    local caption = background:CreateFontString(nil, "OVERLAY", nil)
    caption:SetFont(_G.unpack(cfg.fonts.standard))
    if caption then
        local t = L["BAG_CAPTIONS_" .. self.name:upper():sub(7)] or (tBankBags and self.name:sub(5))
        if not t then t = self.name end
        caption:SetText(t)
        caption:SetPoint("TOPLEFT", 7.5, -7.5)
        self.Caption = caption

        if (tBag or tBank) then
            local close = CreateFrame("Button", nil, self, "UIPanelCloseButton")
            if Aurora then
                local F = Aurora[1]
                F.ReskinClose(close, "TOPRIGHT", self, "TOPRIGHT", 1, 1)
                close:SetSize(30,30)
            else
                close:SetSize(24, 24)
                E:SkinCloseButton(close, self)
            end
            close:ClearAllPoints()
            close:SetPoint("TOPRIGHT", 8, 8)
            close:SetScript("OnClick", function(container)
                if cbNivaya:AtBank() then
                    C_Bank.CloseBankFrame()
                else
                    _G.CloseAllBags()
                end
            end)
        end
    end

    local tBtnOffs = 0
    if (tBag or tBank) then
        -- Bag bar for changing bags
        local bagType = tBag and "bags" or "bank"
        
        local tS = tBag and "backpack+bags" or "bank"
        local tI = tBag and NumBagContainer or 7

        local bagButtons = self:SpawnPlugin("BagBar", tS)
        bagButtons:SetSize(bagButtons:LayoutButtons("grid", tI))
        bagButtons.highlightFunction = function(button, match) button:SetAlpha(match and 1 or 0.1) end
        bagButtons.isGlobal = true

        bagButtons:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, tBag and 40 or 25)
        bagButtons:Hide()

        -- main window gets a fake bag button for toggling key ring
        self.BagBar = bagButtons

        -- We don't need the bag bar every time, so let's create a toggle button for them to show
        self.bagToggle = createIconButton("Bags", self, Textures.BagToggle, "BOTTOMRIGHT", L.BAG_HINT_TOGGLE, tBag)
        self.bagToggle:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
        self.bagToggle:SetScript("OnClick", function()
            if (self.BagBar:IsShown()) then
                self.BagBar:Hide()
            else
                self.BagBar:Show()
            end
            self:UpdateDimensions()
        end)

        -- Button to reset new items:
        if tBag and _G.SavedStats.cBnivCfg.NewItems then
            self.resetBtn = createIconButton("ResetNew", self, Textures.ResetNew, "BOTTOMRIGHT", L.BAG_HINT_RESET_NEW, tBag)
            self.resetBtn:SetPoint("BOTTOMRIGHT", self.bagToggle, "BOTTOMLEFT", 0, 0)
            self.resetBtn:SetScript("OnClick", function() resetNewItems(self) end)
        end

        -- Button to restack items:
        if _G.SavedStats.cBnivCfg.Restack then
            self.restackBtn = createIconButton("Restack", self, Textures.Restack, "BOTTOMRIGHT", L.BAG_HINT_RESTACK, tBag)
            if self.resetBtn then
                self.restackBtn:SetPoint("BOTTOMRIGHT", self.resetBtn, "BOTTOMLEFT", 0, 0)
            else
                self.restackBtn:SetPoint("BOTTOMRIGHT", self.bagToggle, "BOTTOMLEFT", 0, 0)
            end
            self.restackBtn:SetScript("OnClick", function() restackItems(self) end)
        end

        -- Button to send reagents to Reagent Bank:
        if tBank then
            local rbHint = _G.REAGENTBANK_DEPOSIT
            self.reagentBtn = createIconButton("SendReagents", self, Textures.Deposit, "BOTTOMRIGHT", rbHint, tBag)
            if self.restackBtn then
                self.reagentBtn:SetPoint("BOTTOMRIGHT", self.restackBtn, "BOTTOMLEFT", 0, 0)
            else
                self.reagentBtn:SetPoint("BOTTOMRIGHT", self.bagToggle, "BOTTOMLEFT", 0, 0)
            end
            self.reagentBtn:SetScript("OnClick", function()
                _G.DepositReagentBank()
            end)
        end

        -- Tooltip positions
        local btnTable = { self.bagToggle }
        if self.restackBtn then _G.tinsert(btnTable, self.restackBtn) end
        if tBag then
            if self.resetBtn then _G.tinsert(btnTable, self.resetBtn) end
        end
        if tBank then
            if self.reagentBtn then _G.tinsert(btnTable, self.reagentBtn) end
        end
        local ttPos = -(#btnTable * 24 + 16)
        if tBank then ttPos = ttPos + 3 end
        for k, v in pairs(btnTable) do
            v.tooltip:ClearAllPoints()
            v.tooltip:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", ttPos, 5.5)
        end
    end

    if tAccount then
        local bagWarband = self:SpawnPlugin("BagWarband", "accountbank")
        bagWarband:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 2)
        bagWarband:SetSize(bagWarband:LayoutButtons("grid", 5))
        bagWarband.highlightFunction = function(button, match) button:SetAlpha(match and 1 or 0.1) end

        self.BagBar = bagWarband

        local rbHint = _G.ACCOUNT_BANK_DEPOSIT_BUTTON_LABEL
        self.depositBtn = createIconButton("SendAccount", self, Textures.Deposit, "BOTTOMRIGHT", rbHint, false)
        self.depositBtn:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
        self.depositBtn:SetScript("OnClick", function() 
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
            _G.AccountBankPanel.ItemDepositFrame.DepositButton:AutoDepositItems()
            self:UpdateBag()
        end)

        self.depositBtn.tooltip:ClearAllPoints()
        self.depositBtn.tooltip:SetPoint("RIGHT", self.depositBtn, "LEFT", -5, 0)

        local checkbox = CreateFrame("CheckButton", nil, self, "InterfaceOptionsCheckButtonTemplate")
        checkbox:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 2, 2)
        checkbox:SetChecked(GetCVarBool("bankAutoDepositReagents"))
        checkbox:SetScript("OnClick", function(self)
            SetCVar("bankAutoDepositReagents", self:GetChecked())
        end)
        E:SkinCheckBox(checkbox)

        checkbox.fs = checkbox:CreateFontText(14, '', false, "LEFT", 30, 0)
        checkbox.fs:SetText(L.BAG_HINT_ACOUNT_DEPOSIT_INCLUDE_REAGENTS)
    end

    -- Item drop target
    if (tBag or tBank or tReagent or tAccount) then
        self.DropTarget = _G.CreateFrame("ItemButton", self.name .. "DropTarget", self)
        local dtNT = _G[self.DropTarget:GetName() .. "NormalTexture"]
        if dtNT then dtNT:SetTexture(nil) end

        local DropTargetProcessItem = function()
            local bID, sID = GetFirstFreeSlot((tBag and "bag") or (tBank and "bank") or (tReagent and "bankReagent") or false)
            if bID then PickupContainerItem(bID, sID) end
        end

        self.DropTarget:SetScript("OnMouseUp", DropTargetProcessItem)
        self.DropTarget:SetScript("OnReceiveDrag", DropTargetProcessItem)
        self.DropTarget:SetSize(itemSlotSize, itemSlotSize)

        self.DropTarget:CreateBackdrop()
        self.DropTarget.backdrop:SetAllPoints()
        self.DropTarget.backdrop:SetBackdrop({
                                           bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
                                           edgeFile = "Interface\\Buttons\\WHITE8x8",
                                           tile     = false, tileSize = 16, edgeSize = 1,
                                       })
        self.DropTarget.backdrop:SetBackdropColor(1, 1, 1, 0.1)
        self.DropTarget.backdrop:SetBackdropBorderColor(0, 0, 0, 1)

        local freeSlot = self:SpawnPlugin("TagDisplay", "[space]", self.DropTarget)
        freeSlot.__type = (tBag and "Bag") or (tBank and "Bank") or (tReagent and "BankReagent") or (tAccount and "BankAccount")
        freeSlot:SetPoint("BOTTOMRIGHT", self.DropTarget, "BOTTOMRIGHT", 1.5, 1.5)
        freeSlot:SetFont(_G.unpack(cfg.fonts.standard))
        freeSlot:SetJustifyH("RIGHT")
        freeSlot:SetShadowColor(0, 0, 0, 0)

        self.NumFreeSlots = freeSlot

        if _G.SavedStats.cBnivCfg.CompressEmpty then
            self.DropTarget:Show()
        else
            self.DropTarget:Hide()
        end
    end

    if tBag then
        local infoFrame = _G.CreateFrame("Button", nil, self)
        infoFrame:SetPoint("BOTTOMLEFT", 5, -6)
        infoFrame:SetPoint("BOTTOMRIGHT", -86, -6)
        infoFrame:SetHeight(32)

        -- Search bar
        local search = self:SpawnPlugin("SearchBar", infoFrame)
        search.isGlobal = true
        search.highlightFunction = function(button, match) button:SetAlpha(match and 1 or 0.1) end

        local searchIcon = background:CreateTexture(nil, "ARTWORK")
        searchIcon:SetTexture(Textures.Search)
        searchIcon:SetVertexColor(0.8, 0.8, 0.8)
        searchIcon:SetPoint("BOTTOMLEFT", infoFrame, "BOTTOMLEFT", -3, 8)
        searchIcon:SetWidth(16)
        searchIcon:SetHeight(16)

        -- The money display
        local money = self:SpawnPlugin("TagDisplay", "[money]", self)
        money:SetPoint("TOPRIGHT", self, -32, -2)
        money:SetFont(_G.unpack(cfg.fonts.standard))
        money:SetJustifyH("RIGHT")
        money:SetShadowColor(0, 0, 0, 0)
    end

    self:SetScale(_G.SavedStats.cBnivCfg.scale)
    return self
end

------------------------------------------
-- MyButton specific
------------------------------------------
local MyButton = cbNivaya:GetItemButtonClass()
MyButton:Scaffold("Default")

function MyButton:OnAdd()
    self:SetScript('OnMouseUp', function(self, mouseButton)
        if (mouseButton == 'RightButton') then
            local slotId, bagId = self:GetSlotAndBagID()
            local tID = GetContainerItemID(bagId, slotId)
            
            if not tID then return end
            
            local ctrl = IsControlKeyDown()
            
            if ctrl and cbNivaya:AtBank() then
                UseContainerItem(bagId, slotId, nil, true);
            end
        end
    end)
end

function MyButton:OnCreate()
    self:SetNormalTexture(0)
    self:SetPushedTexture(0)
    self:SetHighlightTexture("Interface\\ChatFrame\\ChatFrameBackground")
    self:GetHighlightTexture():SetVertexColor(1, 1, 1, .25)
    self:GetHighlightTexture():SetInside()
    self:SetSize(itemSlotSize - 4, itemSlotSize - 4)
    self:CreateBackdrop()
    
    self.backdrop:SetOutside()
    self.backdrop:SetBackdropColor(.3, .3, .3, .3)

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

local iLvlClassIDs = {
    [Enum.ItemClass.Gem] = Enum.ItemGemSubclass.Artifactrelic,
    [Enum.ItemClass.Armor] = 0,
    [Enum.ItemClass.Weapon] = 0,
}
function isItemHasLevel(item)
    local index = iLvlClassIDs[item.classID]
    return index and (index == 0 or index == item.subClassID)
end

local function isItemNeedsLevel(item)
    return item.link and item.quality > 1 and isItemHasLevel(item)
end

local function getIconOverlayAtlas(item)
    if not item.link then return end

    if C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID(item.link) then
        return "AzeriteIconFrame"
    elseif IsCosmeticItem(item.link) then
        return "CosmeticIconFrame"
    elseif C_Soulbinds_IsItemConduitByItemInfo(item.link) then
        return "ConduitIconFrame", "ConduitIconFrame-Corners"
    end
end

local function updateCanIMogIt(self, item)
    if not self.canIMogIt then return end

    local text, unmodifiedText = CanIMogIt:GetTooltipText(nil, item.bagId, item.slotId)
    if text and text ~= "" then
        local icon = CanIMogIt.tooltipOverlayIcons[unmodifiedText]
        self.canIMogIt:SetTexture(icon)
        self.canIMogIt:Show()
    else
        self.canIMogIt:Hide()
    end
end

local function updatePawnArrow(self, item)
    if not C_AddOns.IsAddOnLoaded("Pawn") then return end
    if not PawnIsContainerItemAnUpgrade then return end
    if self.UpgradeIcon then
        self.UpgradeIcon:SetShown(PawnIsContainerItemAnUpgrade(item.bagId, item.slotId))
    end
end

local function itemColorGradient(perc, ...)
    if perc >= 1 then
        return select(select('#', ...) - 2, ...)
    elseif perc <= 0 then
        return ...
    end

    local num = select('#', ...) / 3
    local segment, relperc = _G.math.modf(perc*(num-1))
    local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)

    return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end

function MyButton:OnUpdateButton(item)
    self.IconOverlay:SetVertexColor(1, 1, 1)
    self.IconOverlay:Hide()
    self.IconOverlay2:Hide()

    local atlas, secondAtlas = getIconOverlayAtlas(item)
    if atlas then
        self.IconOverlay:SetAtlas(atlas)
        self.IconOverlay:Show()
        if secondAtlas then
            local color = C.media.qualityColors[item.quality or 1]
            self.IconOverlay:SetVertexColor(color.r, color.g, color.b)
            self.IconOverlay2:SetAtlas(secondAtlas)
            self.IconOverlay2:Show()
        end
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
    if dMax and (dMax > 0) and (dCur < dMax) then
        local dPer = (dCur / dMax * 100)
        local r, g, b = itemColorGradient((dCur/dMax), 1, 0, 0, 1, 1, 0, 0, 1, 0)
        self.durability:SetText(Round(dPer).."%")
        self.durability:SetTextColor(r, g, b)
    else
        self.durability:SetText("")
    end

    self.backdrop:SetBackdropColor(.3, .3, .3, .3)

    -- Hide empty tooltip
    if not item.texture and GameTooltip:GetOwner() == self then
        GameTooltip:Hide()
    end

    -- Support CanIMogIt
    updateCanIMogIt(self, item)

    -- Support Pawn
    updatePawnArrow(self, item)
end

function MyButton:OnUpdateQuest(item)
    if item.questID and not item.questActive then
        self.QuestIcon:Show()
    else
        self.QuestIcon:Hide()
    end

    if item.questID or item.isQuestItem then
        self.backdrop:SetBackdropBorderColor(.8, .8, 0)
    elseif item.quality and item.quality > -1 then
        local color = C.media.qualityColors[item.quality]
        self.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
    else
        self.backdrop:SetBackdropBorderColor(0, 0, 0)
    end
end