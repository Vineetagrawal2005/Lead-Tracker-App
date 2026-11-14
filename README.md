# Lead Tracker

A small sales CRM mobile app for salespeople, built with Flutter. Track leads, add notes, manage follow-ups, and monitor conversion — inspired by Surefy's Reachout.

## Features
- **Authentication (local):** Signup, login, logout, and "Remember me" session persistence. Passwords are stored as SHA-256 hashes (no plain text).
- **Dashboard:** Greeting with date, stat cards (Total / New / Contacted / Converted), conversion rate with progress bar and segmented status bar, and recent leads with quick navigation.
- **Leads:** Load sample leads from [randomuser.me](https://randomuser.me) (Indian nationals), pull-to-refresh merge (deduped by email, never overwrites user edits), debounced search, status filter chips with counts, sorting, and swipe-to-delete with undo.
- **Lead details:** Full info, Hero avatar, Call button (opens dialer via `url_launcher`, auto-logs a `"Called on..."` note, and promotes `New → Contacted`), status change, notes (add/delete, newest first), edit, and delete.
- **Add/Edit lead:** Validated form (name, 10-digit Indian mobile starting with 6–9, optional email, company, source, status) with duplicate phone prevention.
- **Persistence:** Hive for users/leads/notes and `SharedPreferences` for session state. Data survives app restarts when "Remember me" is checked.
- **UX:** Material 3 theme, loading/error/empty states, retry actions, responsive layouts, and safe areas.

## Screenshots
Place screenshots in `docs/screenshots/`:
- `docs/screenshots/splash.png`
- `docs/screenshots/login.png`
- `docs/screenshots/dashboard.png`
- `docs/screenshots/leads.png`
- `docs/screenshots/lead_details.png`
- `docs/screenshots/add_lead.png`
- `docs/screenshots/profile.png`

## Architecture
Layered structure: **UI → Provider → Services → Hive/API**

- **UI (`screens/`, `widgets/`):** Presentational and interaction logic only. Screens read state via `context.watch` / `Selector` / `Consumer` and trigger actions via `context.read`. No direct Hive or HTTP calls.
- **State (`providers/`):** `AuthProvider` and `LeadProvider` extend `ChangeNotifier`. They hold app state, expose getters (filtered leads, counts, conversion rate), and call services. Every mutation persists immediately and calls `notifyListeners()`.
- **Services (`services/`):** `ApiService` (HTTP + mapping + typed `ApiException`), `StorageService` (Hive boxes + `SharedPreferences` wrapper), and `AuthService` (signup/login rules, hashing). Services are UI-agnostic.
- **Models (`models/`):** `UserModel`, `LeadModel`, and `NoteModel` with `toMap` / `fromMap` / `copyWith`. Stored as Maps in Hive (no code generation / `build_runner`).
- **Core (`core/`):** Constants, theme, `go_router` routes, validators, and launcher helper.

**Why Provider:** Simple, explicit, and easy to explain for a small-to-medium app. `ChangeNotifier` fits the app's state needs (lists, filters, auth session) without extra boilerplate while demonstrating clear separation of concerns.

**Data flow example:**  
Add lead → `AddEditLeadScreen` validates → `LeadProvider.addLead()` checks duplicates and assigns ID/user/timestamps → `StorageService.saveLead()` writes to Hive → `notifyListeners()` → Dashboard and Leads rebuild with updated counts.

**Persistence:**  
Hive boxes `users`, `leads`, and `notes` store records as Maps. `SharedPreferences` stores `isLoggedIn`, `currentUserId`, and `rememberMe`. On startup, `StorageService.init()` opens boxes/prefs before `runApp`, and `SplashScreen` calls `AuthProvider.checkSession()` to restore the session. Leads and notes are scoped per user via a `userId` field and filtered on read.

**Navigation:**  
Uses `go_router` (`core/routes.dart`) for declarative routing (`splash`, `login`, `signup`, `main`, `details`, `add-edit`). The main shell uses `NavigationBar` + `IndexedStack` to preserve tab state.

## Packages

| Package | Why |
| :--- | :--- |
| `provider` | State management (`ChangeNotifier`) for auth and leads. |
| `go_router` | Declarative navigation and route configuration. |
| `http` | Fetch sample leads from `randomuser.me`. |
| `hive`, `hive_flutter` | Fast local key-value storage for users, leads, and notes (no codegen). |
| `shared_preferences` | Persist session/login flags and small settings. |
| `url_launcher` | Open the phone dialer for the Call action. |
| `intl` | Date/time formatting for UI and call-note timestamps. |
| `crypto` | SHA-256 hashing for local password storage. |
| `uuid` | Generate stable unique IDs for models. |
| `fl_chart` | (Available) charting dependency; dashboard uses a segmented bar built with widgets for simplicity. |

## API Integration (`randomuser.me`)
- **Endpoint:** `GET https://randomuser.me/api/?results=30&nat=in&seed=leadtracker` (10s timeout).
- **Mapping:** `name` = `first + last`, `phone` = digits-only last 10, `email` = `email`, `company` = stable pick from an Indian business list, `source` = from source list, `status` = weighted (`New` 50% / `Contacted` 30% / `Converted` 20%), `photoUrl` = `picture.medium`, `isFromApi = true`.
- **Behavior:** On first login with an empty leads store, leads are fetched and saved to Hive. Pull-to-refresh re-fetches and **merges**: adds only new API leads, never overwrites/deletes user-created or edited leads, and dedupes by email.
- **States:** Loading view, error view with Retry (or `"Could not refresh"` snackbar if local data exists), and empty views for no leads vs. no search/filter results. All HTTP logic lives in `api_service.dart` and throws typed `ApiException`s converted to friendly messages.

## Replacing Local Auth/Storage with a Real Backend
Local auth/storage is a placeholder. A real backend can plug in at the service layer with minimal UI changes:
- **Auth:** `AuthService` would call REST endpoints instead of Hive (e.g., `POST /auth/signup`, `POST /auth/login` returning user + token, `POST /auth/logout`). Store the token securely and attach it to requests. `StorageService` session methods would persist token/expiry, and `AuthProvider.checkSession()` would validate/refresh the token.
- **Leads/Notes:** `ApiService` (or a new `LeadApiService`) would expose `GET /leads`, `POST /leads`, `PUT /leads/:id`, `DELETE /leads/:id`, and note endpoints (`GET /leads/:id/notes`, `POST /leads/:id/notes`, `DELETE /notes/:id`). `LeadProvider` would call these services and optionally keep Hive as an offline cache (sync/merge on reconnect).
- **Where to change:** Implement HTTP calls in `lib/services/api_service.dart` and `lib/services/auth_service.dart` (or split into dedicated API services), keeping provider method signatures stable so screens remain unchanged.

## How to Run

**Prerequisites:** Flutter SDK (stable), Dart, Android SDK / emulator or physical device.

```bash
# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Build release APK (Output: build/app/outputs/flutter-apk/app-release.apk)
flutter build apk --release

# Format and analyze code
dart format .
flutter analyze
```

## Known Limitations & Future Improvements
- **Local-only auth:** No real backend, tokens, or multi-device sync.
- **No WhatsApp action:** Only Call is implemented. A WhatsApp button can be added in `core/launcher_helper.dart` using `https://wa.me/<number>` (note left in code).
- **No push reminders / follow-up notifications.**
- **No CSV export/import.**
- **Offline conflict resolution:** API merge is simple (dedupe by email); a real sync strategy would be needed with a backend.
- **Dark mode:** Theme is light-focused; dark mode can be added with a corresponding `ColorScheme`.
- **Tests:** Basic validator and login-form widget tests included; more coverage (provider integration with Hive, full widget flows) can be added.

## Demo Script
<img width="1080" height="2400" alt="WhatsApp Image 2026-11-14 at 6 42 42 PM" src="https://github.com/user-attachments/assets/cdf3c7ce-d9c1-4db1-b794-ca0717eb3051" />
<img width="1080" height="2400" alt="WhatsApp Image 2026-11-14 at 6 42 42 PM (1)" src="https://github.com/user-attachments/assets/de1073a8-cc1e-433b-979b-656eac7cb1b9" />
<img width="720" height="1600" alt="WhatsApp Image 2026-11-14 at 6 42 41 PM" src="https://github.com/user-attachments/assets/fdf0cc87-62f1-4613-839d-c3132ddde84b" />
<img width="720" height="1600" alt="WhatsApp Image 2026-11-14 at 6 42 41 PM (2)" src="https://github.com/user-attachments/assets/715a94f6-cddd-4bda-8547-a5d922fae539" />
<img width="720" height="1600" alt="WhatsApp Image 2026-11-14 at 6 42 41 PM (1)" src="https://github.com/user-attachments/assets/a51fd06b-69f9-44ce-b20d-f3231fdb49d9" />
<img width="720" height="1600" alt="WhatsApp Image 2026-11-14 at 6 42 40 PM" src="https://github.com/user-attachments/assets/0810f266-efaa-4e53-8dc6-e4592cf31488" />
<img width="720" height="1600" alt="WhatsApp Image 2026-11-14 at 6 42 40 PM (3)" src="https://github.com/user-attachments/assets/9e8437a3-4f9c-47d1-a1b4-65be61b9be1d" />
<img width="720" height="1600" alt="WhatsApp Image 2026-11-14 at 6 42 40 PM (2)" src="https://github.com/user-attachments/assets/e657c5ed-e929-4b07-a2f8-517892b52420" />
<img width="720" height="1600" alt="WhatsApp Image 2026-11-14 at 6 42 40 PM (1)" src="https://github.com/user-attachments/assets/6d1a7628-be36-401a-ab57-ca628ca277db" />
<img width="720" height="1600" alt="WhatsApp Image 2026-11-14 at 6 42 39 PM" src="https://github.com/user-attachments/assets/a07d3ae0-1bd0-4204-bd48-cd005bcd9be0" />
<img width="1080" height="2400" alt="WhatsApp Image 2026-11-14 at 6 42 39 PM (2)" src="https://github.com/user-attachments/assets/33d4568c-b4e2-4b0f-af65-e544d65ed86e" />
<img width="1080" height="2400" alt="WhatsApp Image 2026-11-14 at 6 42 39 PM (1)" src="https://github.com/user-attachments/assets/779c5a67-4dfe-4dca-aa33-1c7256a11b4c" />

