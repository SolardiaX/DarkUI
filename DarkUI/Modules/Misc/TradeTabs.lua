local TradeTabs = CreateFrame("Frame","TradeTabs")

local whitelist = {
	[129] = true, -- 急救 First Aid
	[164] = true, -- 煅造 Blacksmithing 
	[165] = true, -- 制皮 Leatherworking	
	[171] = true, -- 炼金 Alchemy 	
    [182] = true, -- 草药学 herbalism	
	[186] = true, -- 采矿 Mining	
	[202] = true, -- 工程 Engineering
	[333] = true, -- 附魔 Enchanting 
	[755] = true, -- 珠宝 Jewelcrafting
	[773] = true, -- 铭文 Inscription
	[794] = true, -- 考古 Archaeology
	[356] = true, -- 钓鱼 Fishing
	[185] = true, -- 烹饪 Cooking 
	[197] = true, -- 裁缝 Tailoring
    [393] = true, -- 剥皮 skinning
}

local onlyPrimary = {
	[171] = true, --炼金 Alchemy
	[202] = true, --工程 Engineering
}

local items = 67556       --大厨的帽子 134020
local RUNEFORGING = 53428 --DK的符文附魔 Runeforging spellid

function TradeTabs:OnEvent(event,...)
	self:UnregisterEvent(event)
	if not IsLoggedIn() then
		self:RegisterEvent(event)
	elseif InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		self:Initialize()
	end
end

