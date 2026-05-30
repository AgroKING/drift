# Drift Frontend

The Drift frontend is a web-based dashboard built with Flutter. It reads the computed JSON attention debt report and renders a glassmorphic dashboard tracking developer tasks, messages, and pull requests.

---

## Directory Structure

The application code is located in `lib/`:

- [main.dart](file:///home/agp/PycharmProjects/drift/frontend/lib/main.dart): Sets up the application theme, manages the mock vs live toggle state, and fetches reports using a `FutureBuilder`.
- [models/drift_report.dart](file:///home/agp/PycharmProjects/drift/frontend/lib/models/drift_report.dart): Defines Dart model classes (`DriftReport`, `TopAction`, `Debts`, `ReviewDebt`, etc.) and handles JSON deserialization.
- [services/report_loader.dart](file:///home/agp/PycharmProjects/drift/frontend/lib/services/report_loader.dart): Fetches reports either locally from `assets/mock_drift_report.json` or over HTTP from the local backend port `8080`.
- [theme/app_theme.dart](file:///home/agp/PycharmProjects/drift/frontend/lib/theme/app_theme.dart): Configures the application's premium dark mode theme, setting up typography, container borders, and system colors.
- [widgets/](file:///home/agp/PycharmProjects/drift/frontend/lib/widgets/):
  - [ai_insight_card.dart](file:///home/agp/PycharmProjects/drift/frontend/lib/widgets/ai_insight_card.dart): Premium glassmorphic card displaying the executive AI insight summary and the suggested action plan items.
  - [debt_category_card.dart](file:///home/agp/PycharmProjects/drift/frontend/lib/widgets/debt_category_card.dart): Renders category cards (Review, Reply, Commitment, Staleness, Drift) with custom accent colors. Utilizes the shared `DebtItemRow` widget to render lists of items.
  - [score_header.dart](file:///home/agp/PycharmProjects/drift/frontend/lib/widgets/score_header.dart): Displays the overall personal Attention Debt Score and metadata (timestamp and delta indicator).
  - [top_action_banner.dart](file:///home/agp/PycharmProjects/drift/frontend/lib/widgets/top_action_banner.dart): Shows a prominent, action-oriented warning banner at the top highlighting the developer's most urgent action item.

---

## Development & Build Instructions

Make sure Flutter is installed on your system. Run these commands from the `frontend/` directory:

### Run Locally (Chrome)
```bash
flutter run -d chrome
```

### Analyze Lint Compliance
```bash
flutter analyze
```

### Format Source Code
```bash
dart format .
```

### Build Production Bundle
```bash
flutter build web
```
This output is saved to `build/web/` and can be served by any static file server.
