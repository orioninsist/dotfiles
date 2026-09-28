#!/usr/bin/env bash

LANGUAGE="${1:-tr}"
PROJECT="/home/murat/Media/6-Project/whisper"
PYTHON="$PROJECT/.venv/bin/python"

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/whisper-type"
PID_FILE="$STATE_DIR/arecord.pid"
RAW="$STATE_DIR/recording.wav"
CLEAN="$STATE_DIR/clean.wav"
LANG_FILE="$STATE_DIR/language"

mkdir -p "$STATE_DIR"

notify() {
    notify-send -a "Whisper" -t 2500 "$1" "$2" 2>/dev/null || true
}

# İkinci basış: mevcut kaydı durdur.
if [[ -f "$PID_FILE" ]]; then
    PID="$(cat "$PID_FILE" 2>/dev/null || true)"

    if [[ "$PID" =~ ^[0-9]+$ ]] && kill -0 "$PID" 2>/dev/null; then
        LANGUAGE="$(cat "$LANG_FILE" 2>/dev/null || printf '%s' "$LANGUAGE")"

        kill -INT "$PID" 2>/dev/null || true

        # arecord'un WAV başlığını düzgün kapatmasını bekle.
        for _ in {1..30}; do
            kill -0 "$PID" 2>/dev/null || break
            sleep 0.1
        done

        rm -f "$PID_FILE" "$LANG_FILE"

        notify "⏳ Whisper" "Yazıya dönüştürülüyor..."

        ffmpeg \
            -y \
            -hide_banner \
            -loglevel error \
            -i "$RAW" \
            -ac 1 \
            -ar 16000 \
            -af "highpass=f=80,lowpass=f=8000,loudnorm=I=-18:TP=-3:LRA=7" \
            "$CLEAN" || {
                notify "Whisper hatası" "Ses işlenemedi."
                exit 1
            }

        TEXT="$(
            "$PYTHON" - "$CLEAN" "$LANGUAGE" <<'PY'
import sys
import whisper

audio = sys.argv[1]
language = sys.argv[2]

model = whisper.load_model("small")

result = model.transcribe(
    audio,
    language=language,
    task="transcribe",
    fp16=False,
    temperature=0,
)

print(result["text"].strip())
PY
        )"

        rm -f "$RAW" "$CLEAN"

        if [[ -n "$TEXT" ]]; then
            wtype -- "$TEXT"
            notify "✓ Whisper" "Metin yazıldı."
        else
            notify "Whisper" "Konuşma algılanmadı."
        fi

        exit 0
    fi

    # Eski/stale PID dosyası.
    rm -f "$PID_FILE" "$LANG_FILE" "$RAW" "$CLEAN"
fi

# İlk basış: kaydı başlat.
rm -f "$RAW" "$CLEAN"

arecord \
    -q \
    -D hw:0,0 \
    -f S16_LE \
    -r 48000 \
    -c 2 \
    "$RAW" &

PID=$!
printf '%s\n' "$PID" > "$PID_FILE"
printf '%s\n' "$LANGUAGE" > "$LANG_FILE"

sleep 0.15

if ! kill -0 "$PID" 2>/dev/null; then
    rm -f "$PID_FILE" "$LANG_FILE"
    notify "Whisper hatası" "Mikrofon kaydı başlatılamadı."
    exit 1
fi

notify "🎙 Whisper" "Kayıt başladı — bitirmek için tekrar Super+I"
