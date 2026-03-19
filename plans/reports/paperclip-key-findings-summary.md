# Paperclip AI Agent Configuration - Key Findings Summary

## Quick Answer to Your Questions

### 1. Where does the agents.yaml file go?
**Answer:** There is NO `agents.yaml` file in Paperclip AI. Configuration is database-driven (PostgreSQL), not YAML-based.

### 2. How to import/load YAML agent configs?
**Answer:** Import/export feature uses **JSON**, not YAML. Export full org structures and import them via UI or (planned) CLI.

### 3. Full YAML schema for agent configuration?
**Answer:** Not YAML. Agent configuration is JSON-based with these main fields:
- `name`, `role`, `title`, `status`
- `adapterType`, `adapterConfig` (varies by adapter)
- `runtimeConfig`, `monthlyTokenBudget`
- `reportsTo` (parent agent)
- `heartbeatSchedule` (cron expression)

### 4. Examples of agents.yaml in the wild?
**Answer:** No YAML examples found. Only JSON examples:
- Hermes adapter example in [NousResearch/hermes-paperclip-adapter](https://github.com/NousResearch/hermes-paperclip-adapter)
- CLI proposal in Issue #369 uses JSON configs

### 5. CLI commands related to agent management?
**Answer:**
- **Current:** `agent list`, `agent get`, `agent local-cli`
- **Planned (Issue #369):** `agent create`, `agent update`, `agent delete`

---

## Architecture Overview

```
┌─────────────────────────────────────────┐
│      Paperclip Web UI (React)          │
│   http://localhost:3000                │
│  - Add/edit agents                     │
│  - Set budgets & schedules             │
│  - Configure adapters                  │
└────────────────┬────────────────────────┘
                 │
          ┌──────▼──────┐
          │  JSON API   │
          │ Endpoints   │
          └──────┬──────┘
                 │
    ┌────────────▼────────────┐
    │   PostgreSQL Database   │
    │  (Prisma ORM)           │
    │                         │
    │  - agents table         │
    │  - companies table      │
    │  - skills table         │
    │  - tasks table          │
    │  - heartbeat_logs table │
    └────────────┬────────────┘
                 │
    ┌────────────▼────────────┐
    │   Agent Adapters        │
    │  (Multiple Runtimes)    │
    │                         │
    │  - Claude Code          │
    │  - Hermes               │
    │  - OpenCode             │
    │  - HTTP Webhooks        │
    │  - Shell Processes      │
    └─────────────────────────┘
```

---

## Configuration Workflow

### Standard Flow
```
1. Run: npx paperclipai onboard --yes
   ↓
2. Opens web UI at localhost:3000
   ↓
3. Create company → Set mission
   ↓
4. Add agents → Configure each:
   - Role & title
   - Adapter type (Claude, Hermes, HTTP, etc)
   - Adapter-specific config (model, settings)
   - Monthly budget
   - Heartbeat schedule (cron expression)
   ↓
5. Config stored in PostgreSQL
   ↓
6. Agents execute on scheduled heartbeats
```

### Programmatic Flow (Planned)
```
CLI Commands (Issue #369):

$ paperclip agent create \
  --company-id <uuid> \
  --name "CEO Agent" \
  --adapter-type claude_local \
  --adapter-config @config.json \
  --budget 1000000

$ paperclip agent update \
  --agent-id <uuid> \
  --budget 2000000

$ paperclip agent delete \
  --agent-id <uuid>
```

---

## Agent Configuration Schema (JSON)

```json
{
  "name": "string",
  "role": "CEO | CTO | Developer | etc",
  "title": "string",
  "adapterType": "claude_local | hermes_local | http | process | openclaw_gateway",

  "adapterConfig": {
    "// Varies by adapterType"
  },

  "monthlyTokenBudget": 1000000,
  "heartbeatSchedule": "0 * * * *",  // Cron format
  "reportsTo": "parent-agent-uuid",
  "status": "active | inactive"
}
```

---

## Adapter Types & Examples

| Type | Runtime | Example Config |
|------|---------|---|
| `claude_local` | Claude Code | `{"model": "claude-3-5-sonnet"}` |
| `hermes_local` | Hermes Agent | `{"model": "anthropic/claude-sonnet-4", "maxIterations": 50}` |
| `http` | Webhook | `{"webhookUrl": "https://example.com/agent"}` |
| `process` | Shell Script | `{"command": "python script.py"}` |
| `openclaw_gateway` | OpenClaw | `{"apiKey": "secret"}` |

---

## Heartbeat Scheduling (Cron Format)

```
┌───────────── minute (0 - 59)
│ ┌───────────── hour (0 - 23)
│ │ ┌───────────── day of month (1 - 31)
│ │ │ ┌───────────── month (1 - 12)
│ │ │ │ ┌───────────── day of week (0 - 6) (Sunday to Saturday)
│ │ │ │ │
│ │ │ │ │
* * * * *

Examples:
0 * * * *     → Every hour
0 9 * * *     → Daily at 9 AM
0 9 * * 1-5   → Weekdays at 9 AM
*/15 * * * *  → Every 15 minutes
```

---

## Key Architectural Decisions

### 1. Database-First Design
- All config stored in PostgreSQL
- No static YAML/JSON files (except export)
- Real-time validation & consistency

### 2. UI-Centric Management
- Web UI is primary config interface
- CLI support still in development
- Easy for non-technical users

### 3. Adapter-Based Extensibility
- Pluggable runtime adapters
- Support for 8+ agent types
- Custom adapters possible (see Hermes example)

### 4. Heartbeat Model
- Scheduled execution (cron-based)
- Event-triggered execution (@mentions, task assignment)
- Session persistence across heartbeats

### 5. Atomic Operations
- Budget enforcement
- Preventing duplicate work (task checkout)
- Governance approval gates

---

## Development & Deployment

### Local Development
```bash
git clone https://github.com/paperclipai/paperclip
cd paperclip
pnpm install
pnpm dev
# Opens http://localhost:3000
```

### Production Deployment
- Point `DATABASE_URL` to production PostgreSQL
- Deploy Node.js application to your infrastructure
- Self-hosted only (no SaaS offering)

---

## Import/Export Capabilities

### What Can Be Exported
- Entire organization structures
- Agent configurations
- Skill definitions
- Company templates

### Export Process
1. UI → Settings → Export Organization
2. Downloads JSON bundle with all configs
3. Secrets are scrubbed (not exported)

### Import Process
1. UI → Import → Select JSON file
2. Handles collisions automatically
3. Full org structure imported in seconds

---

## Current vs Planned Features

### ✅ Already Implemented
- Web UI for agent management
- Database storage of configurations
- Multiple adapter types (8+)
- Heartbeat scheduling
- Export/import with JSON
- Budget enforcement
- Approval workflows

### 🚧 In Development (Issue #369)
- `agent create` CLI command
- `agent update` CLI command
- `agent delete` CLI command
- File-based config references (`@path/to/config.json`)

### ❓ Not Yet Documented
- Complete Prisma schema (in source code only)
- Custom adapter development guide
- Advanced secrets management syntax
- Cloud deployment guidelines

---

## Critical Insight

**Paperclip is not a CLI-first or YAML-based tool.** It's a **web-based multi-agent orchestration platform** where configuration is stored in a database. The team is _planning_ to add CLI support, but as of now, the primary interface is the web UI.

If you need YAML-based agent configuration, you might want to consider alternatives or wait for the CLI commands to be fully implemented.

---

## References

1. [GitHub: paperclipai/paperclip](https://github.com/paperclipai/paperclip)
2. [Official: paperclip.ing](https://paperclip.ing/)
3. [Tutorial: paperclipai.info](https://paperclipai.info/)
4. [Hermes Adapter: NousResearch/hermes-paperclip-adapter](https://github.com/NousResearch/hermes-paperclip-adapter)
5. [CLI Enhancement: Issue #369](https://github.com/paperclipai/paperclip/issues/369)
