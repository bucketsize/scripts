{-# LANGUAGE OverloadedStrings #-}

import Data.List (sort)
import DBus
import DBus.Client

main = do
    client <- connectSession
 
    -- Request a list of connected clients from the bus
    -- reply <- call_ client (methodCall "/org/freedesktop/DBus" "org.freedesktop.DBus" "ListNames")
    --     { methodCallDestination = Just "org.freedesktop.DBus"
    --     }
    -- server_lookup = bus.get_object("org.PulseAudio1", "/org/pulseaudio/server_lookup1")
    -- address = server_lookup.Get("org.PulseAudio.ServerLookup1", "Address", dbus_interface="org.freedesktop.DBus.Properties")


    reply <- call_ client (methodCall "/org/pulseaudio/core1" "org.PulseAudio.Core1" "Name")
        { methodCallDestination = Just "org.PulseAudio1"
        }
 
    -- org.freedesktop.DBus.ListNames() returns a single value, which is
    -- a list of names (here represented as [String])
    let Just names = fromVariant (methodReturnBody reply !! 0)
 
    -- Print each name on a line, sorted so reserved names are below
    -- temporary names.
    mapM_ putStrLn (sort names)

readXmConfig :: FilePath -> IO (M.Map String String)
readXmConfig path = do
  log <- logger
  log ("reading config file: "++path)
  s <- readFile path
  let cls =
        map
        (\l ->
          let w = splitOn '=' l in
              (w!!0, w!!1))
        (lines s)
  return (M.fromList cls)

oconfig = readXmConfig "/tmp/xmonad.cfg"

splitOn :: Char -> String -> [String]
splitOn c cs =
  let (h, r) = break (== c) cs
   in h :
      case r of
        "" -> []
        _  -> splitOn c (tail r)


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

configuredAutostarts :: [(String, IO String)]
configuredAutostarts =
  [
   ("wallpaper", wallpaper)
   , ("display", monitor00)
  ]

