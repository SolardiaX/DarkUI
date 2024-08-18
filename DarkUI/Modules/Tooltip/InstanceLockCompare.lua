local E, C, L = select(2, ...):unpack()

if C.tooltip.enable ~= true or C.tooltip.instance_lock ~= true then return end

----------------------------------------------------------------------------------------
--    Your instance lock status in tooltip(Instance Lock Compare by Dridzt)
----------------------------------------------------------------------------------------

local CreateFrame = CreateFrame
local GetNumSavedInstances = GetNumSavedInstances
local GetSavedInstanceChatLink = GetSavedInstanceChatLink
local GetSavedInstanceInfo = GetSavedInstanceInfo
local GetScreenWidth =GetScreenWidth
local UnitGUID = UnitGUID
local match, gsub = string.match, string.gsub
local hooksecurefunc = hooksecurefunc
local GameTooltip = GameTooltip
local ItemRefTooltip =ItemRefTooltip

local myTip = CreateFrame("GameTooltip", "InstanceLockTooltip", nil, "GameTooltipTemplate")

local function ILockCompare(frame, link)
    if not frame or not link then return end

    local linkType = match(link, "(instancelock):")
    if linkType == "instancelock" then
        local mylink, templink
        local myguid = UnitGUID("player")
        local guid = match(link, "instancelock:([^:]+)")

        if guid ~= myguid then
            local instanceguid = match(link, "instancelock:[^:]+:(%d+):")
            local numsaved = GetNumSavedInstances()
            if numsaved > 0 then
                for i = 1, numsaved do
                    local locked, extended = select(5, GetSavedInstanceInfo(i))
                    if extended or locked then
                        templink = GetSavedInstanceChatLink(i)
                        local myinstanceguid = match(templink, "instancelock:[^:]+:(%d+):")
                        if myinstanceguid == instanceguid then
                            mylink = match(templink, "(instancelock:[^:]+:%d+:%d+:%d+)")
                            break
                        end
                    end
                end
                mylink = mylink or gsub(link, "(instancelock:)([^:]+)(:%d+:%d+:)(%d+)", function(a, g, b, k)
                    g = myguid;
                    k = "0";
                    return a .. g .. b .. k
                end)
            else
                mylink = gsub(link, "(instancelock:)([^:]+)(:%d+:%d+:)(%d+)", function(a, g, b, k)
                    g = myguid;
                    k = "0";
                    return a .. g .. b .. k
                end)
            end
        end

        if mylink then
            if not myTip:IsVisible() and frame:IsVisible() then
                myTip:SetParent(frame)
                myTip:SetOwner(frame, "ANCHOR_NONE")
                myTip:SetTemplate("Transparent")

                local side = "left"
                local rightDist = 0
                local leftPos = frame:GetLeft()
                local rightPos = frame:GetRight()
                if not rightPos then
                    rightPos = 0
                end
                if not leftPos then
                    leftPos = 0
                end
                rightDist = GetScreenWidth() - rightPos
                if leftPos and (rightDist < leftPos) then
                    side = "left"
                else
                    side = "right"
                end
                myTip:ClearAllPoints()
                if side == "left" then
                    myTip:SetPoint("TOPRIGHT", frame, "TOPLEFT", -3, -10)
                elseif side == "right" then
                    myTip:SetPoint("TOPLEFT", frame, "TOPRIGHT", 3, -10)
                end
                myTip:SetHyperlink(mylink)
                myTip:Show()
            end
        end
    end
end

ItemRefTooltip:HookScript("OnDragStop", function(self)
    if myTip:IsVisible() and (myTip:GetParent():GetName() == self:GetName()) then
        local side = "left"
        local rightDist = 0
        local leftPos = self:GetLeft()
        local rightPos = self:GetRight()
        if not rightPos then
            rightPos = 0
        end
        if not leftPos then
            leftPos = 0
        end
        rightDist = GetScreenWidth() - rightPos
        if leftPos and (rightDist < leftPos) then
            side = "left"
        else
            side = "right"
        end
        myTip:ClearAllPoints()
        if side == "left" then
            myTip:SetPoint("TOPRIGHT", self, "TOPLEFT", -3, -10)
        elseif side == "right" then
            myTip:SetPoint("TOPLEFT", self, "TOPRIGHT", 3, -10)
        end
    end
end)

hooksecurefunc(GameTooltip, "SetHyperlink", ILockCompare)
hooksecurefunc(ItemRefTooltip, "SetHyperlink", ILockCompare)