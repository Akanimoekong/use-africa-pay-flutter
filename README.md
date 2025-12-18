# My Awesome Payment Package

A unified Flutter package for integrating multiple payment gateways into your web application. This package provides a simple, consistent API to handle payments through various providers, abstracting away the complexities of each individual SDK.

**Note:** This package is designed specifically for **Flutter Web** and uses `dart:js_interop` to communicate with the payment providers' JavaScript SDKs.

## Features

- ✅ Unified interface for multiple payment providers.
- ✅ Simple, type-safe configuration.
- ✅ Dynamically loads provider-specific JavaScript SDKs as needed.
- ✅ Supports the following payment providers:
  - **Flutterwave**
  - **Paystack**
  - **Monnify**
  - **Remita**

---

## Installation

1.  Add the following to your `pubspec.yaml` file under `dependencies`:

    ```yaml
    dependencies:
      flutter:
        sdk: flutter
      web: ^0.5.1 # Required for JS interoperability
      my_package: # Or whatever you name your package
        path: .
    ```

2.  Run `flutter pub get` to install the dependencies.

---

## Usage

Integrating a payment provider takes three simple steps: **Configure**, **Create**, and **Initialize**.

### Step 1: Configure the Payment

Create an `AdapterConfig` object. This defines all the necessary information for a transaction, such as the amount, currency, user details, and callbacks.

```dart
import 'package:my_package/my_package.dart';

// Define the configuration for the payment
final config = AdapterConfig(
  // Required for all providers
  publicKey: 'YOUR_PROVIDER_PUBLIC_KEY',
  reference: 'your_unique_transaction_reference_${DateTime.now().millisecondsSinceEpoch}',
  amount: 500000, // Amount in the lowest currency unit (e.g., kobo, cents)
  currency: 'NGN',
  user: User(
    email: 'customer@example.com',
    name: 'John Doe',
    phonenumber: '+1234567890',
  ),

  // --- Callbacks ---
  onSuccess: (PaymentResponse response) {
    print('Payment Successful!');
    print('Provider: ${response.provider}');
    print('Transaction ID: ${response.transactionId}');
  },
  onClose: () {
    print('Payment widget closed by user.');
  },

  // --- Provider-Specific Config ---
  // See the section below for details on each provider
  merchantId: 'YOUR_REMITA_MERCHANT_ID',      // For Remita
  serviceTypeId: 'YOUR_REMITA_SERVICE_TYPE_ID', // For Remita
  contractCode: 'YOUR_MONNIFY_CONTRACT_CODE', // For Monnify

  // --- Optional Metadata ---
  metadata: {
    'title': 'My Awesome Store',
    'description': 'Payment for 2 T-shirts',
    'order_id': 'ORD-12345',
  },
);
```

### Step 2: Create the Adapter

Use the `MyPackage.create()` factory to get an instance of the adapter for your desired payment provider.

```dart
// Select the provider you want to use
final provider = PaymentProvider.remita; // Or .flutterwave, .paystack, etc.

// Create the adapter instance
final AdapterInterface adapter = MyPackage.create(provider);
```

### Step 3: Load the Script and Initialize

Call `loadScript()` to dynamically inject the provider's JavaScript SDK into your web page. Once the script is loaded, call `initialize()` with your configuration to open the payment widget.

```dart
// Load the provider's script and then initialize the payment
adapter.loadScript().then((_) {
  adapter.initialize(config);
}).catchError((error) {
  print('Failed to load payment script: $error');
});
```

---

## Provider-Specific Configuration

Different providers have unique requirements. Make sure your `AdapterConfig` includes the correct fields for the provider you are using.

### Amount

- **Paystack**: Expects the amount in the **lowest currency unit** (e.g., kobo, cents).
- **Flutterwave, Monnify, Remita**: Expect the amount in the **major currency unit** (e.g., Naira, Dollars). The package handles the conversion automatically by dividing by 100.

### Required Fields

| Provider    | Required `AdapterConfig` Fields                     |
| :---------- | :-------------------------------------------------- |
| **Paystack**  | `publicKey`, `reference`, `amount`, `currency`, `user.email` |
| **Flutterwave** | `publicKey`, `reference`, `amount`, `currency`, `user.email` | 
| **Monnify**   | `publicKey`, `reference`, `amount`, `currency`, `user.email`, `user.name`, `contractCode` |
| **Remita**    | `publicKey`, `reference`, `amount`, `currency`, `user.email`, `merchantId`, `serviceTypeId` |

---

## Data Models

### `AdapterConfig`

The configuration object passed to the `initialize` method.

### `PaymentResponse`

The object returned in the `onSuccess` callback. It contains a normalized response from the payment provider, including status, transaction ID, provider name, and the raw response data.

### `User`

Represents the customer making the payment.
