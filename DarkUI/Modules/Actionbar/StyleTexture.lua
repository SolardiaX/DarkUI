local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable or not C.actionbar.bars.texture then return end

----------------------------------------------------------------------------------------
--    Background Art for Actionbars
----------------------------------------------------------------------------------------
local module = E:Module("Actionbar"):Sub("Texture")

local _G = _G
local CreateFrame = CreateFrame

local media = {
    mainbar_bg                      = C.media.path .. "bar_mainbar_bg",
    mainbar                         = C.media.path .. C.general.style .. "\\" .. "bar_mainbar" .. (C.general.liteMode and "_lite" or ""),
    leftbar                         = C.media.path .. C.general.style .. "\\" .. "bar_leftbar" .. (C.general.liteMode and "_lite" or ""),
    rightbar                        = C.media.path .. C.general.style .. "\\" .. "bar_rightbar" .. (C.general.liteMode and "_lite" or ""),
    mainbar_statusbar_overlay       = C.media.path .. C.general.style .. "\\" .. "bar_mainbar_bar_overlay",
    mainbar_statusbar_topfill       = C.media.path .. C.general.style .. "\\" .. "bar_mainbar_bar_bottom_fill",
    mainbar_statusbar_bottomfill    = C.media.path .. C.general.style .. "\\" .. "bar_mainbar_bar_top_fill",
}

