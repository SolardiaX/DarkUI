local E, C, L = select(2, ...):unpack()

if not C.stats.enable or not C.stats.config.Memory.enable then return end

----------------------------------------------------------------------------------------
--    Memory of DataText (modified from ShestakUI)
----------------------------------------------------------------------------------------
local module = E:Module("DataText")

local GetAddOnCPUUsage, GetAddOnInfo, GetAddOnMemoryUsage = GetAddOnCPUUsage, GetAddOnInfo, GetAddOnMemoryUsage
local GetAvailableBandwidth = GetAvailableBandwidth
local GetCVar = GetCVar
local GetDownloadedPercentage = GetDownloadedPercentage
local UpdateAddOnCPUUsage, UpdateAddOnMemoryUsage = UpdateAddOnCPUUsage, UpdateAddOnMemoryUsage
local AddonList_OnCancel = AddonList_OnCancel
local PlaySound = PlaySound
local ShowUIPanel = ShowUIPanel
local print, format, floor, time, tinsert, tsort = print, format, floor, time, tinsert, table.sort
local collectgarbage, gcinfo = collectgarbage, gcinfo
local ADDONS, ALT_KEY, FPS_ABBR, MILLISECONDS_ABBR = ADDONS, ALT_KEY, FPS_ABBR, MILLISECONDS_ABBR
local SOUNDKIT = SOUNDKIT
local GameTooltip = GameTooltip
local AddonList = AddonList

local cfg = C.stats.config.Memory

local function sortdesc(a, b) return a[2] > b[2] end
local function formatmem(val, dec)
    return format(format("%%.%df %s", dec or 1, val > 1024 and "MB" or "KB"), val / (val > 1024 and 1024 or 1))
end

local memoryt = {}
local isCPU = GetCVar("scriptProfile") == "1"
local UpdateMemUse = UpdateAddOnMemoryUsage

