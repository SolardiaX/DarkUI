local E, C, L = select(2, ...):unpack()

if not C.blizzard.style then return end

----------------------------------------------------------------------------------------
-- Skin Blizzard Default Frames (modified from FrameColor)
----------------------------------------------------------------------------------------

local r, g, b = unpack(C.media.vertex_color)

local FrameColor = CreateFrame("Frame")
FrameColor.modules = {}

--color scaled edges and header
function FrameColor:NineSlicer(frame, r,g,b)   
    for i, v in pairs({
        frame.NineSlice.TopEdge,
        frame.NineSlice.BottomEdge,
        frame.NineSlice.TopRightCorner,
        frame.NineSlice.TopLeftCorner,
        frame.NineSlice.RightEdge,
        frame.NineSlice.LeftEdge,
        frame.NineSlice.BottomRightCorner,
        frame.NineSlice.BottomLeftCorner,  
    }) do
        v:SetVertexColor(r,g,b)
    end
end

function FrameColor:NewModule(name)
    local module = {}

    module.host = CreateFrame("Frame", nil, FrameColor)
    module.RegisterEvent = function(self, event, func)
        self.host:RegisterEvent(event)
        self.host:SetScript("OnEvent", func)
    end

    FrameColor.modules[name] = module

    return module
end

--Character Frame
local Character = FrameColor:NewModule("Character")
Character:RegisterEvent("PLAYER_LOGIN", function()
    FrameColor:NineSlicer(CharacterFrame,r,g,b)
    FrameColor:NineSlicer(CharacterFrameInset,r,g,b)
    FrameColor:NineSlicer(CharacterFrameInsetRight,r,g,b)
    for i ,v in pairs({
        CharacterFrameBg,
        CharacterStatsPane.ClassBackground,
        PaperDollInnerBorderTop,
        PaperDollInnerBorderTopRight,
        PaperDollInnerBorderRight,
        PaperDollInnerBorderBottom,
        PaperDollInnerBorderBottomRight,
        PaperDollInnerBorderBottomLeft,
        PaperDollInnerBorderLeft,
        PaperDollInnerBorderTopLeft,
        CharacterFrameInset.Bg,
        CharacterFrameTab1.Left,
        CharacterFrameTab1.Middle,
        CharacterFrameTab1.Right,
        CharacterFrameTab2.Left,
        CharacterFrameTab2.Middle,
        CharacterFrameTab2.Right,
        CharacterFrameTab3.Left,
        CharacterFrameTab3.Middle,
        CharacterFrameTab3.Right,
    }) do 
        v:SetVertexColor(r,g,b)
    end
end)

--Combined Bags
local Bag = FrameColor:NewModule("Bag")
Bag:RegisterEvent("PLAYER_LOGIN", function()
    --ContainerFrameCombinedBagsPortrait.CircleMask:SetDesaturated(true)
    FrameColor:NineSlicer(ContainerFrameCombinedBags,r,g,b)
    for i ,v in pairs({
        ContainerFrameCombinedBags.Bg.TopSection,
        ContainerFrameCombinedBags.Bg.BottomEdge,
        ContainerFrameCombinedBags.MoneyFrame.Border.Middle,
        ContainerFrameCombinedBags.MoneyFrame.Border.Left,
        ContainerFrameCombinedBags.MoneyFrame.Border.Right,
    }) do
        v:SetVertexColor(r,g,b)
    end
    ContainerFrameCombinedBags.Bg.BottomLeft:SetColorTexture(r,g,b)
    ContainerFrameCombinedBags.Bg.BottomRight:SetColorTexture(r,g,b)
end)

--Spellbook
local SpellBook = FrameColor:NewModule("SpellBook")
SpellBook:RegisterEvent("PLAYER_LOGIN", function()
    FrameColor:NineSlicer(SpellBookFrame,r,g,b)
    FrameColor:NineSlicer(SpellBookFrameInset,r,g,b)
    for i ,v in pairs({
        SpellBookFrameBg,
        SpellBookFrameTabButton1.Left,
        SpellBookFrameTabButton1.Middle,
        SpellBookFrameTabButton1.Right,
        SpellBookFrameTabButton2.Left,
        SpellBookFrameTabButton2.Middle,
        SpellBookFrameTabButton2.Right,
        SpellBookFrameTabButton3.Left,
        SpellBookFrameTabButton3.Middle,
        SpellBookFrameTabButton3.Right,
    }) do 
        v:SetVertexColor(r,g,b)
    end
end)

