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


