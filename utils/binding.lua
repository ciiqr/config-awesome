local akey = require("awful.key")

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

local function mapAction(action, environment)
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

    return function()
        -- call action
        context(unpack(args))
    end
end

local function createBinding(spec, action, environment)
    local parts = mapKeys(extractParts(spec))
    local key = table.remove(parts)

    return akey(parts, key, mapAction(action, environment))
end

function binding.createKeys(keybindings, environment)
    local keys = {}
    for spec, action in pairs(keybindings) do
        table.insert(keys, createBinding(spec, action, environment))
    end
    return keys
end

return binding
