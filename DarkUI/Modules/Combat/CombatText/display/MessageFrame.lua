local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- MessageFrame
------------------------------------------------------------------------

local module = E:Module("CombatText")
local cfg = C.combat.combatText

local MessageFrame = {}
MessageFrame.__index = MessageFrame

function MessageFrame.new(parent)
    local self = setmetatable({}, MessageFrame)

    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(200, 22)
    frame:Hide()

    local fontString = frame:CreateFontString(nil, "OVERLAY")
    fontString:SetFont(cfg.font, cfg.font_size, cfg.font_style)
    fontString:SetShadowOffset(1, -1)

    local iconContainer = CreateFrame("Frame", nil, frame)
    local countString = iconContainer:CreateFontString(nil, "OVERLAY")
    countString:SetFont(cfg.font, cfg.font_size - 2, cfg.font_style)

    local animationGroup = frame:CreateAnimationGroup()

    self.frame = frame
    self.parent = parent
    self.fontString = fontString
    self.iconContainer = iconContainer
    self.countString = countString
    self.iconTextures = {}
    self.numActiveIcons = 0
    self.animationGroup = animationGroup
    self.verticalMove = animationGroup:CreateAnimation("Translation")
    self.horizontalCurve = animationGroup:CreateAnimation("Translation")
    self.horizontalReturn = animationGroup:CreateAnimation("Translation")
    self.fadeOut = animationGroup:CreateAnimation("Alpha")

    return self
end

function MessageFrame:GetFontString() return self.fontString end

function MessageFrame:GetFrame() return self.frame end

function MessageFrame:GetCountString() return self.countString end

function MessageFrame:SetCountText(text) self.countString:SetText(text or "") end

function MessageFrame:SetIcons(icons)
    for _, texture in ipairs(self.iconTextures) do
        texture:Hide()
    end
    self.numActiveIcons = 0

    if not icons then return end

    local iconList = type(icons) == "table" and icons or { icons }

    for i, iconPath in ipairs(iconList) do
        if not self.iconTextures[i] then self.iconTextures[i] = self.iconContainer:CreateTexture(nil, "ARTWORK") end
        self.iconTextures[i]:SetTexture(iconPath)
        self.iconTextures[i]:Show()
        self.numActiveIcons = i
    end
end

function MessageFrame:SetIconAlpha(alpha) self.iconContainer:SetAlpha(alpha) end

function MessageFrame:SetAnimationAttributes(attributes)
    local iconMountPoint = attributes.iconPosition == "RIGHT" and "LEFT" or "RIGHT"
    local iconHorizontalOffset = attributes.iconPosition == "RIGHT" and 10 or -10

    local iconSize = attributes.iconSize
    local spacing = 2
    local numIcons = self.numActiveIcons or 0
    local countWidth = 0

    if self.countString:GetText() and self.countString:GetText() ~= "" then countWidth = 30 end

    if numIcons > 0 then
        local width = (numIcons * iconSize) + ((numIcons - 1) * spacing)
        local totalWidth = width + countWidth
        self.iconContainer:SetSize(totalWidth, iconSize)

        for i = 1, numIcons do
            local tex = self.iconTextures[i]
            tex:ClearAllPoints()
            if i == 1 then
                tex:SetPoint("LEFT", self.iconContainer, "LEFT", 0, 0)
                tex:SetSize(iconSize, iconSize)
            else
                tex:SetSize(iconSize * 0.7, iconSize * 0.7)
                tex:SetPoint("LEFT", self.iconTextures[i - 1], "RIGHT", spacing, 0)
            end
        end

        self.countString:ClearAllPoints()
        self.countString:SetPoint("LEFT", self.iconTextures[numIcons], "RIGHT", spacing, 0)
    else
        if countWidth > 0 then
            self.iconContainer:SetSize(countWidth, iconSize)
            self.countString:ClearAllPoints()
            self.countString:SetPoint("LEFT", self.iconContainer, "LEFT", 0, 0)
        else
            self.iconContainer:SetSize(1, 1)
        end
    end

    self.iconContainer:SetPoint(iconMountPoint, self.fontString, attributes.iconPosition, iconHorizontalOffset, 0)

    local scrollTime = attributes.duration or (attributes.scrollHeight ~= 0 and math.abs(attributes.scrollHeight) / attributes.scrollSpeed or 2)

    if attributes.reverseDirection then
        local point, relativeTo, relativePoint, xOfs, yOfs = self.frame:GetPoint(1)
        if point then self.frame:SetPoint(point, relativeTo, relativePoint, xOfs or 0, (yOfs or 0) - (attributes.scrollHeight or 0)) end
    end

    local directionMultiplier = attributes.reverseDirection and 1 or -1
    self.verticalMove:SetOffset(0, directionMultiplier * attributes.scrollHeight)
    self.verticalMove:SetDuration(scrollTime)
    self.verticalMove:SetSmoothing("NONE")

    self.horizontalCurve:SetOffset(attributes.horizontalCurveOffset, 0)
    self.horizontalCurve:SetDuration(scrollTime * 0.6)
    self.horizontalCurve:SetSmoothing("OUT")

    self.horizontalReturn:SetOffset(attributes.horizontalReturnOffset, 0)
    self.horizontalReturn:SetStartDelay(scrollTime * 0.4)
    self.horizontalReturn:SetDuration(scrollTime * 0.6)
    self.horizontalReturn:SetSmoothing("IN")

    self.fadeOut:SetFromAlpha(1)
    self.fadeOut:SetToAlpha(0)
    self.fadeOut:SetStartDelay(scrollTime * 0.6)
    self.fadeOut:SetDuration(scrollTime * 0.4)
    self.fadeOut:SetSmoothing("IN")
end

module.Display = module.Display or {}
module.Display.MessageFrame = MessageFrame
