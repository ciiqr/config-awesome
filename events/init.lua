local capi =
{
    screen = screen,
    client = client,
}

local events = {}

function events.init()
    -- TODO
    -- Screen Signals
    capi.screen.connect_signal("property::geometry", screenPropertyGeometry)
    capi.screen.connect_signal("added", screenInit)

    -- Client Signals
    capi.client.connect_signal("manage", manageClient)
    capi.client.connect_signal("focus", clientDidFocus)
    capi.client.connect_signal("unfocus", clientDidLoseFocus)
    capi.client.connect_signal("property::floating", clientDidChangeFloating)
    capi.client.connect_signal("mouse::enter", clientDidMouseEnter)
    setupClientRequestActivate()
end

return events
