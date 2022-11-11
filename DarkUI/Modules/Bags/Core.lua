local _, ns = ...
local E, C, L = ns:unpack()
local cargBags = ns.cargBags

if not C.bags.enable then return end

----------------------------------------------------------------------------------------
--    Core of Bags (modified from cargBags_Nivaya of RealUI)
----------------------------------------------------------------------------------------

-- Lua Globals --
-- luacheck: globals next ipairs
local _G = _G
local BackdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil

local cargBags_Nivaya = _G.CreateFrame("Frame", "cargBags_Nivaya", _G.UIParent)
cargBags_Nivaya:SetScript("OnEvent", function(self, event, ...) self[event](self, event, ...) end)
cargBags_Nivaya:RegisterEvent("ADDON_LOADED")

local cbNivaya = cargBags:GetImplementation("Nivaya")
--cbNivCatDropDown = CreateFrame("Frame", "cbNivCatDropDown", UIParent, "UIDropDownMenuTemplate")

do    --Replacement for UIDropDownMenu
    local frameHeight = 14
    local defaultWidth = 120
    local frameInset = 16

    local f = cbNivCatDropDown or CreateFrame("Frame", "cbNivCatDropDown", UIParent, BackdropTemplate)
    f.ActiveButtons = 0
    f.Buttons = {}

    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:SetSize(defaultWidth+frameInset, 32)
    f:SetClampedToScreen(true)
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:SetSize(defaultWidth + frameInset, 32)
    f:SetClampedToScreen(true)
    f:SetTemplate("Blur")
    f:CreateShadow()

    function f:CreateButton()
        local button = CreateFrame("Button", nil, self)
        button:SetWidth(defaultWidth)
        button:SetHeight(frameHeight)

        local fstr = button:CreateFontString()
        fstr:SetJustifyH("LEFT")
        fstr:SetJustifyV("MIDDLE")
        fstr:SetFontObject("SystemFont_Outline_Small")
        fstr:SetPoint("LEFT", button, "LEFT", 0, 0)
        button.Text = fstr

        function button:SetText(str)
            button.Text:SetText(str)
        end

        button:SetText("test")

        local ntex = button:CreateTexture()
        ntex:SetColorTexture(1, 1, 1, 0)
        ntex:SetAllPoints()
        button:SetNormalTexture(ntex)

        local htex = button:CreateTexture()
        htex:SetColorTexture(1, 1, 1, 0.2)
        htex:SetAllPoints()
        button:SetHighlightTexture(htex)

        local ptex = button:CreateTexture()
        ptex:SetColorTexture(1, 1, 1, 0.4)
        ptex:SetAllPoints()
        button:SetPushedTexture(ptex)

        return button
    end

    function f:AddButton(text, value, func)
        local bID = self.ActiveButtons + 1

        local btn = self.Buttons[bID] or self:CreateButton()

        btn:SetText(text or "")
        btn.value = value
        btn.func = func or function() end

        btn:SetScript("OnClick", function(self, ...) self:func(...) self:GetParent():Hide() end)

        btn:ClearAllPoints()
        if bID == 1 then
            btn:SetPoint("TOP", self, "TOP", 0, -(frameInset/2))
        else
            btn:SetPoint("TOP", self.Buttons[bID-1], "BOTTOM", 0, 0)
        end

        self.Buttons[bID] = btn
        self.ActiveButtons = bID

        self:UpdateSize()
    end

    function f:UpdatePosition(frame, point, relativepoint, ofsX, ofsY)
        point, relativepoint, ofsX, ofsY = point or "TOPLEFT", relativepoint or "BOTTOMLEFT", ofsX or 0, ofsY or 0

        self:ClearAllPoints()
        self:SetPoint(point, frame, relativepoint, ofsX, ofsY)
    end

    function f:UpdateSize()
        local maxButtons = self.ActiveButtons
        local maxwidth = defaultWidth

        for i = 1, maxButtons do
            local width = self.Buttons[i].Text:GetWidth()
            if width > maxwidth then maxwidth = width end
        
        end

        for i = 1, maxButtons do
            self.Buttons[i]:SetWidth(maxwidth)
        end

        local height = maxButtons * frameHeight

        self:SetSize(maxwidth + frameInset, height + frameInset)
    end

    function f:Toggle(frame, point, relativepoint, ofsX, ofsY)
        self:UpdatePosition(frame, point, relativepoint, ofsX, ofsY)
        self:Show()
    end

    tinsert(UISpecialFrames,f:GetName())
