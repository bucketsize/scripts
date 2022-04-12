-- TODO
-- 1. read some config from external json/yaml things like 
--      resolution,
--      wallpaper,
--      colors,
--      so you dont have to keep recompiling for silly things
--
-- 2. build for multiarch, x86_64, aarch64, armhf
--
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE DisambiguateRecordFields #-}
import Control.Monad (liftM)
import XMonad
import XMonad.Core
import System.Exit
import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import XMonad.Layout.Tabbed
import XMonad.Layout.ResizableTile
import XMonad.Layout.Grid
import XMonad.Layout.Magnifier
import XMonad.Layout.TabBarDecoration
import XMonad.Hooks.DynamicLog hiding (shorten)
import XMonad.Actions.CycleWS
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.EwmhDesktops
import XMonad.Actions.DwmPromote
import XMonad.Actions.UpdatePointer
import XMonad.Hooks.UrgencyHook
import XMonad.Util.Run (spawnPipe)
import System.IO 
import XMonad.Prompt
import XMonad.Prompt.Shell
import XMonad.Util.WorkspaceCompare
import XMonad.Util.EZConfig
import XMonad.Actions.Warp
import Data.Ratio
import Control.Monad (liftM, forM_)
import XMonad
import XMonad.Core
import System.Exit
import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import XMonad.Layout.Tabbed
import XMonad.Layout.ResizableTile
import XMonad.Layout.Grid
import XMonad.Layout.Spiral
import XMonad.Layout.Magnifier
import XMonad.Layout.TabBarDecoration
import XMonad.Layout.TwoPane
import XMonad.Layout.NoBorders
import XMonad.Layout.WindowNavigation
import XMonad.Layout.Spacing
import XMonad.Layout.SimpleFloat
import XMonad.Config.Desktop
import XMonad.Config.Gnome
import XMonad.Hooks.DynamicLog hiding (shorten)
import XMonad.Actions.CycleWS
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.EwmhDesktops
import XMonad.Actions.DwmPromote
import XMonad.Actions.UpdatePointer
import XMonad.Hooks.UrgencyHook
import XMonad.Util.Run (spawnPipe)
import System.IO 
import XMonad.Prompt
import XMonad.Prompt.Shell
import XMonad.Prompt.ConfirmPrompt
import XMonad.Util.WorkspaceCompare
import XMonad.Actions.Warp
import Data.Ratio
import XMonad.Util.Paste
import XMonad.Util.EZConfig
import XMonad.Util.SpawnOnce
import XMonad.Hooks.DynamicLog
import XMonad.Actions.WindowBringer
import XMonad.Actions.GridSelect
import XMonad.Hooks.SetWMName
import XMonad.Hooks.EwmhDesktops
import XMonad.Actions.GroupNavigation
import XMonad.Actions.FloatKeys
import XMonad.Config.Desktop
import Data.Ratio -- this makes the '%' operator available (optional)
import Control.Exception
import Data.Monoid
import System.IO
import System.Exit
import Text.Printf

-- import DBus.Notify

-- notifySend summary body = do
--   client <- connectSession
--   let hello = blankNote {summary=summary
--     ,body=(Just $ Text body)
--     ,appImage=(Just $ Icon "dialog-information")
--     }
--   notification <- notify client hello
--   return 0

data Monitor = Monitor
  { output :: String
  , mode :: String
  , position :: String
  }

data Sound = Sound
  { device :: String
  , level :: Int
  }

monitorUp   m = printf "xrandr --output %s --mode %s --pos %s --rotate normal" (output m) (mode m) (position (m::Monitor))
monitorDown m = printf "xrandr --output %s --off" (output m)
vBoxDisplay = Monitor { output="DisplayPort-0", mode="1280x720", position="0x0"}
lenovo_eDP1 = Monitor { output="eDP-1", mode="1280x720", position="0x0"}
pi4Hdmi0 = Monitor { output="HDMI-A-0", mode="1280x720", position="0x0"}
pi4Hdmi1 = Monitor { output="HDMI-A-1", mode="1280x720", position="0x0"}

monitor00=monitorUp lenovo_eDP1 ++ " --primary"

