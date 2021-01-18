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

import qualified XMonad.StackSet as W
import qualified Data.Map as M

handleShutdown :: AsyncException -> IO ()
handleShutdown e = do
  throw e

handleStartup :: X ()
handleStartup = do
  spawn "~/scripts/config/xmonad/autostart.sh"
  setWMName "LG3D"

main = do
  catch start handleShutdown

start = do
  -- handleStartup
  xmproc <- spawnPipe "xmobar"
  xmonad $ docks desktopConfig
    { terminal          = "sakura"
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
  , ("M4-r",                    spawn "dmenu_run -l 10")
  , ("M4-w",                    gotoMenuArgs dmenuArgs)
  , ("M-<KP_Tab>",             goToSelected defaultGSConfig)
  , ("<Print>",                spawn scr_cap)
  , ("C-<Print>",              spawn scr_cap_sel)
  , ("C-M-1",                  spawn dtop_viga)
  , ("C-M-2",                  spawn dtop_hdmi)
  , ("C-M-3",                  spawn dtop_extn)
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
