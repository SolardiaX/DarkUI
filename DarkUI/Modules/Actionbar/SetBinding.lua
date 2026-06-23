local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
-- Hover Key Bind
----------------------------------------------------------------------------------------
local module = E:Module("Actionbar"):Sub("SetBinding")

local tonumber, pairs, strfind, strupper, format = tonumber, pairs, strfind, strupper, format
local InCombatLockdown = InCombatLockdown
local GetBindingKey, SetBinding, SaveBindings, LoadBindings = GetBindingKey, SetBinding, SaveBindings, LoadBindings
local IsAltKeyDown, IsControlKeyDown, IsShiftKeyDown, IsMetaKeyDown = IsAltKeyDown, IsControlKeyDown, IsShiftKeyDown, IsMetaKeyDown

local bind
local macroInit

local ignoreKeys = {
    ["LALT"] = true,
    ["RALT"] = true,
    ["LCTRL"] = true,
    ["RCTRL"] = true,
    ["LSHIFT"] = true,
    ["RSHIFT"] = true,
    ["UNKNOWN"] = true,
    ["LeftButton"] = true,
}

local function hookActionButton(self)
    local pet = self.commandName and strfind(self.commandName, "^BONUSACTION") and "PET"
    local stance = self.commandName and strfind(self.commandName, "^SHAPESHIFT") and "STANCE"
    module:UpdateBind(self, pet or stance or nil)
end

local function hookMacroButton(self) module:UpdateBind(self, "MACRO") end

local function hookSpellButton(self) module:UpdateBind(self, "SPELL") end

function module:RegisterButton(button)
    if button.IsProtected and button.IsObjectType and button:IsObjectType("CheckButton") and button:IsProtected() then
        button:HookScript("OnEnter", hookActionButton)
    end
end

function module:RegisterMacro(addon)
    if addon ~= "Blizzard_MacroUI" then return end
    if macroInit then return end

    hooksecurefunc(MacroFrame.MacroSelector.ScrollBox, "Update", function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local button = select(i, self.ScrollTarget:GetChildren())
            if not button.bindHooked then
                button:HookScript("OnEnter", hookMacroButton)
                button.bindHooked = true
            end
        end
    end)

    macroInit = true
end

function module:UpdateBind(button, spellmacro)
    if not bind or not bind.enabled or InCombatLockdown() then return end

    bind.button = button
    bind.spellmacro = spellmacro
    bind:ClearAllPoints()
    bind:SetAllPoints(button)
    bind:Show()

    if spellmacro == "SPELL" then
        bind.id = button.slotIndex or button:GetID()
        bind.name = C_SpellBook.GetSpellBookItemName(bind.id, Enum.SpellBookSpellBank.Player)
        bind.bindings = { GetBindingKey(spellmacro .. " " .. bind.name) }
    elseif spellmacro == "MACRO" then
        bind.id = button.selectionIndex or button:GetID()
        if MacroFrame and MacroFrame.selectedTab == 2 then bind.id = bind.id + MAX_ACCOUNT_MACROS end
        bind.name = GetMacroInfo(bind.id)
        bind.bindings = { GetBindingKey(spellmacro .. " " .. bind.name) }
    elseif spellmacro == "STANCE" or spellmacro == "PET" then
        bind.name = button:GetName()
        if not bind.name then return end
        bind.tipName = button.commandName and GetBindingName(button.commandName)

        bind.id = tonumber(button:GetID())
        if not bind.id or bind.id < 1 or bind.id > (spellmacro == "STANCE" and 10 or 12) then
            bind.bindstring = "CLICK " .. bind.name .. ":LeftButton"
        else
            bind.bindstring = (spellmacro == "STANCE" and "SHAPESHIFTBUTTON" or "BONUSACTIONBUTTON") .. bind.id
        end
        bind.bindings = { GetBindingKey(bind.bindstring) }
    else
        bind.name = button:GetName()
        if not bind.name then return end
        bind.tipName = button.commandName and GetBindingName(button.commandName)

        bind.action = tonumber(button.action)
        if button.keyBoundTarget then
            bind.bindstring = button.keyBoundTarget
        elseif not bind.action or bind.action < 1 or bind.action > 180 then
            bind.bindstring = "CLICK " .. bind.name .. ":LeftButton"
        else
            local modact = 1 + (bind.action - 1) % 12
            if bind.name == "ExtraActionButton1" then
                bind.bindstring = "EXTRAACTIONBUTTON1"
            elseif bind.action < 25 or bind.action > 72 then
                bind.bindstring = "ACTIONBUTTON" .. modact
            elseif bind.action < 73 and bind.action > 60 then
                bind.bindstring = "MULTIACTIONBAR1BUTTON" .. modact
            elseif bind.action < 61 and bind.action > 48 then
                bind.bindstring = "MULTIACTIONBAR2BUTTON" .. modact
            elseif bind.action < 49 and bind.action > 36 then
                bind.bindstring = "MULTIACTIONBAR4BUTTON" .. modact
            elseif bind.action < 37 and bind.action > 24 then
                bind.bindstring = "MULTIACTIONBAR3BUTTON" .. modact
            end
        end
        bind.bindings = { GetBindingKey(bind.bindstring) }
    end

    bind:GetScript("OnEnter")()
