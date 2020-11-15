local _, ns = ...
local addon = {}

-- Global saved settings
MagnetButtons_Global = { };
MagnetButtons_Global.HideBars = { };
MagnetButtons_Global.FadeBlizzardUI = false;

-- Saved button data
MagnetButtons_ButtonData = { };			-- old
MagnetButtons_GlobalButtonData = { }; 	-- new

-- Global debug setting
BINDING_HEADER_MAGNETBUTTONS = "Magnet Buttons";
BINDING_NAME_MAGBUTTON_CREATE = "Create a new magnetic button";

addon.MaxFrameIndex = 0;
addon.IsInVehicle = false;
addon.clicks = { "LeftButton", "RightButton", "MiddleButton", "Button4", "Button5" };

ns.MagnetButtons = addon

_G["MagnetButtons"] = addon