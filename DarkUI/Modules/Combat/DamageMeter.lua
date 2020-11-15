local E, C, L = select(2, ...):unpack()

if C.combat.damagemeter.enable ~= true then return end

----------------------------------------------------------------------------------------
--	DamageMeter (modified from alDamageMeter)
----------------------------------------------------------------------------------------

local cfg = C.combat.damagemeter

local texture = C.media.texture.gradient

local boss = LibStub("LibBossIDs-1.0")
local dataobj = LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject('Dps', { type = "data source", text = 'DPS: ', icon = "", iconCoords = { 0.065, 0.935, 0.065, 0.935 } })
local band = bit.band
local bossname, mobname = nil, nil
local units, bar, barguids, owners = {}, {}, {}, {}
local current, total, display, fights = {}, {}, {}, {}
local timer, num, offset = 0, 0, 0
local MainFrame
local combatstarted = false
local raidFlags = COMBATLOG_OBJECT_AFFILIATION_RAID + COMBATLOG_OBJECT_AFFILIATION_PARTY + COMBATLOG_OBJECT_AFFILIATION_MINE
local petFlags = COMBATLOG_OBJECT_TYPE_PET + COMBATLOG_OBJECT_TYPE_GUARDIAN
local npcFlags = COMBATLOG_OBJECT_TYPE_NPC + COMBATLOG_OBJECT_CONTROL_NPC

