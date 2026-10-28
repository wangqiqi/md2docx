#!/usr/bin/env bash
# 经 bash 调用：交付/拷贝路径可能丢 exec 位（apply 才会 chmod +x）
exec bash "$(dirname "$0")/verify.sh" --core
