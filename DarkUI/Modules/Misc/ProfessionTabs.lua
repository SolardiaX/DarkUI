local E, C, L = select(2, ...):unpack()

if not C.misc.profession_tabs then return end

----------------------------------------------------------------------------------------
--    Professions tabs on tradeskill frame(ProfessionTabs by Beoko)
----------------------------------------------------------------------------------------

local IsCurrentSpell = IsCurrentSpell
local format = string.format
local next = next
local ranks = PROFESSION_RANKS
local tabs, spells = {}, {}

local handler = CreateFrame("Frame")
handler:SetScript("OnEvent", function(self, event) self[event](self, event) end)
handler:RegisterEvent("TRADE_SKILL_SHOW")
handler:RegisterEvent("TRADE_SKILL_CLOSE")
handler:RegisterEvent("TRADE_SHOW")
handler:RegisterEvent("SKILL_LINES_CHANGED")
handler:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")

local buttonList = {
    [1] = {"Professions-Icon-Skill-High", TRADESKILL_FILTER_HAS_SKILL_UP, C_TradeSkillUI.GetOnlyShowSkillUpRecipes, C_TradeSkillUI.SetOnlyShowSkillUpRecipes},
    [2] = {"Interface\\RAIDFRAME\\ReadyCheck-Ready", CRAFT_IS_MAKEABLE, C_TradeSkillUI.GetOnlyShowMakeableRecipes, C_TradeSkillUI.SetOnlyShowMakeableRecipes},
}

local function filterClick(self)
    local value = self.__value
    if value[3]() then
        value[4](false)
        self:SetBackdropBorderColor(unpack(C.media.border_color))
    else
        value[4](true)
        self:SetBackdropBorderColor(1, 0.8, 0)
    end
end

local buttons = {}
for index, value in pairs(buttonList) do
    local button = CreateFrame("Button", nil, ProfessionsFrame.CraftingPage, "BackdropTemplate")
    button:SetSize(22, 22)
    button:SetPoint("BOTTOMRIGHT", ProfessionsFrame.CraftingPage.RecipeList.FilterButton, "TOPRIGHT", -(index-1)*27, 10)
    button:SetTemplate("Overlay")
    button.Icon = button:CreateTexture(nil, "OVERLAY")
    if index == 1 then
        button.Icon:SetAtlas(value[1])
    else
        button.Icon:SetTexture(value[1])
    end
    button.Icon:SetPoint("TOPLEFT", button, 2, -2)
    button.Icon:SetPoint("BOTTOMRIGHT", button, -2, 2)

    local tooltip_hide = function()
        GameTooltip:Hide()
    end

    local tooltip_show = function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 0, 3)
        GameTooltip:ClearLines()
        GameTooltip:SetText(value[2])
    end
    button:SetScript("OnEnter", tooltip_show)
    button:SetScript("OnLeave", tooltip_hide)

    button.__value = value
    button:SetScript("OnClick", filterClick)

    buttons[index] = button
end

function handler:TRADE_SKILL_LIST_UPDATE()
    for index, value in pairs(buttonList) do
        if value[3]() then
            buttons[index]:SetBackdropBorderColor(1, 0.8, 0)
        else
            buttons[index]:SetBackdropBorderColor(unpack(C.media.border_color))
        end
    end
end
handler:RegisterEvent("TRADE_SKILL_LIST_UPDATE")

local defaults = {
    -- Primary Professions
    [171] = {true, false},    -- Alchemy
    [164] = {true, false},    -- Blacksmithing
    [333] = {true, true},    -- Enchanting
    [202] = {true, false},    -- Engineering
    [182] = {false, false},    -- Herbalism
    [773] = {true, true},    -- Inscription
    [755] = {true, true},    -- Jewelcrafting
    [165] = {true, false},    -- Leatherworking
    [186] = {true, false},    -- Mining
    [393] = {false, false},    -- Skinning
    [197] = {true, false},    -- Tailoring

    -- Secondary Professions
    [794] = {false, false},    -- Archaeology
    [185] = {true, true},    -- Cooking
    [356] = {false, false},    -- Fishing
}

