local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable then return end

----------------------------------------------------------------------------------------
--	ActionBar Button Style (modified from NDui)
----------------------------------------------------------------------------------------
local module = E:Module("Actionbar"):Sub("StyleButton")
local LAB = LibStub("LibActionButton-1.0")

local _G = _G
local SpellFlyout = SpellFlyout
local NUM_ACTIONBAR_BUTTONS = NUM_ACTIONBAR_BUTTONS
local NUM_STANCE_SLOTS = NUM_STANCE_SLOTS or 10
local NUM_POSSESS_SLOTS = NUM_POSSESS_SLOTS or 2
local NUM_PET_ACTION_SLOTS = NUM_PET_ACTION_SLOTS

local cfg = C.actionbar.styles.buttons

local function styleButton(button)
    E:StyleActionButton(button, true)

    if not cfg.showMacroName then
        local name = button.Name or _G[buttonName.."Name"]
        if name then name:SetAlpha(0) end
    end

    if not cfg.showCooldown then
        local cooldown = button.cooldown or _G[buttonName.."Cooldown"]
        if cooldown then cooldown:SetAlpha(0) end
    end

    if not cfg.showHotkey then
        local hotkey = button.HotKey or _G[buttonName.."HotKey"]
        if hotkey then hotkey:SetAlpha(0) end
    end

    if not cfg.showStackCount then
        local count = button.Count or _G[buttonName.."Count"]
        if count then count:SetAlpha(0) end
    end
end

function module:OnActive()
    for i = 1, 8 do
        for j = 1, NUM_ACTIONBAR_BUTTONS do
            styleButton(_G["DarkUI_ActionBar"..i.."Button"..j])
        end
    end

    --petbar buttons
    for i = 1, NUM_PET_ACTION_SLOTS do
        styleButton(_G["PetActionButton"..i])
    end

    --stancebar buttons
    for i = 1, NUM_STANCE_SLOTS do
        styleButton(_G["StanceButton"..i])
    end

    --possess buttons
    for i = 1, NUM_POSSESS_SLOTS do
        styleButton(_G["PossessButton" .. i])
    end

    --extra action button
    styleButton(ExtraActionButton1)

    --bag buttons
    local bagButtons = {
        _G.MainMenuBarBackpackButton,
        _G.CharacterBag0Slot,
        _G.CharacterBag1Slot,
        _G.CharacterBag2Slot,
        _G.CharacterBag3Slot,
        _G.CharacterReagentBag0Slot
    }
    for _, button in next, bagButtons do
        styleButton(button)
    end

    --spell flyout
    SpellFlyout.Background:SetAlpha(0)
    local numFlyouts = 1
    local function checkForFlyoutButtons()
        local button = _G["SpellFlyoutButton"..numFlyouts]
        while button do
            styleButton(button)
            numFlyouts = numFlyouts + 1
            button = _G["SpellFlyoutButton"..numFlyouts]
        end
    end
    SpellFlyout:HookScript("OnShow", checkForFlyoutButtons)
    SpellFlyout:HookScript("OnHide", checkForFlyoutButtons)

    --LAB SpellFlyout
    if LAB.flyoutHandler then
        for _, button in next, LAB.FlyoutButtons do
            button:SetScale(1)
            styleButton(button)
        end

        LAB.RegisterCallback(LAB.flyoutHandler, "OnButtonUpdate", function(_, button)
            if button:GetParent() ~= LAB.flyoutHandler then
                return
            end

            if button:GetParent():GetParent() ~= UIParent then
                button:SetSize(button:GetParent():GetParent():GetSize())
                styleButton(button)
            end
        end)

		LAB.flyoutHandler.Background:Hide()
	end

    -- LAB Equiped Callback
    LAB.RegisterCallback(module, "OnButtonUpdate", function(_, button)
        if not button.backdrop then return end

        if button.Border:IsShown() then
            button.backdrop:SetBackdropBorderColor(0, .7, .1)
        else
            button.backdrop:SetBackdropBorderColor(0, 0, 0)
        end
    end)

    --DarkUI extra buttons
    styleButton(_G["DarkUIExtraButtons_MainLeftButton"])
    styleButton(_G["DarkUIExtraButtons_MainRightButton"])
    styleButton(_G["DarkUIExtraButtons_TopLeftButton"])
    styleButton(_G["DarkUIExtraButtons_TopRightButton"])
end