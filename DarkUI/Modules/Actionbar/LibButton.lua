local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable then return end

----------------------------------------------------------------------------------------
--	ActionButton
----------------------------------------------------------------------------------------
local MAJOR, MINOR = "DarkUI-ActionButton", 1
local actionButton = LibStub:NewLibrary(MAJOR, MINOR)

if not actionButton then return end -- No upgrade needed

local LAB = LibStub("LibActionButton-1.0")

local GetCVarBool = GetCVarBool
local InCombatLockdown = InCombatLockdown
local GetBindingKey = GetBindingKey
local SetOverrideBindingClick, ClearOverrideBindings = SetOverrideBindingClick, ClearOverrideBindings

function actionButton:UpdateButtonConfig(header)
    if not header.buttonConfig then
        header.buttonConfig = {        
            hideElements = {},
            text = {
                hotkey = { font = { STANDARD_TEXT_FONT, 12, "OUTLINE" }, position = {} },
                count = { font = { STANDARD_TEXT_FONT, 12, "OUTLINE" }, position = {} },
                macro = { font = { STANDARD_TEXT_FONT, 12, "OUTLINE" }, position = {} },
            }
        }
    end

    header.buttonConfig.clickOnDown = true
    header.buttonConfig.showGrid = true
    header.buttonConfig.flyoutDirection = header.flyoutDirection

    local lockBars = GetCVarBool("lockActionBars")
    for _, button in next, header.buttons do
        header.buttonConfig.keyBoundTarget = button.bindName
        button.keyBoundTarget = header.buttonConfig.keyBoundTarget

        button:SetAttribute("buttonlock", lockBars)
        button:SetAttribute("unlockedpreventdrag", not lockBars) -- make sure button can drag without being click
        button:SetAttribute("checkmouseovercast", true)
        button:SetAttribute("checkfocuscast", true)
        button:SetAttribute("checkselfcast", true)
        button:SetAttribute("*unit2", "player")
        button:UpdateConfig(header.buttonConfig)
    end
end

function actionButton:UpdateBarConfig(headers)
    for _, bar in next, headers do
        if bar then
            self:UpdateButtonConfig(bar)
        end
    end
end

function actionButton:ReassignBindings(headers)
    if InCombatLockdown() then return end

    for _, bar in next, headers do
        if bar then
            for _, button in next, bar.buttons do
                for _, key in next, {GetBindingKey(button.keyBoundTarget)} do
                    if key and key ~= "" then
                        SetOverrideBindingClick(bar, false, key, button:GetName(), "Keybind")
                    end
                end
            end
        end
    end
end

function actionButton:ClearBindings(headers)
    if InCombatLockdown() then return end

    for _, bar in next, headers do
        if bar then
            ClearOverrideBindings(bar)
        end
    end
end

function actionButton:CreateButton(header, index, size, bindName, btnName)
    local button = LAB:CreateButton(index, btnName or "$parentButton"..index, header)
    button:SetState(0, "action", index)
    button:SetSize(size, size)

    for k = 1, 18 do
        button:SetState(k, "action", (k - 1) * 12 + index)
    end

    button.MasqueSkinned = true
    button.bindName = bindName

    return button
end