local displayMode = {
    DAMAGE,
    SHOW_COMBAT_HEALING,
    ABSORB,
    DISPELS,
    INTERRUPTS,
}
local sMode = cfg.sortby
local AbsorbSpellDuration = {
    -- Death Knight
    [48707] = 5, -- Anti-Magic Shell (DK) Rank 1 -- Does not currently seem to show tracable combat log events. It shows energizes which do not reveal the amount of damage absorbed
    [51052] = 10, -- Anti-Magic Zone (DK)( Rank 1 (Correct spellID?)
    [51271] = 20, -- Unbreakable Armor (DK)
    [77535] = 10, -- Blood Shield (DK)
    -- Druid
    [62606] = 10, -- Savage Defense proc. (Druid) Tooltip of the original spell doesn't clearly state that this is an absorb, but the buff does.
    -- Mage
    [11426] = 60, -- Ice Barrier
    [6143]  = 30, -- Frost Ward
    [1463]  = 60, --  Mana shield
    [543]   = 30, -- Fire Ward
    -- Paladin
    [58597] = 6, -- Sacred Shield (Paladin) proc (Fixed, thanks to Julith)
    [86273] = 6, -- Illuminated Healing, Pala Mastery
    -- Priest
    [17]    = 30, -- Power Word: Shield
    [47753] = 12, -- Divine Aegis
    [47788] = 10, -- Guardian Spirit  (Priest) (50 nominal absorb, this may not show in the CL)
    -- Warlock
    [7812]  = 30, -- Sacrifice
    [6229]  = 30, -- Shadow Ward
    -- Item procs
    [64411] = 15, -- Blessing of the Ancient (Val'anyr Hammer of Ancient Kings equip effect)
    [64413] = 8, -- Val'anyr, Hammer of Ancient Kings proc Protection of Ancient Kings
}
local shields = {}

local menuFrame = CreateFrame("Frame", "alDamageMeterMenu", UIParent, "UIDropDownMenuTemplate")

function dataobj.OnLeave()
    GameTooltip:SetClampedToScreen(true)
    GameTooltip:Hide()
end

function dataobj.OnEnter(self)
    GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT', 0, self:GetHeight())
    GameTooltip:AddLine("alDamageMeter")
    GameTooltip:AddLine("Hint: click to show/hide damage meter window.")
    GameTooltip:Show()
end

function dataobj.OnClick(self, button)
    if MainFrame:IsShown() then
        MainFrame:Hide()
    else
        MainFrame:Show()
    end
end

local IsFriendlyUnit = function(uGUID)
    if units[uGUID] or (owners[uGUID] and units[owners[uGUID]]) or uGUID == UnitGUID("player") then
        return true
    else
        return false
    end
end

local IsUnitInCombat = function(uGUID)
    unit = units[uGUID]
    if unit then
        return UnitAffectingCombat(unit.unit)
    end
    return false
end

local CreateFS = function(frame)
    local fstring = frame:CreateFontString(nil, 'OVERLAY')
    fstring:SetFont(STANDARD_TEXT_FONT, cfg.font_size, cfg.font_style)
    fstring:SetShadowColor(0, 0, 0, 1)
    fstring:SetShadowOffset(0.5, -0.5)
    return fstring
end

local tcopy = function(src)
    local dest = {}
    for k, v in pairs(src) do
        dest[k] = v
    end
    return dest
end

local perSecond = function(cdata)
    return cdata[sMode].amount / cdata.combatTime
end

local report = function(channel, cn)
    local message = E.addonName .. " : " .. sMode
    if channel == "Chat" then
        DEFAULT_CHAT_FRAME:AddMessage(message)
    else
        SendChatMessage(message, channel, nil, cn)
    end
    for i, v in pairs(barguids) do
        if i > cfg.reportstrings or display[v][sMode].amount == 0 then return end
        if sMode == DAMAGE or sMode == SHOW_COMBAT_HEALING then
            message = string.format("%2d. %s    %s (%.0f)", i, display[v].name, E:ShortValue(display[v][sMode].amount), perSecond(display[v]))
        else
            message = string.format("%2d. %s    %s", i, display[v].name, E:ShortValue(display[v][sMode].amount))
        end
        if channel == "Chat" then
            DEFAULT_CHAT_FRAME:AddMessage(message)
        else
            SendChatMessage(message, channel, nil, cn)
        end
    end
end

StaticPopupDialogs[E.addonName .. "ReportDialog"] = {
    text         = "",
    button1      = ACCEPT,
    button2      = CANCEL,
    hasEditBox   = 1,
    timeout      = 30,
    hideOnEscape = 1,
}

local reportList = {
    {
        text = CHAT_LABEL,
        func = function() report("Chat") end,
    },
    {
        text = SAY,
        func = function() report("SAY") end,
    },
    {
        text = PARTY,
        func = function() report("PARTY") end,
    },
    {
        text = RAID,
        func = function() report("RAID") end,
    },
    {
        text = OFFICER,
        func = function() report("OFFICER") end,
    },
    {
        text = GUILD,
        func = function() report("GUILD") end,
    },
    {
        text = TARGET,
        func = function()
            if UnitExists("target") and UnitIsPlayer("target") then
                report("WHISPER", UnitName("target"))
            end
        end,
    },
    {
        text = PLAYER .. "..",
        func = function()
            StaticPopupDialogs[addon_name .. "ReportDialog"].OnAccept = function(self)
                report("WHISPER", _G[self:GetName() .. "EditBox"]:GetText())
            end
            StaticPopup_Show(addon_name .. "ReportDialog")
        end,
    },
    {
        text = CHANNEL .. "..",
        func = function()
            StaticPopupDialogs[addon_name .. "ReportDialog"].OnAccept = function(self)
                report("CHANNEL", _G[self:GetName() .. "EditBox"]:GetText())
            end
            StaticPopup_Show(addon_name .. "ReportDialog")
        end,
    },
}

local OnBarEnter = function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
    GameTooltip:AddLine(self.left:GetText())
    GameTooltip:AddLine(SPELL_DETAIL)
    local a = {}
    local amount = display[barguids[self.id]][sMode].amount
    for spell, value in pairs(display[barguids[self.id]][sMode].spells) do
        tinsert(a, { spell, value })
    end
    table.sort(a, function(a, b) return a[2] > b[2] end)
    for _, v in pairs(a) do
        GameTooltip:AddDoubleLine(v[1], string.format("%d (%.1f%%)", v[2], v[2] / amount * 100), 1, 1, 1, 1, 1, 1)
    end
    wipe(a)
    GameTooltip:AddLine(TARGET)
    for target, value in pairs(display[barguids[self.id]][sMode].targets) do
        tinsert(a, { target, value })
    end
    table.sort(a, function(a, b) return a[2] > b[2] end)
    for _, v in pairs(a) do
        GameTooltip:AddDoubleLine(v[1], string.format("%d (%.1f%%)", v[2], v[2] / amount * 100), 1, 1, 1, 1, 1, 1)
    end
    GameTooltip:Show()
end

local OnBarLeave = function(self)
    GameTooltip:Hide()
end

local CreateBar = function()
    local newbar = CreateFrame("Statusbar", nil, MainFrame)
    newbar:SetStatusBarTexture(texture)
    newbar:SetTemplate("Default")
    newbar:CreateShadow()
    newbar:SetMinMaxValues(0, 100)
    newbar:SetWidth(MainFrame:GetWidth())
    newbar:SetHeight(cfg.barheight)
    newbar.left = CreateFS(newbar)
    newbar.left:SetPoint("LEFT", 2, 6)
    newbar.left:SetJustifyH("LEFT")
    newbar.right = CreateFS(newbar)
    newbar.right:SetPoint("RIGHT", -2, 6)
    newbar.right:SetJustifyH("RIGHT")
    newbar:SetScript("OnEnter", OnBarEnter)
    newbar:SetScript("OnLeave", OnBarLeave)
    newbar:SetScript("OnMouseUp", function(self, button)
        if button == "RightButton" then
            ToggleDropDownMenu(1, nil, menuFrame, 'cursor', 0, 0)
        end
    end)
    return newbar
end

local CreateUnitInfo = function(uGUID)
    local unit = units[uGUID]
    local newdata = {
        name       = unit.name,
        class      = unit.class,
        combatTime = 1,
    }
    for _, v in pairs(displayMode) do
        newdata[v] = {
            amount  = 0,
            spells  = {},
            targets = {},
        }
    end
    return newdata
end

local Add = function(uGUID, amount, mode, spell, target)
    if not current[uGUID] then
        current[uGUID] = CreateUnitInfo(uGUID)
        tinsert(barguids, uGUID)
    end
    if not total[uGUID] then
        total[uGUID] = CreateUnitInfo(uGUID)
    end
    current[uGUID][mode].amount = current[uGUID][mode].amount + amount
    total[uGUID][mode].amount = total[uGUID][mode].amount + amount
    if spell then
        current[uGUID][mode].spells[spell] = (current[uGUID][mode].spells[spell] or 0) + amount
        current[uGUID][mode].targets[target] = (current[uGUID][mode].targets[target] or 0) + amount
        total[uGUID][mode].spells[spell] = (total[uGUID][mode].spells[spell] or 0) + amount
        total[uGUID][mode].targets[target] = (total[uGUID][mode].targets[target] or 0) + amount
    end
end

local SortMethod = function(a, b)
    return display[b][sMode].amount < display[a][sMode].amount
end

local UpdateBars = function()
    table.sort(barguids, SortMethod)
    local color, cur, max
    for i = 1, #barguids do
        cur = display[barguids[i + offset]]
        max = display[barguids[1]]
        if i > cfg.maxbars or not cur then break end
        if cur[sMode].amount == 0 then break end
        if not bar[i] then
            bar[i] = CreateBar()
            bar[i]:SetPoint("TOP", 0, -(cfg.barheight + cfg.spacing) * (i - 1))
        end
        bar[i].id = i + offset
        bar[i]:SetValue(100 * cur[sMode].amount / max[sMode].amount)
        color = RAID_CLASS_COLORS[cur.class]
        if cfg.classcolorbar and color then
            bar[i]:SetStatusBarColor(color.r, color.g, color.b)
        else
            bar[i]:SetStatusBarColor(unpack(cfg.barcolor))
        end
        if sMode == DAMAGE or sMode == SHOW_COMBAT_HEALING then
            bar[i].right:SetFormattedText("%s (%s)", E:ShortValue(cur[sMode].amount), E:ShortValue(perSecond(cur)))
        else
            bar[i].right:SetFormattedText("%s", E:ShortValue(cur[sMode].amount))
        end
        if cfg.classcolorname and color then
            bar[i].left:SetFormattedText("%s%s|r", E:RGBToHex(color), cur.name)
            bar[i].right:SetFormattedText("%s%s|r", E:RGBToHex(color), bar[i].right:GetText())
        else
            bar[i].left:SetText(cur.name)
        end
        bar[i]:Show()
    end
end

local UpdateWindow = function()
    MainFrame:SetSize(cfg.width, cfg.maxbars * (cfg.barheight + cfg.spacing) - cfg.spacing)
    if not IsAddOnLoaded("alInterface") then
        MainFrame.bg:SetBackdropColor(unpack(cfg.backdrop_color))
        MainFrame.bg:SetBackdropBorderColor(unpack(cfg.border_color))
    end
    if cfg.hidetitle then
        MainFrame.title:Hide()
    else
        MainFrame.title:Show()
    end
    for i, v in pairs(bar) do
        v:SetWidth(MainFrame:GetWidth())
        v:SetHeight(cfg.barheight)
        v:SetPoint("TOP", 0, -(cfg.barheight + cfg.spacing) * (i - 1))
        if not IsAddOnLoaded("alInterface") then
            v.left:SetFont(font, cfg.font_size, cfg.font_style)
            v.right:SetFont(font, cfg.font_size, cfg.font_style)
        end
    end
    UpdateBars()
end

local ResetDisplay = function(fight)
    for i, v in pairs(bar) do
        v:Hide()
    end
    display = fight
    wipe(barguids)
    for guid, v in pairs(display) do
        tinsert(barguids, guid)
    end
    offset = 0
    UpdateBars()
end

local Clean = function()
    numfights = 0
    wipe(current)
    wipe(total)
    wipe(fights)
    ResetDisplay(current)
end

local SetMode = function(mode)
    sMode = mode
    for i, v in pairs(bar) do
        v:Hide()
    end
    UpdateBars()
    MainFrame.title:SetText(sMode)
end

local CreateMenu = function(self, level)
    level = level or 1
    local info = {}
    if level == 1 then
        info.isTitle = 1
        info.text = addon_name
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info, level)
        wipe(info)
        info.text = MODE
        info.hasArrow = 1
        info.value = "Mode"
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info, level)
        wipe(info)
        info.text = CHAT_ANNOUNCE
        info.hasArrow = 1
        info.value = "Report"
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info, level)
        wipe(info)
        info.text = COMBAT
        info.hasArrow = 1
        info.value = "Fight"
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info, level)
        wipe(info)
        info.text = SETTINGS
        info.hasArrow = 1
        info.value = "Options"
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info, level)
        wipe(info)
        info.text = RESET
        info.func = Clean
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info, level)
        wipe(info)
        info.text = HIDE
        info.func = function()
            MainFrame:SetAlpha(0)
            MainFrame:EnableMouse(false)
        end
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info, level)
    elseif level == 2 then
        if UIDROPDOWNMENU_MENU_VALUE == "Mode" then
            for i, v in pairs(displayMode) do
                wipe(info)
                info.text = v
                info.func = function() SetMode(v) end
                info.notCheckable = 1
                UIDropDownMenu_AddButton(info, level)
            end
        end
        if UIDROPDOWNMENU_MENU_VALUE == "Report" then
            for i, v in pairs(reportList) do
                wipe(info)
                info.text = v.text
                info.func = v.func
                info.notCheckable = 1
                UIDropDownMenu_AddButton(info, level)
            end
        end
        if UIDROPDOWNMENU_MENU_VALUE == "Fight" then
            wipe(info)
            info.text = L.DAMAGEMETER_CURRENT
            info.func = function() ResetDisplay(current) end
            info.notCheckable = 1
            UIDropDownMenu_AddButton(info, level)
            wipe(info)
            info.text = L.DAMAGEMETER_TOTAL
            info.func = function() ResetDisplay(total) end
            info.notCheckable = 1
            UIDropDownMenu_AddButton(info, level)
            for i, v in pairs(fights) do
                wipe(info)
                info.text = v.name
                info.func = function() ResetDisplay(v.data) end
                info.notCheckable = 1
                UIDropDownMenu_AddButton(info, level)
            end
        end
        if UIDROPDOWNMENU_MENU_VALUE == "Options" then
            wipe(info)
            info.text = L.DAMAGEMETER_VISIBLE_BARS
            info.func = function()
                StaticPopupDialogs[addon_name .. "ReportDialog"].OnAccept = function(self)
                    cfg.maxbars = tonumber(_G[self:GetName() .. "EditBox"]:GetText())
                    UpdateWindow()
                end
                StaticPopupDialogs[addon_name .. "ReportDialog"].OnShow = function(self)
                    _G[self:GetName() .. "EditBox"]:SetText(cfg.maxbars)
                end
                StaticPopup_Show(addon_name .. "ReportDialog")
            end
            info.notCheckable = 1
            UIDropDownMenu_AddButton(info, level)
            wipe(info)
            info.text = L.DAMAGEMETER_BAR_WIDTH
            info.func = function()
                StaticPopupDialogs[addon_name .. "ReportDialog"].OnAccept = function(self)
                    cfg.width = tonumber(_G[self:GetName() .. "EditBox"]:GetText())
                    UpdateWindow()
                end
                StaticPopupDialogs[addon_name .. "ReportDialog"].OnShow = function(self)
                    _G[self:GetName() .. "EditBox"]:SetText(cfg.width)
                end
                StaticPopup_Show(addon_name .. "ReportDialog")
            end
            info.notCheckable = 1
            UIDropDownMenu_AddButton(info, level)
            wipe(info)
            info.text = L.DAMAGEMETER_BAR_HEIGHT
            info.func = function()
                StaticPopupDialogs[addon_name .. "ReportDialog"].OnAccept = function(self)
                    cfg.barheight = tonumber(_G[self:GetName() .. "EditBox"]:GetText())
                    UpdateWindow()
                end
                StaticPopupDialogs[addon_name .. "ReportDialog"].OnShow = function(self)
                    _G[self:GetName() .. "EditBox"]:SetText(cfg.barheight)
                end
                StaticPopup_Show(addon_name .. "ReportDialog")
            end
            info.notCheckable = 1
            UIDropDownMenu_AddButton(info, level)
            wipe(info)
            info.text = L.DAMAGEMETER_SPACING
            info.func = function()
                StaticPopupDialogs[addon_name .. "ReportDialog"].OnAccept = function(self)
                    cfg.spacing = tonumber(_G[self:GetName() .. "EditBox"]:GetText())
                    UpdateWindow()
                end
                StaticPopupDialogs[addon_name .. "ReportDialog"].OnShow = function(self)
                    _G[self:GetName() .. "EditBox"]:SetText(cfg.spacing)
                end
                StaticPopup_Show(addon_name .. "ReportDialog")
            end
            info.notCheckable = 1
            UIDropDownMenu_AddButton(info, level)
            wipe(info)
            info.text = L.DAMAGEMETER_FONT_SIZE
            info.func = function()
                StaticPopupDialogs[addon_name .. "ReportDialog"].OnAccept = function(self)
                    cfg.font_size = tonumber(_G[self:GetName() .. "EditBox"]:GetText())
                    UpdateWindow()
                end
                StaticPopupDialogs[addon_name .. "ReportDialog"].OnShow = function(self)
                    _G[self:GetName() .. "EditBox"]:SetText(cfg.font_size)
                end
                StaticPopup_Show(addon_name .. "ReportDialog")
            end
            info.notCheckable = 1
            UIDropDownMenu_AddButton(info, level)
            wipe(info)
            info.text = L.DAMAGEMETER_HIDE_TITLE
            info.func = function()
                cfg.hidetitle = not cfg.hidetitle
                UpdateWindow()
            end
            info.checked = cfg.hidetitle
            UIDropDownMenu_AddButton(info, level)
            wipe(info)
            info.text = L.DAMAGEMETER_CLASS_COLOR_BAR
            info.func = function()
                cfg.classcolorbar = not cfg.classcolorbar
                UpdateWindow()
            end
            info.checked = cfg.classcolorbar
            UIDropDownMenu_AddButton(info, level)
            wipe(info)
            info.text = L.DAMAGEMETER_CLASS_COLOR_NAME
            info.func = function()
                cfg.classcolorname = not cfg.classcolorname
                UpdateWindow()
            end
            info.checked = cfg.classcolorname
            UIDropDownMenu_AddButton(info, level)
            wipe(info)
            info.text = L.DAMAGEMETER_SAVE_ONLY_BOSS_FIGHTS
            info.func = function()
                cfg.onlyboss = not cfg.onlyboss
                UpdateWindow()
            end
            info.checked = cfg.onlyboss
            UIDropDownMenu_AddButton(info, level)
            wipe(info)
            info.text = L.DAMAGEMETER_MERGE_HEAL_AND_ABSORBS
            info.func = function()
                cfg.mergeHealAbsorbs = not cfg.mergeHealAbsorbs
                UpdateWindow()
            end
            info.checked = cfg.mergeHealAbsorbs
            UIDropDownMenu_AddButton(info, level)
            wipe(info)
            info.text = L.DAMAGEMETER_BAR_COLOR
            info.hasColorSwatch = 1
            info.func = UIDropDownMenuButton_OpenColorPicker
            info.r = cfg.barcolor[1]
            info.g = cfg.barcolor[2]
            info.b = cfg.barcolor[3]
            info.swatchFunc = function()
                cfg.barcolor = { ColorPickerFrame:GetColorRGB() }
                UpdateBars()
            end
            info.cancelFunc = function(restore)
                local pv = ColorPickerFrame.previousValues
                cfg.barcolor = { pv.r, pv.g, pv.b }
                UpdateBars()
            end
            info.notCheckable = 1
            info.keepShownOnClick = false
            UIDropDownMenu_AddButton(info, level)
            info.text = L.DAMAGEMETER_BACKDROP_COLOR
            info.hasColorSwatch = 1
            info.hasOpacity = (cfg.backdrop_color[4] ~= nil)
            info.func = UIDropDownMenuButton_OpenColorPicker
            info.r = cfg.backdrop_color[1]
            info.g = cfg.backdrop_color[2]
            info.b = cfg.backdrop_color[3]
            info.opacity = cfg.backdrop_color[4]
            info.swatchFunc, info.opacityFunc, info.cancelFunc = function()
                cfg.backdrop_color = { ColorPickerFrame:GetColorRGB() }
                cfg.backdrop_color[4] = OpacitySliderFrame:GetValue()
                UpdateWindow()
            end
            info.opacityFunc = info.swatchFunc
            info.cancelFunc = function()
                local pv = ColorPickerFrame.previousValues
                cfg.backdrop_color = { pv.r, pv.g, pv.b, pv.opacity }
                UpdateWindow()
            end
            info.notCheckable = 1
            info.keepShownOnClick = false
            UIDropDownMenu_AddButton(info, level)
            info.text = L.DAMAGEMETER_BORDER_COLOR
            info.hasColorSwatch = 1
            info.hasOpacity = 1
            info.func = UIDropDownMenuButton_OpenColorPicker
            info.r = cfg.border_color[1]
            info.g = cfg.border_color[2]
            info.b = cfg.border_color[3]
            info.opacity = (cfg.border_color[4] ~= nil)
            info.swatchFunc = function()
                cfg.border_color = { ColorPickerFrame:GetColorRGB() }
                cfg.border_color[4] = OpacitySliderFrame:GetValue()
                UpdateWindow()
            end
            info.opacityFunc = info.swatchFunc
            info.cancelFunc = function(restore)
                local pv = ColorPickerFrame.previousValues
                cfg.border_color = { pv.r, pv.g, pv.b, pv.opacity }
                UpdateWindow()
            end
            info.notCheckable = 1
            info.keepShownOnClick = false
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

