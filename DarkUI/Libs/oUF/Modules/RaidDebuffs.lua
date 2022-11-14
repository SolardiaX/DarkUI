----------------------------------------------------------------------------------------
--	Based on oUF_RaidDebuffs (modified from NDUI)
----------------------------------------------------------------------------------------
local _, ns = ...
local oUF = ns.oUF
local E, C, L = ns:unpack()

local class = select(2, UnitClass('player'))
local RaidDebuffsIgnore, invalidPrio = {}, -1

local DispellColor = {
    ["Magic"]   = { .2, .6, 1 },
    ["Curse"]   = { .6, 0, 1 },
    ["Disease"] = { .6, .4, 0 },
    ["Poison"]  = { 0, .6, 0 },
    ["none"]    = { 0, 0, 0 },
}

local DispellPriority = {
    ["Magic"]   = 4,
    ["Curse"]   = 3,
    ["Disease"] = 2,
    ["Poison"]  = 1,
}

local CanDispel = {
	DRUID = {Magic = false, Curse = true, Poison = true},
	EVOKER = {Magic = false, Curse = true, Poison = true, Disease = true},
	MAGE = {Curse = true},
	MONK = {Magic = false, Poison = true, Disease = true},
	PALADIN = {Magic = false, Poison = true, Disease = true},
	PRIEST = {Magic = false, Disease = true},
	SHAMAN = {Magic = false, Curse = true}
}

local DispellFilter = CanDispel[class] or {}

local function checkSpecs()
    local spec = GetSpecialization()
    if class == "DRUID" then
        if spec == 4 then
            DispellFilter.Magic = true
        else
            DispellFilter.Magic = false
        end
    elseif class == "MONK" then
        if spec == 2 then
            DispellFilter.Magic = true
        else
            DispellFilter.Magic = false
        end
    elseif class == "PALADIN" then
        if spec == 1 then
            DispellFilter.Magic = true
        else
            DispellFilter.Magic = false
        end
    elseif class == "PRIEST" then
        if spec == 3 then
            DispellFilter.Magic = false
            DispellFilter.Disease = false
        else
            DispellFilter.Magic = true
            DispellFilter.Disease = true
        end
    elseif class == "SHAMAN" then
        if spec == 3 then
            DispellFilter.Magic = true
        else
            DispellFilter.Magic = false
        end
    end
end

local abs = math.abs
local function OnUpdate(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed >= 0.1 then
        local timeLeft = self.expirationTime - GetTime()
        if self.reverse then timeLeft = abs((self.expirationTime - GetTime()) - self.duration) end
        if timeLeft > 0 then
            local text = E:FormatTime(timeLeft)
            self.time:SetText(text)
        else
            self:SetScript("OnUpdate", nil)
            self.time:Hide()
        end
        self.elapsed = 0
    end
end

local function UpdateDebuffFrame(self, name, icon, count, debuffType, duration, expiration)
    local rd = self.RaidDebuffs
    if name then
        if rd.icon then
            rd.icon:SetTexture(icon)
            rd.icon:Show()
        end

        if rd.count then
            if count and count > 1 then
                rd.count:SetText(count)
                rd.count:Show()
            else
                rd.count:Hide()
            end
        end

        if rd.timer then
            rd.duration = duration
            if duration and duration > 0 then
                rd.expiration = expiration
                rd:SetScript("OnUpdate", OnUpdate)
                rd.timer:Show()
            else
                rd:SetScript("OnUpdate", nil)
                rd.timer:Hide()
            end
        end

        if rd.cd then
            if duration and duration > 0 then
                rd.cd:SetCooldown(expiration - duration, duration)
                rd.cd:Show()
            else
                rd.cd:Hide()
            end
        end

        local c = DispellColor[debuffType] or DispellColor.none
	if rd.ShowDebuffBorder and rd.__shadow then
		rd.__shadow:SetBackdropBorderColor(c[1], c[2], c[3])
        end

        if rd.glowFrame then
            if rd.priority == 6 then
                ShowOverlayGlow(rd.glowFrame)
            else
                HideOverlayGlow(rd.glowFrame)
            end
        end

        rd:Show()
    else
        rd:Hide()
    end
end

local instName
local function checkInstance()
    if IsInInstance() then
        instName = GetInstanceInfo()
    else
        instName = nil
    end
end

local function Update(self, _, unit)
    if unit ~= self.unit then return end

    local rd = self.RaidDebuffs
    rd.priority = invalidPrio
    rd.filter = "HARMFUL"

    local _name, _icon, _count, _debuffType, _duration, _expiration
    local debuffs = rd.Debuffs or {}
    local isCharmed = UnitIsCharmed(unit)
    local canAttack = UnitCanAttack("player", unit)
    local prio

    for i = 1, 32 do
        local name, icon, count, debuffType, duration, expiration, _, _, _, spellId = UnitAura(unit, i, rd.filter)
        if not name then break end

        if rd.ShowDispellableDebuff and debuffType and (not isCharmed) and (not canAttack) then
            if rd.FilterDispellableDebuff then
                prio = DispellFilter[debuffType] and (DispellPriority[debuffType] + 6) or 2
                if prio == 2 then debuffType = nil end
            else
                prio = DispellPriority[debuffType]
            end

            if prio and prio > rd.priority then
                rd.priority, rd.index = prio, i
                _name, _icon, _count, _debuffType, _duration, _expiration = name, icon, count, debuffType, duration, expiration
            end
        end

        local instPrio
        if instName and debuffs[instName] then
            instPrio = debuffs[instName][spellId]
        end

        if not RaidDebuffsIgnore[spellId] and instPrio and (instPrio == 6 or instPrio > rd.priority) then
            rd.priority, rd.index = instPrio, i
            _name, _icon, _count, _debuffType, _duration, _expiration = name, icon, count, debuffType, duration, expiration
        end
    end

    if rd.priority == invalidPrio then
		rd.index, rd.spellID, _name = nil, nil, nil
    end

    UpdateDebuffFrame(self, _name, _icon, _count, _debuffType, _duration, _expiration)
end

local function Path(self, ...)
    return (self.RaidDebuffs.Override or Update)(self, ...)
end

local function ForceUpdate(element)
    return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
    local rd = self.RaidDebuffs
    if rd then
        self:RegisterEvent("UNIT_AURA", Path)
        rd.ForceUpdate = ForceUpdate
        rd.__owner = self
        return true
    end

    checkSpecs()
    self:RegisterEvent("PLAYER_TALENT_UPDATE", checkSpecs, true)
    checkInstance()
    self:RegisterEvent("PLAYER_ENTERING_WORLD", checkInstance, true)
end

local function Disable(self)
    if self.RaidDebuffs then
        self:UnregisterEvent("UNIT_AURA", Path)
        self.RaidDebuffs:Hide()
        self.RaidDebuffs.__owner = nil
    end

    self:UnregisterEvent("PLAYER_TALENT_UPDATE", checkSpecs)
    self:UnregisterEvent("PLAYER_ENTERING_WORLD", checkInstance)
end

oUF:AddElement("RaidDebuffs", Update, Enable, Disable)
