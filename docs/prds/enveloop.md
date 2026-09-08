---
title: "Pace PRD (working name)"
version: "0.3.0"
status: draft
owner: "jho"
stakeholders: []
created: "2026-07-10"
last-updated: "2026-09-07"
jira-epic: ""
---

# Pace (working name)

## Overview

**Summary:** Pace is an AI-friendly, tracking-based budgeting product that stays nearly headless for agent workflows while still giving individuals and families a simple app for progress and review. “Pace” is a working name; the final product rename is still to be decided.

**Problem:** Envelope budgeting asks people to pre-allocate and continuously rebalance money, which creates too much setup and maintenance. Users need a lower-friction way to track spending against a plan and understand whether current spending is sustainable. Most budgeting tools also treat AI as a shallow embedded feature instead of making the product usable by external agents.

**Why now:** AI agents are becoming a primary workflow surface, but budgeting products have not caught up. We want a product architecture that works well with desktop agents and always-on agents through MCP, without forcing the AI experience into a poorly embedded in-app chatbot.

## Budget model: tracking-based by default

Pace uses tracking-based budgeting as the default workflow:

- a budget is created with spending categories and target amounts or limits for a budget period
- initial setup links accounts, infers useful categories and starting targets from recent transactions and income, and auto-categorizes by default
- the user should see useful tracking results without manually assigning every dollar
- transactions count against the relevant category as they are imported and categorized
- each category shows actual spend, target, remaining amount, and pace status
- pace is calculated from elapsed time in the budget period; the system warns when projected spend is likely to exceed the target
- users can adjust targets without moving money between envelopes
- optional envelope-style allocation may be supported later, but it is not the primary MVP workflow

## Goals

| Goal | Metric | Baseline | Target |
|------|--------|----------|--------|
| Fast budget setup | Time from first launch to a usable budget | Manual setup often takes 30+ minutes | <= 10 minutes |
| Better optimization | Estimated discretionary savings identified by AI-assisted setup / review | Unclear or inconsistent | >= 5% of monthly discretionary spend |
| Clear budget awareness | Family viewer can correctly tell whether a purchase affects budget health in usability checks | Not available | 4/5 scenarios answered correctly |
| Fast signup | New user can reach authenticated onboarding | No baseline | Google sign-up/login completes in <= 2 minutes |
| Actionable pacing | Users notice and understand an ahead-of-pace warning | Not available | >= 80% of test users correctly identify the affected category and action |

## Users

| User / persona | Need | Pain today | Success state |
|----------------|------|------------|---------------|
| AI power user | Use an AI assistant to set up, optimize, and analyze a budget | Existing tools do not expose a usable agent interface | Can ask an agent to create budgets, build reports, and critique spending habits |
| Family viewer | See progress and understand the budget without doing the heavy lifting | Budgeting tools feel complex and full of controls they do not need | Can check progress and understand whether a purchase affects the budget |
| Individual / household budget owner | Track spending without manually allocating every dollar | Envelope setup and rebalancing are tedious | Can connect accounts and understand category pace with minimal maintenance |

## Scope

### In scope

- Link financial accounts through a native SimpleFIN connection flow with minimal setup steps
- Support SimpleFIN transaction ingestion with the maximum historical backfill the provider makes available
- Schedule SimpleFIN synchronization and AI categorization on provider-compatible cadences
- Design the provider boundary so additional financial-data providers can be added later without changing the budget domain model
- Ingest and display transactions
- Identify and normalize transfers between linked accounts so they do not double-count against the budget
- Auto-categorize transactions into tracking categories
- Infer and initialize category targets from recent financial activity and income
- Seed budgets from historical spending with conservative behavior when history is sparse
- Support category caps, protected categories, monthly carryover, rebalancing, and clearing/reset tools
- Maintain category ordering and taxonomy over time
- Track actual spending against category targets within a budget period
- Calculate category and overall budget pace, including projected target variance
- Show ahead-of-pace warnings in the product
- Provide a basic current-month dashboard for cashflow, budget progress, and top spending destinations
- Sign up and log in with Google; retain an extensible provider model for future auth providers
- Provide an MCP server so AI agents can inspect budget and transaction data
- Support a simple mobile family-viewer experience for progress review and edits
- Support core budget portability / export later, after adoption
- Support household invitations and role-based access for shared budget review

### Out of scope

