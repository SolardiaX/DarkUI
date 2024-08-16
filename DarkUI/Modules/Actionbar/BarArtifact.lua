local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable or not C.actionbar.bars.artifact.enable then return end

----------------------------------------------------------------------------------------
-- Artifact Bar
----------------------------------------------------------------------------------------
local module = E:Module("Actionbar"):Sub("Artifact")

local _G = _G
local CreateFrame = CreateFrame
local C_ArtifactUI_GetEquippedArtifactInfo = C_ArtifactUI.GetEquippedArtifactInfo
local C_ArtifactUI_IsEquippedArtifactDisabled = C_ArtifactUI.IsEquippedArtifactDisabled
local C_AzeriteItem_HasActiveAzeriteItem = C_AzeriteItem.HasActiveAzeriteItem
local C_AzeriteItem_FindActiveAzeriteItem = C_AzeriteItem.FindActiveAzeriteItem
local C_AzeriteItem_IsAzeriteItemAtMaxLevel = C_AzeriteItem.IsAzeriteItemAtMaxLevel
local C_AzeriteItem_GetAzeriteItemXPInfo = C_AzeriteItem.GetAzeriteItemXPInfo
local C_AzeriteItem_GetPowerLevel = C_AzeriteItem.GetPowerLevel
local HasArtifactEquipped = HasArtifactEquipped
local Item = Item
local unpack = unpack
local MAX_PLAYER_LEVEL, NORMAL_FONT_COLOR = GetMaxPlayerLevel(), NORMAL_FONT_COLOR
local GameTooltip = _G.GameTooltip
local UIParent = _G.UIParent

local cfg = C.actionbar.bars.artifact

local function isAzeriteAvailable()
    local itemLocation = C_AzeriteItem_FindActiveAzeriteItem()
    return itemLocation and itemLocation:IsEquipmentSlot() and not C_AzeriteItem_IsAzeriteItemAtMaxLevel()
end

local function bar_OnEvent(self, _, ...)
    if isAzeriteAvailable() and HasArtifactEquipped() then
        module.holder:Hide()
        module.statusbar:Show()
    else
        module.holder:Show()
        module.statusbar:Hide()
        return
    end

    if isAzeriteAvailable() then
        local azeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem()
        local xp, totalLevelXP = C_AzeriteItem_GetAzeriteItemXPInfo(azeriteItemLocation)
        self:SetStatusBarColor(.9, .8, .6)
        self:SetMinMaxValues(0, totalLevelXP)
        self:SetValue(xp)
    elseif HasArtifactEquipped() then
        if C_ArtifactUI_IsEquippedArtifactDisabled() then
            self:SetStatusBarColor(.6, .6, .6)
            self:SetMinMaxValues(0, 1)
            self:SetValue(1)
        else
            local _, _, _, _, totalPower, pointsSpent, _, _, _, _, _, _, artifactTier = C_ArtifactUI_GetEquippedArtifactInfo()
            local _, power, powerForNextPoint = ArtifactBarGetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP, artifactTier)
            power = powerForNextPoint == 0 and 0 or xp
            self:SetStatusBarColor(.9, .8, .6)
            self:SetMinMaxValues(0, powerForNextPoint)
            self:SetValue(power)            
        end
    end
end

