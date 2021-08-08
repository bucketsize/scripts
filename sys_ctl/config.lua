return
   {
	  pop_term = 'urxvt -title popeye -geometry 64x16 -e ~/scripts/sys_ctl/control.lua fun',
	  --pop_term = 'termite -t popeye -e ~/scripts/sys_ctl/control.lua fun',

	  displays = {
		 {
			name = 'DisplayPort-0',
			mode = {x=1280,y=720},
			pos = {0,0},
			extra_opts = '--primary'
		 },
		 {
			name = 'HDMI-A-0',
			mode = {x=1280, y=720},
			pos = {1,0},
			extra_opts = '--set underscan on --set "underscan hborder" 48 --set "underscan vborder" 24'
		 }
	  }
   }