--Talents
local Talents = FrameColor:NewModule("Talents")
Talents:RegisterEvent("ADDON_LOADED", function(self, event)
    if event == "Blizzard_ClassTalentUI" or (ClassTalentFrame and not ClassTalentFrame.__styled) then
        FrameColor:NineSlicer(ClassTalentFrame, r,g,b)
        for i ,v in pairs({
            ClassTalentFrameBg,
            ClassTalentFrame.TalentsTab.BottomBar,
            ClassTalentFrame.TalentsTab.WarmodeButton.Ring,
            --ClassTalentFrame.TalentsTab.WarmodeButton.Orb,
            ClassTalentFrame.SpecTab.BlackBG,
            ClassTalentFrame.SpecTab.Background,
        }) do 
            v:SetVertexColor(r,g,b)
        end

        for i, v in pairs({ ClassTalentFrame.TabSystem:GetChildren() }) do 
            for _,k in pairs({
                v.Left,
                v.Middle,
                v.Right,
            }) do 
                if k then k:SetVertexColor(r,g,b) end
            end
        end

        ClassTalentFrame.__styled = true
    end
end)

--Achievments
local Achievements = FrameColor:NewModule("Achievements")
Achievements:RegisterEvent("ADDON_LOADED", function(self, event)
    if event == "Blizzard_AchievementUI" or (AchievementFrame and not AchievementFrame.__styled) then
        for i ,v in pairs({
            AchievementFrameMetalBorderRight,
            AchievementFrameMetalBorderBottomRight,
            AchievementFrameMetalBorderBottom,
            AchievementFrameMetalBorderBottomBottomLeft,
            AchievementFrameMetalBorderLeft,
            AchievementFrameMetalBorderTopLeft,
            AchievementFrameMetalBorderTop,
            AchievementFrameMetalBorderTopRight,
            AchievementFrame.Header.PointBorder,
            AchievementFrame.Header.Left,
            AchievementFrame.Header.Right,
            AchievementFrameCategoriesBG,
        }) do 
            v:SetVertexColor(r,g,b)
        end
        FrameColor:NineSlicer(AchievementFrameCategories, r,g,b)

        AchievementFrame.__styled = true
    end
end)

--WorldMap
local WorldMap = FrameColor:NewModule("WorldMap")
WorldMap:RegisterEvent("PLAYER_LOGIN", function()
    FrameColor:NineSlicer(WorldMapFrame.BorderFrame,r,g,b)
    for i ,v in pairs({
        WorldMapFrameBg,
        WorldMapFrame.ScrollContainer.Child.TiledBackground,
        QuestMapFrame.Background,
        QuestScrollFrameTop,
        QuestScrollFrameMiddle,
        QuestScrollFrameBottom,
        QuestMapFrame.VerticalSeparator,
        WorldMapFrame.NavBar.InsetBorderBottom,
        WorldMapFrame.NavBar.InsetBorderBottomLeft,
        WorldMapFrame.NavBar.InsetBorderBottomRight,
        WorldMapFrame.NavBar.InsetBorderTop,
        WorldMapFrame.NavBar.InsetBorderLeft,
        WorldMapFrame.NavBar.InsetBorderRight,
        WorldMapFrame.BlackoutFrame.Blackout,
    }) 
        do v:SetVertexColor(r,g,b)
    end
end)

