local cta_map = {
	["cpu"] = function()
		return "urxvtc -e sh -c 'less /proc/cpuinfo'" 
	end,
	["mem"] = function()
		return "urxvtc -e sh -c 'less /proc/meminfo'" 
	end,
	["cal"] = function()
		return "urxvtc -e sh -c 'less /proc/meminfo'" 
	end,
	["snd"] = function()
		return "urxvtc -e sh -c 'alsamixer'" 
	end,
}
function conky_cta(item) 
	return cta_map[item]()
end
