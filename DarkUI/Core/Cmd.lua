local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
-- Slash Commands
----------------------------------------------------------------------------------------
SlashCmdList["RELOADUI"] = function()
    ReloadUI()
end
SLASH_RELOADUI1 = "/rl"

SlashCmdList["RCSLASH"] = function()
    DoReadyCheck()
end
SLASH_RCSLASH1 = "/rc"

SlashCmdList["TICKET"] = function()
    ToggleHelpFrame()
end
SLASH_TICKET1 = "/gm"

-- Align by Akeru @wowinterface

local grid
local boxSize = 32

local function createGrid()
    grid = CreateFrame("Frame", nil, UIParent)
    grid:SetAllPoints(UIParent)

    grid.boxSize = boxSize

    local size = 2
    local width = GetScreenWidth()
    local ratio = width / GetScreenHeight()
    local height = GetScreenHeight() * ratio

    local wStep = width / boxSize
    local hStep = height / boxSize

    for i = 0, boxSize do
        local tx = grid:CreateTexture(nil, "BACKGROUND")
        if i == boxSize / 2 then
            tx:SetColorTexture(1, 0, 0, 0.5)
        else
            tx:SetColorTexture(0, 0, 0, 0.5)
        end
        tx:SetPoint("TOPLEFT", grid, "TOPLEFT", i * wStep - (size / 2), 0)
        tx:SetPoint("BOTTOMRIGHT", grid, "BOTTOMLEFT", i * wStep + (size / 2), 0)
    end

    height = GetScreenHeight()

    do
        local tx = grid:CreateTexture(nil, "BACKGROUND")
        tx:SetColorTexture(1, 0, 0, 0.5)
        tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height / 2) + (size / 2))
        tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height / 2 + size / 2))
    end

    for i = 1, math.floor((height / 2) / hStep) do
        local tx = grid:CreateTexture(nil, "BACKGROUND")
        tx:SetColorTexture(0, 0, 0, 0.5)

        tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height / 2 + i * hStep) + (size / 2))
        tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height / 2 + i * hStep + size / 2))

        tx = grid:CreateTexture(nil, "BACKGROUND")
        tx:SetColorTexture(0, 0, 0, 0.5)

        tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height / 2 - i * hStep) + (size / 2))
        tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height / 2 - i * hStep + size / 2))
    end
end

function showGrid()
    if not grid then
        createGrid()
    elseif grid.boxSize ~= boxSize then
        grid:Hide()
        createGrid()
    else
        grid:Show()
    end
end

function hideGrid()
    if grid then
        grid:Hide()
    end
end

local isAligning = false
SLASH_TOGGLEGRID1 = "/align"
SlashCmdList["TOGGLEGRID"] = function(arg)
    if isAligning then
        hideGrid()
        isAligning = false
    else
        boxSize = (math.ceil((tonumber(arg) or boxSize) / 32) * 32)
        if boxSize > 256 then
            boxSize = 256
        end
        showGrid()
        isAligning = true
    end
end

--  Command to show frame you currently have mouseovered
SlashCmdList["FRAME"] = function(arg)
    if arg ~= "" then
        arg = _G[arg]
    else
        arg = GetMouseFoci()[1]
    end
    if arg ~= nil then
        _G.FRAME = arg
    end
    if arg ~= nil and not arg:IsForbidden() then
        local point, relativeTo, relativePoint, xOfs, yOfs = arg:GetPoint()
        ChatFrame1:AddMessage("|cffCC0000~~~~~~~~~~~~~~~~~~~~~~~~~")
        ChatFrame1:AddMessage("Name: |cffFFD100" .. (arg:GetName() or "<unamed>"))
        if arg:GetParent() and arg:GetParent():GetName() then
            ChatFrame1:AddMessage("Parent: |cffFFD100" .. arg:GetParent():GetName())
        end

        ChatFrame1:AddMessage("Width: |cffFFD100" .. format("%.2f", arg:GetWidth()))
        ChatFrame1:AddMessage("Height: |cffFFD100" .. format("%.2f", arg:GetHeight()))
        ChatFrame1:AddMessage("Scale: |cffFFD100" .. arg:GetScale())
        ChatFrame1:AddMessage("Strata: |cffFFD100" .. arg:GetFrameStrata())
        ChatFrame1:AddMessage("Level: |cffFFD100" .. arg:GetFrameLevel())
        ChatFrame1:AddMessage("Visibility: |cffFFD100" .. (arg:IsShown() and "True" or "False"))

        if relativeTo and relativeTo:GetName() then
            ChatFrame1:AddMessage("Point: |cffFFD100" .. point .. "|r anchored to " .. relativeTo:GetName() .. "'s |cffFFD100" .. relativePoint)
        end
        if xOfs then
            ChatFrame1:AddMessage("X: |cffFFD100" .. format("%.2f", xOfs))
        end
        if yOfs then
            ChatFrame1:AddMessage("Y: |cffFFD100" .. format("%.2f", yOfs))
        end
        ChatFrame1:AddMessage("|cffCC0000~~~~~~~~~~~~~~~~~~~~~~~~~")
    elseif arg == nil then
        ChatFrame1:AddMessage("Invalid frame name")
    else
        ChatFrame1:AddMessage("Could not find frame info")
    end