--Guild
local Guild = FrameColor:NewModule("Guild")
Guild:RegisterEvent("ADDON_LOADED", function(self, event)
    if event == "Blizzard_Communities" or (CommunitiesFrame and not CommunitiesFrame.__styled) then
        FrameColor:NineSlicer(CommunitiesFrame, r,g,b)
        FrameColor:NineSlicer(CommunitiesFrameInset, r,g,b)
        FrameColor:NineSlicer(CommunitiesFrame.MemberList.InsetFrame, r,g,b)
        FrameColor:NineSlicer(CommunitiesFrame.Chat.InsetFrame, r,g,b)
        FrameColor:NineSlicer(CommunitiesFrameCommunitiesList.InsetFrame, r,g,b)
        for i ,v in pairs({
            CommunitiesFrameBg,
            --CommunitiesFrameMiddle,
            --CommunitiesFrameRight,
            --CommunitiesFrameLeft,
            CommunitiesFrame.ChatEditBox.Left,
            CommunitiesFrame.ChatEditBox.Mid,
            CommunitiesFrame.ChatEditBox.Right,
            CommunitiesFrame.MemberList.ScrollBar.Background,
            CommunitiesFrame.MemberList.ScrollBar.Backplate,
            CommunitiesFrameCommunitiesList.ScrollBar.Background,
            CommunitiesFrameCommunitiesList.ScrollBar.Backplate,
            CommunitiesFrameCommunitiesList.Bg,
            CommunitiesFrameInset.Bg,
            CommunitiesFrame.TopTileStreaks,
            CommunitiesFrame.MemberList.ColumnDisplay.Background,
            CommunitiesFrame.MemberList.ColumnDisplay.TopTileStreaks,
            CommunitiesFrame.GuildBenefitsFrame.InsetBorderRight,
            CommunitiesFrame.GuildBenefitsFrame.InsetBorderLeft,
            CommunitiesFrame.GuildBenefitsFrame.InsetBorderBottomLeft,
            CommunitiesFrame.GuildBenefitsFrame.InsetBorderBottomRight,
            CommunitiesFrame.GuildBenefitsFrame.InsetBorderTopLeft,
            CommunitiesFrame.GuildBenefitsFrame.InsetBorderTopRight,
            CommunitiesFrame.GuildBenefitsFrame.InsetBorderBottomLeft2,
            CommunitiesFrameGuildDetailsFrame.InsetBorderRight,
            CommunitiesFrameGuildDetailsFrame.InsetBorderLeft,
            CommunitiesFrameGuildDetailsFrame.InsetBorderBottomLeft,
            CommunitiesFrameGuildDetailsFrame.InsetBorderBottomRight,
            CommunitiesFrameGuildDetailsFrame.InsetBorderTopLeft,
            CommunitiesFrameGuildDetailsFrame.InsetBorderTopRight,
            CommunitiesFrameGuildDetailsFrame.InsetBorderBottomLeft2,
            CommunitiesFrame.GuildMemberDetailFrame.Border.TopEdge,
            CommunitiesFrame.GuildMemberDetailFrame.Border.BottomEdge,
            CommunitiesFrame.GuildMemberDetailFrame.Border.RightEdge,
            CommunitiesFrame.GuildMemberDetailFrame.Border.LeftEdge,
            CommunitiesFrame.GuildMemberDetailFrame.Border.BottomLeftCorner,
            CommunitiesFrame.GuildMemberDetailFrame.Border.BottomRightCorner,
            CommunitiesFrame.GuildMemberDetailFrame.Border.TopRightCorner,
            CommunitiesFrame.GuildMemberDetailFrame.Border.TopLeftCorner,
        }) do 
            v:SetVertexColor(r,g,b)
        end

        CommunitiesFrame.__styled = true
    end
end)  

--GroupFinder
local GroupFinder = FrameColor:NewModule("GroupFinder")
GroupFinder:RegisterEvent("PLAYER_LOGIN", function()
    FrameColor:NineSlicer(PVEFrame,r,g,b)
    FrameColor:NineSlicer(PVEFrameLeftInset,r,g,b)
    FrameColor:NineSlicer(LFDParentFrameInset,r,g,b)
    for i ,v in pairs({
        PVEFrameBg,
        PVEFrameBRCorner,
        PVEFrameTRCorner,
        PVEFrameBLCorner,
        PVEFrameTLCorner,
        PVEFrameBottomLine,
        PVEFrameLLVert,
        PVEFrameRLVert,
        PVEFrameTopLine,
        PVEFrameLeftInset.Bg,
        PVEFrame.TopTileStreaks,
        PVEFrameTab1.Left,
        PVEFrameTab1.Middle,
        PVEFrameTab1.Right,
        PVEFrameTab2.Left,
        PVEFrameTab2.Middle,
        PVEFrameTab2.Right,
        PVEFrameTab3.Left,
        PVEFrameTab3.Middle,
        PVEFrameTab3.Right,
    }) do 
        v:SetVertexColor(r,g,b)
    end
end)

