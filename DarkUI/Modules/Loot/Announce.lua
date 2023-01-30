local E, C, L = select(2, ...):unpack()

if not C.loot.enable or not _G["LootLite"] then return end

----------------------------------------------------------------------------------------
--	Announce loot(lcLoot by RustamIrzaev)
----------------------------------------------------------------------------------------

local CreateFrame = CreateFrame
local GetNumLootItems, GetLootSlotType, GetLootSlotInfo = GetNumLootItems, GetLootSlotType, GetLootSlotInfo
local LootSlotHasItem, GetLootSlotLink = LootSlotHasItem, GetLootSlotLink
local UnitIsPlayer, UnitExists, UnitName = UnitIsPlayer, UnitExists, UnitName
local SendChatMessage = SendChatMessage
local UIDropDownMenu_AddButton = UIDropDownMenu_AddButton
local ToggleDropDownMenu = ToggleDropDownMenu
local UIDropDownMenu_Initialize = UIDropDownMenu_Initialize
local format = format
local LOOT = LOOT
local LOOT_SLOT_MONEY = Enum.LootSlotType.Money
local LootLite, LootCloseButton = LootLite, LootCloseButton

local function Announce(chn)
    local nums = GetNumLootItems()
    if nums == 0 or (nums == 1 and GetLootSlotType(1) == LOOT_SLOT_MONEY) then
        return
    end
    if UnitIsPlayer("target") or not UnitExists("target") then
        SendChatMessage(">> " .. LOOT .. ":", chn)
    else
        SendChatMessage(">> " .. LOOT .. " - '" .. UnitName("target") .. "':", chn)
    end

    for i = 1, nums do
        if LootSlotHasItem(i) then
            local link = GetLootSlotLink(i)
            local messlink = "- %s"

            if GetLootSlotType(i) ~= LOOT_SLOT_MONEY then
                SendChatMessage(format(messlink, link), chn)
            else
                local _, item = GetLootSlotInfo(i)
                item = item:gsub("\n", ", ")
                SendChatMessage(format(messlink, item), chn)
            end
        end
    end
end

local function LDD_OnClick(self)
    local val = self.value
    Announce(val)
end

local function LDD_Initialize()
    local info = {}

    info.text = L.LOOT_ANNOUNCE
    info.notCheckable = true
    info.isTitle = true
    UIDropDownMenu_AddButton(info)

    info = {}
    info.text = L.LOOT_TO_RAID
    info.value = "raid"
    info.notCheckable = 1
    info.func = LDD_OnClick
    UIDropDownMenu_AddButton(info)

    info = {}
    info.text = L.LOOT_TO_GUILD
    info.value = "guild"
    info.notCheckable = 1
    info.func = LDD_OnClick
    UIDropDownMenu_AddButton(info)

    info = {}
    info.text = L.LOOT_TO_PARTY
    info.value = "party"
    info.notCheckable = 1
    info.func = LDD_OnClick
    UIDropDownMenu_AddButton(info)

    info = {}
    info.text = L.LOOT_TO_SAY
    info.value = "say"
    info.notCheckable = 1
    info.func = LDD_OnClick
    UIDropDownMenu_AddButton(info)

    info = nil
end

local ann = CreateFrame("Button", "LootLiteAnn", LootLite, "UIPanelScrollDownButtonTemplate")
local LDD = CreateFrame("Frame", "LootLiteLDD", LootLite, "UIDropDownMenuTemplate")

E:SkinCharButton(ann, LootLite, ">")

ann:SetSize(14, 14)
ann:ClearAllPoints()
ann:SetPoint("RIGHT", LootCloseButton, "LEFT", -4, 0)
ann:SetFrameStrata("DIALOG")
ann:RegisterForClicks("RightButtonUp", "LeftButtonUp")
ann:SetScript(
        "OnClick",
        function(_, button)
            if button == "RightButton" then
                ToggleDropDownMenu(nil, nil, LDD, ann, 0, 0)
            else
                Announce(E:CheckChat())
            end
        end
)

UIDropDownMenu_Initialize(LDD, LDD_Initialize, "MENU")
