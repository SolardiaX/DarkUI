local E, C, L = select(2, ...):unpack()

lpanels:CreateLayout("AFK", {
-- AFK panel
{	name = "AFK", anchor_to = "TOP", y_off = -210,
	width = 180, height = 80,
	text = {
			{	string = L.PANELS_AFK, anchor_to = "TOP", y_off = -10,
				shadow = 0, outline = 3, font = STANDARD_TEXT_FONT, size = 12,
			},
			{	string = function()
					if afk_timer then
						local secs = mod(time() - afk_timer, 60)
						local mins = floor((time() - afk_timer) / 60)
					return format("%s:%02.f", mins, secs)
					end
				end, update = 0.1,
				shadow = 0, outline = 3, font = STANDARD_TEXT_FONT, size = 12 * 2,
				anchor_to = "CENTER", color = "1 0.1 0.1"
			},
			{	string = L.PANELS_AFK_RCLICK, anchor_to = "BOTTOM", y_off = 13,
				shadow = 0, outline = 3, font = STANDARD_TEXT_FONT, size = 12,
			},
			{	string = L.PANELS_AFK_LCLICK, anchor_to = "BOTTOM", y_off = 3,
				shadow = 0, outline = 3, font = STANDARD_TEXT_FONT, size = 12,
			}
		},
		OnLoad = function(self)
			self:RegisterEvent("PLAYER_FLAGS_CHANGED")
			self:SetTemplate("Transparent")
			self:Hide()
			self:SetWidth(self.text4:GetWidth() + 20)
		end,
		OnEvent = function(self)
			if UnitIsAFK("player") and not afk_timer then
				self.text2:SetText("0:00")
				afk_timer = time()
				self:Show()
			elseif not UnitIsAFK("player") then
				self:Hide()
				afk_timer = nil
			end
		end,
		OnClick = function(self, b)
			self:Hide()
			if b == "LeftButton" then SendChatMessage("", "AFK") end
		end,
		OnEnter = function(self) self:SetBackdropBorderColor(E.myColor.r, E.myColor.g, E.myColor.b) end,
		OnLeave = function(self) self:SetBackdropBorderColor(unpack(C.Media.border_color)) end
	},
})

lpanels:ApplyLayout(nil, "AFK")