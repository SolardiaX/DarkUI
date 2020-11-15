local E, C, L = select(2, ...):unpack()

if not C.automation.auto_confirm_de then return end

----------------------------------------------------------------------------------------
--	Disenchant confirmation(tekKrush by Tekkub)
----------------------------------------------------------------------------------------

local CreateFrame = CreateFrame
local StaticPopup_OnClick = StaticPopup_OnClick

local frame = CreateFrame("Frame")
frame:RegisterEvent("CONFIRM_DISENCHANT_ROLL")
frame:RegisterEvent("CONFIRM_LOOT_ROLL")
frame:RegisterEvent("LOOT_BIND_CONFIRM")
frame:SetScript("OnEvent", function()
    for i = 1, STATICPOPUP_NUMDIALOGS do
        local f = _G["StaticPopup" .. i]
        if (f.which == "CONFIRM_LOOT_ROLL" or f.which == "LOOT_BIND") and f:IsVisible() then
            StaticPopup_OnClick(f, 1)
        end
    end
end)