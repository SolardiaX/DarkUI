local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable and not C.actionbar.styles.range.enable then return end

----------------------------------------------------------------------------------------
--	Out of range check (modified from tullaCC)
----------------------------------------------------------------------------------------
local module = E:Module("Actionbar"):Sub("StyleRange")
local LAB = LibStub("LibActionButton-1.0")

local _G = _G
local GetActionInfo, GetMacroInfo, GetMacroSpell, GetSpellPowerCost = GetActionInfo, GetMacroInfo, GetMacroSpell, GetSpellPowerCost
local UnitPower = UnitPower
local IsActionInRange, IsUsableAction = IsActionInRange, IsUsableAction
local PetHasActionBar, GetPetActionInfo, GetPetActionSlotUsable = PetHasActionBar, GetPetActionInfo, GetPetActionSlotUsable
local After = After
local unpack, tinsert, wipe, pairs, ipairs, type = unpack, tinsert, wipe, pairs, ipairs, type
local hooksecurefunc = hooksecurefunc
local NUM_PET_ACTION_SLOTS = NUM_PET_ACTION_SLOTS

local UPDATE_DELAY = 0.2
local cfg = C.actionbar.styles.range

module.flashAnimations = {}

local function getPetActionButtonState(button)
    local slot = button:GetID() or 0
    local _, _, _, _, _, _, _, checksRange, inRange = GetPetActionInfo(slot)
    local isUsable, notEnoughMana = GetPetActionSlotUsable(slot)

    -- usable (ignoring target information)
    if isUsable then
        -- but out of range
        if checksRange and not inRange then
            return "oor"
        else
            return "normal"
        end
    elseif notEnoughMana then
        return "oom"
    else
        return "unusable"
    end
end

local function getActionButtonState(button)
    if button._state_type == "custom" then return "normal" end
    
    local action = button._state_action -- or button.action
    if not action then return "normal" end

    local actionType, actionTypeId = GetActionInfo(action)

    if not actionType then
        return "normal"
    end
    -- for macros with names that start with a #, we prioritize the OOM check
    -- using a spell cost strategy over other ones to better clarify if the
    -- macro is actually usable or not
    if actionType == "macro" then
        local name = GetMacroInfo(actionTypeId)

        if name and name:sub(1, 1) == "#" then
            local spellId = GetMacroSpell(actionTypeId)
            -- only run the check for spell macros
            if spellId then
                local costs = GetSpellPowerCost(spellId)
                for _, cost in ipairs(costs) do
                    if UnitPower("player", cost.type) < cost.minCost then
                        return "oom"
                    end
                end
                if IsActionInRange(action) == false then
                    return "oor"
                end
                return "normal"
            end
        end
    end
    local isUsable, notEnoughMana = IsUsableAction(action)
    if not isUsable then
        if notEnoughMana then
            return "oom"
        end
        return "unusable"
    end
    -- we do == false here because IsActionInRange can return one of true
    -- (has range, in range), false (has range, out of range), and nil (does
    -- not have range) and we explicitly want to know about (has range, oor)
    if IsActionInRange(action) == false then
        return "oor"
    end
    return "normal"
end

local function alpha_OnFinished(self)
    local owner = self.owner

    if owner.flashing ~= 1 then
        module:StopButtonFlashing(owner)
    end
end

function module:StartButtonFlashing(button)
    local animation = self.flashAnimations and self.flashAnimations[button]

    if not animation then
        animation = button.Flash:CreateAnimationGroup()
        animation:SetLooping("BOUNCE")

        local alpha = animation:CreateAnimation("ALPHA")

        alpha:SetDuration(cfg.flashDuration)
        alpha:SetFromAlpha(0)
        alpha:SetToAlpha(1)
        alpha:SetScript("OnFinished", alpha_OnFinished)

        alpha.owner = button

        if self.flashAnimations then
            self.flashAnimations[button] = animation
        else
            self.flashAnimations = {[button] = animation}
        end
    end

    button.Flash:Show()
    animation:Play()
end

