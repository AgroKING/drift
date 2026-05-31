---
name: Drift
description: Developer Attention Debt Dashboard — a premium dark-mode analytics UI for tracking cross-tool workflow debt across GitHub, Linear, Slack, and Notion.
platform: flutter-web
viewport: desktop (1280px+)

colors:
  # Core surfaces
  background: "#0F1117"
  surface: "#181B23"
  surfaceElevated: "#1E2230"
  surfaceOverlay: "rgba(255,255,255,0.04)"

  # Text
  textPrimary: "#F1F5F9"
  textSecondary: "#94A3B8"
  textMuted: "#64748B"

  # Borders
  border: "rgba(255,255,255,0.08)"
  borderSubtle: "rgba(255,255,255,0.04)"
  borderFocus: "rgba(255,255,255,0.16)"

  # Brand / accent
  accent: "#0D9488"
  accentMuted: "rgba(13,148,136,0.15)"
  accentBorder: "rgba(13,148,136,0.35)"

  # Debt category accents
  review: "#EF4444"
  reply: "#F97316"
  commitment: "#EAB308"
  staleness: "#3B82F6"
  drift: "#A855F7"

  # Semantic
  scoreUp: "#EF4444"
  scoreDown: "#16A34A"
  success: "#22C55E"
  warning: "#F59E0B"
  error: "#EF4444"

typography:
  fontFamily: "Inter"
  fontPackage: "google_fonts"

  displayLg:
    fontSize: "48px"
    fontWeight: 800
    lineHeight: 1.1
    letterSpacing: "-0.02em"

  displaySm:
    fontSize: "36px"
    fontWeight: 700
    lineHeight: 1.15

  scoreLarge:
    fontSize: "56px"
    fontWeight: 800
    lineHeight: 1.0

  h1:
    fontSize: "28px"
    fontWeight: 700
    lineHeight: 1.25

  h2:
    fontSize: "20px"
    fontWeight: 700
    lineHeight: 1.3

  h3:
    fontSize: "16px"
    fontWeight: 700
    lineHeight: 1.35

  bodyLg:
    fontSize: "16px"
    fontWeight: 500
    lineHeight: 1.5

  bodyMd:
    fontSize: "14px"
    fontWeight: 500
    lineHeight: 1.45

  bodySm:
    fontSize: "13px"
    fontWeight: 500
    lineHeight: 1.4

  label:
    fontSize: "12px"
    fontWeight: 800
    lineHeight: 1.2
    letterSpacing: "1.2px"
    textTransform: "uppercase"

  caption:
    fontSize: "11px"
    fontWeight: 600
    lineHeight: 1.3

spacing:
  xs: "4px"
  sm: "8px"
  md: "16px"
  lg: "24px"
  xl: "32px"
  xxl: "48px"
  section: "40px"

rounded:
  sm: "8px"
  md: "12px"
  lg: "16px"
  xl: "18px"
  pill: "999px"

elevation:
  card:
    boxShadow: "0 4px 24px rgba(0,0,0,0.25)"
  cardHover:
    boxShadow: "0 8px 32px rgba(0,0,0,0.35)"
  glow:
    boxShadow: "0 0 32px rgba(13,148,136,0.08)"
  categoryGlow:
    boxShadow: "0 10px 32px rgba(var(--category-color),0.10), 0 26px 72px rgba(var(--category-color),0.06)"
---

## Overview

Drift is a **Developer Attention Debt Dashboard** — a single-page web app that surfaces cross-tool workflow debt for individual developers. It pulls data from GitHub, Linear, Slack, and Notion to compute an overall "Attention Debt Score" and groups individual debt items into five color-coded categories.

### Design Philosophy
- **Dark-first**: A deep, rich dark palette (`#0F1117` background) that feels premium and reduces eye strain during long work sessions.
- **Glassmorphism done right**: Subtle frosted-glass surfaces with `backdrop-filter: blur()` on elevated elements, never on flat content.
- **Data-dense but scannable**: The dashboard is information-heavy. Use strong typographic hierarchy, whitespace, and color-coded accents to keep it readable at a glance.
- **Developer-native**: This is a tool for engineers. Favor clarity and information density over decoration. Monospace badges for task IDs (`LIN-342`), clean tables, and minimal chrome.

