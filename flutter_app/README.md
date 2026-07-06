# Yoga Prana Vidya — Flutter App

Full mobile app for YPV trainers and students. Built with Flutter 3 + GoRouter.

## Screens

### Shared
| Screen | Route | Description |
|--------|-------|-------------|
| Splash | `/` | Animated logo, auto-navigates |
| Onboarding | `/onboarding` | 3-slide carousel with page dots |
| Login | `/login` | Phone/Email tab + OTP verification |
| Role Select | `/role-select` | Trainer or Student choice post-OTP |
| Trainer Registration | `/trainer-reg` | Name, phone, level dropdown |
| Student Registration | `/student-reg` | Name, email, phone |

### Trainer (bottom nav shell)
| Screen | Route | Description |
|--------|-------|-------------|
| Home | `/trainer/home` | KPI tiles, quick actions, recent students |
| My Students | `/trainer/students` | Search + workshop filter, bottom sheet |
| Profile / Settings | `/trainer/settings` | Details, logout with confirmation sheet |
| Add Student | `/trainer/add-student` | Full form with date picker + dropdowns |
| Upgrade Student | `/trainer/upgrade-student` | 2-step: cert search → new record |
| Student Detail | `/trainer/student-detail/:id` | History + upgrade shortcut |

### Student (bottom nav shell)
| Screen | Route | Description |
|--------|-------|-------------|
| Dashboard | `/student/home` | Level card, summary stats, course list |
| Cert History | `/student/certs` | All certificates with copy action |
| Profile / Settings | `/student/settings` | Details, logout sheet |
| Course Detail | `/student/course-detail/:index` | Full detail + copy/download cert |

## Setup

```bash
flutter pub get
flutter run
```

## Project structure

```
lib/
├── main.dart                   # App + GoRouter + shell scaffolds
├── theme/
│   ├── app_colors.dart         # All brand color constants
│   └── app_theme.dart          # MaterialApp theme
├── models/
│   └── models.dart             # StudentModel, WorkshopRecord, TrainerModel
├── data/
│   └── mock_data.dart          # Seed data + helper methods
├── widgets/
│   └── common_widgets.dart     # LevelBadge, YPVAvatar, OtpInput, WhiteCard, …
└── screens/
    ├── shared/                 # Splash, Onboarding, Login, RoleSelect, Registrations
    ├── trainer/                # Home, AddStudent, UpgradeStudent, MyStudents, Detail, Settings
    └── student/                # Dashboard, CourseDetail, CertHistory, Settings
```

## Dependencies

| Package | Purpose |
|---------|---------|
| `go_router ^13` | Declarative navigation + ShellRoute for tab bars |
| `shared_preferences ^2` | Persist onboarding flag + session |
| `intl ^0.19` | Date formatting |

## Design tokens (mirrors the YPV Design System)

| Token | Value |
|-------|-------|
| Primary | `#694CAB` |
| Teal | `#2EB5A0` |
| Blue | `#4A90D9` |
| Green | `#5BAE6B` |
| Background | `#F5F4FA` |
| Ink | `#1A1A2E` |
| Muted | `#8A8A9A` |
| Line | `#E8E8F0` |

## Notes

- All data is mock — wire `MockData` calls to your API/backend
- OTP flow is simulated with a 1.2s delay — replace with your SMS gateway
- `SharedPreferences` keys: `ypv_onboarded` (bool), session role, etc.
- The `TrainerShell` uses `BottomAppBar` + `FloatingActionButton` for the centred FAB tab pattern
