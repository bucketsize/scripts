import XMonad
import XMonad.Util.Paste
import XMonad.Util.EZConfig
import XMonad.Util.SpawnOnce
import XMonad.Util.Run(spawnPipe)
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Config.Desktop
import XMonad.Config.Gnome
import XMonad.Actions.WindowBringer
import XMonad.Actions.GridSelect
import XMonad.Hooks.SetWMName
import XMonad.Hooks.EwmhDesktops
import XMonad.Actions.GroupNavigation
import XMonad.Layout.ResizableTile
import XMonad.Layout.Grid
import XMonad.Layout.TwoPane
import XMonad.Layout.NoBorders
import XMonad.Layout.WindowNavigation
import XMonad.Layout.Spiral
import Data.Ratio -- this makes the '%' operator available (optional)
import XMonad.Layout.Spiral
import XMonad.Layout.Grid
import XMonad.Layout.Spacing
import Control.Exception
import Control.Monad
import Data.Monoid
import System.IO
import System.Exit
import Text.Printf
import qualified XMonad.StackSet as W
import qualified Data.Map as M

-- import DBus.Notify

-- notifySend summary body = do
--   client <- connectSession
--   let hello = blankNote {summary=summary
--     ,body=(Just $ Text body)
--     ,appImage=(Just $ Icon "dialog-information")
--     }
--   notification <- notify client hello
--   return 0

vBoxDisplay = Monitor { output="DisplayPort-0", mode="1280x720", position= "0x0" }
lenovo_eDP1 = Monitor { output="eDP-1", mode="1280x720", position= "0x0" }
pi4Hdmi0 = Monitor { output="HDMI-A-0", mode="1280x720", position= "0x0" }
pi4Hdmi1 = Monitor { output="HDMI-A-1", mode="1280x720", position= "0x0" }

autostarts =
  [("xrdb prefs","xrdb ~/.Xresources")
  ,("dbus session","dbus-launch --sh-syntax --exit-with-session")
  ,("dbus activation","dbus-update-activation-environment --systemd --all")
  ,("video", monitorUp lenovo_eDP1 ++ " --primary")
  ,("wallpaper get", "~/.luarocks/bin/mxctl.control fun getwallpaper")
  ,("wallpaper apply", "~/.luarocks/bin/mxctl.control fun applywallpaper")
  ,("compositer", "picom -cb")
  ,("triggerhappy","/usr/sbin/thd --triggers ~/.config/triggerhappy/th.conf --deviceglob /dev/input/event*")
  ,("music player daemon","mpd")
  ,("policykit ui","lxpolkit")
  ,("notification daemon","dunst")
  ,("network applet","connman-gtk")
  ,("vbox integration","VBoxClient --clipboard")
  ,("steam client","flatpak run com.valvesoftware.Steam")
 ]

main = do
  catch start handleShutdown

start = do
  -- xmobar <- spawnPipe "xmobar"
  xmonad $ ewmh $ docks gnomeConfig
    { terminal          = "qterminal"
      , focusFollowsMouse = True
      , borderWidth       = 4
      , modMask           = mod1Mask
      , workspaces        = ["1", "2", "3", "4"]
      -- normalBorderColor = myNormalBorderColor
      -- focusedBorderColor = myFocusedBorderColor
      -- keys = myKeys
      , mouseBindings = oMouseBindings
      , layoutHook        = oLayoutHook
      , manageHook        = oManageHook
      -- handleEventHook = myEventHook
      , startupHook       = handleStartup
      -- , logHook           = oLogHook xmobar  >>  historyHook
    }
      `additionalKeysP` oAddlKeysP

oMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
    
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modMask, button1), (\w -> focus w >> mouseMoveWindow w))
    
    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, button2), (\w -> focus w >> windows W.swapMaster))
    
    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3), (\w -> focus w >> mouseResizeWindow w))
    
    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

-- https://hackage.haskell.org/package/xmonad-contrib-0.16/docs/XMonad-Util-EZConfig.html#v:mkKeymap
oAddlKeysP =
  [ ("C-M-r",      spawn "xmonad --recompile && xmonad --restart")
    , ("M-l",        spawn "slock")
    , ("M4-r",       spawn "dmenu_run -l 10")
    , ("M4-w",       gotoMenuArgs ["-l", "10"])
    -- , ("M-<KP_Tab>", goToSelected defaultGSConfig)
    -- close focused window 
    , ("M-<F4>",     kill)
    , ("M4-c",  	   kill)
    , ("<Print>",    spawn "import -window root ~/Pictures/$(date +%Y%m%dT%H%M%S).png")
    , ("C-<Print>",  spawn "import ~/Pictures/$(date +%Y%m%dT%H%M%S).png")

    -- Rotate through the available layout algorithms
    , ("M-<Space>", sendMessage NextLayout)
    , ("M-S-<Space>", sendMessage FirstLayout)

    -- Resize viewed windows to the correct size
    , ("M-S-r", refresh)

    -- Move window focus
    , ("M-j", windows W.focusDown)
    , ("M-k", windows W.focusUp  )
    , ("M-<Return>", windows W.focusMaster  )
    
    -- Swap window
    , ("M-S-j", windows W.swapDown >> windows W.focusDown)
    , ("M-S-k", windows W.swapUp >> windows W.focusUp)
    , ("M-S-<Return>", windows W.swapMaster)

    -- Resize the master area
    , ("M-h", sendMessage Shrink)
    , ("M-l", sendMessage Expand)
    , ("M-S-h", sendMessage MirrorShrink)
    , ("M-S-l", sendMessage MirrorExpand)

    -- toggle float/sink
    , ("M-t", withFocused $ windows . W.sink)

    -- Change the number of windows in the master area
    , ("M-,", sendMessage (IncMasterN 1))
    , ("M-.", sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    , ("M-g", sendMessage ToggleStruts)

    -- Quit xmonad
    , ("M-S-q", io (exitWith ExitSuccess))

    -- Restart xmonad
    , ("M-q", restart "xmonad" True)
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
    , className =? "Stardict"        --> doFloat
    , className =? "Smplayer"        --> doFloat
    , className =? "Wicd-client.py"  --> doFloat
    , className =? "Gxmessage"       --> doFloat
    , className =? "Pidgin"          --> doShift "4"
    , className =? "Conkeror"        --> doShift "2"
    , className =? "Emacs"           --> doShift "3"
    , className =? "Shiretoko"       --> doShift "2"
    , className =? "Gvim"            --> doShift "3"
    , resource  =? "desktop_window"  --> doIgnore
    , className =? "stalonetray"     --> doIgnore 
  ]
    <+> manageDocks

oLayoutHook = avoidStruts
          $ configurableNavigation (navigateColor "#00aa00")
          $ smartBorders
          $ spacing 4 
          $ Tall 1 (3/100) (1/2) ||| Grid ||| Full
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

