#!/usr/bin/env python

import os
import sys
import subprocess

dout_file='/tmp/dout_file'
xbri_file='/tmp/xbri_file'

def readf(fn):
    f=open(fn, 'r')
    d=f.read()
    f.close()
    return d.strip()

def writef(fn, d):
    f=open(fn, 'w')
    f.write(d)
    f.close()

if os.path.isfile(dout_file):
    dout=readf(dout_file)
else:
    dout=subprocess.check_output('xrandr | grep "\sconnected" | cut -d" " -f 1', shell=True)
    dout.strip()
    writef(dout_file, dout)
    print("detected output=%s" % dout)

if os.path.isfile(xbri_file):
    xbri=float(readf(xbri_file))
else:
    xbri=0.4
    writef(xbri_file, str(xbri))

if len(sys.argv) > 1:
    if sys.argv[1] == 'up':
        xbri=xbri+0.1
    if sys.argv[1] == 'down':
        xbri=xbri-0.1

if xbri <= 0.01 or xbri >= 0.99:
    sys.exit()

cmd="xrandr --output %s --brightness %s" % (dout, xbri)
dout=subprocess.check_output(cmd, shell=True)
writef(xbri_file, str(xbri))

print(cmd)
