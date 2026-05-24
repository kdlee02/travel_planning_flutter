#!/usr/bin/env bash
# Render Static Site build script.
#
# Render's static-site runtime is just Ubuntu + Node; it doesn't ship
# the Flutter SDK. We install it inline (cached between builds via
# Render's build cache on the `_flutter/` directory).

set -euo pipefail

# ── 1. Install Flutter (cached after first run) ──────────────────────
if [ ! -x "_flutter/bin/flutter" ]; then
  echo "==> Installing Flutter stable channel..."
  git clone https://github.com/flutter/flutter.git \
    --branch stable \
    --depth 1 \
    _flutter
else
  echo "==> Reusing cached Flutter SDK"
  git -C _flutter pull --ff-only || true
fi

export PATH="$PWD/_flutter/bin:$PATH"

flutter --version
flutter config --no-analytics

# ── 2. Resolve packages ──────────────────────────────────────────────
flutter pub get

# ── 3. Decide which API URL to bake in ───────────────────────────────
# render.yaml fills API_BASE_HOST from the backend service's public host
# (e.g. seoul-buddy-api.onrender.com). We turn it into a full URL.
# Falls back to localhost so this script still works for local testing.
if [ -n "${API_BASE_HOST:-}" ]; then
  API_BASE_URL="https://${API_BASE_HOST}"
elif [ -n "${API_BASE_URL:-}" ]; then
  API_BASE_URL="${API_BASE_URL}"
else
  API_BASE_URL="http://localhost:8000"
fi
echo "==> Building with API_BASE_URL=${API_BASE_URL}"

# ── 4. Build the web bundle ──────────────────────────────────────────
flutter build web \
  --release \
  --dart-define=API_BASE_URL="${API_BASE_URL}"

echo "==> Done. Output: build/web"
