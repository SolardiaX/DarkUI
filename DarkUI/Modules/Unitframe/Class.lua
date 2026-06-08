local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Class Power (Blizzard native bars, reparented to DarkUI)
------------------------------------------------------------------------
local core = E:Module("Unitframe")
local module = core:Sub("Class")

local cfg = C.unitframe
local classCfg = cfg.classModule.classpowerbar

------------------------------------------------------------------------
-- Reparent Blizzard ClassPower container to DarkUI player frame
------------------------------------------------------------------------

-- Bars use layoutParent (managed frame system) which relies on OnShow
-- to move them into the container. On fresh login, PlayerFrame isn't
-- shown yet when addons load, so OnShow never fires and bars remain
-- children of PlayerFrame. We must explicitly reparent them.
local managedBars = {
    "DruidComboPointBarFrame",
    "EssencePlayerFrame",
    "RuneFrame",
    "TotemFrame",
}

function core:SetupClassPower(self)
    if not classCfg.blizzard then return end

    local container = PlayerFrameBottomManagedFramesContainer
    if not container then return end

    -- Reparent container to DarkUI player frame
    container:SetParent(self)
    container:ClearAllPoints()
    container:SetPoint(unpack(classCfg.position))
    container:Show()

    -- Explicitly move class bars into the container
    -- (bypasses OnShow/AddManagedFrame which doesn't fire on fresh login)
    for _, name in ipairs(managedBars) do
        local bar = _G[name]
        if bar then
            bar:SetParent(container)
        end
    end

    container:Layout()

    container.SetPoint = E.Dummy
    container.SetParent = E.Dummy

    -- oUF disables PlayerFrame, so Blizzard's PlayerFrame_ToPlayerArt/ToVehicleArt
    -- never fires. We must re-trigger bar setup on power type change (druid shapeshift).
    core:RegisterEvent("UNIT_DISPLAYPOWER", function(_, _, unit)
        if unit ~= "player" then return end
        if PlayerFrame.classPowerBar then
            PlayerFrame.classPowerBar:Setup()
        end
        if EssencePlayerFrame then
            EssencePlayerFrame:Setup()
        end
        container:Layout()
    end)
end
