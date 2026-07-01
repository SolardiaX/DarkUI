local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Quest Choice Frame
-- Ported from ElvUI QuestChoice.lua (2026-07)
------------------------------------------------------------------------

local _G = _G

function S:QuestChoice()
    if not C.general.skins then return end

    local QuestChoiceFrame = _G.QuestChoiceFrame

    for i = 1, 4 do
        local option = QuestChoiceFrame["Option" .. i]
        if option then
            local rewards = option.Rewards
            local item = rewards.Item
            local icon = item.Icon

            if item.IconBorder then item.IconBorder:Kill() end
            S:ReskinIcon(icon)
            icon:SetDrawLayer("ARTWORK")

            local currencies = rewards.Currencies
            for j = 1, 3 do
                local cu = currencies["Currency" .. j]
                if cu then S:ReskinIcon(cu.Icon) end
            end
        end
    end

    S:CreateBackground(QuestChoiceFrame)
    S:ReskinButton(_G.QuestChoiceFrameOption1.OptionButtonsContainer.OptionButton1)
    S:ReskinButton(_G.QuestChoiceFrameOption2.OptionButtonsContainer.OptionButton1)
    S:ReskinButton(_G.QuestChoiceFrameOption3.OptionButtonsContainer.OptionButton1)
    S:ReskinButton(_G.QuestChoiceFrameOption4.OptionButtonsContainer.OptionButton1)

    S:ReskinClose(QuestChoiceFrame.CloseButton)
    QuestChoiceFrame.CloseButton:SetFrameLevel(10)
end

S:AddCallbackForAddon("Blizzard_QuestChoice", "QuestChoice")
