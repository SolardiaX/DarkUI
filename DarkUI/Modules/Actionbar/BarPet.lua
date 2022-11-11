local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable then return end

----------------------------------------------------------------------------------------
--	PetActionBar (modified from Tukui)
----------------------------------------------------------------------------------------

local _G = _G
local CreateFrame = CreateFrame
local RegisterStateDriver = RegisterStateDriver
local unpack, tinsert = unpack, tinsert
local UIParent = _G.UIParent
local PetActionBar = _G.PetActionBar

local cfg = C.actionbar.bars.barpet
local num = NUM_PET_ACTION_SLOTS

local function updatePetBar()
    for i = 1, num, 1 do
        local buttonName = "PetActionButton"..i
        local petActionButton = _G[buttonName]
        local petActionIcon = _G[buttonName.."Icon"]
        local petAutoCastableTexture = _G[buttonName].AutoCastable or _G[buttonName.."AutoCastable"]
        local petAutoCastShine = _G[buttonName.."Shine"]

        local name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i)

        if not isToken then
            petActionIcon:SetTexture(texture)
            petActionButton.tooltipName = name
        else
            petActionIcon:SetTexture(_G[texture])
            petActionButton.tooltipName = _G[name]
        end

        petActionButton.isToken = isToken

        if isActive and name ~= "PET_ACTION_FOLLOW" then
            petActionButton:SetChecked(true)
            if IsPetAttackAction(i) then
                petActionButton:StartFlash()
            end
        else
            petActionButton:SetChecked(false)
            if IsPetAttackAction(i) then
                petActionButton:StopFlash()
                petActionButton:GetCheckedTexture():SetAlpha(1.0)
            end
        end

        if autoCastAllowed then
            petAutoCastableTexture:Show()
        else
            petAutoCastableTexture:Hide()
        end

        if autoCastEnabled then
            AutoCastShine_AutoCastStart(petAutoCastShine)
        else
            AutoCastShine_AutoCastStop(petAutoCastShine)
        end

        if texture then
            if GetPetActionSlotUsable(i) then
                SetDesaturation(petActionIcon, nil)
            else
                SetDesaturation(petActionIcon, 1)
            end
            petActionIcon:Show()
        else
            petActionIcon:Hide()
        end

        if not PetHasActionBar() and texture and name ~= "PET_ACTION_FOLLOW" then
            petActionButton:StopFlash()
            SetDesaturation(petActionIcon, 1)
            petActionButton:SetChecked(false)
        end
    end
end

local bar = CreateFrame("Frame", "DarkUI_PetActionBarHolder", UIParent, "SecureHandlerStateTemplate")
bar:SetWidth(num * cfg.button.size + (num - 1) * cfg.button.space)
bar:SetHeight(cfg.button.size)
bar:SetPoint(unpack(cfg.pos))
bar.buttonList = {}

bar:RegisterEvent("PLAYER_ENTERING_WORLD")
bar:RegisterEvent("PLAYER_CONTROL_LOST")
bar:RegisterEvent("PLAYER_CONTROL_GAINED")
bar:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED")
bar:RegisterEvent("PET_BAR_UPDATE")
bar:RegisterEvent("PET_BAR_UPDATE_USABLE")
bar:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
bar:RegisterEvent("UNIT_PET")
bar:RegisterEvent("UNIT_FLAGS")
bar:RegisterEvent("UNIT_AURA")
bar:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        PetActionBar:EnableMouse(false)
        PetActionBar_ShowGrid = E.dummy
        PetActionBar.UpdateGridLayout = E.dummy
        PetActionBar.showgrid = nil

        PetActionBar:UnregisterAllEvents()

        PetActionBar_Update = updatePetBar

        for i = 1, num do
            local button = _G["PetActionButton" .. i]
            tinsert(bar.buttonList, button) --add the button object to the list

            button:SetSize(cfg.button.size, cfg.button.size)
            button:ClearAllPoints()
            button:SetParent(bar)
            button:Show()
            
            if i == 1 then
                button:SetPoint("BOTTOMLEFT", bar, 0, 0)
            else
                local previous = _G["PetActionButton" .. i - 1]
                button:SetPoint("LEFT", previous, "RIGHT", cfg.button.space, 0)
            end

            -- button.SetPoint = function() return end

            bar:SetAttribute("addchild", button)
        end

        RegisterStateDriver(bar, "visibility", "[@pet,exists,nopossessbar] show; hide")
        hooksecurefunc(PetActionBar, "Update", updatePetBar)

        --create the mouseover functionality
        if cfg.fader_mouseover then
            E:ButtonBarFader(bar, bar.buttonList, cfg.fader_mouseover.fadeIn, cfg.fader_mouseover.fadeOut)
        end

        --create the combat fader
        if cfg.fader_combat then
            E:CombatFrameFader(bar, cfg.fader_combat.fadeIn, cfg.fader_combat.fadeOut)
        end
    elseif event == "PET_BAR_UPDATE" or event == "PLAYER_CONTROL_LOST" or event == "PLAYER_CONTROL_GAINED" or event == "PLAYER_FARSIGHT_FOCUS_CHANGED"
	or event == "UNIT_FLAGS" or (event == "UNIT_PET" and arg1 == "player") or (event == "UNIT_AURA" and arg1 == "pet") then
		updatePetBar()
	elseif event == "PET_BAR_UPDATE_COOLDOWN" then
		PetActionBar:UpdateCooldowns()
	end
end)