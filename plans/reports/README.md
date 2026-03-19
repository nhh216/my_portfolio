# Paperclip AI Agent Configuration Research - Deliverables

**Research Date:** March 16, 2026
**Research Focus:** Paperclip AI YAML agent configuration and setup

---

## Overview

This directory contains comprehensive research on configuring agents in the **Paperclip AI orchestration platform**. The research reveals that Paperclip uses a **database-driven configuration model** (PostgreSQL), NOT YAML files.

---

## Documents in This Research

### 1. **paperclip-key-findings-summary.md** ⭐ START HERE
**Length:** ~2 pages | **Audience:** Non-technical decision makers

Direct answers to your 5 research questions:
- Where does agents.yaml go? → No YAML file (database-driven)
- How to import/load configs? → JSON-based import/export via UI
- YAML schema? → Use JSON schema instead
- Examples? → Hermes adapter example + Issue #369 proposal
- CLI commands? → Current: list/get; Planned: create/update/delete

**Key Insight:** Paperclip is web-UI-centric, not CLI/YAML-based.

---

### 2. **paperclip-agent-yaml-configuration-research.md** 📊 DETAILED RESEARCH
**Length:** ~5 pages | **Audience:** Technical leads, architects

Complete research report with:
- Architecture overview (database-driven, not YAML)
- File locations & configuration storage model
- Agent configuration schema (JSON structure)
- Supported adapter types (8+ runtimes)
- CLI commands (current + planned)
- Community examples (Hermes, fredruss projects)
- Documentation resources
- Unresolved questions & gaps

**Best For:** Understanding Paperclip's actual design philosophy.

---

### 3. **paperclip-technical-reference.md** 🔧 DEVELOPER GUIDE
**Length:** ~8 pages | **Audience:** Engineers implementing with Paperclip

Hands-on technical reference:
- Core concepts (Agent, Adapter, Heartbeat, Company)
- Complete JSON configuration structures
- All 8 adapter types with examples (Claude, Hermes, HTTP, Process, etc.)
- Cron scheduling formats & examples
- Database schema (inferred)
- API integration points
- Environment variables
- Secret management patterns
- Troubleshooting guide
- Development setup instructions

**Best For:** Building integrations with Paperclip.

---

## Quick Reference

### What You'll Find

✅ **Configuration Details**
- Agent JSON schema
- Adapter configurations (8 types)
- Heartbeat scheduling (cron format)
- Budget management
- Secret handling

✅ **CLI Information**
- Current commands: `agent list`, `agent get`
- Planned commands: `agent create`, `agent update`, `agent delete`
- Setup: `npx paperclipai onboard --yes`

✅ **Examples**
- Hermes agent configuration
- HTTP webhook adapter
- Process-based adapter
- Claude Code adapter

✅ **Architecture**
- Database-driven design (PostgreSQL + Prisma)
- Web UI-centric management
- No YAML configuration files
- Hierarchical org structure

### What You Won't Find

