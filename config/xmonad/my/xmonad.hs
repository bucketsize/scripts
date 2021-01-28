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

import Control.Exception
import Control.Monad
import Data.Monoid
import System.IO
import System.Exit
import Text.Printf

import qualified XMonad.StackSet as W
import qualified Data.Map as M

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

data Monitor = Monitor
  { output :: String
  , mode :: String
  , position :: String
  }

monitor00 = Monitor
  { output = "DisplayPort-0"
  , mode   = "1280x720"
  , position   = "0x0"
  }

monitor01 = Monitor
  { output = "HDMI-A-0"
  , mode   = "1280x720"
  , position   = "1280x0"
  }

monitorUp   m = printf "xrandr --output %s --mode %s --pos %s --rotate normal" (output m) (mode m) (position m)
monitorDown m = printf "xrandr --output %s --off" (output m)

handleShutdown :: AsyncException -> IO ()
handleShutdown e = do
  throw e

handleStartup :: X ()
handleStartup = do
  spawn "~/scripts/config/xmonad/autostart.sh"
  setWMName "LG3D" -- java compat

main = do
  catch start handleShutdown

start = do
  xmproc <- spawnPipe "xmobar"
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
    , layoutHook        = avoidStruts $ layoutHook desktopConfig
    , manageHook        = oManageHook
    -- handleEventHook = myEventHook
    , startupHook       = handleStartup
    , logHook           = dynamicLogWithPP xmobarPP
        { ppOutput = hPutStrLn xmproc
        , ppTitle  = xmobarColor "green" "" . shorten 50
        }
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
  , ("M-<KP_Tab>",             goToSelected defaultGSConfig)
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

