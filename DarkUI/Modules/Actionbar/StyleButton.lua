local E, C, L = select(2, ...):unpack()

if not C.actionbar.styles.buttons.enable then return end

----------------------------------------------------------------------------------------
--	Style ActionBars (modified from rButtonTemplate)
----------------------------------------------------------------------------------------

local _G = _G
local CreateFrame = CreateFrame
local unpack = unpack
local hooksecurefunc = hooksecurefunc
local NUM_ACTIONBAR_BUTTONS = NUM_ACTIONBAR_BUTTONS
local NUM_PET_ACTION_SLOTS = NUM_PET_ACTION_SLOTS
local NUM_POSSESS_SLOTS = NUM_POSSESS_SLOTS or 2
local NUM_STANCE_SLOTS = NUM_STANCE_SLOTS or 10
local STANDARD_TEXT_FONT = STANDARD_TEXT_FONT
local ExtraActionButton1 = _G.ExtraActionButton1
local SpellFlyout = _G.SpellFlyout
local SpellFlyoutBackgroundEnd = _G.SpellFlyoutBackgroundEnd
local SpellFlyoutHorizontalBackground = _G.SpellFlyoutHorizontalBackground
local SpellFlyoutVerticalBackground = _G.SpellFlyoutVerticalBackground

local function CallButtonFunctionByName(button, func, ...)
    if button and func and button[func] then button[func](button, ...) end
end

local function ResetNormalTexture(self, file)
    if not self.__normalTextureFile then return end
    if file == self.__normalTextureFile then return end

    self:SetNormalTexture(self.__normalTextureFile)
end

local function ResetTexture(self, file)
    if not self.__textureFile then return end
    if file == self.__textureFile then return end

    self:SetTexture(self.__textureFile)
end

local function ResetVertexColor(self, r, g, b, a)
    if not self.__vertexColor then return end

    local r2, g2, b2, a2 = unpack(self.__vertexColor)
    if not a2 then a2 = 1 end
    if r ~= r2 or g ~= g2 or b ~= b2 or a ~= a2 then self:SetVertexColor(r2, g2, b2, a2) end
end

local function ApplyPoints(self, points)
    if not points then return end

    self:ClearAllPoints()
    for _, point in next, points do self:SetPoint(unpack(point)) end
end

local function ApplyTexCoord(texture, texCoord)
    if texture.__lockdown or not texCoord then return end

    texture:SetTexCoord(unpack(texCoord))
end

local function ApplyVertexColor(texture, color)
    if not color then return end

    texture.__vertexColor = color
    texture:SetVertexColor(unpack(color))
    hooksecurefunc(texture, "SetVertexColor", ResetVertexColor)
end

local function ApplyAlpha(region, alpha)
    if not alpha then return end

    region:SetAlpha(alpha)
end

local function ApplyFont(fontString, font)
    if not font then return end

    fontString:SetFont(unpack(font))
end

local function ApplyHorizontalAlign(fontString, align)
    if not align then return end
    fontString:SetJustifyH(align)
end

local function ApplyVerticalAlign(fontString, align)
    if not align then return end
    fontString:SetJustifyV(align)
end

local function ApplyTexture(texture, file)
    if not file then return end

    texture.__textureFile = file
    texture:SetTexture(file)
    hooksecurefunc(texture, "SetTexture", ResetTexture)
end

local function ApplyNormalTexture(button, file)
    if not file then return end

    button.__normalTextureFile = file
    button:SetNormalTexture(file)
    hooksecurefunc(button, "SetNormalTexture", ResetNormalTexture)
end

local function SetupTexture(texture, cfg, func, button)
    if not texture or not cfg then return end

    ApplyTexCoord(texture, cfg.texCoord)
    ApplyPoints(texture, cfg.points)
    ApplyVertexColor(texture, cfg.color)
    ApplyAlpha(texture, cfg.alpha)
    if func == "SetTexture" then
        ApplyTexture(texture, cfg.file)
    elseif func == "SetNormalTexture" then
        ApplyNormalTexture(button, cfg.file)
    elseif cfg.file then
        CallButtonFunctionByName(button, func, cfg.file)
    end
