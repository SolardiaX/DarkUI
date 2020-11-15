local _, ns = ...
local E, C, L = ns:unpack()
local cargBags = ns.cargBags

if not C.bags.enable then return end

----------------------------------------------------------------------------------------
--	Style of Bags (modified from cargBags_Nivaya of RealUI)
----------------------------------------------------------------------------------------

-- Lua Globals --
local _G = _G
local next, ipairs = _G.next, _G.ipairs

local BackdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil


local Textures = {
    Search         = C.media.path .. "bag_search",
    BagToggle      = C.media.path .. "bag_toggle",
    ResetNew       = C.media.path .. "bag_reset",
    Restack        = C.media.path .. "bag_restack",
    Deposit        = C.media.path .. "bag_deposit",
    TooltipIcon    = C.media.path .. "bag_tooltip_icon",
    Up             = C.media.path .. "bag_up",
    Down           = C.media.path .. "bag_down",
    Left           = C.media.path .. "bag_left",
    Right          = C.media.path .. "bag_right",
    BagUpgradeIcon = C.media.path .. "bag_upgrade_icon",
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

local GetNumFreeSlots = function(bagType)
    local free, max = 0, 0
    if bagType == "bag" then
        for i = 0, 4 do
            free = free + _G.GetContainerNumFreeSlots(i)
            max = max + _G.GetContainerNumSlots(i)
        end
    elseif bagType == "bankReagent" then
        free = _G.GetContainerNumFreeSlots(-3)
        max = _G.GetContainerNumSlots(-3)
    else
        local containerIDs = { -1, 5, 6, 7, 8, 9, 10, 11 }
        for _, i in next, containerIDs do
            free = free + _G.GetContainerNumFreeSlots(i)
            max = max + _G.GetContainerNumSlots(i)
        end
    end
    return free, max
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
    local yPosOffs = self.Caption and 20 or 0
    local isEmpty = true

    local tName = self.name
    local tBankBags = string.find(tName, "Bank")
    local tBank = tBankBags or (tName == "cBniv_Bank")
    local tReagent = (tName == "cBniv_BankReagent")
    local numSlotsBag = {GetNumFreeSlots("bag")}
    local numSlotsBank = {GetNumFreeSlots("bank")}
    local numSlotsReagent = {GetNumFreeSlots("bankReagent")}
    local usedSlotsBag = numSlotsBag[2] - numSlotsBag[1]
    local usedSlotsBank = numSlotsBank[2] - numSlotsBank[1]
    local usedSlotsReagent = numSlotsReagent[2] - numSlotsReagent[1]
    local oldColums = self.Columns
    if (tBank or tBankBags or tReagent) then
        self.Columns = (usedSlotsBank > cfg.sizes.bank.largeItemCount) and cfg.sizes.bank.columnsLarge or cfg.sizes.bank.columnsSmall
--	elseif (tReagent) then
--		self.Columns = (usedSlotsReagent > cfg.sizes.bank.largeItemCount) and cfg.sizes.bank.columnsLarge or cfg.sizes.bank.columnsSmall
    else
        self.Columns = (usedSlotsBag > cfg.sizes.bags.largeItemCount) and cfg.sizes.bags.columnsLarge or cfg.sizes.bags.columnsSmall
    end
    local needColumnUpdate = (self.Columns ~= oldColums)

    local buttonIDs = {}
      for i, button in pairs(self.buttons) do
        local item = cbNivaya:GetCustomItemInfo(button.bagID, button.slotID)
        if item.link then
            buttonIDs[i] = { item.id, item.rarity, button, item.count }
        else
            buttonIDs[i] = { nil, button }
        end
    end
    if ((tBank or tReagent) and _G.SavedStats.cBnivCfg.SortBank) or (not (tBank or tReagent) and _G.SavedStats.cBnivCfg.SortBags) then QuickSort(buttonIDs) end

    for _, v in ipairs(buttonIDs) do
        local button = v[3]
        button:ClearAllPoints()

        local xPos = col * (itemSlotSize + 2) + 2
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

        cB_Bags.main.EmptySlotCounter:SetText(GetNumFreeSlots("bag"))
        cB_Bags.bank.EmptySlotCounter:SetText(GetNumFreeSlots("bank"))
        cB_Bags.bankReagent.EmptySlotCounter:SetText(GetNumFreeSlots("bankReagent"))
    end

    -- This variable stores the size of the item button container
    self.ContainerHeight = (row + (col > 0 and 1 or 0)) * (itemSlotSize + 2)

    if (self.UpdateDimensions) then self:UpdateDimensions() end -- Update the bag's height
    self:SetWidth((itemSlotSize + 2) * self.Columns + 2)
    local t = (tName == "cBniv_Bag") or (tName == "cBniv_Bank") or (tName == "cBniv_BankReagent")
    local tAS = (tName == "cBniv_Ammo") or (tName == "cBniv_Soulshards")
    local bankShown = cB_Bags.bank:IsShown()
    if (not tBankBags and cB_Bags.main:IsShown() and not (t or tAS)) or (tBankBags and bankShown) then 
        if isEmpty then
            self:Hide()
            if bankShown then
                cB_Bags.bank:Show()
    end
        else
            self:Show()
        end 
    end

    cB_BagHidden[tName] = (not t) and isEmpty or false
    cbNivaya:UpdateAnchors(self)
    --update all other bags as well
    if needColumnUpdate and not forced then
        if tBankBags then
            local t = BankFrames
            for i=1,#t do
                if t[i].name ~= tName then
                    t[i]:OnContentsChanged(true)
                end
            end
        else
            local t = BagFrames
            for i=1,#t do
                if t[i].name ~= tName then
                    t[i]:OnContentsChanged(true)
                end
            end
        end
    end
end

--[[function MyContainer:OnButtonAdd(button)
    if not button.Border then return end

    local _,bagType = GetContainerNumFreeSlots(button.bagID)
    if button.bagID == KEYRING_CONTAINER then
        button.Border:SetBackdropBorderColor(0, 0, 0)     -- Key ring
    elseif bagType and bagType > 0 and bagType < 8 then
        button.Border:SetBackdropBorderColor(1, 1, 0)       -- Ammo bag
    elseif bagType and bagType > 4 then
        button.Border:SetBackdropBorderColor(1, 1, 1)       -- Profession bags
    else
        button.Border:SetBackdropBorderColor(0, 0, 0)       -- Normal bags
    end
end]]--

-- Restack Items
local function restackItems(self)
    local tBag, tBank = (self.name == "cBniv_Bag"), (self.name == "cBniv_Bank")
    --local loc = tBank and "bank" or "bags"
    if tBank then
        _G.SortBankBags()
        if _G.IsReagentBankUnlocked() then
            _G.SortReagentBankBags()
        end
    elseif tBag then
        _G.SortBags()
    end
end

-- Reset New
local resetNewItems = function(self)
    cB_KnownItems = _G.SavedStatsPerChar.cB_KnownItems or {}
    if not _G.SavedStatsPerChar.cBniv.clean then
        for item, numItem in next, cB_KnownItems do
            if type(item) == "string" then
                cB_KnownItems[item] = nil
            end
        end
        _G.SavedStatsPerChar.cBniv.clean = true
    end
    for bag = 0, 4 do
        local tNumSlots = GetContainerNumSlots(bag)
        if tNumSlots > 0 then
            for slot = 1, tNumSlots do
                local item = cbNivaya:GetCustomItemInfo(bag, slot)
                --print("resetNewItems", item.id)
                if item.id then
                    if cB_KnownItems[item.id] then
                        cB_KnownItems[item.id] = cB_KnownItems[item.id] + (item.stackCount and item.stackCount or 0)
                    else
                        cB_KnownItems[item.id] = item.stackCount and item.stackCount or 0
                    end
                end
            end 
        end
    end
    cbNivaya:UpdateBags()
end
function cbNivResetNew()
    resetNewItems()
end

local UpdateDimensions = function(self)
    local height = 0            -- Normal margin space
    if self.BagBar and self.BagBar:IsShown() then
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
        height = height + self.Caption:GetStringHeight() + 12
    end
    self:SetHeight(self.ContainerHeight + height)
end

local SetFrameMovable = function(f, v)
    f:SetMovable(true)
    f:SetUserPlaced(true)
    f:RegisterForClicks("LeftButton", "RightButton")
    if v then
        f:SetScript("OnMouseDown", function()
            f:ClearAllPoints()
            f:StartMoving()
        end)
        f:SetScript("OnMouseUp", f.StopMovingOrSizing)
    else
        f:SetScript("OnMouseDown", nil)
        f:SetScript("OnMouseUp", nil)
    end
end

local function IconButton_OnEnter(self)
    self.mouseover = true
    self.icon:SetVertexColor(unpack(C.media.text_color))

    if self.tooltip then
        self.tooltip:Show()
        self.tooltipIcon:Show()
    end
end

local function IconButton_OnLeave(self)
    self.mouseover = false
    self.icon:SetVertexColor(0.8, 0.8, 0.8)
    if self.tooltip then
        self.tooltip:Hide()
        self.tooltipIcon:Hide()
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

    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetPoint(point, button, point, point == "BOTTOMLEFT" and 2 or -2, 2)
    button.icon:SetWidth(22)
    button.icon:SetHeight(22)
    button.icon:SetTexture(texture)
    button.icon:SetVertexColor(0.8, 0.8, 0.8)

    button.tooltip = button:CreateFontString()
    -- button.tooltip:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", isBag and -76 or -59, 4.5)
    button.tooltip:SetFont(_G.unpack(cfg.fonts.standard))
    button.tooltip:SetJustifyH("RIGHT")
    button.tooltip:SetText(hint)
    button.tooltip:SetTextColor(0.8, 0.8, 0.8)
    button.tooltip:Hide()

    button.tooltipIcon = button:CreateTexture(nil, "ARTWORK")
    -- button.tooltipIcon:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", isBag and -71 or -54, 1)
    button.tooltipIcon:SetWidth(18)
    button.tooltipIcon:SetHeight(18)
    button.tooltipIcon:SetTexture(Textures.TooltipIcon)
    button.tooltipIcon:SetVertexColor(0.9, 0.2, 0.2)
    button.tooltipIcon:Hide()

    button.tag = name
    button:SetScript("OnEnter", function() IconButton_OnEnter(button) end)
    button:SetScript("OnLeave", function() IconButton_OnLeave(button) end)
    button.mouseover = false

    return button
end

local GetFirstFreeSlot = function(bagtype)
    if bagtype == "bag" then
        for i = 0,4 do
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
        local bagID = -3
        local t = GetContainerNumFreeSlots(bagID)
        if t > 0 then
            local tNumSlots = GetContainerNumSlots(bagID)
            for j = 1,tNumSlots do
                local tLink = GetContainerItemLink(bagID,j)
                if not tLink then return bagID,j end
            end
        end
    else
        local containerIDs = { -1, 5, 6, 7, 8, 9, 10, 11 }
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
    --print("MyContainer:OnCreate", name)
    settings = settings or {}
    self.Settings = settings
    self.name = name

    local tBag, tBank, tReagent = (name == "cBniv_Bag"), (name == "cBniv_Bank"), (name == "cBniv_BankReagent")
    local tBankBags = string.find(name, "Bank")

    table.insert((tBankBags and BankFrames or BagFrames), self)
    local numSlotsBag = { GetNumFreeSlots("bag") }
    local numSlotsBank = { GetNumFreeSlots("bank") }
    local numSlotsReagent = { GetNumFreeSlots("bankReagent") }

    local usedSlotsBag = numSlotsBag[2] - numSlotsBag[1]
    local usedSlotsBank = numSlotsBank[2] - numSlotsBank[1]
    local usedSlotsReagent = numSlotsReagent[2] - numSlotsReagent[1]

    self:EnableMouse(true)

    self.UpdateDimensions = UpdateDimensions

    self:SetFrameStrata("HIGH")
    tinsert(UISpecialFrames, self:GetName()) -- Close on "Esc"

    if (tBag or tBank) then 
        SetFrameMovable(self, _G.SavedStats.cBnivCfg.Unlocked) 
    end

    if (tBank or tBankBags) then
        self.Columns = (usedSlotsBank > cfg.sizes.bank.largeItemCount) and cfg.sizes.bank.columnsLarge or cfg.sizes.bank.columnsSmall
    elseif (tReagent) then
        self.Columns = (usedSlotsReagent > cfg.sizes.bank.largeItemCount) and cfg.sizes.bank.columnsLarge or cfg.sizes.bank.columnsSmall
    else
        self.Columns = (usedSlotsBag > cfg.sizes.bags.largeItemCount) and cfg.sizes.bags.columnsLarge or cfg.sizes.bags.columnsSmall
    end
    self.ContainerHeight = 0
    self:UpdateDimensions()
    self:SetWidth((itemSlotSize + 2) * self.Columns + 2)

    -- The frame background
    local background = _G.CreateFrame("Frame", nil, self)
    background:SetFrameStrata("HIGH")
    background:SetFrameLevel(1)
    background:SetPoint("TOPLEFT", -4, 4)
    background:SetPoint("BOTTOMRIGHT", 4, -4)
    background:SetTemplate("Blur")
    background:CreateShadow()

    -- Caption, close button
    local caption = background:CreateFontString(background, "OVERLAY", nil)
    caption:SetFont(_G.unpack(cfg.fonts.standard))
    if caption then
        local t = L["BAG_BAGCAPTIONS_" .. self.name:upper():sub(7)] or (tBankBags and self.name:sub(5))
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
                close:SetPoint("TOPRIGHT", 8, 8)
                close:SetDisabledTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Disabled")
                close:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
                close:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
                close:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight", "ADD")
            end
            close:SetPoint("TOPRIGHT", 10, 10)
            close:SetScript("OnClick", function(container)
                if cbNivaya:AtBank() then
                    _G.CloseBankFrame()
                else
                    _G.CloseAllBags()
                end
            end)
        end
    end

    -- mover buttons
    if settings.isCustomBag then
        local moveLR = function(dir)
            local idx = -1
            for i,v in ipairs(_G.SavedStats.cB_CustomBags) do if v.name == name then idx = i end end
            if (idx == -1) then return end

            local tcol = (_G.SavedStats.cB_CustomBags[idx].col + ((dir == "left") and 1 or -1)) % 2
            _G.SavedStats.cB_CustomBags[idx].col = tcol
            cbNivaya:CreateAnchors()
        end

        local moveUD = function(dir)
            local idx = -1
            for i,v in ipairs(_G.SavedStats.cB_CustomBags) do if v.name == name then idx = i end end
            if (idx == -1) then return end

            local pos = idx
            local d = (dir == "up") and 1 or -1
            repeat
                pos = pos + d
            until
                (not _G.SavedStats.cB_CustomBags[pos]) or (_G.SavedStats.cB_CustomBags[pos].col == _G.SavedStats.cB_CustomBags[idx].col)

            if (_G.SavedStats.cB_CustomBags[pos] ~= nil) then
                local ele = _G.SavedStats.cB_CustomBags[idx]
                _G.SavedStats.cB_CustomBags[idx] = _G.SavedStats.cB_CustomBags[pos]
                _G.SavedStats.cB_CustomBags[pos] = ele
                cbNivaya:CreateAnchors()
            end
        end

        local rightBtn = createMoverButton(self, Textures.Right, "Right")
        rightBtn:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
        rightBtn:SetScript("OnClick", function() moveLR("right") end)

        local leftBtn = createMoverButton(self, Textures.Left, "Left")
        leftBtn:SetPoint("TOPRIGHT", self, "TOPRIGHT", -17, 0)
        leftBtn:SetScript("OnClick", function() moveLR("left") end)

        local downBtn = createMoverButton(self, Textures.Down, "Down")
        downBtn:SetPoint("TOPRIGHT", self, "TOPRIGHT", -34, 0)
        downBtn:SetScript("OnClick", function() moveUD("down") end)

        local upBtn = createMoverButton(self, Textures.Up, "Up")
        upBtn:SetPoint("TOPRIGHT", self, "TOPRIGHT", -51, 0)
        upBtn:SetScript("OnClick", function() moveUD("up") end)

        self.rightBtn = rightBtn
        self.leftBtn = leftBtn
        self.downBtn = downBtn
        self.upBtn = upBtn
    end

    local tBtnOffs = 0
      if (tBag or tBank) then
        -- Bag bar for changing bags
        local bagType = tBag and "bags" or "bank"
        local tS = tBag and "backpack+bags" or "bank"
        local tI = tBag and 4 or 7

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
                --  if self.hint then self.hint:Show() end
                --  self.hintShown = true
            else
                self.BagBar:Show()
                --  if self.hint then self.hint:Hide() end
                --  self.hintShown = false
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
            self.restackBtn = createIconButton("Restack", self, Textures.Restack, "BOTTOMRIGHT", L.BAG_RESTACK, tBag)
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
                --print("Deposit!!!")
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
            v.tooltipIcon:ClearAllPoints()
            v.tooltipIcon:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", ttPos + 5, 1.5)
        end
    end

    -- Item drop target
    if (tBag or tBank or tReagent) then
        self.DropTarget = _G.CreateFrame("ItemButton", self.name .. "DropTarget", self)
        local dtNT = _G[self.DropTarget:GetName() .. "NormalTexture"]
        if dtNT then dtNT:SetTexture(nil) end

        local DropTargetProcessItem = function()
            -- if CursorHasItem() then  -- Commented out to fix Guild Bank -> Bags item dragging
            local bID, sID = GetFirstFreeSlot((tBag and "bag") or (tBank and "bank") or "bankReagent")
            if bID then _G.PickupContainerItem(bID, sID) end
            -- end
        end
        self.DropTarget:SetScript("OnMouseUp", DropTargetProcessItem)
        self.DropTarget:SetScript("OnReceiveDrag", DropTargetProcessItem)
        self.DropTarget:SetSize(itemSlotSize - 1, itemSlotSize - 1)

        self.DropTarget:CreateBackdrop()
        self.DropTarget.backdrop:SetAllPoints()
        self.DropTarget.backdrop:SetBackdrop({
                                           bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
                                           edgeFile = "Interface\\Buttons\\WHITE8x8",
                                           tile     = false, tileSize = 16, edgeSize = 1,
                                       })
        self.DropTarget.backdrop:SetBackdropColor(1, 1, 1, 0.1)
        self.DropTarget.backdrop:SetBackdropBorderColor(0, 0, 0, 1)

        local fs = self:CreateFontString(nil, "OVERLAY")
        fs:SetFont(_G.unpack(cfg.fonts.standard))
        fs:SetJustifyH("LEFT")
        fs:SetPoint("BOTTOMRIGHT", self.DropTarget, "BOTTOMRIGHT", 1.5, 1.5)
        self.EmptySlotCounter = fs

        if _G.SavedStats.cBnivCfg.CompressEmpty then
            self.DropTarget:Show()
            self.EmptySlotCounter:Show()
        else
            self.DropTarget:Hide()
            self.EmptySlotCounter:Hide()
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

        -- Hint
        self.hint = background:CreateFontString(nil, "OVERLAY", nil)
        self.hint:SetPoint("BOTTOMLEFT", infoFrame, -0.5, 31.5)
        self.hint:SetFont(_G.unpack(cfg.fonts.standard))
        self.hint:SetTextColor(1, 1, 1, 0.4)
        self.hint:SetText(L.BAG_CLICK_TO_SETCATEGORY)
        self.hintShown = true

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
        if (mouseButton == 'RightButton') and (IsAltKeyDown()) and (IsControlKeyDown()) then
            local tID = GetContainerItemID(self.bagID, self.slotID)
            if tID then
                cbNivCatDropDown.itemName = GetItemInfo(tID)
                cbNivCatDropDown.itemID = tID
                --ToggleDropDownMenu(1, nil, cbNivCatDropDown, self, 0, 0)
                cbNivCatDropDown:Toggle(self, nil, nil, 0, 0)
            end
        end
    end)
