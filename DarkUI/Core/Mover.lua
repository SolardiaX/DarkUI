local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
--	Core Mover Methods
----------------------------------------------------------------------------------------
local string_format, math_abs = string.format, math.abs

local Colors = {
    highlight = {250/255, 250/255, 250/255},
    green = {25/255, 178/255, 25/255},
    normal = {229/255, 178/255, 38/255}
}

local function getVariable(t, vkey)
    for k in gmatch(vkey, "([^.%s]+)") do
        t = t[k]
        if t == nil then return end
    end

    return t
end

-- Get a properly parsed position of a frame,
-- relative to UIParent and the frame's scale.
local getPosition = function(frame)
    -- Retrieve UI coordinates, convert to unscaled screen coordinates
    local worldHeight = WorldFrame:GetHeight() -- 768 -- 
    local worldWidth = WorldFrame:GetWidth()
    local uiScale = UIParent:GetEffectiveScale()
    local uiWidth = UIParent:GetWidth() * uiScale
    local uiHeight = UIParent:GetHeight() * uiScale
    local uiBottom = UIParent:GetBottom() * uiScale
    local uiLeft = UIParent:GetLeft() * uiScale
    local uiTop = UIParent:GetTop() * uiScale - worldHeight -- use values relative to edges, not origin
    local uiRight = UIParent:GetRight() * uiScale - worldWidth -- use values relative to edges, not origin

    -- Retrieve frame coordinates, convert to unscaled screen coordinates
    local frameScale = frame:GetEffectiveScale()
    local x, y = frame:GetCenter(); x = x * frameScale; y = y * frameScale
    local bottom = frame:GetBottom() * frameScale
    local left = frame:GetLeft() * frameScale
    local top = frame:GetTop() * frameScale - worldHeight -- use values relative to edges, not origin
    local right = frame:GetRight() * frameScale - worldWidth -- use values relative to edges, not origin

    -- Figure out the frame position relative to UIParent
    left = left - uiLeft
    bottom = bottom - uiBottom
    right = right - uiRight
    top = top - uiTop

    -- Figure out the point within the given coordinate space,
    -- return values converted to the frame's own scale.
    if (y < uiHeight * 1/3) then
        if (x < uiWidth * 1/3) then
            return "BOTTOMLEFT", left / frameScale, bottom / frameScale
        elseif (x > uiWidth * 2/3) then
            return "BOTTOMRIGHT", right / frameScale, bottom / frameScale
        else
            return "BOTTOM", (x - uiWidth/2) / frameScale, bottom / frameScale
        end
    elseif (y > uiHeight * 2/3) then
        if (x < uiWidth * 1/3) then
            return "TOPLEFT", left / frameScale, top / frameScale
        elseif x > uiWidth * 2/3 then
            return "TOPRIGHT", right / frameScale, top / frameScale
        else
            return "TOP", (x - uiWidth/2) / frameScale, top / frameScale
        end
    else
        if (x < uiWidth * 1/3) then
            return "LEFT", left / frameScale, (y - uiHeight/2) / frameScale
        elseif (x > uiWidth * 2/3) then
            return "RIGHT", right / frameScale, (y - uiHeight/2) / frameScale
        else
            return "CENTER", (x - uiWidth/2) / frameScale, (y - uiHeight/2) / frameScale
        end
    end
end

-- Anchor Template
--------------------------------------
local Anchor = {}

