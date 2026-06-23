local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Display
------------------------------------------------------------------------

local module = E:Module("CombatText")
local cfg = C.combat.combatText

local abs = math.abs

local MessageFrame = module.Display.MessageFrame
local MessageQueue = module.Display.MessageQueue

local POOL_SIZE = 30
local OUTBOUND_OVERFLOW_THRESHOLD = 5

local SCROLL_AREAS = {
    OUTBOUND = {
        enabled = true,
        point = "CENTER",
        startX = 300,
        startY = 100,
        width = 180,
        justify = "LEFT",
        horizontalCurveOffset = 0,
        horizontalReturnOffset = 0,
        scrollHeight = -220,
        scrollSpeed = 90,
        minimumVerticalSpacing = 8,
        iconSize = cfg.icon_size,
        iconPosition = "RIGHT",
    },
    OUTBOUND_SECONDARY = {
        enabled = true,
        point = "CENTER",
        startX = 375,
        startY = 100,
        width = 140,
        justify = "LEFT",
        horizontalCurveOffset = 0,
        horizontalReturnOffset = 0,
        scrollHeight = -220,
        scrollSpeed = 150,
        minimumVerticalSpacing = 8,
        iconSize = cfg.icon_size,
        iconPosition = "RIGHT",
    },
    INBOUND = {
        enabled = true,
        point = "CENTER",
        startX = -300,
        startY = 100,
        width = 160,
        justify = "RIGHT",
        horizontalCurveOffset = 0,
        horizontalReturnOffset = 0,
        scrollHeight = -200,
        scrollSpeed = 90,
        minimumVerticalSpacing = 8,
        iconSize = cfg.icon_size,
        iconPosition = "LEFT",
    },
    NOTIFICATION = {
        enabled = true,
        point = "CENTER",
        startX = 0,
        startY = 100,
        width = 300,
        justify = "CENTER",
        horizontalCurveOffset = 0,
        horizontalReturnOffset = 0,
        scrollHeight = 180,
        scrollSpeed = 90,
        minimumVerticalSpacing = 8,
        iconSize = cfg.icon_size,
        iconPosition = "LEFT",
    },
    STATIC = {
        enabled = true,
        point = "CENTER",
        startX = 0,
        startY = -200,
        width = 300,
        justify = "CENTER",
        horizontalCurveOffset = 0,
        horizontalReturnOffset = 0,
        scrollHeight = 0,
        scrollSpeed = 0,
        duration = 2,
        collisionMode = "STACK",
        minimumVerticalSpacing = 8,
        iconSize = cfg.icon_size,
        iconPosition = "LEFT",
    },
}

------------------------------------------------------------------------
-- Pool
------------------------------------------------------------------------

local animationFrame
local framePool = {}
local displayEventQueues = {}

local function createPool()
    animationFrame = CreateFrame("Frame", nil, UIParent)
    animationFrame:SetAllPoints(UIParent)

    for i = 1, POOL_SIZE do
        table.insert(framePool, MessageFrame.new(animationFrame))
    end

    for name, _ in pairs(SCROLL_AREAS) do
        displayEventQueues[name] = MessageQueue.new()
    end
end

local function getAvailableFrame()
    if #framePool > 0 then return table.remove(framePool) end
    return MessageFrame.new(animationFrame)
end

local function returnFrame(messageFrame)
    if not messageFrame then return end
    local fontString = messageFrame:GetFontString()
    messageFrame:GetFrame():Hide()
    messageFrame:GetFrame():ClearAllPoints()
    fontString:ClearAllPoints()
    fontString:SetText("")
    messageFrame:SetIcons(nil)
    messageFrame:SetCountText(nil)
    messageFrame:SetIconAlpha(1)
    messageFrame.iconContainer:ClearAllPoints()
    table.insert(framePool, messageFrame)
end

------------------------------------------------------------------------
-- Animation Callbacks
------------------------------------------------------------------------

local function onAnimationFinished(self)
    local wrapper = self.wrapper
    local displayEvent = wrapper.displayEvent
    local queue = displayEventQueues[displayEvent.queue]

    returnFrame(wrapper)
    queue:StopProcessing(displayEvent)
end

local function onVerticalUpdate(self)
    local wrapper = self.wrapper
    local displayEvent = wrapper.displayEvent
    local queue = displayEventQueues[displayEvent.queue]
    local attributes = wrapper.attributes

    if queue:IsEmpty() then return end

    if attributes.collisionMode == "STACK" then
        if not queue:IsEmpty() then queue:HandleNextMessage() end
        self:SetScript("OnUpdate", nil)
        return
    elseif attributes.scrollHeight == 0 or attributes.collisionMode == "REPLACE" then
        return
    end

    local eventProgress = self:GetProgress()
    local minCollisionDistance = attributes.iconSize + attributes.minimumVerticalSpacing
    local minCollisionPercent = minCollisionDistance / abs(attributes.scrollHeight)

    if eventProgress > minCollisionPercent then
        queue:HandleNextMessage()
        self:SetScript("OnUpdate", nil)
    end
end

------------------------------------------------------------------------
-- AnimateNextEvent
------------------------------------------------------------------------

