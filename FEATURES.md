# ByTrain 🚆 — Feature Overview

ByTrain is a **Pakistan Railways timetable and station information app** built with Flutter. It shows static train schedules, routes, and station details — no live GPS tracking, no maps, and no backend. All data is bundled inside the app and works fully offline.

> **At a glance**
> - **13 trains** · **26 services** (UP + DN runs) · **142 stations**
> - Dataset: `assets/data/pakrail.json`, stamped `2026-08-12`, season *Summer timetable 2026 (15 Apr – 14 Oct 2026)*
> - 4 tabs: **Home · Search · Plan · Settings**
> - Requires no account, no network, and no API keys

---

## App Structure

| Screen | Purpose |
|---|---|
| Splash | Animated brand intro; auto-navigates to onboarding (first launch only) or Home |
| Onboarding | 5-slide feature introduction with Skip / Next / Get started — shown only on the very first launch |
| Home | Your saved, upcoming journeys (empty state until you save one) |
| Search | One search box for trains, stations, and routes, with filters and voice input |
| Plan (Journey Planner) | Find and save real trains between two stations for a chosen date |
| Train Details | Schedule, duration, and information for a single service |
| Route Details | Full stop-by-stop timetable for a service; tap any stop for station info |
| Station Details | Station code, city/province, and all trains calling there |
| Settings / About | Legal links, version, and team/organization info |

---

## 🏠 Home

The Home tab is your **personal journey board** — it only shows journeys you explicitly saved from the Journey Planner.

- **Upcoming Journeys** — saved journeys with departure dates in the future, sorted by departure time.
  - Each card shows the train name + number, from → to with times, departure date, and journey duration.
  - Tap a card → opens that train's detail page.
  - Tap the bookmark on a card → removes it from your saved journeys.
- **Auto-refresh** — the list reloads whenever you switch back to the Home tab, and supports pull-to-refresh.
- **Empty state** — with nothing saved (or all saved journeys departed), Home shows a friendly *"No upcoming journeys yet"* prompt with a **Plan a Journey** button straight into the planner.
- **Quick actions** — a booking-style card with **Route Planner** and **Search** shortcuts.

> Note: journeys whose departure time has already passed are filtered out automatically.

---

## 🔍 Search

One search bar that understands trains, stations, and routes — with **voice input**. Results update live in the page as you type.

### What you can search
- **Trains** — by name or number (e.g. "Karakoram", "41UP").
- **Stations** — by name or Pakistan Railways code (e.g. "Multan" or "LHR"). Tapping a result opens the Station Details page.
- **Routes** — type "**Lahore to Karachi**" (also accepts `→` or `->`) to get the real trains running that corridor, or any substring like "Karakoram" or "Multan" to surface matching routes. Tapping a route opens the train's detail page.

### Everything shown by default
With the box empty, Search shows the **full dataset**: ALL STATIONS, ALL ROUTES, and ALL TRAINS, so nothing is hidden behind a query.

### Filters
- **Content type** — `All · Trains · Stations · Routes` narrows the page to one kind of result.
- **Train class** — `All · Express · Regional · Local` appears whenever trains are visible.

### 🎙️ Voice input
Tap the **mic** icon in the search bar to search by speaking (requires the microphone permission on first use):

- **On**: the mic turns red, the bar gets a red border, and a *"Listening… tap the mic to stop"* indicator appears. Recognized words fill the search box live as you speak.
- **Off**: tapping the mic again (or typing) stops listening and returns the mic to its normal muted state.
- If voice isn't available (no speech service / permission denied), the app says so instead of faking a listening state.

---

## 🗺 Plan (Journey Planner)

Plan a trip between any two stations and save the journeys you care about.

### 1. Pick stations
Tap the departure/destination fields to open a **searchable station picker** over the real 142-station dataset (search by name or code). Use the swap button to reverse the route instantly.

### 2. Pick date & time
- Date + time pickers (with quick **Today / Tomorrow** labels).
- A **"Now"** button snaps back to the current date/time.

### 3. Travel preferences
- **Fastest Route** (on by default) — results are reordered so quicker journeys appear first.
- **Direct Only** — keeps direct, single-train journeys at the top of the list.

