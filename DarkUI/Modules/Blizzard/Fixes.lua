local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Blizzard Fixes
------------------------------------------------------------------------

local module = E:Module("Blizzard"):Sub("Fixes")

------------------------------------------------------------------------
-- Tooltip blank line fix
------------------------------------------------------------------------

local bug
local function onActionBarEvent()
    if GameTooltip:IsShown() then bug = true end
end

local fixTooltip = CreateFrame("Frame")
fixTooltip:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
fixTooltip:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
fixTooltip:SetScript("OnEvent", onActionBarEvent)

GameTooltip:HookScript("OnTooltipCleared", function(self)
    if self:IsForbidden() then return end
    if bug and self:NumLines() == 0 then
        self:Hide()
        bug = false
    end
end)

------------------------------------------------------------------------
-- FCF_StartAlertFlash taint
------------------------------------------------------------------------

FCF_StartAlertFlash = E.Dummy

------------------------------------------------------------------------
-- Fix Keybind taint
------------------------------------------------------------------------

_G.SettingsPanel.TransitionBackOpeningPanel = _G.HideUIPanel

------------------------------------------------------------------------
-- Fix BackdropTemplate secret value error
------------------------------------------------------------------------

local old_SetupTextureCoordinates = BackdropTemplateMixin.SetupTextureCoordinates
function BackdropTemplateMixin:SetupTextureCoordinates()
    local width = self:GetWidth()
    if issecretvalue and issecretvalue(width) then return end
    old_SetupTextureCoordinates(self)
end

------------------------------------------------------------------------
-- Fix money tooltip
------------------------------------------------------------------------

function SetTooltipMoney(frame, money, _, prefixText, suffixText)
    frame:AddLine((prefixText or "") .. "  " .. C_CurrencyInfo.GetCoinTextureString(money) .. " " .. (suffixText or ""), 1, 1, 1)
end

------------------------------------------------------------------------
-- Fix addon list tooltip
------------------------------------------------------------------------

local _AddonTooltip_Update = AddonTooltip_Update
function AddonTooltip_Update(owner)
    if not owner then return end
    if owner:GetID() < 1 then return end
    _AddonTooltip_Update(owner)
end

------------------------------------------------------------------------
-- NoTaint2 (by warbaby)
------------------------------------------------------------------------