- Push, email, SMS, and highly configurable alerting workflows beyond in-product warnings
- Deep budgeting automation beyond the first setup / read / review loop
- Advanced analytics dashboards beyond the first reporting surface
- Envelope allocation as the default budgeting model
- Additional identity providers beyond Google in the first release

## Domain terms

| Term | Definition | Notes / avoid |
|------|------------|---------------|
| Provider | An external financial-data service used to connect accounts and import records | SimpleFIN is the first provider; keep provider-specific details behind an adapter |
| Account | A linked bank account, credit card, or similar financial source | Avoid “posting” or “entry” |
| Transaction | A synced financial record from an account | Use this as the default record term |
| Merchant | The payee or counterparty associated with a transaction when available | Avoid swapping with “vendor” unless needed |
| Payee | The normalized recipient or source displayed for a transaction, including native transfer payees | Keep transfer payees distinct from merchants |
| Category | A named spending group used to organize transactions and compare actual spending with a target | This replaces “envelope” in the default workflow |
| Target | The planned amount or spending limit for a category in a budget period | Do not imply that money has been physically allocated |
| Category cap | A maximum target or spending limit that automation must not exceed without explicit permission | Caps protect against over-allocation from inferred or automated budgets |
| Protected category | A category whose target or balance automation cannot change without explicit permission | Use for essentials, obligations, or user-selected categories |
| Budget | The parent plan that owns categories and targets for a budget period | Avoid overloading it to mean the app itself |
| Budget period | The time window used for planning, tracking, and reporting | Keep it flexible; do not lock it to month |
| Actual spend | Categorized spending recorded during a budget period | Excludes transfers and other non-spending transactions |
| Pace status | A category’s relationship between current actual spend, elapsed period time, and target | Use “on pace,” “ahead of pace,” or “behind pace” consistently |
| Projected spend | Estimated spend at the end of the budget period if the current pace continues | Clearly label this as a projection |
| Envelope | An optional allocation bucket supported only if/when envelope budgeting is added | Do not use as the default category term |
| Report | A generated or saved presentation of financial data | Prefer this over “view” for user-facing analytics |
| Reporting period | The time range used by a dashboard or report | The current month is the default MVP period |
| Comparison baseline | A prior period or historical average used to contextualize current results | MVP baselines include last month and average |
| Sync run | One scheduled or manually requested provider synchronization attempt | Track status and errors independently for each run |
| Categorization confidence | The system’s confidence that a category assignment is correct | Low-confidence assignments require review or clear labeling |
| Household member | A person granted access to a shared budget with a defined role | Never assume all members have the same permissions |
| MCP server | The integration layer external AI agents use to read and act on budget data | Keep this term consistent |
| Transfer | A movement of funds between linked accounts that must not be counted as income or spending | Represent both sides with canonical source-account, destination-account, and direction mappings |
| Transfer rule | A reusable rule that identifies or labels recurring transfers based on account, direction, payee, amount, or other transaction signals | Rules must be reviewable and reversible |
| Opening balance | The starting balance established for a connected account before imported transaction history begins | It may be created or corrected when historical data is incomplete |

## Requirements

### Setup automation

**Story:** As an AI power user, I want to link my accounts and get an initial budget automatically so that I can use the product without manual setup work.

**Acceptance criteria:**
- [ ] A new user can link supported financial accounts with minimal setup steps
- [ ] The system can infer starting categories and targets from recent transactions and income
- [ ] The system can auto-categorize transactions by default during setup
- [ ] A usable initial budget exists after linking and sync completes

### Account onboarding

**Story:** As an AI power user, I want to create an account and connect my financial sources so that the product can ingest my transactions.

**Acceptance criteria:**
- [ ] A new user can create an account successfully
- [ ] A new user can sign up and log in with Google
- [ ] Provider identity is stored separately from the product profile so additional auth providers can be added later
- [ ] Authentication failures and account-linking conflicts show a recoverable next step
- [ ] A new user can link SimpleFIN natively from the product without a separate manual import workflow
- [ ] A linked SimpleFIN account can ingest transactions and balances
- [ ] The user can see imported transactions after the sync completes
- [ ] A user can disconnect and reconnect a provider connection without deleting the associated budget history
- [ ] Provider credentials or access URLs are handled according to provider requirements and are not exposed in normal transaction views
- [ ] The user can select which discovered accounts to include in the budget

### SimpleFIN ingestion

**Story:** As a budget owner, I want SimpleFIN accounts and history imported reliably so that my tracking budget starts with an accurate picture of my finances.

