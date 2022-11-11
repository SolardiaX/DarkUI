local E, C, L = select(2, ...):unpack()

local ExtraButtons_PREFIX = "DarkUIExtraButtons_"
local ExtraButtons = {
    [1] = {
        name   = "MainLeft",
        parent = "DarkUI_ActionBar1HolderBG",
        pos    = { "TOPRIGHT", _G["ActionButton1"], "TOPLEFT", -10, 7 },
        size   = { 56, 56 }
    },
    [2] = {
        name   = "MainRight",
        parent = "DarkUI_ActionBar1HolderBG",
        pos    = { "TOPLEFT", _G["ActionButton12"], "TOPRIGHT", 10.5, 7 },
        size   = { 56, 56 }
    },
    [3] = {
        name   = "TopLeft",
        parent = "DarkUI_ActionBar3HolderBG",
        pos    = { "TOPRIGHT", _G["MultiBarBottomRightButton1"], "TOPLEFT", -36, -41 },
        size   = { 56, 56 }
    },
    [4] = {
        name   = "TopRight",
        parent = "DarkUI_ActionBar3HolderBG",
        pos    = { "TOPLEFT", _G["MultiBarBottomRightButton12"], "TOPRIGHT", 35, -41 },
        size   = { 56, 56 }
    }
}

local ExtraButtons_Lite_Pos = {
    [1] = { "TOPRIGHT", _G["ActionButton1"], "TOPLEFT", -12.5, 4 },
    [2] = { "TOPLEFT", _G["ActionButton12"], "TOPRIGHT", 14.5, 4 },
    [3] = { "TOPRIGHT", _G["MultiBarBottomLeftButton1"], "TOPLEFT", -11.5, 8 },
    [4] = { "TOPLEFT", _G["MultiBarBottomLeftButton12"], "TOPRIGHT", 14.5, 8 },
}

local ExtraButtons_Lite_Size = {
    [1] = { 51, 51 },
    [2] = { 51, 51 },
    [3] = { 51, 51 },
    [4] = { 51, 51 },
}

local function Button_OnEnter(self)
    --ActionButton_SetTooltip(self)
    self:SetTooltip()
end

local function Button_OnLeave(self)
    GameTooltip:Hide()
end

--[[ Create ]]
local Extra = CreateFrame("Frame", nil, UIParent, "SecureFrameTemplate")
Extra.buttons = {}

function Extra:CreateButton(index, config)
    local name = ExtraButtons_PREFIX .. config.name

    local bar = CreateFrame("Frame", name .. "Bar", _G[config.parent], "SecureHandlerStateTemplate")
    bar:SetFrameStrata("MEDIUM")
    bar:SetSize(unpack(C.general.liteMode and ExtraButtons_Lite_Size[index] or config.size))
    bar:SetID(0)
    bar:SetPoint(unpack(C.general.liteMode and ExtraButtons_Lite_Pos[index] or config.pos))

    local button = CreateFrame("CheckButton", name .. "Button", bar, "ActionBarButtonTemplate")

    button:SetID(0)
    button:SetAllPoints()
    button:SetScript("OnEnter", Button_OnEnter)
    button:SetScript("OnLeave", Button_OnLeave)
    button:SetAttribute('showgrid', 1)
    button:SetAttribute('type', 'action')
    --button:SetAttribute("action", 113 + index)
    if E.class == "DRUID" then
        button:SetAttribute('action', index + 92)
    else
        button:SetAttribute('action', index + 107)
    end

    Extra.buttons[name] = button
end

function Extra:Init()
    for index, config in pairs(ExtraButtons) do
        Extra:CreateButton(index, config)
    end

    local cvar = GetCVar("alwaysShowActionBars") or "0"
    Extra.showgrid = tonumber(cvar)

    -- add events for grid, must after bars initial
    self:RegisterEvent("ACTIONBAR_SHOWGRID")
    self:RegisterEvent("ACTIONBAR_HIDEGRID")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    -- hooks for grid
    hooksecurefunc("MultiActionBar_ShowAllGrids", function()
        Extra.showgrid = 1
        Extra:UpdateGrid()
    end)
    hooksecurefunc("MultiActionBar_HideAllGrids", function()
        Extra.showgrid = 0
        Extra:UpdateGrid()
    end)
end

function Extra:OnEvent(event, ...)
    if event == "PLAYER_REGEN_ENABLED" then
        if InCombatLockdown() then
        else
            self:CallAfterCombat()
        end
    else
        self:OnUpdateGridEvent(event)
    end
end

Extra:SetScript("OnEvent", Extra.OnEvent)

function Extra:OnUpdateGridEvent(event, ...)
    -- event stuff
    if event == "ACTIONBAR_SHOWGRID" then
        Extra.showgrid = 1
    elseif event == "ACTIONBAR_HIDEGRID" then
        Extra.showgrid = 0
    else
        self:SafeCallFunc(self.UpdateGrid)
    end
end

function Extra:UpdateGrid()
    -- in combat we can't let it be shown or hidden
    if InCombatLockdown() then return end

    if GetCVar("alwaysShowActionBars") == "1" then Extra.showgrid = 1 end

    for _, button in pairs(Extra.buttons) do
        button:SetAttribute("showgrid", Extra.showgrid)

        if Extra.showgrid > 0 then
            if not button:GetAttribute("statehidden") then
                button:Show()
                _G[button:GetName() .. "NormalTexture"]:SetVertexColor(1.0, 1.0, 1.0, 0.5)
            end
        elseif not HasAction(button.action) then
            button:Hide()
        end
    end
end

Extra.AfterCombatCallList = {}

function Extra:InitAfterCombat()
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
end

function Extra:RegisterSafeCallObj(func, ...)
    --self.AfterCombatCallList[tostring(func)] = {func, {...}}
    table.insert(self.AfterCombatCallList, { func, { ... } })
end

function Extra:SafeCallFunc(func, ...)
    assert(type(func) == 'function',
           'Wrong param for Extra.SafeCallFunc, need a function type, got ' .. type(func))

    if InCombatLockdown() then
        Extra:RegisterSafeCallObj(func, ...)
    else
        func(...)
    end
end

function Extra:CallAfterCombat()
    local index, pack
    for index, pack in pairs(self.AfterCombatCallList) do
        pack[1](unpack(pack[2]))
    end

    table.wipe(self.AfterCombatCallList)
end

-- self init
Extra:Init()

-- init AfterCombat Events
Extra:InitAfterCombat()
