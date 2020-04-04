local awful = require('awful')
local items = {
	'picom',
	'~/scripts/xdg/x.wallpaper.sh',
  '~/scripts/xdg/sys.mond.lua',
	'xautolock'
		.. ' -time 5 -locker "awesome-client \'_G.LOCKSCREEN:on()\'"'
		.. ' -killtime 10 -killer "feh"'
		.. ' -notify 30 -notifier "notify-send -u critical -t 10000 -- \'Lock activated ETA 30s\'"',
	'xrdb ~/.Xresources',
	'lxsession',
}

local Autostart = {}
function Autostart:setup(ctx)
end
function Autostart:apply()
	for i,cmd in pairs(items) do
		local spk = string.format("pkill -f %s", cmd)
		local spx = string.format("%s &", cmd)
		print('>>> stopping ', spk)
		awful.spawn.easy_async_with_shell(spk, function()
			print('>>> starting ', spx)
			awful.spawn.easy_async_with_shell(spx, function()
				print('>>> done')
			end)
		end)
	end
end
return Autostart
