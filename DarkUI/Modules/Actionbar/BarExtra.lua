local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable then return end

----------------------------------------------------------------------------------------
--	ExtraActionBar (modified from ShestakUI)
----------------------------------------------------------------------------------------

local _G = _G
local CreateFrame = CreateFrame
local RegisterStateDriver = RegisterStateDriver
local unpack, tinsert = unpack, tinsert
local UIParent = _G.UIParent
local ExtraActionBarFrame = _G.ExtraActionBarFrame
local ExtraActionButton1 = _G.ExtraActionButton1
local ZoneAbilityFrame = _G.ZoneAbilityFrame

local cfg = C.actionbar.bars.barextra

-- extra bar
local extraBar = CreateFrame("Frame", "DarkUI_ExtraBarHolder", UIParent)
extraBar:SetSize(cfg.button.size, cfg.button.size)
extraBar:SetPoint(unpack(cfg.pos))
extraBar.buttonList = {}

RegisterStateDriver(extraBar, "visibility", "[petbattle] hide; show")

-- Prevent reanchor
ExtraActionBarFrame:EnableMouse(false)
ExtraAbilityContainer:SetParent(extraBar)
ExtraAbilityContainer:ClearAllPoints()
ExtraAbilityContainer:SetAllPoints()
ExtraActionBarFrame.ignoreInLayout = true
ExtraAbilityContainer.ignoreFramePositionManager = true

ExtraAbilityContainer.SetSize = E.dummy
ExtraAbilityContainer:SetScript("OnShow", nil)
ExtraAbilityContainer:SetScript("OnHide", nil)

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

------------------------------------------------------------------------------------------
--	Skin ExtraActionBarFrame(by Zork)
------------------------------------------------------------------------------------------
local button = ExtraActionButton1
local icon = ExtraActionButton1Icon

tinsert(extraBar.buttonList, button)

button:SetSize(cfg.button.size, cfg.button.size)
button:SetAttribute("showgrid", 1)
button.Count:SetFont(unpack(C.media.standard_font))
button.Count:SetShadowOffset(1, -1)
button.Count:SetPoint("BOTTOMRIGHT", 0, 1)
button.Count:SetJustifyH("RIGHT")

hooksecurefunc("ExtraActionBar_Update", function()
    local bar = ExtraActionBarFrame

	if (HasExtraActionBar()) then
		button.style:SetTexture("")
		icon:SetInside()
	end
end)

--create the mouseover functionality
if cfg.fader_mouseover then
    E:ButtonBarFader(extraBar, extraBar.buttonList, cfg.fader_mouseover.fadeIn, cfg.fader_mouseover.fadeOut)
end

--create the combat fader
if cfg.fader_combat then
    E:CombatFrameFader(extraBar, cfg.fader_combat.fadeIn, cfg.fader_combat.fadeOut)
end

-- ------------------------------------------------------------------------------------------
-- --	Skin ZoneAbilityFrame
-- ------------------------------------------------------------------------------------------
hooksecurefunc(ZoneAbilityFrame, "UpdateDisplayedZoneAbilities", function(self)
    local previous = nil
    for spellButton in self.SpellButtonContainer:EnumerateActive() do
        if spellButton and not spellButton.styled then
            --spellButton.NormalTexture:SetAlpha(0)
            spellButton:SetPushedTexture(C.media.button.pushed) --force it to gain a texture
            spellButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
            spellButton:SetSize(cfg.button.size, cfg.button.size)
            spellButton:CreateTextureBorder()
            spellButton:CreateBackdrop()

            spellButton.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            spellButton.Icon:SetPoint("TOPLEFT", spellButton, 2, -2)
            spellButton.Icon:SetPoint("BOTTOMRIGHT", spellButton, -2, 2)
            spellButton.Icon:SetDrawLayer("BACKGROUND", 7)

            spellButton.Count:SetFont(unpack(C.media.standard_font))
            spellButton.Count:SetShadowOffset(1, -1)
            spellButton.Count:SetPoint("BOTTOMRIGHT", 0, 1)
            spellButton.Count:SetJustifyH("RIGHT")

            spellButton.Cooldown:SetAllPoints(spellButton.Icon)

            spellButton:ClearAllPoints()
            if previous == nil then
                spellButton:SetPoint("CENTER", zoneBar, "CENTER")
            else
                spellButton:SetPoint("BOTTOM", previous, "TOP", 0, 5)
            end

            spellButton.styled = true
        end
    end
end)