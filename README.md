# Treasury Movement App

A comprehensive Flutter application for treasury and account management with support for multi-currency transactions, scheduled transfers, and real-time balance tracking.

## 🚀 Live Demo

**Interactive Demo**: [Hosted on bolt.new](https://bolt.new/treasury-movement-sm)

## 📱 Features

### Core Functionality
- **Multi-Account Management**: Manage multiple accounts with different currencies
- **Real-time Balance Tracking**: Live balance updates with Firebase integration
- **Multi-Currency Transfers**: Support for USD, KES, and NGN with FX conversion
- **Scheduled Transactions**: Plan future transfers with execution control
- **Transaction History**: Comprehensive transaction logging and filtering

### Advanced Features
- **Scheduled Transaction System**: 
  - Create transactions for future dates
  - Manual execution control
  - Visual status indicators
  - Balance protection until execution
- **FX Rate Management**: Static exchange rates for currency conversion
- **Firebase Integration**: Real-time data synchronization
- **Responsive UI**: Modern, intuitive interface with Material Design

## 🛠️ Technology Stack

- **Framework**: Flutter 3.7.2+
- **State Management**: Provider Pattern
- **Backend**: Firebase Firestore
- **Authentication**: Firebase Core
- **UI**: Material Design 3
- **Platform**: Cross-platform (iOS, Android, Web)

## 📋 Prerequisites

- Flutter SDK 3.7.2 or higher
- Dart SDK
- Firebase project setup
- Android Studio / VS Code

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/treasury_movement_sm.git
cd treasury_movement_sm
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup
1. Create a Firebase project
2. Enable Firestore Database
3. Add your Firebase configuration files
4. Set up Firestore security rules

### 4. Run the App
```bash
flutter run
```

## 📊 Data Structure

### Accounts Collection
```json
{
  "id": "account_id",
  "name": "Account Name",
  "currency": "USD",
  "balance": 1000.00
}
```

### Transactions Collection
```json
{
  "id": "transaction_id",
  "fromAccountId": "account_id",
  "toAccountId": "account_id",
  "amount": 100.00,
  "fromCurrency": "USD",
  "toCurrency": "KES",
  "convertedAmount": 12800.00,
  "rate": 128.0,
  "note": "Transaction note",
  "date": "2024-01-01T00:00:00Z",
  "status": "completed"
}
```

## 🔧 Configuration

### FX Rates
Static exchange rates are configured in `lib/providers/treasury_provider.dart`:
```dart
static const Map<String, double> fxRates = {
  'KES-USD': 0.0078,
  'KES-NGN': 1.2,
  'USD-KES': 128.0,
  'USD-NGN': 150.0,
  'NGN-KES': 0.83,
  'NGN-USD': 0.0067,
};
```

### Initial Data
The app comes with sample accounts and transactions. You can modify the initial data in the provider or add data directly to Firestore.

## 📱 App Screenshots

### Dashboard
- Account balance overview
- Quick transfer actions
- Scheduled transaction notifications

### Transfer Screen
- Multi-currency transfer interface
- Date selection for scheduling
- Real-time status indicators

### Transaction History
- Comprehensive transaction list
- Advanced filtering options
- Scheduled transaction execution

## 🔄 Scheduled Transactions

### How It Works
1. **Create**: Select a future date when creating a transfer
2. **Schedule**: Transaction is marked as "scheduled" with no balance impact
3. **Execute**: Use the "Execute Due Transactions" button to process scheduled transfers
4. **Complete**: Balances are updated and status changes to "completed"

### Use Cases
- **Future Payments**: Schedule recurring or one-time payments
- **Testing**: Simulate different time periods
- **Planning**: Manage cash flow projections
- **Simulation**: Test scenarios without affecting current balances

## 🧪 Testing

### Manual Testing
1. Create immediate transfers (today's date)
2. Create scheduled transfers (future date)
3. Execute scheduled transactions
4. Test multi-currency conversions
5. Verify balance updates

### Automated Testing
```bash
flutter test
```

## 📈 Performance

- **Real-time Updates**: Firebase Firestore integration
- **Optimized UI**: Efficient state management with Provider
- **Responsive Design**: Works across different screen sizes
- **Offline Support**: Basic offline functionality with local state

## 🔒 Security

- **Firestore Rules**: Configure appropriate security rules
- **Data Validation**: Input validation on all forms
- **Error Handling**: Comprehensive error handling and user feedback

## 🚀 Deployment

### Web Deployment
```bash
flutter build web
```

### Android Deployment
```bash
flutter build apk --release
```

### iOS Deployment
```bash
flutter build ios --release
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📞 Support

For support and questions:
- Create an issue in the repository
- Contact: [your-email@example.com]
- Documentation: [link-to-docs]

## 🔄 Version History

- **v1.0.0**: Initial release with core functionality
- **v1.1.0**: Added scheduled transactions feature
- **v1.2.0**: Enhanced UI and performance improvements

---

**Built with ❤️ using Flutter and Firebase**
