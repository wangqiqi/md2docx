#!/bin/bash

# =============================================================================
# Super Cursor · maintain skill — 开发环境诊断与安全清理
# 用法：
#   .cursor/skills/maintain/scripts/dev-maintain.sh --diagnose
#   .cursor/skills/maintain/scripts/dev-maintain.sh --clean [--dry-run] [--interactive]
#   .cursor/skills/maintain/scripts/dev-maintain.sh --snapshot | --diff
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CURSOR_ROOT="$(cd "$SKILL_ROOT/../.." && pwd)"
PROJECT_ROOT="$(cd "$CURSOR_ROOT/.." && pwd)"
DISK_COLLECT="${CURSOR_ROOT}/skills/disk/scripts/collect-disk.py"
DISK_SNAPSHOT_DIR="${PROJECT_ROOT}/.cursorGrowth/disk-snapshots"
CONFIG_DEFAULT="${SKILL_ROOT}/config/default-protected.json"
CONFIG_OVERRIDE="${PROJECT_ROOT}/.cursorGrowth/maintain-config.json"
INSTALLER_DIRS_JSON='[]'
PROTECTED_DIRS=()
CACHE_DIRS=()
EXTRA_CACHE_DIRS=()
BUILD_ARTIFACT_DIRS=()
BUILD_ARTIFACT_TMP_GLOBS=()

load_maintain_config() {
    eval "$(python3 "$SCRIPT_DIR/load-config.py" --default "$CONFIG_DEFAULT" --override "$CONFIG_OVERRIDE")"
}
load_maintain_config

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 模式变量
MODE="diagnose"  # 默认诊断模式
DRY_RUN=false
INTERACTIVE=false

# 参数解析
while [[ $# -gt 0 ]]; do
    case $1 in
        --clean)
            MODE="clean"
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --diagnose)
            MODE="diagnose"
            shift
            ;;
        --interactive)
            INTERACTIVE=true
            shift
            ;;
        --snapshot)
            MODE="snapshot"
            shift
            ;;
        --diff)
            MODE="diff"
            shift
            ;;
        *)
            echo -e "${RED}未知参数: $1${NC}"
            echo "用法: $0 [--diagnose|--clean|--snapshot|--diff|--interactive] [--dry-run]"
            exit 1
            ;;
    esac
done