end

---------------------------------------------
---------------------------------------------
local L = L
cB_Bags = {}
cB_BagHidden = {}
cB_CustomBags = {}

-- Those are default values only
local optDefaults = {
    scale          = 1,
    NewItems       = true,
    Restack        = true,
    TradeGoods     = true,
    Armor          = true,
    Gem            = true,
    CoolStuff      = false,
    Junk           = true,
    ItemSets       = true,
    Consumables    = true,
    Quest          = true,
    FilterBank     = true,
    CompressEmpty  = true,
    Unlocked       = true,
    SortBags       = true,
    SortBank       = true,
    BankCustomBags = true,
    BagPos         = {"BOTTOMRIGHT", -99, 26},
    BankPos        = {"TOPLEFT", 20, -20}
}

-- Those are internal settings, don't touch them at all:
local defaults = {}

local ItemSetCaption = (IsAddOnLoaded('ItemRack') and "ItemRack ") or (IsAddOnLoaded('Outfitter') and "Outfitter ") or "Item "
local bankOpenState = false
function cbNivaya:ShowBags(...)
    local bags = {...}
    for i = 1, #bags do
        local bag = bags[i]
        if not cB_BagHidden[bag.name] then
            bag:Show()
        end
    end
end
function cbNivaya:HideBags(...)
    local bags = {...}
    for i = 1, #bags do
        local bag = bags[i]
        bag:Hide()
    end
end

local LoadDefaults = function()
    -- Global saved vars
    if not _G.SavedStats.cB_CustomBags then _G.SavedStats.cB_CustomBags = {} end
    if not _G.SavedStats.cBniv_CatInfo then _G.SavedStats.cBniv_CatInfo = {} end
    if not _G.SavedStats.cBnivCfg then _G.SavedStats.cBnivCfg = {} end

    for k, v in pairs(optDefaults) do
        if _G.type(_G.SavedStats.cBnivCfg[k]) == "nil" then _G.SavedStats.cBnivCfg[k] = v end
    end

    -- Character saved vars
    if not _G.SavedStatsPerChar.cB_KnownItems then _G.SavedStatsPerChar.cB_KnownItems = {} end
    if not _G.SavedStatsPerChar.cBniv then _G.SavedStatsPerChar.cBniv = {} end

    for k, v in pairs(defaults) do
        if _G.type(_G.SavedStatsPerChar.cBniv[k]) == "nil" then _G.SavedStatsPerChar.cBniv[k] = v end
    end

    cBniv = _G.SavedStatsPerChar.cBniv
    cBnivCfg = _G.SavedStats.cBnivCfg
    cB_CustomBags = _G.SavedStats.cB_CustomBags
end

