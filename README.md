# Mini News Intelligence App

A Flutter 3+ news application built for the Junior Developer assignment. The app provides authentication, a category-based news feed, search, article detail, favorites, and offline persistence.

## Download

[Download APK](https://github.com/superbhel7-ship-it/News-app-assignment/releases/download/v1.0.0/app-release.apk)

## Tech Stack

- Flutter 3.38+
- Dart 3 with null safety
- Riverpod for state management
- Dio for API integration
- Hive for local persistence
- Supabase Auth for email/password authentication

## Features

- Simple login and sign-up flow
- Persistent auth session handling
- Category-based news browsing
- Pagination for article lists
- Pull-to-refresh on news screens
- Search with debounce
- Article detail view
- Save and remove favorites
- Offline favorites via Hive
- Error states and loading states across the app

## Project Structure

```text
lib/
  core/
    constants/      # app and API constants
    errors/         # exceptions and failures
    network/        # Dio client setup
    theme/          # colors, text styles, themes
    utils/          # formatting helpers
  data/
    datasources/
      local/        # Hive/local auth helpers
      remote/       # news API datasource
    models/         # API/storage models
    repositories/   # repository implementations
  domain/
    entities/       # pure business entities
    repositories/   # repository contracts
  presentation/
    providers/      # Riverpod notifiers/providers
    screens/        # app screens
    widgets/        # reusable UI components
  main.dart         # app bootstrap
```

## Architecture

The project follows a lightweight clean architecture approach:

- `presentation` handles UI and user interactions.
- `providers` manage state with Riverpod notifiers.
- `domain` defines entities and repository contracts.
- `data` contains datasource implementations and repository implementations.
- `core` contains shared setup like networking, constants, theme, and errors.

This separation keeps UI code smaller, makes data flow predictable, and allows features like favorites and search to scale without tightly coupling screens to networking code.

## State Management

Riverpod is used to manage feature state:

- `authProvider` handles login/logout state
- `newsProvider` handles category feed, refresh, and pagination
- `searchProvider` handles debounced search and search pagination
- `favoritesProvider` handles local favorite persistence and toggle state
- `themeProvider` persists theme selection

## Data Flow

1. UI triggers an action through a Riverpod notifier.
2. The notifier calls a repository.
3. The repository delegates work to remote or local datasources.
4. Datasources return models that map into domain entities.
5. State is updated and reflected in the UI.

## API Integration

The app uses `NewsAPI.org` through Dio.

- Top headlines are fetched by category
- Search uses the `everything` endpoint
- Pagination is handled with `page` and `pageSize`
- Failures are converted into app-level messages using custom exceptions/failures

## Local Persistence

Hive is used for:

- favorites storage
- theme persistence
- local profile/settings storage

Favorites are stored locally so bookmarked articles remain available offline.

## Error Handling

The app includes:

- network exception mapping
- repository-level failure translation
- loading indicators
- retry states for failed API requests
- empty-state UI for favorites and search

## Run the Project

```bash
flutter pub get
flutter run
```

## Build Notes

- Flutter SDK used locally: `3.38.5`
- The project uses null safety
- Environment secrets are currently defined in constants for simplicity in assignment mode and should be moved to secure configuration for production

## Key Decisions

- Riverpod was chosen because it scales well and keeps business logic outside widgets.
- Hive was chosen for favorites because it is lightweight and fast for offline local storage.
- Clean architecture folders were used to keep API, storage, UI, and state layers separated.
- Dio was used for clearer request configuration and better exception handling than raw `http`.

## Improvements If Extended

- move API keys and Supabase config to secure environment variables
- add unit tests for repositories and providers
- add widget tests with mocked providers
- add cached feed responses for offline reading
- unify auth persistence so tests and startup behavior are easier to control