end

local function SetupFontString(fontString, cfg)
    if not fontString or not cfg then return end

    ApplyPoints(fontString, cfg.points)
    ApplyFont(fontString, cfg.font)
    ApplyAlpha(fontString, cfg.alpha)
    ApplyHorizontalAlign(fontString, cfg.halign)
    ApplyVerticalAlign(fontString, cfg.valign)
end

local function SetupCooldown(cooldown, cfg)
    if not cooldown or not cfg then return end

    ApplyPoints(cooldown, cfg.points)
end

local function SetupBackdrop(button, backdrop)
    if not backdrop then return end

    button:CreateBackdrop()
    local bg = button.backdrop
    ApplyPoints(bg, backdrop.points)
    bg:SetFrameLevel(button:GetFrameLevel() - 1)
    bg:SetBackdrop(backdrop)
    if backdrop.backgroundColor then
        bg:SetBackdropColor(unpack(backdrop.backgroundColor))
    end
    if backdrop.borderColor then
        bg:SetBackdropBorderColor(unpack(backdrop.borderColor))
    end
end

local function updateEquipItemColor(button)
    if not button.__bg then return end

    if IsEquippedAction(button.action) then
        button.__bg:SetBackdropBorderColor(0, .7, .1)
    else
        button.__bg:SetBackdropBorderColor(0, 0, 0)
    end
end

local function equipItemColor(button)
    if not button.Update then return end
    hooksecurefunc(button, "Update", updateEquipItemColor)
end

local function StyleActionButton(button, cfg)
    if not button then return end
    if button.__styled then return end

    local buttonName = button:GetName()
    local icon = _G[buttonName.."Icon"]
    local flash = _G[buttonName.."Flash"]
    local flyoutBorder = _G[buttonName.."FlyoutBorder"]
    local flyoutBorderShadow = _G[buttonName.."FlyoutBorderShadow"]
    local hotkey = _G[buttonName.."HotKey"]
    local count = _G[buttonName.."Count"]
    local name = _G[buttonName.."Name"]
    local border = _G[buttonName.."Border"]
    local autoCastable = _G[buttonName.."AutoCastable"]
    local NewActionTexture = button.NewActionTexture
    local cooldown = _G[buttonName.."Cooldown"]
    local normalTexture = button:GetNormalTexture()
    local pushedTexture = button:GetPushedTexture()
    local highlightTexture = button:GetHighlightTexture()
    --normal buttons do not have a checked texture, but checkbuttons do and normal actionbuttons are checkbuttons
    local checkedTexture
    if button.GetCheckedTexture then checkedTexture = button:GetCheckedTexture() end
    local floatingBG = _G[buttonName.."FloatingBG"]
    local NormalTexture = _G[buttonName.."NormalTexture"]

    --pet stuff
    local petShine = _G[buttonName.."Shine"]
    if petShine then petShine:SetInside() end

    --hide stuff
    if floatingBG then floatingBG:Hide() end
    if NewActionTexture then NewActionTexture:SetTexture(nil) end
    if button.SlotArt then button.SlotArt:Hide() end
    if button.RightDivider then button.RightDivider:Hide() end
    if button.SlotBackground then button.SlotBackground:Hide() end
    if button.IconMask then button.IconMask:Hide() end
    if NormalTexture then NormalTexture:SetAlpha(0) end
    if button.SpellHighlightTexture then button.SpellHighlightTexture:SetOutside() end
    if button.QuickKeybindHighlightTexture then button.QuickKeybindHighlightTexture:SetTexture("") end

    --backdrop
    SetupBackdrop(icon)
    equipItemColor(button)

    --textures
    SetupTexture(icon, cfg.icon, "SetTexture", icon)
    SetupTexture(flash, cfg.flash, "SetTexture", flash)
    SetupTexture(flyoutBorder, cfg.flyoutBorder, "SetTexture", flyoutBorder)
    SetupTexture(flyoutBorderShadow, cfg.flyoutBorderShadow, "SetTexture", flyoutBorderShadow)
    SetupTexture(border, cfg.border, "SetTexture", border)
    SetupTexture(normalTexture, cfg.normalTexture, "SetNormalTexture", button)
    SetupTexture(pushedTexture, cfg.pushedTexture, "SetPushedTexture", button)
    SetupTexture(highlightTexture, cfg.highlightTexture, "SetHighlightTexture", button)
    highlightTexture:SetColorTexture(1, 1, 1, .25)
    if checkedTexture then
        SetupTexture(checkedTexture, cfg.checkedTexture, "SetCheckedTexture", button)
        checkedTexture:SetColorTexture(1, .8, 0, .35)
    end

    --cooldown
    SetupCooldown(cooldown, cfg.cooldown)

    if autoCastable then
        autoCastable:SetTexCoord(.217, .765, .217, .765)
        autoCastable:SetInside()
    end

    --hotkey+count+name
    SetupFontString(hotkey, cfg.hotkey)
    SetupFontString(count, cfg.count)
    SetupFontString(name, cfg.name)

    button.__styled = true
