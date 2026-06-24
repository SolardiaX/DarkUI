local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF not loaded")

------------------------------------------------------------------------
-- Classification Indicator (elite/rare/boss icons on nameplates)
------------------------------------------------------------------------

local UnitClassification = UnitClassification

local atlases = {
	elite = "nameplates-icon-elite-gold",
	worldboss = "nameplates-icon-elite-gold",
	rareelite = "nameplates-icon-elite-silver",
	rare = "nameplates-icon-elite-silver",
}

local function Update(self)
	local element = self.ClassificationIndicator
	if not element then return end

	if element.PreUpdate then element:PreUpdate() end

	local classification = UnitClassification(self.unit)
	local atlas = atlases[classification]

	if atlas then
		element:SetAtlas(atlas)
		element:Show()
	else
		element:Hide()
	end

	if element.PostUpdate then return element:PostUpdate(classification) end
end

local function Path(self, ...)
	return (self.ClassificationIndicator.Override or Update)(self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
	local element = self.ClassificationIndicator
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", Path)
		self:RegisterEvent("UNIT_NAME_UPDATE", Path)

		return true
	end
end

local function Disable(self)
	local element = self.ClassificationIndicator
	if element then
		element:Hide()
		self:UnregisterEvent("UNIT_CLASSIFICATION_CHANGED", Path)
		self:UnregisterEvent("UNIT_NAME_UPDATE", Path)
	end
end

oUF:AddElement("ClassificationIndicator", Path, Enable, Disable)