# 日志函数
log() { echo -e "${BLUE}🧹 $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
info() { echo -e "${PURPLE}ℹ️  $1${NC}"; }
bad() { echo -e "${RED}❌ $1${NC}"; }

# 获取精确字节使用量
get_used_bytes() {
    df -B1 "$1" --output=used | tail -1
}

# 受保护目录：由 maintain config 加载

is_protected_path() {
    local target resolved protected expanded
    target=$(readlink -f "$1" 2>/dev/null || echo "$1")
    for protected in "${PROTECTED_DIRS[@]}"; do
        expanded=$(expand_path "$protected")
        resolved=$(readlink -f "$expanded" 2>/dev/null || echo "$expanded")
        if [[ -n "$resolved" && ("$target" == "$resolved" || "$target" == "$resolved"/*) ]]; then
            return 0
        fi
    done
    return 1
}

# 大文件清理等场景下额外跳过的关键用户数据（非缓存）
is_critical_user_data() {
    local target
    target=$(readlink -f "$1" 2>/dev/null || echo "$1")
    [[ "$target" == "$HOME/.config/Cursor"* ]] && return 0
    [[ "$target" == *"/state.vscdb"* ]] && return 0
    return 1
}

expand_path() {
    local p=$1
    if [[ "$p" == .cursorGrowth* ]]; then
        echo "${PROJECT_ROOT}/${p}"
        return
    fi
    p="${p/#\~/$HOME}"
    echo "$p"
}

dir_bytes() {
    du -sb "$1" 2>/dev/null | awk '{print $1}' || echo "0"
}

report_freed() {
    local pre=$1 post=$2 label=$3
    local cleaned=$((pre - post))
    if [ $cleaned -gt 0 ]; then
        success "$label: 释放 $((cleaned / 1024 / 1024)) MB"
    else
        info "$label: 无显著变化"
    fi
}

prompt_yes_no() {
    echo -e "\n${YELLOW}$1 (y/N)${NC}"
    read -r response
    [[ "$response" =~ ^[Yy]$ ]]
}

INSTALLER_NAMES='\( -name "*.deb" -o -name "*.run" -o -name "*.tar.gz" -o -name "*.zip" -o -name "*.AppImage" -o -name "*.exe" \)'

show_installers_in_dir() {
    local dir=$1 title=$2
    echo -e "\n${GREEN}📁 ${title}（🔒 受保护）：${NC}"
    find "$dir" -maxdepth 1 -type f $INSTALLER_NAMES -exec ls -lh {} \; 2>/dev/null | head -10
}

ask_installer_cleanup() {
    local dir=$1 title=$2 varname=$3
    [ -d "$dir" ] || return 0
    show_installers_in_dir "$dir" "$title"
    if prompt_yes_no "是否清理 ${title} 中的旧安装包（30天前）？需明确确认"; then
        eval "$varname=true"
        success "已获同意，将清理 ${title} 中的旧安装包"
    else
        info "跳过 ${title} 清理"
    fi
}

clean_cache_contents() {
    local expanded=$1
    if [[ "$expanded" == *"google-chrome"* || "$expanded" == *"mozilla"* ]]; then
        rm -rf "$expanded"/Default/Cache/* "$expanded"/Profiles/*/Cache/* 2>/dev/null || true
    elif [[ "$expanded" == *"microsoft-edge"* ]]; then
        rm -rf "$expanded"/Default/Cache/* "$expanded"/Default/Code\ Cache/* \
               "$expanded"/Default/Service\ Worker/CacheStorage/* 2>/dev/null || true
    else
        rm -rf "$expanded"/* 2>/dev/null || true
    fi
}

rm_dir_contents_measured() {
    local expanded=$1
    [ -d "$expanded" ] || return 0
    if is_protected_path "$expanded"; then
        warn "跳过受保护缓存路径: $expanded"
        return 0
    fi
    if $DRY_RUN; then
        local size
        size=$(du -sh "$expanded" 2>/dev/null | awk '{print $1}' || echo "0B")
        info "将清理 $expanded ($size)"
        return 0
    fi
    local pre post
    pre=$(dir_bytes "$expanded")
    clean_cache_contents "$expanded"
    post=$(dir_bytes "$expanded")
    report_freed "$pre" "$post" "$expanded"
}

purge_old_installers() {
    local dir=$1 label=$2
    [ -d "$dir" ] || return 0
    find "$dir" -type f \( -name "*.deb" -o -name "*.run" -o -name "*.tar.gz" -o -name "*.zip" -o -name "*.AppImage" \) \
        -mtime +30 -delete 2>/dev/null || true
    success "已清理 ${label} 中的旧安装包"
}

prompt_installer_dirs() {
    while IFS='|' read -r ipath ilabel iflag; do
        [[ -z "$ipath" ]] && continue
        ask_installer_cleanup "$ipath" "$ilabel" "$iflag"
    done < <(python3 -c "import json,sys; from pathlib import Path
for i in json.loads(sys.argv[1]):
 p=Path(i['path']).expanduser()
 if p.is_dir(): print(f'{p}|{i[\"label\"]}|{i[\"flag\"]}')" "$INSTALLER_DIRS_JSON")
}

purge_enabled_installers() {
    python3 -c "import json,sys,os; from pathlib import Path
items=json.loads(sys.argv[1])
flags={k:v for k,v in (x.split('=') for x in sys.argv[2].split(',') if '=' in x)}
for i in items:
 flag=i.get('flag','')
 if flags.get(flag,'false')=='true':
  p=Path(i['path']).expanduser()
  if p.is_dir(): print(f'{p}|{i[\"label\"]}')" "$INSTALLER_DIRS_JSON" \
        "CLEAN_DOWNLOADS_INSTALLERS=${CLEAN_DOWNLOADS_INSTALLERS},CLEAN_INSTALL_DIR=${CLEAN_INSTALL_DIR},CLEAN_DEPENDS_DIR=${CLEAN_DEPENDS_DIR}" \
        | while IFS='|' read -r dir label; do
        [[ -z "$dir" ]] && continue
        purge_old_installers "$dir" "$label"
    done
}

print_protected_dirs_notice() {
    info "以下目录受保护，默认不会清理（需 --interactive --clean 逐项确认）："
    for dir in "${PROTECTED_DIRS[@]}"; do
        echo "  🔒 $dir"
    done
}

print_default_clean_notice() {
    info "--clean 默认会清理：APT 缓存/旧内核、系统日志、回收站、浏览器/npm/pip 缓存、"
    info "  IDE 缓存、ccache、可选构建产物目录等（不触碰受保护目录）"
}

# =============================================================================
# 🩺 诊断功能
# =============================================================================
diagnose_system() {
    echo -e "${CYAN}🛡️  Ubuntu 长期维护模式诊断（专注 22.04 LTS 稳定性）${NC}"
    echo "📅 $(date)"
    echo "========================================"

    # 1. 系统基本信息
    echo -e "\n${GREEN}📌 1. 系统基本信息${NC}"
    OS_INFO=$(lsb_release -d 2>/dev/null || grep -E '^PRETTY_NAME=' /etc/os-release 2>/dev/null | cut -d'=' -f2 | tr -d '"')
    OS_RELEASE=$(lsb_release -rs 2>/dev/null || grep -E '^VERSION_ID=' /etc/os-release 2>/dev/null | cut -d'=' -f2 | tr -d '"')
    KERNEL=$(uname -r)
    ARCH=$(uname -m)

    echo "系统版本: $OS_INFO"
    echo "版本号: $OS_RELEASE"
    echo "内核: $KERNEL"
    echo "架构: $ARCH"

    # 2. 版本维护策略
    echo -e "\n${GREEN}📌 2. 版本维护策略${NC}"
    if [[ "$OS_RELEASE" == "22.04" ]]; then
        success "当前为 Ubuntu 22.04 LTS —— 官方支持至 2027 年（可延至 2032）"
        info "建议：长期使用此版本，无需升级到 24.04"
    elif [[ "$OS_RELEASE" < "22.04" ]]; then
        warn "当前版本低于 22.04 LTS，建议升级到 22.04 以获得长期支持"
        echo "  升级命令：sudo do-release-upgrade"
    else
        info "当前为较新版本（如 24.04），本脚本仍可提供维护建议"
    fi

    # 3. APT 与包管理状态
    echo -e "\n${GREEN}📌 3. APT 与包管理状态${NC}"

    if [ -f /var/lib/dpkg/lock ] || [ -f /var/lib/dpkg/lock-frontend ]; then
        warn "dpkg 锁存在，可能有后台更新（如 unattended-upgrades）"
    else
        success "dpkg 锁正常"
    fi

    if sudo dpkg -l 2>/dev/null | grep -q '^[Hh]'; then
        bad "存在未完成配置的软件包！请运行：sudo dpkg --configure -a"
    else
        success "dpkg 配置状态正常"
    fi

    ORPHANS=$(dpkg -l 2>/dev/null | awk '/^rc/ {print $2}' | wc -l)
    if [ "$ORPHANS" -gt 0 ]; then
        warn "发现 $ORPHANS 个残留配置包（可清理）"
    else
        success "无残留配置包"
    fi

    # 4. 系统资源与健康
    echo -e "\n${GREEN}📌 4. 系统资源与健康${NC}"

    ROOT_AVAIL_GB=$(( $(df / --output=avail | tail -1) / 1024 / 1024 ))
    ROOT_USED_GB=$(( $(df / --output=used | tail -1) / 1024 / 1024 ))
    echo "根分区使用: ${ROOT_USED_GB} GB / 可用: ${ROOT_AVAIL_GB} GB"
    if [ $ROOT_AVAIL_GB -lt 5 ]; then
        bad "磁盘空间紧张！建议立即清理"
    elif [ $ROOT_AVAIL_GB -lt 10 ]; then
        warn "磁盘空间较少（<10GB），建议定期清理"
    else
        success "磁盘空间充足"
    fi

    free -h
    MEM_AVAILABLE=$(free | awk 'NR==2{print int($7/1024/1024)}')
    if [ $MEM_AVAILABLE -lt 1 ]; then
        warn "可用内存 <1GB，注意避免内存密集型任务"
    fi

    if timeout 5 ping -c 1 archive.ubuntu.com &> /dev/null; then
        success "可连接 Ubuntu 官方源"
    else
        bad "无法连接官方源，请检查网络或更换镜像源"
    fi

    # 5. 系统级可清理项
    echo -e "\n${GREEN}📌 5. 系统级可清理项${NC}"

    APT_CACHE=$(du -sh /var/cache/apt/archives/ 2>/dev/null | cut -f1 || echo "0M")
    echo "APT 缓存: $APT_CACHE （清理命令：sudo apt clean）"

    CURRENT_KERNEL=$(uname -r)
    OLD_KERNELS=$(dpkg --list 2>/dev/null | grep 'linux-image-.*-generic' | grep -v "$CURRENT_KERNEL" | wc -l)
    echo "旧内核数量: $OLD_KERNELS （清理命令：sudo apt autoremove --purge）"

    LOG_SIZE=$(sudo du -sh /var/log/ 2>/dev/null | cut -f1 || echo "N/A")
    JOURNAL_SIZE=$(sudo journalctl --disk-usage 2>/dev/null | grep -o '[0-9.]*[KMGT]B*' || echo "N/A")
    echo "日志目录: $LOG_SIZE"
    echo "journal 日志: $JOURNAL_SIZE （清理命令：sudo journalctl --vacuum-time=3d）"

    SNAP_CACHE=$(du -sh /var/cache/snapd/ 2>/dev/null | cut -f1 || echo "0M")
    if [[ "$SNAP_CACHE" != "0M" && "$SNAP_CACHE" != "" ]]; then
        echo "Snap 缓存: $SNAP_CACHE"
    fi

    # 6. 用户级缓存预估（AI/开发工具）
    echo -e "\n${GREEN}📌 6. 用户级缓存预估（AI/开发工具）${NC}"

    user_caches=(
        "~/.cache"
        "~/.ccache"
        "~/.cursor"
        "~/.npm"
        "~/.cache/pip"
        "~/.cache/mamba"
        "~/.conda/pkgs"
        "~/.cache/google-chrome"
        "~/.cache/mozilla"
        "~/.cache/microsoft-edge"
        "~/.cache/uv"
        "~/.cache/vscode-cpptools"
        "~/.cache/thumbnails"
        "~/Downloads"
        "~/.local/share/Trash"
    )

    found_any=false
    for cache in "${user_caches[@]}"; do
        expanded=$(expand_path "$cache")
        if [ -d "$expanded" ]; then
            size=$(du -sh "$expanded" 2>/dev/null | awk '{print $1}' || echo "0B")
            if [[ "$size" =~ ^[0-9.]+[KMGT]B?$ ]] && [[ $(echo "$size" | sed 's/[A-Za-z]//g') != "0" ]]; then
                echo "  💾 $cache: $size"
                found_any=true
            fi
        fi
    done

    if [ "$found_any" = false ]; then
        success "未发现显著用户缓存（或目录不存在）"
    fi

    # 7. 大目录预警（>1GB in /home）
    echo -e "\n${GREEN}📌 7. 大目录预警（/home 下 >1GB）${NC}"

    if command -v sudo &> /dev/null && [ -d /home ]; then
        BIG_DIRS=$(sudo du -h --max-depth=1 /home/* 2>/dev/null | awk '$1 ~ /^[0-9.]+[G]/ {print}' | sort -hr | head -n 8)
        if [ -n "$BIG_DIRS" ]; then
            while IFS= read -r line; do
                echo "  📁 $line"
            done <<< "$BIG_DIRS"
            info "受保护目录见 maintain 配置，默认不会自动清理"
        else
            success "未发现 >1GB 的用户目录"
        fi
    else
        info "无 sudo 权限或 /home 不可访问，跳过大目录扫描"
    fi

    # 8. 开发环境保护提示
    echo -e "\n${GREEN}📌 8. 开发环境保护提示${NC}"
    success "Conda / venv / Docker / Snap 等用户级环境不受系统维护影响"
    info "建议："
    echo "  • 使用 Conda/Miniconda 管理 Python 环境"
    echo "  • 避免使用系统 python3 安装 pip 包（防止依赖污染）"
    echo "  • 定期备份重要环境：conda env export -n myenv > myenv.yml"
    echo "  • Docker 镜像/容器可单独清理：docker system prune -a"

    # 9. 长期维护建议
    echo -e "\n${GREEN}📌 9. 长期维护建议${NC}"
    echo "✅ 运行 $0 --clean 将默认清理："
    echo "   • 系统：APT 缓存、旧内核、journal/旧日志"
    echo "   • 用户：npm/pip/浏览器缩略图/IDE 缓存、回收站、ccache、可配置构建产物"
    echo ""
    echo "🔒 受保护目录见 config/default-protected.json 与 .cursorGrowth/maintain-config.json"
    echo ""
    echo "🔒 无需升级系统版本，22.04 LTS 已足够稳定且长期支持！"

    echo -e "\n${CYAN}💡 要执行清理操作，请运行：$0 --clean${NC}"
    echo -e "${CYAN}📋 要预览清理内容，请运行：$0 --clean --dry-run${NC}"
    echo -e "${CYAN}🗂️  要交互式选择清理，请运行：$0 --interactive --clean${NC}"
}

# =============================================================================
# 🎯 交互式清理选择功能
# =============================================================================
interactive_cleanup_selection() {
    echo -e "\n${YELLOW}🗂️  交互式清理模式：在默认安全清理基础上，确认受保护目录${NC}"
    print_protected_dirs_notice
    print_default_clean_notice

    # 受保护目录相关项：默认关闭，仅交互确认后启用
    CLEAN_DOWNLOADS_INSTALLERS=false
    CLEAN_CONDA_CACHE=false
    CLEAN_INSTALL_DIR=false
    CLEAN_DEPENDS_DIR=false
    CLEAN_LARGE_FILES=false
    CLEAN_HF_CACHE=false
    CLEAN_DOCKER=false
    CLEAN_CONDA_ENVS=false

    prompt_installer_dirs

    if command -v conda &> /dev/null; then
        if prompt_yes_no "是否清理 miniconda3 下载缓存（conda clean，不影响已装环境）？需明确确认"; then
            CLEAN_CONDA_CACHE=true
            success "已获同意，将清理 Conda 下载缓存"
        else
            info "跳过 miniconda3 缓存清理"
        fi
    fi

    if command -v conda &> /dev/null && prompt_yes_no "是否删除未使用的 Conda 环境（不含 base/当前环境）？需明确确认"; then
        CLEAN_CONDA_ENVS=true
        success "已获同意，将清理未使用的 Conda 环境"
    fi

    if [ -d ~/.cache/huggingface ]; then
        hf_size=$(du -sh ~/.cache/huggingface 2>/dev/null | awk '{print $1}')
        if prompt_yes_no "是否清理 HuggingFace 模型缓存（当前 ${hf_size}）？需明确确认"; then
            CLEAN_HF_CACHE=true
            success "已获同意，将清理 HuggingFace 缓存"
        fi
    fi

    if command -v docker &> /dev/null && prompt_yes_no "是否清理 Docker 未使用镜像/容器/卷？需明确确认"; then
        CLEAN_DOCKER=true
        success "已获同意，将清理 Docker 未使用资源"
    fi

    # 检查大文件（自动排除受保护目录）
    echo -e "\n${GREEN}📁 检查大文件（>500M，已排除受保护目录）：${NC}"
    large_file_count=0
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        ls -lh "$file"
        large_file_count=$((large_file_count + 1))
    done < <(find ~ -maxdepth 3 -type f -size +500M 2>/dev/null | while read -r f; do
        is_protected_path "$f" || is_critical_user_data "$f" || echo "$f"
    done | head -10)
    if [ "$large_file_count" -eq 0 ]; then
        info "未发现需展示的大文件（或均在受保护目录内）"
    fi

    if prompt_yes_no "是否清理上述大文件（不会触碰受保护目录）？需明确确认"; then
        CLEAN_LARGE_FILES=true
        success "将清理非受保护目录中的大文件"
    else
        info "跳过大文件清理"
    fi

    echo -e "\n${PURPLE}🎯 选择完成，开始执行清理...${NC}"
}

# =============================================================================
# 🧹 清理功能
# =============================================================================
clean_system() {
    if [[ "${DRY_RUN}" == "true" ]]; then
        echo -e "${YELLOW}🔍 预览模式（--dry-run）：仅显示将清理的内容，不执行删除${NC}"
    fi

    # 可选清理模块默认值
    # ✅ 默认可安全完全清理
    CLEAN_APT=true
    CLEAN_TRASH=true
    CLEAN_IDE_DEEP=true
    CLEAN_AI_CACHE=true
    CLEAN_BUILD_CACHE=true
    # 🔒 受保护目录 / 高风险项，默认关闭
    CLEAN_CONDA_CACHE=false
    CLEAN_DOWNLOADS_INSTALLERS=false
    CLEAN_DOCKER=false
    CLEAN_CONDA_ENVS=false
    CLEAN_INSTALL_DIR=false
    CLEAN_DEPENDS_DIR=false
    CLEAN_LARGE_FILES=false
    CLEAN_HF_CACHE=false

    if [[ "${INTERACTIVE}" == "true" ]]; then
        interactive_cleanup_selection
    fi

    ROOT_BEFORE=$(get_used_bytes /)
    HOME_BEFORE=""
    if [ -d /home ] && mountpoint -q /home; then
        HOME_BEFORE=$(get_used_bytes /home)
    fi

    echo -e "${GREEN}🚀 开始 Ubuntu AI 开发环境深度清理...${NC}"
    echo "当前时间: $(date)"
    echo "=============================================="
    print_default_clean_notice
    print_protected_dirs_notice

    # -------------------------- 1. 系统/用户临时文件 --------------------------
    log "清理系统/用户临时文件..."
    if ! $DRY_RUN; then
        if [ -d /tmp ]; then
            find /tmp -user "$USER" -type f -mtime +7 -delete 2>/dev/null || true
            find /tmp -user "$USER" -type d -mtime +7 -empty -delete 2>/dev/null || true
            success "/tmp 中 ${USER} 的 7 天前临时文件已清理"
        fi

        for tmp_dir in ~/.tmp ~/tmp ~/temp; do
            expanded=$(expand_path "$tmp_dir")
            if [ -d "$expanded" ]; then
                rm -rf "$expanded"/* 2>/dev/null || true
                success "用户临时目录 $expanded 已清空"
            fi
        done
    else
        info "将清理 /tmp（7天前）及 ~/.tmp, ~/tmp, ~/temp"
    fi

    # -------------------------- 2. 系统日志与 APT 清理 --------------------------
    log "清理系统日志..."
    if command -v sudo &> /dev/null; then
        if ! $DRY_RUN; then
            sudo find /var/log -type f \( -name "*.log*" -o -name "*.gz" \) -mtime +3 -delete 2>/dev/null || true
            if systemctl is-active --quiet systemd-journald; then
                sudo journalctl --vacuum-time=3d --quiet 2>/dev/null || true
            fi
            success "系统日志（保留3天）已清理"
        else
            info "将清理 /var/log/*.log*, *.gz（3天前）和 journal 日志（保留3天）"
        fi
    else
        warn "无 sudo 权限，跳过系统日志清理"
    fi

    if [[ "$CLEAN_APT" == "true" ]] && command -v sudo &> /dev/null; then
        log "清理 APT 缓存与旧内核..."
        if ! $DRY_RUN; then
            sudo apt-get clean -y 2>/dev/null || sudo apt clean 2>/dev/null || true
            sudo apt-get autoremove --purge -y 2>/dev/null || sudo apt autoremove --purge -y 2>/dev/null || true
            success "APT 缓存、残留配置包与旧内核已清理"
            if [ -d /var/crash ] && compgen -G '/var/crash/*.crash' > /dev/null; then
                pre=$(du -sb /var/crash 2>/dev/null | awk '{print $1}')
                sudo rm -f /var/crash/*.crash 2>/dev/null || true
                post=$(du -sb /var/crash 2>/dev/null | awk '{print $1}' || echo "0")
                cleaned=$((pre - post))
                if [ $cleaned -gt 0 ]; then
                    success "/var/crash 崩溃转储: 释放 $((cleaned / 1024 / 1024)) MB"
                fi
            fi
        else
            info "将执行: apt clean && apt autoremove --purge"
        fi
    elif [[ "$CLEAN_APT" == "true" ]]; then
        warn "无 sudo 权限，跳过 APT 清理"
    fi

    # -------------------------- 3. 回收站 --------------------------
    if [[ "$CLEAN_TRASH" == "true" ]]; then
        log "清空回收站..."
        if [ -d ~/.local/share/Trash ] && ! $DRY_RUN; then
            pre=$(dir_bytes ~/.local/share/Trash)
            rm -rf ~/.local/share/Trash/* 2>/dev/null || true
            post=$(dir_bytes ~/.local/share/Trash)
            report_freed "$pre" "$post" "回收站"
        elif $DRY_RUN; then
            size=$(du -sh ~/.local/share/Trash 2>/dev/null | awk '{print $1}' || echo "0B")
            info "将清空回收站 (~/.local/share/Trash, $size)"
        fi
    fi

    # -------------------------- 4. 用户应用缓存清理 --------------------------
    log "清理用户应用缓存..."

    cache_dirs=("${CACHE_DIRS[@]}")

    for dir in "${cache_dirs[@]}"; do
        rm_dir_contents_measured "$(expand_path "$dir")"
    done

    extra_cache_dirs=()
    for dir in "${EXTRA_CACHE_DIRS[@]}"; do
        extra_cache_dirs+=("$(expand_path "$dir")")
    done
    if ! $DRY_RUN; then
        for pattern in "$HOME/.cache/.fr-"*; do
            [ -e "$pattern" ] || continue
            is_protected_path "$pattern" && continue
            pre=$(dir_bytes "$pattern")
            rm -rf "$pattern" 2>/dev/null || true
            post=$(dir_bytes "$pattern")
            cleaned=$((pre - post))
            [ $cleaned -gt 0 ] && success "$pattern: 释放 $((cleaned / 1024 / 1024)) MB"
        done
        for expanded in "${extra_cache_dirs[@]}"; do
            [ -d "$expanded" ] || continue
            is_protected_path "$expanded" && continue
            pre=$(dir_bytes "$expanded")
            rm -rf "$expanded"/* 2>/dev/null || true
            post=$(dir_bytes "$expanded")
            report_freed "$pre" "$post" "$expanded"
        done
    else
        info "将清理 ~/.cache/go-build、~/.cache/ms-playwright-go、~/.cache/.fr-* 等"
    fi

    # 桌面元数据
    if ! $DRY_RUN; then
        rm -rf ~/.local/share/recently-used.xbel ~/.local/share/recently-used 2>/dev/null || true
        success "桌面最近文档记录已清理"
    else
        info "将清理桌面最近文档记录"
    fi

    # -------------------------- 5. 包管理器缓存 --------------------------
    log "清理 NPM / Conda / Mamba / pip 缓存..."

    # NPM（不在受保护目录内）
    if [ -d ~/.npm ] && ! $DRY_RUN; then
        pre=$(dir_bytes ~/.npm)
        rm -rf ~/.npm/_cacache ~/.npm/_logs 2>/dev/null || true
        post=$(dir_bytes ~/.npm)
        report_freed "$pre" "$post" "NPM 缓存"
    elif [ -d ~/.npm ] && $DRY_RUN; then
        info "将清理 NPM 缓存 (~/.npm)"
    fi

    # Mamba
    if [ -d ~/.cache/mamba ] && ! $DRY_RUN; then
        pre=$(dir_bytes ~/.cache/mamba)
        rm -rf ~/.cache/mamba/* 2>/dev/null || true
        post=$(dir_bytes ~/.cache/mamba)
        report_freed "$pre" "$post" "Mamba 缓存"
    fi

    # pip
    if command -v pip &> /dev/null && ! $DRY_RUN; then
        pip_cache=$(pip cache dir 2>/dev/null)
        if [ -n "$pip_cache" ] && [ -d "$pip_cache" ]; then
            pre=$(dir_bytes "$pip_cache")
            pip cache purge --quiet 2>/dev/null || rm -rf "$pip_cache" 2>/dev/null || true
            post=$(dir_bytes "$pip_cache")
            report_freed "$pre" "$post" "pip 缓存"
        fi
    fi

    # =============================================================================
    # 🧩 可选清理模块（受保护目录相关项默认关闭，仅交互模式可启用）
    # =============================================================================

    # -------------------------- 可选模块执行逻辑 --------------------------
    if ! $DRY_RUN; then

        # Conda 下载缓存（miniconda3 受保护，仅交互确认后清理 pkgs 缓存）
        if [[ "$CLEAN_CONDA_CACHE" == "true" ]] && command -v conda &> /dev/null; then
            log "清理 Conda 下载缓存（不影响已安装环境）..."
            conda clean --tarballs --packages --index-cache --yes --quiet 2>/dev/null || true
            success "Conda 下载缓存已清理"
        fi

        # 🐳 Docker 清理
        if [[ "$CLEAN_DOCKER" == "true" ]] && command -v docker &> /dev/null; then
            log "执行 Docker 深度清理..."
            if docker system df &> /dev/null; then
                docker system prune -af --volumes 2>/dev/null || true
                success "Docker 未使用资源已清理"
            else
                warn "Docker 服务未运行，跳过清理"
            fi
        fi

        # 🐍 Conda 环境清理
        if [[ "$CLEAN_CONDA_ENVS" == "true" ]] && command -v conda &> /dev/null; then
            log "检查可清理的 Conda 环境..."
            CURRENT_ENV=$(basename "$CONDA_DEFAULT_ENV" 2>/dev/null || echo "base")
            ALL_ENVS=$(conda env list --json 2>/dev/null | python3 -c "import sys, json; print('\n'.join([e.split('/')[-1] for e in json.load(sys.stdin)['envs']]))" 2>/dev/null || echo "")
            TO_REMOVE=()
            for env in $ALL_ENVS; do
                if [[ "$env" != "base" ]] && [[ "$env" != "$CURRENT_ENV" ]]; then
                    TO_REMOVE+=("$env")
                fi
            done
            if [ ${#TO_REMOVE[@]} -gt 0 ]; then
                for env in "${TO_REMOVE[@]}"; do
                    conda env remove -n "$env" --yes 2>/dev/null || true
                    success "已删除 Conda 环境: $env"
                done
            else
                info "无额外 Conda 环境可清理"
            fi
        fi

        # 📦 旧安装包清理（install/depends 需逐项确认）
        if [[ "$CLEAN_DOWNLOADS_INSTALLERS" == "true" || "$CLEAN_INSTALL_DIR" == "true" || "$CLEAN_DEPENDS_DIR" == "true" ]]; then
            log "清理 30 天前的安装包..."
            purge_enabled_installers
        fi

        # 💾 IDE 深度缓存清理
        if [[ "$CLEAN_IDE_DEEP" == "true" ]]; then
            log "深度清理 IDE 缓存..."

            # Cursor 缓存 - 更激进地清理整个目录
            if [ -d "$HOME/.cursor" ]; then
                pre=$(dir_bytes "$HOME/.cursor")
                rm -rf "$HOME/.cursor/cache" "$HOME/.cursor/logs" 2>/dev/null || true
                find "$HOME/.cursor" -name "*.log" -mtime +7 -delete 2>/dev/null || true
                post=$(dir_bytes "$HOME/.cursor")
                report_freed "$pre" "$post" "Cursor 缓存"
            fi

            # VS Code 缓存
            VSCODE_CONFIG="$HOME/.config/Code"
            if [ -d "$VSCODE_CONFIG" ]; then
                rm -rf "$VSCODE_CONFIG"/CachedExtensionVSIXs/* 2>/dev/null || true
                success "VS Code 扩展缓存已清理"
            fi
        fi

        # 🔧 编译缓存清理 (ccache)
        if [[ "$CLEAN_BUILD_CACHE" == "true" ]]; then
            log "清理编译缓存..."
            if [ -d "$HOME/.ccache" ]; then
                pre=$(dir_bytes "$HOME/.ccache")
                ccache -C >/dev/null 2>&1 || rm -rf "$HOME/.ccache"/* 2>/dev/null || true
                post=$(dir_bytes "$HOME/.ccache")
                report_freed "$pre" "$post" "ccache 编译缓存"
            fi

            for artifact in "${BUILD_ARTIFACT_DIRS[@]}"; do
                expanded=$(expand_path "$artifact")
                [ -d "$expanded" ] || continue
                pre=$(dir_bytes "$expanded")
                rm -rf "$expanded"/* 2>/dev/null || true
                post=$(dir_bytes "$expanded")
                report_freed "$pre" "$post" "构建产物 ($expanded)"
            done
            for pattern in "${BUILD_ARTIFACT_TMP_GLOBS[@]}"; do
                [[ -z "$pattern" ]] && continue
                dirs=()
                while IFS= read -r d; do dirs+=("$d"); done < <(compgen -G "$pattern" || true)
                if [ ${#dirs[@]} -gt 0 ]; then
                    pre=0
                    for d in "${dirs[@]}"; do
                        pre=$((pre + $(du -sb "$d" 2>/dev/null | awk '{print $1}' || echo 0)))
                    done
                    rm -rf "${dirs[@]}" 2>/dev/null || true
                    if [ $pre -gt 0 ]; then
                        success "临时构建目录 ($pattern): 释放 $((pre / 1024 / 1024)) MB"
                    fi
                fi
            done
        fi

        # 🤖 AI/机器学习小缓存（HuggingFace 模型默认保留，需交互确认）
        if [[ "$CLEAN_AI_CACHE" == "true" ]]; then
            log "清理 AI/开发工具小缓存..."

            if [[ "$CLEAN_HF_CACHE" == "true" ]] && [ -d ~/.cache/huggingface ]; then
                pre=$(dir_bytes ~/.cache/huggingface)
                rm -rf ~/.cache/huggingface/hub/* 2>/dev/null || true
                post=$(dir_bytes ~/.cache/huggingface)
                report_freed "$pre" "$post" "HuggingFace 缓存"
            fi

            # Tracker 索引（GNOME 文件索引缓存）
            rm -rf ~/.cache/tracker3 ~/.cache/tracker* 2>/dev/null || true
            success "Tracker 索引已清理"

            # 3. 清理 Netron 更新缓存
            if [ -d ~/.cache/netron-updater ]; then
                rm -rf ~/.cache/netron-updater 2>/dev/null || true
                success "Netron 更新缓存已清理"
            fi

            # 4. 清理 VLC 缓存
            if [ -d ~/.cache/vlc ]; then
                rm -rf ~/.cache/vlc 2>/dev/null || true
                success "VLC 缓存已清理"
            fi

            # 5. 清理 NVIDIA 缓存（如果不经常用GPU）
            if [ -d ~/.cache/nvidia ]; then
                rm -rf ~/.cache/nvidia 2>/dev/null || true
                success "NVIDIA 缓存已清理"
            fi

            # 6. 清理其他AI相关小缓存
            rm -rf ~/.cache/matplotlib 2>/dev/null || true
            rm -rf ~/.cache/gstreamer-1.0 2>/dev/null || true
        fi

        # 📁 大文件清理（跳过受保护目录）
        if [[ "$CLEAN_LARGE_FILES" == "true" ]]; then
            log "清理大文件（>500M，已排除受保护目录）..."
            deleted=0
            while IFS= read -r file; do
                [[ -z "$file" ]] && continue
                if is_protected_path "$file" || is_critical_user_data "$file"; then
                    warn "跳过: $file"
                    continue
                fi
                rm -f "$file" 2>/dev/null && deleted=$((deleted + 1))
            done < <(find ~ -maxdepth 3 -type f -size +500M 2>/dev/null)
            success "大文件已清理（删除 ${deleted} 个，受保护目录未触碰）"
        fi

    else
        # --dry-run 模式下提示
        print_default_clean_notice
        info "受保护目录见 maintain 配置"
        if [[ "$CLEAN_APT" == "true" ]]; then
            info "[默认] 将清理 APT 缓存、残留配置包与旧内核"
        fi
        if [[ "$CLEAN_TRASH" == "true" ]]; then
            info "[默认] 将清空回收站"
        fi
        if [[ "$CLEAN_CONDA_CACHE" == "true" ]]; then
            info "[需确认] 将清理 miniconda3 下载缓存（不影响已装环境）"
        else
            info "miniconda3: 默认不清理"
        fi
        if [[ "$CLEAN_DOWNLOADS_INSTALLERS" == "true" ]]; then
            info "[需确认] 将清理 ~/Downloads 中 30 天前的安装包"
        else
            info "Downloads: 默认不清理"
        fi
        if [[ "$CLEAN_DOCKER" == "true" ]]; then
            info "[需确认] 将清理 Docker 未使用资源（镜像/容器/卷）"
        fi
        if [[ "$CLEAN_CONDA_ENVS" == "true" ]]; then
            info "[需确认] 将删除非 base/非当前的 Conda 环境"
        fi
        if [[ "$CLEAN_INSTALL_DIR" == "true" ]]; then
            info "[需确认] 将清理 ~/install 中 30 天前的安装包"
        fi
        if [[ "$CLEAN_DEPENDS_DIR" == "true" ]]; then
            info "[需确认] 将清理 ~/depends 中 30 天前的安装包"
        fi
        if [[ "$CLEAN_IDE_DEEP" == "true" ]]; then
            info "[默认] 将清理 IDE 缓存（Cursor/VS Code 扩展缓存）"
        fi
        if [[ "$CLEAN_AI_CACHE" == "true" ]]; then
            info "[默认] 将清理 Tracker/Netron/VLC 等小缓存"
        fi
        if [[ "$CLEAN_HF_CACHE" == "true" ]]; then
            info "[需确认] 将清理 HuggingFace 模型缓存"
        else
            info "HuggingFace 模型缓存: 默认保留"
        fi
        if [[ "$CLEAN_LARGE_FILES" == "true" ]]; then
            info "[需确认] 将清理非受保护目录中的大文件（>500M）"
        else
            info "大文件清理: 默认关闭"
        fi
    fi

    # -------------------------- 5. 清理后统计 --------------------------
    ROOT_AFTER=$(get_used_bytes /)
    ROOT_CLEANED=$((ROOT_BEFORE - ROOT_AFTER))
    ROOT_GB=$(awk "BEGIN {printf \"%.2f\", $ROOT_CLEANED/1024/1024/1024}")

    HOME_GB="0.00"
    if [ -n "$HOME_BEFORE" ]; then
        HOME_AFTER=$(get_used_bytes /home)
        HOME_CLEANED=$((HOME_BEFORE - HOME_AFTER))
        HOME_GB=$(awk "BEGIN {printf \"%.2f\", $HOME_CLEANED/1024/1024/1024}")
    fi

    echo -e "\n${GREEN}=============================================="
    echo "✅ 所有安全清理操作已完成！"
    echo -e "\n📊 空间释放统计："
    echo -e "${PURPLE}根分区 (/) 释放：${ROOT_GB} GB${NC}"
    if [ "$HOME_GB" != "0.00" ]; then
        echo -e "${PURPLE}/home 分区释放：${HOME_GB} GB${NC}"
    fi

    echo -e "\n${YELLOW}🎯 后续建议：${NC}"
    echo "1. 手动检查大目录：du -h ~ | sort -hr | head -n 20"
    echo "2. 受保护目录见 .cursorGrowth/maintain-config.json（交互模式可确认清理安装包）"
    echo "3. 查看 Conda 环境：conda env list"
    echo "4. 查看 Docker 使用：docker system df"

    echo -e "\n${GREEN}✨ 清理完毕，系统更轻快！${NC}"
}

# =============================================================================
# 📊 磁盘快照（结构化存储 + 变动对比）
# =============================================================================
run_disk_snapshot() {
    if [[ ! -f "$DISK_COLLECT" ]]; then
        bad "未找到 collect-disk.py: $DISK_COLLECT"
        exit 1
    fi
    mkdir -p "$DISK_SNAPSHOT_DIR"
    python3 "$DISK_COLLECT" snapshot --project-dir "$PROJECT_ROOT" --snapshot-dir "$DISK_SNAPSHOT_DIR"
}

run_disk_diff() {
    if [[ ! -f "$DISK_COLLECT" ]]; then
        bad "未找到 collect-disk.py: $DISK_COLLECT"
        exit 1
    fi
    python3 "$DISK_COLLECT" diff --project-dir "$PROJECT_ROOT" --snapshot-dir "$DISK_SNAPSHOT_DIR" --format diff
}

# =============================================================================
# 🚀 主执行逻辑
# =============================================================================
main() {
    case "$MODE" in
        "diagnose")
            diagnose_system
            ;;
        "clean")
            clean_system
            ;;
        "snapshot")
            run_disk_snapshot
            ;;
        "diff")
            run_disk_diff
            ;;
        *)
            echo -e "${RED}错误：未知模式${NC}"
            exit 1
            ;;
    esac
}

# 脚本入口
main "$@"
