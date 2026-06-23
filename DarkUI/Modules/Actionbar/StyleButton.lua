local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Button Style
------------------------------------------------------------------------
local module = E:Module("Actionbar"):Sub("StyleButton")
local LAB = LibStub("LibActionButton-1.0")

local cfg = C.actionbar.styles.buttons

------------------------------------------------------------------------
-- Action button style config
------------------------------------------------------------------------

local hooksecurefunc = hooksecurefunc
local unpack, pairs, gsub = unpack, pairs, gsub
local RANGE_INDICATOR = RANGE_INDICATOR
local KEY_BUTTON3, KEY_BUTTON4, KEY_SPACE, KEY_NUMPAD1 = KEY_BUTTON3, KEY_BUTTON4, KEY_SPACE, KEY_NUMPAD1
local KEY_MOUSEWHEELUP, KEY_MOUSEWHEELDOWN = KEY_MOUSEWHEELUP, KEY_MOUSEWHEELDOWN

local actionStyle = {
    icon = {
        texCoord = { 0.1, 0.9, 0.1, 0.9 },
        points = {
            { "TOPLEFT", 1, -1 },
            { "BOTTOMRIGHT", -1, 1 },
        },
    },
    border = {
        file = C.media.button.border,
        points = {
            { "TOPLEFT", -2, 2 },
            { "BOTTOMRIGHT", 2, -2 },
        },
    },
    flash = {
        file = C.media.button.flash,
        points = {
            { "TOPLEFT", 0, 0 },
            { "BOTTOMRIGHT", 0, 0 },
        },
    },
    normalTexture = {
        file = C.media.button.normal,
        color = { 0.5, 0.5, 0.5, 0.6 },
        points = {
            { "TOPLEFT", 0, 0 },
            { "BOTTOMRIGHT", 0, 0 },
        },
    },
    pushedTexture = {
        file = C.media.button.glow,
        points = {
            { "TOPLEFT", -2, 2 },
            { "BOTTOMRIGHT", 2, -2 },
        },
    },
    checkedTexture = {
        file = "",
        points = {
            { "TOPLEFT", 0, 0 },
            { "BOTTOMRIGHT", 0, 0 },
        },
    },
    highlightTexture = {
        file = "",
        points = {
            { "TOPLEFT", 0, 0 },
            { "BOTTOMRIGHT", 0, 0 },
        },
    },
    hotkey = {
        font = { STANDARD_TEXT_FONT, 11, "OUTLINE" },
        points = {
            { "TOPRIGHT", 0, 0 },
            { "TOPLEFT", 0, 0 },
        },
    },
    count = {
        font = { STANDARD_TEXT_FONT, 11, "OUTLINE" },
        points = {
            { "BOTTOMRIGHT", 0, 0 },
        },
    },
    name = {
        font = { STANDARD_TEXT_FONT, 10, "OUTLINE" },
        points = {
            { "BOTTOMLEFT", 0, 0 },
            { "BOTTOMRIGHT", 0, 0 },
        },
    },
    cooldown = {
        font = { STANDARD_TEXT_FONT, 16, "OUTLINE" },
        points = {
            { "TOPLEFT", 0, 0 },
            { "BOTTOMRIGHT", 0, 0 },
        },
    },
    backdrop = {
        bgFile = C.media.button.buttonback,
        edgeFile = C.media.button.outer_shadow,
        tile = false,
        tileSize = 16,
        edgeSize = 2,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
        backgroundColor = C.media.backdrop_color,
        borderColor = C.media.border_color,
        points = {
            { "TOPLEFT", -2, 2 },
            { "BOTTOMRIGHT", 2, -2 },
        },
    },
}

------------------------------------------------------------------------
-- Hotkey text replacements
------------------------------------------------------------------------

local keyButton = gsub(KEY_BUTTON4, "%d", "")
local keyNumpad = gsub(KEY_NUMPAD1, "%d", "")

local replaces = {
    { "(" .. keyButton .. ")", "M" },
    { "(" .. keyNumpad .. ")", "N" },
    { "(a%-)", "a" },
    { "(c%-)", "c" },
    { "(s%-)", "s" },
    { KEY_BUTTON3, "M3" },
    { KEY_MOUSEWHEELUP, "MU" },
    { KEY_MOUSEWHEELDOWN, "MD" },
    { KEY_SPACE, "Sp" },
    { "CAPSLOCK", "CL" },
    { "BUTTON", "M" },
    { "NUMPAD", "N" },
    { "(ALT%-)", "a" },
    { "(CTRL%-)", "c" },
    { "(SHIFT%-)", "s" },
    { "MOUSEWHEELUP", "MU" },
    { "MOUSEWHEELDOWN", "MD" },
    { "SPACE", "Sp" },
}

------------------------------------------------------------------------
-- Apply helpers
------------------------------------------------------------------------

local function updateHotKey(hotkey)
    local text = hotkey:GetText()
    if not text then return end

    if text == RANGE_INDICATOR then
        text = ""
    else
        for _, value in pairs(replaces) do
            text = gsub(text, value[1], value[2])
        end
    end

    hotkey:SetFormattedText("%s", text)