autostarts = 
  [("xrdb prefs","xrdb ~/.Xresources")
  ,("dbus session","dbus-launch --sh-syntax --exit-with-session")
  ,("dbus activation","dbus-update-activation-environment --systemd --all")
  ,("video", monitor00)
  ,("wallpaper get", "~/.luarocks/bin/mxctl.control fun getwallpaper")
  ,("wallpaper apply", "~/.luarocks/bin/mxctl.control fun applywallpaper")
  ,("compositer", "picom -cb")
  ,("triggerhappy","/usr/sbin/thd --triggers ~/.config/triggerhappy/th.conf --deviceglob /dev/input/event*")
  ,("music player daemon","mpd")
  ,("policykit ui","lxpolkit")
  ,("notification daemon","dunst")
  ,("network applet","connman-gtk --tray")
  ,("vbox integration","VBoxClient --clipboard")
  ,("steam client","flatpak run com.valvesoftware.Steam")
 ]

main = do
  catch start handleShutdown

start = do
  xmobar <- spawnPipe "xmobar"
  xmonad $ ewmh $ desktopConfig
    { terminal          = "qterminal"
      , focusFollowsMouse = False
      , borderWidth       = 4
      , modMask           = mod1Mask
      , workspaces        = ["1", "2", "3", "4"]
      -- normalBorderColor = myNormalBorderColor
      -- focusedBorderColor = myFocusedBorderColor
      ,keys = oKeys
      -- , mouseBindings = oMouseBindings
      , layoutHook        = oLayoutHook
      , manageHook        = oManageHook
      -- handleEventHook = myEventHook
      , startupHook       = handleStartup
      , logHook           = oLogHook xmobar  >>  historyHook
    }

oKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
  [ 
    -- Restart after compile
    ((modm .|. controlMask, xK_r),      spawn "xmonad --recompile && xmonad --restart")

    -- Quit xmonad
    , ((modm .|. controlMask, xK_q), io (exitWith ExitSuccess))

    , ((modm, xK_l),        spawn "slock")
    , ((mod4Mask, xK_r),       spawn "dmenu_run -l 10")
    , ((mod4Mask, xK_w),       gotoMenuArgs ["-l", "10"])

    -- window seitcher alt-tab style
    -- , ((modm, xK_Tab), goToSelected defaultGSConfig)
    -- , ((modm, xK_Tab), nextMatch Backward (return True))
    , ((modm, xK_Tab), windows W.focusDown)
    , ((modm .|. shiftMask, xK_Tab), windows W.focusUp)

    -- close focused window 
    , ((modm, xK_F4),kill)
    , ((mod4Mask, xK_c),kill)
    , ((0, xK_Print), spawn "import -window root ~/Pictures/$(date +%Y%m%dT%H%M%S).png")
    , ((controlMask, xK_Print),spawn "import ~/Pictures/$(date +%Y%m%dT%H%M%S).png")

    -- Rotate through the available layout algorithms
    , ((modm, xK_space), sendMessage NextLayout)

    -- Move window focus
    , ((modm, xK_j), windows W.focusDown)
    , ((modm, xK_k), windows W.focusUp  )
    
    -- Resize the master area
    , ((modm ,xK_h), sendMessage Shrink)
    , ((modm ,xK_l), sendMessage Expand)

    -- toggle float/sink
    , ((modm,xK_t), withFocused $ windows . W.sink)

    -- Change the number of windows in the master area
    , ((modm ,xK_comma), sendMessage (IncMasterN 1))
    , ((modm ,xK_period), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    , ((modm ,xK_g), sendMessage ToggleStruts)

    , ((modm .|. controlMask, xK_l),withFocused (keysResizeWindow (-10,-10) (1,1)))
    , ((modm .|. controlMask, xK_h),withFocused (keysResizeWindow (10,10) (1,1)))
    , ((modm .|. shiftMask, xK_l),withFocused (keysMoveWindowTo (512,384) (1%2,1%2)))
  ]

oManageHook = composeAll . concat $
    [ [ className =? c               --> doFloat | c <- cFloats ]
    , [ title     =? t               --> doFloat | t <- tFloats ]]
  where cFloats = [ "Gimp", "Pidgin", "ROX-Filer", "Dunst", "Conky"
                  , "Pavucontrol", "Steam", "Mpv", "arandr", "Gvim"]
        tFloats = [ "Firefox Preferences", "Downloads", "Add-ons"
                  , "Rename", "Create" ]

oLayoutHook = avoidStruts
          $ configurableNavigation (navigateColor "#00aa00")
          $ smartBorders
          $ spacing 4 
          $ simpleFloat 
          ||| Tall 1 (3/100) (1/2) 
          ||| spiral (125 % 146)
          ||| Full
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
  -- liftIO (notifySend "XMonad" "started")
  -- setWMName "LG3D" -- java compat

