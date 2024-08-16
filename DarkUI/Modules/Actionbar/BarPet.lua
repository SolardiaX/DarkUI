local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable then return end

----------------------------------------------------------------------------------------
--	PetActionBar (modified from ShestakUI)
----------------------------------------------------------------------------------------
local module = E:Module("Actionbar"):Sub("BarPet")

local _G = _G
local CreateFrame = CreateFrame
local IsPetAttackAction = IsPetAttackAction
local AutoCastShine_AutoCastStart, AutoCastShine_AutoCastStop = AutoCastShine_AutoCastStart, AutoCastShine_AutoCastStop
local GetPetActionSlotUsable, GetPetActionInfo = GetPetActionSlotUsable, GetPetActionInfo
local PetHasActionBar = PetHasActionBar
local SetDesaturation = SetDesaturation
local RegisterStateDriver = RegisterStateDriver
local SharedActionButton_RefreshSpellHighlight = SharedActionButton_RefreshSpellHighlight
local Spell = Spell
local hooksecurefunc = hooksecurefunc
local unpack, tinsert = unpack, tinsert
local UIParent = _G.UIParent
local PetActionBar = _G.PetActionBar
local InCombatLockdown = InCombatLockdown
local PET_ACTION_HIGHLIGHT_MARKS = _G.PET_ACTION_HIGHLIGHT_MARKS

local cfg = C.actionbar.bars.barpet
local num = NUM_PET_ACTION_SLOTS

local function updatePetBar()
    for i = 1, num, 1 do
        local buttonName = "PetActionButton"..i
        local petActionButton = _G[buttonName]
        local petActionIcon = petActionButton.icon
        local petAutoCastOverlay = petActionButton.AutoCastOverlay

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
                -- the checked texture looks a little confusing at full alpha (looks like you have an extra ability selected)
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
        petAutoCastOverlay:SetShown(autoCastAllowed)
        petAutoCastOverlay:ShowAutoCastEnabled(autoCastEnabled)
        if texture then
            if GetPetActionSlotUsable(i) then
                petActionIcon:SetVertexColor(1, 1, 1)
            else
                petActionIcon:SetVertexColor(0.4, 0.4, 0.4)
            end
            petActionIcon:Show()
        else
            petActionIcon:Hide()
        end

        SharedActionButton_RefreshSpellHighlight(petActionButton, PET_ACTION_HIGHLIGHT_MARKS[i])
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
                tinsert(self.buttonList, button) --add the button object to the list

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

            --create the mouseover functionality
            if cfg.fader_mouseover then
                E:ButtonBarFader(self, bar.buttonList, cfg.fader_mouseover.fadeIn, cfg.fader_mouseover.fadeOut)
            end

            --create the combat fader
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
        if InCombatLockdown() then return end
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