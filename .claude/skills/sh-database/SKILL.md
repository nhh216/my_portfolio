---
name: sh-database
description: SalaryHero PostgreSQL database schema reference. Use when writing queries, designing features, or any question about SH database tables, columns, relationships, or domain model.
license: proprietary
---

# SalaryHero Database Schema Skill

Reference guide for the SalaryHero (SH) `public` schema. Activate whenever prompts relate to SH tables, columns, foreign keys, or data queries.

## When to Use This Skill

- Writing SQL queries against SH database
- Understanding relationships between SH entities
- Designing new features that touch existing tables
- Debugging data issues or checking column types
- Any question about users, companies, EWA, reimbursement, notifications, etc.

## Schema Source

Full HCL schema: `/Users/hung/Desktop/SalaryHero/sh-db-schemas/schemas/public.hcl`

Use `psql` to query the live database when needed.

## Domain Overview

SalaryHero is an **Earned Wage Access (EWA)** platform operating in Thailand/Myanmar:
- **EWA**: Employees request advance salary withdrawals before payday
- **Companies** onboard employees; employees = **users**
- **Pay cycles** define salary periods and withdrawal windows
- **Reimbursement**: Flexible benefit claims (flexben)
- **Audience Groups**: Target segments for push notifications / surveys
- **Admin / User Admin**: Internal ops (admin) vs company HR portals (user_admin)

---

## Core Tables Reference

### Users & Identity

#### `users` — Primary employee/user table
| Column | Type | Notes |
|--------|------|-------|
| `user_id` | bigserial PK | |
| `status` | enum.general_status | `active`/`inactive` |
| `first_name`, `last_name`, `email`, `phone` | varchar | |
| `company_id` | bigint FK→company | Legacy company reference |
| `department_id` | bigint FK→department | |
| `employee_id` | varchar(50) | HR employee code |
| `salary` | numeric(10,2) | Current salary |
| `salary_type` | varchar(50) | `monthly` (default) |
| `pay_cycle_id` | bigint FK→company_pay_cycles | |
| `direct_debit_status` | enum | `unregister/pending/active/inactive/cancelled` |
| `flexben_status` | enum | `active/inactive` |
| `disbursement_type` | enum | `bank` (default) |
| `is_deleted` | int | 0=alive, 1=deleted (soft delete) |
| `is_blacklist` | boolean | Blacklisted users cannot use EWA |
| `is_transferring` | boolean | Blocks EWA during pay cycle transfer |
| `hired_date`, `termination_date` | timestamp | Employment dates |
| `job_level` | varchar(255) | |
| `last_login_at` | timestamp | Last mobile app login |
| `signup_at` | timestamptz | |
| `language` | varchar(10) | Preferred language |
| `reimbursement_total_budget` | numeric(20,2) | |
| `tags` | jsonb | |

**Indexes**: company_id, department_id, email, employee_id, phone, pay_cycle_id, status

#### `user_identity` — New identity table (migration in progress)
Links `user_uid` (uuid) to legacy `user_id`. Used by `employment` table.

#### `employment` — Employment records (new schema, replaces users employment fields)
| Column | Type | Notes |
|--------|------|-------|
| `employment_id` | uuid PK | |
| `user_uid` | uuid FK→user_identity | |
| `legacy_user_id` | bigint | Backward compat →users.user_id |
| `company_id` | bigint FK→companies | |
| `department_id` | bigint | |
| `employee_id` | varchar(100) | |
| `salary` | numeric(12,2) | |
| `status` | varchar(20) | `active/inactive/pending/terminated` |
| `job_level` | varchar(100) | |
| `salary_type` | varchar(20) | |
| `require_attendance` | boolean | |
| `deduction` | numeric(10,2) | |

#### `user_fcm_tokens` — Firebase push notification tokens
| Column | Type | Notes |
|--------|------|-------|
| `id` | uuid PK | |
| `user_id` | bigint UNIQUE FK→users | One token per user |
| `fcm_token` | varchar(255) | |
| `company_id` | bigint | |
| `user_language` | varchar(10) | |
| `is_valid` | boolean | Default true |
| `refreshed_at` | timestamp | |
| `deleted_at` | timestamp | Soft delete |

#### `user_admin` — HR portal admin users (company HR staff)
| Column | Type | Notes |
|--------|------|-------|
| `user_admin_id` | bigserial PK | |
| `company_id` | bigint | |
| `status` | enum.general_status | |
| `email`, `phone`, `first_name`, `last_name` | varchar | |
| `is_deleted` | int | |

