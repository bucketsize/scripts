local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")

local Wiman = {}
function Wiman:setup(ctx)
	self.ctx = ctx
	return self
end
function Wiman:apply()
	awful.screen.connect_for_each_screen(function(s)
		self:apply_in_screen(s)
	end)
end
function Wiman:toggle()
	if self.tasklist_popup.visible then
		self.tasklist_popup.visible = false
	else
		self.tasklist_popup.visible = true
	end
end
function Wiman:apply_in_screen(s)
	self.tasklist_popup = awful.popup {
    widget = awful.widget.tasklist {
        screen   = s,
        filter   = awful.widget.tasklist.filter.allscreen,
        buttons  = tasklist_buttons,
        style    = {
            shape = gears.shape.rounded_rect,
        },
        layout   = {
            spacing = 5,
            forced_num_rows = 2,
            layout = wibox.layout.grid.horizontal
        },
        widget_template = {
            {
                {
                    id     = 'clienticon',
                    widget = awful.widget.clienticon,
                },
                margins = 4,
                widget  = wibox.container.margin,
            },
            id              = 'background_role',
            forced_width    = 48,
            forced_height   = 48,
            widget          = wibox.container.background,
            create_callback = function(self, c, index, objects) --luacheck: no unused
                self:get_children_by_id('clienticon')[1].client = c
            end,
        },
    },
    border_color = '#777777',
    border_width = 2,
    ontop        = true,
    placement    = awful.placement.centered,
    shape        = gears.shape.rounded_rect
}
end

TASKLIST_POPUP = Wiman
Wiman:setup({})
Wiman:apply()
return Wiman
