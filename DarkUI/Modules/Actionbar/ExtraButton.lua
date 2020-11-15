local _, ns = ...
local E, C, L = ns:unpack()

if not C.actionbar.bars.enable then return end

----------------------------------------------------------------------------------------
--  DarkUI ExtraButtons
----------------------------------------------------------------------------------------

local _G = _G
local MagnetButtons = MagnetButtons or ns.MagnetButtons

local ExtraButtons = {
    [1] = {
        name   = "MainLeft",
        parent = "DarkUI_ActionBar1HolderBG",
        pos    = { "TOPRIGHT", _G["ActionButton1"], "TOPLEFT", -10, 7 },
        size   = { 56, 56 }
    },
    [2] = {
        name   = "MainRight",
        parent = "DarkUI_ActionBar1HolderBG",
        pos    = { "TOPLEFT", _G["ActionButton12"], "TOPRIGHT", 10.5, 7 },
        size   = { 56, 56 }
    },
    [3] = {
        name   = "TopLeft",
        parent = "DarkUI_ActionBar2HolderBG",
        pos    = { "TOPRIGHT", _G["MultiBarBottomLeftButton1"], "TOPLEFT", -36, 5 },
        size   = { 56, 56 }
    },
    [4] = {
        name   = "TopRight",
        parent = "DarkUI_ActionBar2HolderBG",
        pos    = { "TOPLEFT", _G["MultiBarBottomLeftButton12"], "TOPRIGHT", 35, 5 },
        size   = { 56, 56 }
    }
}

local ExtraButtons_Lite_Pos = {
    [1] = { "TOPRIGHT", _G["ActionButton1"], "TOPLEFT", -12.5, 4 },
    [2] = { "TOPLEFT", _G["ActionButton12"], "TOPRIGHT", 14.5, 4 },
    [3] = { "TOPRIGHT", _G["MultiBarBottomLeftButton1"], "TOPLEFT", -11.5, 8 },
    [4] = { "TOPLEFT", _G["MultiBarBottomLeftButton12"], "TOPRIGHT", 14.5, 8 },
}

local ExtraButtons_Lite_Size = {
    [1] = { 51, 51 },
    [2] = { 51, 51 },
    [3] = { 51, 51 },
    [4] = { 51, 51 },
}

--[[ Create ]]
local Extra = CreateFrame("Frame", nil, UIParent, "SecureFrameTemplate")

function Extra:CreateButton(index, config)
    local button = MagnetButtons.NewEmptyButton()

	local attributes = SavedStatsPerChar["ExtraButtons"] and SavedStatsPerChar["ExtraButtons"][index] or nil
	if attributes then
		MagnetButtons.ClearButtonAttributes(button);
		MagnetButtons.SetButton(button, attributes);
	end

	button:GetParent():SetParent(config.parent)
    button:GetParent():ClearAllPoints()
	button:GetParent():SetPoint(unpack(C.general.liteMode and ExtraButtons_Lite_Pos[index] or config.pos))
	button:GetParent():SetSize(unpack(C.general.liteMode and ExtraButtons_Lite_Size[index] or config.size))
	button:SetNormalTexture(nil)
	button:SetAllPoints(button:GetParent())
end

function Extra:Init()
    for index, config in ipairs(ExtraButtons) do
        Extra:CreateButton(index, config)
    end
end

Extra:RegisterEvent("ADDON_LOADED")
Extra:SetScript("OnEvent", function(self, _, name)
    if name == E.addonName then self:Init() end
end)