end

local UpdateItemUpgradeIcon
local ITEM_UPGRADE_CHECK_TIME = 0.5;
local function UpgradeCheck_OnUpdate(self, elapsed)
    self.timeSinceUpgradeCheck = self.timeSinceUpgradeCheck + elapsed;

    if self.timeSinceUpgradeCheck >= ITEM_UPGRADE_CHECK_TIME then
        UpdateItemUpgradeIcon(self);
    end
end

function UpdateItemUpgradeIcon(item)
    item.timeSinceUpgradeCheck = 0;

    local itemIsUpgrade = _G.IsContainerItemAnUpgrade(item:GetParent():GetID(), item:GetID());
    if itemIsUpgrade == nil then
        -- nil means not all the data was available to determine if this is an upgrade.
        item.UpgradeIcon:SetShown(false);
        item:SetScript("OnUpdate", UpgradeCheck_OnUpdate);
    else
        item.UpgradeIcon:SetShown(itemIsUpgrade);
        item:SetScript("OnUpdate", nil);
    end
end

local UpdateScrapIcon
function UpdateScrapIcon(item)
    local itemLocation = _G.ItemLocation:CreateFromBagAndSlot(item:GetParent():GetID(), item:GetID())
    if itemLocation then
        if _G.C_Item.DoesItemExist(itemLocation) and _G.C_Item.CanScrapItem(itemLocation) then
            item.ScrapIcon:SetShown(itemLocation)
        else
            item.ScrapIcon:SetShown(false)
        end
    end
