local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Instance Lock Compare
------------------------------------------------------------------------

local module = E:Module("Tooltip"):Sub("InstanceLockCompare")
local cfg = C.tooltip

local match, gsub = string.match, string.gsub

local myTip

local function anchorToSide(tip, anchor)
    local leftPos = anchor:GetLeft() or 0
    local rightPos = anchor:GetRight() or 0
    local rightDist = GetScreenWidth() - rightPos

    tip:ClearAllPoints()
    if leftPos and (rightDist < leftPos) then
        tip:SetPoint("TOPRIGHT", anchor, "TOPLEFT", -3, -10)
    else
        tip:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 3, -10)
    end
end

local function instanceLockCompare(frame, link)
    if not frame or not link then return end

    local linkType = match(link, "(instancelock):")
    if linkType ~= "instancelock" then return end

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
                g = myguid
                k = "0"
                return a .. g .. b .. k
            end)
        else
            mylink = gsub(link, "(instancelock:)([^:]+)(:%d+:%d+:)(%d+)", function(a, g, b, k)
                g = myguid
                k = "0"
                return a .. g .. b .. k
            end)
        end
    end

    if mylink then
        if not myTip:IsVisible() and frame:IsVisible() then
            myTip:SetParent(frame)
            myTip:SetOwner(frame, "ANCHOR_NONE")
            myTip:SetTemplate("Transparent")
            anchorToSide(myTip, frame)
            myTip:SetHyperlink(mylink)
            myTip:Show()
        end
    end
end

function module:OnInit()
    if not cfg.enable or not cfg.instance_lock then return end

    myTip = CreateFrame("GameTooltip", "InstanceLockTooltip", nil, "GameTooltipTemplate")

    ItemRefTooltip:HookScript("OnDragStop", function(self)
        if myTip:IsVisible() and (myTip:GetParent():GetName() == self:GetName()) then
            anchorToSide(myTip, self)
        end
    end)

    hooksecurefunc(GameTooltip, "SetHyperlink", instanceLockCompare)
    hooksecurefunc(ItemRefTooltip, "SetHyperlink", instanceLockCompare)
end
