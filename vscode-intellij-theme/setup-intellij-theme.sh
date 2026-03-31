#!/bin/bash
# setup-intellij-theme.sh
# Instalace IntelliJ IDEA theme + JetBrains Mono fontu pro VSCode / VSCodium na macOS
# Pokud jsou nainstalovane oba editory, nastavi oba.
# Pouziti: bash setup-intellij-theme.sh

set -e

EXTENSION_ID="OleksandrHavrysh.vscode-intellij-theme"

# --- Detekce editoru ---
EDITORS=()
if command -v code &>/dev/null; then
  EDITORS+=("code|VSCode|$HOME/Library/Application Support/Code/User")
fi
if command -v codium &>/dev/null; then
  EDITORS+=("codium|VSCodium|$HOME/Library/Application Support/VSCodium/User")
fi

if [ ${#EDITORS[@]} -eq 0 ]; then
  echo "Chyba: Nebyl nalezen ani 'code' ani 'codium' v PATH."
  echo ""
  echo "VSCode:   https://code.visualstudio.com"
  echo "VSCodium: https://vscodium.com  (brew install --cask vscodium)"
  exit 1
fi

NAMES=""
for e in "${EDITORS[@]}"; do
  IFS='|' read -r _ name _ <<< "$e"
  NAMES="$NAMES $name"
done
echo "=== IntelliJ IDEA theme setup pro:$NAMES ==="
echo ""

# --- 1. Instalace JetBrains Mono fontu (spolecna pro oba) ---
echo "[1/3] JetBrains Mono font..."

if fc-list 2>/dev/null | grep -qi "JetBrains Mono"; then
  echo "  -> Uz nainstalovany, preskakuji."
else
  FONT_VERSION="2.304"
  FONT_URL="https://github.com/JetBrains/JetBrainsMono/releases/download/v${FONT_VERSION}/JetBrainsMono-${FONT_VERSION}.zip"
  TMPDIR_FONT=$(mktemp -d)

  echo "  -> Stahuji JetBrains Mono v${FONT_VERSION}..."
  curl -fsSL -o "$TMPDIR_FONT/JetBrainsMono.zip" "$FONT_URL"
  unzip -qo "$TMPDIR_FONT/JetBrainsMono.zip" -d "$TMPDIR_FONT/JetBrainsMono"
  cp "$TMPDIR_FONT/JetBrainsMono/fonts/ttf/JetBrainsMono-"*.ttf ~/Library/Fonts/
  rm -rf "$TMPDIR_FONT"
  echo "  -> Nainstalovano do ~/Library/Fonts/"
fi

# --- Funkce: instalace extension pro dany editor ---
install_extension() {
  local cli="$1" name="$2"

  echo ""
  echo "--- $name ---"
  echo "[2/3] IntelliJ IDEA Islands Theme extension..."

  if $cli --list-extensions 2>/dev/null | grep -qi "$EXTENSION_ID"; then
    echo "  -> Uz nainstalovan, preskakuji."
    return
  fi

  if [ "$cli" = "code" ]; then
    $cli --install-extension "$EXTENSION_ID" --force 2>/dev/null
    echo "  -> Nainstalovano z marketplace."
  else
    echo "  -> VSCodium: stahuji .vsix z Open VSX..."
    VSIX_URL="https://open-vsx.org/api/OleksandrHavrysh/vscode-intellij-theme/latest/file/OleksandrHavrysh.vscode-intellij-theme-latest.vsix"
    TMPVSIX=$(mktemp -d)

    if curl -fsSL -o "$TMPVSIX/theme.vsix" "$VSIX_URL" 2>/dev/null; then
      $cli --install-extension "$TMPVSIX/theme.vsix" --force 2>/dev/null
      echo "  -> Nainstalovano z Open VSX."
    else
      echo "  -> Open VSX nema tuto extensi."
      echo "  -> Zkousim stahnout z VS Marketplace primo..."
      VSIX_MS="https://marketplace.visualstudio.com/_apis/public/gallery/publishers/OleksandrHavrysh/vsextensions/vscode-intellij-theme/latest/vspackage"
      if curl -fsSL -o "$TMPVSIX/theme.vsix" "$VSIX_MS" 2>/dev/null; then
        $cli --install-extension "$TMPVSIX/theme.vsix" --force 2>/dev/null
        echo "  -> Nainstalovano z VS Marketplace (VSIX)."
      else
        echo "  !! Nepodarilo se stahnout extensi automaticky."
        echo "  -> Rucne stahni VSIX z: https://marketplace.visualstudio.com/items?itemName=$EXTENSION_ID"
        echo "  -> Pak: $cli --install-extension cesta/k/souboru.vsix"
      fi
    fi
    rm -rf "$TMPVSIX"
  fi
}

# --- Funkce: nastaveni settings.json pro dany editor ---
apply_settings() {
  local settings_dir="$1" name="$2"
  local settings_file="$settings_dir/settings.json"

  echo "[3/3] Nastaveni theme a fontu ($name)..."
  mkdir -p "$settings_dir"

  if [ ! -f "$settings_file" ]; then
    cat > "$settings_file" << 'EOF'
{
  "workbench.colorTheme": "IntelliJ IDEA Islands Dark",
  "editor.fontFamily": "JetBrains Mono, monospace",
  "editor.fontSize": 13,
  "editor.fontLigatures": true
}
EOF
    echo "  -> Vytvoreno: $settings_file"
  else
    python3 -c "
import json, re, sys

path = sys.argv[1]
with open(path, 'r') as f:
    raw = f.read()

clean = re.sub(r'//.*$', '', raw, flags=re.MULTILINE)
clean = re.sub(r',(\s*[}\]])', r'\1', clean)

try:
    data = json.loads(clean)
except json.JSONDecodeError:
    data = {}

changed = False
updates = {
    'workbench.colorTheme': 'IntelliJ IDEA Islands Dark',
    'editor.fontFamily': 'JetBrains Mono, monospace',
    'editor.fontSize': 13,
    'editor.fontLigatures': True
}

for key, val in updates.items():
    if data.get(key) != val:
        data[key] = val
        changed = True

if changed:
    with open(path, 'w') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write('\n')
    print('  -> Aktualizovano: ' + path)
else:
    print('  -> Nastaveni uz bylo spravne.')
" "$settings_file"
  fi
}

# --- Hlavni smycka: projit vsechny nalezene editory ---
for e in "${EDITORS[@]}"; do
  IFS='|' read -r cli name settings_dir <<< "$e"
  install_extension "$cli" "$name"
  apply_settings "$settings_dir" "$name"
done

echo ""
echo "=== Hotovo! ==="
echo ""
RESTART_NAMES=""
for e in "${EDITORS[@]}"; do
  IFS='|' read -r _ name _ <<< "$e"
  RESTART_NAMES="$RESTART_NAMES $name"
done
echo "Restartuj$RESTART_NAMES pro nacteni fontu."
echo ""
echo "Dostupne varianty theme (Cmd+K Cmd+T):"
echo "  - IntelliJ IDEA Islands Dark   (vychozi)"
echo "  - IntelliJ IDEA Islands Light"
echo "  - IntelliJ IDEA Classic Dark"
