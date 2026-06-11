local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Train All
------------------------------------------------------------------------

local module = E:Module("Misc"):Sub("TrainAll")

local cfg = C.misc

local min, select = min, select
local GetMoneyString = GetMoneyString
local ACHIEVEMENTFRAME_FILTER_ALL = ACHIEVEMENTFRAME_FILTER_ALL
local TRAIN = TRAIN
local AVAILABLE = AVAILABLE
local COSTS_LABEL = COSTS_LABEL

local function onAddonLoaded(self, _, addon)
    if addon ~= "Blizzard_TrainerUI" then return end

    local cost, num
    local button = CreateFrame("Button", "ClassTrainerTrainAllButton", ClassTrainerFrame, "UIPanelButtonTemplate")
    button:SetText(ACHIEVEMENTFRAME_FILTER_ALL .. TRAIN)
    button:SetPoint("TOPRIGHT", ClassTrainerTrainButton, "TOPLEFT", 0, 0)
    button:SetWidth(min(120, button:GetTextWidth() + 15))

    button:SetScript("OnEnter", function(btn)
        GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
        GameTooltip:SetText(AVAILABLE .. ": " .. num .. "\n" .. COSTS_LABEL .. " " .. GetMoneyString(cost))
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    button:SetScript("OnClick", function()
        for i = 1, GetNumTrainerServices() do
            if select(2, GetTrainerServiceInfo(i)) == "available" then
                BuyTrainerService(i)
            end
        end
    end)

    hooksecurefunc("ClassTrainerFrame_Update", function()
        num, cost = 0, 0
        for i = 1, GetNumTrainerServices() do
            if select(2, GetTrainerServiceInfo(i)) == "available" then
                num = num + 1
                cost = cost + GetTrainerServiceCost(i)
            end
        end
        button:SetEnabled(num > 0)
    end)

    module:UnregisterEvent("ADDON_LOADED", onAddonLoaded)
end

function module:OnInit()
    if not cfg.train_all then return end

    self:RegisterEvent("ADDON_LOADED", onAddonLoaded)
end