local EndCombat = function()
    MainFrame:SetScript('OnUpdate', nil)
    combatstarted = false
    local fname = bossname or mobname
    if fname then
        if #fights >= cfg.maxfights then
            tremove(fights, 1)
        end
        tinsert(fights, { name = fname, data = tcopy(current) })
        mobname, bossname = nil, nil
    end
end

local CheckPet = function(unit, pet)
    if UnitExists(pet) then
        owners[UnitGUID(pet)] = UnitGUID(unit)
    end
end

local CheckUnit = function(unit)
    if UnitExists(unit) then
        units[UnitGUID(unit)] = {
            name  = UnitName(unit),
            class = select(2, UnitClass(unit)),
            unit  = unit,
        }
        pet = unit .. "pet"
        CheckPet(unit, pet)
    end
end

local CheckRoster = function()
    wipe(units)
    if GetNumGroupMembers() > 0 then
        local unit = IsInRaid() and "raid" or "party"
        for i = 1, GetNumGroupMembers(), 1 do
            CheckUnit(unit .. i)
        end
    end
    CheckUnit("player")
end

local IsRaidInCombat = function()
    if GetNumGroupMembers() > 0 then
        local unit = IsInRaid() and "raid" or "party"
        for i = 1, GetNumGroupMembers(), 1 do
            if UnitExists(unit .. i) and UnitAffectingCombat(unit .. i) then
                return true
            end
        end
    end
    return false
