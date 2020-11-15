local _, ns = ...
local addon = ns.MagnetButtons

addon.primaryAttributes = {
    "type", "spell", "item", "action", "macro", "macrotext", "checkselfcast", "checkfocuscast",
    "toy", "flyoutDirection", "clickbutton", "unit", "marker", "harmbutton", "helpbutton", "attribute-name",
    "attribute-value", "actionpage", "downbutton", "unit-suffix", "toggleForVehicle", "allowVehicleTarget"
}

addon.allAttributes = {
    "type", "type1", "type2", "type3", "type4", "type5", "tooltip", "texture", "zoneType", "checkselfcast", "checkfocuscast",
    "spell", "spell1", "spell2", "spell3", "spell4", "spell5", "macro", "macro1", "macro2", "macro3", "macro4", "macro5",
    "macrotext", "macrotext1", "macrotext2", "macrotext3", "macrotext4", "macrotext5",
    "hotkey", "hoykey1", "hotkey2", "hotkey3", "hotkey4", "hotkey5",
    "item", "item1", "item2", "item3", "item4", "item5", "toy", "toy1", "toy2", "toy3", "toy4", "toy5",
    "unit", "unit1", "unit2", "unit3", "unit4", "unit5", "marker", "marker1", "marker2", "marker3", "marker4", "marker5",
    "flyout", "flyout1", "flyout2", "flyout3", "flyout4", "flyout5", "action", "action1", "action2", "action3", "action4", "action5",
    "flyoutDirection", "flyoutDirection1", "flyoutDirection2", "flyoutDirection3", "flyoutDirection4", "flyoutDirection5",
    "clickbutton", "clickbutton1", "clickbutton2", "clickbutton3", "clickbutton4", "clickbutton5"
}

local function potentialProperties(startingTable, attr, prefix, suffix)
    if (type(attr) ~= "string") then return startingTable end
    if (prefix) then prefix = "*" else prefix = "" end
    if (suffix) then suffix = "*" else suffix = "" end
    table.insert(startingTable, prefix .. attr .. suffix)
    table.insert(startingTable, prefix .. "alt-" .. attr .. suffix);
    table.insert(startingTable, prefix .. "alt-ctrl-" .. attr .. suffix);
    table.insert(startingTable, prefix .. "alt-shift-" .. attr .. suffix);
    if (prefix ~= "*") then
        table.insert(startingTable, prefix .. "alt-ctrl-shift-" .. attr .. suffix);
    end
    table.insert(startingTable, prefix .. "ctrl-" .. attr .. suffix);
    table.insert(startingTable, prefix .. "ctrl-shift-" .. attr .. suffix);
    table.insert(startingTable, prefix .. "shift-" .. attr .. suffix);
    return startingTable;
end

local function generateAllPossibleAttributes()
    local results = { };
    for attribIndex, attrib in ipairs(addon.primaryAttributes) do
        results = potentialProperties(results, attrib, false, false)
        results = potentialProperties(results, attrib, false, true)
        results = potentialProperties(results, attrib, true, false)
        results = potentialProperties(results, attrib, true, true)
        for idx = 1, 5 do
            results = potentialProperties(results, attrib .. tostring(idx), false, false)
            results = potentialProperties(results, attrib .. tostring(idx), true, false)
        end
    end
    return results;
end

addon.CustomAttributes = generateAllPossibleAttributes();
