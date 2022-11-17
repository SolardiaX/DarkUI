local _, ns = ...
local E, C, L = ns:unpack()

if not C.stats.enable or not C.stats.config.Bags.enable then return end

----------------------------------------------------------------------------------------
--	Bags of DataText (modified from ShestakUI)
----------------------------------------------------------------------------------------

local GetContainerNumFreeSlots, GetContainerNumSlots = C_Container.GetContainerNumFreeSlots, C_Container.GetContainerNumSlots
local GetBindingKey = GetBindingKey
local ToggleAllBags = ToggleAllBags
local format = format
local NUM_BAG_SLOTS, NUM_FREE_SLOTS = NUM_BAG_SLOTS, NUM_FREE_SLOTS
local BACKPACK_TOOLTIP = BACKPACK_TOOLTIP
local GameTooltip = GameTooltip

local cfg = C.stats.config.Bags
local module = E.datatext

module:Inject("Bags", {
    OnLoad  = function(self) module:RegEvents(self, "PLAYER_LOGIN BAG_UPDATE") end,
    OnEvent = function(self)
        local free, total = 0, 0
        for i = 0, NUM_BAG_SLOTS do
            free, total = free + GetContainerNumFreeSlots(i), total + GetContainerNumSlots(i)
        end
        self.text:SetText(format(cfg.fmt, free, total))
    end,
    OnClick = function()
        local cb = cargBags or ns.cargBags
        if cb then
            cb.blizzard:Toggle()
        else
            ToggleAllBags()
        end
    end,
    OnEnter = function(self)
        local free, total = 0, 0
        for i = 0, NUM_BAG_SLOTS do
            free, total = free + GetContainerNumFreeSlots(i), total + GetContainerNumSlots(i)
        end
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", -3, 26)
        GameTooltip:ClearLines()
        if GetBindingKey("TOGGLEBACKPACK") then
            GameTooltip:AddLine(BACKPACK_TOOLTIP .. " (" .. GetBindingKey("TOGGLEBACKPACK") .. ")", module.tthead.r, module.tthead.g, module.tthead.b)
        else
            GameTooltip:AddLine(BACKPACK_TOOLTIP, module.tthead.r, module.tthead.g, module.tthead.b)
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(format(NUM_FREE_SLOTS, free, total), 1, 1, 1)
        GameTooltip:Show()
    end,
    OnLeave = function()
        GameTooltip:Hide()
    end,
})