local E, C, L = select(2, ...):unpack()
if not IsAddOnLoaded("DarkUI_Options") then return end

----------------------------------------------------------------------------------------
--	This Module loads new user settings if DarkUI_Options is loaded
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