--Collections
local Collections = FrameColor:NewModule("Collections")
Collections:RegisterEvent("ADDON_LOADED", function(self, event)
    if event == "Blizzard_Collections" or (CollectionsJournal and not CollectionsJournal.__styled) then
        FrameColor:NineSlicer(CollectionsJournal, r,g,b)
        for i ,v in pairs({
            CollectionsJournalBg,
            CollectionsJournalTab1.Left,
            CollectionsJournalTab1.Middle,
            CollectionsJournalTab1.Right,
            CollectionsJournalTab2.Left,
            CollectionsJournalTab2.Middle,
            CollectionsJournalTab2.Right,
            CollectionsJournalTab3.Left,
            CollectionsJournalTab3.Middle,
            CollectionsJournalTab3.Right,
            CollectionsJournalTab4.Left,
            CollectionsJournalTab4.Middle,
            CollectionsJournalTab4.Right,
            CollectionsJournalTab5.Left,
            CollectionsJournalTab5.Middle,
            CollectionsJournalTab5.Right,
        }) do 
            v:SetVertexColor(r,g,b)
        end

        CollectionsJournal.__styled = true
    end
end)  

--EncounterJournal
local AdventureGuide = FrameColor:NewModule("AdventureGuide")
AdventureGuide:RegisterEvent("ADDON_LOADED", function(self, event)
    if event == "Blizzard_EncounterJournal" or (EncounterJournal and not EncounterJournal.__styled) then
        FrameColor:NineSlicer(EncounterJournal, r,g,b)
        FrameColor:NineSlicer(EncounterJournalInset, r,g,b)
        for i ,v in pairs({
            EncounterJournalBg,
            EncounterJournalNavBarInsetBottomBorder,
            EncounterJournalNavBarInsetRightBorder,
            EncounterJournalNavBarInsetLeftBorder,
            EncounterJournalNavBarInsetBotRightCorner,
            EncounterJournalNavBarInsetBotLeftCorner,
            EncounterJournalSearchBox.Left,
            EncounterJournalSearchBox.Right,
            EncounterJournalSearchBox.Middle,
            EncounterJournalDungeonTab.Middle,
            EncounterJournalDungeonTab.Right,
            EncounterJournalDungeonTab.Left,
            EncounterJournalRaidTab.Middle,
            EncounterJournalRaidTab.Right,
            EncounterJournalRaidTab.Left,Raid,
            EncounterJournalSuggestTab.Middle,
            EncounterJournalSuggestTab.Right,
            EncounterJournalSuggestTab.Left,
            EncounterJournalLootJournalTab.Middle,
            EncounterJournalLootJournalTab.Right,
            EncounterJournalLootJournalTab.Left,
            EncounterJournalInstanceSelectTierDropDownMiddle,
            EncounterJournalInstanceSelectTierDropDownRight,
            EncounterJournalInstanceSelectTierDropDownLeft,
        }) do 
            v:SetVertexColor(r,g,b)
        end

        EncounterJournal.__styled = true
    end
end)  

--Mail
local Mail = FrameColor:NewModule("Mail")
Mail:RegisterEvent("PLAYER_LOGIN", function()
    FrameColor:NineSlicer(MailFrame,r,g,b)
    FrameColor:NineSlicer(OpenMailFrame,r,g,b)
    for i ,v in pairs({
        MailFrameBg,
        OpenMailFrameBg,
        MailFrameTab1.Left,
        MailFrameTab1.Middle,
        MailFrameTab1.Right,
        MailFrameTab2.Left,
        MailFrameTab2.Middle,
        MailFrameTab2.Right,
    }) do 
        v:SetVertexColor(r,g,b)
    end
end)

--Gossip
local Gossip = FrameColor:NewModule("Gossip")
Gossip:RegisterEvent("PLAYER_LOGIN", function()
    FrameColor:NineSlicer(GossipFrame,r,g,b)
    for i ,v in pairs({
        GossipFrameBg
    }) do 
        v:SetVertexColor(r,g,b)
    end
end)

