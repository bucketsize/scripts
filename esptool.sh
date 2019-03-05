#!/bin/bash
esptool.py --port /dev/ttyUSB0 write_flash -fm dio 0x00000 $1
