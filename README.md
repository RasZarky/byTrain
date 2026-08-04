# ByTrain 🚆

ByTrain is a modern, high-performance Flutter application designed for tracking train timings, planning journeys, and exploring station details. It uses a **feature-first** architecture and follows industry best practices for state management and navigation.

## ✨ Key Features

-   **Live Tracking**: Real-time updates on train status and timings.
-   **Journey Planner**: Effortlessly plan trips between stations with optimized routes.
-   **Smart Search**: Quickly find trains by number or stations by name.
-   **Interactive Routes**: Visualize full train routes with stop-by-stop details.
-   **Modern UI/UX**:
    -   **Centralized Design System**: Unified theme with support for **Light and Dark Mode** using `ThemeData`.
    -   **Custom Component Library**: Reusable core widgets like `CustomCard` and `AppButton` for UI consistency.
    -   **Skeleton Loading**: Premium shimmering effects using `Skeletonizer` for a polished loading experience.
    -   **Smooth Navigation**: Declarative routing with `GoRouter`, supporting deep links and nested routes.
    -   **Clean States**: Predictable state management via `BLoC` (Business Logic Component), following the 3-file separation pattern (bloc, event, state).

## 🛠 Tech Stack

-   **Framework**: [Flutter](https://flutter.dev)
-   **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) & [bloc](https://pub.dev/packages/bloc)
-   **Navigation**: [go_router](https://pub.dev/packages/go_router)
-   **Loading UI**: [skeletonizer](https://pub.dev/packages/skeletonizer)
-   **Models**: [equatable](https://pub.dev/packages/equatable) for value-based equality.

## 🏗 Project Structure

The project follows a **Feature-first** (Layered) approach, which isolates business logic and makes the codebase highly scalable:

```text
lib/
├── core/               # App-wide configurations
│   ├── router/         # GoRouter path definitions & navigation logic
│   ├── theme/          # Centralized Design System (Colors, Typography, Dimensions)
│   └── widgets/        # Reusable UI components (AppButton, CustomCard, etc.)
├── features/           # Independent business modules
│   ├── home/           # Dashboard & recent activity tracking
│   │   ├── presentation/ # UI & BLoCs (separated into .bloc, .event, .state)
│   │   ├── domain/       # Business logic & models
│   │   └── data/         # Repositories & Data sources
│   ├── search/         # Search logic & results
│   ├── train/          # Train details, routes, and tracking
│   ├── station/        # Station-specific info & facilities
│   ├── journey_planner/# Routing algorithms & trip planning
│   └── settings/       # Preferences, About, & Legal info
└── main.dart           # App entry, Global BlocProviders, & Theme setup
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (^3.10.7)
- Android Studio / VS Code / IntelliJ IDEA

### Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/your-username/by_train.git
    ```
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the application**:
    ```bash
    flutter run
    ```

## 📱 Screens Overview

1.  **Splash Screen**: Branded entry point with initialization logic and Hero animations.
2.  **Onboarding**: Interactive guide for new users using PageView.
3.  **Home**: Dynamic dashboard with **Skeletonizer** integration and Quick Action cards.
4.  **Search**: Powerful search bar with localized inputs for stations.
5.  **Search Results**: Categorized results with high-contrast status indicators.
6.  **Train Details**: Comprehensive view of live status, arrival/departure schedules.
7.  **Route Details**: Visual timeline/timeline-tree of the train's journey.
8.  **Journey Planner**: Station-to-station trip finder with search history.
9.  **Station Details**: Live boards, station facilities, and local maps.
10. **Settings**: Dark mode toggle, notification preferences, and region settings.
11. **About**: Version information, licenses, and developer credits.

## 🧪 Architecture Philosophy

ByTrain follows the **SOLID** principles and uses a **Clean Architecture** approach within each feature. This ensures that the UI is decoupled from the business logic, making it easier to write unit tests and swap out data sources (e.g., moving from a mock API to a real REST API).
