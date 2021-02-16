local _, ns = ...
local E, C, L = ns:unpack()
local oUF = ns.oUF or oUF

local modifier = "shift" -- shift, alt or ctrl
local mouseButton = "1" -- 1 = left, 2 = right, 3 = middle, 4 and 5 = thumb buttons if there are any
local pending = {}

local function SetFocusHotkey(frame)
    if not frame or frame.focuser then return end

    if not InCombatLockdown() then
        frame:SetAttribute(modifier .. "-type" .. mouseButton, "focus")
        frame.focuser = true
        pending[frame] = nil
    else
        pending[frame] = true
    end
end

local function CreateFrame_Hook(_, name, _, template)
    if name and template == "SecureUnitButtonTemplate" then
        SetFocusHotkey(_G[name])
    end
end

hooksecurefunc("CreateFrame", CreateFrame_Hook)

-- Keybinding override so that models can be shift/alt/ctrl+clicked
local f = CreateFrame("CheckButton", "FocuserButton", UIParent, "SecureActionButtonTemplate")
f:SetAttribute("type1", "macro")
f:SetAttribute("macrotext", "/focus mouseover")
SetOverrideBindingClick(FocuserButton, true, modifier .. "-BUTTON" .. mouseButton, "FocuserButton")

f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:SetScript("OnEvent", function()
    if event == "PLAYER_REGEN_ENABLED" then
        if next(pending) then
            for frame in next, pending do
                SetFocusHotkey(frame)
            end
        end
    else
        for _, object in next, oUF.objects do
            if not object.focuser then
                SetFocusHotkey(object)
            end
        end
    end
end)
