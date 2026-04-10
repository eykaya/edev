#!/usr/bin/env bash
# abap-mcp-unified kurulum scripti
# Kullanim: bash tools/setup-mcp.sh

set -e

echo "=== abap-mcp-unified kurulum basliyor ==="

# Submodule guncelle
echo "[1/3] Submodule guncelleniyor..."
git submodule update --init tools/abap-mcp-unified

# Build
echo "[2/3] npm install + build yapiliyor..."
cd tools/abap-mcp-unified
npm install
npm run build
cd ../..

# settings.json kontrol
SETTINGS="$HOME/.claude/settings.json"
MCP_PATH="C:/VsCodeWorkspace/edev/tools/abap-mcp-unified/dist/index.js"

echo "[3/3] Kurulum tamamlandi!"
echo ""
echo "Claude settings.json dosyasina asagidaki mcpServers yapisini ekleyin:"
echo "  Path: $SETTINGS"
echo ""
cat << 'EOF'
  "mcpServers": {
    "sap-adt": {
      "command": "node",
      "args": ["C:/VsCodeWorkspace/edev/tools/abap-mcp-unified/dist/index.js"],
      "env": {
        "SAP_URL": "http://SAPSUNUCU:8000/",
        "SAP_USER": "KULLANICI",
        "SAP_PASSWORD": "SIFRE",
        "SAP_CLIENT": "100",
        "SAP_LANGUAGE": "TR"
      }
    }
  }
EOF
