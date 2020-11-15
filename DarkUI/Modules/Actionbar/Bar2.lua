local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable then return end

----------------------------------------------------------------------------------------
--	MultiBarBottomLeft (modified from ShestakUI)
----------------------------------------------------------------------------------------
local _G = _G
local CreateFrame = CreateFrame
local RegisterStateDriver = RegisterStateDriver
local unpack = unpack
local UIParent = _G.UIParent

local cfg = C.actionbar.bars.bar2
local num = NUM_ACTIONBAR_BUTTONS

if C.general.liteMode then
    cfg.button.space = 6.15
    cfg.button.size = 28
    cfg.pos = { "BOTTOM", "DarkUI_ActionBar1Holder", "TOP", -2.5, 27 }
end

local bar = CreateFrame("Frame", "DarkUI_ActionBar2Holder", UIParent, "SecureHandlerStateTemplate")
bar:SetPoint(unpack(cfg.pos))
bar:SetHeight(cfg.button.size)
bar:SetWidth(num * cfg.button.size + (num - 1) * cfg.button.space)
bar:SetFrameStrata("LOW")

_G.MultiBarBottomLeft:SetParent(bar)

for i = 1, num do
    local button = _G["MultiBarBottomLeftButton" .. i]

    button:SetSize(cfg.button.size, cfg.button.size)
    button:ClearAllPoints()

    if i == 1 then
        button:SetPoint("BOTTOMLEFT", bar, 3, 0)
    else
        local previous = _G["MultiBarBottomLeftButton" .. i - 1]
        button:SetPoint("LEFT", previous, "RIGHT", cfg.button.space, 0)
    end
end

RegisterStateDriver(bar, "visibility", "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists] hide; show")
