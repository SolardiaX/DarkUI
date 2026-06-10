local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Dark Styles (simplified from DarkMode by D4KiR)
------------------------------------------------------------------------

local module = E:Module("Blizzard"):Sub("Styles")

local cfg = C.blizzard

------------------------------------------------------------------------
-- Color Config
------------------------------------------------------------------------

local DARK_COLOR = { 0.36, 0.36, 0.36, 1 }

------------------------------------------------------------------------
-- Core Engine
------------------------------------------------------------------------

local processedTextures = {}

local IGNORE_FRAMES = {
    StoreFrame = true,
    CinematicFrame = true,
    MovieFrame = true,
}

local IGNORE_TEXTURES = {}

local function isValidTexture(obj)
    if not obj then return false end
    if obj.GetTexture and obj:GetTexture() ~= nil then return true end
    if obj.GetTextureFilePath and obj:GetTextureFilePath() ~= nil then return true end
    return type(obj) == "userdata"
end

local function darkenTexture(texture)
    if not isValidTexture(texture) then return end
    if texture:GetAlpha() == 0 then return end

    local id = texture.GetTexture and texture:GetTexture()
    if id and IGNORE_TEXTURES[id] then return end

    local r, g, b, a = unpack(DARK_COLOR)
    if texture.SetVertexColor then
        texture:SetVertexColor(r, g, b, a)

        if not texture.__darkStyled then
            texture.__darkStyled = true
            hooksecurefunc(texture, "SetVertexColor", function(self)
                if self.__darkLock then return end
                self.__darkLock = true
                self:SetVertexColor(r, g, b, a)
                self.__darkLock = false
            end)
        end
    end
end

local function darkenFrame(frame, recursive)
    if not frame then return end
    if frame.IsForbidden and frame:IsForbidden() then return end
    local name = frame.GetName and frame:GetName()
    if name and IGNORE_FRAMES[name] then return end

    if frame.GetRegions then
        for i = 1, frame:GetNumRegions() do
            local region = select(i, frame:GetRegions())
            if region and region.IsObjectType and region:IsObjectType("Texture") then
                darkenTexture(region)
            end
        end
    end

    if recursive and frame.GetChildren then
        for i = 1, select("#", frame:GetChildren()) do
            local child = select(i, frame:GetChildren())
            if child then
                darkenFrame(child, false)
            end
        end
    end
end

------------------------------------------------------------------------
-- Frame Tables
------------------------------------------------------------------------

local BASE_FRAMES = {
    "GameMenuFrame",
    "StaticPopup1",
    "StaticPopup2",
    "StaticPopup3",
    "StaticPopup4",
    "ChatConfigFrame",
    "ColorPickerFrame",
    "OpacityFrame",
    "TicketStatusFrameButton",
    "LFDReadyCheckPopup",
    "LFDRoleCheckPopup",
    "PVPRoleCheckPopup",
    "PVPReadyDialog",
    "LFGDungeonReadyStatus",
    "LFGInvitePopup",
    "LFGListApplicationDialog",
    "LFGListInviteDialog",
    "GuildInviteFrame",
    "RatingMenuFrame",
    "ReportCheatingDialog",
    "ReportFrame",
    "AddFriendFrame",
    "VoiceChatChannelActivatedNotification",
    "VoiceChatPromptActivateChannel",
    "AddonList",
    "StackSplitFrame",
    "HelpFrame",
    "ModelPreviewFrame",
}

local PANEL_FRAMES = {
    "CharacterFrame",
    "FriendsFrame",
    "PVEFrame",
    "MailFrame",
    "OpenMailFrame",
    "MerchantFrame",
    "GossipFrame",
    "QuestFrame",
    "QuestLogPopupDetailFrame",
    "BankFrame",
    "DressUpFrame",
    "TabardFrame",
    "GuildRegistrarFrame",
    "PetitionFrame",
    "ItemTextFrame",
    "TradeFrame",
    "ChannelFrame",
    "LootFrame",
}

