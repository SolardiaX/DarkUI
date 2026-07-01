local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
-- Module System
----------------------------------------------------------------------------------------

local modules = {}
local moduleOrder = {}
local InCombatLockdown = InCombatLockdown
local ipairs, pairs, type = ipairs, pairs, type

function E:Module(name)
    if modules[name] then return modules[name] end

    local module = {
        name = name,
        enabled = false,
        _secure = false,
        _subs = {},
        _subOrder = {},
        _configKey = nil, -- set via module:SetConfigKey("tooltip")
    }

    -- Event shortcuts (delegate to central dispatcher)
    function module:RegisterEvent(event, handler) E.Event:Register(event, handler, self) end

    function module:UnregisterEvent(event, handler) E.Event:Unregister(event, handler, self) end

    function module:UnregisterAllEvents() E.Event:UnregisterAll(self) end

    function module:RegisterEventOnce(event, handler) E.Event:RegisterOnce(event, handler, self) end

    -- Sub-module creation
    function module:Sub(subName)
        if self._subs[subName] then return self._subs[subName] end

        local sub = {
            name = subName,
            parent = self,
            enabled = false,
            _secure = false,
        }
        sub.RegisterEvent = module.RegisterEvent
        sub.UnregisterEvent = module.UnregisterEvent
        sub.UnregisterAllEvents = module.UnregisterAllEvents
        sub.RegisterEventOnce = module.RegisterEventOnce

        function sub:SetSecure() self._secure = true end

        function sub:IsEnabled() return self.enabled end

        self._subs[subName] = sub
        self._subOrder[#self._subOrder + 1] = subName
        return sub
    end

    -- Mark module as containing secure frames
    function module:SetSecure() self._secure = true end

    -- Set which config key controls this module's enable state. Accepts a dotted
    -- path; the leaf may be a table (checks .enable) or a plain boolean toggle.
    -- e.g. module:SetConfigKey("tooltip") → C.tooltip.enable
    --      module:SetConfigKey("general.skins") → C.general.skins
    function module:SetConfigKey(key) self._configKey = key end

    -- Check if the module should be enabled based on config
    function module:ShouldEnable()
        if not self._configKey then return true end
        local cfg = C
        for segment in self._configKey:gmatch("[^.]+") do
            if type(cfg) ~= "table" then return true end
            cfg = cfg[segment]
        end
        if type(cfg) == "table" then return cfg.enable ~= false end
        if type(cfg) == "boolean" then return cfg end
        return true
    end

    -- Enable module and its sub-modules
    function module:Enable()
        if self.enabled then return end

        if InCombatLockdown() and self._secure then
            E.Event:RegisterOnce("PLAYER_REGEN_ENABLED", function() self:Enable() end)
            return
        end

        self.enabled = true
        if self.OnEnable then self:OnEnable() end

        for _, subName in ipairs(self._subOrder) do
            local sub = self._subs[subName]
            if sub.OnEnable then sub:OnEnable() end
            sub.enabled = true
        end
    end

    -- Disable module and its sub-modules
    function module:Disable()
        if not self.enabled then return end

        if InCombatLockdown() and self._secure then
            E.Event:RegisterOnce("PLAYER_REGEN_ENABLED", function() self:Disable() end)
            return
        end

        -- Disable sub-modules first (reverse order)
        for i = #self._subOrder, 1, -1 do
            local sub = self._subs[self._subOrder[i]]
            if sub.enabled then
                if sub.OnDisable then sub:OnDisable() end
                sub:UnregisterAllEvents()
                sub.enabled = false
            end
        end

        if self.OnDisable then self:OnDisable() end
        self:UnregisterAllEvents()
        self.enabled = false
    end

    function module:IsEnabled() return self.enabled end

    -- Toggle (convenience for GUI)
    function module:Toggle()
        if self.enabled then
            self:Disable()
        else
            self:Enable()
        end
    end

    modules[name] = module
    moduleOrder[#moduleOrder + 1] = name
    return module
end

function E:GetModule(name) return modules[name] end

function E:IterateModules()
    local i = 0
    return function()
        i = i + 1
        local name = moduleOrder[i]
        if name then return name, modules[name] end
    end
end

----------------------------------------------------------------------------------------
-- Bootstrap
----------------------------------------------------------------------------------------

function E:InitializeModules()
    for _, name in ipairs(moduleOrder) do
        local module = modules[name]
        if module.OnInit then module:OnInit() end
        -- Also call OnInit for sub-modules
        for _, subName in ipairs(module._subOrder) do
            local sub = module._subs[subName]
            if sub.OnInit then sub:OnInit() end
        end
    end
end

function E:EnableModules()
    for _, name in ipairs(moduleOrder) do
        local module = modules[name]
        if module:ShouldEnable() then module:Enable() end
    end
end
