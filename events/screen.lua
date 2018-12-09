local screens = require("screens")
local capi =
{
    screen = screen,
}

local screen = {}

function screen.init()
    capi.screen.connect_signal("property::geometry", screen.propertyGeometry)
    capi.screen.connect_signal("added", screen.added)
end

function screen.propertyGeometry(screen)
    screens.setWallpaper(screen)
end

function screen.added(screen)
    screens.setup(screen)
end

return screen
