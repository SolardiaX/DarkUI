------------------------------------------------------------------------
-- DebuffsIndicator (debuff icons with dispel-type border on raid frames)
------------------------------------------------------------------------
local _, ns = ...
local oUF = ns.oUF
local E, C = select(2, ...):unpack()

local UnitIsConnected = UnitIsConnected

local NUM_BUTTONS = 2

local DispellColor = {
    ["Magic"]   = { 0.2, 0.6, 1 },
    ["Curse"]   = { 0.6, 0, 1 },
    ["Disease"] = { 0.6, 0.4, 0 },
    ["Poison"]  = { 0, 0.6, 0 },
}

local blacklist = {}

local function CreateButton(element, index)
    local button = CreateFrame("Frame", nil, element)
    button:SetSize(element.size or 16, element.size or 16)
    button:SetFrameLevel(element:GetFrameLevel() + 3)
    button:Hide()

    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetAllPoints()
    button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    button.cd = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    button.cd:SetAllPoints()
    button.cd:SetReverse(true)
    button.cd:SetHideCountdownNumbers(true)

    button.count = button:CreateFontString(nil, "OVERLAY")
    button.count:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
    button.count:SetPoint("BOTTOMRIGHT", 4, -2)
    button.count:SetJustifyH("RIGHT")

    button:CreateShadow()

    return button
end

local function FilterDebuff(spellId, isBossAura, caster)
    if blacklist[spellId] then return false end
    if isBossAura then return true end
    if AuraUtil.ShouldDisplayDebuff(caster, spellId) then return true end
    return false
end

local function Update(self, _, unit)
    if self.unit ~= unit then return end

    local element = self.DebuffsIndicator
    if not element or not element.enable then return end

    for i = 1, NUM_BUTTONS do
        element.buttons[i]:Hide()
    end

    if not UnitIsConnected(unit) then return end

    local shown = 0
    local i = 0
    while true do
        i = i + 1
        local data = C_UnitAuras.GetAuraDataByIndex(unit, i, "HARMFUL")
        if not data then break end
        if shown >= NUM_BUTTONS then break end

        local spellId = data.spellId
        if spellId and not issecretvalue(spellId) and FilterDebuff(spellId, data.isBossAura, data.sourceUnit) then
            shown = shown + 1
            local button = element.buttons[shown]
            button.icon:SetTexture(data.icon)

            if data.applications and data.applications > 1 then
                button.count:SetText(data.applications)
                button.count:Show()
            else
                button.count:Hide()
            end

            if data.duration and data.duration > 0 then
                button.cd:SetCooldown(data.expirationTime - data.duration, data.duration)
                button.cd:Show()
            else
                button.cd:Hide()
            end

            local c = data.dispelName and DispellColor[data.dispelName]
            if button.__shadow then
                if c then
                    button.__shadow:SetBackdropBorderColor(c[1], c[2], c[3])
                else
                    button.__shadow:SetBackdropBorderColor(0, 0, 0)
                end
            end

            button:Show()
        end
    end
end

local function Path(self, ...)
    return (self.DebuffsIndicator.Override or Update)(self, ...)
end

local function ForceUpdate(element)
    return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
    local element = self.DebuffsIndicator
    if not element then return end

    element.__owner = self
    element.ForceUpdate = ForceUpdate

    if C.aura.raidDebuffsBlack then
        blacklist = C.aura.raidDebuffsBlack
    end

    element.buttons = {}
    for i = 1, NUM_BUTTONS do
        local button = CreateButton(element, i)
        if i == 1 then
            button:SetPoint("BOTTOMLEFT", element, "BOTTOMLEFT", 2, 2)
        else
            button:SetPoint("LEFT", element.buttons[i - 1], "RIGHT", 2, 0)
        end
        element.buttons[i] = button
    end

    self:RegisterEvent("UNIT_AURA", Path)
    return true
end

local function Disable(self)
    local element = self.DebuffsIndicator
    if not element then return end

    for i = 1, NUM_BUTTONS do
        element.buttons[i]:Hide()
    end

    self:UnregisterEvent("UNIT_AURA", Path)
end

oUF:AddElement("DebuffsIndicator", Path, Enable, Disable)