function cargBags_Nivaya:ADDON_LOADED(event, addon)
    if (addon ~= E.addonName) then return end
    self:UnregisterEvent(event)
    
    LoadDefaults()
    
    cB_filterEnabled["Armor"] = cBnivCfg.Armor
    cB_filterEnabled["Gem"] = cBnivCfg.Gem
    cB_filterEnabled["TradeGoods"] = cBnivCfg.TradeGoods
    cB_filterEnabled["Junk"] = cBnivCfg.Junk
    cB_filterEnabled["ItemSets"] = cBnivCfg.ItemSets
    cB_filterEnabled["Consumables"] = cBnivCfg.Consumables
    cB_filterEnabled["Quest"] = cBnivCfg.Quest
    cBniv.BankCustomBags = cBnivCfg.BankCustomBags
    cBniv.BagPos = true

    -----------------
    -- Frame Spawns
    -----------------
    local C = cbNivaya:GetContainerClass()

    -- bank bags
    cB_Bags.bankSets        = C:New("cBniv_BankSets")

    if cBniv.BankCustomBags then
        for _,v in ipairs(cB_CustomBags) do 
            cB_Bags['Bank'..v.name] = C:New('Bank'..v.name) 
            cB_existsBankBag[v.name] = true
        end
    end

    cB_Bags.bankArmor           = C:New("cBniv_BankArmor")
    cB_Bags.bankGem             = C:New("cBniv_BankGem")
    cB_Bags.bankConsumables     = C:New("cBniv_BankCons")
    cB_Bags.bankArtifactPower   = C:New("cBniv_BankArtifactPower")
    cB_Bags.bankBattlePet       = C:New("cBniv_BankPet")
    cB_Bags.bankQuest           = C:New("cBniv_BankQuest")
    cB_Bags.bankTrade           = C:New("cBniv_BankTrade")
    cB_Bags.bankReagent         = C:New("cBniv_BankReagent")
    cB_Bags.bank                = C:New("cBniv_Bank")

    cB_Bags.bankSets            :SetMultipleFilters(true, cB_Filters.fBank, cB_Filters.fBankFilter, cB_Filters.fItemSets)
    cB_Bags.bankArmor           :SetExtendedFilter(cB_Filters.fItemClass, "BankArmor")
    cB_Bags.bankGem             :SetExtendedFilter(cB_Filters.fItemClass, "BankGem")
    cB_Bags.bankConsumables     :SetExtendedFilter(cB_Filters.fItemClass, "BankConsumables")
    cB_Bags.bankArtifactPower   :SetExtendedFilter(cB_Filters.fItemClass, "BankArtifactPower")
    cB_Bags.bankBattlePet       :SetExtendedFilter(cB_Filters.fItemClass, "BankBattlePet")
    cB_Bags.bankQuest           :SetExtendedFilter(cB_Filters.fItemClass, "BankQuest")
    cB_Bags.bankTrade           :SetExtendedFilter(cB_Filters.fItemClass, "BankTradeGoods")
    cB_Bags.bankReagent         :SetMultipleFilters(true, cB_Filters.fBankReagent, cB_Filters.fHideEmpty)
    cB_Bags.bank                :SetMultipleFilters(true, cB_Filters.fBank, cB_Filters.fHideEmpty)
    if cBniv.BankCustomBags then
        for _,v in ipairs(cB_CustomBags) do cB_Bags['Bank'..v.name]:SetExtendedFilter(cB_Filters.fItemClass, 'Bank'..v.name) end
    end

    -- inventory bags
    cB_Bags.key            = C:New("cBniv_Keyring")
    cB_Bags.bagItemSets    = C:New("cBniv_ItemSets")
    cB_Bags.bagStuff       = C:New("cBniv_Stuff")

    for _,v in ipairs(cB_CustomBags) do 
        if (v.prio > 0) then 
            cB_Bags[v.name] = C:New(v.name, { isCustomBag = true } )
            v.active = true
            cB_filterEnabled[v.name] = true
        end
    end

    cB_Bags.bagJunk        = C:New("cBniv_Junk")
    cB_Bags.bagNew         = C:New("cBniv_NewItems")

    for _,v in ipairs(cB_CustomBags) do 
        if (v.prio <= 0) then 
            cB_Bags[v.name] = C:New(v.name, { isCustomBag = true } )
            v.active = true
            cB_filterEnabled[v.name] = true
        end
    end

    cB_Bags.armor           = C:New("cBniv_Armor")
    cB_Bags.gem             = C:New("cBniv_Gem")
    cB_Bags.quest           = C:New("cBniv_Quest")
    cB_Bags.consumables     = C:New("cBniv_Consumables")
    cB_Bags.artifactpower   = C:New("cBniv_ArtifactPower")
    cB_Bags.battlepet       = C:New("cBniv_BattlePet")
    cB_Bags.tradegoods      = C:New("cBniv_TradeGoods")
    cB_Bags.main            = C:New("cBniv_Bag")

    cB_Bags.key             :SetExtendedFilter(cB_Filters.fItemClass, "Keyring")
    cB_Bags.bagItemSets     :SetFilter(cB_Filters.fItemSets, true)
    cB_Bags.bagStuff        :SetExtendedFilter(cB_Filters.fItemClass, "Stuff")
    cB_Bags.bagJunk         :SetExtendedFilter(cB_Filters.fItemClass, "Junk")
    cB_Bags.bagNew          :SetFilter(cB_Filters.fNewItems, true)
    cB_Bags.armor           :SetExtendedFilter(cB_Filters.fItemClass, "Armor")
    cB_Bags.gem             :SetExtendedFilter(cB_Filters.fItemClass, "Gem")
    cB_Bags.quest           :SetExtendedFilter(cB_Filters.fItemClass, "Quest")
    cB_Bags.consumables     :SetExtendedFilter(cB_Filters.fItemClass, "Consumables")
    cB_Bags.artifactpower   :SetExtendedFilter(cB_Filters.fItemClass, "ArtifactPower")
    cB_Bags.battlepet       :SetExtendedFilter(cB_Filters.fItemClass, "BattlePet")
    cB_Bags.tradegoods      :SetExtendedFilter(cB_Filters.fItemClass, "TradeGoods")
    cB_Bags.main            :SetMultipleFilters(true, cB_Filters.fBags, cB_Filters.fHideEmpty)
    for _,v in pairs(cB_CustomBags) do cB_Bags[v.name]:SetExtendedFilter(cB_Filters.fItemClass, v.name) end

    cB_Bags.main:SetPoint(unpack(cBnivCfg.BagPos))
    cB_Bags.bank:SetPoint(unpack(cBnivCfg.BankPos))

    cbNivaya:CreateAnchors()
    cbNivaya:Init()
    cbNivaya:ToggleBagPosButtons()