if not C_AddOns.IsAddOnLoaded("!!NoTaint2") then
    if not NoTaint2_Proc_ResetActionButtonAction then
        NoTaint2_Proc_ResetActionButtonAction = 1

        function NoTaint2_ResetActionButtonAction(self)
            local ok = issecurevariable(self, "action")
            if not ok and not InCombatLockdown() then
                self.action = nil
                self:SetAttribute("_aby", "action")
            end
        end

        for _, v in ipairs(ActionBarButtonEventsFrame.frames) do
            hooksecurefunc(v, "UpdateAction", NoTaint2_ResetActionButtonAction)
        end

        local f1 = CreateFrame("Frame")
        f1:RegisterEvent("PLAYER_REGEN_ENABLED")
        f1:SetScript("OnEvent", function()
            for _, v in ipairs(ActionBarButtonEventsFrame.frames) do
                NoTaint2_ResetActionButtonAction(v)
            end
        end)
    end

    if not NoTaint2_CleanStaticPopups then
        function NoTaint2_CleanStaticPopups()
            local numDialogs = (not issecretvalue(STATICPOPUP_NUMDIALOGS) and tonumber(STATICPOPUP_NUMDIALOGS)) or 4
            for index = 1, numDialogs do
                local frame = _G["StaticPopup" .. index]
                if not issecurevariable(frame, "which") then
                    if frame:IsShown() then
                        local info = StaticPopupDialogs[frame.which]
                        if info and not issecurevariable(info, "OnCancel") then
                            info.OnCancel()
                        end
                        frame:Hide()
                    end
                    frame.which = nil
                end
            end
        end

        function NoTaint2_CleanDropDownList()
            local frameToShow = LFDQueueFrameTypeDropDown
            if not frameToShow then return end
            local parent = frameToShow:GetParent()
            frameToShow:SetParent(nil)
            frameToShow:SetParent(parent)
        end

        local global_obj_name = {
            UIDROPDOWNMENU_MAXBUTTONS = 1,
            UIDROPDOWNMENU_MAXLEVELS = 1,
            UIDROPDOWNMENU_OPEN_MENU = 1,
            UIDROPDOWNMENU_INIT_MENU = 1,
            OBJECTIVE_TRACKER_UPDATE_REASON = 1,
        }

        function NoTaint2_CleanGlobal()
            for k in pairs(global_obj_name) do
                if not issecurevariable(k) then
                    _G[k] = nil
                end
            end
        end

        hooksecurefunc(EditModeManagerFrame, "ClearActiveChangesFlags", function(self)
            for _, systemFrame in ipairs(self.registeredSystemFrames) do
                systemFrame:SetHasActiveChanges(nil)
            end
            self:SetHasActiveChanges(nil)
        end)

        hooksecurefunc(EditModeManagerFrame, "HideSystemSelections", function(self)
            if self.editModeActive == false then
                self.editModeActive = nil
            end
        end)

        hooksecurefunc(EditModeManagerFrame, "IsEditModeLocked", function()
            NoTaint2_CleanGlobal()
        end)

        local function cleanAll()
            NoTaint2_CleanDropDownList()
            NoTaint2_CleanStaticPopups()
            NoTaint2_CleanGlobal()
        end

        local Origin_IsShown = EditModeManagerFrame.IsShown
        hooksecurefunc(EditModeManagerFrame, "IsShown", function(self)
            if Origin_IsShown(self) then return end
            local stack = debugstack(4)
            if stack and stack:find('[string "=[C]"]: in function `ShowUIPanel\'\n', 1, true) then
                cleanAll()
            end
        end)
    end

    if not NoTaint2_Proc_StopEnterWorldLayout then
        NoTaint2_Proc_StopEnterWorldLayout = 1
        local f2 = CreateFrame("Frame")
        f2:RegisterEvent("PLAYER_LEAVING_WORLD")
        f2:RegisterEvent("PLAYER_ENTERING_WORLD")
        f2:SetScript("OnEvent", function(_, event, ...)
            if event == "PLAYER_ENTERING_WORLD" then
                local login, reload = ...
                if not login and not reload then
                    NoTaint2_CleanDropDownList()
                    NoTaint2_CleanStaticPopups()
                    NoTaint2_CleanGlobal()
                end
                EditModeManagerFrame:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED")
            elseif event == "PLAYER_LEAVING_WORLD" then
                EditModeManagerFrame:UnregisterEvent("EDIT_MODE_LAYOUTS_UPDATED")
            end
        end)
    end

    if not NoTaint2_Proc_CleanActionButtonFlyout then
        NoTaint2_Proc_CleanActionButtonFlyout = 1
        local barsToUpdate = {
            MainMenuBar, MultiBarBottomLeft, MultiBarBottomRight,
            StanceBar, PetActionBar, PossessActionBar,
            MultiBarRight, MultiBarLeft, MultiBar5, MultiBar6, MultiBar7,
        }
        for _, bar in ipairs(barsToUpdate) do
            hooksecurefunc(bar, "UpdateSpellFlyoutDirection", function(self)
                if not issecurevariable(self, "flyoutDirection") then
                    self.flyoutDirection = nil
                end
                if not issecurevariable(self, "snappedToFrame") then
                    self.snappedToFrame = nil
                end
            end)
        end

        hooksecurefunc("SetClampedTextureRotation", function(texture)
            local parent = texture and texture:GetParent()
            if parent and parent.FlyoutArrowPushed and parent.FlyoutArrowHighlight then
                if not issecurevariable(texture, "rotationDegrees") then
                    texture.rotationDegrees = nil
                end
            end
        end)
    end
end

------------------------------------------------------------------------
-- Fix LFG FilterButton width
------------------------------------------------------------------------

if LFGListFrame and LFGListFrame.SearchPanel and LFGListFrame.SearchPanel.FilterButton then
    hooksecurefunc(LFGListFrame.SearchPanel.FilterButton, "SetWidth", function(self, width)
        if width ~= 94 then
            self:SetWidth(94)
        end
    end)
end

------------------------------------------------------------------------
-- Guild control fallback
------------------------------------------------------------------------

if not GuildControlUIRankSettingsFrameRosterLabel then
    GuildControlUIRankSettingsFrameRosterLabel = CreateFrame("Frame")
    GuildControlUIRankSettingsFrameRosterLabel:Hide()
end
