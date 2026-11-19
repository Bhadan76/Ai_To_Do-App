# TodoApp

A local-state Flutter Todo UI prototype built with Dart and GetX. It includes
onboarding, mock authentication, task management, a dashboard, calendar,
statistics, profile/theme settings, and mock AI assistant/task-generation flows.
No backend or live AI integration is included.

## Architecture

- `lib/app`: app root, GetX named routes/bindings, and light/dark themes.
- `lib/core`: shared design tokens, utilities, and reusable UI components.
- `lib/features`: feature-specific presentation screens and controllers.
- `lib/shared`: task model and widgets used across features.

The visual reference is `assets/images/todo_app_reference.png`.

## Run and verify

```sh
flutter pub get
flutter run
flutter test
flutter analyze
flutter build apk
flutter build web
```
