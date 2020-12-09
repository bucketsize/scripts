import XMonad
import XMonad.Util.Paste
import XMonad.Util.EZConfig
import XMonad.Util.SpawnOnce
import XMonad.Util.Run(spawnPipe)
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Config.Desktop
import XMonad.Actions.WindowBringer
import XMonad.Actions.GridSelect

import Control.Exception
import Control.Monad
import Data.Monoid
import System.IO
import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map as M

handleShutdown :: AsyncException -> IO ()
handleShutdown e = do
  forM_ oAutostart $ \(s, k) ->
    spawn k
  throw e

handleStartup = do
  forM_ oAutostart $ \(s, k) ->
    putStrLn ("start " ++ s) >> spawn k
  forM_ oAutostart $ \(s, k) ->
    putStrLn ("kill " ++ k)  >> spawn s

main = do
  catch start handleShutdown

start = do
  handleStartup
  xmproc <- spawnPipe "xmobar ~/scripts/config/xmobar/xmobarrc"
  xmonad $ docks desktopConfig
    { terminal          = "sakura"
    , focusFollowsMouse = True
    , borderWidth       = 1
    , modMask           = mod1Mask
    , workspaces        = ["1", "2"]
    -- normalBorderColor = myNormalBorderColor
    -- focusedBorderColor = myFocusedBorderColor
    -- key bindings
    -- keys = myKeys
    -- mouseBindings = myMouseBindings
    -- hooks layouts
    , layoutHook        = avoidStruts $ layoutHook desktopConfig
    , manageHook        = oManageHook
    -- handleEventHook = myEventHook
    -- logHook = myLogHook
    -- , startupHook       = handleStartup
    , logHook           = dynamicLogWithPP xmobarPP
        { ppOutput = hPutStrLn xmproc
        , ppTitle  = xmobarColor "green" "" . shorten 50
        }
    }
      `additionalKeysP` oAddlKeysP
      `additionalKeys`oAddlKeys

dmenuArgs = ["-l", "10"]

oAddlKeysP =
  [ ("C-]",                    spawn vol_up)
  , ("C-[",                    spawn vol_down)
  , ("C-/",                    spawn vol_mute)
  , ("<XF86AudioRaiseVolume>", spawn vol_up)
  , ("<XF86AudioLowerVolume>", spawn vol_down)
  , ("<XF86AudioMute>",        spawn vol_mute)
  , ("M-w",                    goToSelected defaultGSConfig)
  ]

oAddlKeys =
  [ ((0,                        xK_Insert), pasteSelection)
  , ((0,                        xK_Print),  spawn scr_cap)
  , ((controlMask,              xK_Print),  spawn scr_cap_sel)
  , ((mod4Mask,                 xK_r),      spawn "dmenu_run -l 10")
  , ((mod4Mask,                 xK_q),      spawn "xmonad --recompile && xmonad --restart")
  , ((mod4Mask,                 xK_l),      spawn scr_lock)
  , ((mod4Mask,                 xK_w),      gotoMenuArgs dmenuArgs)
  , ((mod4Mask,                 xK_b),      bringMenu)
  , ((controlMask .|. mod1Mask, xK_1),      spawn dtop_viga)
  , ((controlMask .|. mod1Mask, xK_2),      spawn dtop_hdmi)
  , ((controlMask .|. mod1Mask, xK_3),      spawn dtop_extn)
  , ((controlMask .|. mod1Mask, xK_4),      spawn kb_led_on)
  , ((controlMask .|. mod1Mask, xK_5),      spawn kb_led_off)
  ]

oManageHook = composeAll
  [ className =? "MPlayer" --> doFloat
  , className =? "Pidgin" --> doFloat
  , className =? "Conky" --> doFloat
  , className =? "Dunst" --> doFloat
  , className =? "Pavucontrol" --> doFloat
  , className =? "Steam" --> doFloat
  , className =? "Gimp" --> doFloat
  , resource  =? "gpicview" --> doFloat
  , className =? "Mpv" --> doFloat
  , className =? "Nm-connection-editor" --> doFloat
  , className =? "arandr" --> doFloat
  , resource  =? "desktop_window" --> doIgnore
  ]
    <+> manageDocks

-- startup
oAutostart =
  [ ( "trayer --edge top --align right --SetDockType true --SetPartialStrut true --expand true --width 10 --transparent true --tint 0x191970 --height 20;"
    , "killall trayer"
    )
  , ( "nm-applet --sm-disable;"
    , "killall nm-applet"
    )
  , ( "sleep 2; ~/scripts/sys_ctl/ctl.lua fun pa_set_default;"
    , ""
    )
  , ( "sleep 2; ~/scripts/sys_ctl/ctl.lua cmd dtop_viga;"
    , ""
    )
  , ( "sleep 2; dunst;"
    , "killall dunst"
    )
  , ( "sleep 1; light-locker --lock-on-suspend --lock-on-lid;"
    , "killall light-locker"
    )
  , ( "sleep 1; xautolock"
      ++ " -time 3 -locker \"~/scripts/sys_ctl/ctl.lua fun scr_lock_if\""
      ++ " -killtime 10 -killer \"notify-send -u critical -t 10000 -- 'Killing system ...'\""
      ++ " -notify 30 -notifier \"notify-send -u critical -t 10000 -- 'Locking system ETA 30s ...'\";"
    , "killall xautolock"
    )
  , ( "sleep 1; picom -cb;"
    , "killall picom"
    )
  , ( "sleep 2; ~/scripts/sys_mon/daemon.lua;"
    , "pkill -f daemon.lua"
    )
  , ( "sleep 3; ~/scripts/xdg/x.wallpaper.sh cycle;"
    , ""
    )
  ]

-- commands
vol_up      = "pactl set-sink-volume @DEFAULT_SINK@ +10%"
vol_down    = "pactl set-sink-volume @DEFAULT_SINK@ -10%"
vol_mute    = "pactl set-sink-mute @DEFAULT_SINK@ toggle"
vol_unmute  = "pactl set-sink-mute @DEFAULT_SINK@ toggle"

scr_lock    = "light-locker-command --lock"
scr_lock_on = "light-locker --lock-on-suspend --lock-on-lid"

scr_cap     = "import -window root ~/Pictures/$(date +%Y%m%dT%H%M%S).png"
scr_cap_sel = "import ~/Pictures/$(date +%Y%m%dT%H%M%S).png"

kb_led_on   = "xset led on"
kb_led_off  = "xset led off"

pref_mode   = "1280x720"

dtop_viga   = "xrandr"
              ++ " --output DisplayPort-0 --mode 1280x720 --pos 0x0 --rotate normal"
              ++ " --output HDMI-A-0 --off"
              ++ " --output DVI-D-0 --off"
dtop_hdmi   = "xrandr"
              ++ " --output DisplayPort-0 --off"
              ++ " --output HDMI-A-0 --mode 1280x720 --pos 1280x0 --rotate normal"
              ++ " --output DVI-D-0 --off"
dtop_extn   = "xrandr"
              ++ " --output DisplayPort-0 --mode 1280x720 --pos 0x0 --rotate normal --primary"
              ++ " --output HDMI-A-0 --mode 1280x720 --pos 1280x0 --rotate normal"
              ++ " --output DVI-D-0 --off"
