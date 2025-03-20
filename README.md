# Learning Stock App

A Flutter application for learning about stocks and financial markets with a clean architecture approach.

## Project Structure

The project follows a clean architecture approach with clear separation of concerns:

```
lib/
├── core/                 # Core functionality used across the app
│   ├── constants/        # App constants
│   ├── di/               # Dependency injection
│   ├── errors/           # Error handling
│   ├── network/          # Network client and API handling
│   ├── theme/            # App theme
│   └── utils/            # Utility classes
│
├── data/                 # Data layer
│   ├── datasources/      # Remote and local data sources
│   ├── models/           # Data models
│   └── repositories/     # Repository implementations
│
├── domain/               # Domain layer
│   ├── entities/         # Business entities
│   ├── repositories/     # Repository interfaces
│   └── usecases/         # Use cases
│
└── presentation/         # Presentation layer
    ├── blocs/            # BLoC state management
    ├── cubits/           # Cubit state management
    ├── pages/            # UI pages
    ├── widgets/          # Reusable UI components
    └── common/           # Common UI elements
```

## Architecture

The app follows the principles of Clean Architecture with three main layers:

1. **Presentation Layer**: Contains UI components and state management (BLoC/Cubit)
2. **Domain Layer**: Contains business logic, entities, and use cases
3. **Data Layer**: Handles data operations, API calls, and local storage

## State Management

The app uses the BLoC pattern with Cubits for state management, providing:

- Clear separation between UI and business logic
- Testable components
- Predictable state changes
- Reactive UI updates

## Key Features

- View trending stocks
- Search for specific stocks
- View detailed stock information
- Track stock price history

## Dependencies

- **State Management**: flutter_bloc, equatable
- **Networking**: dio, http
- **Local Storage**: shared_preferences, hive
- **UI Components**: flutter_svg, cached_network_image, shimmer, fl_chart
- **Utilities**: intl, logger, get_it, dartz

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app
