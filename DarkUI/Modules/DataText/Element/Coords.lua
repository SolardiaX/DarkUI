local E, C, L = select(2, ...):unpack()

if not C.stats.enable or not C.stats.config.Coords.enable then return end

----------------------------------------------------------------------------------------
--    Coords of DataText (modified from ShestakUI)
----------------------------------------------------------------------------------------
local module = E:Module("DataText")

local ChatEdit_ActivateChat = ChatEdit_ActivateChat
local ChatEdit_ChooseBoxForSend = ChatEdit_ChooseBoxForSend
local GetZoneText = GetZoneText
local IsShiftKeyDown = IsShiftKeyDown
local SendChatMessage = SendChatMessage
local ToggleFrame = ToggleFrame
local format = format
local WorldMapFrame = WorldMapFrame

local cfg = C.stats.config.Coords

module:Inject("Coords", {
    text    = { string = function() return module:Coords() end },
    OnClick = function()
        if IsShiftKeyDown() then
            ChatEdit_ActivateChat(ChatEdit_ChooseBoxForSend())
            ChatEdit_ChooseBoxForSend(format(" (%s: %s)", GetZoneText(), module:Coords()))
        else
            ToggleFrame(WorldMapFrame)
        end
    end
})
