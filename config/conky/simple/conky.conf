--[[
# midified
]]

conky.config = {
	--Various settings
	background = false, 							-- forked to background
	cpu_avg_samples = 2,
	diskio_avg_samples = 5,
	double_buffer = true,
	if_up_strictness = 'address',
	net_avg_samples = 2,
	no_buffers = true,
	temperature_unit = 'celsius',
	text_buffer_size = 2048,
	update_interval = 1,
	imlib_cache_size = 2048,                       --spotify cover
	minimum_width = 80,
	maximum_width = 80,

	--Placement
	alignment = 'bottom_right',
	gap_x = 16,
	gap_y = 8,
	minimum_height = 5,
	minimum_width = 10,

	--Graphical
	border_inner_margin = 1, 					-- margin between border and text
	border_outer_margin = 1, 						-- margin between border and edge of window
	border_width = 1, 									-- border width in pixels
	-- default_bar_width = 32,
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
	stippled_borders = true,

	--Textual
	extra_newline = false,
	format_human_readable = false,
	font = '{font}:size=10',
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

	--Windows
	own_window = true,
	own_window_argb_value = 98,
	own_window_argb_visual = true,
	own_window_class = 'Conky',
	own_window_colour = '#010101',
	own_window_hints = 'undecorated,above', 	-- #options: 'undecorated,below,sticky,skip_taskbar,skip_pager',
	own_window_transparent = no,
	own_window_title = 'system_conky',
	own_window_type = 'normal',										-- #options: normal/override/dock/desktop/panel

	--Colours
	default_color = '#111111',  									-- default color and border color
	color1 = '#FFFFFF',

	--Signal Colours
	color7 = '#1F7411',  --green
	color8 = '#FFA726',  --orange
	color9 = '#F1544B',  --firebrick

};


conky.text = [[
${font {font_monospace}:size=8}${color1}${nodename}/
cpu/
 % ${cpu}
 T ${acpitemp}
mem ${memperc}
bat ${battery_percent}
fs/
    / ${fs_used_perc}
 /tmp ${fs_used_perc /tmp}
$hr
vol ${mixer Spkr}
$hr
net/
 up ${upspeedf eth0}
 dw ${downspeedf eth0}
$hr
top/
 cpu ${top cpu 1}
 |${top name 1}
 io  ${top_io io_perc 1}
 |${top_io name 1}
$hr
${font {font}:bold:size=12}${color1}${alignr}${time %H:%M}
${font {font}:size=9}${color1}${alignr}${time %Y-%m-%d}
]]
