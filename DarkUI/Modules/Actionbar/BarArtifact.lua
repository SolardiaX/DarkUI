local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable or not C.actionbar.bars.artifact.enable then return end

------------------------------------------------------
-- Artifact Bar
------------------------------------------------------

local _G = _G
local CreateFrame = CreateFrame
local C_ArtifactUI_GetCostForPointAtRank = C_ArtifactUI.GetCostForPointAtRank
local C_ArtifactUI_GetEquippedArtifactInfo = C_ArtifactUI.GetEquippedArtifactInfo
local C_ArtifactUI_IsEquippedArtifactDisabled = C_ArtifactUI.IsEquippedArtifactDisabled
local C_AzeriteItem_HasActiveAzeriteItem = C_AzeriteItem.HasActiveAzeriteItem
local C_AzeriteItem_FindActiveAzeriteItem = C_AzeriteItem.FindActiveAzeriteItem
local C_AzeriteItem_GetAzeriteItemXPInfo = C_AzeriteItem.GetAzeriteItemXPInfo
local C_AzeriteItem_GetPowerLevel = C_AzeriteItem.GetPowerLevel
local HasArtifactEquipped = HasArtifactEquipped
local Item = Item
local unpack = unpack
local MAX_PLAYER_LEVEL, NORMAL_FONT_COLOR = MAX_PLAYER_LEVEL, NORMAL_FONT_COLOR
local GameTooltip = _G.GameTooltip
local UIParent = _G.UIParent

local cfg = C.actionbar.bars.artifact

local function getNumArtifactTraitsPurchasableFromXP(pointsSpent, artifactXP, artifactTier)
    local numPoints = 0
    local xpForNextPoint = C_ArtifactUI_GetCostForPointAtRank(pointsSpent, artifactTier)

    while artifactXP >= xpForNextPoint and xpForNextPoint > 0 do
        artifactXP = artifactXP - xpForNextPoint

        pointsSpent = pointsSpent + 1
        numPoints = numPoints + 1

        xpForNextPoint = C_ArtifactUI_GetCostForPointAtRank(pointsSpent, artifactTier)
    end

    return numPoints, artifactXP, xpForNextPoint
end

local function bar_OnEvent(self, _, ...)
    if HasArtifactEquipped() then
        local _, _, name, _, totalPower, traitsLearned, _, _, _, _, _, _, tier = C_ArtifactUI_GetEquippedArtifactInfo()
        local _, power, powerForNextTrait = getNumArtifactTraitsPurchasableFromXP(traitsLearned, totalPower, tier)

        if C_ArtifactUI_IsEquippedArtifactDisabled() then
            self:SetStatusBarColor(.6, .6, .6)
            self:SetMinMaxValues(0, 1)
            self:SetValue(1)
        else
            self:SetMinMaxValues(0, powerForNextTrait)
            self:SetValue(power)
        end

        self.name = name
        self.power = power
        self.powerForNext = powerForNextTrait
        self.totalPower = totalPower

        self:Show()
    elseif C_AzeriteItem_HasActiveAzeriteItem() then
        local azeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem()
        local azeriteItem = Item:CreateFromItemLocation(azeriteItemLocation)
        local azeriteItemName = azeriteItem:GetItemName()
        local xp, totalLevelXP = C_AzeriteItem_GetAzeriteItemXPInfo(azeriteItemLocation)

        self:SetStatusBarColor(.9, .8, .6)
        self:SetMinMaxValues(0, totalLevelXP)
        self:SetValue(xp)

        self.name = azeriteItemName
        self.power = xp
        self.powerForNext = totalLevelXP
        self.totalPower = C_AzeriteItem_GetPowerLevel(azeriteItemLocation)

        self:Show()
    end
end

local function bar_OnEnter(self)
    GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")

    GameTooltip:AddLine(L.ACTIONBAR_APB)
    if not HasArtifactEquipped() and not C_AzeriteItem_HasActiveAzeriteItem() then
        GameTooltip:AddDoubleLine(L.ACTIONBAR_AP_NAME, "N/A")
    else
        GameTooltip:AddDoubleLine(L.ACTIONBAR_AP_NAME, self.name, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1, 1, 1)
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(L.ACTIONBAR_AP_TOTAL, (self.totalPower or "N/A") .. "|cffffd100|r")
        GameTooltip:AddDoubleLine(L.ACTIONBAR_AP_UPGRADE, (self.power or "N/A") .. "|cffffd100 /|r" .. (self.powerForNext or "N/A") .. "|cffffd100|r")
    end
    GameTooltip:Show()
end

local function bar_OnLeave()
    GameTooltip:Hide()
end

if cfg.only_at_max_level and E.level < MAX_PLAYER_LEVEL then
    local holder = CreateFrame("Frame", nil, UIParent)
    holder:SetFrameStrata(cfg.bfstrata)
    holder:SetFrameLevel(cfg.bflevel)
    holder:SetSize(cfg.width, cfg.height)
    holder:SetPoint(unpack(cfg.pos))
    holder:SetScale(cfg.scale)

    holder.texture = holder:CreateTexture(nil, "BACKGROUND")
    holder.texture:SetTexture(cfg.statusbar)
    holder.texture:SetAllPoints(holder)
    holder.texture:SetVertexColor(1 / 255, 1 / 255, 1 / 255)

    return
end

local statusbar = CreateFrame("StatusBar", "DarkUI_ArtifactBar", UIParent)
statusbar:SetFrameStrata(cfg.bfstrata)
statusbar:SetFrameLevel(cfg.bflevel)
statusbar:SetSize(cfg.width, cfg.height)
statusbar:SetPoint(unpack(cfg.pos))
statusbar:SetScale(cfg.scale)
statusbar:SetStatusBarTexture(cfg.statusbar)
statusbar:SetStatusBarColor(E.color.r, E.color.g, E.color.b)

statusbar.background = statusbar:CreateTexture(nil, "BACKGROUND", nil, -7)
statusbar.background:SetAllPoints()
statusbar.background:SetTexture(cfg.statusbar)
statusbar.background:SetVertexColor(1, 0, 0, 0.3)

statusbar:SetScript("OnEvent", bar_OnEvent)
statusbar:SetScript("OnEnter", bar_OnEnter)
statusbar:SetScript("OnLeave", bar_OnLeave)

statusbar:RegisterEvent("ARTIFACT_XP_UPDATE")
statusbar:RegisterEvent("UNIT_INVENTORY_CHANGED")
statusbar:RegisterEvent("PLAYER_ENTERING_WORLD")