### Mood & Inspiration
- GitHub's dark mode dashboard
- Linear's clean issue tracker
- Raycast's premium desktop UI
- Vercel's deployment dashboard

### Target Platform
- **Flutter Web** compiled to desktop Chrome
- **Primary viewport**: 1280px–1920px wide desktop
- **No mobile layout needed** (but max-width the content for readability)

---

## Colors

### Core Surfaces
Use a layered surface system to create depth without heavy shadows.

| Token | Value | Usage |
|---|---|---|
| `background` | `#0F1117` | Page / scaffold background |
| `surface` | `#181B23` | Primary card surfaces |
| `surfaceElevated` | `#1E2230` | Modals, dropdowns, hover states |
| `surfaceOverlay` | `rgba(255,255,255,0.04)` | Hover overlays on interactive elements |

### Text
Three levels of text contrast on dark backgrounds.

| Token | Value | Usage |
|---|---|---|
| `textPrimary` | `#F1F5F9` | Headings, primary body text |
| `textSecondary` | `#94A3B8` | Labels, metadata, timestamps |
| `textMuted` | `#64748B` | Disabled text, hints, footers |

### Borders
Subtle white-alpha borders for structure without harsh lines.

| Token | Value | Usage |
|---|---|---|
| `border` | `rgba(255,255,255,0.08)` | Card borders, dividers |
| `borderSubtle` | `rgba(255,255,255,0.04)` | Internal section dividers |
| `borderFocus` | `rgba(255,255,255,0.16)` | Focused / active element borders |

### Category Accent Colors
Each debt category has a signature color used for left accents, glows, badges, and headers.

| Category | Emoji | Color | Hex |
|---|---|---|---|
| Review Debt | 🔴 | Red | `#EF4444` |
| Reply Debt | 🟠 | Orange | `#F97316` |
| Commitment Debt | 🟡 | Yellow | `#EAB308` |
| Staleness Debt | 🔵 | Blue | `#3B82F6` |
| Drift Debt | 🟣 | Purple | `#A855F7` |

Use each category color at **10–15% alpha** for card background tints and at **35% alpha** for borders.

### AI Accent
The AI Insight card uses a teal accent (`#0D9488`) to distinguish it from the five debt categories. Use this for the AI Insight header glow, step number badges, and any AI-generated content markers.

### Score Delta
- **Score increased** (debt got worse): `#EF4444` (red) with ↑ arrow
- **Score decreased** (debt improved): `#16A34A` (green) with ↓ arrow

---

## Typography

All text uses **Inter** via the `google_fonts` Dart package.

### Hierarchy

| Token | Size | Weight | Usage |
|---|---|---|---|
| `displayLg` | 48px | 800 | Landing page hero headline |
| `displaySm` | 36px | 700 | Section headers (FAQs, How it works) |
| `scoreLarge` | 56px | 800 | The big score number |
| `h1` | 28px | 700 | "Attention Debt Score" title |
| `h2` | 20px | 700 | Category card headings |
| `h3` | 16px | 700 | Debt item primary text |
| `bodyLg` | 16px | 500 | AI insight text, top action description |
| `bodyMd` | 14px | 500 | Debt item detail text |
| `bodySm` | 13px | 500 | Secondary metadata in rows |
| `label` | 12px | 800 | Section labels ("TOP PRIORITY", "AI INSIGHT"), uppercased, letter-spaced |
| `caption` | 11px | 600 | Timestamps, footer text |

### Rules
- Never use browser-default fonts — always `GoogleFonts.inter()`
- All uppercase labels must use `letterSpacing: 1.2` minimum
- Score numbers should use tabular (monospaced) figures if available
- Task IDs like `LIN-342` should visually stand out — consider a monospace or semi-bold treatment

---

## Layout

### Page Structure
- **Max content width**: `960px`, centered horizontally
- **Page padding**: `32px` horizontal, `24px` vertical
- **Section gap**: `40px` between major sections (score → top action → insight → categories)
- **Card gap**: `16px` between sibling debt category cards