end

local OnUpdate = function(self, elapsed)
    timer = timer + elapsed
    if timer > 0.5 then
        for i, v in pairs(current) do
            if IsUnitInCombat(i) then
                v.combatTime = v.combatTime + timer
            end
            if i == UnitGUID("player") then
                dataobj.text = string.format("DPS: %.0f", v[DAMAGE].amount / v.combatTime)
            end
        end
        for i, v in pairs(total) do
            if IsUnitInCombat(i) then
                v.combatTime = v.combatTime + timer
            end
        end
        UpdateBars()
        if not InCombatLockdown() and not IsRaidInCombat() then
            EndCombat()
        end
        timer = 0
    end
end

local OnMouseWheel = function(self, direction)
    num = 0
    for i = 1, #barguids do
        if display[barguids[i]][sMode].amount > 0 then
            num = num + 1
        end
    end
    if direction > 0 then
        if offset > 0 then
            offset = offset - 1
        end
    else
        if num > cfg.maxbars + offset then
            offset = offset + 1
        end
    end
    UpdateBars()
end

local StartCombat = function()
    wipe(current)
    combatstarted = true
    ResetDisplay(current)
    MainFrame:SetScript('OnUpdate', OnUpdate)
end

local IsUnitOrPet = function(flags)
    if band(flags, raidFlags) ~= 0 or band(flags, petFlags) ~= 0 then
        return true
    end
    return false
