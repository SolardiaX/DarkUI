local E, C, L = select(2, ...):unpack()

if not C.stats or not C.stats.coords or not C.stats.coords.enable then
    return
end

------------------------------------------------------------------------
-- Coords
------------------------------------------------------------------------

local module = E:Module("DataText")

local ChatEdit_ActivateChat = ChatEdit_ActivateChat
local ChatEdit_ChooseBoxForSend = ChatEdit_ChooseBoxForSend
local GetZoneText = GetZoneText
local IsShiftKeyDown = IsShiftKeyDown
local format = format
local WorldMapFrame = WorldMapFrame

module:Inject("Coords", {
    text = {
        string = function()
            return module:Coords()
        end,
    },
    OnClick = function()
        if IsShiftKeyDown() then
            ChatEdit_ActivateChat(ChatEdit_ChooseBoxForSend())
            ChatEdit_ChooseBoxForSend():Insert(format(" (%s: %s)", GetZoneText(), module:Coords()))
        else
            WorldMapFrame:SetShown(not WorldMapFrame:IsShown())
        end
    end,
})
