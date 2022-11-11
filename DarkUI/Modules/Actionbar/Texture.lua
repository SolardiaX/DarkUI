local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable or not C.actionbar.bars.texture then return end

----------------------------------------------------------------------------------------
--	Background Art for Actionbars
----------------------------------------------------------------------------------------

local _G = _G
local CreateFrame = CreateFrame

local media = {
    mainbar_bg = C.media.path .. "bar_mainbar_bg",
    mainbar    = C.media.path .. C.general.style .. "\\" .. "bar_mainbar" .. (C.general.liteMode and "_lite" or ""),
    leftbar    = C.media.path .. C.general.style .. "\\" .. "bar_leftbar" .. (C.general.liteMode and "_lite" or ""),
    rightbar   = C.media.path .. C.general.style .. "\\" .. "bar_rightbar" .. (C.general.liteMode and "_lite" or "")
}

local MainMenuBarBG = CreateFrame("Frame", "DarkUI_ActionBar1HolderBG", _G["DarkUI_ActionBar1Holder"])
MainMenuBarBG:SetFrameStrata("BACKGROUND")
MainMenuBarBG:SetFrameLevel(2)
MainMenuBarBG:SetSize(1024, 128)
MainMenuBarBG:SetPoint("BOTTOM", _G["DarkUI_ActionBar1Holder"], -3, -50)
MainMenuBarBG:SetScale(.98)

MainMenuBarBG.texture = MainMenuBarBG:CreateTexture(nil, "BACKGROUND")
MainMenuBarBG.texture:SetTexture(media.mainbar)
MainMenuBarBG.texture:SetAllPoints(MainMenuBarBG)

local BarBottomLeftBG = CreateFrame("Frame", "DarkUI_ActionBar2HolderBG", _G["DarkUI_ActionBar2Holder"])
BarBottomLeftBG:SetFrameStrata("BACKGROUND")
BarBottomLeftBG:SetFrameLevel(C.general.style == "cold" and 3 or 4)
BarBottomLeftBG:SetSize(1024, 256)
if C.general.liteMode then
    BarBottomLeftBG:SetPoint("BOTTOM", _G["DarkUI_ActionBar2Holder"], 4, -128)
else
    BarBottomLeftBG:SetPoint("BOTTOM", _G["DarkUI_ActionBar2Holder"], 2, -127)
end
BarBottomLeftBG:SetScale(0.98)

BarBottomLeftBG.texture = BarBottomLeftBG:CreateTexture(nil, "OVERLAY")
BarBottomLeftBG.texture:SetTexture(media.leftbar)
BarBottomLeftBG.texture:SetAllPoints(BarBottomLeftBG)

local BarBottomRightBG = CreateFrame("Frame", "DarkUI_ActionBar3HolderBG", _G["DarkUI_ActionBar3Holder"])
BarBottomRightBG:SetFrameStrata("BACKGROUND")
BarBottomRightBG:SetFrameLevel(C.general.style == "cold" and 4 or 3)
BarBottomRightBG:SetSize(1024, 128)
BarBottomRightBG:SetScale(0.98)
if C.general.liteMode then
    --BarBottomRightBG:SetPoint("BOTTOM", UIParent, 3.5, -52)
    BarBottomRightBG:SetPoint("BOTTOM", _G["DarkUI_ActionBar3Holder"], 4, -49)
else
    BarBottomRightBG:SetPoint("BOTTOM", _G["DarkUI_ActionBar3Holder"], 4, -49)
end

BarBottomRightBG.texture = BarBottomRightBG:CreateTexture(nil, "BACKGROUND")
BarBottomRightBG.texture:SetTexture(media.rightbar)
BarBottomRightBG.texture:SetAllPoints(BarBottomRightBG)

local MainMenuBarBGFill = CreateFrame("Frame", "DarkUI_ActionBar1HolderBG", MainMenuBarBG)
MainMenuBarBGFill:SetFrameStrata("BACKGROUND")
MainMenuBarBGFill:SetFrameLevel(0)
MainMenuBarBGFill:SetSize(1024, 128)
MainMenuBarBGFill:SetPoint("BOTTOM", MainMenuBarBG, 0, 0)

MainMenuBarBGFill.texture = MainMenuBarBGFill:CreateTexture(nil, "BACKGROUND")
MainMenuBarBGFill.texture:SetTexture(media.mainbar_bg)
MainMenuBarBGFill.texture:SetAllPoints(MainMenuBarBGFill)
