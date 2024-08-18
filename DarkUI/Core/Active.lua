local E, C, L = select(2, ...):unpack()

-- if not C_AddOns.IsAddOnLoaded("DarkUI_Options") then return end

----------------------------------------------------------------------------------------
--    Loads user settings from DarkUI_Options
----------------------------------------------------------------------------------------

if not SavedOptions then SavedOptions = {} end
if not SavedOptionsPerChar then SavedOptionsPerChar = {} end

local options = SavedOptions.global and SavedOptions or SavedOptionsPerChar

local function mergeOptions(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                mergeOptions(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end

    return t1
end

C = mergeOptions(C, options)

----------------------------------------------------------------------------------------
-- auto adjust actionbars options
----------------------------------------------------------------------------------------
if C.general.liteMode then
    C.actionbar.bars.bar2.button.space = 6.8
    C.actionbar.bars.bar2.button.size = 28
    C.actionbar.bars.bar2.pos = { "BOTTOM", "DarkUI_ActionBar1", "TOP", 0, 24 }

    C.actionbar.bars.bar3.button.space = 6.8
    C.actionbar.bars.bar3.button.size = 28
    C.actionbar.bars.bar3.pos = { "BOTTOM", "DarkUI_ActionBar2", "TOP", 0, 12 }
end

if not C.actionbar.bars.bar3.enable then
    C.actionbar.bars.barpet.pos[2] = C.actionbar.bars.bar2.enable and "DarkUI_ActionBar2" or "DarkUI_ActionBar1"
    C.actionbar.bars.barstance.pos[2] = C.actionbar.bars.bar2.enable and "DarkUI_ActionBar2" or "DarkUI_ActionBar1"
end