end

local function StyleExtraActionButton(button, cfg)
    if button.__styled then return end

    local buttonName = button:GetName()
    local icon = _G[buttonName.."Icon"]
    --local flash = _G[buttonName.."Flash"] --wierd the template has two textures of the same name
    local hotkey = _G[buttonName.."HotKey"]
    local count = _G[buttonName.."Count"]
    local buttonstyle = button.style --artwork around the button
    local cooldown = _G[buttonName.."Cooldown"]
    local NormalTexture = _G[buttonName.."NormalTexture"]

    button:SetPushedTexture(C.media.button.pushed) --force it to gain a texture
    local normalTexture = button:GetNormalTexture()
    local pushedTexture = button:GetPushedTexture()
    local highlightTexture = button:GetHighlightTexture()
    local checkedTexture = button:GetCheckedTexture()

    --backdrop
    SetupBackdrop(icon)

    --textures
    SetupTexture(icon, cfg.icon, "SetTexture", icon)
    SetupTexture(buttonstyle, cfg.buttonstyle, "SetTexture", buttonstyle)
    SetupTexture(normalTexture, cfg.normalTexture, "SetNormalTexture", button)
    SetupTexture(pushedTexture, cfg.pushedTexture, "SetPushedTexture", button)
    SetupTexture(highlightTexture, cfg.highlightTexture, "SetHighlightTexture", button)
    SetupTexture(checkedTexture, cfg.checkedTexture, "SetCheckedTexture", button)
    highlightTexture:SetColorTexture(1, 1, 1, .25)
    if NormalTexture then NormalTexture:SetAlpha(0) end
    if button.IconMask then button.IconMask:Hide() end
    
    --cooldown
    SetupCooldown(cooldown, cfg.cooldown)

    --hotkey, count
    SetupFontString(hotkey, cfg.hotkey)
    SetupFontString(count, cfg.count)

    button.__styled = true
end

local function StyleItemButton(button, cfg)
    if not button then return end
    if button.__styled then return end

    local buttonName = button:GetName()
    local icon = _G[buttonName .. "IconTexture"]
    local count = _G[buttonName .. "Count"]
    local stock = _G[buttonName .. "Stock"]
    local searchOverlay = _G[buttonName .. "SearchOverlay"]
    local border = button.IconBorder
    local normalTexture = button:GetNormalTexture()
    local pushedTexture = button:GetPushedTexture()
    local highlightTexture = button:GetHighlightTexture()

    --backdrop
    SetupBackdrop(button, cfg.backdrop)

    --textures
    SetupTexture(icon, cfg.icon, "SetTexture", icon)
    SetupTexture(searchOverlay, cfg.searchOverlay, "SetTexture", searchOverlay)
    SetupTexture(border, cfg.border, "SetTexture", border)
    SetupTexture(normalTexture, cfg.normalTexture, "SetNormalTexture", button)
    SetupTexture(pushedTexture, cfg.pushedTexture, "SetPushedTexture", button)
    SetupTexture(highlightTexture, cfg.highlightTexture, "SetHighlightTexture", button)
    highlightTexture:SetColorTexture(1, 1, 1, .25)

    --count+stock
    SetupFontString(count, cfg.count)
    SetupFontString(stock, cfg.stock)

    button.__styled = true
