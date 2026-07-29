#!/usr/bin/env bash
set -euo pipefail

YIUOS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GENERATED="${YIUOS_ROOT}/legacy/hinoki/generated"

case "${GENERATED}" in
  */legacy/hinoki/generated) ;;
  *)
    echo "Refusing to prepare assets outside legacy/hinoki/generated" >&2
    exit 1
    ;;
esac

command -v convert >/dev/null 2>&1 || command -v magick >/dev/null 2>&1 || {
  echo "ImageMagick is required to prepare the hinoki boot animation." >&2
  exit 1
}
command -v zip >/dev/null 2>&1 || {
  echo "zip is required to prepare the hinoki boot animation." >&2
  exit 1
}

find "${GENERATED}" -mindepth 1 -maxdepth 1 ! -name .gitignore -exec rm -rf -- {} +

OVERLAY="${GENERATED}/overlay/frameworks/base/core/res/res/drawable-nodpi"
mkdir -p "${OVERLAY}"
cp \
  "${YIUOS_ROOT}/overlay/common/frameworks/base/core/res/res/drawable-nodpi/default_wallpaper.png" \
  "${OVERLAY}/default_wallpaper.png"

WORK="$(mktemp -d)"
trap 'rm -rf -- "${WORK}"' EXIT
tar -xf "${YIUOS_ROOT}/bootanimation/bootanimation.tar" -C "${WORK}"

if command -v magick >/dev/null 2>&1; then
  while IFS= read -r -d '' frame; do
    magick "${frame}" -resize 720x240 -colors 256 "${frame}"
  done < <(find "${WORK}" -name '*.png' -print0)
else
  find "${WORK}" -name '*.png' -exec convert {} -resize 720x240 -colors 256 {} \;
fi

{
  echo "720 240 60"
  cat "${YIUOS_ROOT}/bootanimation/desc.txt"
} > "${WORK}/desc.txt"

(
  cd "${WORK}"
  zip -0 -q -r "${GENERATED}/bootanimation.zip" desc.txt part0 part1 part2
)

echo "Prepared hinoki wallpaper and boot animation in ${GENERATED}"