end

function module:Listener(key)
    if key == "ESCAPE" or key == "RightButton" then
        if bind.bindings then
            for i = 1, #bind.bindings do
                SetBinding(bind.bindings[i])
            end
        end
        print(format(L.ACTIONBAR_BINDING_ALLCLEAR or "Cleared bindings for %s", bind.tipName or bind.name))
        module:UpdateBind(bind.button, bind.spellmacro)
        return
    end

    if ignoreKeys[key] then return end

    if key == "MiddleButton" then key = "BUTTON3" end
    if strfind(key, "Button%d") then key = strupper(key) end

    local alt = IsAltKeyDown() and "ALT-" or ""
    local ctrl = IsControlKeyDown() and "CTRL-" or ""
    local shift = IsShiftKeyDown() and "SHIFT-" or ""
    local meta = IsMetaKeyDown() and "META-" or ""

    if not bind.spellmacro or bind.spellmacro == "PET" or bind.spellmacro == "STANCE" then
        SetBinding(alt .. ctrl .. shift .. meta .. key, bind.bindstring)
    else
        SetBinding(alt .. ctrl .. shift .. meta .. key, bind.spellmacro .. " " .. bind.name)
    end

    print(format(L.ACTIONBAR_BINDING_BINDTO or "Bound %s to %s", alt .. ctrl .. shift .. meta .. key, bind.tipName or bind.name))
    module:UpdateBind(bind.button, bind.spellmacro)
end

function module:HideFrame()
    bind:ClearAllPoints()
    bind:Hide()
    GameTooltip:Hide()
end

function module:Activate()
    bind.enabled = true
    self:RegisterEvent("PLAYER_REGEN_DISABLED", function() module:Deactivate(false) end)
end

function module:Deactivate(save)
    local which = GetCurrentBindingSet()
    if save then
        SaveBindings(which)
        print("|cffffff00" .. (L.ACTIONBAR_BINDING_SAVE or "Bindings saved") .. "|r")
    else
        LoadBindings(which)
        print("|cffffff00" .. (L.ACTIONBAR_BINDING_DISCARDED or "Bindings discarded") .. "|r")
    end

    bind.enabled = false
    module:HideFrame()
    self:UnregisterEvent("PLAYER_REGEN_DISABLED")
    StaticPopup_Hide("DARKUI_KEYBIND_MODE")
end

