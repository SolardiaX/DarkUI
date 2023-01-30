local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
--	Core Module Methods
----------------------------------------------------------------------------------------
local CreateFrame = CreateFrame
local tinsert, pairs, gmatch = tinsert, pairs, string.gmatch
local modules = {}

local function checkEventHost(module)
    if not module.host then
        module.host = CreateFrame("Frame")
        module.host.events = {}

        module.host:SetScript("OnEvent", function(self, event, ...)
             if self.OnEvent ~= nil then
                local onEvent = self.OnEvent

                if type(onEvent) == "function" then
                    onEvent(module, event, ...)
                elseif type(onEvent) == "string" then
                    onEvent = module[onEvent]
                    if onEvent and type(onEvent) == "function" then
                        onEvent(module, event, ...)
                    end
                end
            end

            if not self.events[event] then return end

            local funcs = self.events[event]

            local function trigger(event, ...)
                local f = module[event]
                if f and type(f) == "function" then
                    f(module, event, ...)
                end

                for _, v in next, funcs do
                    if type(v) == 'string' then
                        local f = module[v]
                        if f and type(f) == "function" then
                            f(module, event, ...)
                        end
                        trigger(v, ...)
                    else
                        v(module, event, ...)
                    end
                end
            end

            trigger(event, ...)
        end)
    end
end

local function registerEvent(module, event, func)
    checkEventHost(module)

    for e in gmatch(event, "([^,%s]+)") do
        if not module.host.events[e] then
            module.host.events[e] = {}
            module.host:RegisterEvent(e)
        end

        if func then
            tinsert(module.host.events[e], func)
        end
    end
end

local function registerAllEvents(module, func)
    if not module.host then
        module.host = CreateFrame("Frame")
        module.host.events = {}
    end

    module.host:SetScript("OnEvent", func)
    module.host:RegisterAllEvents()
end

local function unregisterEvent(module, event, func)
    if not module.host then return end

    local events = module.host.events[event]

    if events then
        if func == nil then
            module.host.events[event] = {}
            return
        end

        for i, v in pairs(events) do
            if v == func then
                module.host.events[event][i] = nil
            end
        end
    end
end

local function registerEventOnce(module, event, func)
    registerEvent(module, event, function(_, e, ...)
        func(module, e, ...)
        unregisterEvent(module, e)
    end)
end

local function setScript(module, event, func)
    if event == "OnEvent" then
        checkEventHost(module)
        module.host.OnEvent = func
    else
        module.host:SetScript(event, function(_, ...)
            func(module, ...)
        end)
    end
end

local function createModule(name)
    local module = {}
    module.name = name

    -- add methods
    module.RegisterEvent = registerEvent
    module.RegisterAllEvents = registerAllEvents
    module.RegisterEventOnce = registerEventOnce
    module.UnregisterEvent = unregisterEvent
    module.SetScript = setScript

    return module
end

-- Create or get module with name
function E:Module(name)
    if modules[name] then return modules[name] end

    local module = createModule(name)

    function module:Sub(subName)
        if not self.sub then
            self.sub = {}
            self.suborders = {}
        end

        if self.sub[subName] then return self.sub[subName] end

        local sub = createModule(subName)

        self.sub[subName] = sub
        tinsert(self.suborders, subName)
        return sub
    end

    modules[name] = module
    return module
end

----------------------------------------------------------------------------------------
--	Collect garbage
----------------------------------------------------------------------------------------
local eventcount = 0
local InCombatLockdown = InCombatLockdown
local collectgarbage = collectgarbage

local Garbage = E:Module("Garbage")
Garbage:RegisterAllEvents(function(_, event)
    eventcount = eventcount + 1

    if (InCombatLockdown() and eventcount > 25000)
            or (not InCombatLockdown() and eventcount > 10000)
            or event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_REGEN_ENABLED"
    then
        collectgarbage()
        eventcount = 0
    end
end)

----------------------------------------------------------------------------------------
--	Load all Modules
----------------------------------------------------------------------------------------
local ipairs = ipairs

local function callByName(module, name, ...)
    if module and name and module[name] then
        module[name](module, ...)
    end

    if module and module.sub then
        for _, sub in ipairs(module.suborders) do
            callByName(module.sub[sub], name, ...)
        end
    end
end

local Loader = E:Module("Loader")
Loader:RegisterEvent("ADDON_LOADED PLAYER_LOGIN PLAYER_ENTERING_WORLD", function(_, event, addon)
    if event == "ADDON_LOADED" and addon == E.addonName then
        if not SavedStats then SavedStats = {} end
        if not SavedStatsPerChar then SavedStatsPerChar = {} end

        for _, module in next, modules do
            callByName(module, "OnInit")
        end
    elseif event == "PLAYER_LOGIN" then
        for _, module in next, modules do
            callByName(module, "OnLogin")
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        for _, module in next, modules do
            callByName(module, "OnActive")
        end

        collectgarbage("collect")
    end
end)