**Acceptance criteria:**
- [ ] The initial SimpleFIN sync requests and imports the maximum historical transaction data the provider makes available, which may currently be limited to approximately six months
- [ ] Sync requests use overlapping date windows so boundary transactions are not missed between requests
- [ ] The system deduplicates records returned by overlapping windows without creating duplicate transactions
- [ ] The system discovers all eligible accounts exposed by the connected SimpleFIN connection and shows them for confirmation
- [ ] Imported account balances are reconciled against the provider’s current balances and discrepancies are surfaced
- [ ] The system creates or calculates an opening balance when imported history does not explain the account’s starting balance
- [ ] A user can review and correct an opening balance without editing imported transactions
- [ ] Correcting an opening balance reconciles the account’s displayed balance without rewriting provider-sourced transactions
- [ ] A subsequent sync preserves previously imported records and only adds or updates provider records safely
- [ ] Provider-specific sync state and identifiers are retained for reliable incremental synchronization
- [ ] Each imported transaction and account retains a stable provider identifier for idempotent updates and reconciliation
- [ ] A partial provider failure identifies affected accounts while preserving successfully imported data
- [ ] Provider-reported pending, updated, and removed records are handled without duplicating or silently losing transaction history

### Scheduled synchronization and categorization

**Story:** As a budget owner, I want account sync and transaction categorization to happen automatically on a provider-compatible schedule so that my budget stays current without manual refreshes.

**Acceptance criteria:**
- [ ] The system schedules recurring SimpleFIN syncs using a cadence compatible with provider terms, limits, and operational guidance
- [ ] The scheduler respects provider rate limits and does not issue requests more frequently than allowed
- [ ] Sync jobs use retries, backoff, and failure handling appropriate to transient provider errors
- [ ] A successful sync triggers AI auto-categorization for new or changed transactions, subject to configured provider and system limits
- [ ] Categorization jobs are idempotent and do not overwrite user-confirmed categories without explicit permission
- [ ] The system records sync and categorization status, timestamps, failures, and the next scheduled attempt
- [ ] Users can see when data was last updated and manually request a refresh when permitted by provider limits
- [ ] A failed sync or categorization job does not block later scheduled attempts or corrupt existing account, transaction, or budget data
- [ ] The scheduling boundary supports future providers with different sync capabilities, rate limits, and cadence requirements
- [ ] Scheduled jobs are scoped to the correct user and account connection and do not run after a connection is revoked

### Provider extensibility

**Story:** As the product team, we want a provider-neutral ingestion boundary so that additional financial-data providers can be added after MVP without rewriting budgeting logic.

**Acceptance criteria:**
- [ ] Imported accounts, transactions, balances, and sync results use provider-neutral product models
- [ ] Provider-specific identifiers and raw metadata can be retained for reconciliation and troubleshooting
- [ ] Adding a future provider does not require changes to category targets, pace calculations, or reporting contracts
- [ ] SimpleFIN remains the only required financial-data provider for the first release

### Budget setup

**Story:** As a budget owner, I want to create a tracking budget and define category targets so that I can understand spending without allocating every dollar.

**Acceptance criteria:**
- [ ] A user can create a budget
- [ ] A user can create one or more categories within that budget
- [ ] Each category has a name and a target amount or limit
- [ ] A budget has explicit start and end dates and a timezone used consistently for periods, schedules, and reports
- [ ] Budget setup does not require the user to assign available cash to categories
- [ ] A usable budget can be inferred from recent activity and reviewed before activation

### Budget automation

**Story:** As a budget owner, I want the system to seed and maintain my budget conservatively so that it stays useful without requiring constant manual upkeep.

**Acceptance criteria:**
- [ ] The system can seed category targets from historical spending, using available history and clearly showing the basis for each suggested target
- [ ] When history is sparse or unreliable, the system uses conservative defaults, marks uncertainty, and avoids presenting guesses as established spending patterns
- [ ] A user can set category caps that automated seeding and rebalancing cannot exceed without confirmation
- [ ] A user can protect categories from automated target changes or clearing/reset actions
- [ ] The system can carry category target variances into the next monthly budget period according to the configured carryover policy
- [ ] A user can preview and approve automated budget rebalancing before targets change, except where the user has explicitly enabled automatic rebalancing
- [ ] Rebalancing respects category caps and protected categories and explains each proposed change
- [ ] A user can clear or reset the current budget, selected categories, or automation suggestions without deleting imported transactions
- [ ] Clear and reset actions require explicit confirmation and state exactly what will and will not change
- [ ] Clearing or resetting a budget preserves an auditable history of prior targets and user decisions
- [ ] A user can reorder categories for display without changing transaction categorization or calculations
- [ ] A user can maintain the category taxonomy by renaming, merging, splitting, archiving, and restoring categories with an appropriate transaction-history policy
- [ ] Taxonomy changes do not silently change historical spending totals or pace results
- [ ] Automation records the prior and new target, the reason for the change, and whether the user approved it

