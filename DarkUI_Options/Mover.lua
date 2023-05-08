local _, ns = ...

local function MakeMoveHandle(frame, text, group, key)
    local MoveHandle = CreateFrame("Frame", nil, UIParent)
    MoveHandle:SetWidth(frame:GetWidth())
    MoveHandle:SetHeight(frame:GetHeight())
    MoveHandle:SetFrameStrata("HIGH")
    MoveHandle:CreateBackdrop()
    MoveHandle:CreateFontText(12, text)
    MoveHandle:SetPoint(unpack(ns.Variable(group, key)))
    MoveHandle:EnableMouse(true)
    MoveHandle:SetMovable(true)
    MoveHandle:RegisterForDrag("LeftButton")
    MoveHandle:SetScript("OnDragStart", function() MoveHandle:StartMoving() end)
    MoveHandle:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local AnchorF, _, AnchorT, X, Y = self:GetPoint()
        ns.Variable(group, key, { AnchorF, "UIParent", AnchorT, X, Y })
    end)
    MoveHandle:Hide()

    frame:SetPoint("CENTER", MoveHandle)
    return MoveHandle
end
