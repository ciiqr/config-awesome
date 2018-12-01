local wibox = require('wibox')
-- A widget which will be added to a wibox within the Awesome Window Manager,
-- it is intended to put visual space between other widgets.

-- Utilities
-- Widget Instance
local spacer = wibox.widget.base.make_widget()

-- Fields
spacer.size = 10

-- Methods
spacer.fit = function(self, width, height)
    -- Square with the minimum size
    local size = self.size
    return size, size
end

spacer.draw = function(self, wibox, cr, width, height)

end

spacer.init = function(self, size)
    self.size = size or self.size
    return self
end

-- Signals

-- Return Created Instance
return spacer
