local E, C, L = unpack(select(2, ...))

if not C.quest.enable and not C.quest.quest_auto_button then return end

----------------------------------------------------------------------------------------
--    AutoButton for used items(by Elv22) (use macro /click AutoButton)
----------------------------------------------------------------------------------------
local module = E:Module("Quest"):Sub("AutoButton")

local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local GetQuestLogSpecialItemInfo = GetQuestLogSpecialItemInfo
local C_Container = C_Container
local GetItemInfo, GetItemCount, GetItemIcon = GetItemInfo, GetItemCount, GetItemIcon
local CooldownFrame_Set = CooldownFrame_Set
local GameTooltip, GameTooltip_Hide = GameTooltip, GameTooltip_Hide
local tonumber = tonumber
local unpack = unpack
local strsplit = strsplit
local hooksecurefunc = hooksecurefunc
local NUM_BAG_SLOTS = NUM_BAG_SLOTS

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
            if C.autobutton[itemID] then
                local itemName = GetItemInfo(itemID)
                local count = GetItemCount(itemID)
                local itemIcon = GetItemIcon(itemID)

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

                self:ShowButton(itemName)
            end
        end
    end
end

function module:OnLogin()
    -- Create anchor
    local AutoButtonAnchor = CreateFrame("Frame", "AutoButtonAnchor", UIParent)
    AutoButtonAnchor:SetPoint(unpack(C.quest.auto_button_pos))
    AutoButtonAnchor:SetSize(40, 40)

    -- Create button
    local AutoButton = CreateFrame("Button", "AutoButton", UIParent, "SecureActionButtonTemplate")
    AutoButton:SetSize(40, 40)
    AutoButton:SetPoint("CENTER", AutoButtonAnchor, "CENTER", 0, 0)
    AutoButton:RegisterForClicks("AnyUp", "AnyDown")
    AutoButton:SetAttribute("type", "item")

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
    hooksecurefunc(QuestObjectiveTracker, "UpdateSingle", function(_, quest)
        local questLogIndex = quest:GetQuestLogIndex()
        local link = GetQuestLogSpecialItemInfo(questLogIndex)
        if link then
            local _, itemID = strsplit(":", link)
            itemID = tonumber(itemID)
            C.autobutton[itemID] = true
            module:startScanningBags()
        end
    end)

    self:RegisterEvent("BAG_UPDATE UNIT_INVENTORY_CHANGED", function()
        module:startScanningBags()
    end)
end
