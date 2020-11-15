local _, ns = ...
local E, C, L = ns:unpack()

if not C.bags.enable then return end

----------------------------------------------------------------------------------------
--	Localization of Bags (modified from cargBags_Nivaya of RealUI)
----------------------------------------------------------------------------------------

local _G = _G

L.BAG_SEARCH = _G.SEARCH
L.BAG_ARMOR = _G.GetItemClassInfo(4)
L.BAG_BATTLEPET = _G.GetItemClassInfo(17)
L.BAG_CONSUMABLES = _G.GetItemClassInfo(0)
L.BAG_GEM = _G.GetItemClassInfo(3)
L.BAG_QUEST = _G.GetItemClassInfo(12)
L.BAG_TRADES = _G.GetItemClassInfo(7)
L.BAG_WEAPON = _G.GetItemClassInfo(2)
L.BAG_ARTIFACTPOWER = ARTIFACT_POWER

L.BAG_BAGCAPTIONS_BANK = _G.BANK
L.BAG_BAGCAPTIONS_BANKREAGENT = _G.REAGENT_BANK
L.BAG_BAGCAPTIONS_BANKSETS = _G.LOOT_JOURNAL_ITEM_SETS
L.BAG_BAGCAPTIONS_BANKARMOR = _G.BAG_FILTER_EQUIPMENT
L.BAG_BAGCAPTIONS_BANKGEM = _G.AUCTION_CATEGORY_GEMS
L.BAG_BAGCAPTIONS_BANKQUEST = _G.AUCTION_CATEGORY_QUEST_ITEMS
L.BAG_BAGCAPTIONS_BANKPET = _G.AUCTION_CATEGORY_BATTLE_PETS
L.BAG_BAGCAPTIONS_BANKTRADE = _G.BAG_FILTER_TRADE_GOODS
L.BAG_BAGCAPTIONS_BANKCONS = _G.BAG_FILTER_CONSUMABLES

L.BAG_BAGCAPTIONS_JUNK = _G.BAG_FILTER_JUNK
L.BAG_BAGCAPTIONS_ITEMSETS = _G.LOOT_JOURNAL_ITEM_SETS
L.BAG_BAGCAPTIONS_ARMOR = _G.BAG_FILTER_EQUIPMENT
L.BAG_BAGCAPTIONS_GEM = _G.AUCTION_CATEGORY_GEMS
L.BAG_BAGCAPTIONS_QUEST = _G.AUCTION_CATEGORY_QUEST_ITEMS
L.BAG_BAGCAPTIONS_CONSUMABLES = _G.BAG_FILTER_CONSUMABLES
L.BAG_BAGCAPTIONS_TRADEGOODS = _G.BAG_FILTER_TRADE_GOODS
L.BAG_BAGCAPTIONS_BATTLEPET = _G.AUCTION_CATEGORY_BATTLE_PETS
L.BAG_BAGCAPTIONS_BAG = _G.INVENTORY_TOOLTIP
L.BAG_BAGCAPTIONS_KEYRING = _G.KEYRING
