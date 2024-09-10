local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
--    modified from DefaultUI_Dark
----------------------------------------------------------------------------------------
local module = E:Module("Blizzard"):Sub("Styles")

local GetWoWVersion = ((select(4, GetBuildInfo())))

local function ColorizationFrameFunction(...)
    local v = ...
    if v then v:SetVertexColor(.4, .4, .4) end
end

module:RegisterEvent("ADDON_LOADED", function(self, event, addon)
    if (addon == E.addonName) then
        
        -- Default Frames --

        for i, v in pairs({    
            PlayerFrameTexture,
            TargetFrameTextureFrameTexture,
            PetFrameTexture,
            PartyMemberFrame1Texture,
            PartyMemberFrame2Texture,
            PartyMemberFrame3Texture,
            PartyMemberFrame4Texture,
            PartyMemberFrame1PetFrameTexture,
            PartyMemberFrame2PetFrameTexture,
            PartyMemberFrame3PetFrameTexture,
            PartyMemberFrame4PetFrameTexture,
            FocusFrameTextureFrameTexture,
            TargetFrameToTTextureFrameTexture,
            FocusFrameToTTextureFrameTexture,
            BonusActionBarFrameTexture0,
            BonusActionBarFrameTexture1,
            BonusActionBarFrameTexture2,
            BonusActionBarFrameTexture3,
            BonusActionBarFrameTexture4,
            MainMenuBarTexture0,
            MainMenuBarTexture1,
            MainMenuBarTexture2,
            MainMenuBarTexture3,
            MainMenuMaxLevelBar0,
            MainMenuMaxLevelBar1,
            MainMenuMaxLevelBar2,
            MainMenuMaxLevelBar3,
            MainMenuBarTextureExtender,
            MinimapBorder,
            MinimapBorderTop,
            CastingBarFrameBorder,
            FocusFrameSpellBarBorder,
            TargetFrameSpellBarBorder,
            MiniMapTrackingButtonBorder,
            MiniMapLFGFrameBorder,
            MiniMapBattlefieldBorder,
            MiniMapMailBorder, 
        }) do
            if (GetWoWVersion <= 90500) then
                MiniMapWorldMapButton:SetAlpha(0.3)
            end
            ColorizationFrameFunction(v)
        end
    
        -- Dark Unit Frames Exception --

        for i, v in pairs({
            PlayerFrameTexture,
            TargetFrameTextureFrameTexture,
            PetFrameTexture,
            PartyMemberFrame1Texture,
            PartyMemberFrame2Texture,
            PartyMemberFrame3Texture,
            PartyMemberFrame4Texture,
            PartyMemberFrame1PetFrameTexture,
            PartyMemberFrame2PetFrameTexture,
            PartyMemberFrame3PetFrameTexture,
            PartyMemberFrame4PetFrameTexture,
            FocusFrameTextureFrameTexture,
            TargetFrameToTTextureFrameTexture,
            FocusFrameToTTextureFrameTexture,
            MinimapBorder,
            MiniMapTrackingButtonBorder,
            MiniMapLFGFrameBorder,
            MiniMapBattlefieldBorder,
            MiniMapMailBorder,
            MiniMapBorderTop, 
        }) do
            ColorizationFrameFunction(v)
        end
        
        -- Alpha Extra Frames --

        for i, v in pairs({
            PaperDollInnerBorderBottom,
            PaperDollInnerBorderBottom2,
            PaperDollInnerBorderLeft,
            PaperDollInnerBorderRight,
            PaperDollInnerBorderTop,
            PaperDollInnerBorderBottomLeft,
            PaperDollInnerBorderBottomRight,
        }) do
            v:SetAlpha(0)
        end
        if (GetWoWVersion > 50600) then
            for i, v in pairs({
                RecruitAFriendFrame.RecruitList.ScrollFrameInset.NineSlice.BottomLeftCorner,
                RecruitAFriendFrame.RecruitList.ScrollFrameInset.NineSlice.BottomRightCorner,
                RecruitAFriendFrame.RecruitList.ScrollFrameInset.NineSlice.BottomEdge,
                RecruitAFriendFrame.RewardClaiming.Inset.NineSlice.BottomLeftCorner,
                RecruitAFriendFrame.RewardClaiming.Inset.NineSlice.BottomRightCorner,
                RecruitAFriendFrame.RewardClaiming.Inset.NineSlice.BottomEdge,
            }) do
                v:SetAlpha(0)
            end
        end

        -- New Interface --

        for i, v in pairs({ 
            Boss1TargetFrameTextureFrameTexture,
            Boss2TargetFrameTextureFrameTexture,
            Boss3TargetFrameTextureFrameTexture,
            Boss4TargetFrameTextureFrameTexture,
            MirrorTimer1Border,
            MirrorTimer2Border,
            MirrorTimer3Border, 
        }) do
            ColorizationFrameFunction(v)
        end
        if (GetWoWVersion >= 50600 and GetWoWVersion <= 90500) then
            for i, v in pairs({ 
                MainMenuBarArtFrame.LeftEndCap,
                MainMenuBarArtFrame.RightEndCap,
                MainMenuBarArtFrameBackground.BackgroundSmall,
                MainMenuBarArtFrameBackground.BackgroundLarge, 
            }) do
                ColorizationFrameFunction(v)
            end
        else
            for i, v in pairs({ 
                MainMenuBarLeftEndCap,
                MainMenuBarRightEndCap,  
            }) do
                ColorizationFrameFunction(v)
            end
        end    
        ----------------------------------------------------------------------
        -- Character
        if (GetWoWVersion > 50600) then
            for i, v in pairs({    
                CharacterFrame.NineSlice.RightEdge,
                CharacterFrame.NineSlice.LeftEdge,
                CharacterFrame.NineSlice.TopEdge,
                CharacterFrame.NineSlice.BottomEdge,
                CharacterFrame.NineSlice.PortraitFrame,
                CharacterFrame.NineSlice.TopRightCorner,
                CharacterFrame.NineSlice.TopLeftCorner,
                CharacterFrame.NineSlice.BottomLeftCorner,
                CharacterFrame.NineSlice.BottomRightCorner,
                CharacterFrameInset.NineSlice.BottomEdge,
                CharacterFrameInset.NineSlice.BottomLeftCorner,
                CharacterFrameInset.NineSlice.BottomRightCorner,
                CharacterFrameInsetRight.NineSlice.BottomEdge,
                CharacterFrameInsetRight.NineSlice.BottomLeftCorner,
                CharacterFrameInsetRight.NineSlice.BottomRightCorner,
                CharacterFrameTab1Left,
                CharacterFrameTab1LeftDisabled,
                CharacterFrameTab1Middle,
                CharacterFrameTab1MiddleDisabled,
                CharacterFrameTab1Right,
                CharacterFrameTab1RightDisabled,
                CharacterFrameTab2Left,
                CharacterFrameTab2LeftDisabled,
                CharacterFrameTab2Middle,
                CharacterFrameTab2MiddleDisabled,
                CharacterFrameTab2Right,
                CharacterFrameTab2RightDisabled,
                CharacterFrameTab3Left,
                CharacterFrameTab3LeftDisabled,
                CharacterFrameTab3Middle,
                CharacterFrameTab3MiddleDisabled,
                CharacterFrameTab3Right,
                CharacterFrameTab3RightDisabled,
                CharacterFrameTab4Left,
                CharacterFrameTab4LeftDisabled,
                CharacterFrameTab4Middle,
                CharacterFrameTab4MiddleDisabled,
                CharacterFrameTab4Right,
                CharacterFrameTab4RightDisabled,
                CharacterFrameTab5Left,
                CharacterFrameTab5LeftDisabled,
                CharacterFrameTab5Middle,
                CharacterFrameTab5MiddleDisabled,
                CharacterFrameTab5Right,
                CharacterFrameTab5RightDisabled,
                TokenFramePopup.Border.TopEdge,
                TokenFramePopup.Border.RightEdge,
                TokenFramePopup.Border.BottomEdge,
                TokenFramePopup.Border.LeftEdge,
                TokenFramePopup.Border.TopRightCorner,
                TokenFramePopup.Border.TopLeftCorner,
                TokenFramePopup.Border.BottomLeftCorner,
                TokenFramePopup.Border.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            for i, v in pairs({
                CharacterFrameInset.NineSlice,
                CharacterFrameInset.NineSlice.BottomLeftCorner,
                CharacterFrameInset.NineSlice.BottomRightCorner,
                CharacterFrameInset.NineSlice.BottomEdge,
                CharacterFrameInsetRight.NineSlice.BottomLeftCorner,
                CharacterFrameInsetRight.NineSlice.BottomRightCorner,
                CharacterFrameInsetRight.NineSlice.BottomEdge, 
            }) do
                v:SetAlpha(0)
            end
            -- PvE/Pvp
            for i, v in pairs({ 
                PVEFrame.NineSlice.TopEdge,
                PVEFrame.NineSlice.TopRightCorner,
                PVEFrame.NineSlice.RightEdge,
                PVEFrame.NineSlice.LeftEdge,
                PVEFrame.NineSlice.BottomRightCorner,
                PVEFrame.NineSlice.BottomEdge,
                PVEFrame.NineSlice.BottomLeftCorner,
                PVEFrame.NineSlice.TopLeftCorner,
                PVEFrameTab1Left,
                PVEFrameTab1LeftDisabled,
                PVEFrameTab1Middle,
                PVEFrameTab1MiddleDisabled,
                PVEFrameTab1Right,
                PVEFrameTab1RightDisabled,
                PVEFrameTab2Left,
                PVEFrameTab2LeftDisabled,
                PVEFrameTab2Middle,
                PVEFrameTab2MiddleDisabled,
                PVEFrameTab2Right,
                PVEFrameTab2RightDisabled,
                PVEFrameTab3Left,
                PVEFrameTab3LeftDisabled,
                PVEFrameTab3Middle,
                PVEFrameTab3MiddleDisabled,
                PVEFrameTab3Right,
                PVEFrameTab3RightDisabled,
             }) do
                ColorizationFrameFunction(v)
            end
            for i, v in pairs({
                PVEFrameLeftInset.NineSlice.BottomLeftCorner,
                PVEFrameLeftInset.NineSlice.BottomRightCorner,
                PVEFrameLeftInset.NineSlice.BottomEdge,
                PVEFrameLeftInset.NineSlice.LeftEdge,
                LFDParentFrameInset.NineSlice.BottomLeftCorner,
                LFDParentFrameInset.NineSlice.BottomRightCorner,
                LFDParentFrameInset.NineSlice.BottomEdge,
                LFDParentFrameInset.NineSlice.LeftEdge,
                RaidFinderFrameRoleInset.NineSlice.BottomLeftCorner,
                RaidFinderFrameRoleInset.NineSlice.BottomRightCorner,
                RaidFinderFrameRoleInset.NineSlice.BottomEdge,
                RaidFinderFrameRoleInset.NineSlice.LeftEdge,
                RaidFinderFrameBottomInset.NineSlice.BottomLeftCorner,
                RaidFinderFrameBottomInset.NineSlice.BottomRightCorner,
                RaidFinderFrameBottomInset.NineSlice.BottomEdge,
                RaidFinderFrameBottomInset.NineSlice.LeftEdge,
                LFGListFrame.CategorySelection.Inset.NineSlice.BottomLeftCorner,
                LFGListFrame.CategorySelection.Inset.NineSlice.BottomRightCorner,
                LFGListFrame.CategorySelection.Inset.NineSlice.BottomEdge,
                LFGListFrame.CategorySelection.Inset.NineSlice.LeftEdge,
                LFGListFrame.SearchPanel.ResultsInset.NineSlice.BottomLeftCorner,
                LFGListFrame.SearchPanel.ResultsInset.NineSlice.BottomRightCorner,
                LFGListFrame.SearchPanel.ResultsInset.NineSlice.BottomEdge,
                LFGListFrame.SearchPanel.ResultsInset.NineSlice.Left, 
            }) do
                v:SetAlpha(0)
            end
            -- Friends
            for i, v in pairs({ 
                FriendsFrame.NineSlice.TopEdge,
                FriendsFrame.NineSlice.TopEdge,
                FriendsFrame.NineSlice.TopRightCorner,
                FriendsFrame.NineSlice.RightEdge,
                FriendsFrame.NineSlice.BottomRightCorner,
                FriendsFrame.NineSlice.BottomEdge,
                FriendsFrame.NineSlice.BottomLeftCorner,
                FriendsFrame.NineSlice.LeftEdge,
                FriendsFrame.NineSlice.TopLeftCorner,
                FriendsFrameInset.NineSlice.BottomEdge,
                FriendsFrameTab1Left,
                FriendsFrameTab1LeftDisabled,
                FriendsFrameTab1Middle,
                FriendsFrameTab1MiddleDisabled,
                FriendsFrameTab1Right,
                FriendsFrameTab1RightDisabled,
                FriendsFrameTab2Left,
                FriendsFrameTab2LeftDisabled,
                FriendsFrameTab2Middle,
                FriendsFrameTab2MiddleDisabled,
                FriendsFrameTab2Right,
                FriendsFrameTab2RightDisabled,
                FriendsFrameTab3Left,
                FriendsFrameTab3LeftDisabled,
                FriendsFrameTab3Middle,
                FriendsFrameTab3MiddleDisabled,
                FriendsFrameTab3Right,
                FriendsFrameTab3RightDisabled,
                FriendsFrameTab4Left,
                FriendsFrameTab4LeftDisabled,
                FriendsFrameTab4Middle,
                FriendsFrameTab4MiddleDisabled,
                FriendsFrameTab4Right,
                FriendsFrameTab4RightDisabled,
                FriendsFriendsFrame.Border.TopEdge,
                FriendsFriendsFrame.Border.RightEdge,
                FriendsFriendsFrame.Border.BottomEdge,
                FriendsFriendsFrame.Border.LeftEdge,
                FriendsFriendsFrame.Border.TopRightCorner,
                FriendsFriendsFrame.Border.TopLeftCorner,
                FriendsFriendsFrame.Border.BottomLeftCorner,
                FriendsFriendsFrame.Border.BottomRightCorner,
                FriendsFrameBattlenetFrame.BroadcastFrame.Border.TopEdge,
                FriendsFrameBattlenetFrame.BroadcastFrame.Border.RightEdge,
                FriendsFrameBattlenetFrame.BroadcastFrame.Border.BottomEdge,
                FriendsFrameBattlenetFrame.BroadcastFrame.Border.LeftEdge,
                FriendsFrameBattlenetFrame.BroadcastFrame.Border.TopRightCorner,
                FriendsFrameBattlenetFrame.BroadcastFrame.Border.TopLeftCorner,
                FriendsFrameBattlenetFrame.BroadcastFrame.Border.BottomLeftCorner,
                FriendsFrameBattlenetFrame.BroadcastFrame.Border.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            for i, v in pairs({
                FriendsFrameInset.NineSlice,
                FriendsFrameInset.NineSlice.BottomLeftCorner,
                FriendsFrameInset.NineSlice.BottomRightCorner,
                FriendsFrameInset.NineSlice.BottomEdge,
                WhoFrameListInset.NineSlice.BottomLeftCorner,
                WhoFrameListInset.NineSlice.BottomRightCorner,
                WhoFrameListInset.NineSlice.BottomEdge,
                WhoFrameListInset.NineSlice.LeftEdge,
                WhoFrameEditBoxInset.NineSlice.BottomLeftCorner,
                WhoFrameEditBoxInset.NineSlice.BottomRightCorner,
                WhoFrameEditBoxInset.NineSlice.BottomEdge, 
            }) do
                v:SetAlpha(0)
            end
            -- Map
            for i, v in pairs({ 
                WorldMapFrame.BorderFrame.NineSlice.TopEdge,
                WorldMapFrame.BorderFrame.NineSlice.TopEdge,
                WorldMapFrame.BorderFrame.NineSlice.TopEdge,
                WorldMapFrame.BorderFrame.NineSlice.TopRightCorner,
                WorldMapFrame.BorderFrame.NineSlice.RightEdge,
                WorldMapFrame.BorderFrame.NineSlice.BottomRightCorner,
                WorldMapFrame.BorderFrame.NineSlice.BottomEdge,
                WorldMapFrame.BorderFrame.NineSlice.BottomLeftCorner,
                WorldMapFrame.BorderFrame.NineSlice.LeftEdge,
                WorldMapFrame.BorderFrame.NineSlice.TopLeftCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- Channels
            for i, v in pairs({ 
                ChannelFrame.NineSlice.TopEdge,
                ChannelFrame.NineSlice.TopEdge,
                ChannelFrame.NineSlice.TopRightCorner,
                ChannelFrame.NineSlice.RightEdge,
                ChannelFrame.NineSlice.BottomRightCorner,
                ChannelFrame.NineSlice.BottomEdge,
                ChannelFrame.NineSlice.BottomLeftCorner,
                ChannelFrame.NineSlice.LeftEdge,
                ChannelFrame.NineSlice.TopLeftCorner,
                ChannelFrame.LeftInset.NineSlice.BottomEdge,
                ChannelFrame.LeftInset.NineSlice.BottomLeftCorner,
                ChannelFrame.LeftInset.NineSlice.BottomRightCorner,
                ChannelFrame.RightInset.NineSlice.BottomEdge,
                ChannelFrame.RightInset.NineSlice.BottomLeftCorner,
                ChannelFrame.RightInset.NineSlice.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            for i, v in pairs({
                ChannelFrameInset.NineSlice,
                ChannelFrameInset.NineSlice.BottomLeftCorner,
                ChannelFrameInset.NineSlice.BottomRightCorner,
                ChannelFrameInset.NineSlice.BottomEdge,
                ChannelFrameInset.NineSlice.LeftEdge 
            }) do
                v:SetAlpha(0)
            end
            -- Chat
            for i, v in pairs({ 
                ChatFrame1EditBoxLeft,
                ChatFrame1EditBoxRight,
                ChatFrame1EditBoxMid,
                ChatFrame2EditBoxLeft,
                ChatFrame2EditBoxRight,
                ChatFrame2EditBoxMid,
                ChatFrame3EditBoxLeft,
                ChatFrame3EditBoxRight,
                ChatFrame3EditBoxMid,
                ChatFrame4EditBoxLeft,
                ChatFrame4EditBoxRight,
                ChatFrame4EditBoxMid,
                ChatFrame5EditBoxLeft,
                ChatFrame5EditBoxRight,
                ChatFrame5EditBoxMid,
                ChatFrame6EditBoxLeft,
                ChatFrame6EditBoxRight,
                ChatFrame6EditBoxMid,
                ChatFrame7EditBoxLeft,
                ChatFrame7EditBoxRight,
                ChatFrame7EditBoxMid,    
            }) do
                ColorizationFrameFunction(v)
            end
            -- StatusBar (ExpBar)
            for i, v in pairs({ 
                StatusTrackingBarManager.SingleBarLarge,
                StatusTrackingBarManager.SingleBarSmall,
                StatusTrackingBarManager.SingleBarLargeUpper,
                StatusTrackingBarManager.SingleBarSmallUpper,    
            }) do
                ColorizationFrameFunction(v)
            end
            -- Mail
            for i, v in pairs({ 
                MailFrame.NineSlice.TopEdge,
                MailFrame.NineSlice.TopRightCorner,
                MailFrame.NineSlice.RightEdge,
                MailFrame.NineSlice.BottomRightCorner,
                MailFrame.NineSlice.BottomEdge,
                MailFrame.NineSlice.BottomLeftCorner,
                MailFrame.NineSlice.LeftEdge,
                MailFrame.NineSlice.TopLeftCorner,
                MailFrameInset.NineSlice.BottomEdge,
                OpenMailFrame.NineSlice.TopEdge,
                OpenMailFrame.NineSlice.TopRightCorner,
                OpenMailFrame.NineSlice.RightEdge,
                OpenMailFrame.NineSlice.BottomRightCorner,
                OpenMailFrame.NineSlice.BottomEdge,
                OpenMailFrame.NineSlice.BottomLeftCorner,
                OpenMailFrame.NineSlice.LeftEdge,
                OpenMailFrame.NineSlice.TopLeftCorner,
                OpenMailFrame.NineSlice.BottomEdge,
                MailFrameTab1Left,
                MailFrameTab1LeftDisabled,
                MailFrameTab1Middle,
                MailFrameTab1MiddleDisabled,
                MailFrameTab1Right,
                MailFrameTab1RightDisabled,
                MailFrameTab2Left,
                MailFrameTab2LeftDisabled,
                MailFrameTab2Middle,
                MailFrameTab2MiddleDisabled,
                MailFrameTab2Right,
                MailFrameTab2RightDisabled,
            }) do
                ColorizationFrameFunction(v)
            end
            for i, v in pairs({
                MailFrameInset.NineSlice,
                MailFrameInset.NineSlice.BottomLeftCorner,
                MailFrameInset.NineSlice.BottomRightCorner,
                SendMailMoneyInset.NineSlice.BottomLeftCorner,
                SendMailMoneyInset.NineSlice.BottomRightCorner, 
            }) do
                v:SetAlpha(0)
            end
            -- Merchant
            for i, v in pairs({ 
                MerchantFrame.NineSlice.TopEdge,
                MerchantFrame.NineSlice.RightEdge,
                MerchantFrame.NineSlice.BottomEdge,
                MerchantFrame.NineSlice.LeftEdge,
                MerchantFrame.NineSlice.TopRightCorner,
                MerchantFrame.NineSlice.TopLeftCorner,
                MerchantFrame.NineSlice.BottomLeftCorner,
                MerchantFrame.NineSlice.BottomRightCorner,
                MerchantFrameTab1Left,
                MerchantFrameTab1LeftDisabled,
                MerchantFrameTab1Middle,
                MerchantFrameTab1MiddleDisabled,
                MerchantFrameTab1Right,
                MerchantFrameTab1RightDisabled,
                MerchantFrameTab2Left,
                MerchantFrameTab2LeftDisabled,
                MerchantFrameTab2Middle,
                MerchantFrameTab2MiddleDisabled,
                MerchantFrameTab2Right,
                MerchantFrameTab2RightDisabled,
                StackSplitFrame.SingleItemSplitBackground, 
            }) do
                ColorizationFrameFunction(v)
            end
            for i, v in pairs({
                MerchantMoneyInset.NineSlice,
                MerchantMoneyInset.NineSlice.BottomLeftCorner,
                MerchantMoneyInset.NineSlice.BottomRightCorner,
                MerchantMoneyInset.NineSlice.BottomEdge,
                MerchantExtraCurrencyInset.NineSlice,
                MerchantExtraCurrencyInset.NineSlice.BottomLeftCorner,
                MerchantExtraCurrencyInset.NineSlice.BottomRightCorner,
                MerchantExtraCurrencyInset.NineSlice.BottomEdge,
                MerchantFrameInset.NineSlice,
                MerchantFrameInset.NineSlice.BottomLeftCorner,
                MerchantFrameInset.NineSlice.BottomRightCorner,
                MerchantFrameInset.NineSlice.BottomEdge,
                MerchantFrameInset.NineSlice.LeftEdge,
            }) do
                v:SetAlpha(0)
            end
            -- Gossip (e.g NPC dialog frame and interactions)
            for i, v in pairs({ 
                GossipFrame.NineSlice.TopEdge,
                GossipFrame.NineSlice.RightEdge,
                GossipFrame.NineSlice.BottomEdge,
                GossipFrame.NineSlice.LeftEdge,
                GossipFrame.NineSlice.TopRightCorner,
                GossipFrame.NineSlice.TopLeftCorner,
                GossipFrame.NineSlice.BottomLeftCorner,
                GossipFrame.NineSlice.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            for i, v in pairs({
                GossipFrameInset.NineSlice,
                GossipFrameInset.NineSlice.BottomLeftCorner,
                GossipFrameInset.NineSlice.BottomRightCorner,
                GossipFrameInset.NineSlice.BottomEdge,
                GossipFrameInset.NineSlice.LeftEdge, 
            }) do 
                v:SetAlpha(0)
            end
            -- Bank
            for i, v in pairs({ 
                BankFrame.NineSlice.TopEdge,
                BankFrame.NineSlice.RightEdge,
                BankFrame.NineSlice.BottomEdge,
                BankFrame.NineSlice.LeftEdge,
                BankFrame.NineSlice.TopRightCorner,
                BankFrame.NineSlice.TopLeftCorner,
                BankFrame.NineSlice.BottomLeftCorner,
                BankFrame.NineSlice.BottomRightCorner,
                BankFrameTab1Left,
                BankFrameTab1LeftDisabled,
                BankFrameTab1Middle,
                BankFrameTab1MiddleDisabled,
                BankFrameTab1Right,
                BankFrameTab1RightDisabled,
                BankFrameTab2Left,
                BankFrameTab2LeftDisabled,
                BankFrameTab2Middle,
                BankFrameTab2MiddleDisabled,
                BankFrameTab2Right,
                BankFrameTab2RightDisabled,
            }) do
                ColorizationFrameFunction(v)
            end
            -- Quest
            for i, v in pairs({ 
                QuestFrame.NineSlice.TopEdge,
                QuestFrame.NineSlice.RightEdge,
                QuestFrame.NineSlice.BottomEdge,
                QuestFrame.NineSlice.LeftEdge,
                QuestFrame.NineSlice.TopRightCorner,
                QuestFrame.NineSlice.TopLeftCorner,
                QuestFrame.NineSlice.BottomLeftCorner,
                QuestFrame.NineSlice.BottomRightCorner,
                QuestFrameInset.NineSlice.BottomEdge,
                QuestLogPopupDetailFrame.NineSlice.TopEdge,
                QuestLogPopupDetailFrame.NineSlice.RightEdge,
                QuestLogPopupDetailFrame.NineSlice.BottomEdge,
                QuestLogPopupDetailFrame.NineSlice.LeftEdge,
                QuestLogPopupDetailFrame.NineSlice.TopRightCorner,
                QuestLogPopupDetailFrame.NineSlice.TopLeftCorner,
                QuestLogPopupDetailFrame.NineSlice.BottomLeftCorner,
                QuestLogPopupDetailFrame.NineSlice.BottomRightCorner,
                QuestLogPopupDetailFrame.NineSlice.BottomEdge,
                QuestNPCModelTopBorder,
                QuestNPCModelRightBorder,
                QuestNPCModelTopRightCorner,
                QuestNPCModelBottomRightCorner,
                QuestNPCModelBottomBorder,
                QuestNPCModelBottomLeftCorner,
                QuestNPCModelLeftBorder,
                QuestNPCModelTopLeftCorner,
                QuestNPCModelTextTopBorder,
                QuestNPCModelTextRightBorder,
                QuestNPCModelTextTopRightCorner,
                QuestNPCModelTextBottomRightCorner,
                QuestNPCModelTextBottomBorder,
                QuestNPCModelTextBottomLeftCorner,
                QuestNPCModelTextLeftBorder,
                QuestNPCModelTextTopLeftCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            for i, v in pairs({
                QuestFrameInset.NineSlice,
                QuestFrameInset.NineSlice.BottomLeftCorner,
                QuestFrameInset.NineSlice.BottomRightCorner,
                QuestFrameInset.NineSlice.BottomEdge,
                QuestFrameInset.NineSlice.LeftEdge, 
            }) do
                v:SetAlpha(0)
            end
            -- Micro Menu and Bag Bar
            for i, v in pairs({ MicroButtonAndBagsBar.MicroBagBar, }) do
                ColorizationFrameFunction(v)
            end
            -- StanceBar
            for i, v in pairs({ 
                StanceBarLeft,
                StanceBarMiddle,
                StanceBarRight, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- DressUP
            for i, v in pairs({ 
                DressUpFrame.NineSlice.TopEdge,
                DressUpFrame.NineSlice.RightEdge,
                DressUpFrame.NineSlice.BottomEdge,
                DressUpFrame.NineSlice.LeftEdge,
                DressUpFrame.NineSlice.TopRightCorner,
                DressUpFrame.NineSlice.TopLeftCorner,
                DressUpFrame.NineSlice.BottomLeftCorner,
                DressUpFrame.NineSlice.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            for i, v in pairs({
                DressUpFrameInset.NineSlice,
                DressUpFrameInset.NineSlice.BottomLeftCorner,
                DressUpFrameInset.NineSlice.BottomRightCorner,
                DressUpFrameInset.NineSlice.BottomEdge,
                DressUpFrameInset.NineSlice.LeftEdge, 
            }) do
                v:SetAlpha(0)
            end
            -- LootFrame
            for i, v in pairs({ 
                LootFrame.NineSlice.TopEdge,
                LootFrame.NineSlice.RightEdge,
                LootFrame.NineSlice.BottomEdge,
                LootFrame.NineSlice.LeftEdge,
                LootFrame.NineSlice.TopRightCorner,
                LootFrame.NineSlice.TopLeftCorner,
                LootFrame.NineSlice.BottomLeftCorner,
                LootFrame.NineSlice.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            if (GetWoWVersion <= 90500) then
                for i, v in pairs({
                    LootFrameInset.NineSlice,
                    LootFrameInset.NineSlice.BottomLeftCorner,
                    LootFrameInset.NineSlice.BottomRightCorner,
                    LootFrameInset.NineSlice.BottomEdge,
                    LootFrameInset.NineSlice.LeftEdge, 
                }) do 
                    v:SetAlpha(0)
                end
            end
            -- HelpFrame
            for i, v in pairs({ 
                HelpFrameTopBorder,
                HelpFrameRightBorder,
                HelpFrameTopRightCorner,
                HelpFrameBottomRightCorner,
                HelpFrameBottomBorder,
                HelpFrameBottomLeftCorner,
                HelpFrameLeftBorder,
                HelpFrameTopLeftCorner,
                HelpFrameVertDivTop,
                HelpFrameVertDivMiddle,
                HelpFrameVertDivBottom,
                HelpFrameHeaderTopBorder,
                HelpFrameHeaderTopRightCorner,
                HelpFrameHeaderRightBorder,
                HelpFrameHeaderBottomRightCorner,
                HelpFrameHeaderBottomBorder,
                HelpFrameHeaderBottomLeftCorner,
                HelpFrameHeaderLeftBorder,
                HelpFrameHeaderTopLeftCorner,
                HelpBrowser.BrowserInset.NineSlice.BottomEdge, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- ItemTextFrame
            for i, v in pairs({    
                ItemTextFrame.NineSlice.TopEdge,
                ItemTextFrame.NineSlice.RightEdge,
                ItemTextFrame.NineSlice.BottomEdge,
                ItemTextFrame.NineSlice.LeftEdge,
                ItemTextFrame.NineSlice.TopRightCorner,
                ItemTextFrame.NineSlice.TopLeftCorner,
                ItemTextFrame.NineSlice.BottomLeftCorner,
                ItemTextFrame.NineSlice.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- PetitionFrame
            for i, v in pairs({    
                PetitionFrame.NineSlice.TopEdge,
                PetitionFrame.NineSlice.RightEdge,
                PetitionFrame.NineSlice.BottomEdge,
                PetitionFrame.NineSlice.LeftEdge,
                PetitionFrame.NineSlice.TopRightCorner,
                PetitionFrame.NineSlice.TopLeftCorner,
                PetitionFrame.NineSlice.BottomLeftCorner,
                PetitionFrame.NineSlice.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- Guild Register Frame & Tabard Frame
            for i, v in pairs({    
                GuildRegistrarFrame.NineSlice.TopEdge,
                GuildRegistrarFrame.NineSlice.RightEdge,
                GuildRegistrarFrame.NineSlice.BottomEdge,
                GuildRegistrarFrame.NineSlice.LeftEdge,
                GuildRegistrarFrame.NineSlice.TopRightCorner,
                GuildRegistrarFrame.NineSlice.TopLeftCorner,
                GuildRegistrarFrame.NineSlice.BottomLeftCorner,
                GuildRegistrarFrame.NineSlice.BottomRightCorner,
                TabardFrame.NineSlice.TopEdge,
                TabardFrame.NineSlice.RightEdge,
                TabardFrame.NineSlice.BottomEdge,
                TabardFrame.NineSlice.LeftEdge,
                TabardFrame.NineSlice.TopRightCorner,
                TabardFrame.NineSlice.TopLeftCorner,
                TabardFrame.NineSlice.BottomLeftCorner,
                TabardFrame.NineSlice.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end    
            -- GuildInviteFrame
            for i, v in pairs({    
                GuildInviteFrame.TopEdge,
                GuildInviteFrame.RightEdge,
                GuildInviteFrame.BottomEdge,
                GuildInviteFrame.LeftEdge,
                GuildInviteFrame.TopRightCorner,
                GuildInviteFrame.TopLeftCorner,
                GuildInviteFrame.BottomLeftCorner,
                GuildInviteFrame.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end    
            -- CastBarBorder
            if (GetWoWVersion <= 90500) then
                for i, v in pairs({    
                    CastingBarFrame.Border,
                    TargetFrameSpellBar.Border,
                    TargetFrameSpellBar.BorderShield, 
                }) do
                    ColorizationFrameFunction(v)
                end    
            end
            -- GameMenu
            for i, v in pairs({    
                GameMenuFrame.Border.TopEdge,
                GameMenuFrame.Border.RightEdge,
                GameMenuFrame.Border.BottomEdge,
                GameMenuFrame.Border.LeftEdge,
                GameMenuFrame.Border.TopRightCorner,
                GameMenuFrame.Border.TopLeftCorner,
                GameMenuFrame.Border.BottomLeftCorner,
                GameMenuFrame.Border.BottomRightCorner,
                GameMenuFrame.Header.RightBG,
                GameMenuFrame.Header.CenterBG,
                GameMenuFrame.Header.LeftBG, 
            }) do
                ColorizationFrameFunction(v)
            end    
            -- VideoOptions (System)
            if (GetWoWVersion <= 90500) then
                for i, v in pairs({    
                    VideoOptionsFrame.Border.TopEdge,
                    VideoOptionsFrame.Border.RightEdge,
                    VideoOptionsFrame.Border.BottomEdge,
                    VideoOptionsFrame.Border.LeftEdge,
                    VideoOptionsFrame.Border.TopRightCorner,
                    VideoOptionsFrame.Border.TopLeftCorner,
                    VideoOptionsFrame.Border.BottomLeftCorner,
                    VideoOptionsFrame.Border.BottomRightCorner,
                    VideoOptionsFrame.Header.RightBG,
                    VideoOptionsFrame.Header.CenterBG,
                    VideoOptionsFrame.Header.LeftBG, 
                }) do
                    ColorizationFrameFunction(v)
                end    
            end
            -- InterfaceOptions (Interface)
            if (GetWoWVersion <= 90500) then
                for i, v in pairs({    
                    InterfaceOptionsFrame.Border.TopEdge,
                    InterfaceOptionsFrame.Border.RightEdge,
                    InterfaceOptionsFrame.Border.BottomEdge,
                    InterfaceOptionsFrame.Border.LeftEdge,
                    InterfaceOptionsFrame.Border.TopRightCorner,
                    InterfaceOptionsFrame.Border.TopLeftCorner,
                    InterfaceOptionsFrame.Border.BottomLeftCorner,
                    InterfaceOptionsFrame.Border.BottomRightCorner,
                    InterfaceOptionsFrame.Header.RightBG,
                    InterfaceOptionsFrame.Header.CenterBG,
                    InterfaceOptionsFrame.Header.LeftBG, 
                }) do
                    ColorizationFrameFunction(v)
                end
            end
            -- AddonsList (Addons)
            for i, v in pairs({    
                AddonList.NineSlice.TopEdge,
                AddonList.NineSlice.RightEdge,
                AddonList.NineSlice.BottomEdge,
                AddonList.NineSlice.LeftEdge,
                AddonList.NineSlice.TopRightCorner,
                AddonList.NineSlice.TopLeftCorner,
                AddonList.NineSlice.BottomLeftCorner,
                AddonList.NineSlice.BottomRightCorner,
                AddonList.NineSlice.BottomEdge, 
            }) do
                ColorizationFrameFunction(v)
            end
            for i, v in pairs({
                AddonListInset.NineSlice,
                AddonListInset.NineSlice.BottomLeftCorner,
                AddonListInset.NineSlice.BottomRightCorner,
                AddonListInset.NineSlice.BottomEdge,
                AddonListInset.NineSlice.LeftEdge,
            }) do 
                v:SetAlpha(0)
            end
            -- StaticPopUp (LogoutFrame)
            for i, v in pairs({    
                StaticPopup1.Border.TopEdge,
                StaticPopup1.Border.RightEdge,
                StaticPopup1.Border.BottomEdge,
                StaticPopup1.Border.LeftEdge,
                StaticPopup1.Border.TopRightCorner,
                StaticPopup1.Border.TopLeftCorner,
                StaticPopup1.Border.BottomLeftCorner,
                StaticPopup1.Border.BottomRightCorner,
                StaticPopup2.Border.TopEdge,
                StaticPopup2.Border.RightEdge,
                StaticPopup2.Border.BottomEdge,
                StaticPopup2.Border.LeftEdge,
                StaticPopup2.Border.TopRightCorner,
                StaticPopup2.Border.TopLeftCorner,
                StaticPopup2.Border.BottomLeftCorner,
                StaticPopup2.Border.BottomRightCorner, 
            }) do
                if (not InCombatLockdown()) then
                    ColorizationFrameFunction(v)
                end
            end
            -- CharacterSlowFrames
            for i, v in pairs({    
                CharacterWristSlotFrame,
                CharacterTabardSlotFrame,
                CharacterShirtSlotFrame,
                CharacterChestSlotFrame,
                CharacterBackSlotFrame,
                CharacterShoulderSlotFrame,
                CharacterNeckSlotFrame,
                CharacterHeadSlotFrame,
                CharacterHandsSlotFrame,
                CharacterWaistSlotFrame,
                CharacterLegsSlotFrame,
                CharacterFeetSlotFrame,
                CharacterFinger0SlotFrame,
                CharacterFinger1SlotFrame,
                CharacterTrinket0SlotFrame,
                CharacterTrinket1SlotFrame,
                CharacterMainHandSlotFrame,
                CharacterSecondaryHandSlotFrame, 
            }) do
                ColorizationFrameFunction(v)
            end    
            -- LFDReadyCheckPopup
            for i, v in pairs({ 
                LFDReadyCheckPopup.Border.TopEdge,
                LFDReadyCheckPopup.Border.RightEdge,
                LFDReadyCheckPopup.Border.BottomEdge,
                LFDReadyCheckPopup.Border.LeftEdge,
                LFDReadyCheckPopup.Border.TopRightCorner,
                LFDReadyCheckPopup.Border.TopLeftCorner,
                LFDReadyCheckPopup.Border.BottomLeftCorner,
                LFDReadyCheckPopup.Border.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- LFDRoleCheckPopup
            for i, v in pairs({ 
                LFDRoleCheckPopup.Border.TopEdge,
                LFDRoleCheckPopup.Border.RightEdge,
                LFDRoleCheckPopup.Border.BottomEdge,
                LFDRoleCheckPopup.Border.LeftEdge,
                LFDRoleCheckPopup.Border.TopRightCorner,
                LFDRoleCheckPopup.Border.TopLeftCorner,
                LFDRoleCheckPopup.Border.BottomLeftCorner,
                LFDRoleCheckPopup.Border.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- PVPRoleCheckPopup
            for i, v in pairs({ 
                PVPRoleCheckPopup.Border.TopEdge,
                PVPRoleCheckPopup.Border.RightEdge,
                PVPRoleCheckPopup.Border.BottomEdge,
                PVPRoleCheckPopup.Border.LeftEdge,
                PVPRoleCheckPopup.Border.TopRightCorner,
                PVPRoleCheckPopup.Border.TopLeftCorner,
                PVPRoleCheckPopup.Border.BottomLeftCorner,
                PVPRoleCheckPopup.Border.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- Areana/Bg EnemyFrame
            if GetWoWVersion > 11402 then
                for i, v in pairs({ 
                    ArenaEnemyFrame1Texture,
                    ArenaEnemyFrame1CastingBar,
                    ArenaEnemyFrame1DropDown,
                    ArenaEnemyFrame1ClassPortrait,
                    ArenaEnemyFrame1PetFrame,
                    ArenaEnemyFrame1SpecBorder,
                    ArenaEnemyFrame2Texture,
                    ArenaEnemyFrame2CastingBar,
                    ArenaEnemyFrame2DropDown,
                    ArenaEnemyFrame2ClassPortrait,
                    ArenaEnemyFrame2PetFrame,
                    ArenaEnemyFrame2SpecBorder,
                    ArenaEnemyFrame3Texture,
                    ArenaEnemyFrame3CastingBar,
                    ArenaEnemyFrame3DropDown,
                    ArenaEnemyFrame3ClassPortrait,
                    ArenaEnemyFrame3PetFrame,
                    ArenaEnemyFrame3SpecBorder,
                    ArenaEnemyFrame4Texture,
                    ArenaEnemyFrame4CastingBar,
                    ArenaEnemyFrame4DropDown,
                    ArenaEnemyFrame4ClassPortrait,
                    ArenaEnemyFrame4PetFrame,
                    ArenaEnemyFrame4SpecBorder,
                    ArenaEnemyFrame5Texture,
                    ArenaEnemyFrame5CastingBar,
                    ArenaEnemyFrame5DropDown,
                    ArenaEnemyFrame5ClassPortrait,
                    ArenaEnemyFrame5PetFrame,
                    ArenaEnemyFrame5SpecBorder, 
                }) do
                    ColorizationFrameFunction(v)
                end
            end
            -- RecruitAFriend
            for i, v in pairs({ 
                RecruitAFriendRecruitmentFrame.Border.TopEdge,
                RecruitAFriendRecruitmentFrame.Border.RightEdge,
                RecruitAFriendRecruitmentFrame.Border.BottomEdge,
                RecruitAFriendRecruitmentFrame.Border.LeftEdge,
                RecruitAFriendRecruitmentFrame.Border.TopRightCorner,
                RecruitAFriendRecruitmentFrame.Border.TopLeftCorner,
                RecruitAFriendRecruitmentFrame.Border.BottomLeftCorner,
                RecruitAFriendRecruitmentFrame.Border.BottomRightCorner,
                RecruitAFriendRewardsFrame.Border.TopEdge,
                RecruitAFriendRewardsFrame.Border.RightEdge,
                RecruitAFriendRewardsFrame.Border.BottomEdge,
                RecruitAFriendRewardsFrame.Border.LeftEdge,
                RecruitAFriendRewardsFrame.Border.TopRightCorner,
                RecruitAFriendRewardsFrame.Border.TopLeftCorner,
                RecruitAFriendRewardsFrame.Border.BottomLeftCorner,
                RecruitAFriendRewardsFrame.Border.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- LFGDiag
            for i, v in pairs({
                LFGDungeonReadyStatus.Border.TopEdge,
                LFGDungeonReadyStatus.Border.RightEdge,
                LFGDungeonReadyStatus.Border.BottomEdge,
                LFGDungeonReadyStatus.Border.LeftEdge,
                LFGDungeonReadyStatus.Border.TopRightCorner,
                LFGDungeonReadyStatus.Border.TopLeftCorner,
                LFGDungeonReadyStatus.Border.BottomLeftCorner,
                LFGDungeonReadyStatus.Border.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- LFGInvitePopup
            for i, v in pairs({ 
                LFGInvitePopup.Border.TopEdge,
                LFGInvitePopup.Border.RightEdge,
                LFGInvitePopup.Border.BottomEdge,
                LFGInvitePopup.Border.LeftEdge,
                LFGInvitePopup.Border.TopRightCorner,
                LFGInvitePopup.Border.TopLeftCorner,
                LFGInvitePopup.Border.BottomLeftCorner,
                LFGInvitePopup.Border.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- LFGListApplicationDialog
            for i, v in pairs({
                LFGListApplicationDialog.Border.TopEdge,
                LFGListApplicationDialog.Border.RightEdge,
                LFGListApplicationDialog.Border.BottomEdge,
                LFGListApplicationDialog.Border.LeftEdge,
                LFGListApplicationDialog.Border.TopRightCorner,
                LFGListApplicationDialog.Border.TopLeftCorner,
                LFGListApplicationDialog.Border.BottomLeftCorner,
                LFGListApplicationDialog.Border.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- LFGListInviteDialog
            for i, v in pairs({
                LFGListInviteDialog.Border.TopEdge,
                LFGListInviteDialog.Border.RightEdge,
                LFGListInviteDialog.Border.BottomEdge,
                LFGListInviteDialog.Border.LeftEdge,
                LFGListInviteDialog.Border.TopRightCorner,
                LFGListInviteDialog.Border.TopLeftCorner,
                LFGListInviteDialog.Border.BottomLeftCorner,
                LFGListInviteDialog.Border.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- LFDRoleCheckPopup
            for i, v in pairs({
                LFDRoleCheckPopup.Border.TopEdge,
                LFDRoleCheckPopup.Border.RightEdge,
                LFDRoleCheckPopup.Border.BottomEdge,
                LFDRoleCheckPopup.Border.LeftEdge,
                LFDRoleCheckPopup.Border.TopRightCorner,
                LFDRoleCheckPopup.Border.TopLeftCorner,
                LFDRoleCheckPopup.Border.BottomLeftCorner,
                LFDRoleCheckPopup.Border.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- PVPReadyDialog
            for i, v in pairs({ 
                PVPReadyDialog.Border.TopEdge,
                PVPReadyDialog.Border.RightEdge,
                PVPReadyDialog.Border.BottomEdge,
                PVPReadyDialog.Border.LeftEdge,
                PVPReadyDialog.Border.TopRightCorner,
                PVPReadyDialog.Border.TopLeftCorner,
                PVPReadyDialog.Border.BottomLeftCorner,
                PVPReadyDialog.Border.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- DropDownList
            for i, v in pairs({ 
                DropDownList1Backdrop.TopEdge,
                DropDownList1Backdrop.RightEdge,
                DropDownList1Backdrop.BottomEdge,
                DropDownList1Backdrop.LeftEdge,
                DropDownList1Backdrop.TopRightCorner,
                DropDownList1Backdrop.TopLeftCorner,
                DropDownList1Backdrop.BottomLeftCorner,
                DropDownList1Backdrop.BottomRightCorner,
                DropDownList2Backdrop.TopEdge,
                DropDownList2Backdrop.RightEdge,
                DropDownList2Backdrop.BottomEdge,
                DropDownList2Backdrop.LeftEdge,
                DropDownList2Backdrop.TopRightCorner,
                DropDownList2Backdrop.TopLeftCorner,
                DropDownList2Backdrop.BottomLeftCorner,
                DropDownList2Backdrop.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- ChatConfigFrame
            for i, v in pairs({ 
                ChatConfigFrame.Header.CenterBG,
                ChatConfigFrame.Header.LeftBG,
                ChatConfigFrame.Header.RightBG,
                ChatConfigFrame.Border.TopEdge,
                ChatConfigFrame.Border.RightEdge,
                ChatConfigFrame.Border.BottomEdge,
                ChatConfigFrame.Border.LeftEdge,
                ChatConfigFrame.Border.TopRightCorner,
                ChatConfigFrame.Border.TopLeftCorner,
                ChatConfigFrame.Border.BottomLeftCorner,
                ChatConfigFrame.Border.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- CinematicFrameCloseDialog
            for i, v in pairs({
                CinematicFrameCloseDialog.Border.TopEdge,
                CinematicFrameCloseDialog.Border.RightEdge,
                CinematicFrameCloseDialog.Border.BottomEdge,
                CinematicFrameCloseDialog.Border.LeftEdge,
                CinematicFrameCloseDialog.Border.TopRightCorner,
                CinematicFrameCloseDialog.Border.TopLeftCorner,
                CinematicFrameCloseDialog.Border.BottomLeftCorner,
                CinematicFrameCloseDialog.Border.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- TradeFrame
            for i, v in pairs({
                TradeFrame.NineSlice.TopEdge,
                TradeFrame.NineSlice.RightEdge,
                TradeFrame.NineSlice.BottomEdge,
                TradeFrame.NineSlice.LeftEdge,
                TradeFrame.NineSlice.TopRightCorner,
                TradeFrame.NineSlice.TopLeftCorner,
                TradeFrame.NineSlice.BottomLeftCorner,
                TradeFrame.NineSlice.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- ReportCheatingDialog
            for i, v in pairs({
                ReportCheatingDialog.Border.TopEdge,
                ReportCheatingDialog.Border.RightEdge,
                ReportCheatingDialog.Border.BottomEdge,
                ReportCheatingDialog.Border.LeftEdge,
                ReportCheatingDialog.Border.TopRightCorner,
                ReportCheatingDialog.Border.TopLeftCorner,
                ReportCheatingDialog.Border.BottomLeftCorner,
                ReportCheatingDialog.Border.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- PlayerReportFrame
            for i, v in pairs({
                ReportFrame.Border.TopEdge,
                ReportFrame.Border.RightEdge,
                ReportFrame.Border.BottomEdge,
                ReportFrame.Border.LeftEdge,
                ReportFrame.Border.TopRightCorner,
                ReportFrame.Border.TopLeftCorner,
                ReportFrame.Border.BottomLeftCorner,
                ReportFrame.Border.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- AddFriendFrame
            for i, v in pairs({
                AddFriendFrame.Border.TopEdge,
                AddFriendFrame.Border.RightEdge,
                AddFriendFrame.Border.BottomEdge,
                AddFriendFrame.Border.LeftEdge,
                AddFriendFrame.Border.TopRightCorner,
                AddFriendFrame.Border.TopLeftCorner,
                AddFriendFrame.Border.BottomLeftCorner,
                AddFriendFrame.Border.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- ArenaPrepFrame
            if GetWoWVersion > 11402 then
                for i, v in pairs({
                    ArenaPrepFrame1CastingBar,
                    ArenaPrepFrame1DropDown,
                    ArenaPrepFrame1ClassPortrait,
                    ArenaPrepFrame2CastingBar,
                    ArenaPrepFrame2DropDown,
                    ArenaPrepFrame2ClassPortrait,
                    ArenaPrepFrame3CastingBar,
                    ArenaPrepFrame3DropDown,
                    ArenaPrepFrame3ClassPortrait,
                    ArenaPrepFrame4CastingBar,
                    ArenaPrepFrame4DropDown,
                    ArenaPrepFrame4ClassPortrait,
                    ArenaPrepFrame5CastingBar,
                    ArenaPrepFrame5DropDown,
                    ArenaPrepFrame5ClassPortrait, 
                }) do
                    ColorizationFrameFunction(v)
                end
            end
            -- AudioOptionsFrame
            if (GetWoWVersion <= 90500) then
                for i, v in pairs({
                    AudioOptionsFrame.Header.CenterBG,
                    AudioOptionsFrame.Header.LeftBG,
                    AudioOptionsFrame.Header.RightBG,
                    AudioOptionsFrame.Border.TopEdge,
                    AudioOptionsFrame.Border.RightEdge,
                    AudioOptionsFrame.Border.BottomEdge,
                    AudioOptionsFrame.Border.LeftEdge,
                    AudioOptionsFrame.Border.TopRightCorner,
                    AudioOptionsFrame.Border.TopLeftCorner,
                    AudioOptionsFrame.Border.BottomLeftCorner,
                    AudioOptionsFrame.Border.BottomRightCorner, 
                }) do
                    ColorizationFrameFunction(v)
                end
            end
            -- ClubFinderReportFrame
            --[[
            for i, v in pairs({
                ClubFinderReportFrame.Border.TopEdge,
                ClubFinderReportFrame.Border.RightEdge,
                ClubFinderReportFrame.Border.BottomEdge,
                ClubFinderReportFrame.Border.LeftEdge,
                ClubFinderReportFrame.Border.TopRightCorner,
                ClubFinderReportFrame.Border.TopLeftCorner,
                ClubFinderReportFrame.Border.BottomLeftCorner,
                ClubFinderReportFrame.Border.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            --]]
            -- ColorPickerFrame
            for i, v in pairs({
                ColorPickerFrame.Header.CenterBG,
                ColorPickerFrame.Header.LeftBG,
                ColorPickerFrame.Header.RightBG,
                ColorPickerFrame.Border.TopEdge,
                ColorPickerFrame.Border.RightEdge,
                ColorPickerFrame.Border.BottomEdge,
                ColorPickerFrame.Border.LeftEdge,
                ColorPickerFrame.Border.TopRightCorner,
                ColorPickerFrame.Border.TopLeftCorner,
                ColorPickerFrame.Border.BottomLeftCorner,
                ColorPickerFrame.Border.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- FolderPicker
            if (GetWoWVersion <= 90500) then
                for i, v in pairs({
                    FolderPicker.Header.CenterBG,
                    FolderPicker.Header.LeftBG,
                    FolderPicker.Header.RightBG,
                    FolderPicker.Border.TopEdge,
                    FolderPicker.Border.RightEdge,
                    FolderPicker.Border.BottomEdge,
                    FolderPicker.Border.LeftEdge,
                    FolderPicker.Border.TopRightCorner,
                    FolderPicker.Border.TopLeftCorner,
                    FolderPicker.Border.BottomLeftCorner,
                    FolderPicker.Border.BottomRightCorner, 
                }) do
                    ColorizationFrameFunction(v)
                end
            end
            -- LootHistoryFrame
            --[[
            for i, v in pairs({
                LootHistoryFrame.Divider,
                LootHistoryFrame.BorderRight,
                LootHistoryFrame.BorderBottom,
                LootHistoryFrame.BorderLeft,
                LootHistoryFrame.BorderTopRight,
                LootHistoryFrame.BorderTopLeft,
                LootHistoryFrame.BorderBottomLeft,
                LootHistoryFrame.BorderBottomRight, 
            }) do
                ColorizationFrameFunction(v)
            end
            --]]
            -- ModelPreviewFrame
            for i, v in pairs({
                ModelPreviewFrame.NineSlice.TopEdge,
                ModelPreviewFrame.NineSlice.RightEdge,
                ModelPreviewFrame.NineSlice.BottomEdge,
                ModelPreviewFrame.NineSlice.LeftEdge,
                ModelPreviewFrame.NineSlice.TopRightCorner,
                ModelPreviewFrame.NineSlice.TopLeftCorner,
                ModelPreviewFrame.NineSlice.BottomLeftCorner,
                ModelPreviewFrame.NineSlice.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- OpacityFrame
            for i, v in pairs({
                OpacityFrame.Border.TopEdge,
                OpacityFrame.Border.RightEdge,
                OpacityFrame.Border.BottomEdge,
                OpacityFrame.Border.LeftEdge,
                OpacityFrame.Border.TopRightCorner,
                OpacityFrame.Border.TopLeftCorner,
                OpacityFrame.Border.BottomLeftCorner,
                OpacityFrame.Border.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- RaidBrowserFrame
            if (GetWoWVersion < 100100) then
                for i, v in pairs({
                    RaidBrowserFrame.NineSlice.TopEdge,
                    RaidBrowserFrame.NineSlice.RightEdge,
                    RaidBrowserFrame.NineSlice.BottomEdge,
                    RaidBrowserFrame.NineSlice.LeftEdge,
                    RaidBrowserFrame.NineSlice.TopRightCorner,
                    RaidBrowserFrame.NineSlice.TopLeftCorner,
                    RaidBrowserFrame.NineSlice.BottomLeftCorner,
                    RaidBrowserFrame.NineSlice.BottomRightCorner, 
                }) do
                    ColorizationFrameFunction(v)
                end
            end
            -- RatingMenuFrame
            for i, v in pairs({
                RatingMenuFrame.Header.CenterBG,
                RatingMenuFrame.Header.LeftBG,
                RatingMenuFrame.Header.RightBG,
                RatingMenuFrame.Border.TopEdge,
                RatingMenuFrame.Border.RightEdge,
                RatingMenuFrame.Border.BottomEdge,
                RatingMenuFrame.Border.LeftEdge,
                RatingMenuFrame.Border.TopRightCorner,
                RatingMenuFrame.Border.TopLeftCorner,
                RatingMenuFrame.Border.BottomLeftCorner,
                RatingMenuFrame.Border.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- TicketStatusFrameButton
            for i, v in pairs({
                TicketStatusFrameButton.TopEdge,
                TicketStatusFrameButton.RightEdge,
                TicketStatusFrameButton.BottomEdge,
                TicketStatusFrameButton.LeftEdge,
                TicketStatusFrameButton.TopRightCorner,
                TicketStatusFrameButton.TopLeftCorner,
                TicketStatusFrameButton.BottomLeftCorner,
                TicketStatusFrameButton.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- VoiceChatChannelActivatedNotification
            for i, v in pairs({
                VoiceChatChannelActivatedNotification.TopEdge,
                VoiceChatChannelActivatedNotification.RightEdge,
                VoiceChatChannelActivatedNotification.BottomEdge,
                VoiceChatChannelActivatedNotification.LeftEdge,
                VoiceChatChannelActivatedNotification.TopRightCorner,
                VoiceChatChannelActivatedNotification.TopLeftCorner,
                VoiceChatChannelActivatedNotification.BottomLeftCorner,
                VoiceChatChannelActivatedNotification.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- VoiceChatPromptActivateChannel
            for i, v in pairs({
                VoiceChatPromptActivateChannel.TopEdge,
                VoiceChatPromptActivateChannel.RightEdge,
                VoiceChatPromptActivateChannel.BottomEdge,
                VoiceChatPromptActivateChannel.LeftEdge,
                VoiceChatPromptActivateChannel.TopRightCorner,
                VoiceChatPromptActivateChannel.TopLeftCorner,
                VoiceChatPromptActivateChannel.BottomLeftCorner,
                VoiceChatPromptActivateChannel.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- WardrobeOutfitEditFrame
            for i, v in pairs({
                WardrobeOutfitEditFrame.Border.TopEdge,
                WardrobeOutfitEditFrame.Border.RightEdge,
                WardrobeOutfitEditFrame.Border.BottomEdge,
                WardrobeOutfitEditFrame.Border.LeftEdge,
                WardrobeOutfitEditFrame.Border.TopRightCorner,
                WardrobeOutfitEditFrame.Border.TopLeftCorner,
                WardrobeOutfitEditFrame.Border.BottomLeftCorner,
                WardrobeOutfitEditFrame.Border.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- WardrobeOutfitFrame
            --[[
            for i, v in pairs({
                WardrobeOutfitFrame.Border.TopEdge,
                WardrobeOutfitFrame.Border.RightEdge,
                WardrobeOutfitFrame.Border.BottomEdge,
                WardrobeOutfitFrame.Border.LeftEdge,
                WardrobeOutfitFrame.Border.TopRightCorner,
                WardrobeOutfitFrame.Border.TopLeftCorner,
                WardrobeOutfitFrame.Border.BottomLeftCorner,
                WardrobeOutfitFrame.Border.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            --]]
            -- QuestSessionManager.CheckStopDialog
            for i, v in pairs({
                QuestSessionManager.CheckStopDialog.Border.TopEdge,
                QuestSessionManager.CheckStopDialog.Border.RightEdge,
                QuestSessionManager.CheckStopDialog.Border.BottomEdge,
                QuestSessionManager.CheckStopDialog.Border.LeftEdge,
                QuestSessionManager.CheckStopDialog.Border.TopRightCorner,
                QuestSessionManager.CheckStopDialog.Border.TopLeftCorner,
                QuestSessionManager.CheckStopDialog.Border.BottomLeftCorner,
                QuestSessionManager.CheckStopDialog.Border.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- QuestSessionManager.StartDialog
            for i, v in pairs({
                QuestSessionManager.StartDialog.Border.TopEdge,
                QuestSessionManager.StartDialog.Border.RightEdge,
                QuestSessionManager.StartDialog.Border.BottomEdge,
                QuestSessionManager.StartDialog.Border.LeftEdge,
                QuestSessionManager.StartDialog.Border.TopRightCorner,
                QuestSessionManager.StartDialog.Border.TopLeftCorner,
                QuestSessionManager.StartDialog.Border.BottomLeftCorner,
                QuestSessionManager.StartDialog.Border.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- MovieFrame.CloseDialog
            for i, v in pairs({
                MovieFrame.CloseDialog.Border.TopEdge,
                MovieFrame.CloseDialog.Border.RightEdge,
                MovieFrame.CloseDialog.Border.BottomEdge,
                MovieFrame.CloseDialog.Border.LeftEdge,
                MovieFrame.CloseDialog.Border.TopRightCorner,
                MovieFrame.CloseDialog.Border.TopLeftCorner,
                MovieFrame.CloseDialog.Border.BottomLeftCorner,
                MovieFrame.CloseDialog.Border.BottomRightCorner, 
            }) do
                ColorizationFrameFunction(v)
            end
            -- ContainerFrame1
            for i, v in pairs({ 
                ContainerFrame1Background1Slot,
                ContainerFrame1BackgroundBottom,
                ContainerFrame1BackgroundMiddle1,
                ContainerFrame1BackgroundMiddle2,
                ContainerFrame1BackgroundTop,
                ContainerFrame1BackgroundPortrait,
             }) do
                ColorizationFrameFunction(v)
            end
            -- ContainerFrame2
            for i, v in pairs({ 
                ContainerFrame2Background1Slot,
                ContainerFrame2BackgroundBottom,
                ContainerFrame2BackgroundMiddle1,
                ContainerFrame2BackgroundMiddle2,
                ContainerFrame2BackgroundTop,
                ContainerFrame2BackgroundPortrait,
             }) do
                ColorizationFrameFunction(v)
            end
            -- ContainerFrame3
            for i, v in pairs({ 
                ContainerFrame3Background1Slot,
                ContainerFrame3BackgroundBottom,
                ContainerFrame3BackgroundMiddle1,
                ContainerFrame3BackgroundMiddle2,
                ContainerFrame3BackgroundTop,
                ContainerFrame3BackgroundPortrait,
             }) do
                ColorizationFrameFunction(v)
            end
            -- ContainerFrame4
            for i, v in pairs({ 
                ContainerFrame4Background1Slot,
                ContainerFrame4BackgroundBottom,
                ContainerFrame4BackgroundMiddle1,
                ContainerFrame4BackgroundMiddle2,
                ContainerFrame4BackgroundTop,
                ContainerFrame4BackgroundPortrait,
             }) do
                ColorizationFrameFunction(v)
            end
            -- ContainerFrame5
            for i, v in pairs({ 
                ContainerFrame5Background1Slot,
                ContainerFrame5BackgroundBottom,
                ContainerFrame5BackgroundMiddle1,
                ContainerFrame5BackgroundMiddle2,
                ContainerFrame5BackgroundTop,
                ContainerFrame5BackgroundPortrait,
              }) do
                ColorizationFrameFunction(v)
            end
            -- SpellBook
            --[[
            for i, v in pairs({ 
                PlayerSpellsFrame.NineSlice.TopEdge,
                PlayerSpellsFrame.NineSlice.RightEdge,
                PlayerSpellsFrame.NineSlice.LeftEdge,
                PlayerSpellsFrame.NineSlice.TopEdge,
                PlayerSpellsFrame.NineSlice.BottomEdge,
                PlayerSpellsFrame.NineSlice.PortraitFrame,
                PlayerSpellsFrame.NineSlice.TopRightCorner,
                PlayerSpellsFrame.NineSlice.TopLeftCorner,
                PlayerSpellsFrame.NineSlice.BottomLeftCorner,
                PlayerSpellsFrame.NineSlice.BottomRightCorner,
                SpellBookFrameTabButton1Left,
                SpellBookFrameTabButton1LeftDisabled,
                SpellBookFrameTabButton1Middle,
                SpellBookFrameTabButton1MiddleDisabled,
                SpellBookFrameTabButton1Right,
                SpellBookFrameTabButton1RightDisabled,
                SpellBookFrameTabButton2Left,
                SpellBookFrameTabButton2LeftDisabled,
                SpellBookFrameTabButton2Middle,
                SpellBookFrameTabButton2MiddleDisabled,
                SpellBookFrameTabButton2Right,
                SpellBookFrameTabButton2RightDisabled, 
            }) do
                ColorizationFrameFunction(v)
            end
            for i, v in pairs({
                SpellBookFrameInset.NineSlice.BottomLeftCorner,
                SpellBookFrameInset.NineSlice.BottomRightCorner,
                SpellBookFrameInset.NineSlice.BottomEdge, 
            }) do
                v:SetAlpha(0)
            end
            --]]
        end
    end

    ----------------------------------------------------------------------
    -------------- Frames that need a load to work properly --------------
    ----------------------------------------------------------------------

    -- Specialization
    if addon == "Blizzard_TalentUI" and GetWoWVersion > 50600 then
        for i, v in pairs({ 
            PlayerTalentFrame.NineSlice.TopEdge,
            PlayerTalentFrame.NineSlice.RightEdge,
            PlayerTalentFrame.NineSlice.BottomEdge,
            PlayerTalentFrame.NineSlice.LeftEdge,
            PlayerTalentFrame.NineSlice.TopRightCorner,
            PlayerTalentFrame.NineSlice.TopLeftCorner,
            PlayerTalentFrame.NineSlice.BottomLeftCorner,
            PlayerTalentFrame.NineSlice.BottomRightCorner,
            PlayerTalentFrameTab1Left,
            PlayerTalentFrameTab1LeftDisabled,
            PlayerTalentFrameTab1Middle,
            PlayerTalentFrameTab1MiddleDisabled,
            PlayerTalentFrameTab1Right,
            PlayerTalentFrameTab1RightDisabled,
            PlayerTalentFrameTab2Left,
            PlayerTalentFrameTab2LeftDisabled,
            PlayerTalentFrameTab2Middle,
            PlayerTalentFrameTab2MiddleDisabled,
            PlayerTalentFrameTab2Right,
            PlayerTalentFrameTab2RightDisabled,
            PlayerTalentFrameTab3Left,
            PlayerTalentFrameTab3LeftDisabled,
            PlayerTalentFrameTab3Middle,
            PlayerTalentFrameTab32MiddleDisabled,
            PlayerTalentFrameTab3Right,
            PlayerTalentFrameTab3RightDisabled, 
        }) do
            ColorizationFrameFunction(v)
        end
        for i, v in pairs({
            PlayerTalentFrameInset.NineSlice,
            PlayerTalentFrameInset.NineSlice.BottomLeftCorner,
            PlayerTalentFrameInset.NineSlice.BottomRightCorner,
            PlayerTalentFrameInset.NineSlice.BottomEdge,
            PlayerTalentFrameInset.NineSlice.LeftEdge,
        }) do
            v:SetAlpha(0)
        end
    end

    -- Collections
    if addon == "Blizzard_Collections" and GetWoWVersion > 50600 then
        for i, v in pairs({ 
            CollectionsJournal.NineSlice.TopEdge,
            CollectionsJournal.NineSlice.TopRightCorner,
            CollectionsJournal.NineSlice.RightEdge,
            CollectionsJournal.NineSlice.BottomRightCorner,
            CollectionsJournal.NineSlice.BottomEdge,
            CollectionsJournal.NineSlice.BottomLeftCorner,
            CollectionsJournal.NineSlice.LeftEdge,
            CollectionsJournal.NineSlice.TopLeftCorner,
            CollectionsJournalTab1Left,
            CollectionsJournalTab1LeftDisabled,
            CollectionsJournalTab1Middle,
            CollectionsJournalTab1MiddleDisabled,
            CollectionsJournalTab1Right,
            CollectionsJournalTab1RightDisabled,
            CollectionsJournalTab2Left,
            CollectionsJournalTab2LeftDisabled,
            CollectionsJournalTab2Middle,
            CollectionsJournalTab2MiddleDisabled,
            CollectionsJournalTab2Right,
            CollectionsJournalTab2RightDisabled,
            CollectionsJournalTab3Left,
            CollectionsJournalTab3LeftDisabled,
            CollectionsJournalTab3Middle,
            CollectionsJournalTab3MiddleDisabled,
            CollectionsJournalTab3Right,
            CollectionsJournalTab3RightDisabled,
            CollectionsJournalTab4Left,
            CollectionsJournalTab4LeftDisabled,
            CollectionsJournalTab4Middle,
            CollectionsJournalTab4MiddleDisabled,
            CollectionsJournalTab4Right,
            CollectionsJournalTab4RightDisabled,
            CollectionsJournalTab5Left,
            CollectionsJournalTab5LeftDisabled,
            CollectionsJournalTab5Middle,
            CollectionsJournalTab5MiddleDisabled,
            CollectionsJournalTab5Right,
            CollectionsJournalTab5RightDisabled,
            MountJournal.BottomLeftInset.NineSlice.BottomRightCorner, 
        }) do
            ColorizationFrameFunction(v)
        end
        for i, v in pairs({
            MountJournal.LeftInset.NineSlice.BottomLeftCorner,
            MountJournal.LeftInset.NineSlice.BottomRightCorner,
            MountJournal.LeftInset.NineSlice.BottomEdge,
            MountJournal.LeftInset.NineSlice.LeftEdge,
            MountJournal.RightInset.NineSlice.BottomLeftCorner,
            MountJournal.RightInset.NineSlice.BottomRightCorner,
            MountJournal.RightInset.NineSlice.BottomEdge,
            MountJournal.RightInset.NineSlice.RightEdge,
            MountJournal.BottomLeftInset.NineSlice.BottomLeftCorner,
            MountJournal.BottomLeftInset.NineSlice.BottomRightCorner,
            MountJournal.BottomLeftInset.NineSlice.BottomEdge,
            MountJournal.BottomLeftInset.NineSlice.LeftEdge,
            PetJournalRightInset.NineSlice.BottomLeftCorner,
            PetJournalRightInset.NineSlice.BottomRightCorner,
            PetJournalRightInset.NineSlice.BottomEdge,
            PetJournalRightInset.NineSlice.RightEdge,
            PetJournalLeftInset.NineSlice.BottomLeftCorner,
            PetJournalLeftInset.NineSlice.BottomRightCorner,
            PetJournalLeftInset.NineSlice.BottomEdge,
            PetJournalLeftInset.NineSlice.LeftEdge,
            ToyBox.iconsFrame.NineSlice.BottomLeftCorner,
            ToyBox.iconsFrame.NineSlice.BottomRightCorner,
            ToyBox.iconsFrame.NineSlice.BottomEdge,
            ToyBox.iconsFrame.NineSlice.LeftEdge,
            HeirloomsJournal.iconsFrame.NineSlice.BottomLeftCorner,
            HeirloomsJournal.iconsFrame.NineSlice.BottomRightCorner,
            HeirloomsJournal.iconsFrame.NineSlice.BottomEdge,
            HeirloomsJournal.iconsFrame.NineSlice.LeftEdge,    
        }) do
            v:SetAlpha(0)
        end
    end

    -- AdventureGuide
    if addon == "Blizzard_EncounterJournal" and GetWoWVersion > 50600 then
        for i, v in pairs({ 
            EncounterJournal.NineSlice.TopEdge,
            EncounterJournal.NineSlice.RightEdge,
            EncounterJournal.NineSlice.BottomEdge,
            EncounterJournal.NineSlice.LeftEdge,
            EncounterJournal.NineSlice.TopRightCorner,
            EncounterJournal.NineSlice.TopLeftCorner,
            EncounterJournal.NineSlice.BottomLeftCorner,
            EncounterJournal.NineSlice.BottomRightCorner, 
        }) do
            ColorizationFrameFunction(v)
        end
        for i, v in pairs({
            EncounterJournalInset.NineSlice,
            EncounterJournalInset.NineSlice.BottomLeftCorner,
            EncounterJournalInset.NineSlice.BottomRightCorner,
            EncounterJournalInset.NineSlice.BottomEdge,
            EncounterJournalInset.NineSlice.LeftEdge, 
        }) do
            v:SetAlpha(0)
        end
    end

    -- Communities
    if addon == "Blizzard_Communities" and GetWoWVersion > 50600 then
        for i, v in pairs({ 
            CommunitiesFrame.NineSlice.TopEdge,
            CommunitiesFrame.NineSlice.RightEdge,
            CommunitiesFrame.NineSlice.BottomEdge,
            CommunitiesFrame.NineSlice.LeftEdge,
            CommunitiesFrame.NineSlice.TopRightCorner,
            CommunitiesFrame.NineSlice.TopLeftCorner,
            CommunitiesFrame.NineSlice.BottomLeftCorner,
            CommunitiesFrame.NineSlice.BottomRightCorner,
            CommunitiesFrameCommunitiesList.InsetFrame.NineSlice.BottomEdge,
            CommunitiesFrame.GuildFinderFrame.InsetFrame.NineSlice.BottomEdge,
            CommunitiesFrame.GuildMemberDetailFrame.Border.TopEdge,
            CommunitiesFrame.GuildMemberDetailFrame.Border.RightEdge,
            CommunitiesFrame.GuildMemberDetailFrame.Border.BottomEdge,
            CommunitiesFrame.GuildMemberDetailFrame.Border.LeftEdge,
            CommunitiesFrame.GuildMemberDetailFrame.Border.TopRightCorner,
            CommunitiesFrame.GuildMemberDetailFrame.Border.TopLeftCorner,
            CommunitiesFrame.GuildMemberDetailFrame.Border.BottomLeftCorner,
            CommunitiesFrame.GuildMemberDetailFrame.Border.BottomRightCorner,
            CommunitiesFrame.ClubFinderInvitationFrame.WarningDialog.BG.TopEdge,
            CommunitiesFrame.ClubFinderInvitationFrame.WarningDialog.BG.RightEdge,
            CommunitiesFrame.ClubFinderInvitationFrame.WarningDialog.BG.LeftEdge,
            CommunitiesFrame.ClubFinderInvitationFrame.WarningDialog.BG.BottomEdge,
            CommunitiesFrame.ClubFinderInvitationFrame.WarningDialog.BG.TopRightCorner,
            CommunitiesFrame.ClubFinderInvitationFrame.WarningDialog.BG.TopLeftCorner,
            CommunitiesFrame.ClubFinderInvitationFrame.WarningDialog.BG.BottomLeftCorner,
            CommunitiesFrame.ClubFinderInvitationFrame.WarningDialog.BG.BottomRightCorner,
            ClubFinderGuildFinderFrame.RequestToJoinFrame.BG.TopEdge,
            ClubFinderGuildFinderFrame.RequestToJoinFrame.BG.RightEdge,
            ClubFinderGuildFinderFrame.RequestToJoinFrame.BG.LeftEdge,
            ClubFinderGuildFinderFrame.RequestToJoinFrame.BG.BottomEdge,
            ClubFinderGuildFinderFrame.RequestToJoinFrame.BG.TopRightCorner,
            ClubFinderGuildFinderFrame.RequestToJoinFrame.BG.TopLeftCorner,
            ClubFinderGuildFinderFrame.RequestToJoinFrame.BG.BottomLeftCorner,
            ClubFinderGuildFinderFrame.RequestToJoinFrame.BG.BottomRightCorner,
            ClubFinderCommunityAndGuildFinderFrame.RequestToJoinFrame.BG.TopEdge,
            ClubFinderCommunityAndGuildFinderFrame.RequestToJoinFrame.BG.RightEdge,
            ClubFinderCommunityAndGuildFinderFrame.RequestToJoinFrame.BG.LeftEdge,
            ClubFinderCommunityAndGuildFinderFrame.RequestToJoinFrame.BG.BottomEdge,
            ClubFinderCommunityAndGuildFinderFrame.RequestToJoinFrame.BG.TopRightCorner,
            ClubFinderCommunityAndGuildFinderFrame.RequestToJoinFrame.BG.TopLeftCorner,
            ClubFinderCommunityAndGuildFinderFrame.RequestToJoinFrame.BG.BottomLeftCorner,
            ClubFinderCommunityAndGuildFinderFrame.RequestToJoinFrame.BG.BottomRightCorner,
            CommunitiesFrame.RecruitmentDialog.BG.TopEdge,
            CommunitiesFrame.RecruitmentDialog.BG.RightEdge,
            CommunitiesFrame.RecruitmentDialog.BG.LeftEdge,
            CommunitiesFrame.RecruitmentDialog.BG.BottomEdge,
            CommunitiesFrame.RecruitmentDialog.BG.TopRightCorner,
            CommunitiesFrame.RecruitmentDialog.BG.TopLeftCorner,
            CommunitiesFrame.RecruitmentDialog.BG.BottomLeftCorner,
            CommunitiesFrame.RecruitmentDialog.BG.BottomRightCorner, 
        }) do
            ColorizationFrameFunction(v)
        end
        for i, v in pairs ({
            CommunitiesFrameCommunitiesList.InsetFrame.NineSlice.BottomLeftCorner,
            CommunitiesFrameCommunitiesList.InsetFrame.NineSlice.BottomRightCorner,
            CommunitiesFrameCommunitiesList.InsetFrame.NineSlice.BottomEdge,
            CommunitiesFrame.GuildFinderFrame.InsetFrame.NineSlice.BottomLeftCorner,
            CommunitiesFrame.GuildFinderFrame.InsetFrame.NineSlice.BottomRightCorner,
            CommunitiesFrame.GuildFinderFrame.InsetFrame.NineSlice.BottomEdge,
            ClubFinderGuildFinderFrame.DisabledFrame.NineSlice.BottomLeftCorner,
            ClubFinderGuildFinderFrame.DisabledFrame.NineSlice.BottomRightCorner,
            ClubFinderGuildFinderFrame.DisabledFrame.NineSlice.BottomEdge,
            ClubFinderGuildFinderFrame.InsetFrame.NineSlice.BottomEdge,
            ClubFinderCommunityAndGuildFinderFrame.InsetFrame.NineSlice.BottomLeftCorner,
            ClubFinderCommunityAndGuildFinderFrame.InsetFrame.NineSlice.BottomRightCorner,
            ClubFinderCommunityAndGuildFinderFrame.InsetFrame.NineSlice.BottomEdge,
            CommunitiesFrameCommunitiesList.InsetFrame.NineSlice.BottomLeftCorner,
            CommunitiesFrameCommunitiesList.InsetFrame.NineSlice.BottomRightCorner,
            CommunitiesFrameCommunitiesList.InsetFrame.NineSlice.BottomEdge,
            CommunitiesFrame.MemberList.InsetFrame.NineSlice.BottomLeftCorner,
            CommunitiesFrame.MemberList.InsetFrame.NineSlice.BottomRightCorner,
            CommunitiesFrame.MemberList.InsetFrame.NineSlice.BottomEdge,
            CommunitiesFrameInset.NineSlice,
            CommunitiesFrameInset.NineSlice.BottomLeftCorner,
            CommunitiesFrameInset.NineSlice.BottomRightCorner,
            CommunitiesFrameInset.NineSlice.BottomEdge,
            CommunitiesFrameInset.NineSlice.LeftEdge, 
        }) do
            v:SetAlpha(0)
        end
    end

    -- Macro
    if addon == "Blizzard_MacroUI" and GetWoWVersion > 50600 then
        for i, v in pairs({ 
            MacroFrame.NineSlice.TopEdge,
            MacroFrame.NineSlice.RightEdge,
            MacroFrame.NineSlice.BottomEdge,
            MacroFrame.NineSlice.LeftEdge,
            MacroFrame.NineSlice.TopRightCorner,
            MacroFrame.NineSlice.TopLeftCorner,
            MacroFrame.NineSlice.BottomLeftCorner,
            MacroFrame.NineSlice.BottomRightCorner, 
        }) do
            ColorizationFrameFunction(v)
        end
        for i, v in pairs({
            MacroFrameInset.NineSlice,
            MacroFrameInset.NineSlice.BottomLeftCorner,
            MacroFrameInset.NineSlice.BottomRightCorner,
            MacroFrameInset.NineSlice.BottomEdge,
        MacroFrameInset.NineSlice.Left, }) do
            v:SetAlpha(0)
        end
    end

    -- AuctionHouse
    if addon == "Blizzard_AuctionHouseUI" and GetWoWVersion > 50600 then
        for i, v in pairs({ 
            AuctionHouseFrame.NineSlice.TopEdge,
            AuctionHouseFrame.NineSlice.RightEdge,
            AuctionHouseFrame.NineSlice.BottomEdge,
            AuctionHouseFrame.NineSlice.LeftEdge,
            AuctionHouseFrame.NineSlice.TopRightCorner,
            AuctionHouseFrame.NineSlice.TopLeftCorner,
            AuctionHouseFrame.NineSlice.BottomLeftCorner,
            AuctionHouseFrame.NineSlice.BottomRightCorner,
            AuctionHouseFrame.NineSlice.BottomEdge,
            AuctionHouseFrameBuyTabLeft,
            AuctionHouseFrameBuyTabLeftDisabled,
            AuctionHouseFrameBuyTabMiddle,
            AuctionHouseFrameBuyTabMiddleDisabled,
            AuctionHouseFrameBuyTabRight,
            AuctionHouseFrameBuyTabRightDisabled,
            AuctionHouseFrameSellTabLeft,
            AuctionHouseFrameSellTabLeftDisabled,
            AuctionHouseFrameSellTabMiddle,
            AuctionHouseFrameSellTabMiddleDisabled,
            AuctionHouseFrameSellTabRight,
            AuctionHouseFrameSellTabRightDisabled,
            AuctionHouseFrameAuctionsTabLeft,
            AuctionHouseFrameAuctionsTabLeftDisabled,
            AuctionHouseFrameAuctionsTabMiddle,
            AuctionHouseFrameAuctionsTabMiddleDisabled,
            AuctionHouseFrameAuctionsTabRight,
            AuctionHouseFrameAuctionsTabRightDisabled,
            AuctionHouseFrame.WoWTokenResults.GameTimeTutorial.NineSlice.TopEdge,
            AuctionHouseFrame.WoWTokenResults.GameTimeTutorial.NineSlice.RightEdge,
            AuctionHouseFrame.WoWTokenResults.GameTimeTutorial.NineSlice.BottomEdge,
            AuctionHouseFrame.WoWTokenResults.GameTimeTutorial.NineSlice.LeftEdge,
            AuctionHouseFrame.WoWTokenResults.GameTimeTutorial.NineSlice.TopRightCorner,
            AuctionHouseFrame.WoWTokenResults.GameTimeTutorial.NineSlice.TopLeftCorner,
            AuctionHouseFrame.WoWTokenResults.GameTimeTutorial.NineSlice.BottomLeftCorner,
            AuctionHouseFrame.WoWTokenResults.GameTimeTutorial.NineSlice.BottomRightCorner,
            AuctionHouseFrame.WoWTokenResults.GameTimeTutorial.NineSlice.BottomEdge,
            AuctionHouseFrame.BuyDialog.Border.TopEdge,
            AuctionHouseFrame.BuyDialog.Border.RightEdge,
            AuctionHouseFrame.BuyDialog.Border.BottomEdge,
            AuctionHouseFrame.BuyDialog.Border.LeftEdge,
            AuctionHouseFrame.BuyDialog.Border.TopRightCorner,
            AuctionHouseFrame.BuyDialog.Border.TopLeftCorner,
            AuctionHouseFrame.BuyDialog.Border.BottomLeftCorner,
            AuctionHouseFrame.BuyDialog.Border.BottomRightCorner,
            AuctionHouseFrame.BuyDialog.Border.BottomEdge, 
        }) do
            ColorizationFrameFunction(v)
        end
        for i, v in pairs({
            AuctionHouseFrame.CategoriesList.NineSlice.BottomLeftCorner,
            AuctionHouseFrame.CategoriesList.NineSlice.BottomRightCorner,
            AuctionHouseFrame.CategoriesList.NineSlice.BottomEdge,
            AuctionHouseFrame.CategoriesList.NineSlice.LeftEdge,
            AuctionHouseFrame.ItemBuyFrame.ItemDisplay.NineSlice.BottomLeftCorner,
            AuctionHouseFrame.ItemBuyFrame.ItemDisplay.NineSlice.BottomRightCorner,
            AuctionHouseFrame.ItemBuyFrame.ItemDisplay.NineSlice.BottomEdge,
            AuctionHouseFrame.ItemBuyFrame.ItemDisplay.NineSlice.LeftEdge,
            AuctionHouseFrame.ItemBuyFrame.ItemList.NineSlice.BottomLeftCorner,
            AuctionHouseFrame.ItemBuyFrame.ItemList.NineSlice.BottomRightCorner,
            AuctionHouseFrame.ItemBuyFrame.ItemList.NineSlice.BottomEdge,
            AuctionHouseFrame.ItemBuyFrame.ItemList.NineSlice.LeftEdge,
            AuctionHouseFrame.ItemSellFrame.NineSlice.BottomLeftCorner,
            AuctionHouseFrame.ItemSellFrame.NineSlice.BottomRightCorner,
            AuctionHouseFrame.ItemSellFrame.NineSlice.BottomEdge,
            AuctionHouseFrame.ItemSellFrame.NineSlice.LeftEdge,
            AuctionHouseFrame.ItemSellList.NineSlice.BottomLeftCorner,
            AuctionHouseFrame.ItemSellList.NineSlice.BottomRightCorner,
            AuctionHouseFrame.ItemSellList.NineSlice.BottomEdge,
            AuctionHouseFrame.ItemSellList.NineSlice.LeftEdge,
            AuctionHouseFrameAuctionsFrame.SummaryList.NineSlice.BottomLeftCorner,
            AuctionHouseFrameAuctionsFrame.SummaryList.NineSlice.BottomRightCorner,
            AuctionHouseFrameAuctionsFrame.SummaryList.NineSlice.BottomEdge,
            AuctionHouseFrameAuctionsFrame.SummaryList.NineSlice.LeftEdge,
            AuctionHouseFrameAuctionsFrame.AllAuctionsList.NineSlice.BottomLeftCorner,
            AuctionHouseFrameAuctionsFrame.AllAuctionsList.NineSlice.BottomRightCorner,
            AuctionHouseFrameAuctionsFrame.AllAuctionsList.NineSlice.BottomEdge,
            AuctionHouseFrameAuctionsFrame.AllAuctionsList.NineSlice.LeftEdge, 
        }) do
            v:SetAlpha(0)
        end
    end

    -- FlightMap
    if addon == "Blizzard_FlightMap" and GetWoWVersion > 50600 then
        for i, v in pairs({ 
            FlightMapFrame.BorderFrame.NineSlice.TopEdge,
            FlightMapFrame.BorderFrame.NineSlice.RightEdge,
            FlightMapFrame.BorderFrame.NineSlice.BottomEdge,
            FlightMapFrame.BorderFrame.NineSlice.LeftEdge,
            FlightMapFrame.BorderFrame.NineSlice.TopRightCorner,
            FlightMapFrame.BorderFrame.NineSlice.TopLeftCorner,
            FlightMapFrame.BorderFrame.NineSlice.BottomLeftCorner,
            FlightMapFrame.BorderFrame.NineSlice.BottomRightCorner,    
        }) do
            ColorizationFrameFunction(v)
        end
    end

    -- TradeSkill
    if addon == "Blizzard_TradeSkillUI" and GetWoWVersion > 50600 then
        for i, v in pairs({ 
            TradeSkillFrame.NineSlice.TopEdge,
            TradeSkillFrame.NineSlice.RightEdge,
            TradeSkillFrame.NineSlice.BottomEdge,
            TradeSkillFrame.NineSlice.LeftEdge,
            TradeSkillFrame.NineSlice.TopRightCorner,
            TradeSkillFrame.NineSlice.TopLeftCorner,
            TradeSkillFrame.NineSlice.BottomLeftCorner,
            TradeSkillFrame.NineSlice.BottomRightCorner, 
        }) do
            ColorizationFrameFunction(v)
        end
        for i, v in pairs({
            TradeSkillFrame.RecipeInset.NineSlice,
            TradeSkillFrame.RecipeInset.NineSlice.BottomLeftCorner,
            TradeSkillFrame.RecipeInset.NineSlice.BottomRightCorner,
            TradeSkillFrame.RecipeInset.NineSlice.BottomEdge,
            TradeSkillFrame.RecipeInset.NineSlice.LeftEdge,
            TradeSkillFrame.DetailsInset.NineSlice,
            TradeSkillFrame.DetailsInset.NineSlice.BottomLeftCorner,
            TradeSkillFrame.DetailsInset.NineSlice.BottomRightCorner,
            TradeSkillFrame.DetailsInset.NineSlice.LeftEdge, 
        }) do
            v:SetAlpha(0)
        end
    end

    -- Inspect
    if addon == "Blizzard_InspectUI" and GetWoWVersion > 50600 then
        for i, v in pairs({ 
            InspectFrame.NineSlice.TopEdge,
            InspectFrame.NineSlice.RightEdge,
            InspectFrame.NineSlice.BottomEdge,
            InspectFrame.NineSlice.LeftEdge,
            InspectFrame.NineSlice.TopRightCorner,
            InspectFrame.NineSlice.TopLeftCorner,
            InspectFrame.NineSlice.BottomLeftCorner,
            InspectFrame.NineSlice.BottomRightCorner,
            InspectFrameInset.NineSlice.BottomEdge,
            InspectFrameTab1Left,
            InspectFrameTab1LeftDisabled,
            InspectFrameTab1Middle,
            InspectFrameTab1MiddleDisabled,
            InspectFrameTab1Right,
            InspectFrameTab1RightDisabled,
            InspectFrameTab2Left,
            InspectFrameTab2LeftDisabled,
            InspectFrameTab2Middle,
            InspectFrameTab2MiddleDisabled,
            InspectFrameTab2Right,
            InspectFrameTab2RightDisabled,
            InspectFrameTab3Left,
            InspectFrameTab3LeftDisabled,
            InspectFrameTab3Middle,
            InspectFrameTab3MiddleDisabled,
            InspectFrameTab3Right,
            InspectFrameTab3RightDisabled,
            InspectFrameTab4Left,
            InspectFrameTab4LeftDisabled,
            InspectFrameTab4Middle,
            InspectFrameTab4MiddleDisabled,
            InspectFrameTab4Right,
            InspectFrameTab4RightDisabled, 
        }) do
            ColorizationFrameFunction(v)
        end
        for i, v in pairs({
            InspectFrameInset.NineSlice,
            InspectFrameInset.NineSlice.BottomLeftCorner,
            InspectFrameInset.NineSlice.BottomRightCorner,
            InspectFrameInset.NineSlice.BottomEdge,
            InspectFrameInset.NineSlice.LeftEdge,
            InspectModelFrameBorderBottom,
            InspectModelFrameBorderBottom2,
            InspectModelFrameBorderLeft,
            InspectModelFrameBorderRight,
            InspectModelFrameBorderTop,
        }) do
            v:SetAlpha(0)
        end
    end

    -- Wardrobe/Transmogrify
    if addon == "Blizzard_Collections" and GetWoWVersion > 50600 then
        for i, v in pairs({ 
            WardrobeFrame.NineSlice.TopEdge,
            WardrobeFrame.NineSlice.RightEdge,
            WardrobeFrame.NineSlice.BottomEdge,
            WardrobeFrame.NineSlice.LeftEdge,
            WardrobeFrame.NineSlice.TopRightCorner,
            WardrobeFrame.NineSlice.TopLeftCorner,
            WardrobeFrame.NineSlice.BottomLeftCorner,
            WardrobeFrame.NineSlice.BottomRightCorner, 
        }) do
            ColorizationFrameFunction(v)
        end
        for i, v in pairs({
            WardrobeCollectionFrame.ItemsCollectionFrame.NineSlice.BottomLeftCorner,
            WardrobeCollectionFrame.ItemsCollectionFrame.NineSlice.BottomRightCorner,
            WardrobeCollectionFrame.ItemsCollectionFrame.NineSlice.BottomEdge,
            WardrobeCollectionFrame.ItemsCollectionFrame.NineSlice.LeftEdge,
            WardrobeTransmogFrame.Inset.NineSlice,
            WardrobeTransmogFrame.Inset.NineSlice.BottomLeftCorner,
            WardrobeTransmogFrame.Inset.NineSlice.BottomRightCorner,
            WardrobeTransmogFrame.Inset.NineSlice.BottomEdge,
            WardrobeTransmogFrame.Inset.NineSlice.LeftEdge, 
        }) do
            v:SetAlpha(0)
        end
    end

    -- ClassTrainer/FlightMaster
    if addon == "Blizzard_TrainerUI" and GetWoWVersion > 50600 then
        for i, v in pairs({ 
            ClassTrainerFrame.NineSlice.TopEdge,
            ClassTrainerFrame.NineSlice.RightEdge,
            ClassTrainerFrame.NineSlice.BottomEdge,
            ClassTrainerFrame.NineSlice.LeftEdge,
            ClassTrainerFrame.NineSlice.TopRightCorner,
            ClassTrainerFrame.NineSlice.TopLeftCorner,
            ClassTrainerFrame.NineSlice.BottomLeftCorner,
            ClassTrainerFrame.NineSlice.BottomRightCorner,
            ClassTrainerFrameInset.NineSlice.BottomEdge, 
        }) do
            ColorizationFrameFunction(v)
        end
        for i, v in pairs({
            ClassTrainerFrameInset.NineSlice,
            ClassTrainerFrameInset.NineSlice.BottomLeftCorner,
            ClassTrainerFrameInset.NineSlice.BottomRightCorner,
            ClassTrainerFrameInset.NineSlice.BottomEdge,
            ClassTrainerFrameInset.NineSlice.LeftEdge, 
        }) do
            v:SetAlpha(0)
        end
    end

    -- Achievement
    if addon == "Blizzard_AchievementUI" and GetWoWVersion >= 30000 then
        for i, v in pairs({ 
            AchievementFrameHeaderRight,
            AchievementFrameHeaderLeft,
            AchievementFrameWoodBorderTopLeft,
            AchievementFrameWoodBorderBottomLeft,
            AchievementFrameWoodBorderTopRight,
            AchievementFrameWoodBorderBottomRight,
            AchievementFrameMetalBorderBottom,
            AchievementFrameMetalBorderBottomLeft,
            AchievementFrameMetalBorderBottomRight,
            AchievementFrameMetalBorderLeft,
            AchievementFrameMetalBorderRight,
            AchievementFrameMetalBorderTop,
            AchievementFrameMetalBorderTopLeft,
            AchievementFrameMetalBorderTopRight, 
        }) do
            ColorizationFrameFunction(v)
        end
    end

    -- Azerite
    if addon == "Blizzard_AzeriteUI" and GetWoWVersion > 50600 then
        for i, v in pairs({ 
            AzeriteEmpoweredItemUI.BorderFrame.NineSlice.TopEdge,
            AzeriteEmpoweredItemUI.BorderFrame.NineSlice.RightEdge,
            AzeriteEmpoweredItemUI.BorderFrame.NineSlice.BottomEdge,
            AzeriteEmpoweredItemUI.BorderFrame.NineSlice.LeftEdge,
            AzeriteEmpoweredItemUI.BorderFrame.NineSlice.TopRightCorner,
            AzeriteEmpoweredItemUI.BorderFrame.NineSlice.TopLeftCorner,
            AzeriteEmpoweredItemUI.BorderFrame.NineSlice.BottomLeftCorner,
            AzeriteEmpoweredItemUI.BorderFrame.NineSlice.BottomRightCorner, 
        }) do
            ColorizationFrameFunction(v)
        end
    end

    -- AlliedRaces
    if addon == "Blizzard_AlliedRacesUI" and GetWoWVersion > 50600 then
        for i, v in pairs({ 
            AlliedRacesFrame.NineSlice.TopEdge,
            AlliedRacesFrame.NineSlice.RightEdge,
            AlliedRacesFrame.NineSlice.BottomEdge,
            AlliedRacesFrame.NineSlice.LeftEdge,
            AlliedRacesFrame.NineSlice.TopRightCorner,
            AlliedRacesFrame.NineSlice.TopLeftCorner,
            AlliedRacesFrame.NineSlice.BottomLeftCorner,
            AlliedRacesFrame.NineSlice.BottomRightCorner, 
        }) do
            ColorizationFrameFunction(v)
        end
        for i, v in pairs({
            AlliedRacesFrameInset.NineSlice,
            AlliedRacesFrameInset.NineSlice.BottomLeftCorner,
            AlliedRacesFrameInset.NineSlice.BottomRightCorner,
            AlliedRacesFrameInset.NineSlice.BottomEdge,
            AlliedRacesFrameInset.NineSlice.LeftEdge, 
        }) do
            v:SetAlpha(0)
        end
    end

    -- Inslands
    if addon == "Blizzard_IslandsQueueUI" and GetWoWVersion > 50600 then
        for i, v in pairs({ 
            IslandsQueueFrame.NineSlice.TopEdge,
            IslandsQueueFrame.NineSlice.RightEdge,
            IslandsQueueFrame.NineSlice.BottomEdge,
            IslandsQueueFrame.NineSlice.LeftEdge,
            IslandsQueueFrame.NineSlice.TopRightCorner,
            IslandsQueueFrame.NineSlice.TopLeftCorner,
            IslandsQueueFrame.NineSlice.BottomLeftCorner,
            IslandsQueueFrame.NineSlice.BottomRightCorner,
            IslandsQueueFrame.ArtOverlayFrame.PortraitFrame, 
        }) do
            ColorizationFrameFunction(v)
        end
    end

    -- GarrisonCapacitive
    if addon == "Blizzard_GarrisonUI" and GetWoWVersion > 50600 then
        for i, v in pairs({ 
            GarrisonCapacitiveDisplayFrame.NineSlice.TopEdge,
            GarrisonCapacitiveDisplayFrame.NineSlice.RightEdge,
            GarrisonCapacitiveDisplayFrame.NineSlice.BottomEdge,
            GarrisonCapacitiveDisplayFrame.NineSlice.LeftEdge,
            GarrisonCapacitiveDisplayFrame.NineSlice.TopRightCorner,
            GarrisonCapacitiveDisplayFrame.NineSlice.TopLeftCorner,
            GarrisonCapacitiveDisplayFrame.NineSlice.BottomLeftCorner,
            GarrisonCapacitiveDisplayFrame.NineSlice.BottomRightCorner, 
        }) do
            ColorizationFrameFunction(v)
        end
        for i, v in pairs({
            GarrisonCapacitiveDisplayFrameInset.NineSlice,
            GarrisonCapacitiveDisplayFrameInset.NineSlice.BottomLeftCorner,
            GarrisonCapacitiveDisplayFrameInset.NineSlice.BottomRightCorner,
            GarrisonCapacitiveDisplayFrameInset.NineSlice.BottomEdge,
            GarrisonCapacitiveDisplayFrameInset.NineSlice.LeftEdge, 
        }) do
            v:SetAlpha(0)
        end
    end

    -- Calendar
    if addon == "Blizzard_Calendar" and GetWoWVersion >= 30000 then
        for i, v in pairs({ 
            CalendarFrameTopMiddleTexture,
            CalendarFrameRightTopTexture,
            CalendarFrameRightMiddleTexture,
            CalendarFrameRightBottomTexture,
            CalendarFrameBottomRightTexture,
            CalendarFrameBottomMiddleTexture,
            CalendarFrameBottomLeftTexture,
            CalendarFrameLeftMiddleTexture,
            CalendarFrameLeftTopTexture,
            CalendarFrameLeftBottomTexture,
            CalendarFrameTopLeftTexture,
            CalendarFrameTopRightTexture,
            CalendarCreateEventFrame.Header.CenterBG,
            CalendarCreateEventFrame.Header.LeftBG,
            CalendarCreateEventFrame.Header.RightBG,
            CalendarCreateEventFrame.Border.TopEdge,
            CalendarCreateEventFrame.Border.RightEdge,
            CalendarCreateEventFrame.Border.BottomEdge,
            CalendarCreateEventFrame.Border.LeftEdge,
            CalendarCreateEventFrame.Border.TopRightCorner,
            CalendarCreateEventFrame.Border.TopLeftCorner,
            CalendarCreateEventFrame.Border.BottomLeftCorner,
            CalendarCreateEventFrame.Border.BottomRightCorner,
            CalendarViewHolidayFrame.Header.CenterBG,
            CalendarViewHolidayFrame.Header.LeftBG,
            CalendarViewHolidayFrame.Header.RightBG,
            CalendarViewHolidayFrame.Border.TopEdge,
            CalendarViewHolidayFrame.Border.RightEdge,
            CalendarViewHolidayFrame.Border.BottomEdge,
            CalendarViewHolidayFrame.Border.LeftEdge,
            CalendarViewHolidayFrame.Border.TopRightCorner,
            CalendarViewHolidayFrame.Border.TopLeftCorner,
            CalendarViewHolidayFrame.Border.BottomLeftCorner,
            CalendarViewHolidayFrame.Border.BottomRightCorner,
            CalendarEventPickerFrame.Header.CenterBG,
            CalendarEventPickerFrame.Header.LeftBG,
            CalendarEventPickerFrame.Header.RightBG,
            CalendarEventPickerFrame.Border.TopEdge,
            CalendarEventPickerFrame.Border.RightEdge,
            CalendarEventPickerFrame.Border.BottomEdge,
            CalendarEventPickerFrame.Border.LeftEdge,
            CalendarEventPickerFrame.Border.TopRightCorner,
            CalendarEventPickerFrame.Border.TopLeftCorner,
            CalendarEventPickerFrame.Border.BottomLeftCorner,
            CalendarEventPickerFrame.Border.BottomRightCorner, 
        }) do
            ColorizationFrameFunction(v)
        end
    end

    -- AzeriteRespec
    if addon == "Blizzard_AzeriteRespecUI" then
        for i, v in pairs({ 
            AzeriteRespecFrame.NineSlice.TopEdge,
            AzeriteRespecFrame.NineSlice.RightEdge,
            AzeriteRespecFrame.NineSlice.BottomEdge,
            AzeriteRespecFrame.NineSlice.LeftEdge,
            AzeriteRespecFrame.NineSlice.TopRightCorner,
            AzeriteRespecFrame.NineSlice.TopLeftCorner,
            AzeriteRespecFrame.NineSlice.BottomLeftCorner,
            AzeriteRespecFrame.NineSlice.BottomRightCorner, 
        }) do
            ColorizationFrameFunction(v)
        end
    end

    -- ScrappingMachineFrame
    if addon == "Blizzard_ScrappingMachineUI" then
        for i, v in pairs({ 
            ScrappingMachineFrame.NineSlice.TopEdge,
            ScrappingMachineFrame.NineSlice.RightEdge,
            ScrappingMachineFrame.NineSlice.BottomEdge,
            ScrappingMachineFrame.NineSlice.LeftEdge,
            ScrappingMachineFrame.NineSlice.TopRightCorner,
            ScrappingMachineFrame.NineSlice.TopLeftCorner,
            ScrappingMachineFrame.NineSlice.BottomLeftCorner,
            ScrappingMachineFrame.NineSlice.BottomRightCorner, 
        }) do
            ColorizationFrameFunction(v)
        end
    end

    -- TimeManagerFrame
    if addon == "Blizzard_TimeManager" then
        if (GetWoWVersion > 50600) then
            for i, v in pairs({ 
                TimeManagerFrame.NineSlice.TopEdge,
                TimeManagerFrame.NineSlice.RightEdge,
                TimeManagerFrame.NineSlice.BottomEdge,
                TimeManagerFrame.NineSlice.LeftEdge,
                TimeManagerFrame.NineSlice.TopRightCorner,
                TimeManagerFrame.NineSlice.TopLeftCorner,
                TimeManagerFrame.NineSlice.BottomLeftCorner,
                TimeManagerFrame.NineSlice.BottomRightCorner,
                TimeManagerFrameInset.NineSlice.TopEdge,
                TimeManagerFrameInset.NineSlice.RightEdge,
                TimeManagerFrameInset.NineSlice.LeftEdge,
                TimeManagerFrameInset.NineSlice.TopRightCorner,
                TimeManagerFrameInset.NineSlice.TopLeftCorner,
                StopwatchFrameBackgroundLeft, 
            }) do
                ColorizationFrameFunction(v)
            end
            for i, v in pairs({
                TimeManagerFrameInset.NineSlice,
                TimeManagerFrameInset.NineSlice.BottomLeftCorner,
                TimeManagerFrameInset.NineSlice.BottomRightCorner,
                TimeManagerFrameInset.NineSlice.BottomEdge,
                TimeManagerFrameInset.NineSlice.LeftEdge, 
            }) do
                v:SetAlpha(0)
            end    
        end
    end

    -- AzeriteEssenceUI
    if addon == "Blizzard_AzeriteEssenceUI" then
        for i, v in pairs({ 
            AzeriteEssenceUI.NineSlice.TopEdge,
            AzeriteEssenceUI.NineSlice.RightEdge,
            AzeriteEssenceUI.NineSlice.BottomEdge,
            AzeriteEssenceUI.NineSlice.LeftEdge,
            AzeriteEssenceUI.NineSlice.TopRightCorner,
            AzeriteEssenceUI.NineSlice.TopLeftCorner,
            AzeriteEssenceUI.NineSlice.BottomLeftCorner,
            AzeriteEssenceUI.NineSlice.BottomRightCorner,
        }) do
            ColorizationFrameFunction(v)
        end
    end

    -- PvP UI
    if addon == "Blizzard_PVPUI" and GetWoWVersion > 50600 then
        for i, v in pairs({ 
            PVPQueueFrame.HonorInset.NineSlice,
            PVPQueueFrame.HonorInset.NineSlice.BottomLeftCorner,
            PVPQueueFrame.HonorInset.NineSlice.BottomRightCorner,
            PVPQueueFrame.HonorInset.NineSlice.BottomEdge,
            HonorFrame.Inset.NineSlice,
            HonorFrame.Inset.NineSlice.BottomLeftCorner,
            HonorFrame.Inset.NineSlice.BottomRightCorner,
            HonorFrame.Inset.NineSlice.BottomEdge,
            ConquestFrame.Inset.NineSlice,
            ConquestFrame.Inset.NineSlice.BottomLeftCorner,
            ConquestFrame.Inset.NineSlice.BottomRightCorner,
            ConquestFrame.Inset.NineSlice.BottomEdge,
            LFGListFrame.CategorySelection.Inset.NineSlice,
            LFGListFrame.CategorySelection.Inset.NineSlice.BottomLeftCorner,
            LFGListFrame.CategorySelection.Inset.NineSlice.BottomRightCorner,
            LFGListFrame.CategorySelection.Inset.NineSlice.BottomEdge, 
        }) do
            v:SetAlpha(0)
        end
    end

    -- Challenges
    if addon == "Blizzard_ChallengesUI" and GetWoWVersion > 50600 then
        for i, v in pairs({ 
            ChallengesFrameInset.NineSlice,
            ChallengesFrameInset.NineSlice.BottomLeftCorner,
            ChallengesFrameInset.NineSlice.BottomRightCorner,
            ChallengesFrameInset.NineSlice.BottomEdge,
            ChallengesFrameInset.NineSlice.LeftEdge, 
        }) do
            v:SetAlpha(0)
        end
    end
    
    -- Archaeology
    if addon == "Blizzard_ArchaeologyUI" and GetWoWVersion > 50600 then
        for i, v in pairs({ 
            ArchaeologyFrame.NineSlice.TopEdge,
            ArchaeologyFrame.NineSlice.RightEdge,
            ArchaeologyFrame.NineSlice.BottomEdge,
            ArchaeologyFrame.NineSlice.LeftEdge,
            ArchaeologyFrame.NineSlice.TopRightCorner,
            ArchaeologyFrame.NineSlice.TopLeftCorner,
            ArchaeologyFrame.NineSlice.BottomLeftCorner,
            ArchaeologyFrame.NineSlice.BottomRightCorner, 
        }) do
            ColorizationFrameFunction(v)
        end
        for i, v in pairs({
            ArchaeologyFrameInset.NineSlice,
            ArchaeologyFrameInset.NineSlice.BottomLeftCorner,
            ArchaeologyFrameInset.NineSlice.BottomRightCorner,
            ArchaeologyFrameInset.NineSlice.BottomEdge,
            ArchaeologyFrameInset.NineSlice.LeftEdge, 
        }) do
            v:SetAlpha(0)
        end
    end

    -- KeybindOptions (Keybind)
    if addon == "Blizzard_BindingUI" and GetWoWVersion > 50600 then
        for i, v in pairs({ 
            KeyBindingFrame.BG.TopEdge,
            KeyBindingFrame.BG.RightEdge,
            KeyBindingFrame.BG.BottomEdge,
            KeyBindingFrame.BG.LeftEdge,
            KeyBindingFrame.BG.TopRightCorner,
            KeyBindingFrame.BG.TopLeftCorner,
            KeyBindingFrame.BG.BottomLeftCorner,
            KeyBindingFrame.BG.BottomRightCorner,
            KeyBindingFrame.Header.RightBG,
            KeyBindingFrame.Header.CenterBG,
            KeyBindingFrame.Header.LeftBG, 
        }) do
            ColorizationFrameFunction(v)
        end
    end

    -- OrderHallTalent
    if addon == "Blizzard_OrderHallUI" and GetWoWVersion > 50600 then
        for i, v in pairs({ 
            OrderHallTalentFrame.NineSlice.TopEdge,
            OrderHallTalentFrame.NineSlice.RightEdge,
            OrderHallTalentFrame.NineSlice.BottomEdge,
            OrderHallTalentFrame.NineSlice.LeftEdge,
            OrderHallTalentFrame.NineSlice.TopRightCorner,
            OrderHallTalentFrame.NineSlice.TopLeftCorner,
            OrderHallTalentFrame.NineSlice.BottomLeftCorner,
            OrderHallTalentFrame.NineSlice.BottomRightCorner, 
        }) do
            ColorizationFrameFunction(v)
        end
    end

    -- GarrisonRecruiterFrame
    if addon == "Blizzard_GarrisonUI" and GetWoWVersion > 50600 then
        for i, v in pairs({
            GarrisonRecruiterFrame.NineSlice.TopEdge,
            GarrisonRecruiterFrame.NineSlice.RightEdge,
            GarrisonRecruiterFrame.NineSlice.BottomEdge,
            GarrisonRecruiterFrame.NineSlice.LeftEdge,
            GarrisonRecruiterFrame.NineSlice.TopRightCorner,
            GarrisonRecruiterFrame.NineSlice.TopLeftCorner,
            GarrisonRecruiterFrame.NineSlice.BottomLeftCorner,
            GarrisonRecruiterFrame.NineSlice.BottomRightCorner,
            GarrisonRecruitSelectFrame.TopBorder,
            GarrisonRecruitSelectFrame.RightBorder,
            GarrisonRecruitSelectFrame.TopRightCorner,
            GarrisonRecruitSelectFrame.BottomRightCorner,
            GarrisonRecruitSelectFrame.BottomBorder,
            GarrisonRecruitSelectFrame.BottomLeftCorner,
            GarrisonRecruitSelectFrame.LeftBorder,
            GarrisonRecruitSelectFrame.TopLeftCorner, 
        }) do
            ColorizationFrameFunction(v)
        end
    end

    -- ChromieTimeFrame
    if addon == "Blizzard_ChromieTimeUI" and GetWoWVersion > 50600 then
        for i, v in pairs({
            ChromieTimeFrame.NineSlice.TopEdge,
            ChromieTimeFrame.NineSlice.RightEdge,
            ChromieTimeFrame.NineSlice.BottomEdge,
            ChromieTimeFrame.NineSlice.LeftEdge,
            ChromieTimeFrame.NineSlice.TopRightCorner,
            ChromieTimeFrame.NineSlice.TopLeftCorner,
            ChromieTimeFrame.NineSlice.BottomLeftCorner,
            ChromieTimeFrame.NineSlice.BottomRightCorner, 
        }) do
            ColorizationFrameFunction(v)
        end
    end

    -- GuideFrame
    if addon == "Blizzard_NewPlayerExperienceGuide" and GetWoWVersion > 50600 then
        for i, v in pairs({
            GuideFrame.NineSlice.TopEdge,
            GuideFrame.NineSlice.RightEdge,
            GuideFrame.NineSlice.BottomEdge,
            GuideFrame.NineSlice.LeftEdge,
            GuideFrame.NineSlice.TopRightCorner,
            GuideFrame.NineSlice.TopLeftCorner,
            GuideFrame.NineSlice.BottomLeftCorner,
            GuideFrame.NineSlice.BottomRightCorner, 
        }) do
            ColorizationFrameFunction(v)
        end
    end

    -- ItemSocketingFrame
    if addon == "Blizzard_ItemSocketingUI" and GetWoWVersion > 50600 then
        for i, v in pairs({
            ItemSocketingFrame.NineSlice.TopEdge,
            ItemSocketingFrame.NineSlice.RightEdge,
            ItemSocketingFrame.NineSlice.BottomEdge,
            ItemSocketingFrame.NineSlice.LeftEdge,
            ItemSocketingFrame.NineSlice.TopRightCorner,
            ItemSocketingFrame.NineSlice.TopLeftCorner,
            ItemSocketingFrame.NineSlice.BottomLeftCorner,
            ItemSocketingFrame.NineSlice.BottomRightCorner, 
        }) do
            ColorizationFrameFunction(v)
        end
    end

    -- ItemUpgrade
    if addon == "Blizzard_ItemUpgradeUI" and GetWoWVersion > 50600 then
        for i, v in pairs({
            ItemUpgradeFrame.NineSlice.TopEdge,
            ItemUpgradeFrame.NineSlice.RightEdge,
            ItemUpgradeFrame.NineSlice.BottomEdge,
            ItemUpgradeFrame.NineSlice.LeftEdge,
            ItemUpgradeFrame.NineSlice.TopRightCorner,
            ItemUpgradeFrame.NineSlice.TopLeftCorner,
            ItemUpgradeFrame.NineSlice.BottomLeftCorner,
            ItemUpgradeFrame.NineSlice.BottomRightCorner, 
        }) do
            ColorizationFrameFunction(v)
        end
    end

    -- Communities
    if addon == "Blizzard_Communities" and GetWoWVersion > 30600 and GetWoWVersion < 90500 then
        for i, v in pairs({ 
            CommunitiesFrameTopBorder,
            CommunitiesFrameRightBorder,
            CommunitiesFrameBottomBorder,
            CommunitiesFrameLeftBorder,
            CommunitiesFrameTopRightCorner,
            CommunitiesFrameTopLeftCorner,
            CommunitiesFrameBottomLeftCorner,
            CommunitiesFrameBottomRightCorner,
            CommunitiesFrameBtnCornerRight,
            CommunitiesFrameBtnCornerLeft,
            CommunitiesFramePortraitFrame,
        }) do
            ColorizationFrameFunction(v)
        end
    end

    -- AdventureGuide
    if addon == "Blizzard_EncounterJournal" and GetWoWVersion > 30600 then
        for i, v in pairs({ 
            EncounterJournalTopBorder,
            EncounterJournalRightBorder,
            EncounterJournalBottomBorder,
            EncounterJournalLeftBorder,
            EncounterJournalTopRightCorner,
            EncounterJournalTopLeftCorner,
            EncounterJournalBottomLeftCorner,
            EncounterJournalBottomRightCorner,
            EncounterJournalBtnCornerRight,
            EncounterJournalBtnCornerLeft,
            EncounterJournalPortraitFrame,
        }) do
            ColorizationFrameFunction(v)
        end
    end


    -- GameTooltip
    if (GetWoWVersion <= 90500) then
        GameTooltip:HookScript("OnTooltipSetUnit", function(self, elapsed)
            for i, v in pairs({
                GameTooltip.BottomEdge,
                GameTooltip.TopEdge,
                GameTooltip.RightEdge,
                GameTooltip.BottomEdge,
                GameTooltip.LeftEdge,
                GameTooltip.TopRightCorner,
                GameTooltip.TopLeftCorner,
                GameTooltip.BottomLeftCorner,
                GameTooltip.BottomRightCorner,
            }) do
            ColorizationFrameFunction(v)
            end
        end)
    elseif (GetWoWVersion >= 90500) then
        GameTooltip:HookScript("OnShow", function(self, elapsed)
            for i, v in pairs({
                GameTooltip.NineSlice.BottomEdge,
                GameTooltip.NineSlice.TopEdge,
                GameTooltip.NineSlice.RightEdge,
                GameTooltip.NineSlice.BottomEdge,
                GameTooltip.NineSlice.LeftEdge,
                GameTooltip.NineSlice.TopRightCorner,
                GameTooltip.NineSlice.TopLeftCorner,
                GameTooltip.NineSlice.BottomLeftCorner,
                GameTooltip.NineSlice.BottomRightCorner,
            }) do
            ColorizationFrameFunction(v)
            end
        end)
    end

    -- LFGDungeonReadyDialog
    if GetWoWVersion > 50600 then
        local ChildRegions = { LFGDungeonReadyDialog.Border:GetRegions() }
        local fs = {}
        for k, v in pairs(ChildRegions) do
            ColorizationFrameFunction(v)
        end
        for i, v in pairs ({
            LFGDungeonReadyDialogYourRoleDescription,
            LFGDungeonReadyDialogRoleLabel,
            LFGDungeonReadyDialogLabel,
        }) do
            v:SetVertexColor(219/255, 222/255, 231/255)
        end
    end

    ---------------------------- NewUI Frames ----------------------------------
    if (addon == E.addonName) then
        if GetWoWVersion >= 90500 then
            -- General
            for i, v in pairs({ 
                PlayerFrame.PlayerFrameContainer.FrameTexture,
                TargetFrame.TargetFrameContainer.FrameTexture,
                FocusFrame.TargetFrameContainer.FrameTexture,
                TargetFrameToT.FrameTexture,
                PlayerFrameAlternateManaBarBorder,
                PlayerFrameAlternateManaBarLeftBorder,
                PlayerFrameAlternateManaBarRightBorder,
                MinimapCompassTexture,
             }) do
                ColorizationFrameFunction(v)
            end
            for i, v in pairs({ 
                PlayerFrame.PlayerFrameContainer.FrameTexture,
                PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture,
                TargetFrame.TargetFrameContainer.FrameTexture,
                FocusFrame.TargetFrameContainer.FrameTexture,
                TargetFrameToT.FrameTexture,
                PlayerFrameAlternateManaBarBorder,
                PlayerFrameAlternateManaBarLeftBorder,
                PlayerFrameAlternateManaBarRightBorder,
                MinimapCompassTexture,
             }) do
                ColorizationFrameFunction(v)
            end
             -- SettingsPanel
            for i, v in pairs({ 
                SettingsPanel.NineSlice.RightEdge,
                SettingsPanel.NineSlice.LeftEdge,
                SettingsPanel.NineSlice.TopEdge,
                SettingsPanel.NineSlice.BottomEdge,
                SettingsPanel.NineSlice.PortraitFrame,
                SettingsPanel.NineSlice.TopRightCorner,
                SettingsPanel.NineSlice.TopLeftCorner,
                SettingsPanel.NineSlice.BottomLeftCorner,
                SettingsPanel.NineSlice.BottomRightCorner,
             }) do
                ColorizationFrameFunction(v)
            end
            -- HelpFrame
            for i, v in pairs({ 
                HelpFrame.NineSlice.RightEdge,
                HelpFrame.NineSlice.LeftEdge,
                HelpFrame.NineSlice.TopEdge,
                HelpFrame.NineSlice.BottomEdge,
                HelpFrame.NineSlice.PortraitFrame,
                HelpFrame.NineSlice.TopRightCorner,
                HelpFrame.NineSlice.TopLeftCorner,
                HelpFrame.NineSlice.BottomLeftCorner,
                HelpFrame.NineSlice.BottomRightCorner,
             }) do
                ColorizationFrameFunction(v)
            end
            -- Action Bar
            for i, v in pairs({ 
                MainMenuBar.EndCaps.RightEndCap,
                MainMenuBar.EndCaps.LeftEndCap,
                MainMenuBar.BorderArt,
                MainStatusTrackingBarContainer.BarFrameTexture,
                ActionButton1NormalTexture,
                ActionButton2NormalTexture,
                ActionButton3NormalTexture,
                ActionButton4NormalTexture,
                ActionButton5NormalTexture,
                ActionButton6NormalTexture,
                ActionButton7NormalTexture,
                ActionButton8NormalTexture,
                ActionButton9NormalTexture,
                ActionButton10NormalTexture,
                ActionButton11NormalTexture,
                ActionButton12NormalTexture,
                ActionButton1.RightDivider,
                ActionButton2.RightDivider,
                ActionButton3.RightDivider,
                ActionButton4.RightDivider,
                ActionButton5.RightDivider,
                ActionButton6.RightDivider,
                ActionButton7.RightDivider,
                ActionButton8.RightDivider,
                ActionButton9.RightDivider,
                ActionButton10.RightDivider,
                ActionButton11.RightDivider,
                MultiBarLeftButton1NormalTexture,
                MultiBarLeftButton2NormalTexture,
                MultiBarLeftButton3NormalTexture,
                MultiBarLeftButton4NormalTexture,
                MultiBarLeftButton5NormalTexture,
                MultiBarLeftButton6NormalTexture,
                MultiBarLeftButton7NormalTexture,
                MultiBarLeftButton8NormalTexture,
                MultiBarLeftButton9NormalTexture,
                MultiBarLeftButton10NormalTexture,
                MultiBarLeftButton11NormalTexture,
                MultiBarLeftButton12NormalTexture,
                MultiBarRightButton1NormalTexture,
                MultiBarRightButton2NormalTexture,
                MultiBarRightButton3NormalTexture,
                MultiBarRightButton4NormalTexture,
                MultiBarRightButton5NormalTexture,
                MultiBarRightButton6NormalTexture,
                MultiBarRightButton7NormalTexture,
                MultiBarRightButton8NormalTexture,
                MultiBarRightButton9NormalTexture,
                MultiBarRightButton10NormalTexture,
                MultiBarRightButton11NormalTexture,
                MultiBarRightButton12NormalTexture,
                MultiBarBottomLeftButton1NormalTexture,
                MultiBarBottomLeftButton2NormalTexture,
                MultiBarBottomLeftButton3NormalTexture,
                MultiBarBottomLeftButton4NormalTexture,
                MultiBarBottomLeftButton5NormalTexture,
                MultiBarBottomLeftButton6NormalTexture,
                MultiBarBottomLeftButton7NormalTexture,
                MultiBarBottomLeftButton8NormalTexture,
                MultiBarBottomLeftButton9NormalTexture,
                MultiBarBottomLeftButton10NormalTexture,
                MultiBarBottomLeftButton11NormalTexture,
                MultiBarBottomLeftButton12NormalTexture,
                MultiBarBottomRightButton1NormalTexture,
                MultiBarBottomRightButton2NormalTexture,
                MultiBarBottomRightButton3NormalTexture,
                MultiBarBottomRightButton4NormalTexture,
                MultiBarBottomRightButton5NormalTexture,
                MultiBarBottomRightButton6NormalTexture,
                MultiBarBottomRightButton7NormalTexture,
                MultiBarBottomRightButton8NormalTexture,
                MultiBarBottomRightButton9NormalTexture,
                MultiBarBottomRightButton10NormalTexture,
                MultiBarBottomRightButton11NormalTexture,
                MultiBarBottomRightButton12NormalTexture,
             }) do
                ColorizationFrameFunction(v)
            end
            -- Bags
            for i, v in pairs({ 
                ContainerFrame1.NineSlice,
                ContainerFrame2.NineSlice,
                ContainerFrame3.NineSlice,
                ContainerFrame4.NineSlice,
                ContainerFrame5.NineSlice,
                ContainerFrame6.NineSlice,
                ContainerFrame7.NineSlice,
                ContainerFrame8.NineSlice,
                ContainerFrame9.NineSlice,
                ContainerFrame10.NineSlice,
                ContainerFrame11.NineSlice,
                ContainerFrame12.NineSlice,
                ContainerFrame13.NineSlice,
                ContainerFrameCombinedBags.NineSlice,
             }) do
                ColorizationFrameFunction(v)
            end
            -- StatusTrackingBarManager
            for i, v in pairs({ 
                StatusTrackingBarManager.BottomBarFrameTexture,
                StatusTrackingBarManager.TopBarFrameTexture,
             }) do
                ColorizationFrameFunction(v)
            end
        end
    end     

    ---------------------------- NewUI Functions ----------------------------------
    -- ClassTalentFrame
    if addon == "Blizzard_ClassTalentUI" and GetWoWVersion >= 90500 then
        for i, v in pairs({ 
            ClassTalentFrame.NineSlice.RightEdge,
            ClassTalentFrame.NineSlice.LeftEdge,
            ClassTalentFrame.NineSlice.TopEdge,
            ClassTalentFrame.NineSlice.BottomEdge,
            ClassTalentFrame.NineSlice.PortraitFrame,
            ClassTalentFrame.NineSlice.TopRightCorner,
            ClassTalentFrame.NineSlice.TopLeftCorner,
            ClassTalentFrame.NineSlice.BottomLeftCorner,
            ClassTalentFrame.NineSlice.BottomRightCorner,
        }) do
            ColorizationFrameFunction(v)
        end
    end

    -- PlayerSpellsFrame
    if addon == "Blizzard_PlayerSpells" and GetWoWVersion >= 90500 then
        for i, v in pairs({ 
            PlayerSpellsFrame.NineSlice.TopEdge,
            PlayerSpellsFrame.NineSlice.RightEdge,
            PlayerSpellsFrame.NineSlice.LeftEdge,
            PlayerSpellsFrame.NineSlice.TopEdge,
            PlayerSpellsFrame.NineSlice.BottomEdge,
            PlayerSpellsFrame.NineSlice.PortraitFrame,
            PlayerSpellsFrame.NineSlice.TopRightCorner,
            PlayerSpellsFrame.NineSlice.TopLeftCorner,
            PlayerSpellsFrame.NineSlice.BottomLeftCorner,
            PlayerSpellsFrame.NineSlice.BottomRightCorner,
         }) do
            ColorizationFrameFunction(v)
        end
    end

    -- ProfessionsFrame
      if addon == "Blizzard_Professions" and GetWoWVersion >= 90500 then
        for i, v in pairs({ 
            ProfessionsFrame.NineSlice.TopEdge,
            ProfessionsFrame.NineSlice.RightEdge,
            ProfessionsFrame.NineSlice.BottomEdge,
            ProfessionsFrame.NineSlice.LeftEdge,
            ProfessionsFrame.NineSlice.TopRightCorner,
            ProfessionsFrame.NineSlice.TopLeftCorner,
            ProfessionsFrame.NineSlice.BottomLeftCorner,
            ProfessionsFrame.NineSlice.BottomRightCorner,
            ProfessionsFrame.CraftingPage.RankBar.Border,
            ProfessionsFrame.CraftingPage.SchematicForm.OutputIcon.IconBorder,
            DropDownList1MenuBackdrop.NineSlice.TopEdge,
            DropDownList1MenuBackdrop.NineSlice.RightEdge,
            DropDownList1MenuBackdrop.NineSlice.BottomEdge,
            DropDownList1MenuBackdrop.NineSlice.LeftEdge,
            DropDownList1MenuBackdrop.NineSlice.TopRightCorner,
            DropDownList1MenuBackdrop.NineSlice.TopLeftCorner,
            DropDownList1MenuBackdrop.NineSlice.BottomLeftCorner,
            DropDownList1MenuBackdrop.NineSlice.BottomRightCorner,
            DropDownList2MenuBackdrop.NineSlice.TopEdge,
            DropDownList2MenuBackdrop.NineSlice.RightEdge,
            DropDownList2MenuBackdrop.NineSlice.BottomEdge,
            DropDownList2MenuBackdrop.NineSlice.LeftEdge,
            DropDownList2MenuBackdrop.NineSlice.TopRightCorner,
            DropDownList2MenuBackdrop.NineSlice.TopLeftCorner,
            DropDownList2MenuBackdrop.NineSlice.BottomLeftCorner,
            DropDownList2MenuBackdrop.NineSlice.BottomRightCorner,
        }) do
            ColorizationFrameFunction(v)
        end
      end

    -- CharacterMainHandSlot
    if GetWoWVersion >= 100000 then
        local ChildRegions = { CharacterMainHandSlot:GetRegions() }
        for k, v in pairs(ChildRegions) do
            ColorizationFrameFunction(v)
        end
      end

    if GetWoWVersion >= 100000 then
        local ChildRegions = { CharacterSecondaryHandSlot:GetRegions() }
        ColorizationFrameFunction(v)
      end
end)
