local E, C, L = select(2, ...):unpack()

local _G = _G
local next = next

local CheckTargetFrame = function() return C.unitframe.enable end
local CheckCastFrame = function() return C.unitframe.enable end
local CheckArenaFrame = function() return C.unitframe.enable end
local CheckPartyFrame = function() return C.unitframe.enable end
local CheckFocusFrame = function() return C.unitframe.enable end
local CheckRaidFrame = function() return C.unitframe.enable end
local CheckBossFrame = function() return C.unitframe.enable end
local CheckAuraFrame = function() return C.unitframe.enable end
local CheckActionBar = function() return C.unitframe.enable end

local IgnoreFrames = {
	MinimapCluster = function() return C.map.minimap.enable end, -- header underneath and rotate minimap (will need to add the setting)
	GameTooltipDefaultContainer = function() return C.tooltip.enable end,

	-- UnitFrames
	PartyFrame = CheckPartyFrame,
	FocusFrame = CheckFocusFrame,
	TargetFrame = CheckTargetFrame,
	PlayerCastingBarFrame = CheckCastFrame,
	ArenaEnemyFramesContainer = CheckArenaFrame,
	CompactRaidFrameContainer = CheckRaidFrame,
	BossTargetFrameContainer = CheckBossFrame,
	PlayerFrame = function() return C.unitframe.enable end,

	-- Auras
	BuffFrame = function() return C.aura.enable end,
	DebuffFrame = function() return C.aura.enable end,

	-- ActionBars
	StanceBar = CheckActionBar,
	EncounterBar = CheckActionBar,
	PetActionBar = CheckActionBar,
	PossessActionBar = CheckActionBar,
	MainMenuBarVehicleLeaveButton = CheckActionBar,
	MultiBarBottomLeft = CheckActionBar,
	MultiBarBottomRight = CheckActionBar,
	MultiBarLeft = CheckActionBar,
	MultiBarRight = CheckActionBar,
	MultiBar5 = CheckActionBar,
	MultiBar6 = CheckActionBar,
	MultiBar7 = CheckActionBar
}

local ShutdownMode = {
	'OnEditModeEnter',
	'OnEditModeExit',
	'HasActiveChanges',
	'HighlightSystem',
	'SelectSystem',
	-- these not running will taint the default bars on spec switch
	--- 'IsInDefaultPosition',
	--- 'UpdateSystem',
}

E:RegisterEvent("PLAYER_ENTERING_WORLD", function()
	local editMode = _G.EditModeManagerFrame

	-- remove the initial registers
	local registered = editMode.registeredSystemFrames
	for i = #registered, 1, -1 do
		local frame = registered[i]
		local ignore = IgnoreFrames[frame:GetName()]
		if ignore and ignore() then
			for _, key in next, ShutdownMode do
				frame[key] = E.Dummy
			end
		end
	end

	-- account settings will be tainted
	local mixin = editMode.AccountSettings
	if CheckCastFrame() then mixin.RefreshCastBar = E.Dummy end
	if CheckAuraFrame() then mixin.RefreshAuraFrame = E.Dummy end
	if CheckBossFrame() then mixin.RefreshBossFrames = E.Dummy end
	if CheckArenaFrame() then mixin.RefreshArenaFrames = E.Dummy end

	if CheckRaidFrame() then
		mixin.RefreshRaidFrames = E.Dummy
		mixin.ResetRaidFrames = E.Dummy
	end
	if CheckPartyFrame() then
		mixin.RefreshPartyFrames = E.Dummy
		mixin.ResetPartyFrames = E.Dummy
	end
	if CheckTargetFrame() and CheckFocusFrame() then
		mixin.RefreshTargetAndFocus = E.Dummy
		mixin.ResetTargetAndFocus = E.Dummy
	end

	if CheckActionBar() then
		mixin.RefreshVehicleLeaveButton = E.Dummy
		mixin.RefreshActionBarShown = E.Dummy
		mixin.RefreshEncounterBar = E.Dummy
	end
end)
