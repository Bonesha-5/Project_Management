# Momentum: Project & SLA Task Tracker

**Make Progress Visible.**

Momentum is a Flutter mobile app that helps a small team track its tasks against deadlines. Every task gets an automatic **SLA status** (On Track, At Risk, Overdue or Completed) based on its due date and progress, so the team can see at a glance what needs attention, who is overloaded and how the project is moving.

The app runs fully offline: all data is stored on the device.

> **Run target:** this app is built for **Android and iOS**. Please run it on an Android emulator, an iOS simulator or a physical phone, not in a browser.

---

## Table of contents

1. [Features](#features)
2. [Screens](#screens)
3. [Getting started](#getting-started)
4. [Demo account](#demo-account)
5. [Project structure](#project-structure)
6. [How the app works](#how-the-app-works)
7. [SLA rules](#sla-rules)
8. [Local storage](#local-storage)
9. [Error handling and validation](#error-handling-and-validation)
10. [Testing](#testing)
11. [Team and contributions](#team-and-contributions)
12. [Git workflow](#git-workflow)
13. [Known limitations](#known-limitations)

---

## Features

- **Simulated sign up and sign in.** Accounts are saved on the device, and the user stays signed in until they sign out.
- **Dashboard** with a time-based greeting, overall project progress, six summary cards, a "This week" row and a **Needs attention** list of At Risk and Overdue tasks.
- **Task management:** create, view, edit, reassign and delete tasks, with search and SLA filters.
- **Automatic SLA status** for every task, with a Time used bar and a Work done bar.
- **Team view** with each member's open task count and a workload badge (Balanced, Heavy, Overloaded).
- **Member Tasks:** tap a team member to see all of their open and completed tasks.
- **Statistics:** tasks by status, on-time rate, open high-priority tasks, open tasks per member and upcoming deadlines.
- **Light and dark mode**, remembered after the app is closed.
- **Data persists** after closing and reopening the app.
- **Sample data** on first launch, so the app is never empty.

---

## Screens

The app has 14 screens: the 13 required screens plus Member Tasks.

| Area | Screens |
|---|---|
| Access | Sign In, Sign Up |
| Insights | Dashboard, Task Statistics |
| Tasks | Task List, Task Details, New Task, Edit Task |
| Team | Team Members, Add Member, Member Tasks |
| Account | Profile, Edit Profile, App Settings |

After sign in, a floating bottom bar gives access to five tabs: **Home, Tasks, Team, Stats and Profile**.

<!-- Add screenshots here, for example:
![Dashboard light](docs/screenshots/dashboard_light.png)
![Dashboard dark](docs/screenshots/dashboard_dark.png)
-->

---

## Getting started

### Prerequisites

- **Flutter SDK** (stable channel, Dart 3.13 or newer). Check with `flutter --version`.
- **Android Studio** with an Android emulator, or Xcode with an iOS simulator, or a physical phone.
- **Windows only:** turn on **Developer Mode** (Settings → For developers), because Flutter plugins such as `shared_preferences` need it.

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/Bonesha-5/Project_Management.git
cd Project_Management

# 2. Download the packages
flutter pub get

# 3. List and start an emulator
flutter emulators
flutter emulators --launch <emulator_id>

# 4. Run the app
flutter run
```

In VS Code, you can instead select the emulator in the bottom-right corner and press **F5**.

### Packages used

| Package | Purpose |
|---|---|
| `shared_preferences` | Saves tasks, members, the signed-in user and the dark mode setting on the device |
| `intl` | Date formatting |
| `cupertino_icons` | iOS-style icons |

Charts are built with ordinary Flutter widgets (`Container`, `Row`, `Column`), so no chart package is needed.

---

## Demo account

On the first launch, the app loads sample data, including a demo account:

| Email | Password |
|---|---|
| `john@email.com` | `password123` |

You can also create a new account with **Sign Up**.

> **Note:** sign in is **simulated**, as allowed by the assignment. There is no backend, no Firebase and no encryption. Accounts are stored on the device, and the app checks the typed email and password against them. Its purpose is to show the interface and the user flow.

---

## Project structure

Each file has exactly one owner.

```
lib/
├── main.dart                     App start, routes, theme state (Byusa)
├── app_theme.dart                Light and dark ThemeData, colour palette (Byusa)
├── models/
│   ├── member.dart               Member model (Byusa)
│   └── task.dart                 Task model, Priority and TaskStatus enums (Deborah)
├── services/
│   ├── storage_service.dart      All saving and loading (Kevine)
│   ├── seed_data.dart            Sample members and tasks (Kevine)
│   ├── auth_service.dart         Sign up, sign in, sign out, profile (Byusa)
│   └── sla_service.dart          SLA rules and statistics (Jospin)
├── widgets/
│   ├── main_shell.dart           Floating bottom bar with five tabs (Kevine)
│   ├── status_pill.dart          SLA status pill and workload badge (Kevine)
│   ├── app_text_field.dart       Shared text field and input validators (Kevine)
│   ├── app_button.dart           Shared button (Kevine)
│   ├── user_avatar.dart          Initials avatar (Kevine)
│   ├── task_card.dart            Task card for the Task List (Deborah)
│   ├── task_form.dart            Form shared by New and Edit Task (Deborah)
│   └── insight_widgets.dart      Cards and bars for Dashboard and Statistics (Jospin)
└── screens/
    ├── sign_in_screen.dart       (Byusa)
    ├── sign_up_screen.dart       (Byusa)
    ├── profile_screen.dart       (Byusa)
    ├── edit_profile_screen.dart  (Byusa)
    ├── app_settings_screen.dart  (Byusa)
    ├── dashboard_screen.dart     (Jospin)
    ├── statistics_screen.dart    (Jospin)
    ├── task_list_screen.dart     (Deborah)
    ├── task_details_screen.dart  (Deborah)
    ├── new_task_screen.dart      (Deborah)
    ├── edit_task_screen.dart     (Deborah)
    ├── team_screen.dart          (Kevine)
    ├── add_member_screen.dart    (Kevine)
    └── member_tasks_screen.dart  (Kevine)

test/
├── sla_service_test.dart         SLA rules and statistics (Jospin)
├── storage_service_test.dart     Storage, sample data, corrupted data (Kevine)
├── shared_widgets_test.dart      Validators, initials, status pill (Kevine)
└── team_screens_test.dart        Team, Add Member, Member Tasks (Kevine)
```

| Folder | What it contains |
|---|---|
| `models` | The shape of the data, with `toJson` and `fromJson` |
| `services` | Logic with no screens: storage, sign in, SLA rules, sample data |
| `widgets` | Reusable pieces shared by several screens |
| `screens` | One `StatefulWidget` per screen |
| `test` | Unit tests and widget tests |

---

## How the app works

### Data flow

```
Screen  ──►  Service  ──►  Device storage
(shows data,     (does the work:     (SharedPreferences
 calls setState)  save, load, SLA)    keeps the data)
```

- **Screens** show data and send user actions. They never read storage directly and never calculate SLA statuses themselves.
- **Services** do the work. `StorageService` saves and loads, `SlaService` calculates statuses and statistics, `AuthService` handles accounts.
- **Storage** keeps the data after the app is closed.

**Example, creating a task:** New Task validates the form, builds a `Task`, saves it through `StorageService` inside `try/catch`, shows a SnackBar and goes back. The Task List opened New Task with `await Navigator.push(...)`, so when it returns, it reloads its data and calls `setState()`. `SlaService` gives the new task its status.

### State management with setState

The app uses Flutter's built-in `setState()`, with no state management package.

- Every screen that shows changing data is a `StatefulWidget`. It loads its data in `initState` and keeps it in variables inside its `State` class.
- After a change (create, edit, delete, filter, toggle), the screen saves through `StorageService` and calls `setState()`, so Flutter rebuilds the screen with the new data.
- When a screen opens another one whose changes matter, it uses `await Navigator.push(...)`, then reloads and calls `setState()` on return.
- The bottom bar keeps the selected tab in a variable and calls `setState()` when a tab is tapped. Each tab is built fresh, so it reloads its data.

### Dark mode: lifting state up

`main.dart` is a `StatefulWidget` that holds `isDark`. It passes a callback, `onThemeChanged`, to the App Settings screen. When the switch changes, the callback calls `setState()` in `main.dart`, so the whole app switches theme at once, and `StorageService.setDarkMode()` remembers the choice.

### Navigation

On launch, a startup gate checks for a saved session and opens either **Sign In** or the **bottom bar** (`MainShell`). Named routes are used for `/sign-in`, `/sign-up`, `/dashboard`, `/profile`, `/edit-profile` and `/app-settings`. The other screens are opened with `Navigator.push`.

---

## SLA rules

All rules live in `lib/services/sla_service.dart`. Screens never repeat them.

| Status | Rule |
|---|---|
| **Completed** | The task's status is Done |
| **Overdue** | The deadline has passed and the task is not Done |
| **At Risk** | Not Done, and due in 48 hours or less |
| **On Track** | Everything else |

- **Deadline:** the date picker only gives a date, so a task is due at the **end** of its due day (23:59:59). A task due today is not overdue at midnight this morning.
- **Time used** is calculated automatically from the created date, the deadline and the current time. Nobody types it.
- **Work done** is a value from 0 to 100, set with a slider. Marking a task Done sets it to 100 and records the completion time.
- **Project progress** is the average Work done of all tasks (0% when there are no tasks).
- **On-time rate** is the share of completed tasks that were finished by their deadline (0% when nothing is completed).
- The 48-hour threshold is one constant, `SlaService.atRiskHours`, so it can be changed in a single place.

### Workload rule

Based on a member's open (not Completed) tasks:

| Open tasks | Badge |
|---|---|
| 0 to 2 | Balanced |
| 3 to 4 | Heavy |
| 5 or more | Overloaded |

---

## Local storage

The app uses **SharedPreferences**. Only `StorageService` reads or writes it.

| Key | Content |
|---|---|
| `tasks` | All tasks, as JSON text |
| `members` | All members, as JSON text |
| `currentUserId` | The signed-in member (removed on sign out) |
| `darkMode` | The theme choice |
| `seeded` | Whether the sample data was already loaded |

**Why SharedPreferences:** the data is small (a few members and a few dozen tasks), so each list is saved as one JSON value. It needs no tables, no SQL and no migrations, works on Android and iOS, and keeps data after the app closes.

**Its limits:** it rewrites the whole list on every save, cannot run queries and is not secure (passwords are plain text, which is acceptable only because sign in is simulated). For a production app with more data, we would use **SQLite** (`sqflite`), and a real authentication service for accounts.

**Sample data:** on the first launch only, the app loads 5 members and 12 tasks covering every status (5 On Track, 3 At Risk, 2 Overdue, 2 Completed) and every workload badge. Due dates are calculated from the current date, so the statuses are correct whenever the app is first opened.

---

## Error handling and validation

- **Saving and loading** are wrapped in `try/catch`. If saving fails, the user sees a SnackBar such as *"Could not save the task. Please try again."*
- **Corrupted or missing data** never crashes the app. Storage returns an empty list instead, and a single broken record is skipped while the rest are kept.
- **Forms** use `Form`, `GlobalKey<FormState>` and shared validators with clear messages: required fields, email format, passwords of at least 6 characters, matching passwords, duplicate emails and due dates in the past.
- **Deleting** a task asks for confirmation in an `AlertDialog`.
- **Empty states** are shown when a list has nothing in it (for example "No tasks yet").
- **No divide-by-zero:** progress and on-time rate show 0% when there are no tasks.
- **Missing members:** a task whose member no longer exists shows "Unassigned".
- **Layout:** every screen uses `SafeArea` and scrollable content, so nothing overflows on small phones or when the keyboard is open, in light and dark mode.

---

## Testing

Run all tests:

```bash
flutter test
```

| Test file | Tests | What it checks |
|---|---|---|
| `sla_service_test.dart` | 22 | Each SLA status, the exact 48-hour boundary, just past due, Done before and after the deadline, 0% and 100% work done, statistics and workload |
| `storage_service_test.dart` | 8 | Sample data on first run only, corrupted data, saving and reloading, sign-in session, dark mode |
| `shared_widgets_test.dart` | 12 | Input validators, avatar initials, status pill |
| `team_screens_test.dart` | 6 | Team list and badges, Member Tasks, Add Member validation and saving, no overflow on a small phone in dark mode |
| **Total** | **48** | |

The app was also tested by hand on an Android emulator, in light and dark mode, including closing and reopening it to confirm that data persists.

---

## Team and contributions

| Member | Role | Main work |
|---|---|---|
| **Byusa Martin** | Access, Profile and Theme | Sign In, Sign Up, Profile, Edit Profile, App Settings, theme, `main.dart`, Member model, AuthService, AI Usage Declaration |
| **Jospin Nganji** | Insights and SLA | Dashboard, Statistics, SlaService, SLA unit tests, PDF report |
| **Kamikazi Deborah** | Tasks | Task List, Task Details, New Task, Edit Task, Task model, task form and card, repository setup, README |
| **Uwineza Kevine** | Team, Data and Shared UI | Team Members, Add Member, Member Tasks, StorageService, sample data, shared widgets, bottom bar, integration of all branches, demo |

---

## Git workflow

- Each member worked on their **own branch** and opened a **pull request** into `main`.
- Shared foundations (models, storage, theme, shared widgets, SLA service) were agreed in a **shared contract** first, so everyone could code against the same names before the files were merged.
- All branches were combined on an `integration` branch, where conflicts were resolved by keeping each **file owner's version**, then tested (`flutter analyze` and `flutter test`) before being merged into `main` with merge commits, so every member's commit history is preserved.
- Nobody pushes directly to `main`. Fixes go through a short-lived branch and a pull request.

---

## Known limitations

- Sign in is simulated: passwords are stored as plain text on the device.
- Data lives on one device only. There is no syncing between team members' phones.
- SharedPreferences suits small data sets, as explained in [Local storage](#local-storage).
- Pushed screens (such as Add Member and Task Details) cover the bottom bar, which is standard behaviour with `Navigator.push`.

---

*Built with Flutter for the Momentum mobile development assignment, October 2026.*