local function bar_OnEnter(self)
    GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
    GameTooltip:AddLine(L.ACTIONBAR_APB)
    GameTooltip:AddLine(" ")

    if isAzeriteAvailable() then
        local azeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem()
        local azeriteItem = Item:CreateFromItemLocation(azeriteItemLocation)
        local xp, totalLevelXP = C_AzeriteItem_GetAzeriteItemXPInfo(azeriteItemLocation)
        local currentLevel = C_AzeriteItem_GetPowerLevel(azeriteItemLocation)
        azeriteItem:ContinueWithCancelOnItemLoad(function()
            GameTooltip:AddLine(azeriteItem:GetItemName().." ("..format(SPELLBOOK_AVAILABLE_AT, currentLevel)..")", 0, .6, 1)
            GameTooltip:AddDoubleLine(ARTIFACT_POWER, BreakUpLargeNumbers(xp).." / "..BreakUpLargeNumbers(totalLevelXP).." ("..floor(xp/totalLevelXP*100).."%)", .6, .8, 1, 1, 1, 1)
        end)
    elseif HasArtifactEquipped() then
        local _, _, name, _, totalXP, pointsSpent, _, _, _, _, _, _, artifactTier = C_ArtifactUI_GetEquippedArtifactInfo()
        local num, xp, xpForNextPoint = ArtifactBarGetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP, artifactTier)
        
        if C_ArtifactUI_IsEquippedArtifactDisabled() then
            GameTooltip:AddLine(name, 0, .6, 1)
            GameTooltip:AddLine(ARTIFACT_RETIRED, .6, .8, 1, 1)
        else
            GameTooltip:AddLine(name.." ("..format(SPELLBOOK_AVAILABLE_AT, pointsSpent)..")", 0,.6,1)
            local numText = num > 0 and " ("..num..")" or ""
            GameTooltip:AddDoubleLine(ARTIFACT_POWER, BreakUpLargeNumbers(totalXP)..numText, .6, .8, 1, 1, 1, 1)
            if xpForNextPoint ~= 0 then
                local perc = " ("..floor(xp/xpForNextPoint*100).."%)"
                GameTooltip:AddDoubleLine(L.ACTIONBAR_AP_UPGRADE, BreakUpLargeNumbers(xp).." / "..BreakUpLargeNumbers(xpForNextPoint)..perc, .6, .8, 1, 1, 1, 1)
            end
        end
    else
        GameTooltip:AddDoubleLine(L.ACTIONBAR_AP_NAME, "N/A")
    end

    GameTooltip:Show()
end

local function bar_OnLeave()
    GameTooltip:Hide()
end

function module:OnInit()
    local holder = CreateFrame("Frame", nil, UIParent)
    holder:SetFrameStrata(cfg.bfstrata)
    holder:SetFrameLevel(cfg.bflevel)
    holder:SetSize(cfg.width, cfg.height)
    holder:SetPoint(unpack(cfg.pos))
    holder:SetScale(cfg.scale)

    holder.texture = holder:CreateTexture(nil, "BACKGROUND")
    holder.texture:SetTexture(C.media.texture.status)
    holder.texture:SetAllPoints(holder)
    holder.texture:SetVertexColor(1 / 255, 1 / 255, 1 / 255)

    local statusbar = CreateFrame("StatusBar", "DarkUI_ArtifactBar", UIParent)
    statusbar:SetFrameStrata(cfg.bfstrata)
    statusbar:SetFrameLevel(cfg.bflevel)
    statusbar:SetSize(cfg.width, cfg.height)
    statusbar:SetPoint(unpack(cfg.pos))
    statusbar:SetScale(cfg.scale)
    statusbar:SetStatusBarTexture(C.media.texture.status)
    statusbar:SetStatusBarColor(E.myColor.r, E.myColor.g, E.myColor.b)

    statusbar.background = statusbar:CreateTexture(nil, "BACKGROUND", nil, -7)
    statusbar.background:SetAllPoints()
    statusbar.background:SetTexture(C.media.texture.status)
    statusbar.background:SetVertexColor(1, 0, 0, 0.3)
    
    statusbar:SetScript("OnEvent", bar_OnEvent)
    statusbar:SetScript("OnEnter", bar_OnEnter)
    statusbar:SetScript("OnLeave", bar_OnLeave)

    statusbar:RegisterEvent("ARTIFACT_XP_UPDATE")
    statusbar:RegisterEvent("UNIT_INVENTORY_CHANGED")
    statusbar:RegisterEvent("PLAYER_ENTERING_WORLD")

    module.holder = holder
    module.statusbar = statusbar
end