end

local function applyPoints(self, points)
    if not points then return end
    self:ClearAllPoints()
    for _, point in next, points do
        self:SetPoint(unpack(point))
    end
end

local function applyTexCoord(texture, texCoord)
    if texture.__lockdown or not texCoord then return end
    texture:SetTexCoord(unpack(texCoord))
end

local function applyVertexColor(texture, color)
    if not color then return end
    texture:SetVertexColor(unpack(color))
end

local function applyAlpha(region, alpha)
    if not alpha then return end
    region:SetAlpha(alpha)
end

local function applyFont(fontString, font)
    if not font then return end
    fontString:SetFont(unpack(font))
end

local function applyHorizontalAlign(fontString, align)
    if not align then return end
    fontString:SetJustifyH(align)
end

local function applyVerticalAlign(fontString, align)
    if not align then return end
    fontString:SetJustifyV(align)
end

local function applyTexture(texture, file)
    if not file then return end
    texture:SetTexture(file)
end

local function applyNormalTexture(button, file)
    if not file then return end
    button:SetNormalTexture(file)
end

local function callButtonFunc(button, func, ...)
    if button and func and button[func] then button[func](button, ...) end
end

------------------------------------------------------------------------
-- Setup helpers
------------------------------------------------------------------------

local function setupTexture(texture, cfg, func, button)
    if not texture or not cfg then return end

    applyTexCoord(texture, cfg.texCoord)
    applyPoints(texture, cfg.points)
    applyVertexColor(texture, cfg.color)
    applyAlpha(texture, cfg.alpha)
    if func == "SetTexture" then
        applyTexture(texture, cfg.file)
    elseif func == "SetNormalTexture" then
        applyNormalTexture(button, cfg.file)
    elseif cfg.file then
        callButtonFunc(button, func, cfg.file)
    end
end

local function setupFontString(fontString, cfg)
    if not fontString or not cfg then return end

    applyPoints(fontString, cfg.points)
    applyFont(fontString, cfg.font)
    applyAlpha(fontString, cfg.alpha)
    applyHorizontalAlign(fontString, cfg.halign)
    applyVerticalAlign(fontString, cfg.valign)
end

local function setupCooldown(cooldown, cfg)
    if not cooldown or not cfg then return end
    applyPoints(cooldown, cfg.points)
end

local function setupBackdrop(button, bdCfg)
    if not bdCfg or button.__bg then return end

    Mixin(button, BackdropTemplateMixin)
    local bg = CreateFrame("Frame", nil, button, "BackdropTemplate")
    applyPoints(bg, bdCfg.points)
    bg:SetFrameLevel(button:GetFrameLevel() - 1)
    bg:SetBackdrop(bdCfg)

    if bdCfg.backgroundColor then bg:SetBackdropColor(unpack(bdCfg.backgroundColor)) end
    if bdCfg.borderColor then bg:SetBackdropBorderColor(unpack(bdCfg.borderColor)) end

    button.__bg = bg
end

------------------------------------------------------------------------
-- Style action button
------------------------------------------------------------------------

local function styleActionButton(button, force)
    if not button then return end
    if button.__styled and not force then return end

    local buttonName = button:GetName()
    local icon = button.icon or _G[buttonName .. "Icon"]
    local hotkey = button.HotKey or _G[buttonName .. "HotKey"]
    local count = button.Count or _G[buttonName .. "Count"]
    local name = button.Name or _G[buttonName .. "Name"]
    local flash = button.Flash or _G[buttonName .. "Flash"]
    local border = button.Border or _G[buttonName .. "Border"]
    local autoCastable = button.AutoCastable or _G[buttonName .. "AutoCastable"]
    local cooldown = button.cooldown or _G[buttonName .. "Cooldown"] or button.Cooldown
    local normal = button.NormalTexture or button:GetNormalTexture()
    local pushed = button.PushedTexture or button:GetPushedTexture()
    local checked = button.CheckedTexture or (button.GetCheckedTexture and button:GetCheckedTexture() or nil)
    local highlight = button.HighlightTexture or button:GetHighlightTexture()
    local newActionTexture = button.NewActionTexture
    local spellHighlight = button.SpellHighlightTexture
    local slotbg = button.SlotBackground
    local iconMask = button.IconMask
    local petShine = _G[buttonName .. "Shine"]

    if border then border:SetTexture("") end
    if flash then flash:SetTexture("") end
    if newActionTexture then newActionTexture:SetTexture("") end
    if slotbg then slotbg:Hide() end
    if iconMask then iconMask:Hide() end
    if petShine then petShine:SetInside() end
    if spellHighlight then spellHighlight:SetOutside() end
    if autoCastable then
        autoCastable:SetTexCoord(0.217, 0.765, 0.217, 0.765)
        autoCastable:SetInside()
    end

    setupBackdrop(button, actionStyle.backdrop)
    setupCooldown(cooldown, actionStyle.cooldown)

    setupTexture(icon, actionStyle.icon, "SetTexture", icon)
    setupTexture(flash, actionStyle.flash, "SetTexture", flash)
    setupTexture(border, actionStyle.border, "SetTexture", border)
    setupTexture(normal, actionStyle.normalTexture, "SetNormalTexture", button)
    setupTexture(pushed, actionStyle.pushedTexture, "SetPushedTexture", button)
    setupTexture(highlight, actionStyle.highlightTexture, "SetHighlightTexture", button)
    setupTexture(checked, actionStyle.checkedTexture, "SetCheckedTexture", button)

    if checked then checked:SetColorTexture(1, 0.8, 0, 0.35) end
    if highlight then highlight:SetColorTexture(1, 1, 1, 0.25) end
    if spellHighlight then spellHighlight:SetOutside() end

    setupFontString(hotkey, actionStyle.hotkey)
    setupFontString(count, actionStyle.count)
    setupFontString(name, actionStyle.name)

    if hotkey then
        updateHotKey(hotkey)
        hooksecurefunc(hotkey, "SetText", updateHotKey)
    end

    button.__styled = true
