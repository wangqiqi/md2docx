#!/bin/bash
# 委托 Super Cursor 标准布局验证
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/verify-super-cursor.sh" "$@"
