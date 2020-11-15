local E, C
local _, ns = ...

local infoColor = "|cff99ccff"

local console

tinsert(UISpecialFrames, console)

local function OpenGUI()
    if InCombatLockdown() then
        UIErrorsFrame:AddMessage(infoColor .. ERR_NOT_IN_COMBAT)
        return
    end
    if console then
        console:Show()
        return
    end

    console = CreateFrame("Frame", "DarkUIConsole", UIParent)
    console:SetSize(800, 600)
    console:SetPoint("CENTER")
    console:SetFrameStrata("HIGH")
    console:SetFrameLevel(5)
    console:SetTemplate("Default")
    console:CreateShadow()

    console:SetMovable(true)
    console:SetUserPlaced(true)
    console:SetClampedToScreen(true)

    console:CreateFontText(18, L_DARKUI_CONSOLE, false, "TOP", 0, -10)
    console:CreateFontText(16, E.version, false, "TOP", 0, -30)

    StaticPopupDialogs["RELOADUI_CONFIRM"] = {
        text         = L_POPUP_CONFIRM_RELOAD,
        button1      = ACCEPT,
        button2      = CANCEL,
        OnAccept     = function() ReloadUI() end,
        whileDead    = 1,
        timeout      = 0,
        hideOnEscape = 1,
    }

    local closeButton = ns.CreateButton(console, 80, 20, CLOSE)
    closeButton:SetPoint("BOTTOMRIGHT", -20, 15)
    closeButton:SetScript("OnClick", function() console:Hide() end)

    local resetButton = ns.CreateButton(console, 80, 20, L_RESET, nil, "DarkUIConsoleApplyButton")
    resetButton:SetPoint("RIGHT", closeButton, "LEFT", -20, 0)
    resetButton:SetScript("OnClick", function() StaticPopup_Show("RESETUI_CONFIRM") end)

    local applyButton = ns.CreateButton(console, 80, 20, APPLY, nil, "DarkUIConsoleApplyButton")
    applyButton:SetPoint("RIGHT", resetButton, "LEFT", -20, 0)
    applyButton:SetScript("OnClick", function() StaticPopup_Show("RELOADUI_CONFIRM") end)
    applyButton:Hide()
    ns.applyButton = applyButton

    local globalChecked = ns.CreateCheckBox(console)
    globalChecked:SetPoint("BOTTOMLEFT", 20, 15)
    globalChecked.name:SetText(L_GLOBAL_OPTION)
    globalChecked:SetChecked(SavedOptions.global)
    globalChecked:HookScript("OnClick", function(self)
        local source = self:GetChecked() and SavedOptionsPerChar or SavedOptions

        local target = ns.DeepCopy(source)
        if self:GetChecked() then
            target.global = true
            SavedOptions = target
            SavedOptionsPerChar = {}
        else
            SavedOptionsPerChar = target
            SavedOptions = {}
        end
    end)

    for i, name in pairs(ns.Categories) do
        ns.CreateTab(console, i, name)
        ns.CreatePage(console, i)
        ns.CreateOption(i)
    end

    for _, hook in pairs(ns.Hooks) do
        hook()
    end

    ns.SelectTab(1)
end

local gui = CreateFrame("Button", "GameMenuFrameDarkUI", GameMenuFrame, "GameMenuButtonTemplate")
gui:SetText(L_DARKUI_CONSOLE)
gui:SetPoint("TOP", GameMenuButtonAddons, "BOTTOM", 0, -21)
GameMenuFrame:HookScript("OnShow", function(self)
    GameMenuButtonLogout:SetPoint("TOP", gui, "BOTTOM", 0, -21)
    self:SetHeight(self:GetHeight() + gui:GetHeight() + 22)
end)

gui:SetScript("OnClick", function()
    if not E then E, C, _ = DarkUI:unpack() end

    HideUIPanel(GameMenuFrame)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
    OpenGUI()
end)
