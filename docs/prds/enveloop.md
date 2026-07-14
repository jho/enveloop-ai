---
title: "Enveloop PRD"
version: "0.1.0"
status: draft
owner: "jho"
stakeholders: []
created: "2026-07-10"
last-updated: "2026-07-12"
jira-epic: ""
---

# Enveloop

## Overview

**Summary:** Enveloop is an AI-friendly budgeting product that stays nearly headless for agent workflows while still giving family members a simple app for progress and review.

**Problem:** Most budgeting tools treat AI as a shallow embedded feature instead of making the product usable by external agents. That makes it hard for an AI power user to ask an assistant to set up, analyze, or optimize a budget from the outside.

**Why now:** AI agents are becoming a primary workflow surface, but budgeting products have not caught up. We want a product architecture that works well with desktop agents and always-on agents through MCP, without forcing the AI experience into a poorly embedded in-app chatbot.

## Budget model

Enveloop uses an envelope-style budgeting model:

- a budget is created first, then envelopes are created inside it
- initial setup links accounts, infers a starting envelope layout from recent transactions and income, and auto-categorizes by default
- the user should not need to manually build a budget before getting value
- money is assigned into envelopes inside a budget period
- transactions are categorized so they can be charged against the right envelope
- unassigned money stays available until the user or agent allocates it
- unused envelope funds roll forward into the next budget period unless the user reallocates them
- overspending in one envelope must be visible so the user or agent can rebalance the budget
- envelopes can be renamed and rebalanced by the user or an authorized family member
- transfers between envelopes should be supported as a first-class action

## Goals

| Goal | Metric | Baseline | Target |
|------|--------|----------|--------|
| Fast budget setup | Time from first launch to a usable budget | Manual setup often takes 30+ minutes | <= 10 minutes |
| Better optimization | Estimated discretionary savings identified by AI-assisted setup / review | Unclear or inconsistent | >= 5% of monthly discretionary spend |
| Clear budget awareness | Family viewer can correctly tell whether a purchase affects budget health in usability checks | Not available | 4/5 scenarios answered correctly |

## Users

| User / persona | Need | Pain today | Success state |
|----------------|------|------------|---------------|
| AI power user | Use an AI assistant to set up, optimize, and analyze a budget | Existing tools do not expose a usable agent interface | Can ask an agent to create budgets, build reports, and critique spending habits |
| Family viewer | See progress and understand the budget without doing the heavy lifting | Budgeting tools feel complex and full of controls they do not need | Can check progress and understand whether a purchase affects the budget |

## Scope

### In scope

- Link financial accounts with minimal setup steps
- Ingest and display transactions
- Auto-categorize transactions and assign them to envelopes
- Infer and initialize a starting budget from recent financial activity
- Fund and review envelope balances within a budget period
- Provide an MCP server so AI agents can inspect budget and transaction data
- Support a simple mobile family-viewer experience for progress review and edits
- Support core budget portability / export later, after adoption

### Out of scope

- Alerting and notification workflows
- Deep budgeting automation beyond the first setup / read / review loop
- Advanced analytics dashboards beyond the first reporting surface
- Local-first/offline-first architecture as a product pillar

## Domain terms

| Term | Definition | Notes / avoid |
|------|------------|---------------|
| Account | A linked bank account, credit card, or similar financial source | Avoid “posting” or “entry” |
| Transaction | A synced financial record from an account | Use this as the default record term |
| Merchant | The payee or counterparty associated with a transaction when available | Avoid swapping with “vendor” unless needed |
| Category | A label assigned to a transaction for budgeting and analysis; usually mapped to an envelope | Keep category names stable once chosen |
| Envelope | A named budget bucket created under a budget and funded within a budget period | The product’s core budgeting unit |
| Budget | The parent plan that owns envelopes and defines how money is organized for a budget period | Avoid overloading it to mean the app itself |
| Budget period | The time window used for planning, tracking, and reporting | Keep it flexible; do not lock it to month |
| Available | The amount of money still left to assign or spend in an envelope | Avoid using as a generic account balance term |
| Rollover | The carryforward of unused envelope funds into the next budget period | Keep the rule explicit in UX and agents |
| Report | A generated or saved presentation of financial data | Prefer this over “view” for user-facing analytics |
| MCP server | The integration layer external AI agents use to read and act on budget data | Keep this term consistent |
| Transfer | A movement of funds between envelopes or accounts | Keep explicit when rebalancing |

## Requirements

### Setup automation

**Story:** As an AI power user, I want to link my accounts and get an initial budget automatically so that I can use the product without manual setup work.

