#!/bin/bash 

qemu-system-i386 \
  -display sdl \
  -soundhw ac97 \
  -vga cirrus \
  $1
