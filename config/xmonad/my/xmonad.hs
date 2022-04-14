-- TODO
-- 1. read some config from external json/yaml things like 
--      resolution,
--      wallpaper,
--      colors,
--      so you dont have to keep recompiling for silly things
-- 2. build for multiarch, x86_64, aarch64, armhf
-- 3. forget
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

readFileLnsC :: Handle -> [String] -> IO [String]
readFileLnsC h acc = do
  eof <- hIsEOF h
  if eof
    then return acc
    else do
      l <- hGetLine h
      readFileLnsC h (acc ++ [l])

readFileLns :: FilePath -> IO [String]
readFileLns path = do
  h <- openFile path ReadMode
  readFileLnsC h []

splitOn :: Char -> String -> [String]
splitOn c cs =
  let (h, r) = break (== c) cs
   in h :
      case r of
        "" -> []
        _  -> splitOn c (tail r)

getLogger :: FilePath -> IO (String -> IO ())
getLogger path = 
  openFile path WriteMode
  >>= (\h -> return (\s -> hPutStrLn h s))

logger :: IO (String -> IO ())
logger = getLogger "/tmp/xmonad.log"

oconfig1 :: IO [(String, String)]
oconfig1 = readFileLns "~/.xmonad/xmonad.properties"
  >>= (\ls -> do
    log <- logger
    let cs =
          map (\l -> do
            let la = (splitOn '=' l)
            (la !! 0, la !! 1)) ls
    return cs) 

oconfig :: IO (M.Map String String)
oconfig = oconfig1 >>= (\ls -> return (M.fromList ls))

data Monitor = Monitor
  { output :: String
  , mode :: String
  , position :: String
  }

data Sound = Sound
  { device :: String
  , level :: Int
  }

oTerminal = "urxvt"

monitorUp   m = printf "xrandr --output %s --mode %s --pos %s --rotate normal" (output m) (mode m) (position (m::Monitor))
monitorDown m = printf "xrandr --output %s --off" (output m)

getMonitor :: String -> IO Monitor
getMonitor label = do
  c <- oconfig
  let d = case (M.lookup label c) of
            Just s  -> s
            Nothing -> "default"
  let m = case (M.lookup (label++"_mode") c) of
            Just s  -> s
            Nothing -> "1280x720"
  let p = case (M.lookup (label++"_position") c) of
            Just s  -> s
            Nothing -> "0x0"
  return Monitor {output = d, mode = m, position = p}

monitor00 = getMonitor "display"
  >>= \m -> return (monitorUp m ++ " --primary")

wallpaper = oconfig
  >>= \c -> return $ "feh --bgscale" ++
    case (M.lookup "wallpaper" c) of 
      Just w -> w
      Nothing-> "~/.wlprs/wallpaper"

configuredAutostarts = 
  [ 
   ("wallpaper", wallpaper)
   , ("display", monitor00)
  ]

autostarts = 
  [("xrdb prefs","xrdb ~/.Xresources")
  ,("dbus session","dbus-launch --sh-syntax --exit-with-session")
  ,("dbus activation","dbus-update-activation-environment --systemd --all")
  ,("compositer", "picom")
  ,("triggerhappy","/usr/sbin/thd --triggers ~/.config/triggerhappy/th.conf --deviceglob /dev/input/event*")
  ,("music player daemon","mpd")
  ,("policykit ui","lxpolkit")
  ,("notification daemon","dunst")
  ,("network applet","connman-gtk --tray")
  ,("vbox integration","VBoxClient --clipboard")
  ,("steam client","flatpak run com.valvesoftware.Steam")
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

oManageHook = composeAll . concat $
    [ [ className =? c               --> doFloat | c <- cFloats ]
    , [ title     =? t               --> doFloat | t <- tFloats ]]
  where cFloats = [ "Gimp", "Pidgin", "ROX-Filer", "Dunst", "Conky"
                  , "Pavucontrol", "Steam", "Mpv", "arandr", "Gvim"]
        tFloats = [ "Firefox Preferences", "Downloads", "Add-ons"
                  , "Rename", "Create" ]

oLayoutHook = avoidStruts
          $ smartBorders
          $ spacing 4 
          $ simpleFloat 
          ||| Tall 1 (3/100) (1/2) 
          ||| Full
          ||| layoutHook desktopConfig

oLogHook statProc = dynamicLogWithPP xmobarPP
        { ppOutput = hPutStrLn statProc
        , ppTitle  = xmobarColor "pink" "" . shorten 50
        }


oStartupHook :: X ()
oStartupHook = do
  log <- (liftIO logger)
  liftIO (forM_ autostarts $ \(name, cmd) -> do
    log ("Xmonad::autostart " ++ name ++ " -> " ++ cmd)
    spawn cmd)
  liftIO (forM_ configuredAutostarts $ \(name, mcmd) -> do
    cmd <- mcmd
    log ("Xmonad::autostart " ++ name ++ " -> " ++ cmd) 
    spawn cmd) 


start = do
  xmobar <- spawnPipe "xmobar"
  xmonad $ ewmh $ desktopConfig
    { terminal              = oTerminal 
      , focusFollowsMouse   = False
      , borderWidth         = 4
      , modMask             = mod1Mask
      , workspaces          = ["1", "2", "3", "4"]
      -- normalBorderColor  = myNormalBorderColor
      -- focusedBorderColor = myFocusedBorderColor
      ,keys                 = oKeys
      -- , mouseBindings    = oMouseBindings
      , layoutHook          = oLayoutHook
      , manageHook          = oManageHook
      -- handleEventHook    = myEventHook
      , startupHook         = oStartupHook
      , logHook             = oLogHook xmobar  >>  historyHook
    }

main = start

