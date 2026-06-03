local E, C, L = select(2, ...):unpack()

-- Out of Range
local module = E:Module("Actionbar"):Sub("StyleRange")
local LAB = LibStub("LibActionButton-1.0")

local cfg = C.actionbar.styles.range

module.flashAnimations = {}

local function getPetActionButtonState(button)
    local slot = button:GetID() or 0
    local _, _, _, _, _, _, _, checksRange, inRange = GetPetActionInfo(slot)
    local isUsable, notEnoughMana = GetPetActionSlotUsable(slot)

    if isUsable then
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
    if button._state_type == "custom" then
        return "normal"
    end

    local action = button._state_action
    if not action then
        return "normal"
    end

    local actionType, actionTypeId = GetActionInfo(action)

    if not actionType then
        return "normal"
    end

    if actionType == "macro" then
        local name = GetMacroInfo(actionTypeId)
        if name and name:sub(1, 1) == "#" then
            local spellId = GetMacroSpell(actionTypeId)
            if spellId then
                local costs = GetSpellPowerCost(spellId)
                if costs then
                    for _, cost in ipairs(costs) do
                        if UnitPower("player", cost.type) < cost.minCost then
                            return "oom"
                        end
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

        self.flashAnimations[button] = animation
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

function module:OnEnable()
    local function registerCallback(header)
        if not header then
            return
        end

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
        registerCallback(_G["DarkUI_ActionBar" .. i])
    end

    local extraHeaders = {
        "DarkUIExtraButtons_MainLeftBar",
        "DarkUIExtraButtons_MainRightBar",
        "DarkUIExtraButtons_TopLeftBar",
        "DarkUIExtraButtons_TopRightBar",
    }

    for _, header in next, extraHeaders do
        registerCallback(_G[header])
    end

    -- Pet action range coloring
    if cfg.petActions then
        self.petActions = {}
        self.watchedPetActions = {}
        self.buttonStates = {}

        for i = 1, NUM_PET_ACTION_SLOTS do
            tinsert(self.petActions, _G["PetActionButton" .. i])
        end

        local function petButton_OnShowHide(button)
            self:UpdatePetActionButtonWatched(button)
            self:UpdateButtonFlashing(button)
        end

        local function petButton_Setup(button)
            button:SetScript("OnUpdate", nil)
            button:HookScript("OnShow", petButton_OnShowHide)
            button:HookScript("OnHide", petButton_OnShowHide)
            self:UpdatePetActionButtonWatched(button)
        end

        local function petActionBar_Update(bar)
            bar = bar or PetActionBarFrame
            bar.rangeTimer = nil

            if PetHasActionBar() then
                for _, button in pairs(self.petActions) do
                    self.buttonStates[button] = nil
                    self:UpdatePetActionButtonWatched(button)
                end
            else
                wipe(self.watchedPetActions)
            end
        end

        local PetActionBarFrame = PetActionBar
        if PetActionBarFrame and type(PetActionBarFrame.Update) == "function" then
            hooksecurefunc(PetActionBarFrame, "Update", petActionBar_Update)
        end

        if PetActionBarFrame then
            local buttons = PetActionBarFrame.actionButtons
            if type(buttons) == "table" then
                for _, button in pairs(buttons) do
                    petButton_Setup(button)
                    hooksecurefunc(button, "StartFlash", function(btn)
                        if btn:IsVisible() then
                            self:StartButtonFlashing(btn)
                        end
                    end)
                end
            end
        end
    end
end
