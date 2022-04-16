{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE DisambiguateRecordFields #-}

-- TODO
-- 1. build for multiarch, x86_64, aarch64, armhf

import Control.Exception
import Control.Monad (liftM, forM_)
import Data.Monoid
import Data.Ratio -- this makes the '%' operator available (optional)
import System.Exit
import System.IO
import Text.Printf
import XMonad
import XMonad.Actions.CycleWS
import XMonad.Actions.DwmPromote
import XMonad.Actions.FloatKeys
import XMonad.Actions.GridSelect
import XMonad.Actions.GroupNavigation
import XMonad.Actions.UpdatePointer
import XMonad.Actions.Warp
import XMonad.Actions.WindowBringer
import XMonad.Config.Desktop
import XMonad.Core
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.Grid
import XMonad.Layout.Magnifier
import XMonad.Layout.NoBorders
import XMonad.Layout.ResizableTile
import XMonad.Layout.SimpleFloat
import XMonad.Layout.Spacing
import XMonad.Layout.Spiral
import XMonad.Layout.TabBarDecoration
import XMonad.Layout.Tabbed
import XMonad.Layout.TwoPane
import XMonad.Layout.WindowNavigation
import XMonad.Prompt
import XMonad.Prompt.ConfirmPrompt
import XMonad.Prompt.Shell
import XMonad.Util.EZConfig
import XMonad.Util.Paste
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.SpawnOnce
import XMonad.Util.WorkspaceCompare
import qualified Data.Map        as M
import qualified XMonad.StackSet as W

oTerminal = "urxvt"
oMxctl fu = "~/.luarocks/bin/mxctl.control fun " ++ fu

autostarts :: [(String, String)]
autostarts =
  [
      ("dbus session","dbus-launch --sh-syntax --exit-with-session")
    , ("dbus activation","dbus-update-activation-environment --systemd --all")
    , ("triggerhappy","/usr/sbin/thd --triggers ~/.config/triggerhappy/th.conf --deviceglob /dev/input/event*")
    , ("music player daemon","mpd")
    , ("video", "sleep 5 && " ++ oMxctl "setup_video")
    , ("xrdb prefs","xrdb ~/.Xresources")
    , ("compositer", "picom")
    , ("wallpaper",  oMxctl "applywallpaper")
    , ("policykit ui","lxpolkit")
    , ("notification daemon","dunst")
    , ("network applet","connman-gtk --tray")
    , ("vbox integration","VBoxClient --clipboard")
    , ("steam client","flatpak run com.valvesoftware.Steam")
  ]

oKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
  [
    -- Restart after compile
    ((modm .|. controlMask, xK_r),      spawn "xmonad --recompile && xmonad --restart")

    -- Quit xmonad
    , ((modm .|. controlMask, xK_q), io (exitWith ExitSuccess))

    , ((modm, xK_Return),        spawn oTerminal)
    , ((modm, xK_l),        spawn "slock")
    , ((mod4Mask, xK_r),       spawn "dmenu_run -l 10")
    , ((mod4Mask, xK_w),       gotoMenuArgs ["-l", "10"])

    -- window seitcher alt-tab style
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

    , ((modm .|. controlMask, xK_l),withFocused (keysResizeWindow (-20,-20) (1%2,1%2)))
    , ((modm .|. controlMask, xK_h),withFocused (keysResizeWindow ( 20, 20) (1%2,1%2)))
    , ((modm .|. controlMask, xK_Right),withFocused (keysResizeWindow (-20,-20) (1%2,1%2)))
    , ((modm .|. controlMask, xK_Left),withFocused (keysResizeWindow ( 20, 20) (1%2,1%2)))

    , ((modm .|. shiftMask, xK_l),withFocused (keysMoveWindow ( 20,0))) -- right
    , ((modm .|. shiftMask, xK_h),withFocused (keysMoveWindow (-20,0))) -- left
    , ((modm .|. shiftMask, xK_j),withFocused (keysMoveWindow (0,-20))) -- up
    , ((modm .|. shiftMask, xK_k),withFocused (keysMoveWindow (0, 20))) -- down
    , ((modm .|. shiftMask, xK_Right),withFocused (keysMoveWindow ( 20,0))) -- right
    , ((modm .|. shiftMask, xK_Left),withFocused (keysMoveWindow (-20,0))) -- left
    , ((modm .|. shiftMask, xK_Up),withFocused (keysMoveWindow (0,-20))) -- up
    , ((modm .|. shiftMask, xK_Down),withFocused (keysMoveWindow (0, 20))) -- down
  ]

oManageHook = composeAll
    [   className =? "Dunst"          --> doFloat
      , className =? "Tint2"          --> doFloat
      , className =? "Conky"          --> doFloat
      , className =? "Mpv"          --> doFloat
      , className =? "Arandr"          --> doFloat
      , className =? "Pavucontrol"          --> doFloat
      , className =? "Pavucontrol-qt"          --> doFloat
      , className =? "Steam"          --> doFloat
      , className =? "Popeye"          --> doFloat
      
      , title =? "Firefox Preferences"          --> doFloat
      , title =? "Downloads"          --> doFloat
      , title =? "Add-ons"          --> doFloat
      , title =? "Rename"          --> doFloat
      , title =? "Create"          --> doFloat
      , title =? "mxctl.control"          --> doFloat
    ]

oLayoutHook = avoidStruts
          $ smartBorders
          $ spacing 4
          $ simpleFloat
          ||| Tall 1 (3/100) (1/2)
          ||| Full
          ||| layoutHook desktopConfig

oLogHook statProc = dynamicLogWithPP xmobarPP
        { ppOutput = hPutStrLn statProc
        , ppTitle  = xmobarColor "pink" "" . shorten 32
        }

getLogger :: FilePath -> IO (String -> IO ())
getLogger path =
  openFile path WriteMode
  >>= (\h -> return (\s -> hPutStrLn h s))

logger :: IO (String -> IO ())
logger = getLogger "/tmp/xmonad.log"

__oStartupHook :: IO ()
__oStartupHook = do
  log <- logger
  forM_ autostarts $ \(name, cmd) -> do
    log ("Xmonad::autostart " ++ name ++ " -> " ++ cmd)
    spawn cmd

oStartupHook = liftIO __oStartupHook

start = do
  xmobar <- spawnPipe "xmobar"
  xmonad $ ewmh $ desktopConfig
    { terminal              = oTerminal
      , focusFollowsMouse   = False
      , borderWidth         = 2
      , modMask             = mod1Mask
      , workspaces          = ["1", "2", "3", "4"]
      , normalBorderColor   = "grey" 
      , focusedBorderColor  = "orange"
      ,keys                 = oKeys
      -- , mouseBindings    = oMouseBindings
      , layoutHook          = oLayoutHook
      , manageHook          = manageDocks 
                              <+> oManageHook
                              <+> manageHook def
      -- handleEventHook    = myEventHook
      , startupHook         = oStartupHook
      , logHook             = oLogHook xmobar  >>  historyHook
    }

main = start