### Basic reporting and dashboarding

**Story:** As a budget owner, I want a simple current-month dashboard so that I can quickly understand cashflow, budget progress, and where money is going.

**Acceptance criteria:**
- [ ] The dashboard defaults to the current calendar month and clearly shows the reporting period
- [ ] The user can toggle comparisons between the current month, last month, and a defined historical average
- [ ] The dashboard shows cash inflows, cash outflows, and net cashflow for the selected period
- [ ] Transfers and credit-card payments are excluded from cashflow income and spending totals, while remaining available in transaction detail when relevant
- [ ] Budget progress is shown as a line graph over the selected period with actual spending and target/expected pace
- [ ] Budget progress supports comparison lines for last month and the historical average when sufficient data exists
- [ ] The dashboard identifies categories that are ahead of pace and links to the relevant budget or transactions
- [ ] The dashboard shows top categories by total dollars spent and by transaction count
- [ ] The dashboard shows top merchants by total dollars spent and by transaction count
- [ ] Category and merchant rankings use the same transfer, refund, and non-spending treatment as budget calculations
- [ ] Empty, partial, or insufficient-history states are explained without presenting misleading comparisons
- [ ] Dashboard values link to the underlying transactions or category details for review
- [ ] The current month’s partial-period data is labeled as partial and is not presented as a complete-month comparison
- [ ] The historical average uses a documented window and excludes periods without sufficient comparable data
- [ ] Cashflow, rankings, and graphs use the same account inclusion, transfer, refund, and date/timezone rules

### Transaction review

**Story:** As an AI power user, I want to browse and review transactions so that I can understand spending patterns.

**Acceptance criteria:**
- [ ] The transaction list loads successfully for linked accounts
- [ ] Imported transactions are visible with core fields such as date, amount, merchant, and category when available
- [ ] The user can view transaction history without needing the MCP server
- [ ] The user can filter or search transactions by account, date, payee, category, transfer status, and review status
- [ ] The user can see whether a transaction was imported, categorized automatically, categorized by a user, or marked as a transfer

### Transaction cleanup automation

**Story:** As an AI power user, I want the system to clean up transaction data automatically so that I do not have to do manual bookkeeping.

**Acceptance criteria:**
- [ ] The system can detect likely duplicate transactions and surface them as a cleanup task or auto-resolve them when confidence is high
- [ ] The system can identify likely transfers and keep them from distorting spending analysis
- [ ] The system can split or adjust transactions when needed for accurate categorization
- [ ] Cleanup actions are driven by automation or AI rather than manual data-entry workflows

### Transfer correctness

**Story:** As a budget owner, I want transfers between my accounts identified correctly so that moving money does not double-penalize my budget or appear as income.

**Acceptance criteria:**
- [ ] The system represents a transfer with canonical source-account, destination-account, and direction mappings
- [ ] Matching transaction pairs across linked accounts are identified as one transfer rather than two spending or income events
- [ ] The system provides native transfer payees for common transfer relationships, including credit-card payments
- [ ] Users and authorized agents can create, review, disable, and update transfer rules
- [ ] Transfer rules can use account pair, transaction direction, normalized payee, amount, timing, and other supported signals
- [ ] Historical transactions can be retagged as transfers when a new match or rule is confirmed
- [ ] The system detects duplicate transfer records, preserves the canonical transfer, and provides a cleanup path for duplicates
- [ ] Transfers are excluded from income totals, spending totals, category actuals, and budget pace calculations
- [ ] Credit-card payments are not treated as income, spending, or new budget activity on either side of the payment
- [ ] Users can inspect why a transaction was identified as a transfer and correct a false positive without losing the underlying transaction

### Categorization and tracking

**Story:** As a budget owner, I want transactions categorized and reflected against tracking targets so that the budget stays accurate with minimal maintenance.

