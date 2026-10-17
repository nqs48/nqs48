#!/usr/bin/env bash
# Genera un SVG con la foto de perfil de GitHub recortada en círculo y un aro dorado delgado.
# Uso: scripts/avatar-vip.sh <usuario-github> <archivo-salida.svg>
set -euo pipefail

user="${1:?Falta el usuario de GitHub}"
out="${2:?Falta el archivo de salida}"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

curl -fsSL "https://github.com/${user}.png?size=400" -o "$tmp"

mime="$(file -b --mime-type "$tmp")"
case "$mime" in
  image/jpeg | image/png) ;;
  *) echo "Formato de avatar inesperado: $mime" >&2; exit 1 ;;
esac

b64="$(base64 < "$tmp" | tr -d '\n')"

cat > "$out" <<EOF
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="240" height="240" viewBox="0 0 240 240">
  <title>${user}</title>
  <defs>
    <linearGradient id="gold" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#e9d38f"/>
      <stop offset=".5" stop-color="#c49b3c"/>
      <stop offset="1" stop-color="#e2c675"/>
    </linearGradient>
    <clipPath id="photo"><circle cx="120" cy="120" r="108"/></clipPath>
  </defs>
  <circle cx="120" cy="120" r="117" fill="none" stroke="url(#gold)" stroke-width="5"/>
  <image x="12" y="12" width="216" height="216" clip-path="url(#photo)" preserveAspectRatio="xMidYMid slice" xlink:href="data:${mime};base64,${b64}"/>
</svg>
EOF

echo "Avatar generado en $out ($mime)"