**Acceptance criteria:**
- [ ] A new user can link supported financial accounts with minimal setup steps
- [ ] The system can infer a starting envelope layout from recent transactions and income
- [ ] The system can auto-categorize transactions by default during setup
- [ ] A usable initial budget exists after linking and sync completes

### Account onboarding

**Story:** As an AI power user, I want to create an account and connect my financial sources so that the product can ingest my transactions.

**Acceptance criteria:**
- [ ] A new user can create an account successfully
- [ ] A linked account can ingest transactions from a supported provider
- [ ] The user can see imported transactions after the sync completes

### Budget setup

**Story:** As an AI power user, I want to create a budget and define envelopes so that the product can organize money into spending buckets.

**Acceptance criteria:**
- [ ] A user can create a budget
- [ ] A user can create one or more envelopes within that budget
- [ ] Each envelope has a name and an initial amount or funding rule
- [ ] Budget setup completes before transaction categorization is required

### Transaction review

**Story:** As an AI power user, I want to browse and review transactions so that I can understand spending patterns.

**Acceptance criteria:**
- [ ] The transaction list loads successfully for linked accounts
- [ ] Imported transactions are visible with core fields such as date, amount, merchant, and category when available
- [ ] The user can view transaction history without needing the MCP server

### Transaction cleanup automation

**Story:** As an AI power user, I want the system to clean up transaction data automatically so that I do not have to do manual bookkeeping.

**Acceptance criteria:**
- [ ] The system can detect likely duplicate transactions and surface them as a cleanup task or auto-resolve them when confidence is high
- [ ] The system can identify likely transfers and keep them from distorting spending analysis
- [ ] The system can split or adjust transactions when needed for accurate categorization
- [ ] Cleanup actions are driven by automation or AI rather than manual data-entry workflows

### Categorization and envelope assignment

**Story:** As an AI power user, I want to categorize transactions and assign them to envelopes so that the budget stays accurate.

**Acceptance criteria:**
- [ ] A transaction can be assigned to a category
- [ ] A transaction can be reassigned to a different category
- [ ] A categorized transaction can be reflected against the correct envelope balance
- [ ] Uncategorized transactions remain visible until they are assigned
- [ ] Envelope balances update when categorized transactions are applied
- [ ] A transfer between envelopes can update balances without being mistaken for spending

### MCP access

**Story:** As an AI power user, I want an MCP server that exposes transaction data so that Claude or another agent can inspect my finances.

**Acceptance criteria:**
- [ ] The MCP server can be configured locally or against a hosted endpoint
- [ ] An external agent can read transaction data through the MCP surface
- [ ] Access is limited to the connected user’s data

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
- [ ] The change updates the associated envelope balance
- [ ] The update is visible to other household members

### AI-assisted analysis

**Story:** As an AI power user, I want the system to help me analyze and optimize my budget so that I can improve my savings without doing the work manually.

**Acceptance criteria:**
- [ ] The system can propose envelope rebalancing recommendations
- [ ] The system can identify recurring spending patterns from recent transactions
- [ ] The system can generate or improve a report based on transaction and budget data
- [ ] The analysis surface can be used by an external AI agent through MCP

## Assumptions and constraints

| Type | Item | Impact if wrong |
|------|------|-----------------|
| Assumption | The best first value is agent-friendly budgeting, not a full consumer finance suite | If wrong, the product scope may need to expand significantly |
| Assumption | Users are willing to connect bank or card accounts through a supported data provider | If wrong, transaction ingestion becomes a blocking problem |
| Constraint | The product must work well with desktop, always-on, and mobile agents | If wrong, the core differentiation weakens |
| Constraint | Privacy and security expectations are high because the product touches financial data | If wrong, trust and adoption suffer |

## Dependencies and risks

| Dependency / risk | Type | Owner | Notes |
|-------------------|------|-------|------|
| Simple account-link provider | Dependency | TBD | Needed for account linking and transaction ingestion |
| MCP server hosting | Dependency | TBD | Needed to expose data to agents reliably |
| Authentication and authorization | Dependency | TBD | Must isolate each user’s financial data |
| Privacy and security review | Risk | TBD | Financial data raises the bar for storage, transport, and access control |
| Mobile app surface | Dependency | TBD | Needed for the family viewer experience |

## Open questions

| # | Question | Owner | Due |
|---|----------|-------|-----|
| Q1 | Which bank data provider should we target first? | jho | TBD |
| Q2 | Should the first MCP deployment be local-only, hosted-only, or both? | jho | TBD |
| Q3 | What level of read access should the family viewer have in v1? | jho | TBD |
| Q4 | What default auto-categorization rules should the setup flow use? | jho | TBD |
| Q5 | Which mobile platform should we prioritize first? | jho | TBD |
