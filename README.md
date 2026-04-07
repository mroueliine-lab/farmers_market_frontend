# Farmers Market POS — Flutter App

A mobile and web Point of Sale (POS) application for the Farmers Market Platform, built with Flutter. This app is used by operators to manage farmer transactions, browse products, record repayments, and track debts.

## Features

- **Authentication** — Secure login with Laravel Sanctum token-based authentication. Session persists across app restarts.
- **Farmer Lookup** — Search farmers by phone number or unique identifier.
- **Create Farmer** — Register new farmer profiles with credit limit configuration.
- **Product Catalog** — Browse products organized by nested categories with tab navigation.
- **Place Orders** — Select products, enter quantities, calculate totals, and choose between cash or credit payment.
- **Debt Summary** — View all open debts for a specific farmer with original and remaining amounts.
- **Commodity Repayment** — Record repayments in kg, with automatic conversion to FCFA using the configured rate. Displays rate used, FCFA credited, and affected debts.
- **Responsive UI** — Adapts to phone, tablet, and desktop/web with bottom navigation on mobile and a side navigation rail on wider screens.

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter 3.x / Dart |
| State Management | Riverpod (StateNotifier, FutureProvider) |
| Navigation | go_router with ShellRoute + auth redirect guard |
| HTTP Client | Dio with Bearer token interceptor |
| Secure Storage | flutter_secure_storage (Android Keystore / iOS Keychain) |
| Architecture | Feature-based clean architecture |

## Project Structure

```
lib/
  core/
    config/         # App configuration (base URL)
    network/        # Dio client + auth interceptor
    storage/        # Secure storage service
    providers.dart  # Shared Riverpod providers
    router.dart     # App navigation + route guard
    responsive.dart # Responsive layout helper
  features/
    auth/           # Login, token management, session restore
    farmers/        # Farmer search, profile, create
    products/       # Product catalog, categories
    cart/           # Cart state, order placement, checkout
    debts/          # Debt list, repayment recording
    home/           # Home screen with quick actions
```

## Prerequisites

- Flutter 3.x SDK
- Dart SDK
- Android emulator / iOS simulator / web browser
- Laravel backend running (see backend repository)

## Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/mroueliine-lab/farmers_market_frontend.git
   cd farmers_market_frontend
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure the backend URL in `lib/core/config/app_config.dart`:
   ```dart
   class AppConfig {
     static const String baseUrl = 'http://your-backend-url/api';
   }
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Backend

This app communicates with a Laravel 11 backend using Sanctum token authentication. The backend repository handles:
- User authentication and role management (Admin, Supervisor, Operator)
- Product and category management
- Farmer profiles and credit limits
- Transaction processing with FIFO debt repayment
- Commodity rate configuration

## Notes

- Operators must be created by an Admin or Supervisor through the backend — there is no self-registration in the POS app.
- Credit limit enforcement is handled server-side. If a credit order exceeds the farmer's available credit, the backend returns a 422 error which is displayed to the operator.
- Debt repayments follow FIFO order — oldest debts are paid first.