function module:OnInit()
    if not C.actionbar.hover_binding then return end

    bind = CreateFrame("Frame", "DarkUI_HoverBind", UIParent)
    bind:SetFrameStrata("DIALOG")
    bind:EnableMouse(true)
    bind:EnableKeyboard(true)
    bind:EnableMouseWheel(true)
    bind.texture = bind:CreateTexture()
    bind.texture:SetPoint("TOPLEFT", bind, 2, -2)
    bind.texture:SetPoint("BOTTOMRIGHT", bind, -2, 2)
    bind.texture:SetColorTexture(1, 1, 1, 0.3)
    bind:Hide()

    bind:SetScript("OnEnter", function()
        GameTooltip:SetOwner(bind, "ANCHOR_NONE")
        GameTooltip:SetPoint("BOTTOM", bind, "TOP", 0, 2)
        GameTooltip:AddLine(bind.tipName or bind.name, 0.6, 0.8, 1)

        if not bind.bindings or #bind.bindings == 0 then
            GameTooltip:AddLine(L.ACTIONBAR_BINDING_NOBINDING or NOT_BOUND, 1, 0, 0)
        else
            GameTooltip:AddDoubleLine(L.ACTIONBAR_BINDING_BINDING or "Binding", L.ACTIONBAR_BINDING_KEY or "Key", 0.6, 0.6, 0.6, 0.6, 0.6, 0.6)
            for i = 1, #bind.bindings do
                GameTooltip:AddDoubleLine(i, bind.bindings[i], 1, 1, 1, 0, 1, 0)
            end
        end
        GameTooltip:Show()
    end)
    bind:SetScript("OnLeave", function() module:HideFrame() end)
    bind:SetScript("OnKeyUp", function(_, key) module:Listener(key) end)
    bind:SetScript("OnMouseUp", function(_, key) module:Listener(key) end)
    bind:SetScript("OnMouseWheel", function(_, delta)
        if delta > 0 then
            module:Listener("MOUSEWHEELUP")
        else
            module:Listener("MOUSEWHEELDOWN")
        end
    end)

    -- Register all actionbar buttons via commandName detection
    local parentModule = E:GetModule("Actionbar")
    local bars = parentModule and parentModule._subs["Bars"]
    if bars and bars.bars then
        for _, bar in next, bars.bars do
            if bar and bar.buttons then
                for _, button in next, bar.buttons do
                    module:RegisterButton(button)
                end
            end
        end
    end

    -- Extra buttons
    local extraBars = parentModule and parentModule._subs["ExtraButton"]
    if extraBars and extraBars.bars then
        for _, bar in next, extraBars.bars do
            if bar and bar.buttons then
                for _, button in next, bar.buttons do
                    module:RegisterButton(button)
                end
            end
        end
    end

    -- Stance/Pet buttons via commandName
    for i = 1, 10 do
        local b = _G["StanceButton" .. i]
        if b then module:RegisterButton(b) end
    end
    for i = 1, 10 do
        local b = _G["PetActionButton" .. i]
        if b then module:RegisterButton(b) end
    end

    if ExtraActionButton1 then module:RegisterButton(ExtraActionButton1) end

    -- Spellbook buttons
    for i = 1, 12 do
        local b = _G["SpellButton" .. i]
        if b then b:HookScript("OnEnter", hookSpellButton) end
    end

    -- Macro UI (lazy load)
    if not C_AddOns.IsAddOnLoaded("Blizzard_MacroUI") then
        hooksecurefunc(C_AddOns, "LoadAddOn", function(addon) module:RegisterMacro(addon) end)
    else
        module:RegisterMacro("Blizzard_MacroUI")
    end

    -- Static popup
    StaticPopupDialogs["DARKUI_KEYBIND_MODE"] = {
        text = L.ACTIONBAR_BINDING_MODETEXT or "Hover over a button and press a key to bind it. Press ESC to clear.",
        button1 = SAVE,
        button2 = CANCEL,
        OnAccept = function() module:Deactivate(true) end,
        OnCancel = function() module:Deactivate(false) end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = false,
        preferredIndex = 5,
    }

    -- Slash command
    SlashCmdList.DARKUI_KEYBIND = function()
        if InCombatLockdown() then
            print(L.ACTIONBAR_BINDING_INCOMBATLOCKDOWN or "Cannot bind in combat")
            return
        end
        if not bind.enabled then
            module:Activate()
            StaticPopup_Show("DARKUI_KEYBIND_MODE")
        end
    end
    SLASH_DARKUI_KEYBIND1 = "/hvb"
end
