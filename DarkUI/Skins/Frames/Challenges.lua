local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB

------------------------------------------------------------------------
-- Mythic+ Challenges UI
-- Ported from AuroraClassic AddOns/Blizzard_ChallengesUI.lua (2026-06)
-- Note: Aurora noise overlay dropped; DarkUI backdrop already carries texture.
------------------------------------------------------------------------

local _G = _G
local hooksecurefunc = hooksecurefunc

function S:ChallengesUI()
    if not (C.skins.enable and C.skins.lfg) then return end

    _G.ChallengesFrameInset:Hide()
    for i = 1, 2 do
        select(i, _G.ChallengesFrame:GetRegions()):Hide()
    end

    local angryStyle
    local function updateIcons(self)
        for i = 1, #self.maps do
            local bu = self.DungeonIcons[i]
            if bu and not bu.__styled then
                bu:GetRegions():SetAlpha(0)
                bu.Icon:SetTexCoord(unpack(DB.TexCoord))
                bu.Icon:SetInside()
                bu.Icon:CreateBackdrop()
                bu.Icon.backdrop:SetBackdropColor(0, 0, 0, 0)

                bu.__styled = true
            end
            if i == 1 then
                self.WeeklyInfo.Child.SeasonBest:ClearAllPoints()
                self.WeeklyInfo.Child.SeasonBest:SetPoint("BOTTOMLEFT", self.DungeonIcons[i], "TOPLEFT", 0, 2)
            end
        end

        if C_AddOns.IsAddOnLoaded("AngryKeystones") and not angryStyle then
            local mod = AngryKeystones.Modules.Schedule
            local scheduel = mod.AffixFrame
            if scheduel then
                scheduel:StripTextures()
                scheduel:CreateBackdrop()
                scheduel.backdrop:SetBackdropColor(0, 0, 0, 0.25)
                if scheduel.Entries then
                    for i = 1, 3 do
                        S:AffixesSetup(scheduel.Entries[i])
                    end
                end

                local party = mod.PartyFrame
                party:StripTextures()
                party:CreateBackdrop()
                party.backdrop:SetBackdropColor(0, 0, 0, 0.25)
            end

            angryStyle = true
        end
    end
    hooksecurefunc(_G.ChallengesFrame, "Update", updateIcons)

    hooksecurefunc(_G.ChallengesFrame.WeeklyInfo, "SetUp", function(self)
        local affixes = C_MythicPlus.GetCurrentAffixes()
        if affixes then S:AffixesSetup(self.Child) end
    end)

    local keystone = _G.ChallengesKeystoneFrame
    S:SetBD(keystone)
    S:ReskinClose(keystone.CloseButton)
    S:Reskin(keystone.StartButton)

    hooksecurefunc(keystone, "Reset", function(self)
        self:GetRegions():SetAlpha(0)
        self.InstructionBackground:SetAlpha(0)
    end)

    hooksecurefunc(keystone, "OnKeystoneSlotted", function(self) S:AffixesSetup(self) end)

    -- New season
    local noticeFrame = _G.ChallengesFrame.SeasonChangeNoticeFrame
    S:Reskin(noticeFrame.Leave)
    noticeFrame.Leave.__bg:SetFrameLevel(noticeFrame:GetFrameLevel() + 1)
    noticeFrame.NewSeason:SetTextColor(1, 0.8, 0)
    noticeFrame.SeasonDescription:SetTextColor(1, 1, 1)
    noticeFrame.SeasonDescription2:SetTextColor(1, 1, 1)
    noticeFrame.SeasonDescription3:SetTextColor(1, 0.8, 0)

    local affix = noticeFrame.Affix
    affix:StripTextures()
    local bg = S:ReskinIcon(affix.Portrait)
    bg:SetFrameLevel(3)

    hooksecurefunc(affix, "SetUp", function(_, affixID)
        local _, _, texture = C_ChallengeMode.GetAffixInfo(affixID)
        if texture then affix.Portrait:SetTexture(texture) end
    end)
end

S:AddCallbackForAddon("Blizzard_ChallengesUI", "ChallengesUI")
