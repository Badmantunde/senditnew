# Order Integration with Payment Flow

This document describes the new order creation flow that ensures orders are only created after payment confirmation.

## Overview

The new order flow implements a **payment-first** approach where:
1. Order summary is computed first
2. Payment is processed and confirmed
3. Order is only created after successful payment
4. All data is properly cached locally

## Architecture

### 1. OrderService (`lib/features/home/data/order_service.dart`)
Handles all backend API interactions for orders:

- **computeOrderSummary()**: Gets pricing before payment
- **createOrder()**: Creates order after payment confirmation
- **getOrders()**: Fetches user's orders
- **getOrder()**: Fetches single order details
- **cancelOrder()**: Cancels an order

### 2. PaymentService (`lib/features/payment/payment_service.dart`)
Handles all payment processing:

- **processPayment()**: Generic payment processor
- **processWalletPayment()**: Wallet-based payments
- **processCardPayment()**: Card-based payments
- **initializePaystackPayment()**: Paystack integration
- **verifyPaystackPayment()**: Payment verification

### 3. ShippingFlowModal (`lib/features/home/presentation/modal/shipping_flow_modal.dart`)
The main UI flow that orchestrates the entire process:

- **Step 1**: Compute and display order summary
- **Step 2**: Select payment method
- **Step 3**: Process payment
- **Step 4**: Create order after payment
- **Step 5**: Show success/receipt

## Flow Diagram

```
User fills order form
        ↓
Validate required fields
        ↓
Show ShippingFlowModal
        ↓
Compute Order Summary (API)
        ↓
Display pricing to user
        ↓
User selects payment method
        ↓
Process Payment
        ↓
Payment Successful? ──No──→ Show Error
        ↓ Yes
Create Order (API)
        ↓
Order Created? ──No──→ Show Error
        ↓ Yes
Show Success & Cache Data
        ↓
Return to Home
```

## API Integration

### 1. Compute Order Summary
```dart
POST /orders/compute
{
  "items": [...],
  "pickup_address": {...},
  "drop_off": {...},
  "payment_method": "paystack",
  "payer": "owner"
}
```

### 2. Create Order (After Payment)
```dart
POST /orders
{
  "items": [...],
  "pickup_address": {...},
  "drop_off": {...},
  "payment_method": "paystack",
  "payer": "owner",
  "transaction_id": "PAY_1234567890"
}
```

## Payment Methods Supported

1. **Sendit Wallet**: Direct wallet deduction
2. **Paystack**: Card, bank transfer, USSD
3. **Mastercard**: Direct card payment
4. **Visa Card**: Direct card payment
5. **Verve Card**: Direct card payment

## Data Caching

### Order Caching
Orders are cached locally using SharedPreferences:
- Key: `created_orders`
- Format: JSON array of order objects
- Purpose: Offline access and quick retrieval

### Address Caching
Frequently used addresses are cached:
- Sender addresses: `saved_sender_addresses`
- Receiver addresses: `saved_receiver_addresses`
- Format: JSON array of address objects

## Error Handling

### Payment Failures
- Insufficient wallet balance
- Invalid card details
- Network errors
- Payment gateway errors

### Order Creation Failures
- API errors
- Invalid data
- Authentication issues

### Fallback Behavior
- Orders are cached locally even if API fails
- User can retry payment
- Clear error messages displayed

## Security Features

1. **Payment Verification**: All payments are verified before order creation
2. **Transaction IDs**: Unique transaction references for tracking
3. **Authentication**: All API calls require valid JWT tokens
4. **Data Validation**: Input validation at multiple levels
5. **Amount Limits**: Maximum transaction limits enforced

## Testing

Run the integration tests:
```bash
flutter test test_order_integration.dart
```

Tests cover:
- Order data preparation
- Address formatting
- Payment validation
- Payment method availability
- Transaction reference generation

## Usage Example

```dart
// 1. Prepare order data
final orderData = {
  'itemName': 'iPhone 16',
  'description': 'New iPhone',
  'category': 'Electronics',
  'weight': '0.5',
  'quantity': 1,
  'insured': true,
  'pickupAddress': {...},
  'dropoffAddress': {...},
};

// 2. Show shipping flow modal
final result = await showModalBottomSheet<bool>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => ShipmentFlowModal(orderData: orderData),
);

// 3. Handle result
if (result == true) {
  // Order created successfully
  Navigator.pop(context, true);
}
```

## Benefits

1. **Payment Guarantee**: Orders are only created after payment confirmation
2. **Better UX**: Clear pricing and payment flow
3. **Error Recovery**: Graceful handling of failures
4. **Offline Support**: Local caching for better performance
5. **Security**: Proper payment verification and authentication
6. **Scalability**: Modular design for easy extension

## Future Enhancements

1. **Real Paystack Integration**: Replace simulation with actual Paystack API
2. **Payment Webhooks**: Handle payment callbacks
3. **Order Tracking**: Real-time order status updates
4. **Push Notifications**: Order status notifications
5. **Analytics**: Payment and order analytics
6. **Refund Processing**: Handle refunds and cancellations 