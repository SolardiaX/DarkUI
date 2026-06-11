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
local panel, tabFrame, scrollFrame, scrollChild
local tabs = {}
local activeTab

local PANEL_WIDTH = 800
local PANEL_HEIGHT = 560
local TAB_WIDTH = 140
local TAB_HEIGHT = 26
local TAB_SPACING = 4
local CONTENT_PADDING = 20
local WIDGET_OFFSET_CHECK = 30
local WIDGET_OFFSET_SLIDER = 60
local WIDGET_OFFSET_DROP = 60
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
    local xOffset = horizon and (PANEL_WIDTH - TAB_WIDTH) / 2 or CONTENT_PADDING

    local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    cb:SetPoint("TOPLEFT", xOffset, -offset)
    cb:SetChecked(DB:Get(dbPath) and true or false)
    E:ReskinCheckBox(cb)

    cb:SetScript("OnClick", function(self)
        DB:Set(dbPath, self:GetChecked())
        needReload = true
    end)

    local text = cb:CreateFontString(nil, "OVERLAY")
    text:SetFont(font, 12, "THINOUTLINE")
    text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    text:SetText(label)
    text:SetTextColor(1, 1, 1)
    cb.label = text

    return WIDGET_OFFSET_CHECK
end

local function createSlider(parent, dbPath, label, offset, extra)
    local font = getFont()
    local minVal, maxVal, step = extra[1], extra[2], extra[3]

    local name = parent:CreateFontString(nil, "OVERLAY")
    name:SetFont(font, 12, "THINOUTLINE")
    name:SetPoint("TOPLEFT", CONTENT_PADDING, -offset)
    name:SetText(label)
    name:SetTextColor(1, 1, 1)

    local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", CONTENT_PADDING, -offset - 22)
    slider:SetWidth(200)
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider:SetValue(DB:Get(dbPath) or minVal)
    E:ReskinSlider(slider)

    slider.Low:SetText(minVal)
    slider.High:SetText(maxVal)
    slider.Text:SetText("")

    local valueText = slider:CreateFontString(nil, "OVERLAY")
    valueText:SetFont(font, 11, "THINOUTLINE")
    valueText:SetPoint("LEFT", slider, "RIGHT", 10, 0)
    valueText:SetText(format("%.2f", DB:Get(dbPath) or minVal))

    slider:SetScript("OnValueChanged", function(self, value)
        value = E:Round(value, 2)
        DB:Set(dbPath, value)
        valueText:SetText(format("%.2f", value))
        needReload = true
    end)

    return WIDGET_OFFSET_SLIDER
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
    frame:SetSize(180, 22)
    frame:SetPoint("TOPLEFT", CONTENT_PADDING, -offset - 20)
    frame:SetTemplate("Blur")

    local currentValue = DB:Get(dbPath)
    local displayText = frame:CreateFontString(nil, "OVERLAY")
    displayText:SetFont(font, 11, "THINOUTLINE")
    displayText:SetPoint("LEFT", 8, 0)
    displayText:SetPoint("RIGHT", -22, 0)
    displayText:SetJustifyH("LEFT")

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

    local arrow = frame:CreateFontString(nil, "OVERLAY")
    arrow:SetFont(font, 12, "THINOUTLINE")
    arrow:SetPoint("RIGHT", -6, 0)
    arrow:SetText("v")
    arrow:SetTextColor(0.7, 0.7, 0.7)

    local list = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    list:SetPoint("TOP", frame, "BOTTOM", 0, -2)
    list:SetWidth(180)
    list:SetFrameStrata("TOOLTIP")
    list:SetTemplate("Default")
    list:CreateShadow()
    list:Hide()

    for i, opt in ipairs(options) do
        local optLabel, optValue
        if type(opt) == "table" then
            optLabel, optValue = opt[1], opt[2]
        else
            optLabel, optValue = opt, i
        end

        local btn = CreateFrame("Button", nil, list)
        btn:SetSize(172, 20)
        btn:SetPoint("TOPLEFT", 4, -(i - 1) * 20 - 4)

        local btnText = btn:CreateFontString(nil, "OVERLAY")
        btnText:SetFont(font, 11, "THINOUTLINE")
        btnText:SetAllPoints()
        btnText:SetJustifyH("LEFT")
        btnText:SetText("  " .. optLabel)
        btn.text = btnText

        btn:SetHighlightTexture(C.media.texture.status)
        btn:GetHighlightTexture():SetVertexColor(cc.r, cc.g, cc.b, 0.2)

        btn:SetScript("OnClick", function()
            DB:Set(dbPath, optValue)
            displayText:SetText(optLabel)
            list:Hide()
            needReload = true
        end)
    end

    list:SetHeight(#options * 20 + 8)

    frame:SetScript("OnMouseUp", function()
        if list:IsShown() then
            list:Hide()
        else
            list:Show()
        end
    end)

    return WIDGET_OFFSET_DROP
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

    return WIDGET_OFFSET_BUTTON
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

        if optType == HEADER then
            offset = offset + createHeader(scrollChild, label or dbPath, offset)
        elseif optType == CHECK then
            offset = offset + createCheckBox(scrollChild, dbPath, label, offset, extra)
        elseif optType == SLIDER then
            offset = offset + createSlider(scrollChild, dbPath, label, offset, extra)
        elseif optType == DROP then
            offset = offset + createDropDown(scrollChild, dbPath, label, offset, extra)
        elseif optType == BUTTON then
            offset = offset + createActionButton(scrollChild, dbPath, label, offset)
        end
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
            tab:SetBackdropBorderColor(cc.r, cc.g, cc.b)
            tab.text:SetTextColor(cc.r, cc.g, cc.b)
        else
            tab:SetBackdropBorderColor(unpack(C.media.border_color))
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
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    panel:Hide()

    tinsert(UISpecialFrames, "DarkUI_OptionsPanel")

    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY")
    title:SetFont(font, 15, "OUTLINE")
    title:SetPoint("TOPLEFT", 15, -12)
    title:SetText("|cffFFCC99Dark|r|cffffffffUI|r " .. (L_DARKUI_CONSOLE or "Options"))

    -- Close button
    local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    E:ReskinCloseButton(close, panel)
    close:SetScript("OnClick", function()
        addon:Hide()
    end)

    -- Global/Character toggle
    local globalCB = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    globalCB:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -30, -8)
    globalCB:SetChecked(DB:IsGlobal())
    E:ReskinCheckBox(globalCB)
    globalCB:SetScript("OnClick", function(self)
        DB:SetUseGlobal(self:GetChecked())
        needReload = true
    end)

    local globalText = globalCB:CreateFontString(nil, "OVERLAY")
    globalText:SetFont(font, 11, "THINOUTLINE")
    globalText:SetPoint("RIGHT", globalCB, "LEFT", -4, 0)
    globalText:SetText(L_GLOBAL_OPTION or "Global")
    globalText:SetTextColor(0.8, 0.8, 0.8)

    -- Tab frame (left side)
    tabFrame = CreateFrame("Frame", nil, panel)
    tabFrame:SetPoint("TOPLEFT", 10, -40)
    tabFrame:SetPoint("BOTTOMLEFT", 10, 10)
    tabFrame:SetWidth(TAB_WIDTH)

    -- Scroll frame (right side)
    scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", TAB_WIDTH + 20, -40)
    scrollFrame:SetPoint("BOTTOMRIGHT", -28, 10)

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
        tab:SetSize(TAB_WIDTH - 10, TAB_HEIGHT)
        tab:SetPoint("TOPLEFT", 0, -(i - 1) * (TAB_HEIGHT + TAB_SPACING))
        tab:SetTemplate("Overlay")

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
                self.text:SetTextColor(1, 1, 1)
            end
        end)
        tab:SetScript("OnLeave", function(self)
            if activeTab ~= i then
                self.text:SetTextColor(0.8, 0.8, 0.8)
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