local function buildSpellList()
	local profs = {GetProfessions()}
	local tradeSpells = {}
	local extras =  0
	for _,prof in pairs(profs) do
		local name, icon, _, _, numAbilities, spelloffset, skillLine = GetProfessionInfo(prof)  
		if whitelist[skillLine] then
			if onlyPrimary[skillLine] then
				numAbilities = 1
			end
			for i = 1, numAbilities do
				if not IsPassiveSpell(i + spelloffset, BOOKTYPE_PROFESSION) then
					if i > 1 then
						tinsert(tradeSpells, i + spelloffset)
						extras = extras + 1
					else
						tinsert(tradeSpells, #tradeSpells + 1 - extras, i + spelloffset)
					end
				end
			end
		end
	end

	return tradeSpells
end

function TradeTabs:Initialize()
	if self.initialized or not IsAddOnLoaded("Blizzard_TradeSkillUI") then return end -- Shouldn't need this, but I'm paranoid
	local parent = TradeSkillFrame
	local tradeSpells = buildSpellList()
	local i = 1
	local prev
	
	-- if player is a DK, insert runeforging at the top
	if select(2, UnitClass("player")) == "DEATHKNIGHT" then
		prev = self:CreateTab(i, parent, RUNEFORGING)
		prev:SetPoint("TOPLEFT", parent, "TOPRIGHT", 0, -22)
		i = i + 1
	end

    local _,_,_,_,cooking = GetProfessions()
	if cooking then
		prev = self:CreateTab(i, parent, items)
		prev:SetPoint("TOPLEFT", parent, "TOPRIGHT", 0, -22)
		prev:SetAttribute('type1','macro')
		prev:SetAttribute('macrotext', "/use 大厨的帽子")
		i = i + 1
	end

	for i, slot in ipairs(tradeSpells) do
		local _, spellID = GetSpellBookItemInfo(slot, BOOKTYPE_PROFESSION)
		local tab = self:CreateTab(i, parent, spellID)
		i = i + 1
		local point,relPoint,x,y = "TOPLEFT", "BOTTOMLEFT", 0, -15
		if not prev then
			prev, relPoint, x, y = parent, "TOPRIGHT", 0, -22
		end
		tab:SetPoint(point, prev, relPoint, x, y)
		prev = tab
	end
	self.initialized = true
end

local function onEnter(self) 
	GameTooltip:SetOwner(self,"ANCHOR_RIGHT") GameTooltip:SetText(self.tooltip) 
	self:GetParent():LockHighlight()
end

local function onLeave(self) 
	GameTooltip:Hide()
	self:GetParent():UnlockHighlight()
end   

local function updateSelection(self)
	if IsCurrentSpell(self.spell) then
		self:SetChecked(true)
		self.clickStopper:Show()
	else
		self:SetChecked(false)
		self.clickStopper:Hide()
	end
end

local function createClickStopper(button)
	local f = CreateFrame("Frame",nil,button)

	f:SetAllPoints(button)
	f:EnableMouse(true)
	f:SetScript("OnEnter",onEnter)
	f:SetScript("OnLeave",onLeave)
	
	button.clickStopper = f
	f.tooltip = button.tooltip
	f:Hide()
end

local ENCHANTING_VELLUM = 38682
local C_TradeSkillUI_GetRecipeInfo, C_TradeSkillUI_GetTradeSkillLine = C_TradeSkillUI.GetRecipeInfo, C_TradeSkillUI.GetTradeSkillLine
local isEnchanting
local tooltipString = "|cffffaa0e%s (%d)"
local function IsRecipeEnchanting(self)
	isEnchanting = nil
	local recipeID = self.selectedRecipeID
	local recipeInfo = recipeID and C_TradeSkillUI_GetRecipeInfo(recipeID)
	if recipeInfo and recipeInfo.alternateVerb then
		local parentSkillLineID = select(6, C_TradeSkillUI_GetTradeSkillLine())
		if parentSkillLineID == 333 then
			isEnchanting = true
			self.CreateButton.tooltip = format(tooltipString, "右键：附魔羊皮纸", GetItemCount(ENCHANTING_VELLUM))
		end
	end
end

function QuickEnchanting()
	if not TradeSkillFrame then return end
	local detailsFrame = TradeSkillFrame.DetailsFrame
	hooksecurefunc(detailsFrame, "RefreshDisplay", IsRecipeEnchanting)
	local createButton = detailsFrame.CreateButton
	createButton:RegisterForClicks("AnyUp")
	createButton:HookScript("OnClick", function(self, btn)
		if btn == "RightButton" and isEnchanting then
			UseItemByName(ENCHANTING_VELLUM)
		end
	end)
end

function TradeTabs:CreateTab(i, parent, spellID)
	local spell, _, texture = GetSpellInfo(spellID)
	local button = CreateFrame("CheckButton", "TradeTabsTab"..i, parent, "SpellBookSkillLineTabTemplate, SecureActionButtonTemplate")
	button.tooltip = spell
	button.spellID = spellID
	button.spell = spellID
	button:Show()
	button:SetAttribute("type","spell")
	button:SetAttribute("spell",spellID)
	button:SetNormalTexture(texture)
	button:SetScript("OnEvent",updateSelection)
	button:RegisterEvent("TRADE_SKILL_SHOW")
	button:RegisterEvent("TRADE_SKILL_CLOSE")
	button:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")
	createClickStopper(button)
	updateSelection(button)
	QuickEnchanting()
	return button
end
TradeTabs:RegisterEvent("TRADE_SKILL_SHOW")	
TradeTabs:SetScript("OnEvent",TradeTabs.OnEvent)
TradeTabs:Initialize()

local aFrame = CreateFrame("Frame")
      aFrame:RegisterEvent("ADDON_LOADED")
      aFrame:SetScript("onEvent",function(self, event, ...)
        local arg1 = ...
        if arg1 == "Blizzard_TradeSkillUI" then 
        local Fm = TradeSkillFrame.OptionalReagentList
        Fm:ClearAllPoints()
        Fm:SetPoint("TOPRIGHT", TradeSkillFrame, "TOPRIGHT", 224, -14)
    end
end)

--制造界面添加 [材料齐备] 勾选框 2018.12.20 完成。
local myButtonCheck = CreateFrame("Frame")
      myButtonCheck:RegisterEvent("ADDON_LOADED")
      myButtonCheck:SetScript("onEvent",function(self,event,...)
         local arg1 = ...
         if arg1 == "Blizzard_TradeSkillUI" then 
            myButtonCheck = CreateFrame("CheckButton",nil,TradeSkillFrame,"UICheckButtonTemplate")  
            myButtonCheck:SetPoint("TOPLEFT", TradeSkillFrame, "TOPRIGHT", -170,-52)
            myButtonCheck:SetSize(28,28)
            myButtonCheck.text:SetText("材料齐备")
            myButtonCheck.text:SetFont(ChatFontNormal:GetFont(), 13, "")
            myButtonCheck:SetScript("OnClick", function() 
                C_TradeSkillUI.SetOnlyShowMakeableRecipes(not C_TradeSkillUI.GetOnlyShowMakeableRecipes());
            end)  
        end
    end)

--制造界面添加 [提高技能] 勾选框 2018.12.20 完成。
--[[
local myButtonCheck2 = CreateFrame("Frame")
      myButtonCheck2:RegisterEvent("ADDON_LOADED")
      myButtonCheck2:SetScript("onEvent",function(self,event,...)
         local arg1 = ...
         if arg1 == "Blizzard_TradeSkillUI" then 
            myButtonCheck2 = CreateFrame("CheckButton",nil,TradeSkillFrame,"UICheckButtonTemplate")  
            myButtonCheck2:SetPoint("TOPLEFT", TradeSkillFrame, "TOPRIGHT", -256,-52)
            myButtonCheck2:SetSize(28,28)
            myButtonCheck2.text:SetText("提高技能")
            myButtonCheck2.text:SetFont(ChatFontNormal:GetFont(), 13, "")
            myButtonCheck2:SetScript("OnClick", function() 
                C_TradeSkillUI.SetOnlyShowSkillUpRecipes(not C_TradeSkillUI.GetOnlyShowSkillUpRecipes());
            end)  
        end
    end)
	]]