local E, C
local addonName, ns = ...

----------------------------------------------------------------------------------------
--	Core Methods form DarkUI Option GUI
----------------------------------------------------------------------------------------
local bgTex = "Interface\\Addons\\" .. addonName .. "\\Media\\bgTex"
local gearTex = "Interface\\WorldMap\\Gear_64"
local sparkTex = "Interface\\CastingBar\\UI-CastingBar-Spark"
local diabled_color = { 0.37, 0.3, 0.3, 1 }

local guiTab, guiPage = {}, {}

local function hookAvaliable(frame, texts, OnEnable, OnDisable)
    frame:HookScript("OnEnable", function(self)
        for _, t in pairs(texts) do
            t:SetTextColor(unpack(C.media.text_color))
        end

        if OnEnable then OnEnable(self) end
    end)
    frame:HookScript("OnDisable", function(self)
        for _, t in pairs(texts) do
            t:SetTextColor(unpack(diabled_color))
        end

        if OnDisable then OnDisable(self) end
    end)
end

local function getVariable(t, group, key)
    if not t or not t[group] then return end

    t = t[group]

    for k in gmatch(key, "([^.%s]+)") do
        t = t[k]
        if t == nil then return end
    end

    return t
end

local function setVariable(t, group, key, value)
    if not t then t = {} end
    if not t[group] then t[group] = {} end

    t = t[group]

    local deep = select(2, string.gsub(key, "([^.%s]+)", ""))
    local index = 1

    for k in gmatch(key, "([^.%s]+)") do
        if index < deep then
            if t[k] == nil then t[k] = {} end
            t = t[k]
        elseif index == deep then
            t[k] = value
        end

        index = index + 1
    end
end

ns.changed = 0

local function Variable(group, key, value)
    local t = SavedOptions.global and SavedOptions or SavedOptionsPerChar

    if value ~= nil then
        setVariable(t, group, key, value)
        if value ~= getVariable(C, group, key) then
            ns.changed = ns.changed + 1
        else
            ns.changed = ns.changed - 1
        end

        if ns.changed ~= 0 then
            ns.applyButton:Show()
        else
            ns.applyButton:Hide()
        end
    else
        local v = getVariable(t, group, key)
        if v == nil then
            v = getVariable(C, group, key)
            setVariable(t, group, key, v)
        end
        return v
    end
end
ns.Variable = Variable

local function SelectTab(i)
    for num = 1, #ns.Categories do
        if num == i then
            guiTab[num]:SetBackdropColor(E.myColor.r, E.myColor.g, E.myColor.b, .3)
            guiTab[num].checked = true
            guiPage[num]:Show()
        else
            guiTab[num]:SetBackdropColor(0, 0, 0, .3)
            guiTab[num].checked = false
            guiPage[num]:Hide()
        end
    end
end
ns.SelectTab = SelectTab

local function tabOnClick(self)
    PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)
    SelectTab(self.index)
end

local function tabOnEnter(self)
    if self.checked then return end
    self:SetBackdropColor(E.myColor.r, E.myColor.g, E.myColor.b, .3)
end

local function tabOnLeave(self)
    if self.checked then return end
    self:SetBackdropColor(0, 0, 0, .3)
end

local function CreateTab(parent, i, name)
    local tab = CreateFrame("Button", nil, parent)
    tab:SetPoint("TOPLEFT", 20, -30 * i - 20 + E.mult)
    tab:SetSize(130, 28)
    tab:SetTemplate("Default", nil, 0)

    tab:CreateFontText(14, name, false, "LEFT", 10, 0)
    tab.index = i

    tab:SetScript("OnClick", tabOnClick)
    tab:SetScript("OnEnter", tabOnEnter)
    tab:SetScript("OnLeave", tabOnLeave)

    guiTab[i] = tab

    return tab
end
ns.CreateTab = CreateTab

local function CreatePage(parent, i)
    local page = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    page:SetPoint("TOPLEFT", 160, -50)
    page:SetSize(610, 500)

    page:CreateBackground()
    page.bg:CreateBackdrop()

    page:Hide()
    page.child = CreateFrame("Frame", nil, page)
    page.child:SetSize(610, 1)

    page:SetScrollChild(page.child)

    guiPage[i] = page

    return page
end
ns.CreatePage = CreatePage

