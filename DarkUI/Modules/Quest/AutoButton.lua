local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Auto Button
------------------------------------------------------------------------

local module = E:Module("Quest"):Sub("AutoButton")

local cfg = C.quest
local format = string.format
local gsub = string.gsub

local BUTTON_POS = { "CENTER", "UIParent", "CENTER", 0, -260 }

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg or not cfg.enable then return end
    if not cfg.auto_button then return end

    local anchor = CreateFrame("Frame", "DarkUI_AutoButtonAnchor", UIParent)
    anchor:SetPoint(unpack(BUTTON_POS))
    anchor:SetSize(40, 40)

    local button = CreateFrame("Button", "DarkUI_AutoButton", UIParent, "SecureActionButtonTemplate")
    button:SetSize(40, 40)
    button:SetPoint("CENTER", anchor, "CENTER", 0, 0)
    button:SetTemplate("Default")
    button:RegisterForClicks("AnyUp", "AnyDown")
    button:SetAttribute("type1", "item")
    button:SetAttribute("type2", "item")

    E:StyleIconButton(button)

    button.t = button:CreateTexture(nil, "BORDER")
    button.t:SetPoint("TOPLEFT", 2, -2)
    button.t:SetPoint("BOTTOMRIGHT", -2, 2)
    button.t:SetTexCoord(unpack(C.media.texCoord))

    button.c = button:CreateFontString(nil, "OVERLAY")
    button.c:SetFont(STANDARD_TEXT_FONT, 14, "THINOUTLINE")
    button.c:SetShadowOffset(1, -1)
    button.c:SetPoint("BOTTOMRIGHT", 1, -2)

    button.k = button:CreateFontString(nil, "OVERLAY")
    button.k:SetFont(STANDARD_TEXT_FONT, 11, "THINOUTLINE")
    button.k:SetShadowOffset(1, -1)
    button.k:SetTextColor(0.7, 0.7, 0.7)
    button.k:SetPoint("TOPRIGHT", 0, -2)
    button.k:SetJustifyH("RIGHT")
    button.k:SetWidth(button:GetWidth() - 1)
    button.k:SetWordWrap(false)

    button.cd = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    button.cd:SetAllPoints(button.t)
    button.cd:SetFrameLevel(1)

    self.button = button

    -- Single named handler: Event:Register dedups by (handler, owner), so
    -- repeated in-combat show/hide calls never stack registrations
    local pendingMouse, pendingItem

    local function onRegenEnabled()
        self:UnregisterEvent("PLAYER_REGEN_ENABLED", onRegenEnabled)
        button:EnableMouse(pendingMouse)
        if pendingMouse and pendingItem then button:SetAttribute("item", pendingItem) end
        pendingItem = nil
    end

    local function hideButton()
        button:SetAlpha(0)
        if not InCombatLockdown() then
            button:EnableMouse(false)
        else
            pendingMouse = false
            pendingItem = nil
            self:RegisterEvent("PLAYER_REGEN_ENABLED", onRegenEnabled)
        end
    end

    local function showButton(item)
        button:SetAlpha(1)
        if not InCombatLockdown() then
            button:EnableMouse(true)
            if item then button:SetAttribute("item", item) end
        else
            pendingMouse = true
            pendingItem = item
            self:RegisterEvent("PLAYER_REGEN_ENABLED", onRegenEnabled)
        end
    end

    local function scanBags()
        hideButton()

        for b = 0, NUM_BAG_SLOTS do
            for s = 1, C_Container.GetContainerNumSlots(b) do
                local itemID = C_Container.GetContainerItemID(b, s)
                itemID = tonumber(itemID)
                if C.autobutton[itemID] and not C.autobuttonIgnore[itemID] then
                    local itemName = C_Item.GetItemInfo(itemID)
                    local count = C_Item.GetItemCount(itemID)
                    local itemIcon = C_Item.GetItemIconByID(itemID)

                    button.t:SetTexture(itemIcon)

                    if count and count > 1 then
                        button.c:SetText(count)
                    else
                        button.c:SetText("")
                    end

                    button:SetScript("OnUpdate", function()
                        local cd_start, cd_finish, cd_enable = C_Container.GetContainerItemCooldown(b, s)
                        CooldownFrame_Set(button.cd, cd_start, cd_finish, cd_enable)
                    end)

                    button:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                        GameTooltip:SetHyperlink(format("item:%s", itemID))
                        GameTooltip:Show()
                    end)

                    button:SetScript("OnLeave", GameTooltip_Hide)
                    button.id = itemID

                    showButton(itemName)
                    return
                end
            end
        end
    end

    hideButton()

    -- Track quest items from objective tracker
    local function updateSingle(_, quest)
        local questLogIndex = quest:GetQuestLogIndex()
        local link = GetQuestLogSpecialItemInfo(questLogIndex)
        if link then
            local itemID = link:match("item:(%d+)")
            itemID = tonumber(itemID) or 0
            if not C.autobutton[itemID] then
                C.autobutton[itemID] = true
                scanBags()
            end
            if quest:IsComplete() then
                C.autobutton[itemID] = false
                scanBags()
            end
        end
    end

    hooksecurefunc(QuestObjectiveTracker, "UpdateSingle", updateSingle)
    hooksecurefunc(CampaignQuestObjectiveTracker, "UpdateSingle", updateSingle)

    self:RegisterEvent("BAG_UPDATE", scanBags)
    self:RegisterEvent("UNIT_INVENTORY_CHANGED", scanBags)

    -- Keybinding display
    local function updateBinding()
        local bind = GetBindingKey("QUEST_BUTTON")
        if bind then
            SetOverrideBinding(button, false, bind, "CLICK DarkUI_AutoButton:LeftButton")
            bind = gsub(bind, "(ALT%-)", "A")
            bind = gsub(bind, "(CTRL%-)", "C")
            bind = gsub(bind, "(SHIFT%-)", "S")
            bind = gsub(bind, "(Mouse Button )", "M")
            bind = gsub(bind, KEY_BUTTON3, "M3")
            bind = gsub(bind, KEY_PAGEUP, "PU")
            bind = gsub(bind, KEY_PAGEDOWN, "PD")
            bind = gsub(bind, KEY_SPACE, "SpB")
            bind = gsub(bind, KEY_MOUSEWHEELUP, "MWU")
            bind = gsub(bind, KEY_MOUSEWHEELDOWN, "MWD")
        end
        button.k:SetText(bind or "")
    end

    self:RegisterEvent("UPDATE_BINDINGS", updateBinding)
    updateBinding()
end
