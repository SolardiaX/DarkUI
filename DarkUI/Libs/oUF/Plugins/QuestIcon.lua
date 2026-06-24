local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Quest Icons on Nameplates (based on ElvUI)
------------------------------------------------------------------------
local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF not loaded")

local wipe, ipairs, next, ceil, floor, tonumber = wipe, ipairs, next, ceil, floor, tonumber
local strmatch, strlower, strfind = strmatch, strlower, strfind
local issecretvalue = issecretvalue
local canaccessvalue = canaccessvalue
local IsInInstance = IsInInstance
local UnitGUID = UnitGUID
local GetLocale = GetLocale
local GetQuestLogSpecialItemInfo = GetQuestLogSpecialItemInfo

local C_QuestLog_GetQuestObjectives = C_QuestLog.GetQuestObjectives
local C_QuestLog_GetLogIndexForQuestID = C_QuestLog.GetLogIndexForQuestID
local C_QuestLog_GetQuestIDForLogIndex = C_QuestLog.GetQuestIDForLogIndex
local C_QuestLog_GetNumQuestLogEntries = C_QuestLog.GetNumQuestLogEntries
local C_QuestLog_GetTitleForQuestID = C_QuestLog.GetTitleForQuestID
local C_TooltipInfo_GetUnit = C_TooltipInfo and C_TooltipInfo.GetUnit

local iconTypes = { "Default", "Item", "Skull", "Chat" }
local questElements = {
	DEFAULT = "Default",
	KILL = "Skull",
	CHAT = "Chat",
	QUEST_ITEM = "Item",
}

local activeQuests = {} -- [title] = {id, index, texture, objectives}
local activeTitles = {} -- [id] = title

------------------------------------------------------------------------
-- Localized Type Classification
------------------------------------------------------------------------

local typesLocalized = {
	enUS = {
		KILL = { "slain", "destroy", "eliminate", "repel", "kill", "defeat" },
		CHAT = { "speak", "talk" },
	},
	deDE = {
		KILL = { "besiegen", "besiegt", "getötet", "töten", "tötet", "vernichtet", "zerstört" },
		CHAT = { "befragt", "sprecht" },
	},
	frFR = {
		KILL = { "tué", "tuer", "abattre", "abattu", "détrui", "élimin", "repouss", "vaincu" },
		CHAT = { "parle", "demande" },
	},
	koKR = {
		KILL = { "쓰러뜨리기", "물리치기", "공격", "파괴" },
		CHAT = { "대화" },
	},
	zhCN = {
		KILL = { "消灭", "摧毁", "击败", "毁灭", "击退", "杀死" },
		CHAT = { "交谈", "谈一谈" },
	},
	zhTW = {
		KILL = { "毀滅", "擊退", "殺死" },
		CHAT = { "交談", "說話" },
	},
}

local questTypes = typesLocalized[GetLocale()] or typesLocalized.enUS

------------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------------

local function GetObjectiveType(text, texture)
	if texture then return "QUEST_ITEM" end

	local lowerText = strlower(text)
	for _, keyword in ipairs(questTypes.KILL) do
		if strfind(lowerText, keyword, nil, true) then return "KILL" end
	end
	for _, keyword in ipairs(questTypes.CHAT) do
		if strfind(lowerText, keyword, nil, true) then return "CHAT" end
	end
end

local function GetQuestObjectives(id, texture)
	local objectives = C_QuestLog_GetQuestObjectives(id)
	if not objectives then return end

	local list
	for _, objective in next, objectives do
		local text = not objective.finished and objective.text
		if text then
			if objective.type == "progressbar" then
				local progress = tonumber(strmatch(text, "([%d%.]+)%%"))
				if progress and progress <= 100 then
					if not list then list = {} end
					list[text] = { value = ceil(100 - progress), type = GetObjectiveType(text, texture), isPercent = true }
				end
			else
				local need = objective.numRequired
				local have = objective.numFulfilled
				if need and have then
					local diff = floor(need - have)
					if diff > 0 then
						if not list then list = {} end
						list[text] = { value = diff, type = GetObjectiveType(text, texture), isPercent = false }
					end
				end
			end
		end
	end

	return list
end

local function UpdateQuest(id, index)
	local title = C_QuestLog_GetTitleForQuestID(id)
	if not title then return end

	if not index then
		index = C_QuestLog_GetLogIndexForQuestID(id)
	end
	if not index then return end

	local _, texture = GetQuestLogSpecialItemInfo(index)

	activeTitles[id] = title
	activeQuests[title] = {
		id = id,
		index = index,
		texture = texture,
		objectives = GetQuestObjectives(id, texture),
	}
end

------------------------------------------------------------------------
-- Tooltip Scanning
------------------------------------------------------------------------