local function CreateGear(parent)
    local bu = CreateFrame("Button", nil, parent)
    bu:SetSize(22, 22)
    bu.Icon = bu:CreateTexture(nil, "ARTWORK")
    bu.Icon:SetAllPoints()
    bu.Icon:SetTexture(gearTex)
    bu.Icon:SetTexCoord(0, .5, 0, .5)
    bu:SetHighlightTexture(gearTex)
    bu:GetHighlightTexture():SetTexCoord(0, .5, 0, .5)

    return bu
end

local function tooltipOnEnter(self)
    GameTooltip:SetOwner(self, self.anchor)
    GameTooltip:ClearLines()
    if self.title then
        GameTooltip:AddLine(self.title)
    end
    if tonumber(self.text) then
        GameTooltip:SetSpellByID(self.text)
    elseif self.text then
        local r, g, b = 1, 1, 1
        if self.color == "class" then
            r, g, b = E.class.r, E.class.g, E.class.b
        elseif self.color == "system" then
            r, g, b = 1, .8, 0
        elseif self.color == "info" then
            r, g, b = .6, .8, 1
        end
        GameTooltip:AddLine(self.text, r, g, b, 1)
    end
    GameTooltip:Show()
end

local function AddTooltip(self, anchor, text, color)
    self.anchor = anchor
    self.text = text
    self.color = color
    self:SetScript("OnEnter", tooltipOnEnter)
    self:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local function CreateGradient(parent, w, h, o, r, g, b, a1, a2)
    parent:SetSize(w, h)
    parent:SetFrameStrata("BACKGROUND")
    
    local gradientFrom, gradientTo = CreateColor(r, g, b, a1), CreateColor(r, g, b, a2)

    local gf = parent:CreateTexture(nil, "BACKGROUND")
    gf:SetAllPoints()
    gf:SetTexture(C.media.texture.gradient)
    gf:SetGradient(o, gradientFrom, gradientTo)
end

local function CreateCheckBox(parent)
    local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    E:SkinCheckBox(cb)

    cb.name = cb:CreateFontText(14, '', false, "LEFT", 30, 0)

    local OnEnable = function(self) self.bg:SetBackdropBorderColor(unpack(C.media.text_color)) end
    local OnDisable = function(self) self.bg:SetBackdropBorderColor(unpack(diabled_color)) end
    hookAvaliable(cb, { cb.name }, OnEnable, OnDisable)

    return cb
end
ns.CreateCheckBox = CreateCheckBox

local function CreateButton(parent, width, height, text, fontSize, name)
    local bu = CreateFrame("Button", name, parent)
    bu:SetSize(width, height)
    E:StyleTextButton(bu)

    bu.text = bu:CreateFontText(fontSize or 14, text, true)

    return bu
end
ns.CreateButton = CreateButton

local function optOnClick(self)
    PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)
    local opt = self.__owner.options
    for i = 1, #opt do
        if self == opt[i] then
            opt[i]:SetBackdropColor(1, .8, 0, .3)
            opt[i].selected = true
        else
            opt[i]:SetBackdropColor(0, 0, 0, .3)
            opt[i].selected = false
        end
    end
    self.__owner.Text:SetText(self.text)
    self:GetParent():Hide()
end

local function optOnEnter(self)
    if self.selected then return end
    self:SetBackdropColor(1, 1, 1, .25)
end

local function optOnLeave(self)
    if self.selected then return end
    self:SetBackdropColor(0, 0, 0)
end

local function buttonOnShow(self)
    self.__list:Hide()
end

local function buttonOnClick(self)
    PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)
    ToggleFrame(self.__list)
end

