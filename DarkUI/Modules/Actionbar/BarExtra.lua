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
local num = 1

--create the frame to hold the buttons
local extraBar = CreateFrame("Frame", "DarkUI_ExtraBarHolder", UIParent, "SecureHandlerStateTemplate")
extraBar:SetWidth(num * cfg.button.size + (num - 1) * cfg.button.space)
extraBar:SetHeight(cfg.button.size)
extraBar:SetPoint(unpack(cfg.pos))
extraBar.buttonList = {}

--move the buttons into position and reparent them
ExtraActionBarFrame:EnableMouse(false)
ExtraAbilityContainer:SetParent(extraBar)
ExtraAbilityContainer:ClearAllPoints()
ExtraAbilityContainer:SetPoint("CENTER", extraBar)
ExtraAbilityContainer.ignoreFramePositionManager = true

--create the mouseover functionality
if cfg.fader_mouseover then
    E:ButtonBarFader(extraBar, extraBar.buttonList, cfg.fader_mouseover.fadeIn, cfg.fader_mouseover.fadeOut)
end

--create the combat fader
if cfg.fader_combat then
    E:CombatFrameFader(extraBar, cfg.fader_combat.fadeIn, cfg.fader_combat.fadeOut)
end

--the extra button
local button = ExtraActionButton1
tinsert(extraBar.buttonList, button) --add the button object to the list
button:SetSize(cfg.button.size, cfg.button.size)

--show/hide the frame on a given state driver
RegisterStateDriver(extraBar, "visibility", "[petbattle][overridebar][vehicleui] hide; show")

--zone ability
local zoneBar = CreateFrame("Frame", "ZoneAbilityBarHolder", UIParent)
zoneBar:SetWidth(cfg.button.size)
zoneBar:SetHeight(cfg.button.size)
zoneBar:SetPoint("BOTTOM", extraBar, "TOP", 0, 10)

ZoneAbilityFrame:SetParent(zoneBar)
ZoneAbilityFrame:ClearAllPoints()
ZoneAbilityFrame:SetPoint("CENTER", 0, 0)
ZoneAbilityFrame.ignoreFramePositionManager = true
ZoneAbilityFrame.Style:SetAlpha(0)

hooksecurefunc(ZoneAbilityFrame, "UpdateDisplayedZoneAbilities", function(self)
	for spellButton in self.SpellButtonContainer:EnumerateActive() do
		if spellButton and not spellButton.styled then
			spellButton.NormalTexture:SetAlpha(0)
			spellButton:SetPushedTexture(C.media.button.pushed) --force it to gain a texture
			spellButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			spellButton:StripTextures()
			spellButton:SetSize(cfg.button.size, cfg.button.size)
			spellButton:CreateTextureBorder()

			spellButton.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			spellButton.Icon:SetPoint("TOPLEFT", spellButton, 2, -2)
			spellButton.Icon:SetPoint("BOTTOMRIGHT", spellButton, -2, 2)
			spellButton.Icon:SetDrawLayer("BACKGROUND", 7)

			spellButton.Count:SetFont(unpack(C.media.standard_font))
			spellButton.Count:SetShadowOffset(1, -1)
			spellButton.Count:SetPoint("BOTTOMRIGHT", 0, 1)
			spellButton.Count:SetJustifyH("RIGHT")

			spellButton.Cooldown:SetAllPoints(spellButton.Icon)

			spellButton.styled = true
		end
	end
end)

-- Fix button visibility
hooksecurefunc(ZoneAbilityFrame, "SetParent", function(self, parent)
	if parent == ExtraAbilityContainer then
		self:SetParent(zoneFrame)
	end
end)
