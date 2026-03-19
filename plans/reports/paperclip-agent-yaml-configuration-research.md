# Paperclip AI Agent YAML Configuration Research Report

**Date:** 2026-03-16
**Research Scope:** Agent configuration in Paperclip AI orchestration platform
**Status:** Complete

---

## Executive Summary

Paperclip AI is an open-source Node.js/React platform for multi-agent orchestration. Agent configuration is **database-driven** (via Prisma ORM with PostgreSQL), **not** YAML-based. Configuration primarily occurs through:
1. Web UI dashboard (add agents, configure adapters, set budgets)
2. JSON-based API payloads (for CLI/programmatic access)
3. Export/import feature with JSON schema (not YAML)

**Key Finding:** There is no `agents.yaml` file in Paperclip. Configuration is stored in PostgreSQL and managed through the web interface or JSON APIs.

---

## 1. File Location & Configuration Storage

### Location Structure
- **Configuration Type:** Database-driven (PostgreSQL + Prisma ORM)
- **No YAML File:** Paperclip does not use `agents.yaml` or similar YAML configuration files
- **Local Data Storage:** When running locally, embedded PostgreSQL stores all agent configurations
- **Production:** Point Paperclip to your own PostgreSQL database
- **Workspace Directory:** Agent sessions/context stored in `~/.paperclip/workspace/` or similar local paths

### Configuration Access
- **Primary Interface:** Web UI at `http://localhost:3000` (after `npx paperclipai onboard`)
- **Database Layer:** Direct Prisma queries (schema not publicly exposed in detail)
- **API Endpoints:** RESTful JSON-based endpoints for agent management

---

## 2. Import/Load Configuration

### How Configurations Are Loaded
1. **Automatic Detection:** On first run, `npx paperclipai onboard --yes` creates the database and initializes the system
2. **No CLI Auto-detection:** Paperclip doesn't scan for YAML files; all config is database queries
3. **Export/Import Feature:** Full org structures, agents, and skills can be exported/imported as JSON bundles

### Import/Export Process
```bash
# Quick start with auto database setup
npx paperclipai onboard --yes

# Launches web UI in browser for all configuration
# No CLI import needed—UI handles everything
```

### Export/Import Capabilities
- Export entire orgs, agents, and skills with secret scrubbing
- Pre-built company templates available for import
- Collision handling for duplicate agent names
- Full org structures imported in seconds

---

## 3. Agent Configuration Schema

### Core Agent Properties (JSON Structure)

Based on the Hermes adapter example and CLI design patterns:

```json
{
  "id": "uuid",
  "companyId": "uuid",
  "name": "Agent Name",
  "role": "CEO | CTO | Developer | etc",
  "title": "Full job title",
  "status": "active | inactive",
  "reportsTo": "parent-agent-id",
  "reportingAgents": ["child-agent-id-1", "child-agent-id-2"],
  "adapterType": "claude_local | codex_local | process | http | opencode_local | pi_local | cursor | openclaw_gateway | hermes_local",
  "adapterConfig": {
    // Varies by adapter type
  },
  "runtimeConfig": {
    // Runtime-specific settings
  },
  "monthlyTokenBudget": 1000000,
  "secrets": {
    // Secret references (not stored directly)
  },
  "description": "What this agent does",
  "heartbeatSchedule": "* * * * *",  // Cron expression
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Adapter-Specific Configurations

#### Claude Code Adapter (claude_local)
```json
{
  "adapterConfig": {
    "model": "claude-3-5-sonnet",
    "systemPrompt": "Custom instruction text",
    "contextWindows": 200000
  }
}
```

#### Hermes Agent Adapter (hermes_local)
```json
{
  "adapterConfig": {
    "model": "anthropic/claude-sonnet-4",
    "maxIterations": 50,
    "timeoutSec": 300,
    "persistSession": true,
    "enabledToolsets": ["terminal", "file", "web", "code", "vision"]
  }
}
```

#### HTTP Webhook Adapter (http)
```json
{
  "adapterConfig": {
    "webhookUrl": "https://example.com/agent/heartbeat",
    "authType": "bearer | basic",
    "timeout": 300
  }
}
```

#### Process Adapter (process)
```json
{
  "adapterConfig": {
    "command": "python script.py",
    "workingDirectory": "/path/to/project",
    "env": {
      "KEY": "value"
    }
  }
}
```

### Heartbeat Configuration

**Schedule Format:** Standard 5-field cron expression (`* * * * *`)
- Examples:
  - `0 * * * *` = Every hour
  - `0 9 * * *` = Daily at 9 AM
  - `0 9 * * 1-5` = Weekdays at 9 AM
  - `*/15 * * * *` = Every 15 minutes

**Trigger Types:**
1. **Scheduled:** Runs on cron interval
2. **Event-Based:** Triggers on task assignment or @-mention
3. **Manual:** Can be triggered through UI

---

## 4. CLI Commands for Agent Management

### Current CLI Commands (Implemented)

```bash
# List all agents
paperclip agent list --company-id <uuid>