local function CreateDropDown(parent, width, height, data)
    local dd = CreateFrame("Frame", nil, parent)
    dd:SetSize(width, height)
    dd:SetTemplate("Blur")
    dd:SetBackdropBorderColor(1, 1, 1, .2)
    dd.Text = dd:CreateFontText(14, "", false)
    dd.options = {}

    local bu = CreateGear(dd)
    bu:SetPoint("LEFT", dd, "RIGHT", -2, 0)
    local list = CreateFrame("Frame", nil, dd)
    list:SetPoint("TOP", dd, "BOTTOM", 0, -2)
    list:SetTemplate("Default")
    list:SetBackdropBorderColor(1, 1, 1, .2)
    list:Hide()
    bu.__list = list
    bu:SetScript("OnShow", buttonOnShow)
    bu:SetScript("OnClick", buttonOnClick)
    dd.button = bu

    local opt, index = {}, 0
    for i, j in pairs(data) do
        opt[i] = CreateFrame("Button", nil, list)
        opt[i]:SetPoint("TOPLEFT", 4, -4 - (i - 1) * (height + 2))
        opt[i]:SetSize(width - 8, height)
        opt[i]:SetTemplate("Default")
        local text = opt[i]:CreateFontText(14, j, false, "LEFT", 5, 0)
        text:SetPoint("RIGHT", -5, 0)
        opt[i].text = j
        opt[i].__owner = dd
        opt[i]:SetScript("OnClick", optOnClick)
        opt[i]:SetScript("OnEnter", optOnEnter)
        opt[i]:SetScript("OnLeave", optOnLeave)

        dd.options[i] = opt[i]
        index = index + 1
    end
    list:SetSize(width, index * (height + 2) + 6)

    dd.Type = "DropDown"
    return dd
end

local function editBoxClearFocus(self)
    self:ClearFocus()
end

local function CreateEditBox(parent, width, height)
    local eb = CreateFrame("EditBox", nil, parent)
    eb:SetSize(width, height)
    eb:SetAutoFocus(false)
    eb:SetTextInsets(5, 5, 0, 0)
    eb:SetFont(unpack(C.media.standard_font))
    eb:SetTemplate("Blur")

    eb:SetScript("OnEscapePressed", editBoxClearFocus)
    eb:SetScript("OnEnterPressed", editBoxClearFocus)

    eb.Type = "EditBox"
    return eb
end

local function updateSliderEditBox(self)
    local slider = self.__owner
    local minValue, maxValue = slider:GetMinMaxValues()
    local text = tonumber(self:GetText())

    if not text then return end

    text = min(maxValue, text)
    text = max(minValue, text)

    slider:SetValue(text)

    self:SetText(text)
    self:ClearFocus()
end

local function CreateSlider(parent, name, minValue, maxValue, x, y, width)
    local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", x, y)
    slider:SetWidth(width or 200)
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetHitRectInsets(0, 0, 0, 0)
    --slider:SetBackdrop(nil)

    slider.Low:SetText(minValue)
    slider.Low:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 10, -2)
    --slider.Low:SetTextColor(C.media.text_color)
    slider.High:SetText(maxValue)
    slider.High:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", -10, -2)
    --slider.High:SetTextColor(C.media.text_color)
    slider.Text:ClearAllPoints()
    slider.Text:SetPoint("CENTER", 0, 25)
    slider.Text:SetText(name)
    slider.Text:SetTextColor(1, .8, 0)
    slider.Thumb:SetTexture(sparkTex)
    slider.Thumb:SetBlendMode("ADD")

    slider:CreateBackground()
    slider.bg:SetPoint("TOPLEFT", 14, -2)
    slider.bg:SetPoint("BOTTOMRIGHT", -15, 3)
    slider.bg:SetTemplate("Overlay")

    slider.value = CreateEditBox(slider, 50, 20)
    slider.value:SetPoint("TOP", slider, "BOTTOM")
    slider.value:SetJustifyH("CENTER")
    slider.value.__owner = slider
    slider.value:SetScript("OnEnterPressed", updateSliderEditBox)

    hookAvaliable(slider, { slider.Low, slider.Text, slider.High })
    slider:HookScript("OnEnable", function(self)
        self.Text:SetTextColor(1, .8, 0)
    end)

    return slider
end

