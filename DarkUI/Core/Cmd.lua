local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
--	Core SlashCMD Methods
----------------------------------------------------------------------------------------

--[[ GM Tickets don't hide my buffs! ]]
TicketStatusFrame:SetFrameStrata('BACKGROUND') 

SlashCmdList["RELOADUI"] = function() ReloadUI() end
SLASH_RELOADUI1 = "/rl"

SlashCmdList["RCSLASH"] = function() DoReadyCheck() end
SLASH_RCSLASH1 = "/rc"

SlashCmdList["TICKET"] = function() ToggleHelpFrame() end
SLASH_TICKET1 = "/gm"

----------------------------------------------------------------------------------------
--  Command to show frame you currently have mouseovered
----------------------------------------------------------------------------------------
SlashCmdList["FRAME"] = function(arg)
    if arg ~= "" then
        arg = _G[arg]
    else
        arg = GetMouseFocus()
    end
    if arg ~= nil then FRAME = arg end
    if arg ~= nil and arg:GetName() ~= nil then
        local point, relativeTo, relativePoint, xOfs, yOfs = arg:GetPoint()
        ChatFrame1:AddMessage("|cffCC0000~~~~~~~~~~~~~~~~~~~~~~~~~")
        ChatFrame1:AddMessage("Name: |cffFFD100"..arg:GetName())
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
