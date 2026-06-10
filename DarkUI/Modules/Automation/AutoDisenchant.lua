local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Auto Disenchant Confirm
------------------------------------------------------------------------

local module = E:Module("Automation"):Sub("AutoDisenchant")

local cfg = C.automation

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg.auto_confirm_de then return end

    local function confirmPopups()
        for i = 1, STATICPOPUP_NUMDIALOGS do
            local f = _G["StaticPopup" .. i]
            if (f.which == "CONFIRM_LOOT_ROLL" or f.which == "LOOT_BIND") and f:IsVisible() then
                StaticPopup_OnClick(f, 1)
            end
        end
    end

    self:RegisterEvent("CONFIRM_DISENCHANT_ROLL", confirmPopups)
    self:RegisterEvent("CONFIRM_LOOT_ROLL", confirmPopups)
    self:RegisterEvent("LOOT_BIND_CONFIRM", confirmPopups)
end
