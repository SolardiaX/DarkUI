local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Context menus (dropdown menus)
-- Ported from ElvUI Mainline/Skins/Menu.lua (v15.15, 2026-06)
------------------------------------------------------------------------

local _G = _G
local hooksecurefunc = hooksecurefunc

local function SkinFrame(frame)
    frame:StripTextures()

    -- Single-field .backdrop doubles as the created-once guard, so a pooled menu
    -- frame keeps its backdrop on reuse — no external relink table needed.
    if not frame.backdrop then
        frame:CreateBackdrop("Transparent") -- :SetTemplate errors out
        frame.backdrop:SetInside(nil, 1, 5)

        if frame.ScrollBar then S:HandleTrimScrollBar(frame.ScrollBar) end
    end

    frame.backdrop:OffsetFrameLevel(nil, frame)
end

function S:SkinMenu(manager, ownerRegion, menuDescription, anchor)
    local menu = manager:GetOpenMenu()
    if not menu then return end

    SkinFrame(menu) -- Initial context menu
    menuDescription:AddMenuAcquiredCallback(SkinFrame) -- SubMenus
end

function S:OpenMenu(ownerRegion, menuDescription, anchor)
    S:SkinMenu(self, ownerRegion, menuDescription, anchor) -- self is manager (Menu.GetManager)
end

function S:OpenContextMenu(ownerRegion, menuDescription)
    S:SkinMenu(self, ownerRegion, menuDescription) -- self is manager (Menu.GetManager)
end

function S:Blizzard_Menu()
    if not (C.skins.enable and C.skins.misc) then return end

    local manager = _G.Menu.GetManager()
    if manager then
        hooksecurefunc(manager, "OpenMenu", S.OpenMenu)
        hooksecurefunc(manager, "OpenContextMenu", S.OpenContextMenu)
    end
end

S:AddCallbackForAddon("Blizzard_Menu")