function module:OnInit()
    local MainMenuBarBG = CreateFrame("Frame", "DarkUI_ActionBar1BG", _G["DarkUI_ActionBar1"])
    MainMenuBarBG:SetFrameStrata("BACKGROUND")
    MainMenuBarBG:SetFrameLevel(2)
    MainMenuBarBG:SetSize(1024, 128)
    MainMenuBarBG:SetPoint("BOTTOM", _G["DarkUI_ActionBar1"], -3, -50)
    -- MainMenuBarBG:SetScale(.98)

    MainMenuBarBG.texture = MainMenuBarBG:CreateTexture(nil, "BACKGROUND")
    MainMenuBarBG.texture:SetTexture(media.mainbar)
    MainMenuBarBG.texture:SetAllPoints(MainMenuBarBG)

    if _G["DarkUI_ActionBar2"] then
        local BarBottomLeftBG = CreateFrame("Frame", "DarkUI_ActionBar2BG", _G["DarkUI_ActionBar2"])
        BarBottomLeftBG:SetFrameStrata("BACKGROUND")
        BarBottomLeftBG:SetFrameLevel(C.general.style == "cold" and 3 or 4)
        BarBottomLeftBG:SetSize(1028, 256)
        if C.general.liteMode then
            BarBottomLeftBG:SetPoint("BOTTOM", _G["DarkUI_ActionBar2"], 1, -128)
        else
            BarBottomLeftBG:SetPoint("BOTTOM", _G["DarkUI_ActionBar2"], -1, -127)
        end
        -- BarBottomLeftBG:SetScale(0.98)

        BarBottomLeftBG.texture = BarBottomLeftBG:CreateTexture(nil, "OVERLAY")
        BarBottomLeftBG.texture:SetTexture(media.leftbar)
        BarBottomLeftBG.texture:SetAllPoints(BarBottomLeftBG)
    end

    if _G["DarkUI_ActionBar3"] then
        local BarBottomRightBG = CreateFrame("Frame", "DarkUI_ActionBar3BG", _G["DarkUI_ActionBar3"])
        BarBottomRightBG:SetFrameStrata("BACKGROUND")
        BarBottomRightBG:SetFrameLevel(C.general.style == "cold" and 4 or 3)
        BarBottomRightBG:SetSize(1026, 128)
        -- BarBottomRightBG:SetScale(0.98)
        if C.general.liteMode then
            BarBottomRightBG:SetPoint("BOTTOM", _G["DarkUI_ActionBar3"], 1, -50)
        else
            BarBottomRightBG:SetPoint("BOTTOM", _G["DarkUI_ActionBar3"], 0, -47)
        end

        BarBottomRightBG.texture = BarBottomRightBG:CreateTexture(nil, "BACKGROUND")
        BarBottomRightBG.texture:SetTexture(media.rightbar)
        BarBottomRightBG.texture:SetAllPoints(BarBottomRightBG)
    end

    local MainMenuBarBGFill = CreateFrame("Frame", "DarkUI_ActionBarBGFill", MainMenuBarBG)
    MainMenuBarBGFill:SetFrameStrata("BACKGROUND")
    MainMenuBarBGFill:SetFrameLevel(0)
    MainMenuBarBGFill:SetSize(1024, 128)
    MainMenuBarBGFill:SetPoint("BOTTOM", MainMenuBarBG, 0, 0)

    MainMenuBarBGFill.texture = MainMenuBarBGFill:CreateTexture(nil, "BACKGROUND")
    MainMenuBarBGFill.texture:SetTexture(media.mainbar_bg)
    MainMenuBarBGFill.texture:SetAllPoints(MainMenuBarBGFill)

    if C.actionbar.bars.exp.enable then
        local StatusBarTopOverlay = CreateFrame("Frame", "DarkUI_StatusBarTopOverlay", MainMenuBarBG)
        StatusBarTopOverlay:SetFrameStrata("BACKGROUND")
        StatusBarTopOverlay:SetFrameLevel(4)
        StatusBarTopOverlay:SetSize(512, 16)
        StatusBarTopOverlay:SetPoint("CENTER", _G["DarkUI_XPBar"], 1, 0)

        StatusBarTopOverlay.texture = StatusBarTopOverlay:CreateTexture(nil, "BACKGROUND")
        StatusBarTopOverlay.texture:SetTexture(media.mainbar_statusbar_overlay)
        StatusBarTopOverlay.texture:SetAllPoints(StatusBarTopOverlay)
    else
        local StatusBarTopFill = CreateFrame("Frame", "DarkUI_StatusBarTopFill", MainMenuBarBG)
        StatusBarTopFill:SetFrameStrata("BACKGROUND")
        StatusBarTopFill:SetFrameLevel(4)
        StatusBarTopFill:SetSize(512, 16)
        StatusBarTopFill:SetPoint("BOTTOM", MainMenuBarBG, 4, 32)

        StatusBarTopFill.texture = StatusBarTopFill:CreateTexture(nil, "BACKGROUND")
        StatusBarTopFill.texture:SetTexture(media.mainbar_statusbar_topfill)
        StatusBarTopFill.texture:SetAllPoints(StatusBarTopFill)
    end

    if C.actionbar.bars.artifact.enable then
        local MainMenuBarBottomOverlay = CreateFrame("Frame", "DarkUI_ActionBar1BarBottomOverlay", MainMenuBarBG)
        MainMenuBarBottomOverlay:SetFrameStrata("BACKGROUND")
        MainMenuBarBottomOverlay:SetFrameLevel(4)
        MainMenuBarBottomOverlay:SetSize(512, 16)
        MainMenuBarBottomOverlay:SetPoint("CENTER", _G["DarkUI_ArtifactBar"], 1, 0)

        MainMenuBarBottomOverlay.texture = MainMenuBarBottomOverlay:CreateTexture(nil, "BACKGROUND")
        MainMenuBarBottomOverlay.texture:SetTexture(media.mainbar_statusbar_overlay)
        MainMenuBarBottomOverlay.texture:SetAllPoints(MainMenuBarBottomOverlay)
    else
        local MainMenuBarBottomFill = CreateFrame("Frame", "DarkUI_ActionBar1BarBottomFill", MainMenuBarBG)
        MainMenuBarBottomFill:SetFrameStrata("BACKGROUND")
        MainMenuBarBottomFill:SetFrameLevel(4)
        MainMenuBarBottomFill:SetSize(512, 16)
        MainMenuBarBottomFill:SetPoint("BOTTOM", MainMenuBarBG, 4, 21)

        MainMenuBarBottomFill.texture = MainMenuBarBottomFill:CreateTexture(nil, "BACKGROUND")
        MainMenuBarBottomFill.texture:SetTexture(media.mainbar_statusbar_bottomfill)
        MainMenuBarBottomFill.texture:SetAllPoints(MainMenuBarBottomFill)
    end
end