end

function MyButton:OnCreate()
    self:SetNormalTexture(nil)
    self:SetPushedTexture(nil)

    -- Scrap Icon
    self.ScrapIcon = self:CreateTexture(nil, "ARTWORK")
    self.ScrapIcon:SetAtlas("bags-icon-scrappable")
    self.ScrapIcon:SetSize(14, 12)
    self.ScrapIcon:SetPoint("TOPRIGHT", -1, -1)

    -- Item Upgrade Icon
    self.UpgradeIcon = self:CreateTexture(nil, "ARTWORK")
    self.UpgradeIcon:SetTexture(Textures.BagUpgradeIcon)
    self.UpgradeIcon:SetTexCoord(0, 1, 0, 1)

    -- Item Upgrade Icon
    self.QuestIcon = self:CreateTexture(nil, "ARTWORK")
    self.QuestIcon:SetTexture("Interface\\GossipFrame\\AvailableQuestIcon")
    self.QuestIcon:SetTexCoord(0, 1, 0, 1)
    self.QuestIcon:SetSize(14, itemSlotSize / 2)
    self.QuestIcon:SetPoint("TOPRIGHT", -1, -1)
end

function MyButton:OnUpdate(item)
    -- Scrap Icon update
    if cfg.scrapIcon and self.ScrapIcon then
        UpdateScrapIcon(self)
    end

    -- Item Upgrade Update
    if cfg.upgradeIcon and self.UpgradeIcon then
        UpdateItemUpgradeIcon(self)
    end
end

function MyButton:OnUpdateQuest(item)
    if item.questID and not item.questActive then
        self.QuestIcon:Show()
    else
        self.QuestIcon:Hide()
    end
end
