local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable then return end

----------------------------------------------------------------------------------------
--    StanceBar (modified from ShestakUI)
----------------------------------------------------------------------------------------
local module = E:Module("Actionbar"):Sub("BarStance")

local _G = _G
local CreateFrame = CreateFrame
local GetShapeshiftFormInfo, GetShapeshiftFormCooldown = GetShapeshiftFormInfo, GetShapeshiftFormCooldown
local CooldownFrame_Set = CooldownFrame_Set
local InCombatLockdown = InCombatLockdown
local RegisterStateDriver = RegisterStateDriver
local unpack, tinsert = unpack, tinsert
local UIParent = _G.UIParent
local StanceBar = _G.StanceBar
local NUM_STANCE_SLOTS = NUM_STANCE_SLOTS or 10

local cfg = C.actionbar.bars.barstance

local shiftBarUpdate = function()
    local numForms = GetNumShapeshiftForms()
    local texture, isActive, isCastable
    local button, icon, cooldown
    local start, duration, enable
    for i = 1, NUM_STANCE_SLOTS do
        button = _G["StanceButton"..i]
        icon = _G["StanceButton"..i.."Icon"]
        if i <= numForms then
            texture, isActive, isCastable = GetShapeshiftFormInfo(i)
            icon:SetTexture(texture)

            cooldown = _G["StanceButton"..i.."Cooldown"]
            if texture then
                cooldown:SetAlpha(1)
            else
                cooldown:SetAlpha(0)
            end

            start, duration, enable = GetShapeshiftFormCooldown(i)
            CooldownFrame_Set(cooldown, start, duration, enable)

            if isActive then
                button:SetChecked(true)
            else
                button:SetChecked(false)
            end

            if isCastable then
                icon:SetVertexColor(1.0, 1.0, 1.0)
            else
                icon:SetVertexColor(0.4, 0.4, 0.4)
            end
        end
    end
end

function module:OnInit()
    local bar = CreateFrame("Frame", "DarkUI_StanceBarHolder", UIParent, "SecureHandlerStateTemplate")
    bar:SetWidth(NUM_STANCE_SLOTS * cfg.button.size + (NUM_STANCE_SLOTS - 1) * cfg.button.space)
    bar:SetHeight(cfg.button.size)
    bar:SetPoint(unpack(cfg.pos))
    bar.buttonList = {}

    bar:RegisterEvent("PLAYER_LOGIN")
    bar:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
    bar:RegisterEvent("UPDATE_SHAPESHIFT_USABLE")
    bar:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN")
    bar:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
    bar:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_LOGIN" then
            StanceBar.ignoreFramePositionManager = true
            StanceBar:StripTextures()
            StanceBar:SetParent(bar)
            StanceBar:ClearAllPoints()
            StanceBar:SetPoint("TOPLEFT", bar, "TOPLEFT", -7, 0)
            StanceBar:EnableMouse(false)
            StanceBar:UnregisterAllEvents()

            for i = 1, NUM_STANCE_SLOTS do
                local button = _G["StanceButton" .. i]
                tinsert(bar.buttonList, button) --add the button object to the list
                button:SetSize(cfg.button.size, cfg.button.size)
                button:SetParent(bar)
                button:ClearAllPoints()
                if i == 1 then
                    button:SetPoint("BOTTOMLEFT", bar, 0, 0)
                else
                    local previous = _G["StanceButton" .. i - 1]
                    button:SetPoint("LEFT", previous, "RIGHT", cfg.button.space, 0)
                end

                local icon = GetShapeshiftFormInfo(i)
                if icon then
                    button:Show()
                else
                    button:Hide()
                end
            end

            --show/hide the frame on a given state driver
            bar.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
            RegisterStateDriver(bar, "visibility", bar.frameVisibility)

            --create the mouseover functionality
            if cfg.fader_mouseover then
                E:ButtonBarFader(bar, bar.buttonList, cfg.fader_mouseover.fadeIn, cfg.fader_mouseover.fadeOut)
            end

            --create the combat fader
            if cfg.fader_combat then
                E:CombatFrameFader(bar, cfg.fader_combat.fadeIn, cfg.fader_combat.fadeOut)
            end
        elseif event == "UPDATE_SHAPESHIFT_FORMS" then
            if InCombatLockdown() then return end
            for i = 1, NUM_STANCE_SLOTS do
                local button = _G["StanceButton"..i]
                local icon = GetShapeshiftFormInfo(i)
                if icon then
                    button:Show()
                else
                    button:Hide()
                end
            end
        else
            shiftBarUpdate()
        end
    end)
end