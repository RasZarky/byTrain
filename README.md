<p align="center">
  <img src="assets/images/logo.png" width="128" alt="ByTrain Logo">
</p>

# ByTrain 🚆 — Pakistan Railways Timetable & Journey Planner

ByTrain is a modern, high-performance, and beautifully crafted **Pakistan Railways timetable & station information app** — static train schedules, routes, and station details with no live GPS tracking, no maps, and no backend. Optimized with declarative state management and rich animations, ByTrain delivers a premium, native-feeling utility experience that works fully offline.

The application follows the **Feature-First Clean Architecture** methodology and is strictly built upon industry-standard Flutter practices.

> 📖 **Full feature walkthrough:** see [FEATURES.md](FEATURES.md)

---

## ✨ Key Features

### 🔍 Unified Search (Trains · Stations · Routes)
*   **One search box** for train names/numbers, station names/codes, and route phrases like *"Lahore to Karachi"*.
*   **Everything visible by default** — the full station, route, and train lists with no query required.
*   **Content filters** (`All · Trains · Stations · Routes`) and **class filters** (`All · Express · Regional · Local`).
*   **🎙️ Voice input** — tap the mic to search by speaking, with a clear listening on/off state.
*   **Live page results** — stations, routes, and trains filter in place as you type (no separate overlay).

### 📅 Journey Planner
*   **Real station pickers** over the 142-station dataset with one-tap route swapping.
*   **Temporal planning** — date & time selectors with "Today"/"Tomorrow" labels and a Now shortcut.
*   **Preferences** — *Fastest Route* and *Direct Only*, which move matching journeys to the top of the results.
*   **Save journeys** — bookmark results; they persist on-device and appear on Home (with SAVED tags on the cards).

### 🏠 Personal Home Board
*   **Upcoming Journeys only** — shows exactly what you saved, sorted by departure time, with pull-to-refresh and auto-reload.
*   **Honest empty state** — a clear call-to-action to plan your first journey instead of fake content.

### 🌱 First Launch
*   **Animated splash** → a 5-slide intro that appears **only on the very first launch** (persisted on-device); every later launch goes straight to Home.

### 🚄 Train, Route & Station Details
*   **Train Details** — schedule, computed duration, train type, route, and operational status (no fabricated live data).
*   **Route Details** — full stop-by-stop timetable; tap any stop for a station card with its calling trains.
*   **Station Details** — official PR code, city/province, and all services calling there with arrival/departure times.

### 📦 Real Data, No Backend
*   A curated snapshot of **13 trains · 26 services · 142 stations** bundled in the app (`assets/data/pakrail.json`), sourced from public timetables and official station codes — works fully offline.
*   **Silent background refresh** — when the app is opened with internet access, it quietly re-fetches the sources (at most once per day, no UI, no alerts) and uses the fresh copy on-device; if anything fails, the bundled dataset stays available.
*   Regenerable manually any time via `dart run tool/import_pakrail.dart` (shares the exact same import code as the background refresh).

---

## 🛠 Tech Stack

ByTrain is built with premium libraries from the Flutter/Dart ecosystem:

*   **Framework**: [Flutter](https://flutter.dev) (Dart SDK `^3.10.7`)
*   **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) & [bloc](https://pub.dev/packages/bloc) (following clean event/state decoupling)
*   **Navigation**: [go_router](https://pub.dev/packages/go_router) (declarative, supporting deep links and stateful shell branches)
*   **Voice Search**: [speech_to_text](https://pub.dev/packages/speech_to_text) (voice input on the Search page)
*   **Persistence**: [shared_preferences](https://pub.dev/packages/shared_preferences) (on-device saved journeys, onboarding flag, refreshed dataset cache)
*   **Networking**: [http](https://pub.dev/packages/http) (background dataset refresh from the public sources)
*   **Image Handling**: [cached_network_image](https://pub.dev/packages/cached_network_image) (disk caching, loading progress, and error state placeholders)
*   **Utilities**: [equatable](https://pub.dev/packages/equatable) (for zero-boilerplate value comparison), [intl](https://pub.dev/packages/intl) (date formatting)
*   **Typography**: [google_fonts](https://pub.dev/packages/google_fonts)

---

## 🏗 Project Architecture

ByTrain implements **Feature-First Clean Architecture**, organizing source directories by independent business modules. This makes the code exceptionally clean, highly modular, testable, and effortless to scale.

```text
lib/
├── core/                       # Shared app configurations & global modules
│   ├── data/                   # Dataset repository, saved journeys, and the silent background refresh
│   │   └── refresh/            # Shared import pipeline (tool + in-app refresh) and DatasetRefresher
│   ├── router/                 # GoRouter declarations & deep-link parameters
│   ├── theme/                  # Theme configurations (Colors, Custom Typography, Dimensions)
│   │   └── bloc/               # Global appearance & mode-switching BLoC
│   └── widgets/                # Reusable cross-feature UI components (Buttons, CustomCards, etc.)
├── features/                   # Independent modular features
│   ├── splash/                 # Animated intro that routes to onboarding (first launch) or Home
│   ├── onboarding/             # 5-slide intro shown only on the first launch
│   ├── home/                   # Personal board of saved, upcoming journeys
│   ├── search/                 # Unified train/station/route search with voice input
│   ├── train/                  # Train schedules, route timelines, and station sheets
│   ├── journey_planner/        # Journey search, preference ordering, and saved journeys
│   ├── station/                # Station details and calling trains
│   └── settings/               # About, support, and legal entries
└── main.dart                   # Root assembly, MultiBlocProviders, startup configs, silent refresh trigger
```

---

## 🚀 Installation & Running

### Prerequisites

*   Flutter SDK installed (`^3.10.7` or later).
*   An Android / iOS device, emulator, or browser. No API keys, backend, or network required — the dataset is bundled.

### Step 1: Clone & Build

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/RasZarky/by_train.git
    cd by_train
    ```
2.  **Retrieve pub dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Launch the app**:
    ```bash
    flutter run
    ```

---

## 🆕 Recent Updates
*   **Silent background refresh**: the app quietly updates its timetable from the public sources when opened online, keeping the bundled dataset as the offline fallback.
*   **Onboarding on first launch only**: the 5-slide intro now shows once; returning users go straight to Home.
*   **Real data everywhere**: every screen (Home, Search, Planner, Train/Route/Station Details) runs on the bundled public dataset — no simulated content.
*   **Unified search**: trains, stations, and routes in one box with content filters and voice input.
*   **Personal Home**: shows only your saved upcoming journeys, with an honest empty state.
*   **Journey Planner**: real station pickers, preference-driven result ordering, and bookmark-to-save with on-card SAVED indicators.
*   **Removed**: live GPS tracking, maps, fabricated statuses, and the search suggestions overlay — the app is schedule-only by design.

---

## 👨‍💻 Development Team

This application was engineered with care by:

*   **Abdul Razak Abubakari** (Mobile Developer)
    *   📧 Email: [ubdoolrazak@gmail.com](mailto:ubdoolrazak@gmail.com)
    *   🔗 GitHub: [RasZarky](https://github.com/RasZarky)
*   **Belal Mohamed** (Mobile Developer)
    *   📧 Email: [dixen.bugs@gmail.com](mailto:dixen.bugs@gmail.com)

---

## 🏢 Organization & Support

ByTrain is an official open-source endeavor supported by **Apexiums Technologies**.

*   🌐 **Website**: [apexiumstechnologies.com](https://apexiumstechnologies.com/)
*   📧 **Support**: [ammanm0789@gmail.com](mailto:ammanm0789@gmail.com)
*   📝 **License**: Distributed under Apexiums internal copyrights. See Settings → About within the application for more.
