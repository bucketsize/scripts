#!/usr/bin/env python3
from libqtile.command.client import InteractiveCommandClient
from subprocess import Popen, PIPE
from configparser import ConfigParser as config_parser
from ewmh import EWMH
from fuzzywuzzy import fuzz
import os
import sys
from re import findall
from os import path
from io import open

c = InteractiveCommandClient()

def minimize():
    if c.window.info()["minimized"] is False:
        c.window.toggle_minimize()
        c.group.next_window()
    else :
        c.window.toggle_minimize()

def get_wm_class():
    window_class = []
    win = EWMH().getClientList()
    for window in win:
        print(window, window.get_wm_class()[1],
              window.get_wm_name(),
              window.get_wm_icon_name())
        window_class.append(window.get_wm_class()[1].lower())
    return window_class

get_wm_class()

