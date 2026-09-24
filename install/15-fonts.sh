#!/usr/bin/env bash
set -Eeuo pipefail

release_api="https://api.github.com/repos/googlefonts/googlesans-code/releases/latest"
font_dir="$HOME/.local/share/fonts/GoogleSansCode"
marker="$font_dir/.release"

if fc-match -f '%{family}\n' "Google Sans Code" 2>/dev/null | head -1 | grep -Fxq "Google Sans Code"; then
  echo "Google Sans Code already installed."
  exit 0
fi

command -v curl >/dev/null || { echo "curl is required" >&2; exit 1; }
command -v python3 >/dev/null || { echo "python3 is required" >&2; exit 1; }

echo "Resolving latest official Google Sans Code release..."
release_json="$(curl -fsSL --retry 3 --retry-delay 2 "$release_api")"
readarray -t release < <(printf '%s' "$release_json" | python3 -c '
import json,sys
r=json.load(sys.stdin)
a=next(x for x in r["assets"] if x["name"].startswith("GoogleSansCode-v") and x["name"].endswith(".zip"))
print(r["tag_name"])
print(a["browser_download_url"])
print((a.get("digest") or "").removeprefix("sha256:"))
')
tag="${release[0]}"
url="${release[1]}"
expected_sha="${release[2]}"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
archive="$tmp/GoogleSansCode.zip"

echo "Downloading Google Sans Code $tag from googlefonts/googlesans-code..."
curl -fL --retry 3 --retry-delay 2 -o "$archive" "$url"

if [[ -n "$expected_sha" ]]; then
  actual_sha="$(sha256sum "$archive" | awk '{print $1}')"
  [[ "$actual_sha" == "$expected_sha" ]] || {
    echo "Google Sans Code release checksum mismatch" >&2
    exit 1
  }
fi

python3 - "$archive" "$tmp/extract" <<'PY'
import sys, zipfile
archive, out = sys.argv[1:3]
with zipfile.ZipFile(archive) as z:
    z.extractall(out)
PY

regular="$(find "$tmp/extract" -type f -name 'GoogleSansCode[[]MONO,wght].ttf' -print -quit)"
italic="$(find "$tmp/extract" -type f -name 'GoogleSansCode-Italic[[]MONO,wght].ttf' -print -quit)"
[[ -n "$regular" && -n "$italic" ]] || {
  echo "Expected Google Sans Code variable fonts were not found in release archive" >&2
  exit 1
}

mkdir -p "$font_dir"
install -m 0644 "$regular" "$font_dir/GoogleSansCode[MONO,wght].ttf"
install -m 0644 "$italic" "$font_dir/GoogleSansCode-Italic[MONO,wght].ttf"
printf '%s\n' "$tag" > "$marker"
fc-cache -f "$font_dir"

fc-match -f '%{family}\n' "Google Sans Code" | head -1 | grep -Fxq "Google Sans Code" || {
  echo "Google Sans Code fontconfig verification failed" >&2
  exit 1
}
echo "Google Sans Code $tag installed."