end

function cbNivaya:CreateAnchors()
-----------------------------------------------
-- Store the anchoring order:
-- read: "tar" is anchored to "src" in the direction denoted by "dir".
-----------------------------------------------
local function CreateAnchorInfo(src, tar, dir)
    tar.AnchorTo = src
    tar.AnchorDir = dir
    if src then
        if not src.AnchorTargets then src.AnchorTargets = {} end
        src.AnchorTargets[tar] = true
    end
end

    -- neccessary if this function is used to update the anchors:
    for k,_ in pairs(cB_Bags) do
        if not ((k == 'main') or (k == 'bank')) then cB_Bags[k]:ClearAllPoints() end
        cB_Bags[k].AnchorTo = nil
        cB_Bags[k].AnchorDir = nil
        cB_Bags[k].AnchorTargets = nil
    end

    -- Main Anchors:
    CreateAnchorInfo(nil, cB_Bags.main, "Bottom")
    CreateAnchorInfo(nil, cB_Bags.bank, "Bottom")

    -- Bank Anchors:
    CreateAnchorInfo(cB_Bags.bank, cB_Bags.bankArmor, "Right")
    CreateAnchorInfo(cB_Bags.bankArmor, cB_Bags.bankSets, "Bottom")
    CreateAnchorInfo(cB_Bags.bankSets, cB_Bags.bankGem, "Bottom")
    CreateAnchorInfo(cB_Bags.bankGem, cB_Bags.bankTrade, "Bottom")

    CreateAnchorInfo(cB_Bags.bank, cB_Bags.bankReagent, "Bottom")
    CreateAnchorInfo(cB_Bags.bankReagent, cB_Bags.bankConsumables, "Bottom")
    CreateAnchorInfo(cB_Bags.bankConsumables, cB_Bags.bankQuest, "Bottom")
    CreateAnchorInfo(cB_Bags.bankQuest, cB_Bags.bankArtifactPower, "Bottom")
    CreateAnchorInfo(cB_Bags.bankArtifactPower, cB_Bags.bankBattlePet, "Bottom")
    -- Bank Custom Container Anchors:
    if cBniv.BankCustomBags then
        local ref = { [0] = 0, [1] = 0 }
        for _,v in ipairs(cB_CustomBags) do
            if v.active then
                local c = v.col
                if ref[c] == 0 then ref[c] = (c == 0) and cB_Bags.bankBattlePet or cB_Bags.bankTrade end
                CreateAnchorInfo(ref[c], cB_Bags['Bank'..v.name], "Bottom")
                ref[c] = cB_Bags['Bank'..v.name]
            end
        end
    end

    -- Bag Anchors:
    CreateAnchorInfo(cB_Bags.main,             cB_Bags.key,             "Bottom")

    CreateAnchorInfo(cB_Bags.main,             cB_Bags.bagItemSets,     "Left")
    CreateAnchorInfo(cB_Bags.bagItemSets,      cB_Bags.armor,           "Top")
    CreateAnchorInfo(cB_Bags.armor,            cB_Bags.gem,             "Top")
    CreateAnchorInfo(cB_Bags.gem,              cB_Bags.artifactpower,   "Top")
    CreateAnchorInfo(cB_Bags.artifactpower,    cB_Bags.battlepet,       "Top")
    CreateAnchorInfo(cB_Bags.battlepet,        cB_Bags.bagStuff,        "Top")
    CreateAnchorInfo(cB_Bags.main,             cB_Bags.tradegoods,      "Top")
    CreateAnchorInfo(cB_Bags.tradegoods,       cB_Bags.consumables,     "Top")
    CreateAnchorInfo(cB_Bags.consumables,      cB_Bags.quest,           "Top")
    CreateAnchorInfo(cB_Bags.quest,            cB_Bags.bagJunk,         "Top")
    CreateAnchorInfo(cB_Bags.bagJunk,          cB_Bags.bagNew,          "Top")

    -- Custom Container Anchors:
    local ref = { [0] = 0, [1] = 0 }
    for _,v in ipairs(cB_CustomBags) do
        if v.active then
            local c = v.col
            if ref[c] == 0 then ref[c] = (c == 0) and cB_Bags.bagStuff or cB_Bags.bagNew end

            CreateAnchorInfo(ref[c], cB_Bags[v.name], "Top")
            ref[c] = cB_Bags[v.name]
        end
    end

    -- Finally update all anchors:
    for _,v in pairs(cB_Bags) do cbNivaya:UpdateAnchors(v) end
