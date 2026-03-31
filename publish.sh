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
  # Zkusit vytahnout title z <h1> v clanku
  DEFAULT_TITLE=$(sed -n 's|.*<h1>\(.*\)</h1>.*|\1|p' "$TARGET_DIR/index.html" | head -1 | sed 's/&mdash;/—/g; s/&amp;/\&/g')

  echo ""
  echo "  Pridavam clanek do DATA pole v index.html."
  echo "  (Enter = pouzit vychozi hodnotu v zavorkach)"
  echo ""

  read -p "  Title [$DEFAULT_TITLE]: " -r INPUT_TITLE
  TITLE="${INPUT_TITLE:-$DEFAULT_TITLE}"

  read -p "  Desc: " -r DESC

  read -p "  Tags: " -r TAGS

  read -p "  Icon [HW] (CBZ/SRV/AI/HW): " -r INPUT_ICON
  ICON="${INPUT_ICON:-HW}"

  read -p "  Meta: " -r META

  CREATED=$(date +%Y-%m-%d)

  # Escapovat uvozovky v hodnotach
  TITLE=$(echo "$TITLE" | sed 's/"/\\"/g')
  DESC=$(echo "$DESC" | sed 's/"/\\"/g')
  TAGS=$(echo "$TAGS" | sed 's/"/\\"/g')
  META=$(echo "$META" | sed 's/"/\\"/g')

  # Vlozit novy zaznam pred ];  pomoci python (spolehlivejsi nez sed)
  python3 -c "
import sys

path = sys.argv[1]
with open(path, 'r') as f:
    content = f.read()

entry = '''  {
    title: \"$TITLE\",
    desc: \"$DESC\",
    tags: \"$TAGS\",
    url: \"$SLUG/\",
    icon: \"$ICON\",
    meta: \"$META\",
    created: \"$CREATED\"
  }'''

content = content.replace('\n];\n', ',\n' + entry + '\n];\n', 1)

with open(path, 'w') as f:
    f.write(content)
" "$SCRIPT_DIR/index.html"

  echo "  -> Pridano do DATA pole."
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
