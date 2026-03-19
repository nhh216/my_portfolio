# Paperclip Agent Configuration Examples

**Date**: 2026-03-16
**Purpose**: Real-world configuration examples for Paperclip agents

---

## Example 1: Startup Tech Company

### Company Structure
```
Mission: "Build AI-powered SaaS product to $1M ARR by 2026"

Company (paperclip.ing)
├─ CEO (5M tokens/month) - Strategic decisions
├─ CTO (4M tokens/month) - Engineering leadership
│  ├─ Backend Lead (2M tokens/month)
│  │  ├─ Backend Engineer 1 (1.5M tokens/month)
│  │  └─ Backend Engineer 2 (1.5M tokens/month)
│  ├─ Frontend Lead (1.5M tokens/month)
│  │  ├─ Frontend Engineer 1 (1M tokens/month)
│  │  └─ Frontend Engineer 2 (1M tokens/month)
│  └─ DevOps Engineer (1M tokens/month)
└─ CEO → Growth Lead (1M tokens/month)
   ├─ Content Writer (500K tokens/month)
   ├─ Marketing Analyst (500K tokens/month)
   └─ Sales Agent (300K tokens/month)

Total: ~15M tokens/month
```

### YAML Configuration

```yaml
company:
  name: "AI SaaS Startup"
  mission: "Build collaborative AI note-taking app to $1M ARR by end of 2026"

agents:
  # CEO - Strategic decision maker
  - id: ceo
    name: "Alice Chen"
    title: "CEO & Co-founder"
    description: "Sets company strategy, approves major decisions, manages board relations"
    reports_to: null
    monthlyBudgetTokens: 5000000
    budgetWarningThreshold: 75
    adapter:
      type: claude_local
      config:
        model: "claude-3-5-sonnet"
        cwd: "/work/company"
        instructionsFilePath: "./agent-instructions/ceo.md"
        timeoutSec: 300
        maxTurnsPerRun: 5
    heartbeatIntervalMinutes: 480  # Check every 8 hours
    eventTriggers: [task_assigned, mentioned_directly]
    requiresApprovalFor: []  # CEO is top authority
    allowedTools: [read, bash]  # Strategic access only

  # CTO - Engineering leadership
  - id: cto
    name: "Bob Williams"
    title: "CTO & Co-founder"
    description: |
      Leads engineering team, owns architecture decisions,
      manages technical roadmap and hiring.
    reports_to: ceo
    monthlyBudgetTokens: 4000000
    budgetWarningThreshold: 75
    adapter:
      type: claude_local
      config:
        model: "claude-3-5-sonnet"
        cwd: "/work/code"
        instructionsFilePath: "./agent-instructions/cto.md"
        timeoutSec: 400
        maxTurnsPerRun: 8
    heartbeatIntervalMinutes: 240  # Check every 4 hours
    eventTriggers: [task_assigned, mentioned_directly]
    requiresApprovalFor: [hiring, budget_increase, external_api_calls]
    allowedTools: [read, write, bash, grep]
    allowedFilePatterns: ["src/**", "docs/**", "config/**"]

  # Backend Lead
  - id: backend-lead
    name: "Charlie Park"
    title: "Backend Lead"
    description: "Leads backend team, designs APIs, mentors engineers"
    reports_to: cto
    monthlyBudgetTokens: 2000000
    budgetWarningThreshold: 80
    adapter:
      type: claude_local
      config:
        model: "claude-3-5-sonnet"
        cwd: "/work/code/backend"
        instructionsFilePath: "./agent-instructions/backend-lead.md"
        timeoutSec: 350
        maxTurnsPerRun: 10
    heartbeatIntervalMinutes: 120  # Check every 2 hours
    eventTriggers: [task_assigned, mentioned_directly]
    requiresApprovalFor: [database_schema_changes, api_breaking_changes]
    allowedTools: [read, write, bash, grep]
    allowedFilePatterns: ["src/backend/**", "tests/backend/**"]

  # Backend Engineer 1
  - id: backend-engineer-1
    name: "Diana Patel"
    title: "Senior Backend Engineer"
    description: "Implements backend features, owns database design"
    reports_to: backend-lead
    monthlyBudgetTokens: 1500000
    budgetWarningThreshold: 80
    adapter:
      type: claude_local
      config:
        model: "claude-3-5-sonnet"
        cwd: "/work/code/backend"
        instructionsFilePath: "./agent-instructions/engineer.md"
        timeoutSec: 300
        maxTurnsPerRun: 15
    heartbeatIntervalMinutes: 60  # Check every hour
    eventTriggers: [task_assigned, mentioned_directly]
    requiresApprovalFor: [file_write_requests]
    allowedTools: [read, write, bash, grep]
    allowedFilePatterns:
      - "src/backend/**"
      - "tests/backend/**"
      - "db/migrations/**"

  # Frontend Lead
  - id: frontend-lead
    name: "Emma Johnson"
    title: "Frontend Lead"
    description: "Leads frontend team, owns UI/UX decisions"
    reports_to: cto
    monthlyBudgetTokens: 1500000
    budgetWarningThreshold: 80
    adapter:
      type: cursor  # Using Cursor IDE
      config:
        model: "claude-3-5-sonnet"
        cwd: "/work/code/frontend"
        instructionsFilePath: "./agent-instructions/frontend-lead.md"
    heartbeatIntervalMinutes: 120
    eventTriggers: [task_assigned]
    allowedTools: [read, write, bash, grep]
    allowedFilePatterns: ["src/frontend/**", "tests/frontend/**"]

  # DevOps Engineer
  - id: devops-engineer
    name: "Frank Chen"
    title: "DevOps Engineer"
    description: "Infrastructure, CI/CD, deployment automation"
    reports_to: cto
    monthlyBudgetTokens: 1000000
    budgetWarningThreshold: 80
    adapter:
      type: claude_local
      config:
        model: "claude-3-5-sonnet"
        cwd: "/work/infrastructure"
        instructionsFilePath: "./agent-instructions/devops.md"
        timeoutSec: 600  # Longer timeout for deployment tasks
        maxTurnsPerRun: 20
    heartbeatIntervalMinutes: 120
    eventTriggers: [task_assigned, deployment_needed]
    requiresApprovalFor: [production_deployments, security_changes]
    allowedTools: [read, write, bash, grep]
    allowedFilePatterns:
      - "infrastructure/**"
      - ".github/workflows/**"
      - "docker/**"

  # Growth Lead (Marketing/Growth)
  - id: growth-lead
    name: "Grace Martinez"
    title: "Growth Lead"
    description: "Leads growth initiatives, manages marketing strategy"
    reports_to: ceo
    monthlyBudgetTokens: 1000000
    budgetWarningThreshold: 80
    adapter:
      type: claude_local
      config:
        model: "claude-3-5-sonnet"
        cwd: "/work/marketing"
        instructionsFilePath: "./agent-instructions/growth.md"
    heartbeatIntervalMinutes: 240  # Less frequent
    eventTriggers: [task_assigned]
    allowedTools: [read, write, bash, grep]
    allowedFilePatterns: ["marketing/**", "content/**"]

  # Content Writer
  - id: content-writer
    name: "Henry Adams"
    title: "Content Writer"
    description: "Creates blog posts, documentation, marketing copy"
    reports_to: growth-lead
    monthlyBudgetTokens: 500000
    budgetWarningThreshold: 80
    adapter:
      type: claude_local
      config:
        model: "claude-haiku"  # Cheaper model for writing tasks
        cwd: "/work/content"
        instructionsFilePath: "./agent-instructions/writer.md"
    heartbeatIntervalMinutes: 240
    eventTriggers: [task_assigned]
    allowedTools: [read, write, bash]
    allowedFilePatterns: ["content/**", "docs/**", "blog/**"]

projects:
  - id: project-auth
    name: "Authentication System"
    goal: "Implement secure OAuth2 + 2FA"
    owner_id: backend-lead
    tasks:
      - "Design OAuth2 flow"
      - "Implement provider integration"
      - "Add 2FA support"
      - "Security audit"

  - id: project-ui
    name: "Redesign Dashboard"
    goal: "Improve UX, reduce load time to <2s"
    owner_id: frontend-lead
    tasks:
      - "Create Figma designs"
      - "Implement React components"
      - "Add performance optimizations"
      - "User testing"

  - id: project-launch
    name: "Product Launch"
    goal: "Public beta with 100 users"
    owner_id: ceo
    tasks:
      - "Deploy infrastructure"
      - "Create marketing content"
      - "Outreach to beta users"
      - "Gather feedback"
```