**Acceptance criteria:**
- [ ] A transaction can be assigned to a category
- [ ] A transaction can be reassigned to a different category
- [ ] A categorized transaction is reflected against the correct category’s actual spend
- [ ] Uncategorized transactions remain visible until they are assigned
- [ ] Category actuals and remaining target update when categorized transactions are applied
- [ ] Transfers and other non-spending transactions are excluded from spending actuals
- [ ] AI assignments include a confidence or review state that is visible to the user
- [ ] A user-confirmed category is not overwritten by scheduled AI categorization without explicit permission
- [ ] A user can correct an AI assignment and optionally create a reusable payee or category rule
- [ ] New transactions with low-confidence or unknown categories are surfaced in a review queue

### Budget pace alerts

**Story:** As a budget owner, I want a warning when spending is ahead of pace so that I can adjust before exceeding a category target.

**Acceptance criteria:**
- [ ] The system calculates pace status for each tracked category with a target
- [ ] A category is marked ahead of pace when actual spend and elapsed-period timing indicate likely target overrun
- [ ] The user can see actual spend, target, elapsed period, projected spend, and the reason for the warning
- [ ] An in-product warning identifies the affected category and links to relevant transactions or a review action
- [ ] The system avoids repeated duplicate warnings for the same category and budget period
- [ ] Users can dismiss or snooze a warning without changing transaction data
- [ ] The system does not issue an ahead-of-pace warning when the category lacks a target or has insufficient period data

### MCP access

**Story:** As an AI power user, I want an MCP server that exposes transaction data so that Claude or another agent can inspect my finances.

**Acceptance criteria:**
- [ ] The MCP server can be configured locally or against a hosted endpoint
- [ ] An external agent can read transaction data through the MCP surface
- [ ] An external agent can read budgets, categories, targets, pace status, and dashboard report data through the MCP surface
- [ ] Access is limited to the connected user’s data
- [ ] Any agent action that changes transactions, categories, targets, rules, or connections is authorized, auditable, and subject to confirmation policy

### Family progress

**Story:** As a family viewer, I want to check budget progress so that I can understand whether spending is on track.

**Acceptance criteria:**
- [ ] A viewer can open a simplified progress screen on mobile
- [ ] The screen shows budget-period progress and recent transaction impact
- [ ] The screen is understandable without requiring budget setup actions
- [ ] A viewer can edit a transaction categorization on mobile

### Household edits

**Story:** As a family member, I want to edit a transaction categorization so that the shared budget stays accurate.

**Acceptance criteria:**
- [ ] A family member can change a transaction category
- [ ] The change updates the associated category actuals and pace status
- [ ] The update is visible to other household members

### Household access

**Story:** As a budget owner, I want to share a budget with household members using clear roles so that collaboration does not expose more financial control than intended.

**Acceptance criteria:**
- [ ] A budget owner can invite a household member and revoke the invitation or access
- [ ] Each household member has an explicit role and permission set
- [ ] Read-only members can view permitted progress and reports without changing budget configuration
- [ ] Members with edit permission can change categories or transaction assignments only within their granted scope
- [ ] Permission changes take effect for subsequent requests and are visible in an access history

### AI-assisted analysis

**Story:** As an AI power user, I want the system to help me analyze and optimize my budget so that I can improve my savings without doing the work manually.

**Acceptance criteria:**
- [ ] The system can propose category target changes or spending interventions
- [ ] The system can identify recurring spending patterns from recent transactions
- [ ] The system can generate or improve a report based on transaction and budget data
- [ ] The analysis surface can be used by an external AI agent through MCP

### Security and data lifecycle

**Story:** As a user of a financial-data product, I want my data and access to be protected so that connecting accounts does not create unnecessary exposure.

**Acceptance criteria:**
- [ ] A user can access only their own accounts, transactions, budgets, reports, and provider connection details unless explicitly shared
- [ ] Household and MCP access checks are enforced server-side for every read and write operation
- [ ] Provider credentials, tokens, and connection secrets are encrypted and excluded from logs and ordinary API responses
- [ ] Disconnecting a provider prevents future scheduled syncs while preserving already imported data according to the product’s retention policy
- [ ] Sensitive access and mutation events are recorded for audit and troubleshooting

## Release phases

### MVP

The MVP should get a household from account linking to a usable budget with minimal manual work.

Includes:
- Setup automation
- Account onboarding
- SimpleFIN ingestion
- Provider extensibility boundary
- Transfer correctness
- Budget setup
- Budget automation
- Scheduled synchronization and categorization
- Basic reporting and dashboarding
- Transaction review
- Categorization and tracking
- Budget pace alerts
- Google authentication
- MCP access
- Family progress
- Household access
- Household edits

