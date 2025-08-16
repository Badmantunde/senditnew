import 'package:shared_preferences/shared_preferences.dart';
import 'package:sendit/features/wallet/wallet_service.dart';

class PaymentService {
  static const String baseUrl = 'https://3j97jn908h.execute-api.us-east-1.amazonaws.com/dev';
  
  // Get authentication token
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('id_token');
  }



  // Initialize Paystack payment
  static Future<Map<String, dynamic>> initializePaystackPayment({
    required double amount,
    required String email,
    required String reference,
    String? callbackUrl,
  }) async {
    try {
      // In a real app, you'd call Paystack's API
      // For now, we'll simulate the payment flow
      
      print('🔄 Initializing Paystack payment...');
      print('💰 Amount: ₦${amount.toStringAsFixed(2)}');
      print('📧 Email: $email');
      print('🔗 Reference: $reference');

      // Simulate payment processing
      await Future.delayed(Duration(seconds: 3));

      return {
        'success': true,
        'data': {
          'authorization_url': 'https://checkout.paystack.com/simulated-payment',
          'access_code': 'simulated_access_code',
          'reference': reference,
        },
        'message': 'Payment initialized successfully',
      };
    } catch (e) {
      print('❌ Error initializing Paystack payment: $e');
      return {
        'success': false,
        'message': 'Failed to initialize payment: $e',
      };
    }
  }

  // Verify Paystack payment
  static Future<Map<String, dynamic>> verifyPaystackPayment(String reference) async {
    try {
      print('🔄 Verifying Paystack payment...');
      print('🔗 Reference: $reference');

      // Simulate payment verification
      await Future.delayed(Duration(seconds: 2));

      // Simulate successful payment
      return {
        'success': true,
        'data': {
          'status': 'success',
          'reference': reference,
          'amount': 100000, // Amount in kobo
          'gateway_response': 'Successful',
        },
        'message': 'Payment verified successfully',
      };
    } catch (e) {
      print('❌ Error verifying Paystack payment: $e');
      return {
        'success': false,
        'message': 'Failed to verify payment: $e',
      };
    }
  }

  // Process wallet payment
  static Future<Map<String, dynamic>> processWalletPayment({
    required double amount,
    required String description,
  }) async {
    try {
      print('🔄 Processing wallet payment...');
      print('💰 Amount: ₦${amount.toStringAsFixed(2)}');
      print('📝 Description: $description');

      final walletService = WalletService();
      final currentBalance = walletService.balance;

      if (currentBalance < amount) {
        return {
          'success': false,
          'message': 'Insufficient wallet balance. Current balance: ₦${currentBalance.toStringAsFixed(2)}',
        };
      }

      // Deduct from wallet
      await walletService.subtractFromBalance(amount);

      return {
        'success': true,
        'transactionId': 'WALLET_${DateTime.now().millisecondsSinceEpoch}',
        'amount': amount,
        'message': 'Payment successful via wallet',
        'newBalance': walletService.balance,
      };
    } catch (e) {
      print('❌ Error processing wallet payment: $e');
      return {
        'success': false,
        'message': 'Wallet payment failed: $e',
      };
    }
  }

  // Process card payment (Mastercard, Visa, etc.)
  static Future<Map<String, dynamic>> processCardPayment({
    required String cardType,
    required double amount,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardholderName,
  }) async {
    try {
      print('🔄 Processing $cardType payment...');
      print('💰 Amount: ₦${amount.toStringAsFixed(2)}');
      print('💳 Card Type: $cardType');

      // Validate card details
      if (cardNumber.length < 13 || cardNumber.length > 19) {
        return {
          'success': false,
          'message': 'Invalid card number',
        };
      }

      if (cvv.length < 3 || cvv.length > 4) {
        return {
          'success': false,
          'message': 'Invalid CVV',
        };
      }

      // Simulate card payment processing
      await Future.delayed(Duration(seconds: 3));

      // Simulate successful payment
      return {
        'success': true,
        'transactionId': 'CARD_${cardType.toUpperCase()}_${DateTime.now().millisecondsSinceEpoch}',
        'amount': amount,
        'message': 'Payment successful via $cardType',
      };
    } catch (e) {
      print('❌ Error processing card payment: $e');
      return {
        'success': false,
        'message': 'Card payment failed: $e',
      };
    }
  }

  // Generic payment processor
  static Future<Map<String, dynamic>> processPayment({
    required String paymentMethod,
    required double amount,
    required String description,
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      print('🔄 Processing payment via $paymentMethod...');
      print('💰 Amount: ₦${amount.toStringAsFixed(2)}');

      switch (paymentMethod.toLowerCase()) {
        case 'wallet':
          return await processWalletPayment(
            amount: amount,
            description: description,
          );

        case 'paystack':
          final email = paymentDetails?['email'] ?? 'user@example.com';
          final reference = 'PAYSTACK_${DateTime.now().millisecondsSinceEpoch}';
          
          final initResult = await initializePaystackPayment(
            amount: amount,
            email: email,
            reference: reference,
          );

          if (!initResult['success']) {
            return initResult;
          }

          // Simulate payment completion
          await Future.delayed(Duration(seconds: 2));

          final verifyResult = await verifyPaystackPayment(reference);
          if (verifyResult['success']) {
            return {
              'success': true,
              'transactionId': reference,
              'amount': amount,
              'message': 'Payment successful via Paystack',
            };
          } else {
            return verifyResult;
          }

        case 'master':
        case 'visa':
        case 'verve':
          final cardNumber = paymentDetails?['cardNumber'] ?? '4111111111111111';
          final expiryDate = paymentDetails?['expiryDate'] ?? '12/25';
          final cvv = paymentDetails?['cvv'] ?? '123';
          final cardholderName = paymentDetails?['cardholderName'] ?? 'Test User';

          return await processCardPayment(
            cardType: paymentMethod,
            amount: amount,
            cardNumber: cardNumber,
            expiryDate: expiryDate,
            cvv: cvv,
            cardholderName: cardholderName,
          );

        default:
          return {
            'success': false,
            'message': 'Unsupported payment method: $paymentMethod',
          };
      }
    } catch (e) {
      print('❌ Error processing payment: $e');
      return {
        'success': false,
        'message': 'Payment processing failed: $e',
      };
    }
  }

  // Get payment methods available
  static List<Map<String, dynamic>> getAvailablePaymentMethods() {
    return [
      {
        'id': 'wallet',
        'name': 'Sendit Wallet',
        'description': 'Pay using your wallet balance',
        'icon': 'assets/images/wallet2.png',
        'enabled': true,
      },
      {
        'id': 'paystack',
        'name': 'Paystack',
        'description': 'Pay with card, bank transfer, or USSD',
        'icon': 'assets/images/paystack.png',
        'enabled': true,
      },
      {
        'id': 'master',
        'name': 'Mastercard',
        'description': 'Pay with Mastercard',
        'icon': 'assets/images/masterr.png',
        'enabled': true,
      },
      {
        'id': 'visa',
        'name': 'Visa Card',
        'description': 'Pay with Visa card',
        'icon': 'assets/images/vis.png',
        'enabled': true,
      },
      {
        'id': 'verve',
        'name': 'Verve Card',
        'description': 'Pay with Verve card',
        'icon': 'assets/images/verve.svg',
        'enabled': true,
      },
    ];
  }

  // Check if payment method is available
  static bool isPaymentMethodAvailable(String paymentMethod) {
    final methods = getAvailablePaymentMethods();
    return methods.any((method) => 
      method['id'] == paymentMethod.toLowerCase() && 
      method['enabled'] == true
    );
  }

  // Get wallet balance for payment validation
  static Future<double> getWalletBalance() async {
    final walletService = WalletService();
    await walletService.initializeBalance();
    return walletService.balance;
  }

  // Validate payment amount
  static bool isValidAmount(double amount) {
    return amount > 0 && amount <= 1000000; // Max ₦1M per transaction
  }

  // Generate unique transaction reference
  static String generateTransactionReference(String paymentMethod) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return '${paymentMethod.toUpperCase()}_$timestamp$random';
  }
} 