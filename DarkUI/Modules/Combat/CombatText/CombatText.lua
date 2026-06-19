local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- CombatText (Main Module)
------------------------------------------------------------------------

local module = E:Module("CombatText")
module:SetConfigKey("combattext")

local cfg = C.combattext
module.cfg = cfg

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg or not cfg.enable then
        return
    end

    -- Initialize display layer
    module.Display.Init()

    -- Start CLEU + UNIT_COMBAT outgoing damage detection
    if module.CombatLog then
        module.CombatLog:Enable()
    end

    -- Register all events
    local eventFrame = CreateFrame("Frame")
    for event, _ in pairs(module.handlers) do
        eventFrame:RegisterEvent(event)
    end
    eventFrame:SetScript("OnEvent", function(_, event, ...)
        local handler = module.handlers[event]
        if handler then
            handler(...)
        end
    end)
    module.eventFrame = eventFrame

    -- Hide Blizzard floating combat text
    if cfg.hide_blizzard then
        C_CVar.SetCVar("enableFloatingCombatText", 0)
        C_CVar.SetCVar("floatingCombatTextCombatHealing_v2", 0)
        C_CVar.SetCVar("floatingCombatTextCombatDamage_v2", 0)
    end

    -- Restore CVars on logout
    local logoutFrame = CreateFrame("Frame")
    logoutFrame:RegisterEvent("PLAYER_LOGOUT")
    logoutFrame:SetScript("OnEvent", function()
        if cfg.hide_blizzard then
            C_CVar.SetCVar("enableFloatingCombatText", 1)
            C_CVar.SetCVar("floatingCombatTextCombatHealing_v2", 1)
            C_CVar.SetCVar("floatingCombatTextCombatDamage_v2", 1)
        end
    end)

    -- Slash commands
    local testTicker = nil
    SlashCmdList.XCT = function(input)
        input = (input or ""):lower()
        if input == "test" then
            if testTicker then
                testTicker:Cancel()
                testTicker = nil
                print("|cFF00FFFFxCT|r test stopped.")
                return
            end
            print("|cFF00FFFFxCT|r test started. Type /xct test again to stop.")
            local areas = module.Display.SCROLL_AREAS
            testTicker = C_Timer.NewTicker(0.5, function()
                for name, _ in pairs(areas) do
                    local testEvent = {
                        eligibleScrollFrames = { name },
                        message = "|cFFFFFF00" .. name .. "|r",
                    }
                    module.Display.AnimateEvent(testEvent)
                end
            end)
        end
    end
    SLASH_XCT1 = "/xct"
end