local function GetQuests(unitID)
	if IsInInstance() then return end
	if not canaccessvalue(unitID) then return end

	local data = C_TooltipInfo_GetUnit(unitID)
	if not data or not data.lines then return end

	local QuestList, notMyQuest, lastTitle

	for i = 3, #data.lines do
		local line = data.lines[i]
		local text = line.leftText
		if not text or text == "" then break end
		if issecretvalue(text) then return end

		if line.type == 18 then -- QuestPlayer
			notMyQuest = text ~= E.myName
		elseif not notMyQuest then
			if line.type == 17 then -- QuestTitle
				lastTitle = activeQuests[text]
			elseif line.type == 8 and lastTitle then -- QuestObjective
				local objectives = lastTitle.objectives
				if objectives then
					local quest = objectives[text]
					if quest then
						if not QuestList then QuestList = {} end
						QuestList[#QuestList + 1] = {
							itemTexture = lastTitle.texture,
							isPercent = quest.isPercent,
							objectiveCount = quest.value,
							questType = quest.type or "DEFAULT",
						}
					end
				end
			end
		end
	end

	return QuestList
end

------------------------------------------------------------------------
-- oUF Element
------------------------------------------------------------------------

local function HideIcon(icon)
	icon:Hide()
	if icon.Text then icon.Text:SetText("") end
end

local function HideIcons(element)
	for _, name in ipairs(iconTypes) do
		HideIcon(element[name])
	end
end

local function Update(self, event)
	local element = self.QuestIcons
	if not element then return end

	local unit = self.unit
	if not unit then return end

	if IsInInstance() then return end

	local list
	local guid = UnitGUID(unit)
	if not issecretvalue(guid) and element.guid ~= guid then
		element.guid = guid
	elseif event == "UNIT_NAME_UPDATE" or event == "NAME_PLATE_UNIT_ADDED" then
		list = element.lastQuests
	end

	if element.PreUpdate then element:PreUpdate() end

	if not list then
		list = GetQuests(unit)
		element.lastQuests = list
	end

	element:SetShown(list ~= nil)

	if list then
		HideIcons(element)

		local shown = 0
		for _, quest in ipairs(list) do
			local objectiveCount = quest.objectiveCount
			local questType = quest.questType
			local isPercent = quest.isPercent

			local icon = (isPercent or objectiveCount > 0) and element[questElements[questType] or "Default"]
			if icon and not icon:IsShown() then
				icon:Show()
				icon:ClearAllPoints()
				icon:SetPoint("LEFT", element, "LEFT", shown * (icon:GetWidth() + 2), 0)
				shown = shown + 1

				if questType ~= "CHAT" and icon.Text and (isPercent or objectiveCount > 1) then
					icon.Text:SetText(isPercent and (objectiveCount .. "%") or objectiveCount)
				end

				if questType == "QUEST_ITEM" and quest.itemTexture then
					icon:SetTexture(quest.itemTexture)
				end
			end
		end
	end

	if element.PostUpdate then return element:PostUpdate() end
end

local function Path(self, ...)
	return (self.QuestIcons.Override or Update)(self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
	local element = self.QuestIcons
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent("QUEST_LOG_UPDATE", Path, true)
		self:RegisterEvent("UNIT_NAME_UPDATE", Path, true)

		return true
	end
end

local function Disable(self)
	local element = self.QuestIcons
	if element then
		element:Hide()
		HideIcons(element)
		element.lastQuests = nil
		element.guid = nil

		self:UnregisterEvent("QUEST_LOG_UPDATE", Path)
		self:UnregisterEvent("UNIT_NAME_UPDATE", Path)
	end
end

------------------------------------------------------------------------
-- Quest Cache Frame
------------------------------------------------------------------------

local frame = CreateFrame("Frame")
frame:RegisterEvent("QUEST_ACCEPTED")
frame:RegisterEvent("QUEST_REMOVED")
frame:RegisterEvent("QUEST_LOG_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function(self, event, questID)
	if event == "QUEST_ACCEPTED" then
		UpdateQuest(questID)
	elseif event == "QUEST_REMOVED" then
		local title = activeTitles[questID]
		if title then
			activeQuests[title] = nil
			activeTitles[questID] = nil
		end
	else
		wipe(activeQuests)
		wipe(activeTitles)

		for index = 1, C_QuestLog_GetNumQuestLogEntries() do
			local id = C_QuestLog_GetQuestIDForLogIndex(index)
			if id and id > 0 then
				UpdateQuest(id, index)
			end
		end

		if event == "PLAYER_ENTERING_WORLD" then
			self:UnregisterEvent(event)
		end
	end
end)

oUF:AddElement("QuestIcons", Path, Enable, Disable)
