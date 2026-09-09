model "Nemeo MVP"

persona User
persona HouseholdMember
persona Agent

context Identity
context Connections
context Accounts
context Transactions
context Transfers
context Budget
context Reporting
context Household
context Access

# Account onboarding
slice "Create Account" {
  ui Sign-up Screen @User
  command Create Account
  event Account Created @Identity
}

slice "Authenticate User" {
  ui Sign-in Screen @User
  command Authenticate User
  event User Authenticated @Identity
}

slice "Connect SimpleFIN" {
  ui Provider Connection Screen @User
  command Connect Provider
  event Provider Connected @Connections
}

slice "Review Discovered Accounts" {
  view Discovered Provider Accounts from "Account Created", "User Authenticated", "Provider Connected"
  ui Account Selection Screen @User
}

slice "Link Selected Accounts" {
  ui Account Selection Confirmation @User
  command Link Accounts
  event Accounts Linked @Accounts
}

# Initial and scheduled ingestion
slice "Schedule Account Sync" {
  view Syncable Connections from "Accounts Linked"
  processor Sync Scheduler
}

slice "Start Account Sync" {
  command Start Account Sync
  event Account Sync Started @Connections
}
arrow Sync Scheduler -> Start Account Sync

slice "Request Provider Data" {
  view Provider Sync Requests from "Account Sync Started"
  translation SimpleFIN Adapter
}

slice "Receive Provider Data" {
  command Receive Provider Data
  event Provider Data Received @Connections
}
arrow SimpleFIN Adapter -> Receive Provider Data

slice "Normalize Provider Records" {
  view Received Provider Data from "Provider Data Received"
  processor Ingestion Normalizer
}

slice "Import Accounts and Transactions" {
  command Import Provider Records
  event Accounts and Transactions Imported @Accounts
}
arrow Ingestion Normalizer -> Import Provider Records

slice "Show Imported Transactions" {
  view Imported Transaction List from "Accounts and Transactions Imported"
  ui Transactions Screen @User
}

slice "Reconcile Provider Balances" {
  view Balance Reconciliation Worklist from "Accounts and Transactions Imported"
  processor Balance Reconciler
}

slice "Record Opening Balance" {
  command Record Opening Balance
  event Opening Balance Recorded @Accounts
}
arrow Balance Reconciler -> Record Opening Balance

slice "Show Reconciled Account Balance" {
  view Reconciled Transaction List from "Opening Balance Recorded"
  ui Reconciled Transactions Screen @User
}

# Categorization and transfer correctness
slice "Find Transactions Needing Categories" {
  view Unclassified Transactions from "Accounts and Transactions Imported"
  processor Categorization Engine
}

slice "Apply Suggested Categories" {
  command Apply Suggested Categories
  event Transactions Categorized @Transactions
}
arrow Categorization Engine -> Apply Suggested Categories

slice "Review Categorization" {
  view Categorization Review Queue from "Transactions Categorized"
  ui Categorization Review Screen @User
}

slice "Confirm Category Assignment" {
  ui Transaction Detail Screen @User
  command Confirm Category Assignment
  event Category Assignment Confirmed @Transactions
}

slice "Find Transfer Candidates" {
  view Transfer Candidate Queue from "Transactions Categorized"
  processor Transfer Matcher
}

slice "Classify Transfer" {
  command Classify Transfer
  event Transfer Classified @Transfers
}
arrow Transfer Matcher -> Classify Transfer

slice "Review Transfer Classification" {
  view Transfer Review Queue from "Transfer Classified"
  ui Transfer Review Screen @User
}

slice "Correct Transfer Classification" {
  ui Transfer Detail Screen @User
  command Correct Transfer Classification
  event Transfer Classification Corrected @Transfers
}

# Tracking budget setup and maintenance
slice "Open Budget Setup" {
  view Budget Setup Inputs from "Transactions Categorized", "Transfer Classified"
  ui Budget Setup Screen @User
}

slice "Create Tracking Budget" {
  command Create Tracking Budget
  event Tracking Budget Created @Budget
}
arrow Budget Setup Screen -> Create Tracking Budget

slice "Seed Category Targets" {
  view Category Target Seeding Inputs from "Tracking Budget Created"
  processor Budget Seeder
}

slice "Propose Category Targets" {
  command Propose Category Targets
  event Category Targets Proposed @Budget
}
arrow Budget Seeder -> Propose Category Targets

slice "Review Proposed Targets" {
  view Proposed Category Targets from "Category Targets Proposed"
  ui Target Review Screen @User
}

slice "Approve Category Targets" {
  ui Target Approval Screen @User
  command Approve Category Targets
  event Category Targets Approved @Budget
}

slice "Calculate Budget Progress" {
  view Budget Calculation Inputs from "Category Targets Approved", "Category Assignment Confirmed", "Transfer Classification Corrected"
  processor Budget Calculator
}

slice "Record Budget Progress" {
  command Recalculate Budget Progress
  event Budget Progress Calculated @Budget
}
arrow Budget Calculator -> Recalculate Budget Progress

slice "Show Budget Dashboard" {
  view Current Budget Dashboard from "Budget Progress Calculated"
  ui Budget Dashboard Screen @User
}

slice "Evaluate Pace" {
  view Pace Evaluation Inputs from "Budget Progress Calculated"
  processor Pace Evaluator
}

slice "Record Pace Warning" {
  command Record Pace Warning
  event Pace Warning Recorded @Reporting
}
arrow Pace Evaluator -> Record Pace Warning

slice "Show Pace Warning" {
  view Current Pace Warnings from "Pace Warning Recorded"
  ui Pace Warning Screen @User
}

# Household collaboration
slice "Invite Household Member" {
  ui Household Access Screen @User
  command Invite Household Member
  event Household Invitation Sent @Household
}

slice "Review Household Invitation" {
  view Pending Household Invitations from "Household Invitation Sent"
  ui Invitation Screen @HouseholdMember
}

slice "Accept Household Invitation" {
  ui Invitation Acceptance Screen @HouseholdMember
  command Accept Household Invitation
  event Household Member Added @Household
}

slice "View Household Progress" {
  view Shared Budget Progress from "Budget Progress Calculated", "Household Member Added"
  ui Family Progress Screen @HouseholdMember
}

slice "Edit Shared Categorization" {
  ui Shared Transaction Screen @HouseholdMember
  command Edit Shared Category
  event Shared Category Edited @Transactions
}

slice "Refresh Shared Categorization" {
  view Updated Shared Budget Inputs from "Shared Category Edited"
  ui Updated Shared Transaction Screen @HouseholdMember
}

# MCP reads and authorized writes
slice "Read Budget Through MCP" {
  view MCP Budget Data from "Budget Progress Calculated"
  ui MCP Budget Query @Agent
}

slice "Read Transactions Through MCP" {
  view MCP Transaction Data from "Accounts and Transactions Imported", "Transactions Categorized"
  ui MCP Transaction Query @Agent
}

slice "Authorize MCP Category Change" {
  translation MCP Category Change Adapter
}

slice "Record MCP Category Change" {
  command Apply MCP Category Change
  event MCP Category Change Recorded @Transactions
}
arrow MCP Category Change Adapter -> Apply MCP Category Change

slice "Read Updated MCP Transactions" {
  view Updated MCP Transaction Data from "MCP Category Change Recorded"
  ui Updated MCP Transaction Query @Agent
}
