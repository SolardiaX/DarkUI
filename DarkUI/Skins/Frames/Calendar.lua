local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB
local cr, cg, cb = DB.r, DB.g, DB.b

------------------------------------------------------------------------
-- Calendar
-- Ported from AuroraClassic AddOns/Blizzard_Calendar.lua (2026-06)
-- Notes:
--   * Aurora noise overlay dropped; DarkUI backdrop supplies texture.
--   * B.Dummy → local noop function assigned directly to the method slot.
--   * C.mult → E.mult.
------------------------------------------------------------------------

local _G = _G
local select, ipairs, next, unpack = select, ipairs, next, unpack
local hooksecurefunc = hooksecurefunc

local function noop() end

local function reskinEventList(frame)
    frame:StripTextures()
    frame:CreateBackdrop()
    if frame.ScrollBar then S:ReskinTrimScroll(frame.ScrollBar) end
end

local function reskinCalendarPage(frame)
    frame:StripTextures()
    S:SetBD(frame)
    frame.Header:StripTextures()
    if frame.ScrollBar then S:ReskinTrimScroll(frame.ScrollBar) end
end

function S:Calendar()
    if not (C.skins.enable and C.skins.calendar) then return end

    for i = 1, 42 do
        local dayButtonName = "CalendarDayButton" .. i
        local bu = _G[dayButtonName]
        bu:DisableDrawLayer("BACKGROUND")
        bu:SetHighlightTexture(DB.bdTex)
        local bg = bu:CreateBackdrop()
        bg:SetInside()
        local hl = bu:GetHighlightTexture()
        hl:SetVertexColor(cr, cg, cb, 0.25)
        hl:SetInside(bg)
        hl.SetAlpha = noop

        _G[dayButtonName .. "DarkFrame"]:SetAlpha(0.5)
        _G[dayButtonName .. "EventTexture"]:SetInside(bg)
        _G[dayButtonName .. "EventBackgroundTexture"]:SetAlpha(0)
        _G[dayButtonName .. "OverlayFrameTexture"]:SetInside(bg)

        local eventButtonIndex = 1
        local eventButton = _G[dayButtonName .. "EventButton" .. eventButtonIndex]
        while eventButton do
            eventButton:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
            eventButton.black:SetTexture(nil)
            eventButtonIndex = eventButtonIndex + 1
            eventButton = _G[dayButtonName .. "EventButton" .. eventButtonIndex]
        end
    end

    for i = 1, 7 do
        _G["CalendarWeekday" .. i .. "Background"]:SetAlpha(0)
    end

    _G.CalendarViewEventDivider:Hide()
    _G.CalendarCreateEventDivider:Hide()
    _G.CalendarCreateEventFrameButtonBackground:Hide()
    _G.CalendarCreateEventMassInviteButtonBorder:Hide()
    _G.CalendarCreateEventCreateButtonBorder:Hide()
    S:ReskinIcon(_G.CalendarCreateEventIcon)
    _G.CalendarCreateEventIcon.SetTexCoord = noop
    _G.CalendarEventPickerCloseButtonBorder:Hide()
    _G.CalendarCreateEventRaidInviteButtonBorder:Hide()
    _G.CalendarMonthBackground:SetAlpha(0)
    _G.CalendarYearBackground:SetAlpha(0)
    _G.CalendarFrameModalOverlay:SetAlpha(0.25)
    _G.CalendarViewHolidayFrame.Texture:SetAlpha(0)
    _G.CalendarTexturePickerAcceptButtonBorder:Hide()
    _G.CalendarTexturePickerCancelButtonBorder:Hide()
    _G.CalendarClassTotalsButton:StripTextures()

    _G.CalendarFrame:StripTextures()
    S:SetBD(_G.CalendarFrame, nil, 9, 0, -7, 1)
    _G.CalendarClassTotalsButton:CreateBackdrop()

    reskinEventList(_G.CalendarViewEventInviteList)
    reskinEventList(_G.CalendarViewEventDescriptionContainer)
    reskinEventList(_G.CalendarCreateEventInviteList)
    reskinEventList(_G.CalendarCreateEventDescriptionContainer)

    reskinCalendarPage(_G.CalendarViewHolidayFrame)
    reskinCalendarPage(_G.CalendarCreateEventFrame)
    reskinCalendarPage(_G.CalendarViewEventFrame)
    reskinCalendarPage(_G.CalendarTexturePickerFrame)
    reskinCalendarPage(_G.CalendarEventPickerFrame)
    reskinCalendarPage(_G.CalendarViewRaidFrame)

    local frames = {
        _G.CalendarViewEventTitleFrame,
        _G.CalendarViewHolidayTitleFrame,
        _G.CalendarViewRaidTitleFrame,
        _G.CalendarCreateEventTitleFrame,
        _G.CalendarTexturePickerTitleFrame,
        _G.CalendarMassInviteTitleFrame,
    }
    for _, titleFrame in next, frames do
        titleFrame:StripTextures()
        local parent = titleFrame:GetParent()
        parent:StripTextures()
        S:SetBD(parent)
    end

    _G.CalendarWeekdaySelectedTexture:SetDesaturated(true)
    _G.CalendarWeekdaySelectedTexture:SetVertexColor(cr, cg, cb)

    hooksecurefunc("CalendarFrame_SetToday", function() _G.CalendarTodayFrame:SetAllPoints() end)

    _G.CalendarTodayFrame:SetScript("OnUpdate", nil)
    _G.CalendarTodayTextureGlow:Hide()
    _G.CalendarTodayTexture:Hide()

    local todayBg = _G.CalendarTodayFrame:CreateBackdrop()
    todayBg:SetInside()
    todayBg:SetBackdropBorderColor(cr, cg, cb)

    for i, class in ipairs(CLASS_SORT_ORDER) do
        local bu = _G["CalendarClassButton" .. i]
        bu:GetRegions():Hide()
        bu:CreateBackdrop()
        S:ClassIconTexCoord(bu:GetNormalTexture(), class)
    end

    S:ReskinFilterButton(_G.CalendarFrame.FilterButton)
    _G.CalendarViewEventFrame:SetPoint("TOPLEFT", _G.CalendarFrame, "TOPRIGHT", -6, -24)
    _G.CalendarViewHolidayFrame:SetPoint("TOPLEFT", _G.CalendarFrame, "TOPRIGHT", -6, -24)
    _G.CalendarViewRaidFrame:SetPoint("TOPLEFT", _G.CalendarFrame, "TOPRIGHT", -6, -24)
    _G.CalendarCreateEventFrame:SetPoint("TOPLEFT", _G.CalendarFrame, "TOPRIGHT", -6, -24)
    _G.CalendarCreateEventInviteButton:SetPoint("TOPLEFT", _G.CalendarCreateEventInviteEdit, "TOPRIGHT", 1, 1)
    _G.CalendarClassButton1:SetPoint("TOPLEFT", _G.CalendarClassButtonContainer, "TOPLEFT", 5, 0)

    local line = _G.CalendarMassInviteFrame:CreateTexture(nil, "BACKGROUND")
    line:SetSize(240, E.mult)
    line:SetPoint("TOP", _G.CalendarMassInviteFrame, "TOP", 0, -150)
    line:SetTexture(DB.bdTex)
    line:SetVertexColor(0, 0, 0)

    _G.CalendarMassInviteFrame:ClearAllPoints()
    _G.CalendarMassInviteFrame:SetPoint("BOTTOMLEFT", _G.CalendarCreateEventFrame, "BOTTOMRIGHT", 28, 0)
    _G.CalendarTexturePickerFrame:ClearAllPoints()
    _G.CalendarTexturePickerFrame:SetPoint("TOPLEFT", _G.CalendarCreateEventFrame, "TOPRIGHT", 28, 0)

    local cbuttons = {
        "CalendarViewEventAcceptButton",
        "CalendarViewEventTentativeButton",
        "CalendarViewEventDeclineButton",
        "CalendarViewEventRemoveButton",
        "CalendarCreateEventMassInviteButton",
        "CalendarCreateEventCreateButton",
        "CalendarCreateEventInviteButton",
        "CalendarEventPickerCloseButton",
        "CalendarCreateEventRaidInviteButton",
        "CalendarTexturePickerAcceptButton",
        "CalendarTexturePickerCancelButton",
        "CalendarMassInviteAcceptButton",
    }
    for i = 1, #cbuttons do
        local cbutton = _G[cbuttons[i]]
        if cbutton then S:Reskin(cbutton) end
    end

    _G.CalendarViewEventAcceptButton.flashTexture:SetTexture("")
    _G.CalendarViewEventTentativeButton.flashTexture:SetTexture("")
    _G.CalendarViewEventDeclineButton.flashTexture:SetTexture("")

    S:ReskinClose(_G.CalendarCloseButton, _G.CalendarFrame, -14, -4)
    S:ReskinClose(_G.CalendarCreateEventCloseButton)
    S:ReskinClose(_G.CalendarViewEventCloseButton)
    S:ReskinClose(_G.CalendarViewHolidayCloseButton)
    S:ReskinClose(_G.CalendarViewRaidCloseButton)
    S:ReskinClose(_G.CalendarMassInviteCloseButton)

    S:ReskinDropDown(_G.CalendarCreateEventFrame.CommunityDropdown)
    S:ReskinDropDown(_G.CalendarCreateEventFrame.EventTypeDropdown)
    S:ReskinDropDown(_G.CalendarCreateEventFrame.HourDropdown)
    S:ReskinDropDown(_G.CalendarCreateEventFrame.MinuteDropdown)
    S:ReskinDropDown(_G.CalendarCreateEventFrame.AMPMDropdown)
    S:ReskinDropDown(_G.CalendarMassInviteFrame.CommunityDropdown)
    S:ReskinDropDown(_G.CalendarMassInviteFrame.RankDropdown)

    S:ReskinEditBox(_G.CalendarCreateEventTitleEdit)
    S:ReskinEditBox(_G.CalendarCreateEventInviteEdit)
    S:ReskinEditBox(_G.CalendarMassInviteMinLevelEdit)
    S:ReskinEditBox(_G.CalendarMassInviteMaxLevelEdit)
    S:ReskinArrow(_G.CalendarPrevMonthButton, "left")
    S:ReskinArrow(_G.CalendarNextMonthButton, "right")
    _G.CalendarPrevMonthButton:SetSize(19, 19)
    _G.CalendarNextMonthButton:SetSize(19, 19)
    S:ReskinCheck(_G.CalendarCreateEventLockEventCheck)
end

S:AddCallbackForAddon("Blizzard_Calendar", "Calendar")