---

## Example 2: Minimal Setup (Solopreneur)

```yaml
company:
  name: "One-Person AI Agency"
  mission: "Build AI tools and charge $10K/month"

agents:
  - id: solo-agent
    name: "You"
    title: "Founder"
    description: "All roles"
    reports_to: null
    monthlyBudgetTokens: 3000000  # Reasonable for one person
    adapter:
      type: claude_local
      config:
        model: "claude-3-5-sonnet"
        cwd: "/work/projects"
        instructionsFilePath: "./instructions.md"
    heartbeatIntervalMinutes: 60
    eventTriggers: [task_assigned, mentioned_directly]
    requiresApprovalFor: []
    allowedTools: [read, write, bash, grep]
    allowedFilePatterns: ["**/*"]

projects:
  - id: ai-tool-1
    name: "AI Content Generator"
    goal: "$5K/month revenue"
    owner_id: solo-agent
```

---

## Example 3: Distributed Team (Remote Agencies)

```yaml
company:
  name: "Distributed AI Agency"
  mission: "Deliver AI solutions globally"

agents:
  # Management
  - id: agency-ceo
    name: "Manager Bot"
    title: "Agency Manager"
    reports_to: null
    monthlyBudgetTokens: 3000000
    adapter:
      type: http_webhook
      config:
        endpoint: "https://manager-api.agency.com/execute"
        apiKey: "${MANAGER_API_KEY}"
    heartbeatIntervalMinutes: 120
    requiresApprovalFor: [hiring, budget_approval]

  # Developer in US timezone
  - id: dev-us
    name: "Developer US"
    title: "Senior Engineer"
    reports_to: agency-ceo
    monthlyBudgetTokens: 2000000
    adapter:
      type: claude_local
      config:
        model: "claude-3-5-sonnet"
        cwd: "/work"
    heartbeatIntervalMinutes: 60
    allowedFilePatterns: ["src/**"]

  # Developer in EU timezone
  - id: dev-eu
    name: "Developer EU"
    title: "Senior Engineer"
    reports_to: agency-ceo
    monthlyBudgetTokens: 2000000
    adapter:
      type: claude_local
      config:
        model: "claude-3-5-sonnet"
        cwd: "/work"
    heartbeatIntervalMinutes: 60
    allowedFilePatterns: ["src/**"]

  # Remote content writer
  - id: writer-global
    name: "Content Writer"
    title: "Technical Writer"
    reports_to: agency-ceo
    monthlyBudgetTokens: 800000
    adapter:
      type: http_webhook
      config:
        endpoint: "https://writer-service.example.com/process"
    heartbeatIntervalMinutes: 240
```