local function animateNextEvent(displayEvent)
    if not displayEvent then return end

    local attributes = SCROLL_AREAS[displayEvent.queue]
    local messageFrame = displayEvent.messageFrame:GetFrame()
    local point = attributes.point or "CENTER"
    messageFrame:SetPoint(point, UIParent, point, attributes.startX, attributes.startY)

    local ag = displayEvent.messageFrame.animationGroup
    local verticalMove = displayEvent.messageFrame.verticalMove

    displayEvent.messageFrame.displayEvent = displayEvent
    displayEvent.messageFrame.attributes = attributes
    ag.wrapper = displayEvent.messageFrame
    verticalMove.wrapper = displayEvent.messageFrame

    displayEvent.messageFrame:SetAnimationAttributes(attributes)

    ag:SetScript("OnFinished", onAnimationFinished)
    verticalMove:SetScript("OnUpdate", onVerticalUpdate)

    messageFrame:Show()
    ag:Play()
end

for name, _ in pairs(SCROLL_AREAS) do
    -- queues will be created in Init, register handler later
end

------------------------------------------------------------------------
-- AnimateEvent (public entry point)
------------------------------------------------------------------------

local function animateEvent(displayEvent)
    if not displayEvent then return end

    for _, scrollFrameName in ipairs(displayEvent.eligibleScrollFrames) do
        if scrollFrameName == "OUTBOUND_SECONDARY" then break end

        displayEvent.queue = scrollFrameName

        local queue = displayEventQueues[displayEvent.queue]

        if displayEvent.queue == "OUTBOUND" and #queue.messages > OUTBOUND_OVERFLOW_THRESHOLD then
            local secArea = SCROLL_AREAS["OUTBOUND_SECONDARY"]
            if secArea and secArea.enabled then
                queue = displayEventQueues["OUTBOUND_SECONDARY"]
                displayEvent.queue = "OUTBOUND_SECONDARY"
            end
        end

        local attributes = SCROLL_AREAS[displayEvent.queue]

        local messageFrame = getAvailableFrame()
        local fontString = messageFrame:GetFontString()
        local frame = messageFrame:GetFrame()

        frame:SetWidth(attributes.width or 200)

        fontString:ClearAllPoints()
        local justify = attributes.justify or "CENTER"
        if justify == "LEFT" then
            fontString:SetPoint("LEFT", frame, "LEFT", 0, 0)
            fontString:SetJustifyH("LEFT")
        elseif justify == "RIGHT" then
            fontString:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
            fontString:SetJustifyH("RIGHT")
        else
            fontString:SetPoint("CENTER", frame, "CENTER", 0, 0)
            fontString:SetJustifyH("CENTER")
        end

        fontString:SetFont(cfg.font, displayEvent.isCrit and cfg.font_size_crit or cfg.font_size, cfg.font_style)
        fontString:SetText(displayEvent.message or "")

        local countString = messageFrame:GetCountString()
        if countString then countString:SetFont(cfg.font, cfg.font_size, cfg.font_style) end

        messageFrame:SetCountText(displayEvent.countText)

        if displayEvent.iconTexture and cfg.icons then
            messageFrame:SetIcons(displayEvent.iconTexture)
            if displayEvent.iconAlpha then
                messageFrame:SetIconAlpha(displayEvent.iconAlpha)
            else
                messageFrame:SetIconAlpha(1)
            end
        else
            messageFrame:SetIcons(nil)
        end

        displayEvent.messageFrame = messageFrame

        if attributes.collisionMode == "REPLACE" then
            queue.messages = {}
            for i = #queue.inProcess, 1, -1 do
                local evt = queue.inProcess[i]
                if evt.messageFrame and evt.messageFrame.animationGroup then
                    evt.messageFrame.animationGroup:Stop()
                    returnFrame(evt.messageFrame)
                    queue:StopProcessing(evt)
                end
            end
        elseif attributes.collisionMode == "STACK" then
            local yOffset = cfg.font_size + (attributes.minimumVerticalSpacing or 0)
            for _, existingEvent in ipairs(queue.inProcess) do
                if existingEvent.messageFrame then
                    local ef = existingEvent.messageFrame:GetFrame()
                    local pt, relativeTo, relativePoint, xOfs, yOfs = ef:GetPoint()
                    ef:ClearAllPoints()
                    ef:SetPoint(pt, relativeTo, relativePoint, xOfs, yOfs + yOffset)
                end
            end
        end

        queue:AddMessage(displayEvent)
        queue:Start()
    end
end

------------------------------------------------------------------------
-- Init & Public API
------------------------------------------------------------------------

local function init()
    createPool()
    for name, _ in pairs(SCROLL_AREAS) do
        displayEventQueues[name]:RegisterMessageHandler(animateNextEvent)
    end
end

local function clearCombatQueues()
    displayEventQueues.OUTBOUND:Clear()
    displayEventQueues.OUTBOUND_SECONDARY:Clear()
    displayEventQueues.INBOUND:Clear()
end

module.Display = module.Display or {}
module.Display.Init = init
module.Display.AnimateEvent = animateEvent
module.Display.ClearCombatQueues = clearCombatQueues
module.Display.SCROLL_AREAS = SCROLL_AREAS
module.Display.Queues = displayEventQueues