--Settings
local Settings = FrameColor:NewModule("Settings")
Settings:RegisterEvent("PLAYER_LOGIN", function()
    FrameColor:NineSlicer(SettingsPanel,r,g,b)
    for i ,v in pairs({
       SettingsPanel.Bg.TopSection,
       SettingsPanel.Bg.BottomEdge,
    }) do 
        v:SetVertexColor(r,g,b)
    end
    SettingsPanel.Bg.BottomRight:SetColorTexture(r,g,b)
    SettingsPanel.Bg.BottomLeft:SetColorTexture(r,g,b)
end)

--InspectFramce
local Inspect = FrameColor:NewModule("Inspect")
Inspect:RegisterEvent("ADDON_LOADED", function(self, event)
    if event == "Blizzard_InspectUI" or (InspectFrame and not InspectFrame.__styled) then
        FrameColor:NineSlicer(InspectFrame, r,g,b)
        FrameColor:NineSlicer(InspectFrameInset, r,g,b)
        for i ,v in pairs({
            InspectFrameBg,
            InspectModelFrameBorderBottom,
            InspectModelFrameBorderBottomRight,
            InspectModelFrameBorderBottomLeft,
            InspectModelFrameBorderTop,
            InspectModelFrameBorderTopLeft,
            InspectModelFrameBorderTopRight,
            InspectModelFrameBorderLeft,
            InspectModelFrameBorderRight,
            InspectFrameInset.Bg,
            InspectFrameTab1.Left,
            InspectFrameTab1.Middle,
            InspectFrameTab1.Right,
            InspectFrameTab2.Left,
            InspectFrameTab2.Middle,
            InspectFrameTab2.Right,
            InspectFrameTab3.Left,
            InspectFrameTab3.Middle,
            InspectFrameTab3.Right,
        }) do 
            v:SetVertexColor(r,g,b)
        end
        for i, v in pairs({ InspectFrame:GetChildren() }) do 
            for _,k in pairs({
                v.Left,
                v.Middle,
                v.Right,
            }) do 
                k:SetVertexColor(r,g,b)
            end
        end

        InspectFrame.__styled = true
    end
end)  

--Friends
local Friends = FrameColor:NewModule("Friends")
Friends:RegisterEvent("PLAYER_LOGIN", function()
    FrameColor:NineSlicer(FriendsFrame,r,g,b)
    for i ,v in pairs({
        FriendsFrameBg,
        RaidInfoFrame.Header.CenterBG,
        RaidInfoFrame.Header.RightBG,
        RaidInfoFrame.Header.LeftBG,
        RaidInfoFrame.Border.TopEdge,
        RaidInfoFrame.Border.RightEdge,
        RaidInfoFrame.Border.LeftEdge,
        RaidInfoFrame.Border.BottomEdge,
        RaidInfoFrame.Border.TopLeftCorner,
        RaidInfoFrame.Border.TopRightCorner,
        RaidInfoFrame.Border.BottomLeftCorner,
        RaidInfoFrame.Border.BottomRightCorner,
        RaidInfoDetailHeader,
        RaidInfoDetailFooter,
        FriendsFrameTab1.Left,
        FriendsFrameTab1.Middle,
        FriendsFrameTab1.Right,
        FriendsFrameTab2.Left,
        FriendsFrameTab2.Middle,
        FriendsFrameTab2.Right,
        FriendsFrameTab3.Left,
        FriendsFrameTab3.Middle,
        FriendsFrameTab3.Right,
        FriendsFrameTab4.Left,
        FriendsFrameTab4.Middle,
        FriendsFrameTab4.Right,
    }) do 
        v:SetVertexColor(r,g,b)
    end
end)

--Transmog 
local Transmog = FrameColor:NewModule("Transmog")
Transmog:RegisterEvent("ADDON_LOADED", function(self, event)
    if event == "Blizzard_Collections" or (WardrobeFrame and not WardrobeFrame.__styled) then
        FrameColor:NineSlicer(WardrobeFrame, r,g,b)
        for i ,v in pairs({
            WardrobeFramBg,
        }) do
            v:SetVertexColor(r,g,b)
        end

        WardrobeFrame.__styled = true
    end
end)  

