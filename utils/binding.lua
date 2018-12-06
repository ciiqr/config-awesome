local awful = require("awful")
local gears = require("gears")

local binding = {}

local function extractParts(spec)
    -- extract parts from key spec
    local parts = {}
    for part in string.gmatch(spec, "[^%s+]+") do
        table.insert(parts, part)
    end

    -- ensure at least 1 part
    assert(#parts ~= 0, "INVALID_KEY_SPEC: " .. spec)

    return parts
end

local function mapKeys(parts)
    local keyMap = {
        Super = "Mod4",
        Alt = "Mod1",
        -- Ctrl = "Control",
        Enter = "Return",
        PageDown = "Next",
        PageUp = "Prior",
    }

    local modifiers = {}
    for i, part in ipairs(parts) do
        table.insert(modifiers, keyMap[part] or part)
    end

    return modifiers
end

local function extractAction(action)
    -- extract parts from action
    local parts = {}
    for part in string.gmatch(action, "[^.]+") do
        table.insert(parts, part)
    end

    -- ensure at least 1 part
    assert(#parts ~= 0, "EMPTY_ACTION: " .. action)

    return parts
end

local function mapAction(action, environment, keyArgs)
    -- TODO: consider allowing an array style table instead of just a dictionary style table ie.
        -- {action = "command.run", args = {"sleep"}}
        -- {"command.run", "sleep"}
    -- get action details
    local actionName
    local args
    if type(action) == "string" then
        actionName = action
        args = {}
    else
        actionName = action.action
        args = action.args or {}
    end

    -- get action function from environment
    local parts = extractAction(actionName)
    local context = environment
    for i, key in ipairs(parts) do
        context = assert(context[key], "ACTION_NOT_FOUND: " .. actionName)
    end

    return function(...)
        local runtimeArgs = {...}
        -- append key args
        for i, arg in ipairs(keyArgs) do
            table.insert(runtimeArgs, arg);
        end
        -- append user supplied args
        for i, arg in ipairs(args) do
            table.insert(runtimeArgs, arg);
        end

        -- call action
        context(unpack(runtimeArgs))
    end
end

local function evalKeyPattern(key)
    local result = {}

    -- if key matches {%d-%d} ie. {0-9}
    local match = key:match("{(%d+-%d+)}")
    if match then
        -- split match on -
        local parts = {}
        for part in string.gmatch(match, "[^-]+") do
            table.insert(parts, part)
        end
        assert(#parts == 2, "KEY_PATTERN_IMPOSSIBLE: ")

        -- create keys for range
        for i = parts[1], parts[2] do
            local keyCode = i + 9
            table.insert(result, {
                key = "#"..keyCode,
                args = {i},
            })
        end
    else
        -- create normal key
        table.insert(result, {
            key = key,
            args = {},
        })
    end

    return result
end

local function createBinding(spec, action, environment)
    local parts = mapKeys(extractParts(spec))
    local keyPattern = table.remove(parts)
    local keys = evalKeyPattern(keyPattern)

    local awfulKeys = {}
    for i,key in ipairs(keys) do
        local iKeys = awful.key(parts, key.key, mapAction(action, environment, key.args))
        awfulKeys = gears.table.join(awfulKeys, iKeys)
    end
    return awfulKeys
end

function binding.createKeys(keybindings, environment)
    local keys = {}
    for spec, action in pairs(keybindings) do
        table.insert(keys, createBinding(spec, action, environment))
    end
    return keys
end

return binding
