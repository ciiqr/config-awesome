local awful = require("awful")
local inspect = require("third-party.inspect") -- TODO: luarocks instead?

-- Saves the content to the specified file name OR a default name (Over-Writes existing files)
local function saveFile(content, fileName)
    local file = io.open(fileName or "saveFile.txt", "w")
    file:write(content)
    file:close()
end


--Debugging
function debugString(object, recursion)
    return inspect(object, recursion or 2)
end

function debugEditor(object, recursion, editor)
    return awful.spawn.with_shell("echo \""..debugString(object, recursion).."\" | "..editor)
end

function debugLeaf(object, recursion)
    return debugEditor(object, recursion, "leafpad")
end

function debugSubl(object, recursion)
    return debugEditor(object, recursion, "subl3 -n")
end

function debugFile(object, recursion, file)
    saveFile(inspect(object, recursion or 1), file or "debug.txt")
end

function debugPrint(object, recursion)
    notifySend(debugString(object, recursion))
end
