local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Mail
------------------------------------------------------------------------

local module = E:Module("Blizzard"):Sub("Mail")

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if C_AddOns.IsAddOnLoaded("Postal") or C_AddOns.IsAddOnLoaded("OpenAll") then return end

    local deletedelay = 0.5
    local t = 0
    local takingOnlyCash = false
    local button, button2
    local baseInboxFrame_OnClick
    local profit = 0
    local needsToWait = false
    local lastopened

    local function stopOpening(msg)
        button:SetScript("OnUpdate", nil)
        button:SetScript("OnClick", nil)
        button2:SetScript("OnClick", nil)
        if baseInboxFrame_OnClick then
            InboxFrame_OnClick = baseInboxFrame_OnClick
        end
        button:UnregisterEvent("UI_ERROR_MESSAGE")
        takingOnlyCash = false

        if msg then print("|cffffff00" .. msg .. "|r") end
        if profit > 0 then
            print(format("|cff66C6FF%s |cffFFFFFF%s", AMOUNT_RECEIVED_COLON, C_CurrencyInfo.GetCoinTextureString(profit)))
            profit = 0
        end

        -- re-bind after stop
        button:SetScript("OnClick", function() module:OpenAll() end)
        button2:SetScript("OnClick", function() module:OpenAllCash() end)
    end

    local function openMail(index)
        if not InboxFrame:IsVisible() then return stopOpening(L.MAIL_NEED or "Mailbox closed") end
        if index == 0 then return stopOpening(L.MAIL_COMPLETE or "All mail collected") end

        local _, _, _, _, money, COD, _, numItems = GetInboxHeaderInfo(index)
        if money > 0 then
            TakeInboxMoney(index)
            needsToWait = true
            profit = profit + money
        elseif not takingOnlyCash and numItems and numItems > 0 and COD <= 0 then
            TakeInboxItem(index)
            needsToWait = true
        end

        local items = GetInboxNumItems()
        if (numItems and numItems > 0) or (items > 1 and index <= items) then
            lastopened = index
            t = 0
            button:SetScript("OnUpdate", function(_, elapsed)
                t = t + elapsed
                if not needsToWait or t > deletedelay then
                    needsToWait = false
                    button:SetScript("OnUpdate", nil)
                    local _, _, _, _, m, c, _, n = GetInboxHeaderInfo(lastopened)
                    if m > 0 or (not takingOnlyCash and c <= 0 and n and n > 0) then
                        openMail(lastopened)
                    else
                        openMail(lastopened - 1)
                    end
                end
            end)
        else
            stopOpening(L.MAIL_COMPLETE or "All mail collected")
        end
    end

    function module:OpenAll()
        if GetInboxNumItems() == 0 then return end
        button:SetScript("OnClick", nil)
        button2:SetScript("OnClick", nil)
        baseInboxFrame_OnClick = InboxFrame_OnClick
        InboxFrame_OnClick = E.Dummy
        button:RegisterEvent("UI_ERROR_MESSAGE")
        openMail(GetInboxNumItems())
    end

    function module:OpenAllCash()
        takingOnlyCash = true
        self:OpenAll()
    end

    local function onEvent(_, _, _, text)
        if text == ERR_INV_FULL then
            stopOpening(L.MAIL_ENVFULL or "Inventory full")
        elseif text == ERR_ITEM_MAX_COUNT then
            stopOpening(L.MAIL_MAXCOUNT or "Unique item limit")
        end
    end

    local function makeButton(id, text, w, h, x, y)
        local b = CreateFrame("Button", id, InboxFrame, "UIPanelButtonTemplate")
        b:SetSize(w, h)
        b:SetPoint("CENTER", InboxFrame, "TOP", x, y)
        b:SetText(text)
        return b
    end

    button = makeButton("DarkUI_OpenAllButton", ALL, 70, 25, -65, -398)
    button:SetScript("OnClick", function() module:OpenAll() end)
    button:SetScript("OnEvent", onEvent)

    button2 = makeButton("DarkUI_OpenAllCashButton", MONEY, 70, 25, 18, -398)
    button2:SetScript("OnClick", function() module:OpenAllCash() end)

    -- Mouse wheel scrolling
    MailFrame:EnableMouseWheel(true)
    MailFrame:SetScript("OnMouseWheel", function(_, d)
        if d > 0 then
            InboxPrevPageButton:Click()
        else
            InboxNextPageButton:Click()
        end
    end)

    if OpenAllMail then OpenAllMail:Hide() end
end