### Post-MVP

These capabilities should be designed for, but can ship after the first usable product:

- Transaction cleanup automation
- AI-assisted analysis
- Core budget portability / export
- Advanced reporting depth
- Local-first/offline-first architecture
- Additional authentication providers
- Optional envelope-style allocation

## Assumptions and constraints

| Type | Item | Impact if wrong |
|------|------|-----------------|
| Assumption | The best first value is agent-friendly tracking, not a full consumer finance suite | If wrong, the product scope may need to expand significantly |
| Assumption | Users are willing to connect bank or card accounts through a supported data provider | If wrong, transaction ingestion becomes a blocking problem |
| Constraint | The product must work well with desktop, always-on, and mobile agents | If wrong, the core differentiation weakens |
| Constraint | Privacy and security expectations are high because the product touches financial data | If wrong, trust and adoption suffer |
| Constraint | Budget pace warnings must be understandable and conservative enough to avoid alert fatigue | If wrong, users may ignore the product |
| Constraint | Transfer classification must be conservative and explainable because false positives can hide real spending | If wrong, budget totals and user trust suffer |
| Constraint | Budget automation must be reversible and must not overwrite transactions or silently change protected categories | If wrong, users lose control of their financial history |

## Dependencies and risks

| Dependency / risk | Type | Owner | Notes |
|-------------------|------|-------|------|
| SimpleFIN integration | Dependency | TBD | Required for native account linking, provider-available historical backfill, sync, and balance reconciliation |
| MCP server hosting | Dependency | TBD | Needed to expose data to agents reliably |
| Authentication and authorization | Dependency | TBD | Must isolate each user’s financial data |
| Google identity integration | Dependency | TBD | Needed for low-friction MVP signup/login; should leave room for additional providers |
| Transfer matching and normalization | Dependency | TBD | Needed to map account directions, transfer payees, rules, historical retagging, and duplicate cleanup |
| Budget automation engine | Dependency | TBD | Needed for historical seeding, caps, protected categories, carryover, rebalancing, reset tools, and taxonomy maintenance |
| Job scheduler and provider policy handling | Dependency | TBD | Needed for provider-compatible SimpleFIN sync, retries, rate limits, and scheduled AI categorization |
| Privacy and security review | Risk | TBD | Financial data raises the bar for storage, transport, and access control |
| Mobile app surface | Dependency | TBD | Needed for the family viewer experience |

## Open questions

| # | Question | Owner | Due |
|---|----------|-------|-----|
| Q1 | What SimpleFIN connection flow and credential-handling approach should the MVP use? | jho | Before implementation |
| Q2 | Should the first MCP deployment be local-only, hosted-only, or both? | jho | TBD |
| Q3 | What level of read access should the family viewer have in v1? | jho | TBD |
| Q4 | What default auto-categorization rules should the setup flow use? | jho | TBD |
| Q5 | Which mobile platform should we prioritize first? | jho | TBD |
| Q6 | What should the final product name be, and should the repository/docs be renamed with it? | jho | Before implementation |
| Q7 | Should pace use only elapsed calendar time, or account for income timing and known recurring bills? | jho | Before alert implementation |
| Q8 | Which in-product alert controls are required for MVP: dismiss, snooze, thresholds, or all three? | jho | Before alert implementation |
| Q9 | Do existing envelope concepts/data need to be migrated, or can the product make a clean model transition? | jho | Before implementation |
| Q10 | Which transfer matches can be auto-applied versus requiring user confirmation? | jho | Before implementation |
| Q11 | Does monthly carryover apply to unused target, overspend variance, or both, and should it be opt-in per category? | jho | Before implementation |
| Q12 | Which categories should be protected by default, if any? | jho | Before implementation |
| Q13 | What default sync cadence should we use within the limits and guidance of SimpleFIN, and should users be able to customize it? | jho | Before implementation |
| Q14 | What historical window should define the average comparison baseline? | jho | Before dashboard implementation |
| Q15 | What confidence threshold should send an AI categorization to review instead of applying it automatically? | jho | Before categorization implementation |
| Q16 | What is the retention and deletion policy for disconnected provider data, audit history, and user accounts? | jho | Before implementation |
| Q17 | Which household roles and permissions are required for the first release? | jho | Before household implementation |
