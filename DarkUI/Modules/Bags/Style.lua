local E, C, L, DB = select(2, ...):unpack()
local cargBags = select(2, ...).cargBags

------------------------------------------------------------------------
-- Bag Style
------------------------------------------------------------------------

local module = E:Module("Bags")
local cfg = C.bags

local CHAR_BANK_TYPE = Enum.BankType.Character or 0
local ACCOUNT_BANK_TYPE = Enum.BankType.Account or 2

local ipairs, unpack, ceil, strmatch = ipairs, unpack, math.ceil, string.match
local C_Container_GetContainerItemDurability = C_Container.GetContainerItemDurability
local C_Container_GetContainerNumFreeSlots = C_Container.GetContainerNumFreeSlots
local C_Container_GetContainerNumSlots = C_Container.GetContainerNumSlots
local C_Container_GetContainerItemLink = C_Container.GetContainerItemLink
local C_Container_PickupContainerItem = C_Container.PickupContainerItem

local iconSize = cfg.iconSize or 28
local fontSize = cfg.fontSize or 12
local SPACING = 3
local HEADER_HEIGHT = 38
local FOOTER_HEIGHT = 32

local Textures = {
    Search = C.media.path .. "bag_search",
    BagToggle = C.media.path .. "bag_toggle",
    ResetNew = C.media.path .. "bag_reset",
    Restack = C.media.path .. "bag_restack",
    Deposit = C.media.path .. "bag_deposit",
}

local FONT_STANDARD = { STANDARD_TEXT_FONT, fontSize, "OUTLINE" }

------------------------------------------------------------------------
-- Container & Button Classes
------------------------------------------------------------------------

module.MyContainer = nil
module.MyButton = nil

function module:GetClasses(impl)
    self.MyContainer = impl:GetContainerClass()
    self.MyButton = impl:GetItemButtonClass()
    self.MyButton:Scaffold("Default")
    return self.MyContainer, self.MyButton
end

------------------------------------------------------------------------
-- Container Label Map
------------------------------------------------------------------------

local containerLabels = {
    AzeriteItem = L.BAG_LABEL_AZERITE,
    Equipment = L.BAG_LABEL_EQUIPMENT,
    EquipSet = L.BAG_LABEL_EQUIPSET,
    Consumable = L.BAG_LABEL_CONSUMABLE,
    Junk = L.BAG_LABEL_JUNK,
    BagReagent = L.BAG_LABEL_REAGENT,
    BagGoods = L.BAG_LABEL_GOODS,
    BagQuest = L.BAG_LABEL_QUEST,
    BagCollection = L.BAG_LABEL_COLLECTION,
    BagAnima = L.BAG_LABEL_ANIMA,
    BagStone = L.BAG_LABEL_STONE,
    BagAOE = L.BAG_LABEL_AOE,
    BagLegacy = L.BAG_LABEL_LEGACY,
    BagLower = L.BAG_LABEL_LOWER,
    BagDecor = L.BAG_LABEL_DECOR,
    BankEquipment = L.BAG_LABEL_EQUIPMENT,
    BankEquipSet = L.BAG_LABEL_EQUIPSET,
    BankAzeriteItem = L.BAG_LABEL_AZERITE,
    BankConsumable = L.BAG_LABEL_CONSUMABLE,
    BankGoods = L.BAG_LABEL_GOODS,
    BankQuest = L.BAG_LABEL_QUEST,
    BankCollection = L.BAG_LABEL_COLLECTION,
    BankAnima = L.BAG_LABEL_ANIMA,
    BankAOE = L.BAG_LABEL_AOE,
    BankLegacy = L.BAG_LABEL_LEGACY,
    BankLower = L.BAG_LABEL_LOWER,
    BankDecor = L.BAG_LABEL_DECOR,
    BankJunk = L.BAG_LABEL_JUNK,
    AccountEquipment = L.BAG_LABEL_EQUIPMENT,
    AccountAOE = L.BAG_LABEL_AOE,
    AccountGoods = L.BAG_LABEL_GOODS,
    AccountConsumable = L.BAG_LABEL_CONSUMABLE,
    AccountLegacy = L.BAG_LABEL_LEGACY,
}

------------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------------

local function highlightFunction(button, match)
    button:SetAlpha(match and 1 or 0.1)
end

local function getCustomGroupTitle(index)
    local names = module.customNames
    return (names and names[index]) or (PREFERENCES .. " " .. index)
end

------------------------------------------------------------------------
-- Icon Button
------------------------------------------------------------------------

