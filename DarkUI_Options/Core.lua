------------------------------------------------------------------------
-- DarkUI Options Panel
------------------------------------------------------------------------

local addon = {}
DarkUI_Options = addon

local CHECK, SLIDER, DROP, HEADER, BUTTON = 1, 2, 3, 4, 5
addon.CHECK = CHECK
addon.SLIDER = SLIDER
addon.DROP = DROP
addon.HEADER = HEADER
addon.BUTTON = BUTTON

------------------------------------------------------------------------
-- Tab & Option Data (populated by Options.lua)
------------------------------------------------------------------------

addon.TabList = {}
addon.OptionList = {}
addon.Hooks = {}
addon.widgets = {}

function addon:RegisterTab(key, label)
    self.TabList[#self.TabList + 1] = { key = key, label = label }
end

------------------------------------------------------------------------
-- Deferred DarkUI namespace access
------------------------------------------------------------------------

local E, C, L, DB

local function ensureNamespace()
    if E then
        return true
    end
    local ns = _G["DarkUI"]
    if not ns then
        return false
    end
    E, C, L, DB = ns:unpack()
    return true
end

------------------------------------------------------------------------
-- Reload Popup
------------------------------------------------------------------------

StaticPopupDialogs["DARKUI_RELOAD_UI"] = {
    text = L_POPUP_CONFIRM_RELOAD or "Reload UI to apply changes?",
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = ReloadUI,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------

local needReload = false
local panel, tabFrame, scrollFrame, scrollChild, applyButton
local tabs = {}
local activeTab

local PANEL_WIDTH = 1024
local PANEL_HEIGHT = 600
local TAB_WIDTH = 200
local TAB_HEIGHT = 28
local TAB_SPACING = 2
local CONTENT_PADDING = 20
local CONTENT_LEFT = 240
local HORIZON_OFFSET = 330
local WIDGET_OFFSET_CHECK = 35
local WIDGET_OFFSET_SLIDER = 70
local WIDGET_OFFSET_DROP = 70
local WIDGET_OFFSET_HEADER = 35
local WIDGET_OFFSET_BUTTON = 32

------------------------------------------------------------------------
-- Widget Factory (all use E/C/DB at runtime)
------------------------------------------------------------------------

local function getFont()
    return C.media.standard_font[1]
end

local function getClassColor()
    return E.myColor
end

local function createHeader(parent, text, offset)
    local font = getFont()
    local cc = getClassColor()

    local header = parent:CreateFontString(nil, "OVERLAY")
    header:SetFont(font, 13, "OUTLINE")
    header:SetPoint("TOPLEFT", CONTENT_PADDING, -offset)
    header:SetText(text)
    header:SetTextColor(cc.r, cc.g, cc.b)

    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetHeight(1)
    line:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -4)
    line:SetPoint("RIGHT", parent, "RIGHT", -CONTENT_PADDING, 0)
    line:SetColorTexture(cc.r, cc.g, cc.b, 0.3)

    return WIDGET_OFFSET_HEADER
end

local function createCheckBox(parent, dbPath, label, offset, horizon)
    local font = getFont()

    local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    if horizon then
        cb:SetPoint("TOPLEFT", HORIZON_OFFSET, -(offset - WIDGET_OFFSET_CHECK))
    else
        cb:SetPoint("TOPLEFT", CONTENT_PADDING, -offset)
    end
    cb:SetChecked(DB:Get(dbPath) and true or false)
    E:StyleCheckBox(cb)

    cb:SetScript("OnClick", function(self)
        DB:Set(dbPath, self:GetChecked())
        needReload = true
        if applyButton then applyButton:Show() end
    end)

    local text = cb:CreateFontString(nil, "OVERLAY")
    text:SetFont(font, 12, "THINOUTLINE")
    text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    text:SetText(label)
    text:SetTextColor(1, 1, 1)
    cb.label = text

    if horizon then
        return 0, cb
    end
    return WIDGET_OFFSET_CHECK, cb
end

local function createSlider(parent, dbPath, label, offset, extra)
    local font = getFont()
    local minVal, maxVal, step = extra[1], extra[2], extra[3]

    local name = parent:CreateFontString(nil, "OVERLAY")
    name:SetFont(font, 12, "THINOUTLINE")
    name:SetPoint("TOPLEFT", CONTENT_PADDING, -offset)
    name:SetText(label)
    name:SetTextColor(1, 0.8, 0)

    local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", CONTENT_PADDING + 20, -offset - 24)
    slider:SetWidth(200)
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider:SetValue(DB:Get(dbPath) or minVal)
    E:ReskinSlider(slider)

    slider.Low:SetText(minVal)
    slider.High:SetText(maxVal)
    slider.Text:SetText("")

    local editBox = CreateFrame("EditBox", nil, slider, "BackdropTemplate")
    editBox:SetSize(50, 20)
    editBox:SetPoint("TOP", slider, "BOTTOM", 0, -2)
    editBox:SetAutoFocus(false)
    editBox:SetTextInsets(5, 5, 0, 0)
    editBox:SetFont(font, 11, "THINOUTLINE")
    editBox:SetJustifyH("CENTER")
    editBox:SetTemplate("Blur")
    editBox:SetText(format("%.2f", DB:Get(dbPath) or minVal))

    editBox:SetScript("OnEnterPressed", function(self)
        local value = tonumber(self:GetText())
        if not value then return end
        value = max(minVal, min(maxVal, value))
        slider:SetValue(value)
        self:SetText(format("%.2f", value))
        self:ClearFocus()
    end)
    editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    slider:SetScript("OnValueChanged", function(self, value)
        value = E:Round(value, 2)
        DB:Set(dbPath, value)
        editBox:SetText(format("%.2f", value))
        needReload = true
        if applyButton then applyButton:Show() end
    end)

    return WIDGET_OFFSET_SLIDER, slider
end

local function createDropDown(parent, dbPath, label, offset, options)
    local font = getFont()
    local cc = getClassColor()

    local name = parent:CreateFontString(nil, "OVERLAY")
    name:SetFont(font, 12, "THINOUTLINE")
    name:SetPoint("TOPLEFT", CONTENT_PADDING, -offset)
    name:SetText(label)
    name:SetTextColor(1, 1, 1)

    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetSize(200, 28)
    frame:SetPoint("TOPLEFT", CONTENT_PADDING, -offset - 20)
    frame:SetTemplate("Blur")
    frame:SetBackdropBorderColor(1, 1, 1, 0.2)

    local currentValue = DB:Get(dbPath)
    local displayText = frame:CreateFontString(nil, "OVERLAY")
    displayText:SetFont(font, 12, "THINOUTLINE")
    displayText:SetPoint("CENTER")

    local currentIndex
    for i, opt in ipairs(options) do
        if type(opt) == "table" then
            if opt[2] == currentValue then
                currentIndex = i
                displayText:SetText(opt[1])
                break
            end
        else
            if i == currentValue or opt == currentValue then
                currentIndex = i
                displayText:SetText(opt)
                break
            end
        end
    end
    if not currentIndex then
        displayText:SetText(tostring(currentValue or ""))
    end

    local list = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    list:SetPoint("TOP", frame, "BOTTOM", 0, -2)
    list:SetWidth(200)
    list:SetFrameStrata("TOOLTIP")
    list:SetTemplate("Default")
    list:SetBackdropBorderColor(1, 1, 1, 0.2)
    list:Hide()

    for i, opt in ipairs(options) do
        local optLabel, optValue
        if type(opt) == "table" then
            optLabel, optValue = opt[1], opt[2]
        else
            optLabel, optValue = opt, i
        end

        local btn = CreateFrame("Button", nil, list, "BackdropTemplate")
        btn:SetSize(192, 28)
        btn:SetPoint("TOPLEFT", 4, -(i - 1) * 30 - 4)
        btn:SetTemplate("Default")

        local btnText = btn:CreateFontString(nil, "OVERLAY")
        btnText:SetFont(font, 12, "THINOUTLINE")
        btnText:SetPoint("LEFT", 5, 0)
        btnText:SetPoint("RIGHT", -5, 0)
        btnText:SetJustifyH("LEFT")
        btnText:SetText(optLabel)
        btn.text = btnText

        btn:SetScript("OnClick", function()
            DB:Set(dbPath, optValue)
            displayText:SetText(optLabel)
            list:Hide()
            needReload = true
            if applyButton then applyButton:Show() end
        end)
        btn:SetScript("OnEnter", function(self)
            self:SetBackdropColor(1, 1, 1, 0.25)
        end)
        btn:SetScript("OnLeave", function(self)
            self:SetBackdropColor(0, 0, 0, 0.3)
        end)
    end

    list:SetHeight(#options * 30 + 8)

    local gear = CreateFrame("Button", nil, frame)
    gear:SetSize(22, 22)
    gear:SetPoint("LEFT", frame, "RIGHT", -2, 0)
    gear.Icon = gear:CreateTexture(nil, "ARTWORK")
    gear.Icon:SetAllPoints()
    gear.Icon:SetTexture("Interface\\WorldMap\\Gear_64")
    gear.Icon:SetTexCoord(0, 0.5, 0, 0.5)
    gear:SetHighlightTexture("Interface\\WorldMap\\Gear_64")
    gear:GetHighlightTexture():SetTexCoord(0, 0.5, 0, 0.5)

    gear:SetScript("OnClick", function()
        if list:IsShown() then
            list:Hide()
        else
            list:Show()
        end
    end)

    return WIDGET_OFFSET_DROP, frame
end

local function createActionButton(parent, cmd, label, offset)
    local font = getFont()

    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetSize(120, 22)
    btn:SetPoint("TOPLEFT", CONTENT_PADDING, -offset)
    E:ReskinButton(btn)

    local text = btn:CreateFontString(nil, "OVERLAY")
    text:SetFont(font, 11, "THINOUTLINE")
    text:SetPoint("LEFT", btn, "RIGHT", 10, 0)
    text:SetText(label)
    text:SetTextColor(0.9, 0.9, 0.9)

    local cmdText = btn:CreateFontString(nil, "OVERLAY")
    cmdText:SetFont(font, 11, "OUTLINE")
    cmdText:SetPoint("CENTER")
    cmdText:SetText(cmd)
    cmdText:SetTextColor(1, 0.82, 0)

    btn:SetScript("OnClick", function()
        local editBox = ChatFrame1EditBox or ChatFrame1.editBox
        if editBox then
            ChatFrame_OpenChat(cmd)
            editBox:SetText(cmd)
            ChatEdit_SendText(editBox)
        end
    end)

    return WIDGET_OFFSET_BUTTON, btn
end

------------------------------------------------------------------------
-- Tab System
------------------------------------------------------------------------

local function clearContent()
    if scrollChild then
        for _, child in ipairs({ scrollChild:GetChildren() }) do
            child:Hide()
            child:SetParent(nil)
        end
        for _, region in ipairs({ scrollChild:GetRegions() }) do
            region:Hide()
            region:SetParent(nil)
        end
    end
    wipe(addon.widgets)
end

local function populateContent(key)
    clearContent()

    local options = addon.OptionList[key]
    if not options then
        return
    end

    local offset = 10
    for _, opt in ipairs(options) do
        local optType = opt[1]
        local dbPath = opt[2]
        local label = opt[3]
        local extra = opt[4]
        local initFn = opt[5]
        local h, widget

        if optType == HEADER then
            h = createHeader(scrollChild, label or dbPath, offset)
        elseif optType == CHECK then
            h, widget = createCheckBox(scrollChild, dbPath, label, offset, extra)
        elseif optType == SLIDER then
            h, widget = createSlider(scrollChild, dbPath, label, offset, extra)
        elseif optType == DROP then
            h, widget = createDropDown(scrollChild, dbPath, label, offset, extra)
        elseif optType == BUTTON then
            h, widget = createActionButton(scrollChild, dbPath, label, offset)
        end

        if h then
            offset = offset + h
        end

        if widget and dbPath then
            addon.widgets[dbPath] = widget
        end

        if initFn and widget then
            initFn(widget, addon)
        end
    end

    if addon.Hooks[key] then
        addon.Hooks[key](addon)
    end

    scrollChild:SetHeight(offset + 20)
end

local function selectTab(index)
    if activeTab == index then
        return
    end
    activeTab = index

    local cc = getClassColor()
    for i, tab in ipairs(tabs) do
        if i == index then
            tab:SetBackdropColor(cc.r, cc.g, cc.b, 0.3)
            tab.checked = true
            tab.text:SetTextColor(cc.r, cc.g, cc.b)
        else
            tab:SetBackdropColor(0, 0, 0, 0.3)
            tab.checked = false
            tab.text:SetTextColor(0.8, 0.8, 0.8)
        end
    end

    local tabInfo = addon.TabList[index]
    if tabInfo then
        populateContent(tabInfo.key)
    end
end

------------------------------------------------------------------------
-- Main Panel (created on first Toggle)
------------------------------------------------------------------------

local function createPanel()
    local font = getFont()
    local cc = getClassColor()

    panel = CreateFrame("Frame", "DarkUI_OptionsPanel", UIParent, "BackdropTemplate")
    panel:SetSize(PANEL_WIDTH, PANEL_HEIGHT)
    panel:SetPoint("CENTER")
    panel:SetTemplate("Default")
    panel:CreateShadow()
    panel:SetFrameStrata("HIGH")
    panel:SetFrameLevel(10)
    panel:EnableMouse(true)
    panel:SetMovable(true)
    panel:SetClampedToScreen(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    panel:Hide()

    tinsert(UISpecialFrames, "DarkUI_OptionsPanel")

    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY")
    title:SetFont(font, 15, "OUTLINE")
    title:SetPoint("TOP", 0, -10)
    title:SetText("|cffFFCC99Dark|r|cffffffffUI|r " .. (L_DARKUI_CONSOLE or "Options"))

    -- Version
    local version = panel:CreateFontString(nil, "OVERLAY")
    version:SetFont(font, 12, "THINOUTLINE")
    version:SetPoint("TOP", 0, -28)
    version:SetText(E.version or "")
    version:SetTextColor(0.6, 0.6, 0.6)

    -- Close (X) button
    local closeX = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    E:StyleCloseButton(closeX, panel)
    closeX:SetScript("OnClick", function()
        addon:Hide()
    end)

    -- Bottom buttons
    local closeButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    closeButton:SetSize(80, 22)
    closeButton:SetPoint("BOTTOMRIGHT", -20, 15)
    E:ReskinButton(closeButton)
    closeButton:SetText(CLOSE)
    closeButton:SetScript("OnClick", function() addon:Hide() end)

    applyButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    applyButton:SetSize(80, 22)
    applyButton:SetPoint("RIGHT", closeButton, "LEFT", -20, 0)
    E:ReskinButton(applyButton)
    applyButton:SetText(APPLY)
    applyButton:Hide()
    applyButton:SetScript("OnClick", function()
        StaticPopup_Show("DARKUI_RELOAD_UI")
        needReload = false
        applyButton:Hide()
    end)

    -- Global/Character toggle (bottom-left)
    local globalCB = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    globalCB:SetPoint("BOTTOMLEFT", 20, 15)
    globalCB:SetChecked(DB:IsGlobal())
    E:StyleCheckBox(globalCB)
    globalCB:SetScript("OnClick", function(self)
        DB:SetUseGlobal(self:GetChecked())
        needReload = true
        applyButton:Show()
    end)

    local globalText = globalCB:CreateFontString(nil, "OVERLAY")
    globalText:SetFont(font, 12, "THINOUTLINE")
    globalText:SetPoint("LEFT", globalCB, "RIGHT", 4, 0)
    globalText:SetText(L_GLOBAL_OPTION or "Global")
    globalText:SetTextColor(0.8, 0.8, 0.8)

    -- Tab frame (left side)
    tabFrame = CreateFrame("Frame", nil, panel)
    tabFrame:SetPoint("TOPLEFT", 0, -50)
    tabFrame:SetPoint("BOTTOMLEFT", 0, 40)
    tabFrame:SetWidth(CONTENT_LEFT)

    -- Scroll frame (right side)
    scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", CONTENT_LEFT, -50)
    scrollFrame:SetPoint("BOTTOMRIGHT", -28, 40)

    local scrollBar = scrollFrame.ScrollBar or _G[scrollFrame:GetName() .. "ScrollBar"]
    if scrollBar then
        E:ReskinScrollBar(scrollBar)
    end

    scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetWidth(scrollFrame:GetWidth())
    scrollChild:SetHeight(1)
    scrollFrame:SetScrollChild(scrollChild)

    -- Build tabs
    for i, tabInfo in ipairs(addon.TabList) do
        local tab = CreateFrame("Button", nil, tabFrame, "BackdropTemplate")
        tab:SetSize(TAB_WIDTH, TAB_HEIGHT)
        tab:SetPoint("TOPLEFT", 20, -(i - 1) * (TAB_HEIGHT + TAB_SPACING))
        tab:SetTemplate("Default", nil, 0)

        local text = tab:CreateFontString(nil, "OVERLAY")
        text:SetFont(font, 12, "THINOUTLINE")
        text:SetPoint("LEFT", 10, 0)
        text:SetText(tabInfo.label)
        text:SetTextColor(0.8, 0.8, 0.8)
        tab.text = text

        tab:SetScript("OnClick", function()
            selectTab(i)
        end)
        tab:SetScript("OnEnter", function(self)
            if activeTab ~= i then
                self:SetBackdropColor(cc.r, cc.g, cc.b, 0.3)
            end
        end)
        tab:SetScript("OnLeave", function(self)
            if activeTab ~= i then
                self:SetBackdropColor(0, 0, 0, 0.3)
            end
        end)

        tabs[i] = tab
    end
end

------------------------------------------------------------------------
-- Public API
------------------------------------------------------------------------

function addon:Toggle()
    if not ensureNamespace() then
        print("|cffff0000DarkUI_Options:|r DarkUI not loaded.")
        return
    end

    if not panel then
        createPanel()
    end

    if panel:IsShown() then
        self:Hide()
    else
        panel:Show()
        if not activeTab then
            selectTab(1)
        end
    end
end

function addon:Show()
    if not ensureNamespace() then
        return
    end
    if not panel then
        createPanel()
    end
    panel:Show()
    if not activeTab then
        selectTab(1)
    end
end

function addon:Hide()
    if panel then
        panel:Hide()
    end
    if needReload then
        StaticPopup_Show("DARKUI_RELOAD_UI")
        needReload = false
    end
end

------------------------------------------------------------------------
-- Game Menu Button
------------------------------------------------------------------------

local function addGameMenuButton()
    local btn = CreateFrame("Button", "GameMenuButtonDarkUI", GameMenuFrame, "MainMenuFrameButtonTemplate")
    btn:SetSize(200, 35)
    btn:SetText("|cffFFCC99Dark|r|cffffffffUI|r")
    btn:SetScript("OnClick", function()
        HideUIPanel(GameMenuFrame)
        addon:Toggle()
    end)
    btn:Hide()

    local offset = btn:GetHeight()

    hooksecurefunc(GameMenuFrame, "Layout", function(self)
        local anchor
        local others = {}
        for button in self.buttonPool:EnumerateActive() do
            if button:GetText() == ADDONS then
                anchor = button
            elseif button ~= btn then
                others[#others + 1] = button
            end
        end
        if not anchor then
            return
        end

        local anchorTop = anchor:GetTop()

        local p, rel, rp, x, y = anchor:GetPoint()
        if p and rel and y then
            anchor:SetPoint(p, rel, rp, x, y - offset)
        end

        for _, button in ipairs(others) do
            if button:GetTop() < anchorTop then
                local p2, rel2, rp2, x2, y2 = button:GetPoint()
                if p2 and rel2 and y2 then
                    button:SetPoint(p2, rel2, rp2, x2, y2 - offset)
                end
            end
        end

        btn:ClearAllPoints()
        btn:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, 10)
        btn:Show()

        self:SetHeight(self:GetHeight() + offset)
    end)
end

local menuFrame = CreateFrame("Frame")
menuFrame:RegisterEvent("PLAYER_LOGIN")
menuFrame:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    if GameMenuFrame then
        addGameMenuButton()
    end
end)
