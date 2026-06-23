local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- DamageMeter Snap (window attach / position memory)
------------------------------------------------------------------------

local module = E:Module("Combat"):Sub("DamageMeter")

local BASE_FRAME_NAME = "DamageMeterSessionWindow"
local SPACING = 1

local cfg

local dragHookCache = setmetatable({}, { __mode = "k" })
local snappedStateCache = setmetatable({}, { __mode = "k" })

------------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------------

local function getSideInset() return 5 end

local function stripControl(window)
    if not window then return end
    if window.ResizeButton then window.ResizeButton:Hide() end
    if window.ResizeGrip then window.ResizeGrip:Hide() end
    if window.MinimizeContainer then
        if window.MinimizeContainer.ResizeButton then window.MinimizeContainer.ResizeButton:Hide() end
        if window.MinimizeContainer.ResizeGrip then window.MinimizeContainer.ResizeGrip:Hide() end
    end
end

local function restoreControl(window)
    if not window then return end
    if window.ResizeButton then window.ResizeButton:Show() end
    if window.ResizeGrip then window.ResizeGrip:Show() end
    if window.MinimizeContainer then
        if window.MinimizeContainer.ResizeButton then window.MinimizeContainer.ResizeButton:Show() end
        if window.MinimizeContainer.ResizeGrip then window.MinimizeContainer.ResizeGrip:Show() end
    end
end

------------------------------------------------------------------------
-- Drag & Position Memory
------------------------------------------------------------------------

local function setupDragAndMemory(window, index)
    if not window or dragHookCache[window] then return end

    window:SetMovable(true)
    window:RegisterForDrag("LeftButton")

    local origDragStart = window:GetScript("OnDragStart")
    window:SetScript("OnDragStart", function(self, ...)
        if snappedStateCache[self] then return end
        if origDragStart then
            origDragStart(self, ...)
        else
            self:StartMoving()
        end
    end)

    local origDragStop = window:GetScript("OnDragStop")
    window:SetScript("OnDragStop", function(self, ...)
        if snappedStateCache[self] then return end
        if origDragStop then
            origDragStop(self, ...)
        else
            self:StopMovingOrSizing()
        end
    end)

    hooksecurefunc(window, "StopMovingOrSizing", function(self)
        if snappedStateCache[self] then return end
        local p, _, rp, x, y = self:GetPoint()
        module.Snap.freePositions[index] = { point = p, relativePoint = rp, x = x, y = y }
    end)

    dragHookCache[window] = true
end

local function restoreFreePositions()
    local freePositions = module.Snap.freePositions
    for i = 2, 3 do
        local window = _G[BASE_FRAME_NAME .. i]
        if window and freePositions[i] then
            local isAttached = cfg.enableSnap and i > 1
            if not isAttached then
                local pos = freePositions[i]
                window:ClearAllPoints()
                window:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y)
                snappedStateCache[window] = false
            end
        end
    end
end

local function rescueStuckWindow(window, index)
    if not window then return end
    if module.Snap.freePositions[index] then return end

    local pt, rel, rp, x, y = window:GetPoint()
    local isRelUIParent = (not rel) or (rel == UIParent)
    local isStuckAtTopLeft = (pt == "TOPLEFT" and isRelUIParent and (not x or x == 0) and (not y or y == 0))
    local isSizeBugged = window:GetWidth() < 100 or window:GetHeight() < 50

    if isStuckAtTopLeft or isSizeBugged then
        window:SetMovable(true)
        window:ClearAllPoints()
        window:SetPoint("CENTER", UIParent, "CENTER", (index - 1) * 50, -(index - 1) * 50)
        if isSizeBugged then window:SetSize(300, 200) end
        window:SetUserPlaced(true)
    end
end

local function detachWindow(window, index)
    if not window then return end
    restoreControl(window)

    window:SetMovable(true)
    window:RegisterForDrag("LeftButton")
    snappedStateCache[window] = false

    if module.Snap.freePositions[index] then
        local pos = module.Snap.freePositions[index]
        window:ClearAllPoints()
        window:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y)
        return
    end

    rescueStuckWindow(window, index)
