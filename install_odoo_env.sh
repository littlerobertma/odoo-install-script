#!/bin/bash
# ==================================================
# Odoo 环境初始化安装脚本
# Ubuntu 22.04/24.04
# PostgreSQL + Python依赖 + wkhtmltopdf
# ==================================================

set -e

echo "======================================"
echo " 开始安装 Odoo 环境依赖"
echo "======================================"


# -----------------------------
# 1. 系统更新
# -----------------------------
echo "[1/5] 更新系统..."

sudo apt update
sudo apt upgrade -y


# -----------------------------
# 2. 安装 PostgreSQL
# -----------------------------
echo "[2/5] 安装 PostgreSQL..."

sudo apt install postgresql -y


echo "配置 PostgreSQL 用户..."

sudo -u postgres psql <<EOF

DO \$\$
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_roles WHERE rolname = 'odoo'
    ) THEN
        CREATE USER odoo WITH PASSWORD 'qweasdzxc123.';
    END IF;
END
\$\$;

ALTER USER odoo WITH SUPERUSER;

EOF


echo "PostgreSQL 配置完成"


# -----------------------------
# 3. Python环境依赖
# -----------------------------
echo "[3/5] 安装 Python 和系统依赖..."

sudo apt install -y \
python3-pip \
build-essential \
wget \
python3-dev \
python3-venv \
python3-wheel \
libxml2-dev \
libxslt-dev \
libzip-dev \
libldap2-dev \
libpq-dev \
libsasl2-dev \
python3-setuptools \
node-less \
nodejs \
npm


# -----------------------------
# 4. wkhtmltopdf依赖
# -----------------------------
echo "[4/5] 安装 wkhtmltopdf 依赖..."

sudo apt install -y \
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


# -----------------------------
# 5. 安装wkhtmltopdf
# -----------------------------
echo "[5/5] 安装 wkhtmltopdf..."


cd /tmp


if [ ! -f wkhtmltox_0.12.6.1-3.jammy_amd64.deb ]; then

wget https://ghfast.top/https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_amd64.deb

fi


sudo dpkg -i wkhtmltox_0.12.6.1-3.jammy_amd64.deb || true


sudo apt --fix-broken install -y


echo "安装中文字体..."

sudo apt install -y \
fonts-wqy-zenhei \
fonts-wqy-microhei \
xfonts-wqy


echo ""
echo "======================================"
echo " Odoo 环境安装完成"
echo "======================================"

echo ""
echo "PostgreSQL:"
echo " 用户: odoo"
echo " 密码: qweasdzxc123."
echo ""

echo "wkhtmltopdf版本:"
wkhtmltopdf --version