local classColor
local function iconButtonOnEnter(self)
    self.mouseover = true
    if not classColor then
        classColor = { GetClassColor(select(2, UnitClass("player"))) }
    end
    self.icon:SetVertexColor(classColor[1], classColor[2], classColor[3])
    if self.tooltip then
        self.tooltip:Show()
    end
end

local function iconButtonOnLeave(self)
    self.mouseover = false
    self.icon:SetVertexColor(0.8, 0.8, 0.8)
    if self.tooltip then
        self.tooltip:Hide()
    end
end

local function createIconButton(name, parent, texture, hint)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(24, 24)
    button:SetNormalTexture(0)
    button:SetPushedTexture(0)
    button:SetHighlightTexture("Interface\\ChatFrame\\ChatFrameBackground")
    button:GetHighlightTexture():SetVertexColor(1, 1, 1, 0.25)
    button:GetHighlightTexture():SetInside()

    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetSize(22, 22)
    button.icon:SetPoint("CENTER")
    button.icon:SetTexture(texture)
    button.icon:SetVertexColor(0.8, 0.8, 0.8)

    button.tooltip = button:CreateFontString()
    button.tooltip:SetFont(unpack(FONT_STANDARD))
    button.tooltip:SetJustifyH("RIGHT")
    button.tooltip:SetText(hint or "")
    button.tooltip:SetTextColor(0.8, 0.8, 0.8)
    button.tooltip:Hide()

    button.tag = name
    button:SetScript("OnEnter", iconButtonOnEnter)
    button:SetScript("OnLeave", iconButtonOnLeave)
    button.mouseover = false

    return button
end

------------------------------------------------------------------------
-- Free Slot
------------------------------------------------------------------------

local freeSlotContainerTypes = { Bag = "Bag", Bank = "Bank", BagReagent = "BagReagent", Account = "BankAccount" }

local function getFirstFreeSlot(name)
    local containerIDs
    if name == "Bag" then
        containerIDs = { 0, 1, 2, 3, 4 }
    elseif name == "BagReagent" then
        containerIDs = { 5 }
    elseif name == "Bank" then
        containerIDs = { 6, 7, 8, 9, 10, 11 }
    elseif name == "BankAccount" then
        containerIDs = { 12, 13, 14, 15, 16 }
    end
    if not containerIDs then
        return false
    end

    for _, i in next, containerIDs do
        local t = C_Container_GetContainerNumFreeSlots(i)
        if t > 0 then
            local numSlots = C_Container_GetContainerNumSlots(i)
            for j = 1, numSlots do
                if not C_Container_GetContainerItemLink(i, j) then
                    return i, j
                end
            end
        end
    end
    return false
end

------------------------------------------------------------------------
-- Container: OnCreate
------------------------------------------------------------------------

