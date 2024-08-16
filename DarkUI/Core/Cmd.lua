local E, C, L = select(2, ...):unpack()

--[[
    DarkUI Slash Commands:
    /rl     - reload ui
    /rc     - raid ready check
    /gm     - call gm help
    --
    /frame  - get frame info on mouse hover or with global name
    /align  - toggle align grid on WorldFrame
]]

----------------------------------------------------------------------------------------
--	Core SlashCMD Methods
----------------------------------------------------------------------------------------
SlashCmdList["RELOADUI"] = function() ReloadUI() end
SLASH_RELOADUI1 = "/rl"

SlashCmdList["RCSLASH"] = function() DoReadyCheck() end
SLASH_RCSLASH1 = "/rc"

SlashCmdList["TICKET"] = function() ToggleHelpFrame() end
SLASH_TICKET1 = "/gm"

----------------------------------------------------------------------------------------
-- Align by Akeru @wowinterface
----------------------------------------------------------------------------------------

local grid
local boxSize = 32

local function createGrid()
    grid = CreateFrame('Frame', nil, UIParent) 
    grid:SetAllPoints(UIParent)

    grid.boxSize = boxSize 

    local size = 2 
    local width = GetScreenWidth()
    local ratio = width / GetScreenHeight()
    local height = GetScreenHeight() * ratio

    local wStep = width / boxSize
    local hStep = height / boxSize

    for i = 0, boxSize do 
        local tx = grid:CreateTexture(nil, 'BACKGROUND') 
        if i == boxSize / 2 then 
            tx:SetColorTexture(1, 0, 0, .5) 
        else 
            tx:SetColorTexture(0, 0, 0, .5) 
        end 
        tx:SetPoint("TOPLEFT", grid, "TOPLEFT", i*wStep - (size/2), 0) 
        tx:SetPoint('BOTTOMRIGHT', grid, 'BOTTOMLEFT', i*wStep + (size/2), 0) 
    end 

    height = GetScreenHeight()
    
    do
        local tx = grid:CreateTexture(nil, 'BACKGROUND') 
        tx:SetColorTexture(1, 0, 0, .5)
        tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height/2) + (size/2))
        tx:SetPoint('BOTTOMRIGHT', grid, 'TOPRIGHT', 0, -(height/2 + size/2))
    end

    for i = 1, math.floor((height/2)/hStep) do
        local tx = grid:CreateTexture(nil, 'BACKGROUND') 
        tx:SetColorTexture(0, 0, 0, .5)
        
        tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height/2+i*hStep) + (size/2))
        tx:SetPoint('BOTTOMRIGHT', grid, 'TOPRIGHT', 0, -(height/2+i*hStep + size/2))
        
        tx = grid:CreateTexture(nil, 'BACKGROUND') 
        tx:SetColorTexture(0, 0, 0, .5)
        
        tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height/2-i*hStep) + (size/2))
        tx:SetPoint('BOTTOMRIGHT', grid, 'TOPRIGHT', 0, -(height/2-i*hStep + size/2))		
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
        if boxSize > 256 then boxSize = 256 end    
        showGrid()
        isAligning = true
    end
end

----------------------------------------------------------------------------------------
--  Command to show frame you currently have mouseovered
----------------------------------------------------------------------------------------
SlashCmdList["FRAME"] = function(arg)
    if arg ~= "" then
        arg = _G[arg]
    else
        arg = GetMouseFoci()[1]
    end
    if arg ~= nil then _G.FRAME = arg end
    if arg ~= nil and not arg:IsForbidden() then
        local point, relativeTo, relativePoint, xOfs, yOfs = arg:GetPoint()
        ChatFrame1:AddMessage("|cffCC0000~~~~~~~~~~~~~~~~~~~~~~~~~")
        ChatFrame1:AddMessage("Name: |cffFFD100"..(arg:GetName() or "<unamed>"))
        if arg:GetParent() and arg:GetParent():GetName() then
            ChatFrame1:AddMessage("Parent: |cffFFD100"..arg:GetParent():GetName())
        end

        ChatFrame1:AddMessage("Width: |cffFFD100"..format("%.2f", arg:GetWidth()))
        ChatFrame1:AddMessage("Height: |cffFFD100"..format("%.2f", arg:GetHeight()))
        ChatFrame1:AddMessage("Scale: |cffFFD100"..arg:GetScale())
        ChatFrame1:AddMessage("Strata: |cffFFD100"..arg:GetFrameStrata())
        ChatFrame1:AddMessage("Level: |cffFFD100"..arg:GetFrameLevel())
        ChatFrame1:AddMessage("Visibility: |cffFFD100"..(arg:IsShown() and "True" or "False"))

        if relativeTo and relativeTo:GetName() then
            ChatFrame1:AddMessage("Point: |cffFFD100"..point.."|r anchored to "..relativeTo:GetName().."'s |cffFFD100"..relativePoint)
        end
        if xOfs then
            ChatFrame1:AddMessage("X: |cffFFD100"..format("%.2f", xOfs))
        end
        if yOfs then
            ChatFrame1:AddMessage("Y: |cffFFD100"..format("%.2f", yOfs))
        end
        ChatFrame1:AddMessage("|cffCC0000~~~~~~~~~~~~~~~~~~~~~~~~~")
    elseif arg == nil then
        ChatFrame1:AddMessage("Invalid frame name")
    else
        ChatFrame1:AddMessage("Could not find frame info")
    end
end
SLASH_FRAME1 = "/frame"
