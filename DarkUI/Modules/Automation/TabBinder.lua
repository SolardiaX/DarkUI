local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Tab Binder
------------------------------------------------------------------------

local module = E:Module("Automation"):Sub("TabBinder")

local cfg = C.automation

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg.tab_binder then return end

    local RTB_Fail = false

    local function updateBindings()
        local bindSet = GetCurrentBindingSet()
        if bindSet ~= 1 and bindSet ~= 2 then return end
        if InCombatLockdown() then
            RTB_Fail = true
            return
        end

        local pvpType = C_PvP.GetZonePVPInfo()
        local _, zoneType = IsInInstance()

        local targetKey = GetBindingKey("TARGETNEARESTENEMYPLAYER")
            or GetBindingKey("TARGETNEARESTENEMY")
            or "TAB"

        local lastTargetKey = GetBindingKey("TARGETPREVIOUSENEMYPLAYER")
            or GetBindingKey("TARGETPREVIOUSENEMY")
            or "SHIFT-TAB"

        local currentBind = GetBindingAction(targetKey)
        local isPvP = (zoneType == "arena" or zoneType == "pvp" or pvpType == "combat")

        local wantedTarget = isPvP and "TARGETNEARESTENEMYPLAYER" or "TARGETNEARESTENEMY"
        local wantedPrev = isPvP and "TARGETPREVIOUSENEMYPLAYER" or "TARGETPREVIOUSENEMY"

        if currentBind ~= wantedTarget then
            local success = SetBinding(targetKey, wantedTarget)
            if lastTargetKey then
                SetBinding(lastTargetKey, wantedPrev)
            end
            if success then
                SaveBindings(bindSet)
                RTB_Fail = false
            else
                RTB_Fail = true
            end
        end
    end

    self:RegisterEvent("PLAYER_ENTERING_WORLD", updateBindings)
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", updateBindings)

    self:RegisterEvent("PLAYER_REGEN_ENABLED", function()
        if RTB_Fail then updateBindings() end
    end)

    self:RegisterEvent("DUEL_REQUESTED", updateBindings)
    self:RegisterEvent("DUEL_FINISHED", updateBindings)
end
