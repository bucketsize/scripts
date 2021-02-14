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
import XMonad.Hooks.SetWMName

import XMonad.Layout.ResizableTile
import XMonad.Layout.Grid
import XMonad.Layout.TwoPane
import XMonad.Layout.NoBorders
import XMonad.Layout.WindowNavigation

import Control.Exception
import Control.Monad
import Data.Monoid
import System.IO
import System.Exit
import Text.Printf

import DBus.Notify

import qualified XMonad.StackSet as W
import qualified Data.Map as M

notifySend summary body = do
  client <- connectSession
  let hello = blankNote {summary=summary
    ,body=(Just $ Text body)
    ,appImage=(Just $ Icon "dialog-information")
    }
  notification <- notify client hello
  return 0

-- commands
-- pulseaudio
vol_up      = "pactl set-sink-volume @DEFAULT_SINK@ +10%"
vol_down    = "pactl set-sink-volume @DEFAULT_SINK@ -10%"
vol_mute    = "pactl set-sink-mute @DEFAULT_SINK@ toggle"
vol_unmute  = "pactl set-sink-mute @DEFAULT_SINK@ toggle"

-- i3 lock
scr_lock    = "sh ~/scripts/xdg/x.lock-i3.sh"

-- imagemagik
scr_cap     = "import -window root ~/Pictures/$(date +%Y%m%dT%H%M%S).png"
scr_cap_sel = "import ~/Pictures/$(date +%Y%m%dT%H%M%S).png"

kb_led_on   = "xset led on"
kb_led_off  = "xset led off"

monitor00 = Monitor { output="DisplayPort-0", mode="1280x720", position= "0x0" }
monitor01 = Monitor { output="HDMI-A-0", mode="1280x720", position= "1280x0"  }

autostarts =
  [("video", monitorUp monitor00 ++ " --primary; " ++ monitorDown monitor01)
  ,("compositer", "picom -cb")
  ,("wallpaper", "~/scripts/xdg/x.wallpaper.sh cycle")
  ,("notifyd", "dunst")
  ,("systray", "trayer --edge top --align right --SetDockType false --SetPartialStrut true --expand false --width 10 --transparent true --tint 0x111111 --height 20")
  ,("nmapplet", "nm-applet --sm-disable")
  ,("audio", "~/scripts/sys_ctl/ctl.lua fun pa_set_default")
  ,("autolock", "~/scripts/sys_ctl/ctl.lua cmd autolockd_xautolock")
  ,("sysmon", "~/scripts/sys_mon/daemon.lua")
  ]

main = do
  catch start handleShutdown

start = do
  xmobar <- spawnPipe "xmobar"
  xmonad $ docks desktopConfig
    { terminal          = "st.2"
    , focusFollowsMouse = True
    , borderWidth       = 1
    , modMask           = mod1Mask
    , workspaces        = ["1", "2", "3", "4"]
    -- normalBorderColor = myNormalBorderColor
    -- focusedBorderColor = myFocusedBorderColor
    -- keys = myKeys
    -- mouseBindings = myMouseBindings
    , layoutHook        = oLayoutHook
    , manageHook        = oManageHook
    -- handleEventHook = myEventHook
    , startupHook       = handleStartup
    , logHook           = oLogHook xmobar
    }
      `additionalKeysP` oAddlKeysP

dmenuArgs = ["-l", "10"]

-- https://hackage.haskell.org/package/xmonad-contrib-0.16/docs/XMonad-Util-EZConfig.html#v:mkKeymap
oAddlKeysP =
  [ ("C-]",                    spawn vol_up)
  , ("C-[",                    spawn vol_down)
  , ("C-/",                    spawn vol_mute)
  , ("<XF86AudioRaiseVolume>", spawn vol_up)
  , ("<XF86AudioLowerVolume>", spawn vol_down)
  , ("<XF86AudioMute>",        spawn vol_mute)
  , ("M-q",                    spawn "xmonad --recompile && xmonad --restart")
  , ("M-l",                    spawn scr_lock)
  , ("M4-r",                   spawn "dmenu_run -l 10")
  , ("M4-w",                   gotoMenuArgs dmenuArgs)
  -- , ("M-<KP_Tab>",             goToSelected defaultGSConfig)
  , ("M-<F4>",                 kill)
  , ("<Print>",                spawn scr_cap)
  , ("C-<Print>",              spawn scr_cap_sel)
  , ("C-M-2",                  spawn (monitorUp   monitor01))
  , ("C-M-3",                  spawn (monitorDown monitor01))
  , ("C-M-4",                  spawn kb_led_on)
  , ("C-M-5",                  spawn kb_led_off)
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

oLayoutHook =
      avoidStruts
          $ configurableNavigation (navigateColor "#00aa00")
          $ smartBorders
          $ TwoPane (3/100) (1/2)
          ||| layoutHook desktopConfig

oLogHook statProc =
      dynamicLogWithPP xmobarPP
        { ppOutput = hPutStrLn statProc
        , ppTitle  = xmobarColor "pink" "" . shorten 50
        }

handleShutdown :: AsyncException -> IO ()
handleShutdown e = do
  throw e

handleStartup :: X ()
handleStartup = do
  forM_ autostarts $ \(name, cmd) ->
    (spawn cmd) >> liftIO (print ("started" ++ name))
  liftIO (notifySend "XMonad" "started")
  setWMName "LG3D" -- java compat

data Monitor = Monitor
  { output :: String
  , mode :: String
  , position :: String
  }

data Sound = Sound
  { device :: String
  , level :: Int
  }

monitorUp   m = printf "xrandr --output %s --mode %s --pos %s --rotate normal" (output m) (mode m) (position m)
monitorDown m = printf "xrandr --output %s --off" (output m)

