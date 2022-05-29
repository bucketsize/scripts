Config { font = "xft:{font_monospace}:size={font_monospace_size}:antialias=false"
       , additionalFonts = []
       , alpha = 127
       , border = TopB
       , borderColor = "black"
       , bgColor = "#111111"
       , fgColor = "grey"
       , position = TopSize L 100 18
       , textOffset = -1
       , iconOffset = -1
       , lowerOnStart = True
       , pickBroadest = False
       , persistent = False
       , hideOnStart = False
       , iconRoot = "."
       , allDesktops = True
       , overrideRedirect = True
       , commands = [ Run StdinReader
	   , Run Weather "VOBL"
			[ "-t"," <tempC>C/<skyCondition>"
			, "-L","64"
			, "-H","77"
			, "--normal","green"
			, "--high","red"
			, "--low","lightblue"] 36000
		--, Run UVMeter "bangalore" ["-H", "3", "-L", "3", "--low", "green", "--high", "red"] 900
		--, Run Network "enp6s0"
		-- [ "-L","0"
		-- , "-H","32",
		-- , "--normal","green"
		-- , "--high","red"
		-- ] 10
		, Run DynNetwork
			[ "--template" , "^<tx> .<rx> kB"
			, "--Low"      , "1000"       -- units: B/s
			, "--High"     , "5000"       -- units: B/s
			, "--low"      , "green"
			, "--normal"   , "yellow"
			, "--high"     , "red"
			] 10
		, Run Cpu ["-t","<total>%","-L","3","-H","50","--normal","green","--high","red"] 10
		, Run Memory ["-t","<usedratio>%"] 10
		, Run Swap ["-t","<usedratio>"] 10
		, Run CoreTemp [ "-t" ,"<core0>C","--Low","50","--High", "70","--low","darkgreen","--normal","darkorange","--high","darkred"] 50
		, Run Battery ["-t","<left>%: <timeleft>","-L","30","-H","60","-h","green","-n","yellow","-l","red"] 10
		, Run Com "uname" ["-s","-r"] "" 36000
		, Run Date "%a %b %_d %Y %H:%M:%S" "date" 10
		]
       , sepChar = "%"
       , alignSep = "}{"
       , template = "%date% } %StdinReader% {Cpu: %cpu% %coretemp% Mem: %memory% Net: %dynnetwork% %battery%"
       }
