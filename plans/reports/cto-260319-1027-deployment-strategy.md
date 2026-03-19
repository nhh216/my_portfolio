# Deployment Strategy: Flutter Web App

## Project Summary
- **Flutter**: 3.41.4 stable
- **Dart SDK**: ^3.11.1
- **Router**: go_router (requires hash URL strategy for static hosting)
- **Dependencies**: dio, hive_flutter, google_fonts, riverpod (all web-compatible)
- **Git remote**: Not configured yet

## Options Evaluation

| Criteria | GitHub Pages | Firebase Hosting | Vercel |
|---|---|---|---|
| Free tier | Yes (unlimited) | Yes (10GB/mo) | Yes (100GB/mo) |
| Custom domain | Yes | Yes | Yes |
| Auto-deploy on push | Yes (Actions) | Requires CLI/Actions | Requires adapter |
| Backend needed | No | No | No |
| Setup complexity | Low (4 steps) | Medium (6 steps) | Medium (5 steps) |
| Flutter web support | Native via Actions | Native via CLI | Needs build config |

## Decision: GitHub Pages + GitHub Actions

**Rationale**: Simplest option, zero cost, zero backend, native CI/CD via Actions, and the project already needs a GitHub repo for hosting source code. Single platform for code + hosting.

## URL Strategy Requirement

`go_router` defaults to path-based URLs which break on GitHub Pages (404 on refresh). Must use hash URL strategy.

**File**: `lib/main.dart` -- add before `runApp()`:
```dart
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
usePathUrlStrategy(); // or setUrlStrategy(HashUrlStrategy()) for hash-based
```

For GitHub Pages, use `HashUrlStrategy()` to avoid 404s on page refresh. If using custom domain with proper server config, `PathUrlStrategy` works.

## Deployment Steps (8 steps)

### Step 1: Create GitHub repo
```bash
cd /Users/hung/Desktop/Project/my_portfolio
git init
git add -A
git commit -m "Initial commit"
gh repo create my_portfolio --public --source=. --push
```

### Step 2: Verify web build locally
```bash
flutter build web --release --base-href "/my_portfolio/"
```

### Step 3: Create GitHub Actions workflow
```bash
mkdir -p .github/workflows
```

Write `.github/workflows/deploy-web.yml`:
```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.41.4'
          channel: 'stable'
      - run: flutter pub get
      - run: flutter build web --release --base-href "/my_portfolio/"
      - uses: actions/upload-pages-artifact@v3
        with:
          path: build/web

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - id: deployment
        uses: actions/deploy-pages@v4
```

### Step 4: Enable GitHub Pages
```bash
gh api repos/{owner}/my_portfolio/pages -X POST -f source='{"type":"workflow"}' || true
```
Or: GitHub repo Settings > Pages > Source: "GitHub Actions"

### Step 5: Push and deploy
```bash
git add .github/workflows/deploy-web.yml
git commit -m "ci: add GitHub Pages deployment workflow"
git push
```

### Step 6: Verify deployment
Site will be live at: `https://{username}.github.io/my_portfolio/`

### Step 7 (optional): Custom domain
```bash
echo "yourdomain.com" > CNAME
# Update DNS: CNAME record pointing to {username}.github.io
# Change --base-href to "/" in workflow
```

### Step 8 (optional): Update base-href for custom domain
In workflow, change `--base-href "/my_portfolio/"` to `--base-href "/"`.

## Notes
- Build output goes to `build/web/` (~5-15MB typical)
- Google Fonts fetched at runtime; no bundle size concern
- Hive uses IndexedDB on web; works without backend
- Dio HTTP calls require CORS on target APIs
- Auto-deploys on every push to `main`
