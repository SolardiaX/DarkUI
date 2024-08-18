local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable then return end

----------------------------------------------------------------------------------------
--    ExtraActionBar (modified from ShestakUI)
----------------------------------------------------------------------------------------
local module = E:Module("Actionbar"):Sub("BarExtra")

local _G = _G
local CreateFrame = CreateFrame
local RegisterStateDriver = RegisterStateDriver
local HasExtraActionBar = HasExtraActionBar
local unpack, tinsert = unpack, tinsert
local hooksecurefunc = hooksecurefunc
local UIParent = _G.UIParent
local ExtraActionBarFrame = _G.ExtraActionBarFrame
local ExtraActionButton1 = _G.ExtraActionButton1
local ZoneAbilityFrame = _G.ZoneAbilityFrame

local cfg = C.actionbar.bars.barextra

function module:OnInit()
    -- extra bar
    local extraBar = CreateFrame("Frame", "DarkUI_ExtraBarHolder", UIParent)
    extraBar:SetSize(cfg.button.size, cfg.button.size)
    extraBar:SetPoint(unpack(cfg.pos))
    extraBar.buttonList = {}

    RegisterStateDriver(extraBar, "visibility", "[petbattle] hide; show")

    -- Prevent reanchor
    ExtraActionBarFrame:EnableMouse(false)
    ExtraActionBarFrame.ignoreInLayout = true
    ExtraActionBarFrame:SetParent(extraBar)
    ExtraActionBarFrame:ClearAllPoints()
    ExtraActionBarFrame:SetAllPoints()

    hooksecurefunc(ExtraActionBarFrame, "SetParent", function(self, parent)
        if parent == ExtraAbilityContainer then
            self:SetParent(extraBar)
        end
    end)

    local button = ExtraActionButton1
    button:SetSize(cfg.button.size, cfg.button.size)
    E:StyleButton(button, 2)

    button.style:SetTexture(nil)
    hooksecurefunc(button.style, "SetTexture", function(style, texture)
        if texture then
            style:SetTexture(nil)
        end
    end)

    tinsert(extraBar.buttonList, button)

    --create the mouseover functionality
    if cfg.fader_mouseover then
        E:ButtonBarFader(extraBar, extraBar.buttonList, cfg.fader_mouseover.fadeIn, cfg.fader_mouseover.fadeOut)
    end

    --create the combat fader
    if cfg.fader_combat then
        E:CombatFrameFader(extraBar, cfg.fader_combat.fadeIn, cfg.fader_combat.fadeOut)
    end

    --zone ability
    local zoneBar = CreateFrame("Frame", "DarkUI_ZoneAbilityBarHolder", UIParent)
    zoneBar:SetSize(cfg.button.size, cfg.button.size)
    zoneBar:SetPoint("BOTTOM", extraBar, "TOP", 0, 10)

    RegisterStateDriver(zoneBar, "visibility", "[petbattle] hide; show")

    -- Prevent reanchor
    ZoneAbilityFrame.ignoreInLayout = true
    ZoneAbilityFrame:SetParent(zoneBar)
    ZoneAbilityFrame:ClearAllPoints()
    ZoneAbilityFrame:SetPoint("CENTER", zoneBar)
    ZoneAbilityFrame.SpellButtonContainer:SetPoint("CENTER", zoneBar)
    ZoneAbilityFrame.SpellButtonContainer:SetSize(cfg.button.size, cfg.button.size)
    ZoneAbilityFrame.SpellButtonContainer.spacing = 3
    ZoneAbilityFrame.Style:SetAlpha(0)

    hooksecurefunc("ExtraActionBar_Update", function()
        if HasExtraActionBar() then
            zoneBar:SetPoint("BOTTOM", extraBar, "TOP", 0, 10)
        else
            zoneBar:SetPoint(unpack(cfg.pos))
        end
    end)

    --    Skin ZoneAbilityFrame
    hooksecurefunc(ZoneAbilityFrame, "UpdateDisplayedZoneAbilities", function(self)
        local previous = nil
        for spellButton in self.SpellButtonContainer:EnumerateActive() do
            if spellButton and not spellButton.__styled then
                spellButton:SetSize(cfg.button.size, cfg.button.size)
                E:StyleButton(spellButton)

                spellButton:ClearAllPoints()
                if previous == nil then
                    spellButton:SetPoint("CENTER", zoneBar, "CENTER")
                else
                    spellButton:SetPoint("BOTTOM", previous, "TOP", 0, 5)
                end
            end
        end
    end)
end