end

function cbNivaya:UpdateAnchors(self)
    if not self.AnchorTargets then return end
    for v,_ in pairs(self.AnchorTargets) do
        local t, u = v.AnchorTo, v.AnchorDir
        if t then
            local h = cB_BagHidden[t.name]
            v:ClearAllPoints()

            if    not h        and u == "Top"        then v:SetPoint("BOTTOM", t, "TOP", 0, 9)
            elseif    h        and u == "Top"        then v:SetPoint("BOTTOM", t, "BOTTOM")
            elseif    not h    and u == "Bottom"    then v:SetPoint("TOP", t, "BOTTOM", 0, -9)
            elseif    h        and u == "Bottom"    then v:SetPoint("TOP", t, "TOP")
            elseif    u == "Left"                    then v:SetPoint("BOTTOMRIGHT", t, "BOTTOMLEFT", -9, 0)
            elseif    u == "Right"                then v:SetPoint("TOPLEFT", t, "TOPRIGHT", 9, 0) end
            end
        end
end

function cbNivaya:OnOpen()
    cB_Bags.main:Show()
    cbNivaya:ShowBags(cB_Bags.armor, cB_Bags.bagNew, cB_Bags.bagItemSets, cB_Bags.gem, cB_Bags.quest, cB_Bags.consumables, cB_Bags.artifactpower, cB_Bags.battlepet, 
                      cB_Bags.tradegoods, cB_Bags.bagStuff, cB_Bags.bagJunk)
    for _,v in ipairs(cB_CustomBags) do if v.active then cbNivaya:ShowBags(cB_Bags[v.name]) end end
end

function cbNivaya:OnClose()
    cbNivaya:HideBags(cB_Bags.main, cB_Bags.armor, cB_Bags.bagNew, cB_Bags.bagItemSets, cB_Bags.gem, cB_Bags.quest, cB_Bags.consumables, cB_Bags.artifactpower, cB_Bags.battlepet, 
                      cB_Bags.tradegoods, cB_Bags.bagStuff, cB_Bags.bagJunk, cB_Bags.key)
    for _,v in ipairs(cB_CustomBags) do if v.active then cbNivaya:HideBags(cB_Bags[v.name]) end end