end

E:Module("Actionbar").StyleActionButton = styleActionButton

------------------------------------------------------------------------
-- Per-button visibility config
------------------------------------------------------------------------

local function styleButton(button)
    if not button then return end

    styleActionButton(button, true)

    local buttonName = button:GetName()

    if not cfg.showMacroName then
        local name = button.Name or (buttonName and _G[buttonName .. "Name"])
        if name then name:SetAlpha(0) end
    end

    if not cfg.showCooldown then
        local cooldown = button.cooldown or (buttonName and _G[buttonName .. "Cooldown"]) or button.Cooldown
        if cooldown then cooldown:SetAlpha(0) end
    end

    if not cfg.showHotkey then
        local hotkey = button.HotKey or (buttonName and _G[buttonName .. "HotKey"])
        if hotkey then hotkey:SetAlpha(0) end
    end

    if not cfg.showStackCount then
        local count = button.Count or (buttonName and _G[buttonName .. "Count"])
        if count then count:SetAlpha(0) end
    end
end

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnEnable()
    for i = 1, 8 do
        for j = 1, NUM_ACTIONBAR_BUTTONS do
            styleButton(_G["DarkUI_ActionBar" .. i .. "Button" .. j])
        end
    end

    for i = 1, NUM_PET_ACTION_SLOTS do
        styleButton(_G["PetActionButton" .. i])
    end

    for i = 1, (NUM_STANCE_SLOTS or 10) do
        styleButton(_G["StanceButton" .. i])
    end

    for i = 1, (NUM_POSSESS_SLOTS or 2) do
        styleButton(_G["PossessButton" .. i])
    end

    styleButton(ExtraActionButton1)

    local bagButtons = {
        MainMenuBarBackpackButton,
        CharacterBag0Slot,
        CharacterBag1Slot,
        CharacterBag2Slot,
        CharacterBag3Slot,
        CharacterReagentBag0Slot,
    }
    for _, button in next, bagButtons do
        styleButton(button)
    end

    -- Spell flyout
    if SpellFlyout then
        SpellFlyout.Background:SetAlpha(0)
        local numFlyouts = 1
        local function checkForFlyoutButtons()
            local button = _G["SpellFlyoutButton" .. numFlyouts]
            while button do
                styleButton(button)
                numFlyouts = numFlyouts + 1
                button = _G["SpellFlyoutButton" .. numFlyouts]
            end
        end
        SpellFlyout:HookScript("OnShow", checkForFlyoutButtons)
        SpellFlyout:HookScript("OnHide", checkForFlyoutButtons)
    end

    -- LAB SpellFlyout
    if LAB.flyoutHandler then
        for _, button in next, LAB.FlyoutButtons do
            button:SetScale(1)
            styleButton(button)
        end

        LAB.RegisterCallback(LAB.flyoutHandler, "OnButtonUpdate", function(_, button)
            if button:GetParent() ~= LAB.flyoutHandler then return end
            if button:GetParent():GetParent() ~= UIParent then
                button:SetSize(button:GetParent():GetParent():GetSize())
                styleButton(button)
            end
        end)

        LAB.flyoutHandler.Background:Hide()
    end

    -- Equipped border color
    LAB.RegisterCallback(module, "OnButtonUpdate", function(_, button)
        if not button.__bg then return end
        if button.Border and button.Border:IsShown() then
            button.__bg:SetBackdropBorderColor(0, 0.7, 0.1)
        else
            button.__bg:SetBackdropBorderColor(0, 0, 0)
        end
    end)

    -- DarkUI extra buttons
    styleButton(_G["DarkUIExtraButtons_MainLeftButton"])
    styleButton(_G["DarkUIExtraButtons_MainRightButton"])
    styleButton(_G["DarkUIExtraButtons_TopLeftButton"])
    styleButton(_G["DarkUIExtraButtons_TopRightButton"])
end