local function CreateOption(i)
    local parent, offset = guiPage[i].child, 20
    local optionList = ns.OptionList[i]

    if not optionList or type(optionList) ~= 'table' then return end

    for _, option in ipairs(optionList) do
        local optType, group, key, name, horizon, data, init, callback, tooltip = unpack(option)
        -- TextLine
        if optType == 0 then
            local line = parent:CreateFontText(14, '', false, "LEFT", 30, 0)
            line:SetText(group .. key .. name)
            if horizon then
                line:SetPoint("TOPLEFT", 330, -offset + 35)
            else
                line:SetPoint("TOPLEFT", 20, -offset)
                offset = offset + 35
            end
        -- Checkbox
        elseif optType == 1 then
            local cb = CreateCheckBox(parent)
            cb:SetHitRectInsets(-5, -5, -5, -5)
            if horizon then
                cb:SetPoint("TOPLEFT", 330, -offset + 35)
            else
                cb:SetPoint("TOPLEFT", 20, -offset)
                offset = offset + 35
            end
            cb:SetChecked(Variable(group, key))
            cb:SetScript("OnClick", function(self)
                Variable(group, key, self:GetChecked())
                if callback then callback(self:GetChecked()) end
            end)
            cb.name:SetText(name)
            if data and type(data) == "function" then
                local bu = CreateGear(parent)
                bu:SetPoint("LEFT", cb.name, "RIGHT", -2, 1)
                bu:SetScript("OnClick", data)
            end
            if tooltip then
                cb.title = L_TIPS
                AddTooltip(cb, "ANCHOR_RIGHT", tooltip, "info")
            end

            if init then init(cb) end
            ns.opt_widgets[group .. ':' .. key] = cb
            -- Slider
        elseif optType == 3 then
            local min, max, step = unpack(data)
            local decimal = step > 2 and 2 or step
            local x, y
            if horizon then
                x, y = 350, -offset + 40
            else
                x, y = 40, -offset - 30
                offset = offset + 70
            end
            local s = CreateSlider(parent, name, min, max, x, y)
            s:SetValue(Variable(group, key))
            s:SetScript("OnValueChanged", function(_, v)
                local current = tonumber(format("%." .. step .. "f", v))
                Variable(group, key, v)
                s.value:SetText(format("%." .. decimal .. "f", current))
                if callback then
                    if type(callback) == 'string' then
                        RunScript(callback)
                    else
                        callback(v)
                    end
                end
            end)
            s.value:SetText(Variable(group, key))

            if init then init(s) end
            ns.opt_widgets[group .. ':' .. key] = s
            -- Dropdown
        elseif optType == 4 then
            local dd = CreateDropDown(parent, 200, 28, data)
            if horizon then
                dd:SetPoint("TOPLEFT", 345, -offset + 45)
            else
                dd:SetPoint("TOPLEFT", 35, -offset - 25)
                offset = offset + 70
            end
            dd.Text:SetText(data[Variable(group, key)] or Variable(group, key))

            local opt = dd.options
            dd.button:HookScript("OnClick", function()
                for num = 1, #data do
                    if num == Variable(group, key) then
                        opt[num]:SetBackdropColor(1, .8, 0, .3)
                        opt[num].selected = true
                    else
                        opt[num]:SetBackdropColor(0, 0, 0, .3)
                        opt[num].selected = false
                    end
                end
            end)
            for i, _ in pairs(data) do
                opt[i]:HookScript("OnClick", function()
                    Variable(group, key, i)
                    if callback then callback(i) end
                end)
            end

            if horizon then
                dd:CreateFontText(14, name, false, "CENTER", 0, 25)
            else
                local title = dd:CreateFontText(14, name, false)
                title:SetPoint("RIGHT", dd, "LEFT", -20, 0)
                local p1, t, p2, x, y = dd:GetPoint()
                dd:SetPoint(p1, t, p2, x + math.max(title:GetWidth(), 73), y)
            end

            if init then init(dd) end
            ns.opt_widgets[group .. ':' .. key] = dd
            -- Blank, no optType
        else
            local l = CreateFrame("Frame", nil, parent)
            l:SetPoint("TOPLEFT", 25, -offset - 12)
            CreateGradient(l, 560, E.mult, "Horizontal", 1, 1, 1, .25, .25)
            offset = offset + 35
        end
    end
end
ns.CreateOption = CreateOption

function ns.DeepCopy(obj, seen)
    -- Handle non-tables and previously-seen tables.
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end

    -- New table; mark it as seen an copy recursively.
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[ns.DeepCopy(k, s)] = ns.DeepCopy(v, s) end
    return res
end

local init = CreateFrame("Frame")
init:RegisterEvent("PLAYER_LOGIN")
init:SetScript("OnEvent", function()
    if not DarkUI then return end

    if not SavedOptionsPerChar then SavedOptionsPerChar = {} end
    if not SavedOptions then SavedOptions = { global = false } end

    --TODO remove unused saved options for new version

    E, C, _ = DarkUI:unpack()
end)