end

local OnEvent = function(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22 = CombatLogGetCurrentEventInfo()
        if eventType == "SPELL_SUMMON" and (band(sourceFlags, raidFlags) ~= 0 or band(sourceFlags, npcFlags) ~= 0 or band(sourceFlags, petFlags) ~= 0 or band(destFlags, petFlags) ~= 0) then
            if owners[sourceGUID] then
                owners[destGUID] = owners[sourceGUID]
            else
                owners[destGUID] = sourceGUID
                for pet, owner in pairs(owners) do
                    if owners[owner] then
                        owners[pet] = owners[owner]
                        break
                    end
                end
            end
        end

        if band(sourceFlags, raidFlags) == 0 and band(destFlags, raidFlags) == 0 and band(sourceFlags, petFlags) == 0 and band(destFlags, petFlags) == 0 then return end
        if eventType == "SWING_DAMAGE" or eventType == "RANGE_DAMAGE" or eventType == "SPELL_DAMAGE" or eventType == "SPELL_PERIODIC_DAMAGE" or eventType == "DAMAGE_SHIELD" then
            local amount, _, _, _, _, absorbed = eventType == "SWING_DAMAGE" and arg12 or arg15
            local spellName = eventType == "SWING_DAMAGE" and MELEE_ATTACK or arg13
            if IsFriendlyUnit(sourceGUID) and not IsFriendlyUnit(destGUID) and combatstarted then
                if amount and amount > 0 then
                    if owners[sourceGUID] then
                        sourceGUID = owners[sourceGUID]
                        spellName = "Pet: " .. spellName
                    end
                    Add(sourceGUID, amount, DAMAGE, spellName, destName)
                    if not bossname and boss.BossIDs[tonumber(destGUID:sub(9, 12), 16)] then
                        bossname = destName
                    elseif not mobname and not cfg.onlyboss then
                        mobname = destName
                    end
                end
            end
        elseif eventType == "SPELL_HEAL" or eventType == "SPELL_PERIODIC_HEAL" then
            spellId, spellName, spellSchool, amount, over, school, resist = arg12
            if IsFriendlyUnit(sourceGUID) and IsFriendlyUnit(destGUID) and combatstarted then
                over = over or 0
                if amount and amount > 0 then
                    sourceGUID = owners[sourceGUID] or sourceGUID
                    Add(sourceGUID, amount - over, SHOW_COMBAT_HEALING, spellName, destName)
                end
            end
        elseif eventType == "SPELL_DISPEL" then
            if IsFriendlyUnit(sourceGUID) and combatstarted then
                sourceGUID = owners[sourceGUID] or sourceGUID
                Add(sourceGUID, 1, DISPELS, "Dispel", destName)
            end
        elseif eventType == "SPELL_INTERRUPT" then
            if IsFriendlyUnit(sourceGUID) and not IsFriendlyUnit(destGUID) and combatstarted then
                sourceGUID = owners[sourceGUID] or sourceGUID
                Add(sourceGUID, 1, INTERRUPTS, "Interrupt", destName)
            end
        elseif eventType == "SPELL_AURA_APPLIED" then
            local spellId, spellName, spellSchool, auraType, amount = arg12
            sourceGUID = owners[sourceGUID] or sourceGUID
            if amount and AbsorbSpellDuration[spellId] and IsFriendlyUnit(sourceGUID) and IsFriendlyUnit(destGUID) then
                shields[destGUID] = shields[destGUID] or {}
                shields[destGUID][spellName] = shields[destGUID][spellName] or {}
                shields[destGUID][spellName][sourceGUID] = amount
            end
        elseif eventType == "SPELL_AURA_REFRESH" then
            local spellId, spellName, spellSchool, auraType, amount = arg12
            sourceGUID = owners[sourceGUID] or sourceGUID
            if amount and AbsorbSpellDuration[spellId] and IsFriendlyUnit(destGUID) then
                if shields[destGUID] and shields[destGUID][spellName] and shields[destGUID][spellName][sourceGUID] then
                    local old = shields[destGUID][spellName][sourceGUID]
                    shields[destGUID][spellName][sourceGUID] = amount
                    if old > amount then
                        Add(sourceGUID, old - amount, cfg.mergeHealAbsorbs and SHOW_COMBAT_HEALING or ABSORB, spellName, destName)
                    end
                end
            end
        elseif eventType == "SPELL_AURA_REMOVED" then
            local spellId, spellName, spellSchool, auraType, amount = arg12
            sourceGUID = owners[sourceGUID] or sourceGUID
            if amount and AbsorbSpellDuration[spellId] and IsFriendlyUnit(destGUID) then
                if shields[destGUID] and shields[destGUID][spellName] and shields[destGUID][spellName][sourceGUID] then
                    local old = shields[destGUID][spellName][sourceGUID]
                    shields[destGUID][spellName][sourceGUID] = nil
                    if old > amount then
                        Add(sourceGUID, old, cfg.mergeHealAbsorbs and SHOW_COMBAT_HEALING or ABSORB, spellName, destName)
                    end
                end
            end
        else
            return
        end
    elseif event == "ADDON_LOADED" then
        local name = ...
        if name == E.addonName then
            self:UnregisterEvent(event)
            MainFrame = CreateFrame("Frame",  "DarkUI_DamageMeterFrame", UIParent)
            MainFrame:SetFrameStrata("LOW")
            MainFrame:SetFrameLevel(1)
            MainFrame:SetSize(cfg.width, cfg.maxbars * (cfg.barheight + cfg.spacing) - cfg.spacing)
            MainFrame:SetPoint(unpack(cfg.pos))
            MainFrame:CreateBackground()
            MainFrame:SetMovable(true)
            MainFrame:EnableMouse(true)
            MainFrame:EnableMouseWheel(true)
            MainFrame:SetScript("OnMouseDown", function(self, button)
                if button == "LeftButton" and IsModifiedClick("SHIFT") then
                    self:StartMoving()
                end
            end)
            MainFrame:SetScript("OnMouseUp", function(self, button)
                if button == "RightButton" then
                    ToggleDropDownMenu(1, nil, menuFrame, 'cursor', 0, 0)
                end
                if button == "LeftButton" then
                    self:StopMovingOrSizing()
                end
            end)
            MainFrame:SetScript("OnMouseWheel", OnMouseWheel)
            MainFrame:Show()
            UIDropDownMenu_Initialize(menuFrame, CreateMenu, "MENU")
            CheckRoster()
        end
    elseif event == "VARIABLES_LOADED" then
        MainFrame.title = CreateFS(MainFrame)
        MainFrame.title:SetPoint("BOTTOM", MainFrame, "TOP", 0, 1)
        MainFrame.title:SetText(sMode)
        UpdateWindow()
    elseif event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
        CheckRoster()
    elseif event == "PLAYER_REGEN_DISABLED" then
        if not combatstarted then
            StartCombat()
        end
    elseif event == "UNIT_PET" then
        local unit = ...
        local pet = unit .. "pet"
        CheckPet(unit, pet)
    end
end

local addon = CreateFrame("frame", nil, UIParent)
addon:SetScript('OnEvent', OnEvent)
addon:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
addon:RegisterEvent("ADDON_LOADED")
addon:RegisterEvent("VARIABLES_LOADED")
addon:RegisterEvent("GROUP_ROSTER_UPDATE")
addon:RegisterEvent("PLAYER_ENTERING_WORLD")
addon:RegisterEvent("PLAYER_REGEN_DISABLED")
addon:RegisterEvent("UNIT_PET")

SlashCmdList["alDamage"] = function(msg)
    if MainFrame:GetAlpha() > 0 then
        MainFrame:SetAlpha(0)
        MainFrame:EnableMouse(false)
    else
        MainFrame:SetAlpha(1)
        MainFrame:EnableMouse(true)
    end
end
SLASH_alDamage1 = "/dmg"