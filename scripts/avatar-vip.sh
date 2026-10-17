#!/usr/bin/env bash
# Genera un SVG con la foto de perfil de GitHub recortada en círculo y un marco dorado tipo VIP.
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
      <stop offset="0" stop-color="#fff3c4"/>
      <stop offset=".22" stop-color="#e6b93a"/>
      <stop offset=".45" stop-color="#8f6512"/>
      <stop offset=".62" stop-color="#f7d774"/>
      <stop offset=".82" stop-color="#b3801c"/>
      <stop offset="1" stop-color="#fff0b0"/>
    </linearGradient>
    <radialGradient id="glow" cx=".5" cy=".5" r=".5">
      <stop offset=".78" stop-color="#f5c542" stop-opacity=".55"/>
      <stop offset="1" stop-color="#f5c542" stop-opacity="0"/>
    </radialGradient>
    <clipPath id="photo"><circle cx="120" cy="120" r="94"/></clipPath>
  </defs>
  <circle cx="120" cy="120" r="120" fill="url(#glow)"/>
  <circle cx="120" cy="120" r="108" fill="url(#gold)"/>
  <circle cx="120" cy="120" r="99" fill="#1b1505"/>
  <circle cx="120" cy="120" r="97" fill="url(#gold)"/>
  <image x="26" y="26" width="188" height="188" clip-path="url(#photo)" preserveAspectRatio="xMidYMid slice" xlink:href="data:${mime};base64,${b64}"/>
  <g transform="translate(190 190)">
    <circle r="22" fill="url(#gold)" stroke="#1b1505" stroke-width="2.5"/>
    <path fill="#1b1505" d="M0-12l3.5 7.6 8.2.9-6.1 5.6 1.7 8.1L0 6.1l-7.3 4.1 1.7-8.1-6.1-5.6 8.2-.9z"/>
  </g>
</svg>
EOF

echo "Avatar generado en $out ($mime)"
