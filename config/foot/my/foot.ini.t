# -*- conf -*-

font={font_monospace}:size={font_monospace_size}
# font-bold=<bold variant of regular font>
# font-italic=<italic variant of regular font>
# font-bold-italic=<bold+italic variant of regular font>
# dpi-aware=yes
# initial-window-size-pixels=700x500  # Or,
initial-window-size-chars=96x24
# initial-window-mode=windowed
pad=2x2
# shell=$SHELL (if set, otherwise user's default shell from /etc/passwd)
# term=foot (or xterm-256color if built with -Dterminfo=disabled)
# login-shell=no
# workers=<number of logical CPUs>
# bold-text-in-bright=no
# bell=none
# word-delimiters=,│`|:"'()[]{}<>
notify=notify-send -a foot -i foot ${title} ${body}
selection-target=primary

[scrollback]
lines=2048
# multiplier=3.0
# indicator-position=relative
# indicator-format=

[cursor]
# style=block
# color=111111 dcdccc
# blink=no

[mouse]
# hide-when-typing=no
# alternate-scroll-mode=yes

[colors]
alpha=0.96
# foreground=dcdccc
background=000000
# regular0=222222  # black
# regular1=cc9393  # red
# regular2=7f9f7f  # green
# regular3=d0bf8f  # yellow
# regular4=6ca0a3  # blue
# regular5=dc8cc3  # magenta
# regular6=93e0e3  # cyan
# regular7=dcdccc  # white
# bright0=666666   # bright black
# bright1=dca3a3   # bright red
# bright2=bfebbf   # bright green
# bright3=f0dfaf   # bright yellow
# bright4=8cd0d3   # bright blue
# bright5=fcace3   # bright magenta
# bright6=b3ffff   # bright cyan
# bright7=ffffff   # bright white
# selection-foreground=<inverse foreground/background>
# selection-background=<inverse foreground/background>

[csd]
# preferred=server
# size=26
# color=<foreground color>
# button-width=26
# button-minimize-color=ff0000ff
# button-maximize-color=ff00ff00
# button-close-color=ffff0000

[key-bindings]
# scrollback-up-page=Shift+Page_Up
# scrollback-up-half-page=none
# scrollback-up-line=none
# scrollback-down-page=Shift+Page_Down
# scrollback-down-half-page=none
# scrollback-down-line=none
# clipboard-copy=Control+Shift+C
# clipboard-paste=Control+Shift+V
# primary-paste=Shift+Insert
# search-start=Control+Shift+R
# font-increase=Control+plus Control+equal Control+KP_Add
# font-decrease=Control+minus Control+KP_Subtract
# font-reset=Control+0 Control+KP_0
# spawn-terminal=Control+Shift+N
# minimize=none
# maximize=none
# fullscreen=none
# pipe-visible=[sh -c "xurls | bemenu | xargs -r firefox"] none
# pipe-scrollback=[sh -c "xurls | bemenu | xargs -r firefox"] none
# pipe-selected=[xargs -r firefox] none

[search-bindings]
# cancel=Control+g Escape
# commit=Return
# find-prev=Control+r
# find-next=Control+s
# cursor-left=Left Control+b
# cursor-left-word=Control+Left Mod1+b
# cursor-right=Right Control+f
# cursor-right-word=Control+Right Mod1+f
# cursor-home=Home Control+a
# cursor-end=End Control+e
# delete-prev=BackSpace
# delete-prev-word=Mod1+BackSpace Control+BackSpace
# delete-next=Delete
# delete-next-word=Mod1+d Control+Delete
# extend-to-word-boundary=Control+w
# extend-to-next-whitespace=Control+Shift+W
# clipboard-paste=Control+v Control+y
primary-paste=Shift+Insert

[mouse-bindings]
# primary-paste=BTN_MIDDLE
# select-begin=BTN_LEFT
# select-begin-block=Control+BTN_LEFT
# select-extend=BTN_RIGHT
# select-word=BTN_LEFT-2
# select-word-whitespace=Control+BTN_LEFT-2
# select-row=BTN_LEFT-3