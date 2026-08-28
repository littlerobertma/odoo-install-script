#!/bin/bash
# ==================================================
# Odoo 环境初始化安装脚本
#
# 支持:
#   Ubuntu 22.04 (jammy)
#   Ubuntu 24.04 (noble)
#
# 安装内容:
#   PostgreSQL
#   Python 环境
#   Odoo 依赖
#   wkhtmltopdf
#   中文字体
# ==================================================

set -e

# ==============================
# 检查 Root 权限
# ==============================
if [ "$EUID" -ne 0 ]; then
    echo "请使用 root 执行:"
    echo "sudo bash install_odoo_env.sh"
    exit 1
fi

# ==============================
# 获取系统信息
# ==============================
echo "======================================"
echo "检测系统版本"
echo "======================================"

source /etc/os-release

echo "系统名称: $PRETTY_NAME"
echo "版本代号: $VERSION_CODENAME"

if [ "$ID" != "ubuntu" ]; then
    echo "当前不是 Ubuntu 系统"
    exit 1
fi

case "$VERSION_CODENAME" in
    jammy)
        echo "检测到 Ubuntu 22.04"
        ;;
    noble)
        echo "检测到 Ubuntu 24.04"
        ;;
    *)
        echo "不支持的 Ubuntu 版本: $VERSION_CODENAME"
        exit 1
        ;;
esac

apt update

# ==============================
# 系统更新
# ==============================
echo "======================================"
echo "[1/5] 更新系统"
echo "======================================"

apt upgrade -y

# ==============================
# PostgreSQL
# ==============================
echo "======================================"
echo "[2/5] 安装 PostgreSQL"
echo "======================================"

apt install -y postgresql

read -r -s -p "请输入 Odoo 数据库密码: " ODOO_DB_PASSWORD
echo

echo "创建 Odoo 数据库用户"

sudo -u postgres psql <<EOF
DO \$\$
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_roles WHERE rolname='odoo'
    )
    THEN
        CREATE USER odoo WITH PASSWORD '$ODOO_DB_PASSWORD';
    END IF;
END
\$\$;

ALTER USER odoo WITH PASSWORD '$ODOO_DB_PASSWORD' SUPERUSER;
EOF

echo "PostgreSQL 完成"

# ==============================
# Python 依赖
# ==============================
echo "======================================"
echo "[3/5] 安装 Python 依赖"
echo "======================================"

apt install -y \
    python3-pip \
    build-essential \
    wget \
    python3-dev \
    python3-venv \
    python3-wheel \
    libxml2-dev \
    libxslt1-dev \
    libzip-dev \
    libldap2-dev \
    libpq-dev \
    libsasl2-dev \
    python3-setuptools \
    node-less \
    nodejs \
    npm

# ==============================
# wkhtmltopdf 依赖
# ==============================
echo "======================================"
echo "[4/5] 安装 wkhtmltopdf 依赖"
echo "======================================"

apt install -y \
    libxrender1 \
    libfontconfig1 \
    libx11-6 \
    libxext6 \
    libx11-xcb1 \
    libxcb1 \
    libxtst6 \
    libxrandr2 \
    libxcursor1 \
    libxi6

# ==============================
# 安装 wkhtmltopdf
# ==============================
echo "======================================"
echo "[5/5] 安装 wkhtmltopdf"
echo "======================================"

cd /tmp

WKHTML="wkhtmltox_0.12.6.1-3.jammy_amd64.deb"

if [ ! -f "$WKHTML" ]; then
    wget "https://ghfast.top/https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/$WKHTML"
fi

dpkg -i "$WKHTML" || true
apt --fix-broken install -y

# ==============================
# 中文字体
# ==============================
echo "安装中文字体"

apt install -y \
    fonts-wqy-zenhei \
    fonts-wqy-microhei \
    xfonts-wqy

# ==============================
# 完成
# ==============================
echo ""
echo "======================================"
echo " Odoo 环境安装完成 "
echo "======================================"
echo ""
echo "PostgreSQL 用户:"
echo "用户名: odoo"
echo "密码: 已使用安装时输入的密码"
echo ""
echo "wkhtmltopdf 版本:"

wkhtmltopdf --version
