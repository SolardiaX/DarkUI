local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable and not C.actionbar.bars.bags.enable then return end

----------------------------------------------------------------------------------------
--    Bags (modified from ShestakUI & ElvUI)
----------------------------------------------------------------------------------------
local module = E:Module("Actionbar"):Sub("Bags")

local _G = _G
local CreateFrame = CreateFrame
local RegisterStateDriver = RegisterStateDriver
local unpack, tinsert = unpack, tinsert
local UIParent = _G.UIParent

local cfg = C.actionbar.bars.bags

local buttonList = {
    "MainMenuBarBackpackButton",
    "CharacterBag0Slot",
    "CharacterBag1Slot",
    "CharacterBag2Slot",
    "CharacterBag3Slot",
    "CharacterReagentBag0Slot"
}

local num = #buttonList

function module:OnInit()
    local bar = CreateFrame("Frame", "DarkUI_BagsHolder", UIParent, "SecureHandlerStateTemplate")
    bar:SetWidth(num * cfg.button.size + (num - 1) * cfg.button.space)
    bar:SetHeight(cfg.button.size)
    bar:SetPoint(unpack(cfg.pos))
    bar:SetScale(cfg.scale)
    bar.buttonList = {}

    bar:RegisterEvent("PLAYER_ENTERING_WORLD")
    bar:SetScript("OnEvent", function(self, event)
        _G.BagBarExpandToggle:Hide()

        --move the buttons into position and reparent them
        local previous
        for i, b in pairs(buttonList) do
            local button = _G[b]
            button:SetParent(bar)
            button.SetParent = E.Dummy
            tinsert(bar.buttonList, button) --add the button object to the list

            button:SetSize(cfg.button.size, cfg.button.size)
            button:ClearAllPoints()
            button:GetNormalTexture():SetAlpha(0)
            button:GetPushedTexture():SetAlpha(0)
            button:GetHighlightTexture():SetAlpha(0)
            button.SlotHighlightTexture:Kill()
            button.CircleMask:Hide()

            local icon = button.icon or _G[button:GetName()..'IconTexture']
            button.oldTex = icon:GetTexture()
            icon:Show()
            icon:SetInside()
            icon:SetTexture((not button.oldTex or button.oldTex == 1721259) and C.media.path .. "bag_pack" or button.oldTex)

            button:ClearAllPoints()
            if i == 1 then
                button:SetPoint("LEFT", bar, "LEFT", 0, 0)
            else
                button:SetPoint("LEFT", previous, "RIGHT", cfg.button.space, 0)
            end
            button.SetPoint = E.Dummy

            previous = button
        end

        --show/hide the frame on a given state driver
        RegisterStateDriver(bar, "visibility", "[petbattle] hide; show")

        if cfg.fader_mouseover then
            E:ButtonBarFader(bar, bar.buttonList, cfg.fader_mouseover.fadeIn, cfg.fader_mouseover.fadeOut)
        end
    end)
end