local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- MessageQueue
------------------------------------------------------------------------

local module = E:Module("CombatText")

local MessageQueue = {}
MessageQueue.__index = MessageQueue

function MessageQueue.new()
    local self = setmetatable({}, MessageQueue)
    self.active = false
    self.messages = {}
    self.inProcess = {}
    return self
end

function MessageQueue:RegisterMessageHandler(handlerFunction)
    if type(handlerFunction) ~= "function" then
        return
    end
    self.handlerFunction = handlerFunction
end

function MessageQueue:AddMessage(message)
    table.insert(self.messages, message)
end

function MessageQueue:HandleNextMessage()
    if #self.messages == 0 then
        return
    end
    local message = table.remove(self.messages, 1)
    table.insert(self.inProcess, message)
    self.handlerFunction(message)
end

function MessageQueue:StopProcessing(message)
    for i, v in ipairs(self.inProcess) do
        if v == message then
            table.remove(self.inProcess, i)
        end
    end
    if #self.inProcess == 0 and #self.messages == 0 then
        self.active = false
    end
end

function MessageQueue:IsEmpty()
    if #self.messages == 0 then
        return true
    end
    return false
end

function MessageQueue:Start()
    if not self.active then
        self.active = true
        self:HandleNextMessage()
    end
end

function MessageQueue:Stop()
    self.active = false
end

function MessageQueue:Clear()
    wipe(self.messages)
end

module.Display = module.Display or {}
module.Display.MessageQueue = MessageQueue