> When a preference is toggled, matching journeys are moved to the top of the results and the search re-runs automatically.

### 4. Results
- Real trains with real scheduled departure/arrival times for your chosen date, sorted sensibly.
- **FASTEST** tag marks the quickest option; a **SAVED** tag marks journeys you've bookmarked.
- **Bookmark any journey** (filled bookmark = saved) — it's stored on-device and appears on Home.
  - Save confirmation appears as a snackbar: *"Journey saved — view it on Home"* or *"This journey is already saved"* (deduplicated by train + departure time).

---

## 🚄 Train Details

Opened from Search, Route, Home, or Station pages. Shows only real, applicable data:

- **Header** — train name, number, and schedule imagery/gradient.
- **Operational Status** — a static card stating the service status from the timetable (e.g. Running). No live-tracking UI.
- **Journey Details** — origin → destination, scheduled departure/arrival, and the **total journey time** computed from the timetable.
- **Train Information** — Type (Express/Regional/Local), number of stops, duration, and route.
- **View Full Route** — opens the stop-by-stop timetable page.

Handles loading (spinner) and not-found (unknown train id) states honestly.

---

## 📋 Route Details

The full timetable for one service (UP or DN run):

- **Stops & Timeline** — every station in order with arrival time, departure time, and platform when published.
- **Tap any stop** → a station card (code, city/province) with the other trains calling there and their arrival/departure times at that stop; link through to the full Station Details page.

---

## 🏛 Station Details

Real station information from the dataset:

- Name, Pakistan Railways **code**, city, and province.
- **Trains through this station** — every service calling there, with its arrival/departure time at this station; tap one to open the train.

---

## ⚙️ Settings & About

- **About ByTrain** — version, development team, and organization (Apexiums Technologies) with links.
- Help Center, Privacy Policy, and Terms of Service entries (static placeholders for legal content).

---

## 💾 Data — how it works

There is **no backend and no runtime network calls**. The app ships a curated snapshot of the timetable:

| Component | Detail |
|---|---|
| Source 1 | **pakinformation.com** — stop-by-stop UP/DN timetables for major services |
| Source 2 | **Wikidata SPARQL** — official Pakistan Railways station codes (property P6785) |
| Cross-check | Train numbers/endpoints verified against the Wikipedia train list |
| Dataset | `assets/data/pakrail.json` — 13 trains, 26 services, 142 stations |
| Manual refresh | Re-run `dart run tool/import_pakrail.dart` to regenerate the dataset from the sources |
| Auto refresh | The app silently re-fetches the sources in the background when opened online (at most once per day, no UI); the refreshed copy is stored on-device |
| Offline fallback | If a refresh fails or never runs, the app always falls back to the bundled dataset — schedules are always available |

The background refresh uses the exact same import code as the CLI tool, so both stay in sync. Refreshes are polite (daily cooldown, hourly retry cap after failures) and fully invisible to the user.

**What's not in the data (by design):**
- **Fares** — Pakistan Railways doesn't publish prices in the public timetable, so price fields are hidden rather than made up.
- **Platforms** — also unpublished; shown only when a source provides them.
- **Live status / delays / GPS** — out of scope; the app is schedule-only.

---

## 🧪 Quality

- `flutter analyze` — clean, zero issues.
- **31 automated tests**, covering the data pipeline (real Karakoram Express route, station codes, journey search, station/route search), the search UI (default-all + content filters + voice fallback), the journey planner (ordering + bookmarking), Home (empty state + upcoming filter), and train details (real data, deep links, not-found).

---

## 🛠 Tech Stack

- **Flutter / Dart** (Material 3, multi-platform: Android, iOS, Web, Desktop)
- **flutter_bloc** — state management (every screen's data flows through BLoCs)
- **go_router** — declarative navigation with a stateful 4-tab shell
- **speech_to_text** — voice search on the Search page
- **shared_preferences** — on-device persistence for saved journeys
- **cached_network_image**, **intl**, **google_fonts**, **equatable** — image caching, formatting, typography, and equality
- **No backend** — the app runs entirely from bundled data

---

*Written for sharing — accurate as of the current codebase (August 2026).*
