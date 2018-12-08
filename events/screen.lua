local capi =
{
    screen = screen,
}

local screen = {}

function screen.init()
    capi.screen.connect_signal("property::geometry", screen.propertyGeometry)
    capi.screen.connect_signal("added", screen.added)
end

function screen.propertyGeometry(s)
    screenSetWallpaper(s)
end

function screen.added(s)
    screenInit(s)
end

return screen
