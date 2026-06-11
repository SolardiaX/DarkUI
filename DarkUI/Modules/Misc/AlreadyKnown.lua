local ns = select(2, ...)
local E, C, L = ns:unpack()

------------------------------------------------------------------------
-- Already Known
------------------------------------------------------------------------

local module = E:Module("Misc"):Sub("AlreadyKnown")

local cfg = C.misc

local color = { r = 0.1, g = 1, b = 0.1 }
local knowns = {}
local recipe = Enum.ItemClass.Recipe
local pet = Enum.ItemMiscellaneousSubclass.CompanionPet
local mount = Enum.ItemMiscellaneousSubclass.Mount
local knowablesClass = { [recipe] = true }
local knowablesSubclass = { [pet] = true, [mount] = true }

local pattern = ITEM_PET_KNOWN:gsub("%(", "%%("):gsub("%)", "%%)")

local tooltip = CreateFrame("GameTooltip", "DarkUI_AKScanTooltip", nil, "GameTooltipTemplate")
tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

local function scanTooltip(line, numLines)
    if line > numLines then return end
    local text = _G["DarkUI_AKScanTooltipTextLeft" .. line]:GetText()
    if not text or text == "" then return scanTooltip(line + 1, numLines) end
    if text == ITEM_SPELL_KNOWN or text:match(pattern) then return true end
    return scanTooltip(line + 1, numLines)
end

local function isKnown(itemLink)
    if not itemLink then return end

    local speciesID = itemLink:match("battlepet:(%d+):")
    if speciesID then return C_PetJournal.GetNumCollectedInfo(tonumber(speciesID)) > 0 end

    local itemID = itemLink:match("item:(%d+):")
    if not itemID then return end
    itemID = tonumber(itemID)
    if knowns[itemID] then return true end

    if PlayerHasToy(itemID) then
        knowns[itemID] = true
        return true
    end

    if C_Heirloom.PlayerHasHeirloom(itemID) then
        knowns[itemID] = true
        return true
    end

    local _, _, _, _, _, _, _, _, _, _, _, classID, subClassID = C_Item.GetItemInfo(itemID)
    if not (knowablesClass[classID] or knowablesSubclass[subClassID]) then return end

    tooltip:ClearLines()
    tooltip:SetHyperlink(itemLink)
    if not scanTooltip(2, tooltip:NumLines()) then return end

    if subClassID ~= pet then knowns[itemID] = true end
    return true
end

------------------------------------------------------------------------
-- Hooks
------------------------------------------------------------------------

local function hookLootFrame(self)
    local slotIndex = self:GetSlotIndex()
    local texture, _, _, _, _, locked = GetLootSlotInfo(slotIndex)
    if texture and not locked and isKnown(GetLootSlotLink(slotIndex)) then
        SetItemButtonTextureVertexColor(self.Item, color.r, color.g, color.b)
    end
end