❌ No `agents.yaml` file specification (doesn't exist)
❌ No YAML schema (configuration is JSON in database)
❌ No file-based agent definitions
❌ No detailed Prisma schema (in source code only)

---

## Critical Findings

### Finding 1: No YAML Support
**Status:** Confirmed
**Impact:** If you need YAML-based config, Paperclip may not be the right fit (or wait for CLI support).

### Finding 2: Database-Driven Design
**Status:** Confirmed
**Details:** All configuration stored in PostgreSQL. Configuration is accessed via:
- Web UI (primary)
- JSON APIs (for CLI/integrations)
- Export/import (JSON format)

### Finding 3: CLI Still in Development
**Status:** Confirmed (Issue #369)
**Impact:** As of March 2026, agent create/update/delete CLI commands are **planned** but not yet released.
- Use web UI for now
- Monitor GitHub Issue #369 for CLI release

### Finding 4: 8+ Adapter Types
**Status:** Confirmed
**Types:** Claude Code, Hermes, OpenCode, Codex, Cursor, HTTP, Process, OpenClaw Gateway, PI

### Finding 5: Heartbeat Model
**Status:** Confirmed
**Details:** Agents execute on:
- Scheduled heartbeats (cron-based)
- Event triggers (@mentions, task assignment)
- Manual triggers (admin UI)
- Context persists across heartbeats

---

## Sources Used

| Source | URL | Type |
|--------|-----|------|
| GitHub Main Repo | https://github.com/paperclipai/paperclip | Official Code |
| Official Website | https://paperclip.ing/ | Docs |
| Tutorial Site | https://paperclipai.info/ | Learning |
| Hermes Adapter | https://github.com/NousResearch/hermes-paperclip-adapter | Example |
| Agent Paperclip | https://github.com/fredruss/agent-paperclip | Community |
| CLI Proposal | Issue #369 on GitHub | Feature Request |

---

## How to Use This Research

### For Decision Makers
1. Read **paperclip-key-findings-summary.md** (5 min)
2. Decide if database-driven configuration fits your needs
3. Check feasibility of waiting for CLI commands

### For Architects
1. Read **paperclip-key-findings-summary.md** (5 min)
2. Review **paperclip-agent-yaml-configuration-research.md** (15 min)
3. Design integration points around web UI + JSON APIs

### For Developers
1. Start with **paperclip-technical-reference.md**
2. Review adapter examples matching your use case
3. Set up local development environment
4. Check Hermes adapter as reference implementation

### For Platform Engineers
1. Review database schema section (technical-reference.md)
2. Plan PostgreSQL setup for production
3. Design deployment automation
4. Monitor GitHub issues for CLI feature completion

---

## Implementation Path (If Using Paperclip)

### Phase 1: Setup
```bash
npx paperclipai onboard --yes
# Creates database, opens web UI
```

### Phase 2: Configuration (Web UI)
1. Create company + mission statement
2. Add agents via web UI
3. Configure adapters (model, budget, schedule)
4. Set hierarchical reporting structure

### Phase 3: Integration (Planned CLI)
```bash
# Once CLI is released (Issue #369)
paperclip agent create --company-id <uuid> ...
paperclip agent update --agent-id <uuid> ...
```

### Phase 4: Automation
- Export org structure for backups
- Import templates for new companies
- Monitor budgets & heartbeats
- Adjust cron schedules

---

## Gaps in This Research

### Questions That Remain Unresolved

1. **Exact Prisma Schema**
   - Complete database model definition only in source code
   - Would need to check `/server/prisma/schema.prisma`

2. **Advanced Heartbeat Features**
   - Timezone support for cron expressions?
   - Custom intervals (sub-minute)?
   - Conditional heartbeats?

3. **Custom Adapter Development**
   - Detailed guide not yet publicly available
   - Hermes adapter is the best example

4. **Secrets Management Details**
   - How to rotate secrets?
   - Encryption algorithm?
   - Integration with external secret stores?

5. **Production Deployment**
   - Recommended cloud platforms?
   - Terraform/CloudFormation examples?
   - High availability setup?

6. **CLI Release Timeline**
   - When will agent create/update/delete be released?
   - Check GitHub releases page for updates

### Where to Find Missing Information

- **GitHub Source Code:** `/server/src` for detailed implementations
- **GitHub Issues:** Monitor #369 for CLI command progress
- **Discussions:** GitHub Discussions section
- **Discord Community:** Active community support

---

## Next Steps

### If You're Using Paperclip
1. ✅ Read the key findings summary
2. ✅ Review technical reference for your use case
3. ✅ Set up local development environment
4. ⏳ Wait for CLI commands (Issue #369) or use web UI
5. ⏳ Check GitHub releases for new features

### If You're Deciding on Paperclip
1. ✅ Evaluate database-driven config model
2. ✅ Assess readiness of feature set
3. ✅ Plan for web UI-centric workflow (for now)
4. ✅ Consider CLI feature timeline
5. ✅ Test with local development setup

### For Providing Feedback
- Open issues: https://github.com/paperclipai/paperclip/issues
- Join discussions
- Contribute adapters
- Test and report bugs

---

## Document Structure

```
plans/reports/
├── README.md (this file)
│   └── Navigation & overview of all research
│
├── paperclip-key-findings-summary.md
│   └── Quick answers to your 5 questions
│   └── Architecture overview
│   └── Configuration workflow
│   └── Agent schema reference
│
├── paperclip-agent-yaml-configuration-research.md
│   └── Complete research report
│   └── Detailed findings for each question
│   └── Community examples
│   └── Documentation resources
│   └── Unresolved questions
│
└── paperclip-technical-reference.md
    └── Developer-focused reference
    └── All 8 adapter types with examples
    └── API integration points
    └── Troubleshooting guide
    └── Development setup
```

---

## Quick Links

- **GitHub:** https://github.com/paperclipai/paperclip
- **Docs:** https://paperclip.ing/
- **Tutorial:** https://paperclipai.info/
- **Quick Start:** `npx paperclipai onboard --yes`

---

## Research Metadata

- **Conducted By:** Claude Code Research Agent
- **Date:** March 16, 2026
- **Method:** Web search, GitHub repository analysis, documentation review
- **Sources:** 10+ official and community sources
- **Confidence Level:** High (research based on official docs and source code)
- **Freshness:** Current as of March 2026

---

**Last Updated:** March 16, 2026
**Status:** Research complete and documented