if E.class == "DEATHKNIGHT" then spells[#spells + 1] = 53428 end    -- Runeforging
if E.class == "ROGUE" then spells[#spells + 1] = 1804 end            -- Pick Lock

local function UpdateSelectedTabs(object)
    if not handler:IsEventRegistered("CURRENT_SPELL_CAST_CHANGED") then
        handler:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")
    end

    for index = 1, #tabs[object] do
        local tab = tabs[object][index]
        tab:SetChecked(IsCurrentSpell(tab.name))
    end
end

local function ResetTabs(object)
    for index = 1, #tabs[object] do
        tabs[object][index]:Hide()
    end

    tabs[object].index = 0
end

local function UpdateTab(object, name, rank, texture, hat)
    local index = tabs[object].index + 1
    local tab = tabs[object][index] or CreateFrame("CheckButton", "ProTabs"..tabs[object].index, object, "SpellBookSkillLineTabTemplate, SecureActionButtonTemplate")

    tab:ClearAllPoints()

    if C_AddOns.IsAddOnLoaded("Aurora") then
        tab:SetPoint("TOPLEFT", object, "TOPRIGHT", 11, (-44 * index) + 10)

        tab:DisableDrawLayer("BACKGROUND")
        tab:SetNormalTexture(texture)
        tab:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)

        local F, C = unpack(Aurora)
        tab:SetCheckedTexture(C.media.checked)
        tab:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.3)
        tab:GetHighlightTexture():SetAllPoints(tab:GetNormalTexture())
        F.CreateBG(tab)
    else
        tab:SetPoint("TOPLEFT", object, "TOPRIGHT", 0, (-44 * index) + 18)
        tab:SetNormalTexture(texture)
    end

    if hat then
        tab:SetAttribute("type", "toy")
        tab:SetAttribute("toy", 134020)
    elseif texture == 135805 then    -- Cooking Fire
        tab:SetAttribute("type", "macro")
        tab:SetAttribute("macrotext", "/cast [@player]"..name)
    else
        tab:SetAttribute("type", "spell")
        tab:SetAttribute("spell", name)
    end

    tab:Show()

    tab.name = name
    tab.tooltip = rank and (rank ~= "" and rank ~= name) and format("%s (%s)", name, rank) or name

    tabs[object][index] = tabs[object][index] or tab
    tabs[object].index = tabs[object].index + 1
end

local function GetProfessionRank(currentSkill, skillLineName)
    if skillLineName then
        return skillLineName
    end

    if currentSkill <= 74 then
        return APPRENTICE
    end

    for index = #ranks, 1, -1 do
        local requiredSkill, title = ranks[index][1], ranks[index][2]

        if currentSkill >= requiredSkill then
            return title
        end
    end
end

local function HandleProfession(object, professionID, hat)
    if professionID then
        local _, _, currentSkill, _, numAbilities, offset, skillID, _, _, _, skillLineName = GetProfessionInfo(professionID)

        if defaults[skillID] then
            for index = 1, numAbilities do
                if defaults[skillID][index] then
                    local name = GetSpellBookItemName(offset + index, "profession")
                    local rank = GetProfessionRank(currentSkill, skillLineName)
                    local texture = GetSpellBookItemTexture(offset + index, "profession")

                    if name and rank and texture then
                        UpdateTab(object, name, rank, texture)
                    end
                end
            end
        end

        if hat and PlayerHasToy(134020) and C_ToyBox.IsToyUsable(134020) then
            UpdateTab(object, C_Spell.GetSpellInfo(67556), nil, 236571, true)
        end
    end
end

local function HandleTabs(object)
    if not object then return end
    tabs[object] = tabs[object] or {}

    if InCombatLockdown() then
        handler:RegisterEvent("PLAYER_REGEN_ENABLED")
    else
        local firstProfession, secondProfession, archaeology, fishing, cooking = GetProfessions()

        ResetTabs(object)

        HandleProfession(object, firstProfession)
        HandleProfession(object, secondProfession)
        HandleProfession(object, archaeology)
        HandleProfession(object, fishing)
        HandleProfession(object, cooking, true)

        for index = 1, #spells do
            if IsSpellKnown(spells[index]) then
                local name, rank, texture = C_Spell.GetSpellInfo(spells[index])
                UpdateTab(object, name, rank, texture)
            end
        end
    end

    UpdateSelectedTabs(object)
end

function handler:TRADE_SKILL_SHOW(event)
    local owner = ATSWFrame or MRTSkillFrame or SkilletFrame or ProfessionsFrame

    if C_AddOns.IsAddOnLoaded("TradeSkillDW") and owner == ProfessionsFrame then
        self:UnregisterEvent(event)
    else
        HandleTabs(owner)
        self[event] = function() for object in next, tabs do UpdateSelectedTabs(object) end end
    end
end

function handler:TRADE_SKILL_CLOSE()
    for object in next, tabs do
        if object:IsShown() then
            UpdateSelectedTabs(object)
        end
    end
end

function handler:TRADE_SHOW(event)
    local owner = TradeFrame

    HandleTabs(owner)
    self[event] = function() UpdateSelectedTabs(owner) end
end

function handler:PLAYER_REGEN_ENABLED(event)
    self:UnregisterEvent(event)

    for object in next, tabs do HandleTabs(object) end
end

function handler:SKILL_LINES_CHANGED()
    for object in next, tabs do HandleTabs(object) end
end

function handler:CURRENT_SPELL_CAST_CHANGED(event)
    local numShown = 0

    for object in next, tabs do
        if object:IsShown() then
            numShown = numShown + 1
            UpdateSelectedTabs(object)
        end
    end

    if numShown == 0 then self:UnregisterEvent(event) end
end