local ADDON_FRAMES = {
    ["Blizzard_AchievementUI"] = { "AchievementFrame" },
    ["Blizzard_AuctionHouseUI"] = { "AuctionHouseFrame" },
    ["Blizzard_Collections"] = { "CollectionsJournal" },
    ["Blizzard_Communities"] = { "CommunitiesFrame" },
    ["Blizzard_EncounterJournal"] = { "EncounterJournal" },
    ["Blizzard_GuildBankUI"] = { "GuildBankFrame" },
    ["Blizzard_InspectUI"] = { "InspectFrame" },
    ["Blizzard_ItemSocketingUI"] = { "ItemSocketingFrame" },
    ["Blizzard_ItemUpgradeUI"] = { "ItemUpgradeFrame" },
    ["Blizzard_MacroUI"] = { "MacroFrame" },
    ["Blizzard_TalentUI"] = { "PlayerTalentFrame" },
    ["Blizzard_Professions"] = { "ProfessionsFrame" },
    ["Blizzard_WorldMap"] = { "WorldMapFrame" },
}

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg.style then return end

    local function processBaseFrames()
        for _, name in ipairs(BASE_FRAMES) do
            local frame = _G[name]
            if frame then
                darkenFrame(frame, true)
            end
        end
    end

    local function processPanelFrames()
        for _, name in ipairs(PANEL_FRAMES) do
            local frame = _G[name]
            if frame and not frame.__darkProcessed then
                darkenFrame(frame, true)
                frame.__darkProcessed = true
            end
        end
    end

    processBaseFrames()
    processPanelFrames()

    self:RegisterEvent("ADDON_LOADED", function(_, _, addon)
        local frames = ADDON_FRAMES[addon]
        if frames then
            C_Timer.After(0.1, function()
                for _, name in ipairs(frames) do
                    local frame = _G[name]
                    if frame and not frame.__darkProcessed then
                        darkenFrame(frame, true)
                        frame.__darkProcessed = true
                    end
                end
            end)
        end
    end)

    -- Re-process on certain events where Blizzard resets colors
    self:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        C_Timer.After(0.5, processBaseFrames)
    end)

    -- Dynamic content: GossipFrame / QuestFrame
    local function darkenScrollContent(frame)
        if not frame then return end
        C_Timer.After(0.2, function()
            darkenFrame(frame, true)
        end)
    end

    if GossipFrame then
        GossipFrame:HookScript("OnShow", function()
            darkenScrollContent(GossipFrame)
        end)
        if GossipFrame.GreetingPanel and GossipFrame.GreetingPanel.ScrollBox then
            hooksecurefunc(GossipFrame.GreetingPanel.ScrollBox, "FullUpdate", function()
                darkenScrollContent(GossipFrame.GreetingPanel)
            end)
        end
    end

    if QuestFrame then
        QuestFrame:HookScript("OnShow", function()
            darkenScrollContent(QuestFrame)
        end)
    end

    -- Vigor bar decorations
    local function darkenVigor()
        if not UIWidgetPowerBarContainerFrame then return end
        for i = 1, select("#", UIWidgetPowerBarContainerFrame:GetChildren()) do
            local child = select(i, UIWidgetPowerBarContainerFrame:GetChildren())
            if child then
                if child.DecorLeft and child.DecorLeft.GetAtlas then
                    local atlas = child.DecorLeft:GetAtlas()
                    if atlas and atlas:find("vigor", 1, true) then
                        darkenTexture(child.DecorLeft)
                        darkenTexture(child.DecorRight)
                    end
                end
                for j = 1, select("#", child:GetChildren()) do
                    local grandchild = select(j, child:GetChildren())
                    if grandchild and grandchild.Frame and grandchild.Frame.GetAtlas then
                        local atlas = grandchild.Frame:GetAtlas()
                        if atlas and atlas:find("vigor", 1, true) then
                            darkenTexture(grandchild.Frame)
                        end
                    end
                end
            end
        end
    end

    self:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED", function()
        C_Timer.After(0.3, darkenVigor)
    end)
    C_Timer.After(1.5, darkenVigor)
end