# Get specific agent details
paperclip agent get --company-id <uuid> --agent-id <uuid>

# Local CLI access (run agent commands)
paperclip agent local-cli --company-id <uuid> --agent-id <uuid>
```

### Planned CLI Commands (Issue #369)

**Agent Create:**
```bash
paperclip agent create \
  --company-id <uuid> \
  --name "Agent Name" \
  --adapter-type claude_local \
  --role CEO \
  --title "Chief Executive Officer" \
  --reports-to <parent-agent-id> \
  --adapter-config '{"model":"claude-3-5-sonnet"}' \
  --runtime-config '{"schedule":"0 * * * *"}' \
  --budget 1000000
```

**Agent Update:**
```bash
paperclip agent update \
  --company-id <uuid> \
  --agent-id <uuid> \
  --name "New Name" \
  --budget 2000000 \
  --adapter-config @path/to/config.json
```

**Agent Delete:**
```bash
paperclip agent delete \
  --company-id <uuid> \
  --agent-id <uuid>
```

**Note:** Config file references use `@path/to/file.json` syntax for file-based JSON configs.

### Setup & Onboarding

```bash
# Interactive setup (recommended)
npx paperclipai onboard

# Automated setup with defaults
npx paperclipai onboard --yes

# Running the system
pnpm dev          # Development mode
npm start         # Production mode
```

---

## 5. Supported Adapter Types

Paperclip supports multiple runtime adapters:

| Adapter Type | Runtime | Description |
|---|---|---|
| `claude_local` | Claude Code | Local Claude Code execution |
| `codex_local` | Codex | Local Codex agent |
| `opencode_local` | OpenCode | Open-source code executor |
| `pi_local` | PI | PI platform integration |
| `cursor` | Cursor Editor | Cursor IDE integration |
| `http` | HTTP Webhook | External HTTP endpoint |
| `process` | Shell Process | Local command execution |
| `openclaw_gateway` | OpenClaw | OpenClaw agent gateway |
| `hermes_local` | Hermes | Hermes agent (Nous Research) |

---

## 6. Community Examples & References

### Hermes Paperclip Adapter
**Repository:** [NousResearch/hermes-paperclip-adapter](https://github.com/NousResearch/hermes-paperclip-adapter)

**Example Agent Config:**
```json
{
  "name": "Hermes Engineer",
  "adapterType": "hermes_local",
  "adapterConfig": {
    "model": "anthropic/claude-sonnet-4",
    "maxIterations": 50,
    "timeoutSec": 300,
    "persistSession": true,
    "enabledToolsets": ["terminal", "file", "web"]
  }
}
```

### Agent Paperclip (Desktop Companion)
**Repository:** [fredruss/agent-paperclip](https://github.com/fredruss/agent-paperclip)

**Note:** This is a separate desktop monitoring tool for Claude Code/Codex, not the Paperclip orchestration platform itself. It monitors agent status without requiring terminal access.

### Paperclip Main Repository
**Repository:** [paperclipai/paperclip](https://github.com/paperclipai/paperclip)
- Contains all agent adapter implementations
- Prisma schema definitions (database models)
- API endpoint definitions
- Example company templates for import

---

## 7. Key Configuration Concepts

### Organization Chart & Hierarchy
- Agents have reporting lines (CEO → CTO → Developers)
- Each agent has `reportsTo` field (parent agent ID)
- `reportingAgents` array shows direct reports
- Structure enforced at database level

### Budget Management
- Monthly token budget per agent
- Automatic halt at budget limit
- Warnings at 80% utilization
- Budget tracking in real-time dashboard

### Secret Management
- Secrets stored with local encryption
- Only secret references persisted in agent config
- Support for environment variable references
- No plaintext credentials in config

### Task & Goal Alignment
- Company mission cascades to projects → tasks
- Each agent sees context of their assigned work
- Task checkout prevents duplicate work
- Atomic operations ensure consistency

### Approval Workflows
- Config changes are revisioned
- Bad changes can be rolled back
- Approval gates enforced at governance level
- Complete audit trail maintained

---

## 8. Project Setup & Requirements

### System Requirements
- **Node.js:** 20+
- **Package Manager:** pnpm 9.15+
- **Database:** PostgreSQL (embedded locally, or external in production)

### Quick Start
```bash
# One-line setup
npx paperclipai onboard --yes

