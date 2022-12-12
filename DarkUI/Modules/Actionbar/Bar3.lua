local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable then return end

----------------------------------------------------------------------------------------
--	MultiBarBottomRight (modified from ShestakUI)
----------------------------------------------------------------------------------------
local _G = _G
local CreateFrame = CreateFrame
local RegisterStateDriver = RegisterStateDriver
local unpack = unpack
local UIParent = _G.UIParent

local cfg = C.actionbar.bars.bar3
local num = NUM_ACTIONBAR_BUTTONS

if C.general.liteMode then
    cfg.button.space = 6.15
    cfg.button.size = 28
    cfg.pos = { "BOTTOM", "DarkUI_ActionBar2", "TOP", 0, 11 }
end

local bar = CreateFrame("Frame", "DarkUI_ActionBar3", UIParent, "SecureHandlerStateTemplate")
bar:SetPoint(unpack(cfg.pos))
bar:SetHeight(cfg.button.size)
bar:SetWidth(num * cfg.button.size + (num - 1) * cfg.button.space)
bar:SetFrameStrata("MEDIUM")

_G.MultiBarBottomRight:SetParent(bar)
_G.MultiBarBottomRight.QuickKeybindGlow:SetTexture("")

bar:RegisterEvent("PLAYER_ENTERING_WORLD")
bar:SetScript("OnEvent", function(self, event)
    for i = 1, num do
        local button = _G["MultiBarBottomRightButton" .. i]

        button:SetSize(cfg.button.size, cfg.button.size)
        button:ClearAllPoints()

        if i == 1 then
            button:SetPoint("BOTTOMLEFT", bar, 3, 0)
        else
            local previous = _G["MultiBarBottomRightButton" .. i - 1]
            button:SetPoint("LEFT", previous, "RIGHT", cfg.button.space, 0)
        end
    end

    RegisterStateDriver(bar, "visibility", "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists] hide; show")
end)