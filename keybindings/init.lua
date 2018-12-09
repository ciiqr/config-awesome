local keybindings = {}

function keybindings.init()
    -- Global Keys
    root.keys(require("keybindings.global"))
end

return keybindings
