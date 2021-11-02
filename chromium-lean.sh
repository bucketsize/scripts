#!/bin/sh

chromium --disk-cache-dir=/tmp/.chromium-cache \
    --process-per-site \
    --enable-features=VaapiVideoDecoder \
    --use-gl=egl


