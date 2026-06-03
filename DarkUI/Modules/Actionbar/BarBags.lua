local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
-- Bags
----------------------------------------------------------------------------------------
local module = E:Module("Actionbar"):Sub("Bags")

local cfg = C.actionbar.bars.bags

local buttonList = {
    "MainMenuBarBackpackButton",
    "CharacterBag0Slot",
    "CharacterBag1Slot",
    "CharacterBag2Slot",
    "CharacterBag3Slot",
    "CharacterReagentBag0Slot",
}

local num = #buttonList

function module:OnInit()
    if not cfg then
        return
    end

    local bar = CreateFrame("Frame", "DarkUI_BagsHolder", UIParent, "SecureHandlerStateTemplate")
    bar:SetWidth(num * cfg.button.size + (num - 1) * cfg.button.space)
    bar:SetHeight(cfg.button.size)
    bar:SetPoint(unpack(cfg.pos))
    bar:SetScale(cfg.scale)
    bar.buttonList = {}

    bar:RegisterEvent("PLAYER_ENTERING_WORLD")
    bar:SetScript("OnEvent", function(self)
        if BagBarExpandToggle then
            BagBarExpandToggle:Hide()
        end

        local previous
        for i, b in pairs(buttonList) do
            local button = _G[b]
            if button then
                button:SetParent(bar)
                button.SetParent = E.Dummy
                tinsert(bar.buttonList, button)

                button:SetSize(cfg.button.size, cfg.button.size)
                button:ClearAllPoints()
                if button:GetNormalTexture() then
                    button:GetNormalTexture():SetAlpha(0)
                end
                if button:GetPushedTexture() then
                    button:GetPushedTexture():SetAlpha(0)
                end
                if button:GetHighlightTexture() then
                    button:GetHighlightTexture():SetAlpha(0)
                end
                if button.SlotHighlightTexture then
                    button.SlotHighlightTexture:Kill()
                end
                if button.CircleMask then
                    button.CircleMask:Hide()
                end

                local icon = button.icon or _G[button:GetName() .. "IconTexture"]
                if icon then
                    button.oldTex = icon:GetTexture()
                    icon:Show()
                    icon:SetInside()
                    icon:SetTexture((not button.oldTex or button.oldTex == 1721259) and C.media.path .. "bag_pack" or button.oldTex)
                end

                button:ClearAllPoints()
                if i == 1 then
                    button:SetPoint("LEFT", bar, "LEFT", 0, 0)
                else
                    button:SetPoint("LEFT", previous, "RIGHT", cfg.button.space, 0)
                end
                button.SetPoint = E.Dummy

                previous = button
            end
        end

        RegisterStateDriver(bar, "visibility", "[petbattle] hide; show")

        if cfg.fader_mouseover then
            E:ButtonBarFader(bar, bar.buttonList, cfg.fader_mouseover.fadeIn, cfg.fader_mouseover.fadeOut)
        end
    end)
end
