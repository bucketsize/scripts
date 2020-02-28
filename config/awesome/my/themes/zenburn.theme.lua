-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

local gears = require("gears")
local base_theme = dofile(gears.filesystem.get_themes_dir() .. "zenburn/theme.lua")
local theme                                     = {}
theme.font                                      = "DejaVu Sans 10"
theme.font_mono                                 = "DejaVu Sans Mono 10"
theme.wallpaper 																= "/home/jb/Pictures/IMG_20200128_213854.jpg"
theme.tasklist_disable_task_name								= false
return gears.table.join(base_theme, theme)