end
SLASH_FRAME1 = "/frame"

------------------------------------------------------------------------
-- /darkui tpl — Template Preview
------------------------------------------------------------------------

local tplFrame

local function createTemplatePreview()
	local f = CreateFrame("Frame", "DarkUI_TemplateTest", UIParent, "BackdropTemplate")
	f:SetSize(640, 260)
	f:SetPoint("CENTER")
	f:SetFrameStrata("DIALOG")
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	f:SetTemplate("Default")
	f:CreateShadow()

	local title = f:CreateFontText(14, "DarkUI Template Preview", true)
	title:SetPoint("TOP", 0, -10)

	-- Row 1: SetTemplate modes
	local templates = { "Default", "Shadow", "Border", "Blur", "Transparent", "Overlay", "Invisible" }
	local xPos = 20
	for _, tpl in ipairs(templates) do
		local box = CreateFrame("Frame", nil, f, "BackdropTemplate")
		box:SetSize(60, 60)
		box:SetPoint("TOPLEFT", xPos, -40)
		box:SetTemplate(tpl)

		local label = f:CreateFontString(nil, "OVERLAY")
		label:SetFont(STANDARD_TEXT_FONT, 9, "OUTLINE")
		label:SetPoint("TOP", box, "BOTTOM", 0, -4)
		label:SetText(tpl)
		label:SetTextColor(0.8, 0.8, 0.8)

		xPos = xPos + 82
	end

	-- Row 2: Create* combinations
	local row2Y = -140
	local demos = {
		{ label = "CreateBG", fn = function(box) box:CreateBG() end },
		{ label = "BG+Shadow", fn = function(box)
			local bg = box:CreateBG()
			bg:CreateShadow()
		end },
		{ label = "CreateBorder", fn = function(box) box:CreateBorder(2) end },
		{ label = "BG+Gradient", fn = function(box)
			box:CreateBG()
			box:CreateGradient()
		end },
		{ label = "ReskinIcon", fn = function(box)
			local tex = box:CreateTexture(nil, "ARTWORK")
			tex:SetAllPoints()
			tex:SetTexture(134400)
			E:ReskinIcon(tex, true, box)
		end },
	}

	xPos = 20
	for _, demo in ipairs(demos) do
		local box = CreateFrame("Frame", nil, f)
		box:SetSize(48, 48)
		box:SetPoint("TOPLEFT", xPos, row2Y)
		demo.fn(box)

		local label = f:CreateFontString(nil, "OVERLAY")
		label:SetFont(STANDARD_TEXT_FONT, 9, "OUTLINE")
		label:SetPoint("TOP", box, "BOTTOM", 0, -4)
		label:SetText(demo.label)
		label:SetTextColor(0.8, 0.8, 0.8)

		xPos = xPos + 115
	end

	-- Close button
	local close = CreateFrame("Button", nil, f)
	close:SetSize(18, 18)
	close:SetPoint("TOPRIGHT", -6, -6)
	close:SetTemplate("Overlay")
	close.text = close:CreateFontText(14, "x")
	close.text:SetPoint("CENTER", 0, 1)
	close:SetScript("OnClick", function()
		f:Hide()
	end)

	return f
end

SLASH_DARKUI1 = "/darkui"
SlashCmdList["DARKUI"] = function(msg)
	msg = msg and msg:lower():trim() or ""
	if msg == "tpl" or msg == "template" then
		if not tplFrame then
			tplFrame = createTemplatePreview()
		end
		tplFrame:SetShown(not tplFrame:IsShown())
	else
		print("|cff00ff00DarkUI|r commands:")
		print("  /darkui tpl — Template style preview")
	end
end
