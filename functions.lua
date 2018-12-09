-- Utility
function tableIndexOf(haystack, needle)
    for index, value in ipairs(haystack) do
        if value == needle then
            return index
        end
    end

    return nil
end

function trim(s)
    -- trim string
    -- SOURCE: http://lua-users.org/wiki/StringTrim#trim6
    return s:match'^()%s*$' and '' or s:match'^%s*(.*%S)'
end

function execForOutput(command)
    local file = assert(io.popen(command))
    local output = file:read("*all")

    file:close()
    return output
end

-- Template
function evalTemplate(template, data)
    return template:gsub("{([%w_]+)}", data)
end
function expandUser(path)
    return path:gsub('~', os.getenv('HOME'))
end

-- Naughty
function notifySend(text, timeout, preset)
    local naughty = require("naughty")
    naughty.notify({
        preset = preset or naughty.config.presets.normal,
        text = text,
        screen = "primary",
        timeout = timeout or 0
    })
end

-- Debugging
function debugString(object, recursion)
    local inspect = require("utils.inspect") -- TODO: luarocks instead?
    return inspect(object, recursion or 2)
end

function debugEditor(object, recursion, editor)
    local awful = require("awful")
    return awful.spawn.with_shell("echo \""..debugString(object, recursion).."\" | "..editor)
end

function debugLeaf(object, recursion)
    return debugEditor(object, recursion, "leafpad")
end

function debugSubl(object, recursion)
    return debugEditor(object, recursion, "subl3 -n")
end

function debugFile(object, recursion, file)
    local file = io.open(file or "debug.txt", "w")
    file:write(debugString(object, recursion))
    file:close()
end

function debugPrint(object, recursion)
    notifySend(debugString(object, recursion))
end