module:Inject("Memory", {
    text    = {
        string      = function(self)
            self.total = 0
            UpdateMemUse()
            local parent = self:GetParent()
            for i = 1, C_AddOns.GetNumAddOns() do self.total = self.total + GetAddOnMemoryUsage(i) end
            if parent.hovered then self:GetParent():GetScript("OnEnter")(parent) end
            return self.total >= 1024 and format(cfg.fmt_mb, self.total / 1024) or format(cfg.fmt_kb, self.total)
        end, update = 5,
    },
    OnEnter = function(self)
        self.hovered = true
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:ClearAllPoints()
        GameTooltip:SetPoint(cfg.tip_anchor, cfg.tip_frame, cfg.tip_x, cfg.tip_y)
        GameTooltip:ClearLines()
        local lat, r = select(4, GetNetStats()), 750
        GameTooltip:AddDoubleLine(
                format("|cffffffff%s|r %s, %s%s|r %s", floor(GetFramerate()), FPS_ABBR, module:Gradient(1 - lat / r), lat, MILLISECONDS_ABBR),
                format("%s: |cffffffff%s", ADDONS, formatmem(self.text.total)), module.tthead.r, module.tthead.g, module.tthead.b, module.tthead.r, module.tthead.g, module.tthead.b)
        GameTooltip:AddLine(" ")
        if cfg.max_addons ~= 0 or IsAltKeyDown() then
            if isCPU and IsControlKeyDown() then
                self.timer = 5
            end
            if not self.timer or self.timer + 5 < time() then
                if isCPU and IsControlKeyDown() then
                    UpdateAddOnCPUUsage()
                    for i = 1, #memoryt do memoryt[i] = nil end
                    for i = 1, C_AddOns.GetNumAddOns() do
                        local addon, name = C_AddOns.GetAddOnInfo(i)
                        if C_AddOns.IsAddOnLoaded(i) then tinsert(memoryt, { name or addon, GetAddOnCPUUsage(i) }) end
                    end
                    tsort(memoryt, sortdesc)
                else
                    self.timer = time()
                    UpdateMemUse()
                    for i = 1, #memoryt do memoryt[i] = nil end
                    for i = 1, C_AddOns.GetNumAddOns() do
                        local addon, name = C_AddOns.GetAddOnInfo(i)
                        if C_AddOns.IsAddOnLoaded(i) then tinsert(memoryt, { name or addon, GetAddOnMemoryUsage(i) }) end
                    end
                    tsort(memoryt, sortdesc)
                end
            end
            local exmem = 0
            for i, t in ipairs(memoryt) do
                if cfg.max_addons and i > cfg.max_addons and not IsAltKeyDown() then
                    exmem = exmem + t[2]
                else
                    local color = t[2] <= 102.4 and { 0, 1 } -- 0 - 100
                            or t[2] <= 512 and { 0.5, 1 } -- 100 - 512
                            or t[2] <= 1024 and { 0.75, 1 } -- 512 - 1mb
                            or t[2] <= 2560 and { 1, 1 } -- 1mb - 2.5mb
                            or t[2] <= 5120 and { 1, 0.75 } -- 2.5mb - 5mb
                            or t[2] <= 8192 and { 1, 0.5 } -- 5mb - 8mb
                            or { 1, 0.1 } -- 8mb +
                    if isCPU and IsControlKeyDown() then
                        GameTooltip:AddDoubleLine(t[1], format("%d ms", t[2]), 1, 1, 1, color[1], color[2], 0)
                    else
                        GameTooltip:AddDoubleLine(t[1], formatmem(t[2]), 1, 1, 1, color[1], color[2], 0)
                    end
                end
            end
            if exmem > 0 and not IsAltKeyDown() then
                local more = #memoryt - cfg.max_addons
                GameTooltip:AddDoubleLine(format("%d %s (%s)", more, L.DATATEXT_HIDDEN, ALT_KEY), formatmem(exmem), module.ttsubh.r, module.ttsubh.g, module.ttsubh.b, module.ttsubh.r, module.ttsubh.g, module.ttsubh.b)
            end
            GameTooltip:AddDoubleLine(" ", "--------------", 1, 1, 1, 0.5, 0.5, 0.5)
        end
        local bandwidth = GetAvailableBandwidth()
        if bandwidth ~= 0 then
            GameTooltip:AddDoubleLine(L.DATATEXT_BANDWIDTH, format("%s " .. "Mbps", E:Round(bandwidth, 2)), module.ttsubh.r, module.ttsubh.g, module.ttsubh.b, 1, 1, 1)
            GameTooltip:AddDoubleLine(L.DATATEXT_DOWNLOAD, format("%s%%", floor(GetDownloadedPercentage() * 100 + 0.5)), module.ttsubh.r, module.ttsubh.g, module.ttsubh.b, 1, 1, 1)
            GameTooltip:AddLine(" ")
        end
        GameTooltip:AddDoubleLine(L.DATATEXT_MEMORY_USAGE, formatmem(gcinfo() - self.text.total), module.ttsubh.r, module.ttsubh.g, module.ttsubh.b, 1, 1, 1)
        GameTooltip:AddDoubleLine(L.DATATEXT_TOTAL_MEMORY_USAGE, formatmem(collectgarbage "count"), module.ttsubh.r, module.ttsubh.g, module.ttsubh.b, 1, 1, 1)
        if isCPU then
            self.totalCPU = 0
            UpdateAddOnCPUUsage()
            for i = 1, C_AddOns.GetNumAddOns() do self.totalCPU = self.totalCPU + GetAddOnCPUUsage(i) end
            GameTooltip:AddDoubleLine(L.DATATEXT_TOTAL_CPU_USAGE, format("%d ms", self.totalCPU), module.ttsubh.r, module.ttsubh.g, module.ttsubh.b, 1, 1, 1)
        end
        GameTooltip:Show()
    end,
    OnClick = function(self, button)
        if button == "RightButton" then
            UpdateMemUse()
            local before = gcinfo()
            collectgarbage()
            UpdateMemUse()
            print(format("|cff66C6FF%s:|r %s", L.DATATEXT_GARBAGE_COLLECTED, formatmem(before - gcinfo())))
            self.timer, self.text.elapsed = nil, 5
            self:GetScript("OnEnter")(self)
        elseif button == "LeftButton" then
            if AddonList:IsShown() then
                AddonList_OnCancel()
            else
                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
                ShowUIPanel(AddonList)
            end
        end
    end
})