#### `admins` — Internal SalaryHero ops admins
| Column | Type | Notes |
|--------|------|-------|
| `admin_id` | bigserial PK | |
| `uid` | varchar(50) | Firebase UID |
| `role_list` | json | |
| `company_list` | json | |
| `allow_modify_salary` | boolean | |

---

### Companies

#### `companies` — Primary company table (new)
| Column | Type | Notes |
|--------|------|-------|
| `id` | bigserial PK | |
| `legacy_id` | bigint | |
| `name`, `name_th` | varchar(255) | |
| `slug` | varchar(255) | |
| `status` | enum | `active/inactive` |
| `parent_company_id` | bigint FK self | Parent company |
| `bank_code` | varchar | |
| `has_sites` | boolean | |
| `has_departments` | boolean | |
| `direct_debit` | boolean | |
| `is_placeholder` | boolean | Ghost/dummy company flag |
| `label_group_id` | bigint FK→company_label_group | |
| `line_id`, `line_url` | varchar/text | LINE contact |

#### `company` — Legacy company table
| Column | Type | Notes |
|--------|------|-------|
| `company_id` | bigserial PK | |
| `name`, `name_th` | varchar | |
| `slug` | varchar | |
| `status` | enum.general_status | |
| `login_phone/line/microsoft/employee_id` | mixed | Auth methods |
| `tenant_id` | varchar | |
| `bank_code` | varchar | |

#### `company_setting` — Per-company configuration
#### `company_addon` — Feature addons per company
| Column | Type | Notes |
|--------|------|-------|
| `company_id` | bigint FK→companies | |
| `addon` | enum | Feature addon type |
| `is_enabled` | boolean | |
| `properties` | jsonb | |

#### `company_pay_cycles` — Pay cycle definitions
| Column | Type | Notes |
|--------|------|-------|
| `company_pay_cycle_id`/`id` | PK | |
| `status` | enum | `active/inactive` |
| `pay_cycle_type` | enum | `monthly/bimonthly/monthly_attendance/bimonthly_attendance` |
| `company_id` | bigint | |

#### `company_pay_cycle_periods` — Periods within pay cycles
#### `company_auth_settings` — Auth methods per company
| Column | Type | Notes |
|--------|------|-------|
| `auth_method` | enum | `microsoft/phone/line/employee_id/microsoft_entra_id` |
| `is_enabled` | boolean | |

#### `department` — Company departments
| Column | Type | Notes |
|--------|------|-------|
| `department_id` | bigserial PK | |
| `company_id` | bigint | |
| `name` | varchar | |
| `is_deleted` | int | |

#### `company_sites` — Physical work sites
#### `company_user_sites` — User→site assignment

---

### EWA (Earned Wage Access)

#### `ewa_request` — Salary advance requests
| Column | Type | Notes |
|--------|------|-------|
| `ewa_request_id` | bigserial PK | |
| `user_id` | bigint FK→users | |
| `company_id` | bigint | |
| `status` | enum.ewa_status | `pending/processing/cancelled/rejected/completed/new/failed/closed` |
| `amount` | numeric | Requested amount |
| `fee` | numeric | Transaction fee |
| `bank_code` | varchar | |
| `bank_account_no` | varchar | |
| `pay_cycle_id` | bigint | |

#### `ewa_balance_templates` — Balance calculation rules per company
| Column | Type | Notes |
|--------|------|-------|
| `withdrawal_type` | enum | `rolling/percent/cumulative` |
| `attendance_by` | enum | `day/hour/none` |

#### `ewa_fee_templates` — Fee structures
| Column | Type | Notes |
|--------|------|-------|
| `fee_type` | enum | `interval/per_request/subscription/pcs` |
| `saas_fee_type` | enum | `none/active_employee/requested_employee/fixed` |

#### `ewa_request_summary` / `ewa_request_summaries` — Aggregated request summaries
#### `ewa_request_audit` — Audit log for EWA requests
#### `ewa_user_snaps` — User snapshot at time of EWA request
#### `ewa_instant_payment_logs` / `ewa_instant_payment_bank` — Instant payment tracking

---

### Notifications

#### `notification` — Individual notifications sent to users
| Column | Type | Notes |
|--------|------|-------|
| `category` | enum | `request/announcement/education/information/bankAccount/voucher/referral/balance_calculation/insurance/digital_consent/direct_debit_register/direct_debit_deduction/survey_immediate_trigger/flexben_claim/flexben_announcement/cutoff_reminder/fee_payment` |
| `user_id` | bigint FK→users | |

#### `notification_plan` — Scheduled notification campaigns
#### `notification_plan_repeat_config` — Repeat config for notification plans
| Column | Type | Notes |
|--------|------|-------|
| `type` | enum | Repeat type |
| `status` | enum | |

