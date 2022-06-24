--[[
	status line
]]

conky.config = {
	-- Various settings
	background = false, 							-- forked to background
	cpu_avg_samples = 4,
	diskio_avg_samples = 4,
	double_buffer = true,
	if_up_strictness = 'address',
	net_avg_samples = 4,
	no_buffers = true,
	temperature_unit = 'celsius',
	text_buffer_size = 512,
	update_interval = 1,
	imlib_cache_size = 512,                       --spotify cover
	out_to_console = false,


	--Placement
	alignment = 'tr',
	gap_x = 0,
	gap_y = 2,
	minimum_height = 8,
	minimum_width = 1280,
	maximum_width = 1280,

	--Graphical
	border_inner_margin = 1, 					-- margin between border and text
	border_outer_margin = 1, 						-- margin between border and edge of window
	border_width = 1, 									-- border width in pixels
	default_bar_width = 32,
	default_bar_height = 8,
	default_gauge_height = 40,
	default_gauge_width = 40,
	default_graph_height = 24,
	default_graph_width = 40,
	default_shade_color = '#000000',
	default_outline_color = '#000000',
	draw_borders = false,								--draw borders around text
	draw_graph_borders = true,
	draw_shades = false,
	draw_outline = false,
	stippled_borders = 1,

	--Textual
	extra_newline = false,
	format_human_readable = true,
	max_text_width = 0,
	max_user_text = 16384,
	override_utf8_locale = true,
	short_units = true,
	top_name_width = 16,
	top_name_verbose = false,
	uppercase = false,
	use_spacer = 'none',
	use_xft = true,
	xftalpha = 1,
	pad_percents = 0,

	--Windows
	own_window = true,
	
	-- #options: normal/override/dock/desktop/panel
	own_window_type = 'dock',
	
	-- #options: 'undecorated,below,sticky,skip_taskbar,skip_pager',
	-- no minimize -> override, desktop
	own_window_hints = 'undecorated,above,skip_taskbar',
	
	own_window_colour = '#010101',
	own_window_transparent = false,
	own_window_argb_visual = true,
	own_window_argb_value = 184,
	own_window_title = 'system_conky',
	own_window_class = 'Conky',

	--Colours
	default_color = '#111111',  									-- default color and border color
	color1 = '#FFFFFF',

	--Signal Colours
	color7 = '#1F7411',  --green
	color8 = '#FFA726',  --orange
	color9 = '#F1544B',  --firebrick

	lua_load = "~/scripts/config/conky/line/conky_helper.lua",

};


conky.text = [[
${color1}\
${font {font_conky}:pixelsize={font_conky_size}}\
${time %H:%M:%S %Y-%m-%d}\
${alignr}\
cpu ${cpu}% ${acpitemp}T\
 | mem ${memperc}%\
 | fs ${fs_used_perc}% ${diskio}\
 | net ${upspeedf {net_if}} ${downspeedf {net_if}}\
 | bat ${battery_percent}%\
]]
