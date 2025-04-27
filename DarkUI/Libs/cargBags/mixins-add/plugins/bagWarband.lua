--[[
    Create tabs for blizzard AccountBankPanel.
    By siweia.
]]
local addon, ns = ...
local E, C, L = ns:unpack()
local cargBags = ns.cargBags
local Implementation = cargBags.classes.Implementation

local AccountBankPanel = AccountBankPanel
local BANK_TAB1 = Enum.BagIndex.AccountBankTab_1 or 13
local ACCOUNT_BANK_TYPE = Enum.BankType.Account or 2

function Implementation:GetBagWarnbandButtonClass()
    return self:GetClass("BagWarbandButton", true, "BagWarbandButton")
end

local BagWarbandButton = cargBags:NewClass("BagWarbandButton", nil, "Button")

local function AddBankTabSettingsToTooltip(tooltip, depositFlags)
    if not tooltip or not depositFlags then return end

    if FlagsUtil.IsSet(depositFlags, Enum.BagSlotFlags.ExpansionCurrent) then
        GameTooltip_AddNormalLine(tooltip, BANK_TAB_EXPANSION_ASSIGNMENT:format(BANK_TAB_EXPANSION_FILTER_CURRENT))
    elseif FlagsUtil.IsSet(depositFlags, Enum.BagSlotFlags.ExpansionLegacy) then
        GameTooltip_AddNormalLine(tooltip, BANK_TAB_EXPANSION_ASSIGNMENT:format(BANK_TAB_EXPANSION_FILTER_LEGACY))
    end
    
    local filterList = ContainerFrameUtil_ConvertFilterFlagsToList(depositFlags)
    if filterList then
        GameTooltip_AddNormalLine(tooltip, BANK_TAB_DEPOSIT_ASSIGNMENTS:format(filterList), true)
    end
end

local function UpdateTooltip(self, id)
    if not AccountBankPanel.purchasedBankTabData then return end
    local data = AccountBankPanel.purchasedBankTabData[id]

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    if not data then
        GameTooltip:AddLine(BANKSLOTPURCHASE, 1, 0, 0, 1)
    else
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip_SetTitle(GameTooltip, data.name, NORMAL_FONT_COLOR)
        AddBankTabSettingsToTooltip(GameTooltip, data.depositFlags)
        GameTooltip_AddInstructionLine(GameTooltip, BANK_TAB_TOOLTIP_CLICK_INSTRUCTION)
    end
    GameTooltip:Show()
end

local function RefreshBar(bar)
    local container = bar.container

    for _, button in pairs(bar.buttons) do
        button:UpdateButton()

        if not button.filter then
            local bagId = button.bagId
            button.filter = function(i) return i.bagId ~= bagId end
        end

        container:SetFilter(button.filter, button.bagId ~= bar.selectedId)
        container.implementation:OnEvent("BAG_UPDATE", button.bagId)
    end
end

local buttonNum = 0
function BagWarbandButton:Create(bagID)
    buttonNum = buttonNum + 1
    local name = addon.."BagWarband"..buttonNum
    local button = setmetatable(CreateFrame("Button", name, nil, "BackdropTemplate"), self.__index)
    button:SetID(buttonNum)
    button.bagId = bagID

    button:RegisterForDrag("LeftButton", "RightButton")
    button:RegisterForClicks("AnyUp")
    button:SetSize(32, 32)
    button.Icon = button:CreateTexture(nil, "ARTWORK")
    button.Icon:SetInside(button)

    button.checked = button:CreateTexture()
    button.checked:SetTexture(C.media.button.checked)
    button.checked:SetAllPoints()

    E:StyleButton(button)
    E:ApplyBackdrop(button)

    cargBags.SetScriptHandlers(button, "OnClick", "OnEnter", "OnLeave")

    if(button.OnCreate) then button:OnCreate(bagID) end

    return button
end

function BagWarbandButton:UpdateButton()
    if not AccountBankPanel.purchasedBankTabData then return end

    local currentTabID = self:GetID()
    local data = AccountBankPanel.purchasedBankTabData[currentTabID]

    if not data then
        self.Icon:SetAtlas("Garr_Building-AddFollowerPlus", TextureKitConstants.UseAtlasSize)
        self.checked:SetAlpha(0)
    else
        self.Icon:SetTexture(data.icon)

        if self.bagId == self.bar.selectedId then
            self.checked:SetAlpha(1)

            -- tag [space] of selected bag
            if self.bar.container.NumFreeSlots then
                self.bar.container.NumFreeSlots.__bagId = self.bagId
            end
        else
            self.checked:SetAlpha(0)
        end
    end
end

function BagWarbandButton:OnClick(btn)
    if not AccountBankPanel.purchasedBankTabData then return end

    local currentTabID = self:GetID()
    local data = AccountBankPanel.purchasedBankTabData[currentTabID]

    if not data then
        StaticPopup_Show("CONFIRM_BUY_BANK_TAB", nil, nil, {bankType = ACCOUNT_BANK_TYPE})
    else
        if btn == "LeftButton" then
            -- if self.bar.selectedId ~= self.bagId then
                self.bar.selectedId = self.bagId
                RefreshBar(self.bar)
            -- end
        else -- right button
            local menu = AccountBankPanel.TabSettingsMenu
            if menu then
                if menu:IsShown() then menu:Hide() end
                menu:SetParent(UIParent)
                menu:SetFrameStrata("DIALOG")
                menu:ClearAllPoints()
                menu:SetPoint("CENTER", 0, 100)
                menu:EnableMouse(true)
                menu:TriggerEvent(BankPanelTabSettingsMenuMixin.Event.OpenTabSettingsRequested, self.bagId)
            end
        end
    end
end

-- Register the plugin
cargBags:RegisterPlugin("BagWarband", function(self, bags)
    if(cargBags.ParseBags) then
        bags = cargBags:ParseBags(bags)
    end

    local bar = CreateFrame("Frame", nil, self)
    bar.container = self
    bar.selectedId = nil

    bar.layouts = cargBags.classes.Container.layouts
    bar.LayoutButtons = cargBags.classes.Container.LayoutButtons

    local buttonClass = self.implementation:GetBagWarnbandButtonClass()
    bar.buttons = {}
    for i = 1, #bags do
        local button = buttonClass:Create(bags[i])
        button:SetParent(bar)
        button.bar = bar
        
        table.insert(bar.buttons, button)
        
        if i == 1 then
            bar.selectedId = bags[i]
        end
    end

    hooksecurefunc(AccountBankPanel, "RefreshBankTabs", function(self)
        RefreshBar(bar)
    end)

    bar:RegisterEvent("BANK_TABS_CHANGED")
    bar:RegisterEvent("BANK_TAB_SETTINGS_UPDATED")
    bar:SetScript("OnEvent", function(_, event)
        AccountBankPanel:OnEvent(event, Enum.BankType.Account)
    end)

    RefreshBar(bar)

    return bar
end)