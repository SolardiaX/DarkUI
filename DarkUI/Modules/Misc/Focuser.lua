local ns = select(2, ...)
local E, C, L = ns:unpack()
local oUF = ns.oUF

------------------------------------------------------------------------
-- Focuser
------------------------------------------------------------------------

local module = E:Module("Misc"):Sub("Focuser")

local cfg = C.misc

local modifier = "shift"
local mouseButton = "1"
local pending = {}

local InCombatLockdown = InCombatLockdown
local next, strmatch = next, string.match

local function setupFocus(frame)
    if not frame or frame.focuser then return end
    local name = frame.GetName and frame:GetName()
    if name and strmatch(name, "oUF_NPs") then return end

    if not InCombatLockdown() then
        frame:SetAttribute(modifier .. "-type" .. mouseButton, "focus")
        frame.focuser = true
        pending[frame] = nil
    else
        pending[frame] = true
    end
end

local function onCreateFrame(_, name, _, template)
    if name and template == "SecureUnitButtonTemplate" then
        setupFocus(_G[name])
    end
end

function module:OnInit()
    if not cfg.focuser then return end

    local f = CreateFrame("CheckButton", "FocuserButton", UIParent, "SecureActionButtonTemplate")
    f:SetAttribute("type1", "macro")
    f:SetAttribute("macrotext", "/focus mouseover")
    SetOverrideBindingClick(f, true, modifier .. "-BUTTON" .. mouseButton, "FocuserButton")
    f:RegisterForClicks("LeftButtonUp", "LeftButtonDown")

    hooksecurefunc("CreateFrame", onCreateFrame)

    self:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        for _, object in next, oUF.objects do
            if not object.focuser then
                setupFocus(object)
            end
        end
    end)

    self:RegisterEvent("PLAYER_REGEN_ENABLED", function()
        if next(pending) then
            for frame in next, pending do
                setupFocus(frame)
            end
        end
    end)

    self:RegisterEvent("GROUP_ROSTER_UPDATE", function()
        for _, object in next, oUF.objects do
            if not object.focuser then
                setupFocus(object)
            end
        end
    end)
end