function module:StopButtonFlashing(button)
    local animation = self.flashAnimations and self.flashAnimations[button]

    if animation then
        animation:Stop()
        button.Flash:Hide()
    end
end

function module:UpdateButtonFlashing(button)
    if button.flashing and button:IsVisible() then
        self:StartButtonFlashing(button)
    else
        self:StopButtonFlashing(button)
    end
end

function module:UpdatePetActionButtonWatched(button)
    local slot = button:GetID() or 0
    local _, _, _, _, _, _, _, checksRange = GetPetActionInfo(slot)

    if button:IsVisible() and checksRange then
        self.watchedPetActions[button] = true
    else
        self.watchedPetActions[button] = nil
    end

    local function handleUpdate()
        if module:UpdatePetActionButtonStates() then
            After(UPDATE_DELAY, handleUpdate)
        end
    end
    
end

function module:UpdatePetActionButtonStates()
    local updatedButtons = false

    if next(self.watchedPetActions) then
        for button in pairs(self.watchedPetActions) do
            button.icon:SetVertexColor(unpack(cfg[getPetActionButtonState(button)]))
        end

        updatedButtons = true
    end

    return updatedButtons
end

function module:OnActive()
    local function registerCallback(header)
        if not header then return end

        LAB.RegisterCallback(header, "OnButtonUsable", function(_, button)
            button.icon:SetVertexColor(unpack(cfg[getActionButtonState(button)]))
        end)

        if cfg.flashAnimations then
            LAB.RegisterCallback(header, "OnButtonState", function(_, button)
                module:UpdateButtonFlashing(button)
            end)
        end
    end

    for i = 1, 8 do
        registerCallback(_G["DarkUI_ActionBar"..i])
    end

    local extraHeaders = {
        "DarkUIExtraButtons_MainLeftBar",
        "DarkUIExtraButtons_MainRightBar",
        "DarkUIExtraButtons_TopLeftBar",
        "DarkUIExtraButtons_TopRightBar"
    }
    
    for _, header in next, extraHeaders do
        registerCallback(header) 
    end

    -- register pet actions, if we want to
    if cfg.petActions then
        -- register all pet action slots
        self.petActions = {}
        self.watchedPetActions = {}

        for i = 1, NUM_PET_ACTION_SLOTS do
            tinsert(self.petActions, _G["PetActionButton" .. i])
        end

        local function petButton_OnShowHide(button)
            self:UpdatePetActionButtonWatched(button)
            self:UpdateButtonFlashing(button)
        end

        local function petButton_OnUpdate(button)
            -- button:SetScript("OnUpdate", nil)
            button:HookScript("OnShow", petButton_OnShowHide)
            button:HookScript("OnHide", petButton_OnShowHide)
            self:UpdatePetActionButtonWatched(button)
        end

        local function petActionBar_Update(bar)
            -- the UI does not actually use the self arg here
            -- and sometimes calls the method without it
            bar = bar or _G.PetActionBarFrame

            -- reset the timer on update, so that we don"t trigger the bar"s
            -- own range updater code
            bar.rangeTimer = nil

            -- if we have a bar, update all the actions
            if PetHasActionBar() then
                for _, button in pairs(self.petActions) do
                    -- clear our current styling
                    self.buttonStates[button] = nil
                    self:UpdatePetActionButtonWatched(button)
                end
                -- if we don"t, wipe any actions we currently are showing
            else
                wipe(self.watchedPetActions)
            end
        end

        -- hook any pet button events we need to take care of
        -- register events on update initially, and wipe out their individual on
        -- update handlers.
        local PetActionBar = _G.PetActionBar
        if type(PetActionBar.Update) == "function" then
            hooksecurefunc(PetActionBar, "Update", petActionBar_Update)
        end

        local buttons = PetActionBar.actionButtons
        if type(buttons) == "table" then
            for _, button in pairs(PetActionBar.actionButtons) do
                hooksecurefunc(button, "OnUpdate", petButton_OnUpdate)
                hooksecurefunc(button, "StartFlash", function(button)
                    if button:IsVisible() then
                        self:StartButtonFlashing(button)
                    end
                end)
            end
        end
    end
end