### Content Zones (top to bottom)
1. **Navbar** — floating card pinned to top, logo + brand + live/mock toggle
2. **Score Header** — score number box + title + delta + timestamp
3. **Top Priority Banner** — highlighted urgent action with deep-link CTA
4. **AI Insight Card** — glassmorphic card with AI summary + numbered plan
5. **Debt Category Cards (×5)** — collapsible/expandable sections with item rows
6. **Footer** — "Powered by Coral" attribution

### Responsive Behavior
- At widths below `960px`, content fills available space with `24px` horizontal padding
- At widths above `1200px`, content remains centered at `960px` max-width
- No mobile breakpoints needed

---

## Elevation

Use layered surfaces instead of heavy drop shadows. The dark background naturally provides depth.

| Token | Shadow | Usage |
|---|---|---|
| `card` | `0 4px 24px rgba(0,0,0,0.25)` | Default card resting state |
| `cardHover` | `0 8px 32px rgba(0,0,0,0.35)` | Card hover state (clickable items) |
| `glow` | `0 0 32px rgba(13,148,136,0.08)` | AI insight card ambient glow |
| `categoryGlow` | `0 10px 32px rgba({category},0.10)` | Category-colored ambient glow on cards |

### Glassmorphism
- Apply `BackdropFilter(blur: 18px)` only on the AI Insight card and optionally the navbar
- Glass surface: `surfaceElevated` at **90% opacity** with a 1.5px gradient border
- Do NOT apply glass effects on debt category cards or rows — keep them opaque for readability

---

## Shapes

| Token | Radius | Usage |
|---|---|---|
| `sm` | `8px` | Small chips, badges, inline tags |
| `md` | `12px` | Buttons, input fields, internal containers |
| `lg` | `16px` | Score box, inner item containers |
| `xl` | `18px` | Primary cards, category cards, banners |
| `pill` | `999px` | Status badges, live/mock toggle pill |

---

## Components

### Navbar
- Floating card at the top of the page (not a standard AppBar)
- Contains: Logo/brand text "Drift" on the left, live/mock toggle on the right
- Height: `56px` inner content
- Background: `{surface}` with `{border}` border
- Corner radius: `{rounded.md}`

### Score Header
- Two-part layout: boxed score number on the left, title + delta text on the right
- Score box: `{surface}` background, `{border}` border, `{rounded.lg}` corners
- Score number: `{typography.scoreLarge}`, `{textPrimary}` color
- Delta: colored arrow + number, `{scoreUp}` or `{scoreDown}`
- Title: `{typography.h1}`, NOT `40px` (that was the old broken size)
- Timestamp: `{typography.caption}`, `{textMuted}` color

### Top Priority Banner
- Full-width card with category-colored gradient border glow
- Label: "TOP PRIORITY" in `{typography.label}` style
- Body: action text in `{typography.bodyLg}`
- CTA button: pill-shaped, `{surfaceOverlay}` background, category-colored border
- CTA label adapts by URL host: "Open in GitHub →", "Open in Linear →", etc.

### AI Insight Card
- Glassmorphic dark card with teal accent glow
- Header: "✨ AI INSIGHT" in `{typography.label}` with `{textSecondary}` color
- Body: insight text in `{typography.bodyLg}` with `{textPrimary}` color
- Separator: 1px line at `{borderSubtle}`
- Suggested plan: numbered steps with teal circle badges
- Step numbers: `{accent}` colored, `10px` font in an 18px circle
- Step text: `{typography.bodySm}`, `{textPrimary}` color

### Debt Category Card
- Container card for each of the 5 debt categories
- Header row: emoji + category label (`{typography.h2}`) + item count badge
- Left accent bar: 4px wide vertical strip in the category color
- Background: `{surface}` with `{border}`
- Corner radius: `{rounded.xl}`
- Category glow shadow using the category accent color
- Empty state: "✅ You're caught up — no items waiting for you"

### Debt Item Rows
All rows share a common structure: primary text line + secondary metadata line.
- Primary text: `{typography.h3}`, `{textPrimary}`
- Secondary text: `{typography.bodySm}`, `{textSecondary}`
- Cross-axis alignment: **start** (left-aligned), NOT center
- Clickable rows (Review, Staleness) should show a subtle hover state
- Rows are separated by 1px `{borderSubtle}` dividers