end

local function StyleAllActionButtons(cfg)
    for i = 1, NUM_ACTIONBAR_BUTTONS do
        StyleActionButton(_G["ActionButton" .. i], cfg)
        StyleActionButton(_G["MultiBarBottomLeftButton" .. i], cfg)
        StyleActionButton(_G["MultiBarBottomRightButton" .. i], cfg)
        StyleActionButton(_G["MultiBarLeftButton" .. i], cfg)
        StyleActionButton(_G["MultiBarRightButton" .. i], cfg)
        StyleActionButton(_G["MultiBar5Button" .. i], cfg)
        StyleActionButton(_G["MultiBar6Button" .. i], cfg)
        StyleActionButton(_G["MultiBar7Button" .. i], cfg)
    end
    for i = 1, 6 do
        StyleActionButton(_G["OverrideActionBarButton" .. i], cfg)
    end
    --petbar buttons
    for i = 1, NUM_PET_ACTION_SLOTS do
        StyleActionButton(_G["PetActionButton" .. i], cfg)
    end
    --stancebar buttons
    for i = 1, NUM_STANCE_SLOTS do
        StyleActionButton(_G["StanceButton" .. i], cfg)
    end
    --possess buttons
    for i = 1, NUM_POSSESS_SLOTS do
        StyleActionButton(_G["PossessButton" .. i], cfg)
    end
    --spell flyout
    SpellFlyout.Background:Hide()
    local function checkForFlyoutButtons()
        local i = 1
        local button = _G["SpellFlyoutButton" .. i]
        while button and button:IsShown() do
            StyleActionButton(button, cfg)
            i = i + 1
            button = _G["SpellFlyoutButton" .. i]
        end
    end
    SpellFlyout:HookScript("OnShow", checkForFlyoutButtons)
end

-- actionButtonConfig
local actionButtonConfig = {}

--backdrop
actionButtonConfig.backdrop = {
    bgFile          = C.media.button.buttonback,
    edgeFile        = C.media.button.outer_shadow,
    tile            = false,
    tileSize        = 32,
    edgeSize        = 5,
    insets          = { left = 5, right = 5, top = 5, bottom = 5 },
    backgroundColor = { 0.1, 0.1, 0.1, 0.8 },
    borderColor     = { 0, 0, 0, 1 },
    points          = {
        { "TOPLEFT", -3, 3 },
        { "BOTTOMRIGHT", 3, -3 }
    }
}

--icon
actionButtonConfig.icon = {
    texCoord = { 0.1, 0.9, 0.1, 0.9 },
    points   = {
        { "TOPLEFT", 1, -1 },
        { "BOTTOMRIGHT", -1, 1 }
    }
}

--flyoutBorder
actionButtonConfig.flyoutBorder = {
    file = ""
}

--flyoutBorderShadow
actionButtonConfig.flyoutBorderShadow = {
    file = ""
}

--border
actionButtonConfig.border = {
    file   = C.media.texture.border,
    points = {
        { "TOPLEFT", -2, 2 },
        { "BOTTOMRIGHT", 2, -2 }
    }
}

--normalTexture
actionButtonConfig.normalTexture = {
    file   = C.media.button.normal,
    color  = { 0.5, 0.5, 0.5, 0.6 },
    points = {
        { "TOPLEFT", 0, 0 },
        { "BOTTOMRIGHT", 0, 0 }
    }
}
--flash
actionButtonConfig.flash = { 
    file = C.media.button.flash,
    points = {
        { "TOPLEFT", 0, 0 },
        { "BOTTOMRIGHT", 0, 0 }
    }
}
--pushedTexture
actionButtonConfig.pushedTexture = { 
    file = C.media.button.pushed,
    points = {
        { "TOPLEFT", 0, 0 },
        { "BOTTOMRIGHT", 0, 0 }
    }
}
--checkedTexture
actionButtonConfig.checkedTexture = { 
    file = C.media.button.checked,
    points = {
        { "TOPLEFT", 0, 0 },
        { "BOTTOMRIGHT", 0, 0 }
    }
}
--highlightTexture
actionButtonConfig.highlightTexture = {
    file   = "",
    points = {
        { "TOPLEFT", E.mult, -E.mult },
        { "BOTTOMRIGHT", -E.mult, E.mult },
    }
}

