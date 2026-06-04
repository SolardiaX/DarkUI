local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
-- MicroMenu
----------------------------------------------------------------------------------------
local module = E:Module("Actionbar"):Sub("MicroMenu")

local cfg = C.actionbar.bars.micromenu

local buttonList = {
    "CharacterMicroButton",
    "ProfessionMicroButton",
    "PlayerSpellsMicroButton",
    "AchievementMicroButton",
    "QuestLogMicroButton",
    "HousingMicroButton",
    "GuildMicroButton",
    "LFDMicroButton",
    "EJMicroButton",
    "CollectionsMicroButton",
    "StoreMicroButton",
    "MainMenuMicroButton",
}

local num = #buttonList

function module:OnInit()
    if not cfg then
        return
    end

    local bar = CreateFrame("Frame", "DarkUI_MicroMenuBarHolder", UIParent, "SecureHandlerStateTemplate")
    bar:SetWidth(num * cfg.button.size + (num - 1) * cfg.button.space)
    bar:SetHeight(cfg.button.size)
    bar:SetPoint(unpack(cfg.pos))
    bar:SetScale(cfg.scale)
    bar.buttonList = {}

    local previous
    for i, b in pairs(buttonList) do
        local button = _G[b]
        if button then
            button:SetScale(0.75)
            local bg = button:CreateBG()
            bg:CreateShadow()

            button:SetParent(bar)
            button.SetParent = E.Dummy

            button:ClearAllPoints()

            if i == 1 then
                button:SetPoint("LEFT", bar, "LEFT", 0, 0)
            else
                button:SetPoint("LEFT", previous, "RIGHT", cfg.button.space + 4, 0)
            end

            button:HookScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
                GameTooltip_SetTitle(GameTooltip, self.tooltipText)
            end)

            tinsert(bar.buttonList, button)
            previous = button
        end
    end

    RegisterStateDriver(bar, "visibility", "[petbattle] hide; show")

    if cfg.fader_mouseover then
        E:ButtonBarFader(bar, bar.buttonList, cfg.fader_mouseover.fadeIn, cfg.fader_mouseover.fadeOut)
    end

    if HelpOpenWebTicketButton then
        HelpOpenWebTicketButton:Kill()
    end
    if MainMenuMicroButton then
        if MainMenuMicroButton.MainMenuBarPerformanceBar then
            MainMenuMicroButton.MainMenuBarPerformanceBar:Kill()
        end
        MainMenuMicroButton:SetScript("OnUpdate", nil)
    end
    if MicroMenu and MicroMenu.UpdateHelpTicketButtonAnchor then
        MicroMenu.UpdateHelpTicketButtonAnchor = E.Dummy
    end
end
