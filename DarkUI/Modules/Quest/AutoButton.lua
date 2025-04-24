local E, C, L = unpack(select(2, ...))

if not C.quest.enable and not C.quest.quest_auto_button then return end

----------------------------------------------------------------------------------------
--    AutoButton for used items(by Elv22) (use macro /click AutoButton)
----------------------------------------------------------------------------------------
local module = E:Module("Quest"):Sub("AutoButton")

function module:HideButton()
    self.AutoButton:SetAlpha(0)
    if not InCombatLockdown() then
        self.AutoButton:EnableMouse(false)
    else
        self.AutoButton:RegisterEvent("PLAYER_REGEN_ENABLED")
        self.AutoButton:SetScript("OnEvent", function(_, event)
            if event == "PLAYER_REGEN_ENABLED" then
                self.AutoButton:EnableMouse(false)
                self.AutoButton:UnregisterEvent("PLAYER_REGEN_ENABLED")
            end
        end)
    end
end

function module:ShowButton(item)
    self.AutoButton:SetAlpha(1)
    if not InCombatLockdown() then
        self.AutoButton:EnableMouse(true)
        if item then
            self.AutoButton:SetAttribute("item", item)
        end
    else
        self.AutoButton:RegisterEvent("PLAYER_REGEN_ENABLED")
        self.AutoButton:SetScript("OnEvent", function(_, event)
            if event == "PLAYER_REGEN_ENABLED" then
                self.AutoButton:EnableMouse(true)
                if item then
                    self.AutoButton:SetAttribute("item", item)
                end
                self.AutoButton:UnregisterEvent("PLAYER_REGEN_ENABLED")
            end
        end)
    end
end

function module:startScanningBags()
    self:HideButton()

    -- Scan bags for Item matchs
    for b = 0, NUM_BAG_SLOTS do
        for s = 1, C_Container.GetContainerNumSlots(b) do
            local itemID = C_Container.GetContainerItemID(b, s)
            itemID = tonumber(itemID)
            if C.autobutton[itemID] and not C.autobuttonIgnore[itemID] then
                local itemName = C_Item.GetItemInfo(itemID)
				local count = C_Item.GetItemCount(itemID)
				local itemIcon = C_Item.GetItemIconByID(itemID)

                -- Set our texture to the item found in bags
                self.AutoButton.t:SetTexture(itemIcon)

                -- Get the count if there is one
                if count and count > 1 then
                    self.AutoButton.c:SetText(count)
                else
                    self.AutoButton.c:SetText("")
                end

                self.AutoButton:SetScript("OnUpdate", function()
                    local cd_start, cd_finish, cd_enable = C_Container.GetContainerItemCooldown(b, s)
                    CooldownFrame_Set(self.AutoButton.cd, cd_start, cd_finish, cd_enable)
                end)

                self.AutoButton:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                    GameTooltip:SetHyperlink(format("item:%s", itemID))
                    GameTooltip:Show()
                end)

                self.AutoButton:SetScript("OnLeave", GameTooltip_Hide)
                self.AutoButton.id = itemID

                self:ShowButton(itemName)
            end
        end
    end
end

function module:OnLogin()
    -- Create anchor
    local AutoButtonAnchor = CreateFrame("Frame", "DarkUI_AutoButtonAnchor", UIParent)
    AutoButtonAnchor:SetPoint(unpack(C.quest.auto_button_pos))
    AutoButtonAnchor:SetSize(40, 40)

    -- Create button
    local AutoButton = CreateFrame("Button", "DarkUI_AutoButton", UIParent, "SecureActionButtonTemplate")
    AutoButton:SetSize(40, 40)
    AutoButton:SetPoint("CENTER", AutoButtonAnchor, "CENTER", 0, 0)
    AutoButton:RegisterForClicks("AnyUp", "AnyDown")
    AutoButton:SetAttribute("type1", "item")
    AutoButton:SetAttribute("type2", "item")
    AutoButton:SetAttribute("type3", "macro")

    E:StyleButton(AutoButton)

    -- Texture for our button
    AutoButton.t = AutoButton:CreateTexture(nil, "BORDER")
    AutoButton.t:SetPoint("TOPLEFT", 2, -2)
    AutoButton.t:SetPoint("BOTTOMRIGHT", -2, 2)
    AutoButton.t:SetTexCoord(unpack(C.media.texCoord))

    -- Count text for our button
    AutoButton.c = AutoButton:CreateFontString(nil, "OVERLAY")
    AutoButton.c:SetFont(STANDARD_TEXT_FONT, 14, "THINOUTLINE")
    AutoButton.c:SetShadowOffset(1, -1)
    AutoButton.c:SetPoint("BOTTOMRIGHT", 1, -2)

    -- Cooldown
    AutoButton.cd = CreateFrame("Cooldown", nil, AutoButton, "CooldownFrameTemplate")
    AutoButton.cd:SetAllPoints(AutoButton.t)
    AutoButton.cd:SetFrameLevel(1)

    self.AutoButton = AutoButton
    self:HideButton()

    -- Add all items from quest to our table
    local function UpdateSingle(_, quest)
        local questLogIndex = quest:GetQuestLogIndex()
        local link = GetQuestLogSpecialItemInfo(questLogIndex)
        if link then
            local itemID = link:match("item:(%d+)")
            itemID = tonumber(itemID) or 0
            if not C.autobutton[itemID] then
                C.autobutton[itemID] = true
                module:startScanningBags()
            end
            if quest:IsComplete() then
                C.autobutton[itemID] = false
                module:startScanningBags()
            end
        end
    end

    hooksecurefunc(QuestObjectiveTracker, "UpdateSingle", UpdateSingle)
    hooksecurefunc(CampaignQuestObjectiveTracker, "UpdateSingle", UpdateSingle)

    self:RegisterEvent("BAG_UPDATE UNIT_INVENTORY_CHANGED", function()
        module:startScanningBags()
    end)
end
