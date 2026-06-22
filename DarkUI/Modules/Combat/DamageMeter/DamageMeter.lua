local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- DamageMeter Skin
------------------------------------------------------------------------

local module = E:Module("Combat"):Sub("DamageMeter")

local cfg
local C_Timer_After = C_Timer.After

------------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------------

function module:ForEachWindow(callback)
    for i = 1, 3 do
        local window = _G["DamageMeterSessionWindow" .. i]
        if window then
            callback(window)
        end
    end
end

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    cfg = C.combat.damageMeter
    if not cfg or not cfg.enable then return end
    module.cfg = cfg

    if C_CVar.GetCVar("damageMeterEnabled") ~= "1" then
        C_CVar.SetCVar("damageMeterEnabled", "1")
    end

    if C_AddOns.IsAddOnLoaded("Blizzard_DamageMeter") then
        self:Bootstrap()
    end

    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("ADDON_LOADED")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED")
    eventFrame:SetScript("OnEvent", function(_, event, arg1)
        if event == "ADDON_LOADED" and arg1 == "Blizzard_DamageMeter" then
            self:Bootstrap()
            eventFrame:UnregisterEvent("ADDON_LOADED")
        elseif event == "PLAYER_ENTERING_WORLD" then
            C_Timer_After(0.5, function() self:Refresh() end)
        elseif event == "EDIT_MODE_LAYOUTS_UPDATED" then
            C_Timer_After(0.5, function() self:Refresh() end)
        end
    end)
    module.eventFrame = eventFrame
end

function module:Bootstrap()
    if module._bootstrapped then return end
    module._bootstrapped = true

    module.Texture:Init()
    module.Hover:Init()
    module.Snap:Init()
    module.Reset:Init()
end

function module:Refresh()
    if not _G.DamageMeter then return end
    if not module._bootstrapped then return end
    module.Texture:Refresh()
    module.Snap:Refresh()
    module.Hover:RefreshTargets()
end
