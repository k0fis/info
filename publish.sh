#!/bin/bash
# publish.sh — Publikovani clanku z k-serveru na info.kofis.eu (GitHub Pages)
#
# Pouziti:
#   ./publish.sh <slug>
#
# Priklad:
#   ./publish.sh vscode-intellij-theme
#
# Skript:
#   1. Zkopiruje slozku z /Volumes/Share/archiv/info/<slug>/ do repa
#   2. Upravi cesty v HTML (shared.css relativni, navigace pro info.kofis.eu)
#   3. Prida zaznam do DATA pole v index.html (interaktivne)
#   4. Commitne a pushne

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_BASE="/Volumes/Share/archiv/info"

SLUG="$1"

if [ -z "$SLUG" ]; then
  echo "Pouziti: $0 <slug>"
  echo ""
  echo "Dostupne clanky na k-serveru:"
  for d in "$SOURCE_BASE"/*/; do
    name=$(basename "$d")
    [ -f "$d/index.html" ] && echo "  $name"
  done
  exit 1
fi

SOURCE_DIR="$SOURCE_BASE/$SLUG"
TARGET_DIR="$SCRIPT_DIR/$SLUG"

if [ ! -d "$SOURCE_DIR" ]; then
  echo "Chyba: $SOURCE_DIR neexistuje."
  exit 1
fi

if [ ! -f "$SOURCE_DIR/index.html" ]; then
  echo "Chyba: $SOURCE_DIR/index.html nenalezen."
  exit 1
fi

# --- 1. Kopie souboru ---
echo "[1/4] Kopiruju $SLUG..."
mkdir -p "$TARGET_DIR"
cp -R "$SOURCE_DIR"/* "$TARGET_DIR"/

# --- 2. Uprava cest v HTML ---
echo "[2/4] Upravuju cesty v index.html..."

# shared.css: /shared.css -> ../shared.css
sed -i '' 's|href="/shared.css"|href="../shared.css"|g' "$TARGET_DIR/index.html"

# Navigace: nahradit k-server breadcrumb
sed -i '' 's|<nav class="site-nav"><a href="/">k-server</a><span class="sep">/</span><a href="/info/">info</a><span class="sep">/</span>|<nav class="site-nav"><a href="../">info</a><span class="sep">/</span>|g' "$TARGET_DIR/index.html"

# Footer: nahradit k-server footer
sed -i '' 's|<nav class="site-footer">.*</nav>|<nav class="site-footer"><a href="../">info.kofis.eu</a></nav>|g' "$TARGET_DIR/index.html"

# Title: nahradit "k-server" za "info.kofis.eu"
sed -i '' 's| - k-server</title>| — info.kofis.eu</title>|g' "$TARGET_DIR/index.html"

# Odstranit /Volumes/Share cesty (nahradit odkazem na skript)
sed -i '' 's|/Volumes/Share/archiv/info/[^"<]*setup-|setup-|g' "$TARGET_DIR/index.html"

echo "  -> Hotovo."

# --- 3. DATA pole ---
echo "[3/4] Zaznam v index.html DATA poli..."

# Zkontrolovat jestli uz tam clanek neni
if grep -q "\"$SLUG/\"" "$SCRIPT_DIR/index.html"; then
  echo "  -> Clanek '$SLUG' uz je v DATA poli, preskakuji."
else
  echo ""
  echo "Clanek neni v index.html. Pridej ho rucne do DATA pole:"
  echo ""
  echo "  {"
  echo "    title: \"...\","
  echo "    desc: \"...\","
  echo "    tags: \"...\","
  echo "    url: \"$SLUG/\","
  echo "    icon: \"HW\","
  echo "    meta: \"...\","
  echo "    created: \"$(date +%Y-%m-%d)\""
  echo "  }"
  echo ""
  echo "Nebo spust: vi $SCRIPT_DIR/index.html"
fi

# --- 4. Git ---
echo "[4/4] Git commit & push..."
cd "$SCRIPT_DIR"
git add .
git status --short

read -p "Commitnout a pushnout? [Y/n] " -r REPLY
REPLY=${REPLY:-Y}
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
  git commit -m "publish: $SLUG"
  git push
  echo ""
  echo "=== Publikovano! ==="
  echo "URL: https://info.kofis.eu/$SLUG/"
else
  echo "Preskakuji git push. Soubory jsou staged."
fi
