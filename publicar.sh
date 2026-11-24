#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
command -v gh >/dev/null || { echo "Instala GitHub CLI: https://cli.github.com/"; exit 1; }
command -v git >/dev/null || { echo "Instala Git"; exit 1; }
gh auth status >/dev/null 2>&1 || gh auth login
owner=$(gh api user --jq .login)
repo="${owner}/promopy-hci"
if gh repo view "$repo" >/dev/null 2>&1; then
  echo "El repositorio $repo ya existe; no se modificará automáticamente."; exit 1
fi
if [ -e .git ]; then echo "Esta carpeta ya es un repositorio; no se modificará automáticamente."; exit 1; fi
read -r -p "Se publicarán el portafolio y los anexos en $repo (público). ¿Continuar? [s/N] " answer
[[ "$answer" =~ ^[sS]$ ]] || exit 0
python3 - "$owner" <<'PY2'
from pathlib import Path
import sys
p=Path('README.md');p.write_text(p.read_text().replace('facu18xk.github.io',sys.argv[1]+'.github.io').replace('URL prevista, pendiente de publicación','GitHub Pages').replace('URL prevista','GitHub Pages'))
PY2
git init -b main
git add .
git commit -m "Publicar portafolio HCI de PromoPY"
gh repo create "$repo" --public --source=. --remote=origin --push
if ! gh api --method POST "repos/$repo/pages" -f 'source[branch]=main' -f 'source[path]=/' >/dev/null; then
  echo "Repositorio creado. Activa Pages en https://github.com/$repo/settings/pages (main, / root)."; exit 1
fi
echo "Pages solicitado: https://$owner.github.io/promopy-hci/"
echo "Demo: https://$owner.github.io/promopy-hci/demo/"
echo "Comprueba el despliegue en https://github.com/$repo/actions"