---

## Example 4: Specialized Agent Team

```yaml
# Each agent is a specialist with narrow scope

agents:
  - id: code-reviewer
    title: "Code Review Bot"
    monthlyBudgetTokens: 500000
    adapter:
      type: claude_local
      config:
        model: "claude-3-5-sonnet"
    allowedTools: [read, bash, grep]
    allowedFilePatterns: ["src/**"]  # Read-only

  - id: test-writer
    title: "Test Generation Bot"
    monthlyBudgetTokens: 800000
    adapter:
      type: claude_local
      config:
        model: "claude-3-5-sonnet"
    allowedFilePatterns: ["tests/**"]  # Write tests only

  - id: documentation-bot
    title: "Documentation Generator"
    monthlyBudgetTokens: 300000
    adapter:
      type: claude_local
      config:
        model: "claude-haiku"  # Cheaper for routine docs
    allowedFilePatterns: ["docs/**"]

  - id: devops-bot
    title: "Infrastructure Automation"
    monthlyBudgetTokens: 1000000
    adapter:
      type: claude_local
      config:
        model: "claude-3-5-sonnet"
        timeoutSec: 600
    allowedFilePatterns:
      - "infrastructure/**"
      - ".github/workflows/**"
    requiresApprovalFor: [production_deployments]
```

---

## Example 5: Cost-Optimized Setup

Strategy: Use cheaper models for routine tasks, expensive models for complex work

```yaml
agents:
  # Complex decision-making - use Sonnet
  - id: architect
    title: "System Architect"
    monthlyBudgetTokens: 3000000
    adapter:
      type: claude_local
      config:
        model: "claude-3-5-sonnet"  # Most capable

  # Routine development - use Haiku
  - id: dev-routine
    title: "Developer (Routine)"
    monthlyBudgetTokens: 1000000
    adapter:
      type: claude_local
      config:
        model: "claude-haiku"  # 80% cheaper, good for well-defined tasks

  # Documentation/writing - use Haiku
  - id: documentation
    title: "Documentation"
    monthlyBudgetTokens: 400000
    adapter:
      type: claude_local
      config:
        model: "claude-haiku"

  # Code review/analysis - mix Sonnet/Haiku
  - id: code-reviewer
    title: "Code Reviewer"
    monthlyBudgetTokens: 700000
    adapter:
      type: claude_local
      config:
        model: "claude-opus"  # Most thorough for critical reviews

# Total: ~5.1M tokens/month at mixed rates
# Would cost ~$15/month with optimal model selection
```

---

## Configuration Validation Checklist

Before deploying, verify:

- [ ] Every agent (except CEO) has a `reports_to` value
- [ ] No circular reporting relationships
- [ ] All budget amounts are reasonable (100K-10M range)
- [ ] Heartbeat intervals match role (dev: 30-60min, manager: 120-480min)
- [ ] File patterns are restrictive enough (security)
- [ ] Adapter types exist (`claude_local`, `cursor`, etc.)
- [ ] All file paths are absolute or relative to `cwd`
- [ ] No duplicate agent IDs
- [ ] Instructions files exist at specified paths
- [ ] Approval gates configured for high-risk operations

---

**Last Updated**: 2026-03-16