--cooldown
if C.actionbar.styles.buttons.showCooldown then
    actionButtonConfig.cooldown = {
        font   = { STANDARD_TEXT_FONT, 15, "OUTLINE" },
        points = {
            { "TOPLEFT", 0, 0 },
            { "BOTTOMRIGHT", 0, 0 }
        },
        alpha  = 1
    }
else
    actionButtonConfig.cooldown = {
        alpha = 0
    }
end

--name (macro name fontstring)
if C.actionbar.styles.buttons.showName then
    actionButtonConfig.name = {
        font   = { STANDARD_TEXT_FONT, 10, "OUTLINE" },
        points = {
            { "BOTTOMLEFT", 0, 0 },
            { "BOTTOMRIGHT", 0, 0 }
        },
        alpha  = 1
    }
else
    actionButtonConfig.name = {
        alpha = 0
    }
end

--hotkey
if C.actionbar.styles.buttons.showHotkey then
    actionButtonConfig.hotkey = {
        font   = { STANDARD_TEXT_FONT, 11, "OUTLINE" },
        points = {
            { "TOPRIGHT", 0, 0 },
            { "TOPLEFT", 0, 0 }
        },
        alpha  = 1
    }
else
    actionButtonConfig.hotkey = {
        alpha = 0
    }
end

--count
if C.actionbar.styles.buttons.showStackCount then
    actionButtonConfig.count = {
        font   = { STANDARD_TEXT_FONT, 11, "OUTLINE" },
        points = {
            { "BOTTOMRIGHT", 0, 0 }
        },
        alpha  = 1
    }
else
    actionButtonConfig.count = {
        alpha = 0
    }
end

local host = CreateFrame("Frame")
host:RegisterEvent("PLAYER_LOGIN")
host:SetScript("OnEvent", function()
    --rButtonTemplate:StyleAllActionButtons
    StyleAllActionButtons(actionButtonConfig)

    -- itemButtonConfig
    local itemButtonConfig = {}

    itemButtonConfig.backdrop = actionButtonConfig.backdrop
    itemButtonConfig.icon = actionButtonConfig.icon
    itemButtonConfig.count = actionButtonConfig.count
    itemButtonConfig.stock = actionButtonConfig.name
    itemButtonConfig.border = { file = "" }
    itemButtonConfig.normalTexture = actionButtonConfig.normalTexture

    --rButtonTemplate:StyleItemButton
    local itemButtons = {
        _G.MainMenuBarBackpackButton,
        _G.CharacterBag0Slot,
        _G.CharacterBag1Slot,
        _G.CharacterBag2Slot,
        _G.CharacterBag3Slot
    }
    for _, button in next, itemButtons do
        StyleItemButton(button, itemButtonConfig)
    end

    -- extraButtonConfig
    local extraButtonConfig = actionButtonConfig
    extraButtonConfig.buttonstyle = { file = "" }

    --rButtonTemplate:StyleExtraActionButton
    StyleExtraActionButton(ExtraActionButton1, extraButtonConfig)

    --DarkUI extra buttons
    StyleActionButton(_G["DarkUIExtraButtons_MainLeftButton"], actionButtonConfig)
    StyleActionButton(_G["DarkUIExtraButtons_MainRightButton"], actionButtonConfig)
    StyleActionButton(_G["DarkUIExtraButtons_TopLeftButton"], actionButtonConfig)
    StyleActionButton(_G["DarkUIExtraButtons_TopRightButton"], actionButtonConfig)
end)