--AuctionHouse 
local AuctionHouse = FrameColor:NewModule("AuctionHouse")
AuctionHouse:RegisterEvent("ADDON_LOADED", function(self, event)
    if event == "Blizzard_AuctionHouseUI" or (AuctionHouseFrame and not AuctionHouseFrame.__styled) then
        FrameColor:NineSlicer(AuctionHouseFrame, r,g,b)
        for i ,v in pairs({
            AuctionHouseFrameBg,
            AuctionHouseFrameBuyTab.Left,
            AuctionHouseFrameBuyTab.Middle,
            AuctionHouseFrameBuyTab.Right,
            AuctionHouseFrameSellTab.Left,
            AuctionHouseFrameSellTab.Middle,
            AuctionHouseFrameSellTab.Right,
            AuctionHouseFrameAuctionsTab.Left,
            AuctionHouseFrameAuctionsTab.Middle,
            AuctionHouseFrameAuctionsTab.Right,
            AuctionHouseFrameAuctionsFrameAuctionsTab.Left,
            AuctionHouseFrameAuctionsFrameAuctionsTab.Middle,
            AuctionHouseFrameAuctionsFrameAuctionsTab.Right,
            AuctionHouseFrameAuctionsFrameBidsTab.Left,
            AuctionHouseFrameAuctionsFrameBidsTab.Middle,
            AuctionHouseFrameAuctionsFrameBidsTab.Right,
        }) do 
            v:SetVertexColor(r,g,b)
        end

        AuctionHouseFrame.__styled = true
    end
end)  

--Macros 
local Macros = FrameColor:NewModule("Macros")
Macros:RegisterEvent("ADDON_LOADED", function(self, event)
    if event == "Blizzard_MacroUI" or (MacroFrame and not MacroFrame.__styled) then
        FrameColor:NineSlicer(MacroFrame, r,g,b)
        FrameColor:NineSlicer(MacroFrameTextBackground, r,g,b)
        for i ,v in pairs({
            MacroFrameBg,
        }) do 
            v:SetVertexColor(r,g,b)
        end

        MacroFrame.__styled = true
    end
end)  

--Quest
local Quest = FrameColor:NewModule("Quest")
Quest:RegisterEvent("PLAYER_LOGIN", function()
    FrameColor:NineSlicer(QuestFrame,r,g,b)
    for i ,v in pairs({
        QuestFrameBg
    }) do 
        v:SetVertexColor(r,g,b)
    end
end)

--Merchant
local Merchant = FrameColor:NewModule("Merchant")
Merchant:RegisterEvent("PLAYER_LOGIN", function()
    FrameColor:NineSlicer(MerchantFrame,r,g,b)
    for i ,v in pairs({
        MerchantFrameBg
    }) do 
        v:SetVertexColor(r,g,b)
    end
end)

--Loot
local Loot = FrameColor:NewModule("Loot")
Loot:RegisterEvent("PLAYER_LOGIN", function()
    FrameColor:NineSlicer(LootFrame,r,g,b)
    for i ,v in pairs({
        LootFrameBg.TopSection,
        LootFrameBg.BottomEdge,
    }) do
        v:SetVertexColor(r,g,b)
    end
    LootFrameBg.BottomRight:SetColorTexture(r,g,b)
    LootFrameBg.BottomLeft:SetColorTexture(r,g,b)
end)

--Trade
local Trade = FrameColor:NewModule("Trade")
Trade:RegisterEvent("PLAYER_LOGIN", function()
    FrameColor:NineSlicer(TradeFrame,r,g,b)
    for i ,v in pairs({
        TradeFrameBg,
        TradeRecipientBG,
    }) do 
        v:SetVertexColor(r,g,b)
    end
end)

--DressingRoom
local DressingRoom = FrameColor:NewModule("Trade")
DressingRoom:RegisterEvent("PLAYER_LOGIN", function()
    FrameColor:NineSlicer(DressUpFrame,r,g,b)
    FrameColor:NineSlicer(DressUpFrameInset,r,g,b)
    for i ,v in pairs({
        DressUpFrame.Bg,
        DressUpFrame.TitleBg,
        DressUpFrameInset.Bg,
    }) do 
        v:SetVertexColor(r,g,b)
    end
end)

