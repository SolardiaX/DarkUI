local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Coords
------------------------------------------------------------------------

local module = E:Module("DataText")

local ChatEdit_ActivateChat = ChatEdit_ActivateChat
local ChatEdit_ChooseBoxForSend = ChatEdit_ChooseBoxForSend
local GetZoneText = GetZoneText
local IsShiftKeyDown = IsShiftKeyDown
local format = format

module:Inject("Coords", {
    text = {
        string = function() return module:Coords() end,
    },
    OnClick = function()
        if IsShiftKeyDown() then
            ChatEdit_ActivateChat(ChatEdit_ChooseBoxForSend())
            ChatEdit_ChooseBoxForSend():Insert(format(" (%s: %s)", GetZoneText(), module:Coords()))
        else
            -- Go through the UIPanel system: a bare SetShown bypasses ShowUIPanel
            -- bookkeeping and widens the taint surface of the map's OnShow chain.
            ToggleWorldMap()
        end
    end,
})
