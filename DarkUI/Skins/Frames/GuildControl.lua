local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB
local cr, cg, cb = DB.r, DB.g, DB.b

------------------------------------------------------------------------
-- Guild Control UI
-- Ported from AuroraClassic AddOns/Blizzard_GuildControlUI.lua (2026-06)
------------------------------------------------------------------------

local _G = _G
local select, pairs = select, pairs
local hooksecurefunc = hooksecurefunc

local function updateGuildRanks()
    for i = 1, GuildControlGetNumRanks() do
        local rank = _G["GuildControlUIRankOrderFrameRank" .. i]
        if not rank.__styled then
            rank.upButton.icon:Hide()
            rank.downButton.icon:Hide()
            rank.deleteButton.icon:Hide()

            S:ReskinArrow(rank.upButton, "up")
            S:ReskinArrow(rank.downButton, "down")
            S:ReskinClose(rank.deleteButton)
            S:ReskinInput(rank.nameBox, 20)

            rank.__styled = true
        end
    end
end

function S:GuildControl()
    if not (C.skins.enable and C.skins.guild) then return end

    S:SetBD(_G.GuildControlUI)

    for i = 1, 9 do
        select(i, _G.GuildControlUI:GetRegions()):Hide()
    end

    for i = 1, 8 do
        select(i, _G.GuildControlUIRankBankFrameInset:GetRegions()):Hide()
    end

    _G.GuildControlUIRankSettingsFrameOfficerBg:SetAlpha(0)
    _G.GuildControlUIRankSettingsFrameRosterBg:SetAlpha(0)
    _G.GuildControlUIRankSettingsFrameBankBg:SetAlpha(0)
    _G.GuildControlUITopBg:Hide()
    _G.GuildControlUIHbar:Hide()

    -- Guild ranks
    local f = CreateFrame("Frame")
    f:RegisterEvent("GUILD_RANKS_UPDATE")
    f:SetScript("OnEvent", updateGuildRanks)
    hooksecurefunc("GuildControlUI_RankOrder_Update", updateGuildRanks)

    -- Guild tabs / bank permissions
    local checkboxes = { "viewCB", "depositCB" }
    hooksecurefunc("GuildControlUI_BankTabPermissions_Update", function()
        for i = 1, GetNumGuildBankTabs() + 1 do
            local tab = "GuildControlBankTab" .. i
            local bu = _G[tab]
            if bu and not bu.__styled then
                local ownedTab = bu.owned

                _G[tab .. "Bg"]:Hide()
                S:ReskinIcon(ownedTab.tabIcon)
                bu:CreateBackdrop()
                S:Reskin(bu.buy.button)
                S:ReskinInput(ownedTab.editBox)

                for _, name in pairs(checkboxes) do
                    local box = ownedTab[name]
                    box:SetNormalTexture(0)
                    box:SetPushedTexture(0)
                    box:SetHighlightTexture(DB.bdTex)

                    local check = box:GetCheckedTexture()
                    check:SetDesaturated(true)
                    check:SetVertexColor(cr, cg, cb)

                    box.backdrop = nil
                    local bg = box:CreateBackdrop()
                    bg:SetInside(box, 4, 4)

                    local hl = box:GetHighlightTexture()
                    hl:SetInside(bg)
                    hl:SetVertexColor(cr, cg, cb, 0.25)
                end

                bu.__styled = true
            end
        end
    end)

    S:ReskinCheck(_G.GuildControlUIRankSettingsFrameOfficerCheckbox)
    for i = 1, 20 do
        local checkbox = _G["GuildControlUIRankSettingsFrameCheckbox" .. i]
        if checkbox then S:ReskinCheck(checkbox) end
    end

    S:Reskin(_G.GuildControlUIRankOrderFrameNewButton)
    S:ReskinClose(_G.GuildControlUICloseButton)
    S:ReskinTrimScroll(_G.GuildControlUIRankBankFrameInsetScrollFrame.ScrollBar)
    S:ReskinDropDown(_G.GuildControlUINavigationDropdown)
    S:ReskinDropDown(_G.GuildControlUIRankSettingsFrameRankDropdown)
    S:ReskinDropDown(_G.GuildControlUIRankBankFrameRankDropdown)
    S:ReskinInput(_G.GuildControlUIRankSettingsFrameGoldBox, 20)
end

S:AddCallbackForAddon("Blizzard_GuildControlUI", "GuildControl")