function module:SetupContainerClass(MyContainer, impl)
    function MyContainer:OnCreate(name, settings)
        self.Settings = settings or {}
        self.name = name
        self:SetFrameStrata("HIGH")
        self:SetClampedToScreen(true)
        self.iconSize = iconSize

        -- Main panels have settings.Bags
        if settings and settings.Bags then
            self:SetupMainPanel(name, settings, impl)
        else
            self:SetupSubContainer(name, settings)
        end
    end

    function MyContainer:SetupSubContainer(name, settings)
        -- Sub-container: label only, no background (covered by main panel's unified bg)
        -- Enable drag to move parent (main panel)
        self:EnableMouse(true)
        self:RegisterForDrag("LeftButton")
        self:SetScript("OnDragStart", function(s)
            local parent = s:GetParent()
            if parent and parent.StartMoving then
                parent:StartMoving()
            end
        end)
        self:SetScript("OnDragStop", function(s)
            local parent = s:GetParent()
            if parent and parent.StopMovingOrSizing then
                parent:StopMovingOrSizing()
            end
        end)

        local label
        if strmatch(name, "Custom%d") then
            label = getCustomGroupTitle(settings and settings.Index or 0)
        else
            label = containerLabels[name]
        end

        if label then
            self.label = self:CreateFontString(nil, "OVERLAY")
            self.label:SetFont(unpack(FONT_STANDARD))
            self.label:SetPoint("TOPLEFT", 5, -8)
            self.label:SetText(label)
            self.label:SetTextColor(1, 0.82, 0)
        end

        -- FreeSlot for reagent container
        if name == "BagReagent" then
            self:CreateFreeSlotButton("BagReagent")
        end
    end

    function MyContainer:SetupMainPanel(name, settings, backpack)
        -- Unified background frame (covers main panel + all sub-containers above)
        local bgFrame = CreateFrame("Frame", nil, self)
        bgFrame:SetFrameStrata("HIGH")
        bgFrame:SetFrameLevel(0)
        bgFrame:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", -4, -4)
        bgFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 4, -4)
        bgFrame:SetPoint("TOPLEFT", self, "TOPLEFT", -4, 4)
        bgFrame:SetPoint("TOPRIGHT", self, "TOPRIGHT", 4, 4)
        E:StyleFrame(bgFrame, false)
        self.bgFrame = bgFrame

        -- Caption (top-left label)
        local captionText = (name == "Bag") and INVENTORY_TOOLTIP
            or (name == "Bank") and BANK
            or (name == "Account") and ACCOUNT_BANK_PANEL_TITLE
            or name
        local caption = self:CreateFontString(nil, "OVERLAY")
        caption:SetFont(unpack(FONT_STANDARD))
        caption:SetText(captionText)
        caption:SetPoint("TOPLEFT", 7.5, -7.5)
        self.Caption = caption

        -- Movable
        self:EnableMouse(true)
        self:SetMovable(true)
        self:SetUserPlaced(true)
        self:RegisterForDrag("LeftButton")
        self:SetScript("OnDragStart", self.StartMoving)
        self:SetScript("OnDragStop", function(f)
            f:StopMovingOrSizing()
            local point, _, relPoint, x, y = f:GetPoint()
            x = E:Round(x or 0)
            y = E:Round(y or 0)
            DB:SetStats("cBniv." .. name .. "Pos", { point, "UIParent", relPoint, x, y }, true)
        end)

        -- Close button (top-right)
        self.closeBtn = createIconButton("Close", self, "Interface\\RAIDFRAME\\ReadyCheck-NotReady", "")
        self.closeBtn:SetSize(16, 16)
        self.closeBtn.icon:ClearAllPoints()
        self.closeBtn.icon:SetAllPoints()
        self.closeBtn:SetPoint("TOPRIGHT", self, "TOPRIGHT", -2, -2)
        self.closeBtn:SetScript("OnClick", function()
            if backpack:AtBank() then
                C_Bank.CloseBankFrame()
            else
                CloseAllBags()
            end
        end)

        -- Function buttons (bottom-right, right to left)
        local buttons = {}

        local bagToggle = createIconButton("Bags", self, Textures.BagToggle, L.BAG_HINT_TOGGLE)
        bagToggle:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
        buttons[#buttons + 1] = bagToggle
        local lastBtn = bagToggle

        if name == "Bag" and cfg.showNewItem then
            local resetBtn = createIconButton("ResetNew", self, Textures.ResetNew, L.BAG_HINT_RESET_NEW)
            resetBtn:SetPoint("BOTTOMRIGHT", lastBtn, "BOTTOMLEFT", 0, 0)
            resetBtn:SetScript("OnClick", function()
                module:ResetNewItems()
            end)
            buttons[#buttons + 1] = resetBtn
            lastBtn = resetBtn
        end

        local sortBtn = createIconButton("Sort", self, Textures.Restack, L.BAG_HINT_RESTACK)
        sortBtn:SetPoint("BOTTOMRIGHT", lastBtn, "BOTTOMLEFT", 0, 0)
        sortBtn:SetScript("OnClick", function()
            if cfg.sortMode == 3 then
                return
            end
            if name == "Bank" then
                C_Container.SortBankBags()
            elseif name == "Account" then
                if C_Container.SortAccountBankBags then
                    C_Container.SortAccountBankBags()
                end
            else
                C_Container.SortBags()
            end
        end)
        buttons[#buttons + 1] = sortBtn
        lastBtn = sortBtn

        if name == "Bank" or name == "Account" then
            local depositBtn = createIconButton("Deposit", self, Textures.Deposit, L.BAG_HINT_DEPOSIT)
            depositBtn:SetPoint("BOTTOMRIGHT", lastBtn, "BOTTOMLEFT", 0, 0)
            depositBtn:SetScript("OnClick", function()
                if name == "Account" then
                    C_Bank.AutoDepositItemsIntoBank(ACCOUNT_BANK_TYPE)
                else
                    C_Bank.AutoDepositItemsIntoBank(CHAR_BANK_TYPE)
                end
            end)
            buttons[#buttons + 1] = depositBtn
            lastBtn = depositBtn
        end

        self.widgetButtons = buttons

        -- Bag bar
        local bagSettings = settings.Bags
        local bagColumns = (name == "Bag") and 5 or (name == "Bank") and 6 or 5
        local bagBar = self:SpawnPlugin("BagBar", bagSettings)
        bagBar:SetSize(bagBar:LayoutButtons("grid", bagColumns))
        bagBar.highlightFunction = highlightFunction
        bagBar.isGlobal = true
        bagBar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, (name == "Bag") and 32 or 20)
        bagBar:Hide()
        self.BagBar = bagBar

        bagToggle:SetScript("OnClick", function()
            if self.BagBar:IsShown() then
                self.BagBar:Hide()
            else
                self.BagBar:Show()
            end
        end)

        -- Warband bag bar (account bank)
        if name == "Account" then
            local warbandBar = self:SpawnPlugin("BagWarband", "accountbank")
            warbandBar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 2)
            warbandBar:SetSize(warbandBar:LayoutButtons("grid", 5))
            warbandBar.highlightFunction = highlightFunction
            self.BagBar = warbandBar
        end

        -- Search bar (bag only, bottom-left)
        if name == "Bag" then
            local infoFrame = CreateFrame("Button", nil, self)
            infoFrame:SetPoint("BOTTOMLEFT", 5, -6)
            infoFrame:SetPoint("BOTTOMRIGHT", -86, -6)
            infoFrame:SetHeight(32)

            local searchIcon = self:CreateTexture(nil, "ARTWORK")
            searchIcon:SetTexture(Textures.Search)
            searchIcon:SetVertexColor(0.8, 0.8, 0.8)
            searchIcon:SetPoint("BOTTOMLEFT", infoFrame, "BOTTOMLEFT", -3, 8)
            searchIcon:SetSize(16, 16)

            local search = self:SpawnPlugin("SearchBar", infoFrame)
            search.isGlobal = true
            search.highlightFunction = highlightFunction
        end

        -- Money display (top-right)
        if name == "Bag" then
            local money = self:SpawnPlugin("TagDisplay", "[money]", self)
            money:SetPoint("TOPRIGHT", self, -32, -2)
            money:SetFont(unpack(FONT_STANDARD))
            money:SetJustifyH("RIGHT")
            money:SetShadowColor(0, 0, 0, 0)
        end

        -- Free slot
        self:CreateFreeSlotButton(name)
    end

    function MyContainer:CreateFreeSlotButton(name)
        local tagName = freeSlotContainerTypes[name]
        if not tagName then
            return
        end

        local slot = CreateFrame("Button", self:GetName() .. "FreeSlot", self, "BackdropTemplate")
        slot:SetSize(iconSize, iconSize)
        slot:SetHighlightTexture("Interface\\ChatFrame\\ChatFrameBackground")
        slot:GetHighlightTexture():SetVertexColor(1, 1, 1, 0.25)
        slot:GetHighlightTexture():SetInside()
        slot:SetBackdrop({ bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
        slot:SetBackdropColor(0.3, 0.3, 0.3, 0.3)
        slot:SetBackdropBorderColor(0, 0, 0, 1)
        slot.__name = tagName
        slot:SetScript("OnMouseUp", function(s)
            local bagID, slotID = getFirstFreeSlot(s.__name)
            if slotID then
                C_Container_PickupContainerItem(bagID, slotID)
            end
        end)
        slot:SetScript("OnReceiveDrag", function(s)
            local bagID, slotID = getFirstFreeSlot(s.__name)
            if slotID then
                C_Container_PickupContainerItem(bagID, slotID)
            end
        end)

        local tag = self:SpawnPlugin("TagDisplay", "[space]", slot)
        tag:SetFont(STANDARD_TEXT_FONT, fontSize + 2, "OUTLINE")
        tag:SetTextColor(0.6, 0.8, 1)
        tag:SetPoint("CENTER", 1, 0)
        tag.__type = tagName
        slot.tag = tag

        self.freeSlot = slot
    end

    -----------------------------------------------------------------------
    -- Container: OnContentsChanged
    -----------------------------------------------------------------------

    function MyContainer:OnContentsChanged()
        self:SortButtons("bagSlot")

        local bagType = self.Settings.BagType or "Bag"
        local columns = module:GetContainerColumns(bagType)
        local offset = self.Settings.Bags and HEADER_HEIGHT or (self.label and 32 or 4)
        local xOffset = 5
        local yOffset = -offset + xOffset

        local _, height = self:LayoutButtons("grid", columns, SPACING, xOffset, yOffset)

        -- Free slot positioning
        if self.freeSlot then
            if cfg.gatherEmpty then
                local numSlots = #self.buttons + 1
                local row = ceil(numSlots / columns)
                local col = numSlots % columns
                if col == 0 then
                    col = columns
                end

                local xPos = (col - 1) * (iconSize + SPACING)
                local yPos = -1 * (row - 1) * (iconSize + SPACING)

                self.freeSlot:ClearAllPoints()
                self.freeSlot:SetPoint("TOPLEFT", self, "TOPLEFT", xPos + xOffset, yPos + yOffset)
                self.freeSlot:Show()

                if height < 0 then
                    height = iconSize
                elseif col == 1 then
                    height = height + iconSize + SPACING
                end
            else
                self.freeSlot:Hide()
            end
        end

        local width = columns * (iconSize + SPACING) - SPACING
        local footer = self.Settings.Bags and FOOTER_HEIGHT or 0
        self:SetSize(width + xOffset * 2, height + offset + footer)

        module:UpdateAllAnchors()
    end
end

------------------------------------------------------------------------
-- Item Button Style
------------------------------------------------------------------------

function module:SetupItemButtonClass(MyButton)
    function MyButton:OnCreate()
        self:SetNormalTexture(0)
        self:SetPushedTexture(0)
        self:SetHighlightTexture("Interface\\ChatFrame\\ChatFrameBackground")
        self:GetHighlightTexture():SetVertexColor(1, 1, 1, 0.25)
        self:GetHighlightTexture():SetInside()
        self:SetSize(iconSize, iconSize)

        self:CreateBackdrop("default", 0)
        self.__backdrop:SetBackdropColor(0.3, 0.3, 0.3, 0.3)

        self.Icon:SetInside()
        self.Icon:SetTexCoord(unpack(C.media.texCoord))

        self.Count:SetPoint("BOTTOMRIGHT", -1, 2)
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
        self.QuestIcon:SetSize(14, iconSize / 2)
        self.QuestIcon:SetPoint("TOPRIGHT", -1, -1)

        self.iLvl = self:CreateFontString(nil, "OVERLAY")
        self.iLvl:SetJustifyH("LEFT")
        self.iLvl:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 1, 2)
        self.iLvl:SetFont(unpack(C.media.standard_font))

        self.durability = self:CreateFontString(nil, "OVERLAY")
        self.durability:SetJustifyH("LEFT")
        self.durability:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -1)
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

    local function getIconOverlayAtlas(item)
        if not item.link then
            return
        end
        if C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(item.link) then
            return "AzeriteIconFrame"
        elseif IsCosmeticItem and IsCosmeticItem(item.link) then
            return "CosmeticIconFrame"
        end
    end

    local function itemColorGradient(perc, ...)
        if perc >= 1 then
            return select(select("#", ...) - 2, ...)
        end
        if perc <= 0 then
            return ...
        end
        local num = select("#", ...) / 3
        local segment, relperc = math.modf(perc * (num - 1))
        local r1, g1, b1, r2, g2, b2 = select((segment * 3) + 1, ...)
        return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
    end

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

        -- Item level
        self.iLvl:SetText("")
        if cfg.showItemLevel and item.ilvl and item.quality and item.quality > 1 then
            local color = C.media.qualityColors[item.quality]
            if color then
                self.iLvl:SetText(item.ilvl)
                self.iLvl:SetTextColor(color.r, color.g, color.b)
            end
        end

        -- Durability
        local dCur, dMax = C_Container_GetContainerItemDurability(item.bagId, item.slotId)
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

        -- CanIMogIt
        if self.canIMogIt then
            local text, unmodifiedText = CanIMogIt:GetTooltipText(nil, item.bagId, item.slotId)
            if text and text ~= "" then
                self.canIMogIt:SetTexture(CanIMogIt.tooltipOverlayIcons[unmodifiedText])
                self.canIMogIt:Show()
            else
                self.canIMogIt:Hide()
            end
        end

        -- Pawn
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
            if color then
                self.__backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
            else
                self.__backdrop:SetBackdropBorderColor(0, 0, 0)
            end
        else
            self.__backdrop:SetBackdropBorderColor(0, 0, 0)
        end
    end
end

------------------------------------------------------------------------
-- Bag Button Style
------------------------------------------------------------------------

function module:SetupBagButtonClass(impl)
    local BagButton = impl:GetBagButtonClass()

    function BagButton:OnCreate()
        self:SetNormalTexture(0)
        self:SetPushedTexture(0)
        self:SetHighlightTexture("Interface\\ChatFrame\\ChatFrameBackground")
        self:GetHighlightTexture():SetVertexColor(1, 1, 1, 0.25)
        self:GetHighlightTexture():SetInside()
        self:SetSize(iconSize, iconSize)
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
end
