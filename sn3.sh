#!/bin/bash

# Root သို့မဟုတ် sudo ဖြင့် Run ရန် စစ်ဆေးခြင်း
if [ "$EUID" -ne 0 ]; then
  echo "⚠️ ကျေးဇူးပြု၍ ဤ script ကို sudo ဖြင့် (သို့မဟုတ် root အဖြစ်) run ပါ။"
  exit 1
fi

echo "========================================"
echo "         SN3 Cloudflare Tunnel          "
echo "========================================"

# Token တောင်းခံခြင်း
read -p "Cloudflare Tunnel Token ထည့်ပါ (ey... ဖြင့်စသော): " TUNNEL_TOKEN

if [ -z "$TUNNEL_TOKEN" ]; then
  echo "❌ Error: Token ထည့်ရန် လိုအပ်ပါသည်။"
  exit 1
fi

echo "----------------------------------------"
echo "1. cloudflared ကို ထည့်သွင်းနေပါသည်..."
echo "----------------------------------------"

# Architecture စစ်ဆေးခြင်း
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    CLOUDFLARED_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    CLOUDFLARED_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64"
else
    echo "❌ Unsupported architecture: $ARCH"
    exit 1
fi

curl -L --output /usr/local/bin/cloudflared "$CLOUDFLARED_URL"
chmod +x /usr/local/bin/cloudflared

echo "----------------------------------------"
echo "2. Tunnel ကို Service အဖြစ် ချိတ်ဆက်နေပါသည်..."
echo "----------------------------------------"

# Service အဟောင်းရှိလျှင် ရှင်းလင်းခြင်း
cloudflared service uninstall 2>/dev/null

# Service အဖြစ် install လုပ်ခြင်း
cloudflared service install "$TUNNEL_TOKEN"

echo "----------------------------------------"
echo "3. Service ကို စတင်နေပါသည်..."
echo "----------------------------------------"

systemctl daemon-reload
systemctl enable cloudflared
systemctl restart cloudflared

echo "----------------------------------------"
echo "✨ SN3 Tunnel အောင်မြင်စွာ ချိတ်ဆက်ပြီးပါပြီ! ✨"
echo "အခြေအနေကို စစ်ဆေးရန်: sudo systemctl status cloudflared"
echo "========================================"