---

### Audience Groups

#### `audience_group` — Targeting groups for notifications/surveys
| Column | Type | Notes |
|--------|------|-------|
| `audience_group_id` | bigserial PK | |
| `name` | varchar(250) | |
| `audience_group_type` | enum | `criteria` (default) |
| `companies_criteria` | jsonb | Criteria for dynamic groups |
| `company_list` | json | Static company list |
| `total_audience` | bigint | Cached count |
| `min_salary`, `max_salary` | numeric(10,2) | Salary filters |
| `job_levels` | jsonb | Job level filters |
| `status` | enum.general_status | |
| `is_deleted` | int | |

#### `audience_group_users` — User membership in audience groups
| Column | Type | Notes |
|--------|------|-------|
| `audience_group_id` | bigint | PK composite |
| `user_id` | bigint | PK composite |

**Index**: `(user_id, audience_group_id)` for reverse lookup

---

### Reimbursement / Flexben

#### `reimbursement_claims` — Flexben reimbursement requests
#### `reimbursement_categories` — Expense categories
#### `reimbursement_budgets` — Budget allocations
#### `reimbursement_budget_categories` — Category-budget links
#### `reimbursement_periods` / `reimbursement_periods_v2` — Claim periods
#### `reimbursement_claim_reviews` — Approval workflow
#### `reimbursement_claim_status_history` — Status changes
#### `reimbursement_fees` — Fee configurations
#### `reimbursement_deductions` — Deductions from reimbursement

---

### Banking & Payments

#### `user_bank` — User bank accounts
| Column | Type | Notes |
|--------|------|-------|
| `verify` | enum | `unverified/rejected/verified/pending` |
| `bank_code` | varchar FK→banks | |
| `account_no` | varchar | |
| `user_id` | bigint FK→users | |

#### `user_promptpay` — PromptPay accounts
| Column | Type | Notes |
|--------|------|-------|
| `promptpay_type` | enum | |

#### `banks` — Bank master data
| Column | Type | Notes |
|--------|------|-------|
| `bank_code` | varchar(20) PK | |
| `name`, `short_name` | varchar | |
| `instant_payment` | boolean | |
| `name_locales`, `full_name_locales` | jsonb | Localized names |

#### `omise_transaction_events` — Omise payment gateway events

---

### Employee Profile & Import

#### `employee_profile` — Detailed employee profile (consent/onboarding)
| Column | Type | Notes |
|--------|------|-------|
| `consent_status` | enum | `pending_review/pending_update/new/approved/disabled` |
| `employee_status` | enum | `active/inactive/resigned` |

#### `employee_import` — Bulk employee import jobs
| Column | Type | Notes |
|--------|------|-------|
| `import_type` | enum | `employee/consent` |
| `status` | varchar | |

#### `employee_import_config` — Import config per company
#### `employee_import_mapping` — Column mapping for imports

---

### Surveys

#### `survey` — Survey definitions
| Column | Type | Notes |
|--------|------|-------|
| `status` | enum | `ongoing/drafted/paused` |
| `audience_type` | enum | `audience_group/individual/all` |
| `trigger_type` | enum | `after_withdrawal_request/after_signup/immediate` |

#### `survey_question`, `survey_response`, `survey_response_item`

---

### Other Key Tables

#### `user_audit` — Audit log for user changes
#### `company_audits` — Audit log for company changes
| Column | Type | Notes |
|--------|------|-------|
| `entity` | enum | `companies/company_pay_cycles/...` |
| `prev_state`, `current_state` | jsonb | Before/after snapshot |

#### `user_module` / `module` — Feature module access per user
#### `user_role` / `roles` — RBAC for users
#### `user_admin_role` / `company_user_admin_role` — HR admin roles
#### `connection` — HRIS integrations (SFTP/API connections)
| Column | Type | Notes |
|--------|------|-------|
| `authentication_type` | enum | `NONE/BASIC/BEARER/API_KEY/OAUTH/SAML/S3` |
| `schedule_type` | enum | `MANUAL/CRON` |

#### `policies` / `policy_version` / `policy_user_consent` / `policy_user_notice` — Policy management
#### `user_pending_change` — Pending user data changes
| Column | Type | Notes |
|--------|------|-------|
| `status` | enum | `pending/processing/applied/cancelled/failed` |

#### `user_pin_lock` — PIN lock records
| Column | Type | Notes |
|--------|------|-------|
| `type` | enum | `temporary/permanent` |

