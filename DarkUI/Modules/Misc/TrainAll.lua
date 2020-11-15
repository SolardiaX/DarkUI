local E, C, L = select(2, ...):unpack()

if not C.misc.train_all then return end

----------------------------------------------------------------------------------------
-- Learn all available skills(TrainAll by SDPhantom)
----------------------------------------------------------------------------------------

local CreateFrame = CreateFrame
local GetMoneyString = GetMoneyString
local min, select = min, select
local hooksecurefunc = hooksecurefunc
local ACHIEVEMENTFRAME_FILTER_ALL, TRAIN = ACHIEVEMENTFRAME_FILTER_ALL, TRAIN
local AVAILABLE = AVAILABLE
local COSTS_LABEL = COSTS_LABEL
local GameTooltip = GameTooltip

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, _, addon)
    if addon == "Blizzard_TrainerUI" then

        local cost, num
        local button = CreateFrame("Button", "ClassTrainerTrainAllButton", ClassTrainerFrame, "UIPanelButtonTemplate")
        button:SetText(ACHIEVEMENTFRAME_FILTER_ALL .. TRAIN)
        button:SetPoint("TOPRIGHT", ClassTrainerTrainButton, "TOPLEFT", 0, 0)

        button:SetWidth(min(120, button:GetTextWidth() + 15))
        button:SetScript("OnEnter", function()
            GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
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
    end
end)