# Manual setup
git clone https://github.com/paperclipai/paperclip
cd paperclip
pnpm install
pnpm dev

# Access at http://localhost:3000
```

### Database
- **Local:** Automatic embedded PostgreSQL (no configuration needed)
- **Production:** Point `DATABASE_URL` to your own PostgreSQL instance

---

## 9. Documentation Resources

### Official Sources
1. **GitHub Repository:** [paperclipai/paperclip](https://github.com/paperclipai/paperclip)
   - Source code with all adapters and schema
   - AGENTS.md documentation
   - core-concepts.md for architectural details
   - docs/guides/agent-developer/ for developer guides

2. **Official Website:** [paperclip.ing](https://paperclip.ing/)
   - High-level overview
   - Links to full documentation

3. **Tutorial Site:** [paperclipai.info](https://paperclipai.info/)
   - 7-day structured learning path
   - Conceptual overview (Days 1-4 available, Days 5-7 coming soon)

4. **GitHub Issues:** [Issue #369](https://github.com/paperclipai/paperclip/issues/369)
   - Details on planned CLI commands
   - Agent creation/update/delete specifications

### Community Projects
- Hermes Paperclip Adapter: [NousResearch/hermes-paperclip-adapter](https://github.com/NousResearch/hermes-paperclip-adapter)
- Agent Paperclip Desktop: [fredruss/agent-paperclip](https://github.com/fredruss/agent-paperclip)

---

## 10. Unresolved Questions & Gaps

1. **Exact Prisma Schema:** Complete database schema definition not publicly exposed in detail. Found references to agent, company, and skill tables, but full schema available only in source code.

2. **Advanced Heartbeat Options:** Whether cron supports non-standard syntax (e.g., timezone offsets, stepped ranges) not documented in available sources.

3. **Custom Adapter Development:** Complete guide for building custom adapters not yet found. Only Hermes example available.

4. **Secrets Management Details:** How secret references work exactly (syntax, storage, rotation) not fully documented.

5. **CLI Status:** Issue #369 indicates agent create/update/delete commands are still planned. Current release status unknown (check latest GitHub releases).

6. **Production Deployment:** Specific guidance on deploying Paperclip to cloud providers (AWS, GCP, Azure) not covered in search results.

---

## Conclusion

**Paperclip AI uses a database-driven configuration model, not YAML files.** All agent setup is managed through:
- **Web UI** for interactive configuration
- **JSON APIs** for programmatic access
- **Export/Import** for bulk org structures

There is **no `agents.yaml` file**. Configuration lives in PostgreSQL and is accessed through the web dashboard or planned CLI commands. The platform emphasizes organizational structure (reporting lines, budgets, governance) over file-based config, making it suitable for complex multi-agent orchestration scenarios.

---

## Sources

- [GitHub - paperclipai/paperclip](https://github.com/paperclipai/paperclip)
- [Paperclip Official Site](https://paperclip.ing/)
- [Paperclip Tutorial](https://paperclipai.info/)
- [GitHub - NousResearch/hermes-paperclip-adapter](https://github.com/NousResearch/hermes-paperclip-adapter)
- [GitHub - fredruss/agent-paperclip](https://github.com/fredruss/agent-paperclip)
- [GitHub Issue #369 - Agent CLI Commands](https://github.com/paperclipai/paperclip/issues/369)
