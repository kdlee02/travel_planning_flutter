# AI Travel Planner – Flutter + FastAPI

```
flutter/
├── backend/          ← FastAPI server (Python)
│   ├── api.py
│   ├── .env          ← put your GEMINI_API_KEY here
│   └── requirements.txt
└── frontend/         ← Flutter app (Dart)
    ├── pubspec.yaml
    └── lib/
        ├── main.dart
        ├── models/travel_state.dart
        ├── services/api_service.dart
        ├── screens/chat_screen.dart
        └── widgets/
            ├── chat_bubble.dart
            └── info_drawer.dart
```

---

## 1. Install Flutter

```bash
# macOS – easiest via homebrew
brew install --cask flutter

# Verify
flutter doctor
```

`flutter doctor` will tell you if Xcode (iOS) or Android Studio (Android) need
any extra setup. For web you just need Chrome.

---

## 2. Start the backend

```bash
cd flutter/backend

# One-time: install Python deps (use the same venv as the rest of the project)
pip install -r requirements.txt

# Fill in your key
echo "GEMINI_API_KEY=AIza..." > .env

# Run
uvicorn api:app --reload --port 8000
```

The server will be at http://localhost:8000.
Interactive docs: http://localhost:8000/docs

---

## 3. Run the Flutter app

```bash
cd flutter/frontend

# One-time: fetch Dart packages
flutter pub get

# Run on Chrome (easiest for local dev)
flutter run -d chrome

# Run on iOS simulator (needs Xcode)
flutter run -d ios

# Run on Android emulator (needs Android Studio)
# NOTE: change _base in lib/services/api_service.dart to
#       'http://10.0.2.2:8000' for Android emulator
flutter run -d android
```

---

## Notes

- The Gemini API key is **baked into the backend** – the Flutter app never sees it.
- `graph.py` and `state.py` are imported from the parent `ai_agent_travel/`
  directory via `sys.path` – no duplication needed.
- To deploy later: containerise `backend/` with Docker and host on Cloud Run /
  Railway / Fly.io; build the Flutter app with `flutter build web` or
  `flutter build apk`.
