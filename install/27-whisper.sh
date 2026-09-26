#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT="$HOME/Media/6-Project/whisper"
REPO="https://github.com/orioninsist/whisper.git"
PIN="8609812"
PYTHON_VERSION="3.12"
MODEL="small"

command -v uv >/dev/null
command -v git >/dev/null

PROJECTS_ROOT="$HOME/Media/6-Project"
mkdir -p "$PROJECTS_ROOT"

if [[ ! -e "$PROJECT" ]]; then
    echo "Cloning Whisper..."
    git clone "$REPO" "$PROJECT"
    git -C "$PROJECT" checkout "$PIN"
elif [[ ! -d "$PROJECT/.git" ]]; then
    echo "$PROJECT exists but is not a Git checkout." >&2
    exit 1
else
    echo "Preserving existing Whisper checkout at $PROJECT"
fi

echo "Installing Python $PYTHON_VERSION with uv..."
uv python install "$PYTHON_VERSION"

PYTHON="$HOME/.local/bin/python3.12"
[[ -x "$PYTHON" ]] || {
    echo "Python 3.12 executable not found at $PYTHON" >&2
    exit 1
}

rebuild=0
if [[ ! -x "$PROJECT/.venv/bin/python" ]]; then
    rebuild=1
elif ! "$PROJECT/.venv/bin/python" - <<'PY' >/dev/null 2>&1
import torch
import whisper
assert torch.version.cuda is None
try:
    import triton
except ImportError:
    pass
else:
    raise SystemExit(1)
PY
then
    rebuild=1
fi

if (( rebuild )); then
    echo "Building CPU-only Whisper environment..."
    rm -rf "$PROJECT/.venv"

    UV_LINK_MODE=copy uv venv \
        --python "$PYTHON" \
        "$PROJECT/.venv"

    UV_LINK_MODE=copy uv pip install \
        --python "$PROJECT/.venv/bin/python" \
        torch==2.14.0+cpu \
        --index-url https://download.pytorch.org/whl/cpu

    UV_LINK_MODE=copy uv pip install \
        --python "$PROJECT/.venv/bin/python" \
        more-itertools==11.1.0 \
        numba==0.67.0 \
        numpy==2.5.3 \
        tiktoken==0.14.0 \
        tqdm==4.70.1

    UV_LINK_MODE=copy uv pip install \
        --python "$PROJECT/.venv/bin/python" \
        --no-deps -e "$PROJECT"
else
    echo "CPU-only Whisper environment already valid."
fi

echo "Ensuring Whisper $MODEL model is cached..."
"$PROJECT/.venv/bin/python" - "$MODEL" <<'PY'
import sys
import whisper

model = sys.argv[1]
whisper.load_model(model)
print(f"Whisper model ready: {model}")
PY

echo "Verifying CPU-only Whisper..."
"$PROJECT/.venv/bin/python" - <<'PY'
import torch
import whisper

assert torch.version.cuda is None, torch.version.cuda
assert not torch.cuda.is_available()

try:
    import triton
except ImportError:
    pass
else:
    raise SystemExit("Triton unexpectedly installed")

print("Whisper CPU environment ready")
print("Torch:", torch.__version__)
print("Whisper:", whisper.__file__)
PY