-- Constructor
Anchor.Create = function(self, frame, name, vkey)
    local anchor = CreateFrame("Button", nil, UIParent)

    for method, func in next, Anchor do
        if method ~= "Create" then
            anchor[method] = func
        end
    end

    anchor:Hide()
    anchor:Enable()
    anchor:SetFrameStrata("HIGH")
    anchor:SetFrameLevel(1000)
    anchor:SetAllPoints(frame)
    anchor:SetMovable(true)
    anchor:SetHitRectInsets(-20,-20,-20,-20)
    anchor:RegisterForDrag("LeftButton")
    anchor:RegisterForClicks("AnyUp")
    anchor:SetScript("OnDragStart", self.OnDragStart)
    anchor:SetScript("OnDragStop", self.OnDragStop)
    anchor:SetScript("OnClick", self.OnClick)
    anchor:SetScript("OnShow", self.OnShow)
    anchor:SetScript("OnHide", self.OnHide)
    anchor:SetScript("OnEnter", self.OnEnter)
    anchor:SetScript("OnLeave", self.OnLeave)

    local overlay = CreateFrame("Frame", nil, anchor, "BackdropTemplate")
    overlay:SetAllPoints()
    overlay:SetBackdrop({
        bgFile =[[Interface\Tooltips\UI-Tooltip-Background]],
        tile = true,
        tileSize = 16,
        edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
        edgeSize = 16,
        insets = { left = 5, right = 3, top = 3, bottom = 5 }
    })
    overlay:SetBackdropColor(.5, 1, .5, .75)
    overlay:SetBackdropBorderColor(.5, 1, .5, 1)
    anchor.overlay = overlay

    anchor.name = overlay:CreateFontText(13, "")
    anchor.name:SetTextColor(unpack(Colors.highlight))
    anchor.name:SetIgnoreParentScale(true)
    anchor.name:SetIgnoreParentAlpha(true)
    anchor.name:SetJustifyV("MIDDLE")
    anchor.name:SetJustifyH("CENTER")
    anchor.name:SetText(name)

    anchor.hint = overlay:CreateFontText(13, "")
    anchor.hint:SetTextColor(unpack(Colors.highlight))
    anchor.hint:SetIgnoreParentScale(true)
    anchor.hint:SetIgnoreParentAlpha(true)
    anchor.hint:SetPoint("TOP", overlay, "BOTTOM", -20)
    anchor.hint:SetText("")

    anchor.vkey = vkey
    anchor.position = { getPosition(anchor) }
    anchor.frame = frame

    return anchor
end

Anchor.Enable = function(self)
    self.enabled = true
end

Anchor.Disable = function(self)
    self.enabled = false
end

Anchor.IsEnabled = function(self)
    return self.enabled
end

Anchor.SetEnabled = function(self, enable)
    self.enabled = enable and true or false
end

Anchor.UpdateHint = function(self)
    local msg = string_format(E:RGBToHex(Colors.highlight).."%s, %.0f, %.0f|r", unpack(self.position))
    msg = msg .. E:RGBToHex(Colors.green) .."\n<Left-Click and drag to move>|r"
    msg = msg .. E:RGBToHex(Colors.green) .."\n<Right-Click to undo change>|r"

    self.hint:SetText(msg)
    self.hint:Show()
end

-- Anchor Script Handlers
--------------------------------------
Anchor.OnDragStart = function(self, button)
    self:StartMoving()
    self:SetUserPlaced(false)
    self.elapsed = 0
    self:SetScript("OnUpdate", self.OnUpdate)
end

Anchor.OnDragStop = function(self)
    self:StopMovingOrSizing()
    self:SetScript("OnUpdate", nil)
    self.frame:ClearAllPoints()
    self.frame:SetPoint(unpack(self.position))
end

Anchor.OnClick = function(self, button)
    if (button == "RightButton") then
        self.frame:ClearAllPoints()
        self.frame:SetPoint(unpack(getVariable(C, self.vkey)))
    end
end

Anchor.OnShow = function(self)
    self:SetFrameLevel(50)
    self:SetAlpha(.75)
end

Anchor.OnHide = function(self)
    self:SetScript("OnUpdate", nil)
    self.elapsed = 0
end

Anchor.OnEnter = function(self)
    self:UpdateHint()
    self:SetAlpha(1)
end

Anchor.OnLeave = function(self)
    self:UpdateHint()
    self:SetAlpha(.75)
end

Anchor.OnUpdate = function(self, elapsed)
    self.elapsed = self.elapsed + elapsed
    if (self.elapsed < 0.02) then
        return
    end
    self.elapsed = 0

    self.position = { getPosition(self) }

    self:UpdateHint()
end

-- local default = CreateFrame("Frame", "TestMoverFrame", UIParent)
-- default:SetSize(64, 64)
-- default:SetPoint("CENTER", UIParent, -150, 200)
-- default:SetTemplate("Default")
-- default:CreateFontText(12, "Default", false, "TOP", 0, 15)

-- local mover = Anchor:Create(default, "Default Tooltip", "tooltip.position")
-- mover:Show()
