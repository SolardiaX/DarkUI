----------------------------------------------------------------------------------------
--	Core Module Methods
----------------------------------------------------------------------------------------
local E, C, L, M = select(2, ...):unpack()

local CreateFrame = CreateFrame
local tinsert, pairs, gmatch = tinsert, pairs, string.gmatch
local modules = {}

local function checkEventHost(module)
    if not module.host then
        module.host = CreateFrame("Frame")
        module.host.events = {}

        module.host:SetScript("OnEvent", function(self, event, ...)
            if not self.events[event] then return end

            for _, v in next, self.events[event] do
                v(event, ...)
            end
        end)
    end
end

local function setScript(module, event, func)
    if not module.host then
        module.host = CreateFrame("Frame")
        module.host.events = {}
    end

    module.host:SetScript(event, func)
end

local function registerEvent(module, event, func)
    checkEventHost(module)

    for e in gmatch(event, "([^,%s]+)") do
        if not module.host.events[e] then
            module.host.events[e] = {}
            module.host:RegisterEvent(e)
        end
        tinsert(module.host.events[e], func)
    end
end

local function registerAllEvents(module, func)
    setScript(module, 'OnEvent', func)
    module.host:RegisterAllEvents()
end

local function unregisterEvent(module, event, func)
    if not module.host then return end

    if module.host.events[event] then
        for k, v in pairs(module.host.events[event]) do
            if v == func or func == nil then
                module.host.events[event][k] = nil
            end
        end
    end
end

local function registerEventOnce(module, event, func)
    registerEvent(module, event, function(e, ...)
        func(e, ...)
        unregisterEvent(module, e)
    end)
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
function M:Module(name)
    if modules[name] then return modules[name] end

    local module = createModule(name)

    function module:Sub(subName)
        local sub = createModule(subName)

        if not self.sub then
            self.sub = {}
            self.suborders = {}
        end

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

local Garbage = M:Module("Garbage")
Garbage:RegisterAllEvents(function(event)
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
local Loader = M:Module("Loader")
Loader:RegisterEvent("ADDON_LOADED PLAYER_LOGIN PLAYER_ENTERING_WORLD", function(event, addon)
    if event == "ADDON_LOADED" and addon == E.addonName then
        if not SavedOptionsPerChar then SavedOptionsPerChar = {} end
    elseif event == "PLAYER_LOGIN" then
        local function init(module)
            if module.Init then
                module:Init()
            end

            if module.sub then
                for _, name in ipairs(module.suborders) do
                    init(module.sub[name])
                end
            end
        end

        for _, module in next, modules do
            init(module)
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        local function active(module)
            if module.Active then
                module:Active()
            end

            if module.sub then
                for _, name in ipairs(module.suborders) do
                    active(module.sub[name])
                end
            end
        end

        for _, module in next, modules do
            active(module)
        end

        collectgarbage("collect")
    end
end)