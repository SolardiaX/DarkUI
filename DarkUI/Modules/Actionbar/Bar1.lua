local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable then return end

----------------------------------------------------------------------------------------
--	ActionBar (modified from ShestakUI)
----------------------------------------------------------------------------------------
local _G = _G
local CreateFrame = CreateFrame
local GetActionTexture = GetActionTexture
local RegisterStateDriver = RegisterStateDriver
local unpack = unpack
local UIParent = _G.UIParent

local cfg = C.actionbar.bars.bar1
local num = NUM_ACTIONBAR_BUTTONS

local bar = CreateFrame("Frame", "DarkUI_ActionBar1Holder", UIParent, "SecureHandlerStateTemplate")
bar:SetPoint(unpack(cfg.pos))
bar:SetHeight(cfg.button.size)
bar:SetWidth(num * cfg.button.size + (num - 1) * cfg.button.space)
bar.GetSpellFlyoutDirection = MainMenuBar.GetSpellFlyoutDirection
bar.flyoutDirection = MainMenuBar.flyoutDirection

for i = 1, num do
    local button = _G["ActionButton" .. i]
    button:SetSize(cfg.button.size, cfg.button.size)
    button:ClearAllPoints()
    if i == 1 then
        button:SetPoint("BOTTOMLEFT", bar, 0, 0)
    else
        local previous = _G["ActionButton" .. i - 1]
        button:SetPoint("LEFT", previous, "RIGHT", cfg.button.space, 0)
    end
end

local Page = {
    ["DRUID"]   = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
    ["ROGUE"]   = "[bonusbar:1] 7;",
    ["WARRIOR"] = "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;",
    ["PRIEST"]  = "[bonusbar:1] 7;",
    ["DEFAULT"] = "[possessbar] 16; [shapeshift] 17; [overridebar] 18; [vehicleui] 16; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;",
}

local function GetBar()
    local condition = Page["DEFAULT"]
    local class = E.class
    local page = Page[class]
    if page then
        condition = condition .. " " .. page
    end
    condition = condition .. " 1"
    return condition
end

bar:RegisterEvent("PLAYER_LOGIN")
bar:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
bar:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
bar:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        for i = 1, num do
            local button = _G["ActionButton" .. i]
            self:SetFrameRef("ActionButton" .. i, button)
            button:SetParent(bar)
        end

        self:Execute([[
			buttons = table.new()
			for i = 1, 12 do
				table.insert(buttons, self:GetFrameRef("ActionButton"..i))
			end
		]])

        self:SetAttribute("_onstate-page", [[
			for i, button in ipairs(buttons) do
				button:SetAttribute("actionpage", tonumber(newstate))
			end
		]])

        RegisterStateDriver(self, "page", GetBar())
    elseif event == "UPDATE_VEHICLE_ACTIONBAR" or event == "UPDATE_OVERRIDE_ACTIONBAR" then
        for i = 1, num do
            local button = _G["ActionButton" .. i]
            local action = button.action
            local icon = button.icon

            if action >= 120 then
                local texture = GetActionTexture(action)

                if texture then
                    icon:SetTexture(texture)
                    icon:Show()
                else
                    if icon:IsShown() then
                        icon:Hide()
                    end
                end
            end
        end
    end
end)