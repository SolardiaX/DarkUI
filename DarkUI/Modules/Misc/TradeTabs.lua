local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Trade Tabs
------------------------------------------------------------------------

local module = E:Module("Misc"):Sub("TradeTabs")

local cfg = C.misc

local pairs, tinsert = pairs, table.insert
local InCombatLockdown = InCombatLockdown
local GetProfessions, GetProfessionInfo = GetProfessions, GetProfessionInfo
local PlayerHasToy = PlayerHasToy
local IsPlayerSpell = IsPlayerSpell

local BOOKTYPE_PROFESSION = BOOKTYPE_PROFESSION or 0
local RUNEFORGING_ID = 53428
local PICK_LOCK = 1804
local CHEF_HAT = 134020
local THERMAL_ANVIL = 87216

local tabList = {}
local tabIndex = 0

local onlyPrimary = {
    [171] = true, -- Alchemy
    [182] = true, -- Herbalism
    [186] = true, -- Mining
    [202] = true, -- Engineering
    [356] = true, -- Fishing
    [393] = true, -- Skinning
}

local function createTab(spellID, toyID, itemID)
    local name, texture
    if toyID then
        _, name, texture = C_ToyBox.GetToyInfo(toyID)
    elseif itemID then
        name = C_Item.GetItemNameByID(itemID)
        texture = C_Item.GetItemIconByID(itemID)
    else
        name = C_Spell.GetSpellName(spellID)
        texture = C_Spell.GetSpellTexture(spellID)
    end
    if not name then return end

    tabIndex = tabIndex + 1
    local tab = CreateFrame("CheckButton", nil, ProfessionsFrame, "SecureActionButtonTemplate")
    tab:SetSize(32, 32)
    tab.spellID = spellID
    tab.itemID = toyID or itemID
    tab:RegisterForClicks("AnyUp", "AnyDown")

    if spellID == 818 then
        tab:SetAttribute("type", "macro")
        tab:SetAttribute("macrotext", "/cast [@player]" .. name)
    elseif toyID then
        tab:SetAttribute("type", "toy")
        tab:SetAttribute("toy", toyID)
    elseif itemID then
        tab:SetAttribute("type", "item")
        tab:SetAttribute("item", name)
    else
        tab:SetAttribute("type", "spell")
        tab:SetAttribute("spell", spellID)
    end

    tab:SetNormalTexture(texture)
    tab:SetHighlightTexture([[Interface\Buttons\ButtonHilight-Square]])
    tab:GetHighlightTexture():SetBlendMode("ADD")
    tab:GetHighlightTexture():SetAlpha(0.25)

    local nt = tab:GetNormalTexture()
    if nt then nt:SetTexCoord(0.08, 0.92, 0.08, 0.92) end

    tab.CD = CreateFrame("Cooldown", nil, tab, "CooldownFrameTemplate")
    tab.CD:SetAllPoints()

    tab:SetPoint("TOPLEFT", ProfessionsFrame, "TOPRIGHT", 3, -tabIndex * 38 - 40)

    tab:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(name)
        GameTooltip:Show()
    end)
    tab:SetScript("OnLeave", function() GameTooltip:Hide() end)

    tinsert(tabList, tab)
end

local function updateTabs()
    for _, tab in pairs(tabList) do
        local spellID = tab.spellID
        local itemID = tab.itemID

        if spellID and C_Spell.IsCurrentSpell(spellID) then
            tab:SetChecked(true)
        else
            tab:SetChecked(false)
        end

        if itemID then
            local start, duration = C_Item.GetItemCooldown(itemID)
            if start and duration and duration > 0 then tab.CD:SetCooldown(start, duration) end
        elseif spellID then
            local cooldownInfo = C_Spell.GetSpellCooldown(spellID)
            if cooldownInfo and cooldownInfo.isActive then tab.CD:SetCooldown(cooldownInfo.startTime, cooldownInfo.duration) end
        end
    end
end

local function buildProfessions()
    local prof1, prof2, _, fish, cook = GetProfessions()
    local profs = { prof1, prof2, fish, cook }

    if E.myClass == "DEATHKNIGHT" then
        createTab(RUNEFORGING_ID)
    elseif E.myClass == "ROGUE" and IsPlayerSpell(PICK_LOCK) then
        createTab(PICK_LOCK)
    end

    local isCook
    for _, prof in pairs(profs) do
        if prof then
            local _, _, _, _, numSpells, spelloffset, skillLine = GetProfessionInfo(prof)
            if skillLine == 185 then isCook = true end

            local maxSpells = onlyPrimary[skillLine] and 1 or numSpells
            if maxSpells > 0 then
                for i = 1, maxSpells do
                    local slotID = i + spelloffset
                    if not C_SpellBook.IsSpellBookItemPassive(slotID, BOOKTYPE_PROFESSION) then
                        local info = C_SpellBook.GetSpellBookItemInfo(slotID, BOOKTYPE_PROFESSION)
                        if info and info.spellID then createTab(info.spellID) end
                    end
                end
            end
        end
    end

    if isCook and PlayerHasToy(CHEF_HAT) and C_ToyBox.IsToyUsable(CHEF_HAT) then createTab(nil, CHEF_HAT) end
    if C_Item.GetItemCount(THERMAL_ANVIL) > 0 then createTab(nil, nil, THERMAL_ANVIL) end
end

local initialized

local function loadTradeTabs()
    if initialized then return end
    if InCombatLockdown() then return end

    initialized = true
    buildProfessions()
    updateTabs()

    module:RegisterEvent("TRADE_SKILL_SHOW", updateTabs)
    module:RegisterEvent("TRADE_SKILL_CLOSE", updateTabs)
    module:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", updateTabs)
end

local function loadTradeTabsDeferred()
    if initialized then return end
    if InCombatLockdown() then
        module:RegisterEvent("PLAYER_REGEN_ENABLED", loadTradeTabsDeferred)
        return
    end
    module:UnregisterEvent("PLAYER_REGEN_ENABLED", loadTradeTabsDeferred)
    loadTradeTabs()
end

function module:OnInit()
    if not cfg.profession_tabs then return end

    if ProfessionsFrame then
        ProfessionsFrame:HookScript("OnShow", loadTradeTabsDeferred)
    else
        self:RegisterEvent("ADDON_LOADED", function(_, _, addon)
            if addon == "Blizzard_Professions" then loadTradeTabsDeferred() end
        end)
    end
end
