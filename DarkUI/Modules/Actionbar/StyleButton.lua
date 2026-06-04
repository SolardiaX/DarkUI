local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
-- Button Style
----------------------------------------------------------------------------------------
local module = E:Module("Actionbar"):Sub("StyleButton")
local LAB = LibStub("LibActionButton-1.0")

local cfg = C.actionbar.styles.buttons

local function styleButton(button)
    if not button then
        return
    end

    E:StyleActionButton(button, true)

    local buttonName = button:GetName()

    if not cfg.showMacroName then
        local name = button.Name or (buttonName and _G[buttonName .. "Name"])
        if name then
            name:SetAlpha(0)
        end
    end

    if not cfg.showCooldown then
        local cooldown = button.cooldown or (buttonName and _G[buttonName .. "Cooldown"]) or button.Cooldown
        if cooldown then
            cooldown:SetAlpha(0)
        end
    end

    if not cfg.showHotkey then
        local hotkey = button.HotKey or (buttonName and _G[buttonName .. "HotKey"])
        if hotkey then
            hotkey:SetAlpha(0)
        end
    end

    if not cfg.showStackCount then
        local count = button.Count or (buttonName and _G[buttonName .. "Count"])
        if count then
            count:SetAlpha(0)
        end
    end
end

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

    -- Equipped border color
    LAB.RegisterCallback(module, "OnButtonUpdate", function(_, button)
        if not button.__bg then
            return
        end
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