#### Review Debt Row
- `PR #482 · "Add rate limiting" · @amit`
- `acme/backend · ⏱ 6 days · 💬 3 Slack asks · ⛓ LIN-891`

#### Reply Debt Row
- `💬 Slack #design-review · @sarah · 3 days ago`
- `"Can you approve the API schema change?..."`

#### Commitment Debt Row
- `LIN-342 · "Migrate auth to OAuth2"`
- `Status: In Progress · Last commit: 12d ago`
- Warning badge if `daysStale >= 10`: "⚠️ No Git activity matching this task"

#### Staleness Debt Row
- `PR #461 · "Fix CORS headers" · acme/backend`
- `Open 8 days · 0 reviews`
- Tip if `reviews == 0`: "💡 Nobody's looking at it. Ping #frontend?"

#### Drift Debt Row
- `LIN-278 "Implement webhook retry" → marked Done`
- `but PR #445 is still open in GitHub`
- Contradiction: `⚠️ Task marked Done in Linear but PR #445 is still open` — styled in `{drift}` purple accent

### Live/Mock Toggle Badge
- Pill-shaped badge: `{rounded.pill}`
- Live mode: `{success}` green with pulsing fade animation
- Mock mode: `{textMuted}` gray, no animation
- Labels: "LIVE MODE" / "MOCK DATA" in `{typography.caption}`, uppercased, letter-spaced

### Footer
- Centered text: "Powered by Coral · github + linear + slack + notion"
- Style: `{typography.caption}`, `{textMuted}` color
- Bottom margin: `{spacing.xl}`

---

## Do's and Don'ts

### ✅ Do
- Pull ALL color values from the tokens above — zero hardcoded hex in widget files
- Use `{typography.label}` style for ALL section headers (uppercased, letter-spaced)
- Left-align all debt row content (`CrossAxisAlignment.start`)
- Cap content width at `960px` and center on the page
- Use the correct category accent color for each debt type
- Make Review and Staleness rows visually tappable (hover state, cursor pointer)
- Show a personalized greeting using the `user` field (e.g. "Good morning, agp")
- Handle nullable `url` fields gracefully — hide CTA button when URL is null

### ❌ Don't
- Don't use a light/white theme — the app is dark-mode only
- Don't modify `lib/models/drift_report.dart` — the data contract is immutable
- Don't modify `lib/services/report_loader.dart` — the data fetching logic is locked
- Don't modify `assets/mock_drift_report.json` — the mock data is locked
- Don't reference deleted assets (`logo.png`, `backgroundPattern.jpg`, `architecture_diagram.png`)
- Don't set `fontSize: 40` on the "Attention Debt Score" title — max `28px`
- Don't center-align multi-line text in debt rows — always left-align
- Don't use `BackdropFilter` on every card — reserve it for the AI Insight card only
- Don't mix dark-island widgets into a light page — the entire app is dark
- Don't forget the empty state for categories with 0 items

---

## Agent Prompt Guide

When generating or editing Flutter widgets for Drift, follow these rules:

1. **Import paths**: Use `package:drift/` imports (e.g. `package:drift/models/drift_report.dart`)
2. **Font usage**: Always use `GoogleFonts.inter()` — never use `TextStyle()` without it
3. **Color references**: Define colors as `static const Color` at the top of each widget class, matching the token names from YAML above
4. **Null safety**: The `url` field on `TopAction`, `ReviewDebt`, and `StalenessDebt` is nullable — always guard with `if (url != null && url.isNotEmpty)`
5. **URL launcher**: Use `launchUrl(uri, webOnlyWindowName: '_blank')` for external links
6. **Data loading**: `HomeView` must use `ReportLoader().loadMockReport()` for mock mode and `ReportLoader().fetchLiveReport()` for live mode, wrapped in a `FutureBuilder<DriftReport>`
7. **Build target**: `flutter build web` from the `frontend/` directory
8. **Dev server**: `flutter run -d chrome` from the `frontend/` directory
