#!/usr/bin/env bash
# abap-mcp-unified kurulum scripti
# Kullanim: bash tools/setup-mcp.sh
#
# .env dosyasi varsa SAP bilgilerini otomatik okur,
# yoksa interaktif olarak sorar.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MCP_DIR="$REPO_ROOT/tools/abap-mcp-unified"
SETTINGS="$HOME/.claude/settings.json"

echo "=== abap-mcp-unified kurulum basliyor ==="

# --- [1] Submodule ---
echo "[1/4] Submodule guncelleniyor..."
cd "$REPO_ROOT"
git submodule update --init tools/abap-mcp-unified

# --- [2] Build ---
echo "[2/4] npm install + build yapiliyor..."
cd "$MCP_DIR"
npm install --silent
npm run build
cd "$REPO_ROOT"

# --- [3] SAP bilgilerini oku ---
echo "[3/4] SAP baglanti bilgileri belirleniyor..."

ENV_FILE="$REPO_ROOT/.env"
if [ -f "$ENV_FILE" ]; then
  echo "  .env dosyasi bulundu, bilgiler oradan alinacak."
  export $(grep -v '^#' "$ENV_FILE" | grep -v '^$' | xargs)
else
  echo "  .env dosyasi bulunamadi, lutfen bilgileri girin:"
  read -rp "  SAP_URL   [http://IP:8000/]: " SAP_URL
  read -rp "  SAP_USER  : " SAP_USER
  read -rsp "  SAP_PASSWORD: " SAP_PASSWORD; echo
  read -rp "  SAP_CLIENT [100]: " SAP_CLIENT
  read -rp "  SAP_LANGUAGE [TR]: " SAP_LANGUAGE
  SAP_CLIENT="${SAP_CLIENT:-100}"
  SAP_LANGUAGE="${SAP_LANGUAGE:-TR}"
fi

# Windows path (MINGW/Git Bash icin)
MCP_JS_PATH="$(echo "$MCP_DIR/dist/index.js" | sed 's|/c/|C:/|')"
WIN_SETTINGS="$(echo "$SETTINGS" | sed 's|/c/|C:/|')"

# --- [4] settings.json guncelle ---
echo "[4/4] ~/.claude/settings.json guncelleniyor..."

mkdir -p "$HOME/.claude"

# Node.js ile JSON guncelle (jq gerektirmez)
node - <<NODEJS
const fs = require('fs');
const path = '$WIN_SETTINGS';

let settings = {};
if (fs.existsSync(path)) {
  try { settings = JSON.parse(fs.readFileSync(path, 'utf8')); } catch(e) {}
}

settings.mcpServers = settings.mcpServers || {};
settings.mcpServers['sap-adt'] = {
  command: 'node',
  args: ['$MCP_JS_PATH'],
  env: {
    SAP_URL:      '${SAP_URL}',
    SAP_USER:     '${SAP_USER}',
    SAP_PASSWORD: '${SAP_PASSWORD}',
    SAP_CLIENT:   '${SAP_CLIENT}',
    SAP_LANGUAGE: '${SAP_LANGUAGE}'
  }
};

fs.writeFileSync(path, JSON.stringify(settings, null, 2));
console.log('  settings.json guncellendi: ' + path);
NODEJS

echo ""
echo "=== Kurulum tamamlandi! ==="
echo "  MCP server: $MCP_JS_PATH"
echo "  Settings  : $WIN_SETTINGS"
echo ""
echo "Claude Code'u yeniden baslatmaniz yeterli."