end

function cbNivaya:OnBankOpened()
    cB_Bags.bank:Show()

    cbNivaya:ShowBags(cB_Bags.bankSets, cB_Bags.bankReagent, cB_Bags.bankArmor, cB_Bags.bankGem, cB_Bags.bankQuest, cB_Bags.bankTrade, cB_Bags.bankConsumables, cB_Bags.bankArtifactPower, cB_Bags.bankBattlePet)
    if cBniv.BankCustomBags then
        for _,v in ipairs(cB_CustomBags) do if v.active then cbNivaya:ShowBags(cB_Bags['Bank'..v.name]) end end
    end
end

function cbNivaya:OnBankClosed()
    cbNivaya:HideBags(cB_Bags.bank, cB_Bags.bankSets, cB_Bags.bankReagent, cB_Bags.bankArmor, cB_Bags.bankGem, cB_Bags.bankQuest, cB_Bags.bankTrade, cB_Bags.bankConsumables, cB_Bags.bankArtifactPower, cB_Bags.bankBattlePet)    
    
    if cBniv.BankCustomBags then
        for _,v in ipairs(cB_CustomBags) do if v.active then cbNivaya:HideBags(cB_Bags['Bank'..v.name]) end end
    end
end

function cbNivaya:ToggleBagPosButtons()
    for _,v in ipairs(cB_CustomBags) do 
        if v.active then 
            local b = cB_Bags[v.name]
            if cBniv.BagPos then
                b.rightBtn:Hide()
                b.leftBtn:Hide()
                b.downBtn:Hide()
                b.upBtn:Hide()
            else
                b.rightBtn:Show()
                b.leftBtn:Show()
                b.downBtn:Show()
                b.upBtn:Show()
            end
        end
    end
    cBniv.BagPos = not cBniv.BagPos
end

local buttonCollector = {}
local Event = _G.CreateFrame('Frame', nil)
Event:RegisterEvent("PLAYER_ENTERING_WORLD")
Event:SetScript('OnEvent', function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        for bagId = -3, 11 do
            local slots = GetContainerNumSlots(bagId)
            for slotId = 1, slots do
                local button = cbNivaya.buttonClass:New(bagId, slotId)
                buttonCollector[#buttonCollector + 1] = button
                cbNivaya:SetButton(bagId, slotId, nil)
            end
        end
        for i,button in pairs(buttonCollector) do
            if button.container then
                button.container:RemoveButton(button)
            end
            button:Free()
        end
        cbNivaya:UpdateBags()

        if _G.IsReagentBankUnlocked() then
            NivayacBniv_Bank.reagentBtn:Show()
        else
            NivayacBniv_Bank.reagentBtn:Hide()
            local buyReagent = CreateFrame("Button", nil, NivayacBniv_BankReagent, "UIPanelButtonTemplate")
            buyReagent:SetText(BANKSLOTPURCHASE)
            buyReagent:SetWidth(buyReagent:GetTextWidth() + 20)
                buyReagent:SetPoint("CENTER", NivayacBniv_BankReagent, 0, 0)
                buyReagent:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:AddLine(REAGENT_BANK_HELP, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            buyReagent:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
            buyReagent:SetScript("OnClick", function()
                --print("Reagent Bank!!!")
                StaticPopup_Show("CONFIRM_BUY_REAGENTBANK_TAB")
            end)
            buyReagent:SetScript("OnEvent", function(...)
                --print("OnReagentPurchase", ...)
                buyReagent:UnregisterEvent("REAGENTBANK_PURCHASED")
                NivayacBniv_Bank.reagentBtn:Show()
                buyReagent:Hide()
            end)

            if Aurora then
                local F = Aurora[1]
                F.Reskin(buyReagent)
            end
            buyReagent:RegisterEvent("REAGENTBANK_PURCHASED")
        end

        cbNivResetNew()
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end)

function cargBags_Nivaya:ResetItemClass()
    for k,v in pairs(cB_ItemClass) do
        if v == "NoClass" then
            cB_ItemClass[k] = nil
        end
    end
    cbNivaya:UpdateBags()
end
