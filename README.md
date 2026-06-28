# 💸 PayTrack - Personal Finance & Payment Planner

**PayTrack** is a beautifully designed, modern Flutter application built to help you track your personal loans, subscription plans, and any recurring payments with ease. With an intuitive and visually stunning dashboard, you'll never miss a due date again!

## ✨ Features

- **📊 Comprehensive Dashboard**: Get a bird's-eye view of your finances. View "Due This Month", "Lifetime Paid vs Remaining", "Installments Progress", and your "Plans by Type" with gorgeous charts powered by `fl_chart`.
- **📅 Smart Payment Plans**: Create Weekly, Monthly, or Annual payment plans. The app will automatically generate future installments for you!
- **💡 Strict OOP Architecture**: Built with Riverpod for robust state management and strictly adheres to Object-Oriented Programming principles. The core business logic is perfectly encapsulated inside the models.
- **🌍 Global Currency Support**: Instantly swap between USD, EUR, GBP, JPY, INR, LKR, and more without reloading. All charts and numbers update on the fly!
- **🧮 Built-in Loan Calculator**: Quickly calculate monthly payments and total interest for potential loans right inside the app.
- **📱 Responsive Navigation**: Swipe seamlessly between Analytics, Plans, and the Calculator using the intuitive PageView and custom top-bar navigation.
- **🎨 Stunning UI / Dark Mode**: Premium glassmorphic design that adapts beautifully to your device's Light or Dark theme.
- **🔔 Notifications**: (WIP) Built-in local notification scheduling so you are reminded X days before a payment is due.
- **💾 Offline First**: Uses Hive for blazing-fast, secure local storage.

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Dart SDK

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Whi7erose/PayTrack.git
   ```
2. Navigate into the directory:
   ```bash
   cd PayTrack
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## 🛠 Tech Stack
- **Framework:** Flutter
- **Language:** Dart
- **State Management:** Riverpod
- **Local Storage:** Hive
- **Charting:** fl_chart
- **Utilities:** intl, uuid

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
