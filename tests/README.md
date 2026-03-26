# tests/

This directory consolidates all test infrastructure and generated output artifacts.

## Structure

| Path | Purpose |
|------|---------|
| `e2e/` | Playwright end-to-end test specs |
| `playwright.config.ts` | Playwright configuration (testDir → `./e2e`) |
| `playwright-report/` | HTML report from last Playwright run (generated, gitignored) |
| `test-results/` | Playwright trace/video artifacts (generated, gitignored) |
| `test-api.js` | Manual API smoke test |
| `test-bq*.js` | BigQuery connectivity tests |
| `test-raw-ws.mjs` | Raw WebSocket handshake test |
| `test-ws.mjs` | Application WebSocket integration test |

## Running E2E Tests

```bash
npx playwright test --config=tests/playwright.config.ts
```

## Note

Log files, output dumps, and Lighthouse reports are gitignored via `.gitignore → tests/*`.