#### `verification` — OTP/verification records
| Column | Type | Notes |
|--------|------|-------|
| `status` | enum | `request/verified/cancelled/signup` |

#### `attendance` / `attendance_import` — Attendance records
#### `budget` / `budget_category` / `budget_transaction` — Personal finance budgeting
#### `upload_files` — File upload tracking
#### `job_level_history` — Job level change history
#### `sent_email_logs` / `ewa_email_settings` — Email tracking
#### `user_balance` — User balance snapshots
#### `user_identity` — New identity model (uuid-based)
#### `user_temporary` — Temporary user records
#### `app_event` — Internal async event queue
#### `job_execution` — Background job execution logs
#### `receipt_running_number` — Sequential receipt numbers
#### `general_setting` — Global system settings
#### `invoice_setting` — Invoice configuration
#### `insurance_*` — Insurance product tables

---

## Key Relationships

```
companies (id) ←──── company_addon.company_id
companies (id) ←──── company_auth_settings.company_id
companies (id) ←──── company_pay_cycles (via companies_company_pay_cycles)
companies (id) ←──── company_sites.company_id
companies (id) ←──── department.company_id (legacy via company table)

company (company_id) ←── users.company_id  [LEGACY]
companies (id) ←────────── users (via employment.company_id) [NEW]

users (user_id) ←── user_fcm_tokens.user_id  [UNIQUE - one token per user]
users (user_id) ←── user_bank.user_id
users (user_id) ←── user_promptpay.user_id
users (user_id) ←── ewa_request.user_id
users (user_id) ←── notification.user_id
users (user_id) ←── audience_group_users.user_id
users (user_id) ←── budget.user_id
users (user_id) ←── user_balance.user_id
users (user_id) ←── job_level_history.user_id
users (user_id) ←── employment.legacy_user_id [migration bridge]

user_identity (user_uid) ←── employment.user_uid [NEW model]

banks (bank_code) ←── user_bank.bank_code
banks (bank_code) ←── ewa_request.bank_code

audience_group (audience_group_id) ←── audience_group_users.audience_group_id
budget_category (id) ←── budget_transaction.category_id (self-ref: parent_id)
```

---

## Common Enum Quick Reference

| Enum | Values |
|------|--------|
| `general_status` | `active`, `inactive` |
| `ewa_status` | `pending`, `processing`, `cancelled`, `rejected`, `completed`, `new`, `failed`, `closed` |
| `enum_companies_status` | `active`, `inactive` |
| `enum_users_direct_debit_status` | `unregister`, `pending`, `active`, `inactive`, `cancelled` |
| `enum_employee_profile_consent_status` | `pending_review`, `pending_update`, `new`, `approved`, `disabled` |
| `enum_employee_profile_employee_status` | `active`, `inactive`, `resigned` |
| `enum_company_auth_settings_auth_method` | `microsoft`, `phone`, `line`, `employee_id`, `microsoft_entra_id` |
| `enum_verification_status` | `request`, `verified`, `cancelled`, `signup` |
| `enum_user_bank_account_verify` | `unverified`, `rejected`, `verified`, `pending` |
| `audience_group_type` | `criteria` |
| `flexben_status` | `active`, `inactive` |
| `user_pending_change_status` | `pending`, `processing`, `applied`, `cancelled`, `failed` |
| `enum_notification_category` | `request`, `announcement`, `education`, `information`, `bankAccount`, `voucher`, `referral`, `balance_calculation`, `insurance`, `digital_consent`, `direct_debit_register`, `direct_debit_deduction`, `survey_immediate_trigger`, `flexben_claim`, `flexben_announcement`, `cutoff_reminder`, `fee_payment` |
| `survey_status_enum` | `ongoing`, `drafted`, `paused` |
| `survey_trigger_type_enum` | `after_withdrawal_request`, `after_signup`, `immediate` |

---

## Important Notes

1. **Dual company tables**: `company` (legacy, `company_id`) and `companies` (new, `id`). Most new code uses `companies`.
2. **Soft deletes**: Most tables use `deleted_at` timestamp + `is_deleted` int (0/1). Always filter `WHERE deleted_at IS NULL` or `is_deleted = 0`.
3. **`user_fcm_tokens` has UNIQUE constraint on `user_id`** — one FCM token per user.
4. **Migration in progress**: `employment` + `user_identity` tables are new schema replacing user employment fields in `users`. Use `legacy_user_id` as bridge.
5. **Timestamps**: Mix of `timestamp` (no tz) and `timestamptz`. New tables prefer `timestamptz`.
6. **Localization**: Many display fields have `_th` (Thai) and `_mm` (Myanmar) variants. New tables use `_locales` jsonb.
