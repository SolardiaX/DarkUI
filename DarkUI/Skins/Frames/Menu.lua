local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB
local cr, cg, cb = DB.r, DB.g, DB.b

------------------------------------------------------------------------
-- Game Menu (Esc menu)
-- Ported from AuroraClassic FrameXML/GameMenuFrame.lua (2026-06)
-- Dropped: Aurora noise overlay (DarkUI backdrop carries the texture)
------------------------------------------------------------------------

local _G = _G

function S:Menu()
    if not (C.skins.enable and C.skins.misc) then return end

    local GameMenuFrame = _G.GameMenuFrame

    GameMenuFrame.Header:StripTextures()
    GameMenuFrame.Header:ClearAllPoints()
    GameMenuFrame.Header:SetPoint("TOP", GameMenuFrame, 0, 7)
    S:SetBD(GameMenuFrame)
    GameMenuFrame.Border:Hide()
    GameMenuFrame.Header.Text:SetFontObject(Game16Font)

    local line = GameMenuFrame.Header:CreateTexture(nil, "ARTWORK")
    line:SetSize(156, E.mult)
    line:SetPoint("BOTTOM", 0, 5)
    line:SetColorTexture(1, 1, 1, 0.25)

    local buttons = {
        "GameMenuButtonHelp",
        "GameMenuButtonWhatsNew",
        "GameMenuButtonStore",
        "GameMenuButtonMacros",
        "GameMenuButtonAddons",
        "GameMenuButtonLogout",
        "GameMenuButtonQuit",
        "GameMenuButtonContinue",
        "GameMenuButtonSettings",
        "GameMenuButtonEditMode",
    }
    for _, buttonName in next, buttons do
        local button = _G[buttonName]
        if button then S:Reskin(button) end
    end

    hooksecurefunc(GameMenuFrame, "InitButtons", function(self)
        if not self.buttonPool then return end

        for button in self.buttonPool:EnumerateActive() do
            if not button.__styled then
                button:DisableDrawLayer("BACKGROUND")
                button.backdrop = nil
                button.bg = button:CreateBackdrop()
                button.bg:SetInside()
                local hl = button:GetHighlightTexture()
                hl:SetColorTexture(cr, cg, cb, 0.25)
                hl:SetInside(button.bg)

                button.__styled = true
            end
        end
    end)
end

S:AddCallback("Menu")
