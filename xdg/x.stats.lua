#! /usr/bin/env lua

--
-- Sample GTK Hello program
--
-- Based on test from LuiGI code.  Thanks Adrian!
--

local lgi = require 'lgi'
local Gtk = lgi.require('Gtk')

-- Create top level window with some properties and connect its 'destroy'
-- signal to the event loop termination.
local window = Gtk.Window {
   title = 'window',
   default_width = 400,
   default_height = 300,
   on_destroy = Gtk.main_quit
}

if tonumber(Gtk._version) >= 3 then
   window.has_resize_grip = true
end

-- Pack everything into the window.
local vbox = Gtk.VBox()
vbox:pack_start(Gtk.Label { label = 'Contents' }, true, true, 0)
window:add(vbox)

-- Show window and start the loop.
window:show_all()
Gtk.main()
