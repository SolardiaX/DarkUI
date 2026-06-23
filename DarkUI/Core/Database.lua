local _, ns = ...
local E, C, L = ns:unpack()

----------------------------------------------------------------------------------------
-- DB System
----------------------------------------------------------------------------------------

local DB = ns[4]

local overrides = {}

local wipe = wipe
local type, pairs, tonumber = type, pairs, tonumber

local function deepCopy(src)
    if type(src) ~= "table" then return src end
    local copy = {}
    for k, v in pairs(src) do
        copy[k] = deepCopy(v)
    end
    return copy
end

local function mergeInto(target, source)
    for k, v in pairs(source) do
        if type(v) == "table" and type(target[k]) == "table" then
            mergeInto(target[k], v)
        else
            target[k] = v
        end
    end
end

-- Navigate a dot-path ("actionbar.bars.bar1.enable") into a table
-- Returns (parentTable, finalKey) or (nil, nil) if path doesn't exist
local function traverse(tbl, path, create)
    local current = tbl
    local keys = {}
    for k in path:gmatch("([^.]+)") do
        keys[#keys + 1] = tonumber(k) or k
    end

    for i = 1, #keys - 1 do
        local k = keys[i]
        if current[k] == nil then
            if create then
                current[k] = {}
            else
                return nil, nil
            end
        elseif type(current[k]) ~= "table" then
            if create then
                current[k] = {}
            else
                return nil, nil
            end
        end
        current = current[k]
    end

    return current, keys[#keys]
end

-- Remove empty parent tables after a reset
local function cleanEmpty(root, path)
    local keys = {}
    for k in path:gmatch("([^.]+)") do
        keys[#keys + 1] = tonumber(k) or k
    end

    -- Walk from deepest to shallowest
    for depth = #keys - 1, 1, -1 do
        local current = root
        for i = 1, depth - 1 do
            current = current[keys[i]]
            if not current then return end
        end
        local k = keys[depth]
        if type(current[k]) == "table" and next(current[k]) == nil then
            current[k] = nil
        else
            break
        end
    end
end

----------------------------------------------------------------------------------------
-- Public API
----------------------------------------------------------------------------------------

-- Get value from merged config
function DB:Get(path)
    local tbl, key = traverse(C, path, false)
    if tbl then return tbl[key] end
    return nil
end

-- Set override value (if equals current C value after reset, removes the override)
function DB:Set(path, value)
    local curTbl, curKey = traverse(C, path, false)
    local curValue = curTbl and curTbl[curKey]

    -- Store in overrides
    local tbl, key = traverse(overrides, path, true)
    if tbl then tbl[key] = value end

    -- Update C directly
    if curTbl then curTbl[curKey] = value end
end

-- Reset single path to default (remove override)
function DB:Reset(path)
    local tbl, key = traverse(overrides, path, false)
    if tbl and tbl[key] ~= nil then
        tbl[key] = nil
        cleanEmpty(overrides, path)
    end
end

-- Reset a section or everything
function DB:ResetAll(section)
    if section then
        overrides[section] = nil
    else
        wipe(overrides)
    end
end

-- Check if value equals default (no override stored)
function DB:IsDefault(path)
    local tbl, key = traverse(overrides, path, false)
    return not tbl or tbl[key] == nil
end

-- Deep value equality
function DB:ValuesEqual(a, b)
    if type(a) ~= type(b) then return false end
    if type(a) ~= "table" then return a == b end
    for k, v in pairs(a) do
        if not self:ValuesEqual(v, b[k]) then return false end
    end
    for k in pairs(b) do
        if a[k] == nil then return false end
    end
    return true
end

-- Toggle global vs per-character
function DB:SetUseGlobal(useGlobal)
    SavedConfig.useGlobal = useGlobal
    overrides = useGlobal and SavedConfig.global or SavedConfigPerChar.overrides
    self:BuildProxy()
end

function DB:IsGlobal() return SavedConfig and SavedConfig.useGlobal or false end

----------------------------------------------------------------------------------------
-- Stats API (runtime state persistence, not merged into C)
----------------------------------------------------------------------------------------

function DB:GetStats(path, perChar)
    local root = perChar and SavedStatsPerChar or SavedStats
    if not path or path == "" then return root end
    local tbl, key = traverse(root, path, false)
    if tbl then return tbl[key] end
    return nil
end

function DB:SetStats(path, value, perChar)
    local root = perChar and SavedStatsPerChar or SavedStats
    local tbl, key = traverse(root, path, true)
    if tbl then tbl[key] = value end
end

----------------------------------------------------------------------------------------
-- Proxy Builder
----------------------------------------------------------------------------------------

function DB:BuildProxy() mergeInto(C, overrides) end

----------------------------------------------------------------------------------------
-- Initialization
----------------------------------------------------------------------------------------

function DB:Initialize()
    if not SavedConfig then SavedConfig = { version = E.version, useGlobal = true, global = {} } end
    if not SavedConfigPerChar then SavedConfigPerChar = { version = E.version, overrides = {} } end
    if not SavedStats then SavedStats = {} end
    if not SavedStatsPerChar then SavedStatsPerChar = {} end

    -- Version mismatch: full reset (user accepted this design)
    if SavedConfig.version ~= E.version then
        local useGlobal = SavedConfig.useGlobal
        SavedConfig = { version = E.version, useGlobal = useGlobal ~= false, global = {} }
    end
    if SavedConfigPerChar.version ~= E.version then SavedConfigPerChar = { version = E.version, overrides = {} } end

    -- Point to active override source
    overrides = SavedConfig.useGlobal and SavedConfig.global or SavedConfigPerChar.overrides

    -- Apply user overrides onto C (defaults already written by Config/Defaults.lua)
    self:BuildProxy()
end
