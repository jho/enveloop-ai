model "Budgeting"

persona User

context Accounts
context Transactions
context Expenses
context Budget

slice "Add Accounts" {
  ui Accounts Screen @User
  command Add Accounts
  event Accounts Added @Accounts
}

slice "Account List" {
  view Account List from "Accounts Added"
  ui Accounts Screen @User
}

slice "Sync Queue" {
  view Sync Queue from "Accounts Added"
  processor Transaction Sync
}

slice "Import Transactions" {
  command Import Transactions
  event Transactions Synced @Transactions
}

slice "General Transactions" {
  view Transaction List from "Transactions Synced"
  ui Transactions Screen @User
}

slice "Search Transactions" {
  view Searchable Transactions from "Transactions Synced"
  ui Search Screen @User
}

slice "Review Expenses" {
  view Expense List from "Transactions Synced"
  ui Expenses Screen @User
}

slice "Categorize Expense" {
  ui Expense Detail @User
  command Categorize Expense
  event Expense Categorized @Expenses
}

slice "Uncategorized Expenses" {
  view Uncategorized Expenses from "Transactions Synced", "Expense Categorized"
  ui Uncategorized Expenses Screen @User
}

slice "Create Budget" {
  ui Budget Setup @User
  command Create Budget
  event Budget Created @Budget
}

slice "Budget Summary" {
  view Budget Summary from "Budget Created", "Budget Month Started", "Budget Month Ended", "Expense Categorized"
  ui Budget Screen @User
}

slice "Open Budget Month" {
  command Start Budget Month
  event Budget Month Started @Budget
}

slice "Close Budget Month" {
  command End Budget Month
  event Budget Month Ended @Budget
}
