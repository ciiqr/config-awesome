-- Saves the content to the specified file name OR a default name (Over-Writes existing files)
local function saveFile(content, fileName)
    local file = io.open(fileName or "saveFile.txt", "w")
    file:write(content)
    file:close()
end


--Debugging
function debug_string(object, recursion)
    return inspect(object, recursion or 2)
end

function debug_editor(object, recursion, editor)
    return awful.spawn.with_shell("echo \""..debug_string(object, recursion).."\" | "..editor)
end

function debug_leaf(object, recursion)
    return debug_editor(object, recursion, "leafpad")
end

function debug_subl(object, recursion)
    return debug_editor(object, recursion, "subl3 -n")
end

function debug_file(object, recursion, file)
    saveFile(inspect(object, recursion or 1), file or "debug.txt")
end

function debug_print(object, recursion)
    notify_send(debug_string(object, recursion))
end
