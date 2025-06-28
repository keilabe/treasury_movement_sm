# Scheduled Transactions Feature

## Overview

The Treasury Movement app supports scheduled transactions, allowing users to set up transfers for future dates. This feature is useful for:

- Planning future payments
- Setting up recurring transfers
- Testing scenarios by simulating different dates
- Managing cash flow projections

## How It Works

### 1. Creating Scheduled Transactions

When creating a transfer:
- **Current/Past Date**: Transaction is executed immediately and balances are updated
- **Future Date**: Transaction is marked as "scheduled" and balances are NOT updated

### 2. Transaction Status

Transactions have two possible statuses:
- `completed`: Transaction has been executed and balances updated
- `scheduled`: Transaction is waiting to be executed

### 3. Executing Scheduled Transactions

Scheduled transactions can be executed in two ways:

#### Method 1: Dashboard
- If there are scheduled transactions due, a notification appears on the dashboard
- Click the "Execute" button to process all due transactions

#### Method 2: Transaction History
- Navigate to the Transaction History screen
- If there are scheduled transactions due, a prominent button appears
- Click "Execute Due Transactions" to process them

### 4. Visual Indicators

The app provides clear visual feedback:

- **Transfer Screen**: Shows whether a transaction will be scheduled or immediate
- **Transaction History**: Scheduled transactions are marked with orange color and "Scheduled" status
- **Dashboard**: Shows count of due scheduled transactions
- **Confirmation Screen**: Different messages for scheduled vs completed transactions

## Usage Examples

### Example 1: Schedule a Future Payment
1. Go to Transfer screen
2. Select accounts and enter amount
3. Choose a future date (e.g., next week)
4. The app will show "This transaction will be scheduled for [date]"
5. Click "Schedule Transfer"
6. Transaction appears in history with "Scheduled" status
7. Balances remain unchanged until execution

### Example 2: Simulate Time Passage
1. Create several scheduled transactions for different future dates
2. Change your device date to a future date
3. Go to Transaction History or Dashboard
4. Click "Execute Due Transactions"
5. All transactions due on or before the current date will be processed
6. Balances are updated and transaction status changes to "Completed"

### Example 3: Immediate Transfer
1. Go to Transfer screen
2. Select accounts and enter amount
3. Choose today's date or a past date
4. The app will show "This transaction will be executed immediately"
5. Click "Transfer Money"
6. Transaction is processed immediately and balances are updated

## Technical Details

### Provider Methods

- `transfer()`: Creates transactions and determines if they should be scheduled or immediate
- `executeDueScheduledTransactions()`: Processes all scheduled transactions that are due
- `_executeTransaction()`: Internal method that updates account balances

### Data Flow

1. **Creation**: Transaction is saved to Firestore with appropriate status
2. **Scheduling**: No balance updates occur
3. **Execution**: When executed, balances are updated and status changes to "completed"
4. **Sync**: All changes are synchronized with Firestore

### Error Handling

- The system includes comprehensive error handling and logging
- Failed executions are logged with detailed error messages
- The UI provides feedback through snackbars and status indicators

## Best Practices

1. **Testing**: Use scheduled transactions to test different scenarios without affecting current balances
2. **Planning**: Schedule recurring payments or future transfers in advance
3. **Simulation**: Change device dates to simulate different time periods
4. **Monitoring**: Regularly check the Transaction History for due scheduled transactions

## Limitations

- Scheduled transactions are based on device date/time
- No automatic execution - manual intervention required
- No recurring transaction support (each must be scheduled individually)
- FX rates are calculated at scheduling time, not execution time 