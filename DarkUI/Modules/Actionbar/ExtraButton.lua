local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
--	EtraButton
----------------------------------------------------------------------------------------
local module = E:Module("Actionbar"):Sub("ExtraButton")
local actionButton = LibStub("DarkUI-ActionButton")
local LAB = LibStub("LibActionButton-1.0")

local _G = _G
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local HasAction = HasAction
local GetCVar = GetCVar
local C_PetBattles_IsInBattle = C_PetBattles.IsInBattle
local GameTooltip = _G.GameTooltip
local hooksecurefunc = hooksecurefunc
local unpack, pairs, tonumber, tinsert, twipe = unpack, pairs, tonumber, table.insert, table.wipe

local ExtraButtons_PREFIX = "DarkUIExtraButtons_"
local ExtraButtons = {
    [1] = {
        name   = "MainLeft",
        bindName = "DarkUIExtraButtonsMainLeftButton", flyout="LEFT",
        parent = "DarkUI_ActionBar1",
        pos    = { "TOPRIGHT", "DarkUI_ActionBar1Button1", "TOPLEFT", -10, 7 },
        size   = 56
    },
    [2] = {
        name   = "MainRight",
        bindName = "DarkUIExtraButtonsMainRightButton", flyout="RIGHT",
        parent = "DarkUI_ActionBar1",
        pos    = { "TOPLEFT", "DarkUI_ActionBar1Button12", "TOPRIGHT", 11, 7 },
        size   = 56
    },
    [3] = {
        name   = "TopLeft",
        bindName = "DarkUIExtraButtonsTopLeftButton", flyout="UP",
        parent = "DarkUI_ActionBar2",
        pos    = { "BOTTOMRIGHT", "DarkUIExtraButtons_MainLeftBar", "TOPLEFT", -11, -3 },
        size   = 56
    },
    [4] = {
        name   = "TopRight",
        bindName = "DarkUIExtraButtonsTopRightButton", flyout="UP",
        parent = "DarkUI_ActionBar2",
        pos    = { "BOTTOMLEFT", "DarkUIExtraButtons_MainRightBar", "TOPRIGHT", 7, -3 },
        size   = 56
    }
}

local ExtraButtons_Lite_Pos = {
    [1] = { "TOPRIGHT", "DarkUI_ActionBar1Button1", "TOPLEFT", -11, 6 },
    [2] = { "TOPLEFT", "DarkUI_ActionBar1Button12", "TOPRIGHT", 12, 6 },
    [3] = { "BOTTOM", "DarkUIExtraButtons_MainLeftButton", "TOP", 1, 5 },
    [4] = { "BOTTOM", "DarkUIExtraButtons_MainRightButton", "TOP", 2, 5 },
}

local ExtraButtons_Lite_Size = {
    [1] = 55,
    [2] = 55,
    [3] = 50,
    [4] = 50,
}

local function createBar(cfg, index)
    if not _G[cfg.parent] then return end

    local name = ExtraButtons_PREFIX .. cfg.name
    local bar = CreateFrame("Frame", name .. "Bar", _G[cfg.parent], "SecureHandlerStateTemplate")

    bar.buttons = {}
    bar.flyoutDirection = cfg.flyout

    bar:SetPoint(unpack(cfg.pos))
    bar:SetSize(cfg.size, cfg.size)

    local button = actionButton:CreateButton(bar, index, cfg.size, cfg.bindName, name .. "Button")
    button:SetAllPoints(bar)
    
    tinsert(bar.buttons, button)

    bar:SetAttribute("_onstate-page", [[
        self:SetAttribute("state", newstate)
        control:ChildUpdate("state", newstate)
    ]])

    LAB.RegisterCallback(bar, "OnButtonUpdate", function(_, button)
        button:SetAlpha(1)
    end)

    return bar
end

function module:OnInit()
    self.bars = {}

    local locked = GetCVar("lockActionBars")
    local index = E.myClass == "DRUID" and 92 or 107

    for i = 1, 4 do
        local cfg = ExtraButtons[i]

        if C.general.liteMode then
            cfg.pos = ExtraButtons_Lite_Pos[i]
            cfg.size = ExtraButtons_Lite_Size[i]
        end
        
        local bar = createBar(cfg, i+index)
        
        self.bars[cfg.name] = bar
    end

    actionButton:UpdateBarConfig(self.bars)

    if C_PetBattles_IsInBattle() then
        actionButton:ClearBindings(self.bars)
    else
        actionButton:ReassignBindings(self.bars)
    end

    self:RegisterEvent("CVAR_UPDATE", function(_, _, var, value)
        if var == "lockActionBars" then
            if InCombatLockdown() then
                self:RegisterEventOnce("PLAYER_REGEN_ENABLED", function()
                    actionButton:UpdateBarConfig(self.bars)
                    -- toggleLock(value)
                end)
            else
                actionButton:UpdateBarConfig(self.bars)
                -- toggleLock(value)
            end
        end
    end)

    self:RegisterEvent("UPDATE_BINDINGS PET_BATTLE_CLOSE", function() actionButton:ReassignBindings(self.bars) end)
    self:RegisterEvent("PET_BATTLE_OPENING_DONE", function() actionButton:ClearBindings(self.bars) end)
end