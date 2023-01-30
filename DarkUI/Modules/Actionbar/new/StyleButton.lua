local E, C, L, M = select(2, ...):unpack()

if not C.actionbar.styles.cooldown.enable then return end

----------------------------------------------------------------------------------------
--	Style ActionBars (modified from NDui)
----------------------------------------------------------------------------------------
local module = M:Module("Actionbar"):Sub("Cooldown")

local keyButton = gsub(KEY_BUTTON4, "%d", "")
local keyNumpad = gsub(KEY_NUMPAD1, "%d", "")

local replaces = {
    {"("..keyButton..")", "M"},
    {"("..keyNumpad..")", "N"},
    {"(a%-)", "a"},
    {"(c%-)", "c"},
    {"(s%-)", "s"},
    {KEY_BUTTON3, "M3"},
    {KEY_MOUSEWHEELUP, "MU"},
    {KEY_MOUSEWHEELDOWN, "MD"},
    {KEY_SPACE, "Sp"},
    {"CAPSLOCK", "CL"},
    {"BUTTON", "M"},
    {"NUMPAD", "N"},
    {"(ALT%-)", "a"},
    {"(CTRL%-)", "c"},
    {"(SHIFT%-)", "s"},
    {"MOUSEWHEELUP", "MU"},
    {"MOUSEWHEELDOWN", "MD"},
    {"SPACE", "Sp"},
}

local backdrop = {
    bgFile          = C.media.button.buttonback,
    edgeFile        = C.media.button.outer_shadow,
    tile            = false,
    tileSize        = 32,
    edgeSize        = 5,
    insets          = { left = 5, right = 5, top = 5, bottom = 5 },
    backgroundColor = { 0.1, 0.1, 0.1, 0.8 },
    borderColor     = { 0, 0, 0, 1 },
}

local function setupBackdrop(button)
    button:CreateBackdrop()

    local bg = button.backdrop
    bg:SetFrameLevel(button:GetFrameLevel() - 1)
    bg:SetBackdrop(backdrop)

    if backdrop.backgroundColor then
        bg:SetBackdropColor(unpack(backdrop.backgroundColor))
    end
    if backdrop.borderColor then
        bg:SetBackdropBorderColor(unpack(backdrop.borderColor))
    end

    bg:SetPoint("TOPLEFT", -2, 2)
    bg:SetPoint("BOTTOMRIGHT", 2, -2)
end

function module:UpdateHotKey()
    local text = self:GetText()
    if not text then return end

    if text == RANGE_INDICATOR then
        text = ""
    else
        for _, value in pairs(replaces) do
            text = gsub(text, value[1], value[2])
        end
    end
    self:SetFormattedText("%s", text)
end

function module:StyleActionButton(button)
    if not button then return end
    if button.__styled then return end

    local buttonName = button:GetName()
    local icon = button.icon
    local cooldown = button.cooldown
    local hotkey = button.HotKey
    local count = button.Count
    local name = button.Name
    local flash = button.Flash
    local border = button.Border
    local normal = button.NormalTexture
    local normal2 = button:GetNormalTexture()
    local slotbg = button.SlotBackground
    local pushed = button.PushedTexture
    local checked = button.CheckedTexture
    local highlight = button.HighlightTexture
    local newActionTexture = button.NewActionTexture
    local spellHighlight = button.SpellHighlightTexture
    local iconMask = button.IconMask
    local petShine = _G[buttonName.."Shine"]
    local autoCastable = button.AutoCastable

    if normal2 then normal2:SetAlpha(0) end
    if flash then flash:SetTexture(C.media.button.flash) end
    if newActionTexture then newActionTexture:SetTexture(nil) end
    if border then border:SetTexture(C.media.texture.border) end
    if slotbg then slotbg:Hide() end
    if iconMask then iconMask:Hide() end
    if button.style then button.style:SetAlpha(0) end
    if petShine then petShine:SetInside() end
    if autoCastable then
        autoCastable:SetTexCoord(.217, .765, .217, .765)
        autoCastable:SetInside()
    end

    if normal then
        normal:SetAlpha(0)
        button:SetNormalTexture(C.media.button.normal)
    end

    if icon then
        icon:SetInside()
        if not icon.__lockdown then
            icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        end
        setupBackdrop(button)
    end
    if cooldown then
        cooldown:SetAllPoints()
    end
    if pushed then
        pushed:SetInside()
        pushed:SetTexture(C.media.button.pushed)
    end
    if checked then
        checked:SetInside()
        checked:SetTexture(C.media.button.checked)
    end
    if highlight then
        highlight:SetInside()
        highlight:SetColorTexture(1, 1, 1, .25)
    end
    if spellHighlight then
        spellHighlight:SetOutside()
    end
    if hotkey then
        self.UpdateHotKey(hotkey)
        hooksecurefunc(hotkey, "SetText", self.UpdateHotKey)
    end

    button.__styled = true
end

function module:Init()
    for i = 1, 8 do
        for j = 1, 12 do
            self:StyleActionButton(_G["DarkUI_ActionBar"..i.."Button"..j])
        end
    end
    --petbar buttons
    for i = 1, NUM_PET_ACTION_SLOTS do
        self:StyleActionButton(_G["PetActionButton"..i])
    end
    --stancebar buttons
    for i = 1, 10 do
        self:StyleActionButton(_G["StanceButton"..i])
    end
    --leave vehicle
    self:StyleActionButton(_G["DarkUI_LeaveVehicleButton"])
    --extra action button
    self:StyleActionButton(ExtraActionButton1)
    --spell flyout
    SpellFlyout.Background:SetAlpha(0)
    local numFlyouts = 1
    local function checkForFlyoutButtons()
        local button = _G["SpellFlyoutButton"..numFlyouts]
        while button do
            self:StyleActionButton(button)
            numFlyouts = numFlyouts + 1
            button = _G["SpellFlyoutButton"..numFlyouts]
        end
    end
    SpellFlyout:HookScript("OnShow", checkForFlyoutButtons)
    SpellFlyout:HookScript("OnHide", checkForFlyoutButtons)
end