--CraftingFrame
local Crafting = FrameColor:NewModule("Crafting")
Crafting:RegisterEvent("PLAYER_LOGIN", function()
    FrameColor:NineSlicer(ProfessionsFrame,r,g,b)
    FrameColor:NineSlicer(ProfessionsFrame.CraftingPage.SchematicForm,r,g,b)
    for i ,v in pairs({
        ProfessionsFrameBg,
        ProfessionsFrame.CraftingPage.RecipeList.Background,
        ProfessionsFrame.CraftingPage.RecipeList.SearchBox.Middle,
        ProfessionsFrame.CraftingPage.RecipeList.SearchBox.Left,
        ProfessionsFrame.CraftingPage.RecipeList.SearchBox.Right,
        ProfessionsFrameMiddleLeft,
        ProfessionsFrameMiddleMiddle,
        ProfessionsFrameMiddleRight,
        ProfessionsFrameTopLeft,
        ProfessionsFrameTopRight,
        ProfessionsFrameTopMiddle,
        ProfessionsFrameBottomLeft,
        ProfessionsFrameBottomRight,
        ProfessionsFrameBottomMiddle,
        ProfessionsFrameNormalTexture,
        ProfessionsFrame.CraftingPage.RankBar.Border,
        ProfessionsFrame.CraftingPage.RecipeList.BackgroundNineSlice.TopEdge,
        ProfessionsFrame.CraftingPage.RecipeList.BackgroundNineSlice.BottomEdge,
        ProfessionsFrame.CraftingPage.RecipeList.BackgroundNineSlice.TopRightCorner,
        ProfessionsFrame.CraftingPage.RecipeList.BackgroundNineSlice.TopLeftCorner,
        ProfessionsFrame.CraftingPage.RecipeList.BackgroundNineSlice.RightEdge,
        ProfessionsFrame.CraftingPage.RecipeList.BackgroundNineSlice.LeftEdge,
        ProfessionsFrame.CraftingPage.RecipeList.BackgroundNineSlice.BottomRightCorner,
        ProfessionsFrame.CraftingPage.RecipeList.BackgroundNineSlice.BottomLeftCorner,  
        ProfessionsFrame.CraftingPage.RecipeList.ScrollBar.Track.Middle,
        ProfessionsFrame.CraftingPage.RecipeList.ScrollBar.Track.Begin,
        ProfessionsFrame.CraftingPage.RecipeList.ScrollBar.Track.End,
        ProfessionsFrame.CraftingPage.RecipeList.ScrollBar.Track.Thumb.Middle,
        ProfessionsFrame.CraftingPage.RecipeList.ScrollBar.Track.Thumb.Begin,
        ProfessionsFrame.CraftingPage.RecipeList.ScrollBar.Track.Thumb.End,
        ProfessionsFrame.CraftingPage.RecipeList.ScrollBar.Forward.Texture,
        ProfessionsFrame.CraftingPage.RecipeList.ScrollBar.Back.Texture,
    }) do 
        v:SetVertexColor(r,g,b)
    end
    for i, v in pairs({ ProfessionsFrame.TabSystem:GetChildren() }) do 
        for _,k in pairs({
            v.Left,
            v.Middle,
            v.Right,
        }) do 
            if k then k:SetVertexColor(r,g,b) end
        end
    end
end)

--ESCMenu
local ESCMenu = FrameColor:NewModule("ESCMenu")
ESCMenu:RegisterEvent("PLAYER_LOGIN", function()
    for i, v in pairs({
        GameMenuFrame.Border.Bg,
        GameMenuFrame.Border.TopRightCorner,
        GameMenuFrame.Border.RightEdge,
        GameMenuFrame.Border.BottomRightCorner,
        GameMenuFrame.Border.BottomEdge,
        GameMenuFrame.Border.BottomLeftCorner,
        GameMenuFrame.Border.LeftEdge,
        GameMenuFrame.Border.TopLeftCorner,
        GameMenuFrame.Header.CenterBG,
        GameMenuFrame.Header.LeftBG,
        GameMenuFrame.Header.RightBG,
    }) do
        v:SetVertexColor(r,g,b)
    end
end)

--add shadow for UIParent
local shadow = CreateFrame("Frame", nil, UIParent)
shadow:SetAllPoints(UIParent)
shadow:SetFrameLevel(0)
shadow:SetFrameStrata("BACKGROUND")

shadow.tex = shadow:CreateTexture()
shadow.tex:SetTexture(C.media.texture.shadow_background)
shadow.tex:SetAllPoints(shadow)
shadow.tex:SetAlpha(.50)
