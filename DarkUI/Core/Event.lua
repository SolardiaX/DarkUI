local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
-- Central Event Dispatcher
----------------------------------------------------------------------------------------

local Event = {}
E.Event = Event

local frame = CreateFrame("Frame")
local registry = {} -- [event] = { {handler, owner}, ... }

frame:SetScript("OnEvent", function(_, event, ...)
    local handlers = registry[event]
    if not handlers then
        return
    end

    for i = #handlers, 1, -1 do
        local entry = handlers[i]
        if entry then
            local handler, owner = entry[1], entry[2]
            if type(handler) == "function" then
                handler(owner, event, ...)
            elseif type(handler) == "string" and owner then
                local fn = owner[handler]
                if fn then
                    fn(owner, event, ...)
                end
            end
        end
    end
end)

function Event:Register(event, handler, owner)
    if not event or not handler then
        return
    end

    if event:find(" ") then
        for ev in event:gmatch("%S+") do
            self:Register(ev, handler, owner)
        end
        return
    end

    if not registry[event] then
        registry[event] = {}
        local ok = pcall(frame.RegisterEvent, frame, event)
        if not ok then
            registry[event] = nil
            return
        end
    end

    local handlers = registry[event]
    for _, entry in ipairs(handlers) do
        if entry[1] == handler and entry[2] == owner then
            return
        end
    end

    handlers[#handlers + 1] = { handler, owner }
end

function Event:Unregister(event, handler, owner)
    if event and event:find(" ") then
        for ev in event:gmatch("%S+") do
            self:Unregister(ev, handler, owner)
        end
        return
    end

    local handlers = registry[event]
    if not handlers then
        return
    end

    for i = #handlers, 1, -1 do
        local entry = handlers[i]
        if entry[1] == handler and entry[2] == owner then
            table.remove(handlers, i)
            break
        end
    end

    if #handlers == 0 then
        registry[event] = nil
        frame:UnregisterEvent(event)
    end
end

function Event:UnregisterAll(owner)
    for event, handlers in pairs(registry) do
        for i = #handlers, 1, -1 do
            if handlers[i][2] == owner then
                table.remove(handlers, i)
            end
        end
        if #handlers == 0 then
            registry[event] = nil
            frame:UnregisterEvent(event)
        end
    end
end

function Event:RegisterOnce(event, handler, owner)
    local wrapper
    wrapper = function(self, ev, ...)
        Event:Unregister(event, wrapper, owner or E)
        if type(handler) == "function" then
            handler(owner or self, ev, ...)
        end
    end
    Event:Register(event, wrapper, owner or E)
end

-- Convenience: register on E directly
function E:RegisterEvent(event, handler)
    Event:Register(event, handler, self)
end

function E:UnregisterEvent(event, handler)
    Event:Unregister(event, handler, self)
end
