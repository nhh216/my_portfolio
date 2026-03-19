# Paperclip AI Agent Orchestration: Research Report

**Date**: 2026-03-16
**Subject**: Comprehensive research on Paperclip agent orchestration platform
**Status**: Complete

---

## Executive Summary

Paperclip is an open-source Node.js/React orchestration platform that manages teams of AI agents as an automated company. Rather than running isolated agents, Paperclip provides a governance layer that coordinates multiple AI agents with org charts, budgets, goals, and task delegation—enabling "zero-human companies" where AI agents handle business operations autonomously.

**Key Insight**: Paperclip is unopinionated about agent runtimes. It works with Claude Code, OpenClaw, Python scripts, shell commands, HTTP webhooks, or any agent that can receive heartbeat signals.

---

## Part 1: What is Paperclip?

### Overview
- **Type**: Open-source AI agent orchestration platform
- **Tech Stack**: Node.js server + React UI + embedded PostgreSQL
- **Purpose**: Coordinates multiple AI agents as employees in a company structure
- **Core Philosophy**: Agents bring runtimes/models; Paperclip brings governance/coordination

### Repository & Documentation
- **Main Repo**: [paperclipai/paperclip](https://github.com/paperclipai/paperclip)
- **Official Site**: [paperclip.ing](https://paperclip.ing/)
- **Tutorial Site**: [paperclipai.info](https://paperclipai.info/)

### Installation

**Quick Start**:
```bash
npx paperclipai onboard --yes
```

**Manual Setup**:
```bash
git clone https://github.com/paperclipai/paperclip.git
cd paperclip
pnpm install  # pnpm 9.15+ required
pnpm dev
```

**Requirements**:
- Node.js 20+
- pnpm 9.15+
- No external database setup needed (embedded PostgreSQL auto-initializes)

**Access**: API server runs at `http://localhost:3100`

### Core Concepts

**Organizational Structure**:
```
Company Mission
  ↓
Project Goals (groups of work)
  ↓
Agent Goals (individual agent assignments)
  ↓
Concrete Tasks (work items)
```

Each level provides context. Agents always understand what they're doing and why.

**Agent Hierarchy**:
- Every agent has a **boss** (reports_to) except the CEO
- Forms a strict tree hierarchy for delegation and escalation
- Agents have roles (CEO, CTO, Content Writer, SEO Analyst)
- Each agent has a job description and reporting line

---

## Part 2: Agent Configuration & agents.yaml

### Configuration Model

Every agent requires:
```
Adapter Type + Configuration = Agent Identity & Behavior
```

Configuration is **adapter-specific**. Different adapter types (Claude, OpenClaw, etc.) have different config fields.

### Supported Adapter Types

#### 1. **Local Adapters** (Integrated IDEs)
- `claude_local` - Claude Code sessions
- `cursor` - Cursor IDE with model discovery, run-log streaming, skill injection
- `opencode_local` - OpenCode IDE (first-class integration)
- `pi_local` - Pi IDE

#### 2. **Remote Agent Adapters**
- `openclaw_remote` - OpenClaw bot framework
- `codex_local` - Codex agent
- `hermes_local` - Hermes Agent (with specialized adapter)

#### 3. **Script/Command Adapters**
- `bash_script` - Shell scripts
- `python_script` - Python execution

#### 4. **Custom Adapters**
- `http_webhook` - Any HTTP-callable endpoint
- Custom adapters (with example: Hermes Paperclip adapter pattern)

### Claude Local Adapter Configuration

Example configuration fields for `claude_local` adapter:

```yaml
agents:
  - id: engineer-001
    name: "Backend Engineer"
    adapter:
      type: claude_local
      config:
        model: "claude-3-5-sonnet"  # or claude-haiku, claude-opus
        cwd: "/path/to/project"  # Working directory
        instructionsFilePath: "./agent-instructions.md"
        timeoutSec: 300  # Execution timeout
        maxTurnsPerRun: 10  # Limit iterations per heartbeat
```

### Generic Agent Configuration Fields

Based on observed patterns (Hermes, Claude adapters):

```yaml
agents:
  - id: unique-agent-id
    name: "Agent Display Name"
    title: "Job Title"  # e.g., "CEO", "CTO", "Content Writer"
    description: "Job description and responsibilities"
    reports_to: ceo-agent-id  # Manager's agent ID (null for CEO)

    # Budget & Governance
    monthlyBudgetTokens: 1000000  # Hard limit per month
    budgetWarningThreshold: 80  # Soft warning at 80%

    # Adapter Configuration
    adapter:
      type: claude_local  # or other adapter type
      config:
        model: "claude-3-5-sonnet"
        cwd: "/project/path"
        timeoutSec: 300
        maxTurnsPerRun: 10
        # Adapter-specific fields vary

    # Execution Scheduling
    heartbeatIntervalMinutes: 60  # How often agent checks for work
    eventTriggers:
      - task_assigned
      - mentioned_directly

    # Scope & Permissions
    allowedTools: [read, write, bash, grep]
    allowedFilePatterns: ["src/**", "docs/**"]
    requiresApprovalFor:
      - file_write_requests
      - external_api_calls
      - hiring_new_agents
```

**Note**: The exact YAML schema is not fully documented publicly. Fields derive from observed configs and Paperclip's UI-based agent editor. Configuration can be done via:
1. Web UI (recommended for initial setup)
2. CLI commands (`agent list`, `agent get`)
3. Direct API calls

---

## Part 3: Reporting Hierarchy (reports_to)

### Hierarchy Structure

- **Tree Structure**: Every agent (except CEO) reports to exactly one manager
- **Org Charts**: Visual representation in Paperclip UI
- **Delegation Flow**: Work flows both up and down the org chart

### How reports_to Works

```yaml
agents:
  - id: ceo
    name: "CEO"
    title: "CEO"
    reports_to: null  # CEO has no boss

  - id: cto
    name: "CTO"
    title: "Chief Technology Officer"
    reports_to: ceo  # Reports to CEO

  - id: backend-engineer
    name: "Backend Engineer"
    title: "Senior Backend Engineer"
    reports_to: cto  # Reports to CTO

  - id: frontend-engineer
    name: "Frontend Engineer"
    title: "Senior Frontend Engineer"
    reports_to: cto  # Reports to CTO (same manager as backend)
```

### Hierarchy Implications

1. **Escalation**: Tasks blocked by subordinate agents can be escalated up
2. **Delegation**: CEO can delegate to CTO; CTO delegates to engineers
3. **Context**: Each agent knows their position in the org chart
4. **Approval Gates**: Manager approval required for certain operations
5. **Budget Attribution**: Costs tracked per agent and by management chain

### Best Practice: Flat vs. Deep Hierarchies

- **Shallow hierarchies** (2-3 levels): Better for small teams, faster communication
- **Deep hierarchies** (4+ levels): Better for large orgs, clearer specialization
- **Wide teams** (many reports per manager): Risk of bottleneck at manager level
- **Balanced trees**: Optimal for coordination (typically 3-5 direct reports per manager)

---

## Part 4: Agent Adapters (Detailed)

### How Adapters Work

**General Pattern**:
1. Paperclip sends task + context to adapter (via heartbeat signal)
2. Adapter executes agent in its runtime environment
3. Adapter captures output, token usage, errors
4. Adapter reports results back to Paperclip
5. Paperclip updates task status and billing

### Example: Hermes Adapter Implementation

```bash
# Paperclip heartbeat triggers:
hermes-adapter <task_id> <context_json>

# Adapter:
# 1. Spawns: hermes --single-query --task <task_id>
# 2. Hermes processes task using its tool suite
# 3. Hermes exits with results
# 4. Adapter parses stdout/stderr
# 5. Adapter extracts: token usage, session ID, completion status
# 6. Adapter POSTs results to Paperclip API
```

Reference: [NousResearch/hermes-paperclip-adapter](https://github.com/NousResearch/hermes-paperclip-adapter)

### Supported Adapter Ecosystem

| Adapter Type | Status | Integration Level | Notes |
|---|---|---|---|
| Claude Code | ✅ Stable | First-class (UI + CLI) | Local IDE integration |
| Cursor | ✅ Stable | First-class | Model discovery, skill injection |
| OpenCode | ✅ Stable | First-class | Run-log streaming |
| OpenClaw | ✅ Stable | Second-class | Remote bot framework |
| Codex | ✅ Stable | Second-class | Local agent |
| Hermes | ✅ Stable | Third-party | Community adapter |
| Bash/Python | ✅ Stable | Basic | Shell scripts, no special integration |
| HTTP Webhook | ✅ Flexible | Custom | Any HTTP-callable endpoint |

### Adapter Configuration Patterns

**Local Adapters** (Claude, Cursor, etc.):
```yaml
adapter:
  type: claude_local
  config:
    model: "claude-3-5-sonnet"
    cwd: "/path/to/work"
    instructionsFilePath: "./instructions.md"
    timeoutSec: 300
```

**Remote Adapters** (OpenClaw):
```yaml
adapter:
  type: openclaw_remote
  config:
    endpoint: "https://openclaw-instance.example.com"
    apiKey: "${OPENCLAW_API_KEY}"
    agentId: "openclaw-agent-uuid"
```

**Webhook Adapters** (Custom):
```yaml
adapter:
  type: http_webhook
  config:
    endpoint: "https://my-agent-service.example.com/execute"
    apiKey: "${CUSTOM_API_KEY}"
    method: "POST"
    timeout: 300
```

---

## Part 5: Advanced Features

### 1. Tools & File Access

**Available Tools** (based on observed implementations):
- `read` - Read files
- `write` - Write files
- `bash` - Execute shell commands
- `grep` - Search file contents

**File Access Model**:
- **Working Directory** (`cwd`): Base path for file operations
- **Allowed Patterns**: Regex/glob patterns restricting file access
- **Approval Gates**: File write operations may require human approval
- **Permissions Issue**: Agents don't have write permissions by default; need explicit approval

### 2. Task Context & Goal Ancestry

**Context Flow**:
```
Company Goal (context root)
  └─ Project Goal (provides context)
      └─ Agent Goal (specific assignment)
          └─ Task (concrete work item)
```

Each task carries **full goal ancestry**, so agents understand:
- **Why** they're doing the work (company mission)
- **Where** it fits (project + goal context)
- **What** to do (task description)
- **How** to measure success (success criteria)

**Benefit**: Agents don't restart from scratch on heartbeats; they maintain session context.

### 3. Budget & Cost Control

**Budget Model**:
```
Monthly Token Budget (hard limit)
  ├─ 80% Warning Threshold (soft alert)
  ├─ Cost Tracking (per agent, per task, per project)
  ├─ Real-time Monitoring (dashboard visibility)
  └─ Auto-Pause at 100% (agent stops working)
```

**Atomic Enforcement**:
- Task checkout is atomic
- Budget deduction is atomic
- No double-work, no runaway spend

### 4. Governance & Approval Gates

**Controlled Operations**:
- Agent hiring/firing (CEO must approve)
- Strategy execution (CEO reviews before delegation)
- Budget modifications (governance layer)
- Config changes (revisioned, rollback-safe)

**Audit Trail**:
- All conversations logged
- All decisions recorded
- Complete trace of who did what, when, why

### 5. Session Persistence

Unlike stateless agents that restart:
- Agents maintain **persistent context** across heartbeats
- Task context is resumed, not restarted
- Conversation history available across sessions
- Reduces repeated work, improves efficiency

### 6. Execution Model: Heartbeats vs. Continuous

**Heartbeat Model** (Paperclip default):
```
Heartbeat Interval (e.g., 60 minutes)
  ├─ Agent wakes up
  ├─ Checks for assigned tasks
  ├─ Executes tasks
  ├─ Reports results
  └─ Goes to sleep
```

**Event Triggers** (Supplementary):
- Task assignment (agent wakes immediately)
- Direct mention (@agent-name)
- Escalation from subordinate
- Custom webhooks

**Benefits**: Lower cost, predictable execution, governance-friendly

---

## Part 6: Best Practices for Agent Configuration

### 1. Mission-Driven Architecture

**Pattern**:
```
Company Mission: "Build #1 AI note-taking app to $1M MRR"
  └─ Project Goal: "Achieve 10K daily active users"
      └─ Agent Goal: "Improve email notification system"
          └─ Task: "Fix notification delivery failures"
```

**Best Practice**: Write mission statements at goal level; trace every task back to company mission.

### 2. Clear Role Definition

```yaml
agent:
  title: "Senior Backend Engineer"
  description: |
    Responsible for designing and implementing API endpoints,
    database schemas, and backend services. Reports to CTO.
    Budget: 5M tokens/month.
  specialties:
    - "Python/FastAPI"
    - "Database design"
    - "API architecture"
```

### 3. Appropriate Budget Allocation

**Guidelines**:
- **Entry-level tasks**: 100K-500K tokens/month
- **Mid-level engineering**: 500K-2M tokens/month
- **Senior/specialized roles**: 2M-5M+ tokens/month
- **Set budgets based on**: Role complexity, task scope, model cost

### 4. Reasonable Execution Timing

```yaml
# Development agents: Frequent heartbeats
agents:
  - id: backend-engineer
    heartbeatIntervalMinutes: 30  # Check every 30 min

  # Writing/analysis agents: Less frequent
  - id: content-writer
    heartbeatIntervalMinutes: 120  # Check every 2 hours

  # Executive agents: Rare heartbeats
  - id: ceo
    heartbeatIntervalMinutes: 240  # Check every 4 hours
```

### 5. Tool & File Access Control

```yaml
agent:
  allowedTools: [read, write, bash]
  allowedFilePatterns:
    - "src/**"
    - "docs/**"
    - "tests/**"
  requiresApprovalFor:
    - file_write_requests
    - external_api_calls
    - database_modifications
```

### 6. Adapter Selection

**Decision Tree**:
- **Running locally with IDE?** → Use `claude_local` or `cursor`
- **Using existing OpenClaw setup?** → Use `openclaw_remote`
- **Running custom agent service?** → Use `http_webhook`
- **Need simple script?** → Use `bash_script` or `python_script`

### 7. Hierarchical Structure Design

**Anti-pattern**: Flat structure (all agents report to CEO)
- Creates bottleneck at CEO
- Limits scalability
- Poor task delegation

**Good pattern**: Balanced hierarchy
```
CEO (1)
  ├─ CTO (1)
  │   ├─ Backend Lead (1)
  │   │   ├─ Backend Engineer 1
  │   │   └─ Backend Engineer 2
  │   └─ Frontend Lead (1)
  │       ├─ Frontend Engineer 1
  │       └─ Frontend Engineer 2
  └─ COO (1)
      ├─ Content Lead (1)
      │   └─ Content Writer 1
      └─ Operations Lead (1)
```

### 8. Deployment Patterns

**Single Node (Development)**:
```bash
npm run dev  # Embedded Postgres, local files
```

**Production (Standalone)**:
```bash
npm run build && npm start
# Point to external Postgres, persistent storage
```

**Multi-tenant**:
```
Single Paperclip instance
  ├─ Company A (isolated org)
  ├─ Company B (isolated org)
  └─ Company C (isolated org)
```

---

## Part 7: Unresolved Questions & Limitations

### 1. agents.yaml File Location

**Status**: Not officially documented as a standard config file in public docs.

**Questions**:
- Is `.paperclip/agents.yaml` a community standard or internal pattern?
- Are agents typically configured via web UI vs. YAML files?
- Is there a bulk import/export feature for YAML configs?

**Resolution**: Configuration is primarily done via Paperclip UI. Bulk import may exist but isn't documented in public search results.

### 2. Exact YAML Schema

**Status**: Not published in full.

**Questions**:
- What are all supported fields in the YAML schema?
- Are there optional vs. required fields?
- What validation rules apply?

**Resolution**: Check Paperclip's source code (`src/` or similar) for schema definitions, or use web UI for safe, validated configuration.

### 3. Custom Adapter Development

**Status**: Partially documented.

**Questions**:
- What's the exact interface adapters must implement?
- How do adapters handle session persistence?
- What's the protocol for heartbeat signals?

**Resolution**: Hermes adapter example is instructive; check GitHub for full interface spec.

### 4. File Write Permissions

**Status**: Known issue (GitHub #696).

**Current Behavior**: Agents don't have write permissions by default; need approval.

**Questions**:
- How is approval workflow implemented?
- Can approvals be batched/automated?

**Resolution**: Approval gates exist but full workflow not documented.

### 5. Advanced Scheduling

**Status**: Basic scheduling (heartbeat intervals) documented; advanced scheduling unclear.

**Questions**:
- Can agents be scheduled with cron expressions?
- Can tasks be scheduled for specific times?
- Are there workflow/pipeline features?

**Resolution**: Heartbeat model is primary; advanced scheduling not evident in public docs.

---

## Part 8: Key Resources

### Official
- [Paperclip GitHub](https://github.com/paperclipai/paperclip)
- [paperclip.ing](https://paperclip.ing/) (Official site)
- [paperclipai.info](https://paperclipai.info/) (Tutorial)

### Documentation Paths in Repo
- `/docs/guides/agent-developer/` - Agent development guide
- `/doc/PRODUCT.md` - Product overview
- `/doc/DEVELOPING.md` - Development setup
- `/AGENTS.md` - Agent configuration (if available)
- `/docs/start/core-concepts.md` - Core concepts

### Related Tools & Adapters
- [fredruss/agent-paperclip](https://github.com/fredruss/agent-paperclip) - Desktop companion for Claude Code
- [NousResearch/hermes-paperclip-adapter](https://github.com/NousResearch/hermes-paperclip-adapter) - Example adapter implementation
- [Paperclip MCP Server](https://skywork.ai) - Model Context Protocol integration

---

## Summary: Quick Reference

| Aspect | Details |
|---|---|
| **What** | AI agent orchestration platform (open-source) |
| **Tech** | Node.js + React + embedded PostgreSQL |
| **Agents** | Claude Code, OpenClaw, Cursor, Bash, HTTP webhooks, custom |
| **Config** | Web UI primarily; YAML via API/CLI |
| **Hierarchy** | Tree structure with `reports_to` field |
| **Budget** | Per-agent monthly token limits, hard enforce |
| **Schedule** | Heartbeat intervals + event triggers |
| **Tools** | Read, Write, Bash, Grep (plus adapter-specific) |
| **Advanced** | Session persistence, approval gates, audit trails, cost tracking |
| **Best Practice** | Mission-driven, clear roles, balanced hierarchy, appropriate budgets |

---

**Report Generated**: 2026-03-16
**Research Quality**: High (8+ sources, official docs prioritized)
**Confidence Level**: 85% (some schema details inferred from patterns)
