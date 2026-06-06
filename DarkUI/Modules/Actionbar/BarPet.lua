local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
-- PetActionBar
----------------------------------------------------------------------------------------
local module = E:Module("Actionbar"):Sub("BarPet")

local cfg = C.actionbar.bars.barpet
local num = NUM_PET_ACTION_SLOTS

local function hasPetActionHighlightMark(index)
    if PET_ACTION_HIGHLIGHT_MARKS then
        return PET_ACTION_HIGHLIGHT_MARKS[index]
    end
    return false
end

local function updatePetBar()
    if not PetHasActionBar() then
        return
    end

    for i = 1, num do
        local buttonName = "PetActionButton" .. i
        local petActionButton = _G[buttonName]
        local petActionIcon = petActionButton.icon
        local petAutoCastOverlay = petActionButton.AutoCastOverlay or petActionButton.AutoCastable

        local name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled, spellID = GetPetActionInfo(i)

        if not isToken then
            petActionIcon:SetTexture(texture)
            petActionButton.tooltipName = name
        else
            petActionIcon:SetTexture(_G[texture])
            petActionButton.tooltipName = _G[name]
        end

        petActionButton.isToken = isToken

        if spellID then
            local spell = Spell:CreateFromSpellID(spellID)
            petActionButton.spellDataLoadedCancelFunc = spell:ContinueWithCancelOnSpellLoad(function()
                petActionButton.tooltipSubtext = spell:GetSpellSubtext()
            end)
        end

        if isActive then
            if IsPetAttackAction(i) then
                petActionButton:StartFlash()
                petActionButton:GetCheckedTexture():SetAlpha(0.5)
            else
                petActionButton:StopFlash()
                petActionButton:GetCheckedTexture():SetAlpha(1.0)
            end
            petActionButton:SetChecked(true)
        else
            petActionButton:StopFlash()
            petActionButton:SetChecked(false)
        end

        if petAutoCastOverlay then
            petAutoCastOverlay:SetShown(autoCastAllowed)
            if petAutoCastOverlay.ShowAutoCastEnabled then
                petAutoCastOverlay:ShowAutoCastEnabled(autoCastEnabled)
            end
        end

        if texture then
            if GetPetActionSlotUsable(i) then
                petActionIcon:SetVertexColor(1, 1, 1)
                petActionIcon:SetDesaturation(0)
            else
                petActionIcon:SetVertexColor(0.4, 0.4, 0.4)
                petActionIcon:SetDesaturation(1)
            end
            petActionIcon:Show()
        else
            petActionIcon:Hide()
        end

        SharedActionButton_RefreshSpellHighlight(petActionButton, hasPetActionHighlightMark(i))
    end
end

function module:OnInit()
    local bar = CreateFrame("Frame", "DarkUI_PetActionBarHolder", UIParent, "SecureHandlerStateTemplate")
    bar:SetWidth(num * cfg.button.size + (num - 1) * cfg.button.space)
    bar:SetHeight(cfg.button.size)
    bar:SetPoint(unpack(cfg.pos))
    bar.buttonList = {}

    PetActionBar:SetParent(bar)

    bar:RegisterEvent("UNIT_PET")
    bar:RegisterEvent("UNIT_FLAGS")
    bar:RegisterEvent("UNIT_AURA")
    bar:RegisterEvent("PET_UI_UPDATE")
    bar:RegisterEvent("PET_BAR_UPDATE")
    bar:RegisterEvent("PET_BAR_UPDATE_USABLE")
    bar:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
    bar:RegisterEvent("PLAYER_ENTERING_WORLD")
    bar:RegisterEvent("PLAYER_CONTROL_LOST")
    bar:RegisterEvent("PLAYER_CONTROL_GAINED")
    bar:RegisterEvent("PLAYER_TARGET_CHANGED")
    bar:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED")
    bar:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
    bar:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")

    bar:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_ENTERING_WORLD" then
            for i = 1, num do
                local button = _G["PetActionButton" .. i]
                tinsert(self.buttonList, button)

                button:SetSize(cfg.button.size, cfg.button.size)
                button:ClearAllPoints()
                button:SetParent(self)
                button:Show()

                if i == 1 then
                    button:SetPoint("BOTTOMLEFT", self, 0, 0)
                else
                    local previous = _G["PetActionButton" .. i - 1]
                    button:SetPoint("LEFT", previous, "RIGHT", cfg.button.space, 0)
                end
            end

            RegisterStateDriver(bar, "visibility", "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; [pet] show; hide")

            if cfg.fader_mouseover then
                E:ButtonBarFader(self, bar.buttonList, cfg.fader_mouseover.fadeIn, cfg.fader_mouseover.fadeOut)
            end

            if cfg.fader_combat then
                E:CombatFrameFader(bar, cfg.fader_combat.fadeIn, cfg.fader_combat.fadeOut)
            end
        elseif event == "PET_BAR_UPDATE_COOLDOWN" then
            PetActionBar:UpdateCooldowns()
        else
            updatePetBar()
        end
    end)

    hooksecurefunc(_G["PetActionButton10"], "SetPoint", function(_, _, anchor)
        if InCombatLockdown() then
            return
        end
        if anchor and anchor == PetActionBar then
            for i = 1, num do
                local button = _G["PetActionButton" .. i]
                button:SetParent(bar)
                button:ClearAllPoints()
                if i == 1 then
                    button:SetPoint("BOTTOMLEFT", 0, 0)
                else
                    local previous = _G["PetActionButton" .. i - 1]
                    button:SetPoint("LEFT", previous, "RIGHT", cfg.button.space, 0)
                end
            end
        end
    end)
end
