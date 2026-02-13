# GUIDELINES.md — Development Conventions & Standards

## API Design Conventions

<!--
Standardize how every endpoint behaves. Agents reference this section for every implementation task.
Adjust these to fit your project's API style.
-->

- All responses: `{ success: boolean, data?: any, error?: { code: string, message: string } }`
- Pagination: `?page=1&limit=20` → `{ data, meta: { page, limit, total, totalPages } }`
- Filtering: query params (e.g., `?status=active&category=widgets`)
- Sorting: `?sort=created_at&order=desc`
- All timestamps ISO 8601 UTC
- All monetary amounts in cents (integer) — no floating point
- API versioning: `/api/v1/` prefix on all routes
- Consistent error codes across all endpoints

## Database Conventions

- UUIDs for all primary keys
- All tables: `created_at` and `updated_at` timestamps
- Soft deletes where appropriate (define which entities)
- Indexes on: all foreign keys, all `status` fields, frequently queried columns
- Database transactions for multi-table operations
- No raw SQL — parameterized queries or ORM only
- Reversible migrations — every up must have a down
- Connection pooling configured for expected load

## Security Standards

<!--
Define your security baseline. Every agent must follow these.
Adjust auth mechanisms, key sizes, rate limits to your project.
-->

- API keys: 32-byte random, stored as bcrypt hash, transmitted via `X-API-Key` header
- JWT: RS256, 1hr expiry, refresh token rotation
- Input validation: [validation library] schemas on every endpoint — no unvalidated input reaches service layer
- Rate limiting: [N] req/min per client for API, [N] req/min for webhook endpoints
- Webhook signature verification before processing
- CORS: allowed domains whitelist only
- No secrets in code or logs
- All external connections over TLS

## Coding Standards

<!--
Language-specific conventions. Add sections for each language in your project.
-->

### [Primary Language] Conventions

- [Linting/formatting tool and config]
- [Type safety requirements]
- [Documentation requirements: JSDoc/TSDoc/docstrings]
- [Import ordering conventions]
- [Error handling patterns]
- [Logging conventions]

## Pre-commit Hooks

<!--
Pre-commit hooks catch lint and format issues at commit time. This is especially
important for agent-dispatched work: when an agent runs `git commit`, the hook
runs automatically, fails with exact errors, and the agent can self-correct
without coordinator intervention.

Hooks are stored in `.git/hooks/` and shared across git worktrees, making them
compatible with the parallel agent dispatch pattern.
-->

**Recommended setup:** Use the [`pre-commit`](https://pre-commit.com/) framework.

```bash
pip install pre-commit
pre-commit install
```

**Starter `.pre-commit-config.yaml`** (customize for your stack):

```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.9.1
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format
```

**Rules:**
- Agents MUST fix hook failures and re-commit. Never use `--no-verify`.
- Keep hooks fast (lint + format only). Heavy checks (mypy, full test suite) stay in CI.
- All team members and agents share the same hook configuration via `.pre-commit-config.yaml`.

## Testing Strategy

- **Unit tests:** Service layer functions, business logic, pure functions
- **Integration tests:** API endpoints against real database (test containers)
- **E2E tests:** Full lifecycle flows
- **Load tests:** Critical paths under concurrent access
- **Coverage targets:** [N]% service layer, [N]% overall

### Critical Test Scenarios

<!--
List the 4-8 most important test scenarios that MUST pass. These represent the highest-risk paths.

Example:
1. Two users perform conflicting action simultaneously — verify no data corruption
2. Refund on complex order — verify correct amounts to correct accounts
3. External service goes down mid-operation — verify graceful handling
4. Permission boundary — verify unauthorized access blocked
-->

## Environment Variables

<!--
Define all required environment variables. This is the canonical list — agents reference it for config.

```env
# Core
NODE_ENV=development
PORT=3000
DATABASE_URL=postgresql://user:pass@localhost:5432/dbname

# Auth
JWT_PRIVATE_KEY_PATH=./keys/private.pem
JWT_PUBLIC_KEY_PATH=./keys/public.pem

# External Services
# [SERVICE]_API_KEY=...
# [SERVICE]_WEBHOOK_SECRET=...
```
-->