local function hookMerchant()
    local numItems = GetMerchantNumItems()
    for i = 1, MERCHANT_ITEMS_PER_PAGE do
        local index = (MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE + i
        if index > numItems then return end

        local button = _G["MerchantItem" .. i .. "ItemButton"]
        if button and button:IsShown() then
            local info = C_MerchantFrame.GetItemInfo(index)
            if info and info.isUsable and isKnown(GetMerchantItemLink(index)) then
                SetItemButtonTextureVertexColor(button, color.r, color.g, color.b)
            end
        end
    end
end

local function hookBuyback()
    local numItems = GetNumBuybackItems()
    for i = 1, BUYBACK_ITEMS_PER_PAGE do
        if i > numItems then return end
        local button = _G["MerchantItem" .. i .. "ItemButton"]
        if button and button:IsShown() then
            local _, _, _, _, _, isUsable = GetBuybackItemInfo(i)
            if isUsable and isKnown(GetBuybackItemLink(i)) then
                SetItemButtonTextureVertexColor(button, color.r, color.g, color.b)
            end
        end
    end
end

local function hookQuestRewards()
    local numQuestRewards, numQuestChoices
    if QuestInfoFrame.questLog then
        numQuestRewards = GetNumQuestLogRewards()
        numQuestChoices = GetNumQuestLogChoices(C_QuestLog.GetSelectedQuest(), true)
    else
        numQuestRewards = GetNumQuestRewards()
        numQuestChoices = GetNumQuestChoices()
    end

    if numQuestRewards + numQuestChoices == 0 then return end

    local rewardsCount = 0
    if numQuestChoices > 0 then
        for i = 1, numQuestChoices do
            local button = _G["QuestInfoItem" .. (i + rewardsCount)]
            if button and button:IsShown() then
                local isUsable
                if QuestInfoFrame.questLog then
                    _, _, _, _, isUsable = GetQuestLogChoiceInfo(i)
                else
                    _, _, _, _, isUsable = GetQuestItemInfo("choice", i)
                end
                local link = QuestInfoFrame.questLog and GetQuestLogItemLink("choice", i) or GetQuestItemLink("choice", i)
                if isUsable and isKnown(link) then
                    SetItemButtonTextureVertexColor(button, color.r, color.g, color.b)
                end
            end
            rewardsCount = rewardsCount + 1
        end
    end

    if numQuestRewards > 0 then
        for i = 1, numQuestRewards do
            local button = _G["QuestInfoItem" .. (i + rewardsCount)]
            if button and button:IsShown() then
                local isUsable
                if QuestInfoFrame.questLog then
                    _, _, _, _, isUsable = GetQuestLogRewardInfo(i)
                else
                    _, _, _, _, isUsable = GetQuestItemInfo("reward", i)
                end
                local link = QuestInfoFrame.questLog and GetQuestLogItemLink("reward", i) or GetQuestItemLink("reward", i)
                if isUsable and isKnown(link) then
                    SetItemButtonTextureVertexColor(button, color.r, color.g, color.b)
                end
            end
            rewardsCount = rewardsCount + 1
        end
    end
end

local function hookAuctionHouse(self)
    local children = { self.ScrollTarget:GetChildren() }
    for i = 1, #children do
        local button = children[i]
        if button and button.rowData and button.rowData.itemKey and button.rowData.itemKey.itemID then
            local itemLink
            if button.rowData.itemKey.itemID == 82800 then
                itemLink = format("|Hbattlepet:%d::::::|h[Dummy]|h", button.rowData.itemKey.battlePetSpeciesID)
            else
                itemLink = format("item:%d:", button.rowData.itemKey.itemID)
            end

            if itemLink and isKnown(itemLink) then
                if button.SelectedHighlight then
                    button.SelectedHighlight:Show()
                    button.SelectedHighlight:SetVertexColor(color.r, color.g, color.b)
                    button.SelectedHighlight:SetAlpha(0.2)
                end
                if button.cells and button.cells[2] and button.cells[2].Icon then
                    button.cells[2].Icon:SetVertexColor(color.r, color.g, color.b)
                end
            else
                if button.SelectedHighlight then
                    button.SelectedHighlight:SetVertexColor(1, 1, 1)
                end
                if button.cells and button.cells[2] and button.cells[2].Icon then
                    button.cells[2].Icon:SetVertexColor(1, 1, 1)
                end
            end
        end
    end
end

local function hookBlackMarketHotItem(self)
    local texture = self.HotDeal and self.HotDeal.Item and self.HotDeal.Item.IconTexture
    if not (texture and texture:IsShown()) then return end
    local name, _, _, _, usable, _, _, _, _, _, _, _, _, _, link = C_BlackMarket.GetHotItem()
    if name and usable and isKnown(link) then
        texture:SetVertexColor(color.r, color.g, color.b)
    end
end

local function hookBlackMarketItem(self, elementData)
    local name, _, _, _, usable, _, _, _, _, _, _, _, _, _, link = C_BlackMarket.GetItemInfoByIndex(elementData.index)
    if name and usable and isKnown(link) then
        self.Item.IconTexture:SetVertexColor(color.r, color.g, color.b)
    end
end

local function hookGuildBank()
    if not GuildBankFrame or GuildBankFrame.mode ~= "bank" then return end
    local tab = GetCurrentGuildBankTab()
    for i = 1, 98 do
        local index = math.fmod(i, 14)
        if index == 0 then index = 14 end
        local column = math.ceil((i - 0.5) / 14)
        local button = GuildBankFrame.Columns and GuildBankFrame.Columns[column] and GuildBankFrame.Columns[column].Buttons and GuildBankFrame.Columns[column].Buttons[index]
        if button and button:IsShown() then
            local texture, _, locked = GetGuildBankItemInfo(tab, i)
            if texture and not locked then
                if isKnown(GetGuildBankItemLink(tab, i)) then
                    SetItemButtonTextureVertexColor(button, color.r, color.g, color.b)
                else
                    SetItemButtonTextureVertexColor(button, 1, 1, 1)
                end
            end
        end
    end
end

------------------------------------------------------------------------

function module:OnInit()
    if not cfg.already_known then return end

    hooksecurefunc(LootFrameElementMixin, "Init", hookLootFrame)
    hooksecurefunc("MerchantFrame_UpdateMerchantInfo", hookMerchant)
    hooksecurefunc("MerchantFrame_UpdateBuybackInfo", hookBuyback)

    if C_AddOns.IsAddOnLoaded("Pawn") then
        hooksecurefunc("PawnUI_OnQuestInfo_ShowRewards", hookQuestRewards)
    else
        hooksecurefunc("QuestInfo_ShowRewards", hookQuestRewards)
    end

    -- LoD addons
    local auctionHooked, blackMarketHooked, guildBankHooked

    if C_AddOns.IsAddOnLoaded("Blizzard_AuctionHouseUI") then
        auctionHooked = true
        hooksecurefunc(AuctionHouseFrame.BrowseResultsFrame.ItemList.ScrollBox, "Update", hookAuctionHouse)
    end
    if C_AddOns.IsAddOnLoaded("Blizzard_BlackMarketUI") then
        blackMarketHooked = true
        hooksecurefunc("BlackMarketFrame_UpdateHotItem", hookBlackMarketHotItem)
        hooksecurefunc(BlackMarketItemMixin, "Init", hookBlackMarketItem)
    end
    if C_AddOns.IsAddOnLoaded("Blizzard_GuildBankUI") then
        guildBankHooked = true
        hooksecurefunc(GuildBankFrame, "Update", hookGuildBank)
    end

    if not (auctionHooked and blackMarketHooked and guildBankHooked) then
        self:RegisterEvent("ADDON_LOADED", function(_, _, addon)
            if addon == "Blizzard_AuctionHouseUI" and not auctionHooked then
                auctionHooked = true
                hooksecurefunc(AuctionHouseFrame.BrowseResultsFrame.ItemList.ScrollBox, "Update", hookAuctionHouse)
            elseif addon == "Blizzard_BlackMarketUI" and not blackMarketHooked then
                blackMarketHooked = true
                hooksecurefunc("BlackMarketFrame_UpdateHotItem", hookBlackMarketHotItem)
                hooksecurefunc(BlackMarketItemMixin, "Init", hookBlackMarketItem)
            elseif addon == "Blizzard_GuildBankUI" and not guildBankHooked then
                guildBankHooked = true
                hooksecurefunc(GuildBankFrame, "Update", hookGuildBank)
            end
        end)
    end
end
