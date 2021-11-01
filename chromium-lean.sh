#!/bin/sh

chromium --disk-cache-dir=/tmp/.chromium-cache \
    # --single-process \ # insecure
    --process-per-site \
    --enable-features=VaapiVideoDecoder \
    --use-gl=egl