end

------------------------------------------------------------------------
-- Snapping
------------------------------------------------------------------------

local function snapWindowTo(current, target, direction, useCustomSize, customVal)
    if not current or not target or not target:IsShown() then return end

    stripControl(current)
    current:SetMovable(true)

    local targetW = target:GetWidth()
    local targetH = target:GetHeight()
    local currentW = targetW
    local currentH = targetH

    if direction == "TOP" or direction == "BOTTOM" then
        if useCustomSize and customVal then currentH = customVal end
    elseif direction == "LEFT" or direction == "RIGHT" then
        if useCustomSize and customVal then currentW = customVal end
    end

    current:ClearAllPoints()
    current:SetWidth(currentW)
    current:SetHeight(currentH)

    if direction == "TOP" then
        current:SetPoint("BOTTOMLEFT", target, "TOPLEFT", 0, SPACING)
        current:SetPoint("BOTTOMRIGHT", target, "TOPRIGHT", 0, SPACING)
    elseif direction == "BOTTOM" then
        current:SetPoint("TOPLEFT", target, "BOTTOMLEFT", 0, -SPACING)
        current:SetPoint("TOPRIGHT", target, "BOTTOMRIGHT", 0, -SPACING)
    elseif direction == "LEFT" then
        local inset = getSideInset()
        current:SetPoint("TOPRIGHT", target, "TOPLEFT", -SPACING + inset, 0)
        current:SetPoint("BOTTOMRIGHT", target, "BOTTOMLEFT", -SPACING + inset, 0)
    elseif direction == "RIGHT" then
        local inset = getSideInset()
        current:SetPoint("TOPLEFT", target, "TOPRIGHT", SPACING - inset, 0)
        current:SetPoint("BOTTOMLEFT", target, "BOTTOMRIGHT", SPACING - inset, 0)
    end

    snappedStateCache[current] = true
end

------------------------------------------------------------------------
-- Snap Module
------------------------------------------------------------------------

module.Snap = {}
module.Snap.freePositions = {}

function module.Snap:Refresh()
    if InCombatLockdown() then return end
    if EditModeManagerFrame and EditModeManagerFrame:IsShown() then return end

    local win1 = _G[BASE_FRAME_NAME .. "1"]
    local win2 = _G[BASE_FRAME_NAME .. "2"]
    local win3 = _G[BASE_FRAME_NAME .. "3"]

    if win2 then rescueStuckWindow(win2, 2) end
    if win3 then rescueStuckWindow(win3, 3) end

    if win2 then setupDragAndMemory(win2, 2) end
    if win3 then setupDragAndMemory(win3, 3) end

    if not cfg.enableSnap then
        restoreFreePositions()
        if win2 and win2:IsShown() then detachWindow(win2, 2) end
        if win3 and win3:IsShown() then detachWindow(win3, 3) end
        return
    end

    if not win1 or not win1:IsShown() then return end

    if win2 and win2:IsShown() then
        local pos = cfg.win2Position or "TOP"
        local useCustom = cfg.win2CustomSize or false
        local customVal = cfg.win2SizeVal or 150
        snapWindowTo(win2, win1, pos, useCustom, customVal)
    end

    if win3 and win3:IsShown() then
        local targetIndex = cfg.win3Target or 2
        local targetWin = _G[BASE_FRAME_NAME .. targetIndex]
        local pos = cfg.win3Position or "TOP"
        local useCustom = cfg.win3CustomSize or false
        local customVal = cfg.win3SizeVal or 150

        if targetIndex == 2 and (not win2 or not win2:IsShown()) then targetWin = win1 end
        snapWindowTo(win3, targetWin, pos, useCustom, customVal)
    end
end

function module.Snap:Init()
    cfg = module.cfg
    self:Refresh()
end
