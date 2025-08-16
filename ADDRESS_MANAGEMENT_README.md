# Address Management System

This document describes the address management functionality implemented in the SendIt Flutter app.

## Overview

The address management system allows users to:
- Create, read, update, and delete addresses
- View saved addresses in a dedicated screen
- Select addresses during order creation
- Manage addresses through a user-friendly interface

## Architecture

### 1. Data Layer
- **AddressService** (`lib/features/profile/data/address_service.dart`): Handles all API calls to the backend
- **Address Entity** (`lib/features/profile/domain/entities/address.dart`): Data model for addresses

### 2. Presentation Layer
- **SavedAddressScreen** (`lib/features/profile/presentation/saved_address_screen.dart`): Main screen for managing addresses
- **SavedAddressModal** (`lib/features/home/presentation/modal/saved_address_modal.dart`): Modal for selecting addresses during order creation

### 3. Utilities
- **DummyAddresses** (`lib/features/profile/data/dummy_addresses.dart`): Provides dummy data for testing

## API Endpoints

The system integrates with the following backend endpoints:

### 1. Create Address
- **POST** `/profile/addresses`
- **Request Body:**
```json
{
  "street": "Lagos",
  "city": "Lagos", 
  "state": "Lagos",
  "postal_code": "1234",
  "country": "Nigeria",
  "longtitude": "6.34421",
  "latitude": "6.123456"
}
```

### 2. Update Address
- **PUT** `/profile/addresses/{address_id}`
- **Request Body:**
```json
{
  "street": "GRA",
  "city": "Ikeja",
  "state": "Lagos", 
  "postal_code": "1234",
  "country": "Nigeria"
}
```

### 3. List Addresses
- **GET** `/profile/addresses`
- **Response:**
```json
{
  "status": "success",
  "status_code": 200,
  "data": [
    {
      "address_id": "6decbeac-2496-477b-8e1b-2fde27fbed3b",
      "street": "Lagos",
      "city": "Lagos",
      "state": "Lagos",
      "postal_code": "1234",
      "country": "Nigeria",
      "is_default": "false",
      "created_at": "2025-06-03T00:54:48.071611+00:00",
      "updated_at": "2025-06-03T00:54:48.071631+00:00"
    }
  ]
}
```

### 4. Get Address by ID
- **GET** `/profile/addresses/{address_id}`

### 5. Delete Address
- **DELETE** `/profile/addresses/{address_id}`

## Features

### 1. Saved Addresses Screen
- View all saved addresses
- Add new addresses
- Edit existing addresses
- Delete addresses
- Mark addresses as default
- Refresh address list
- Add dummy addresses for testing

### 2. Address Selection Modal
- Select addresses during order creation
- Separate modals for pickup and delivery addresses
- Navigate to address management if no addresses exist

### 3. Integration with Order Creation
- Seamless integration with the order creation flow
- Automatic address population in order forms
- Support for both sender and receiver addresses

## Usage

### 1. Accessing Saved Addresses
```dart
// Navigate to saved addresses screen
Navigator.pushNamed(context, '/saved-addresses');
```

### 2. Using Address Selection Modal
```dart
// In order creation flow
void openSavedAddressModal({required bool isPickup}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SavedAddressModal(
        isPickup: isPickup,
        onAddressSelected: (Address address) {
          // Handle selected address
          setState(() {
            if (isPickup) {
              pickupAddress = address.toOrderAddress();
            } else {
              dropoffAddress = address.toOrderAddress();
            }
          });
        },
      );
    },
  );
}
```

### 3. Adding Dummy Addresses
```dart
// Add 5 dummy addresses for testing
await DummyAddresses.addDummyAddresses(5);
```

## Dummy Addresses

The system includes 8 pre-defined dummy addresses in Lagos, Nigeria:

1. **12, Unity Road, Ikeja** - Ikeja, Lagos
2. **3B Ogunlana Drive, Off Masha Road, Surulere** - Surulere, Lagos  
3. **15 Olayemi Street, Off Allen Avenue** - Ikeja, Lagos
4. **78B Admiralty Way, Lekki Phase 1** - Lekki, Lagos
5. **25 Victoria Island Crescent, Victoria Island** - Victoria Island, Lagos
6. **7 Ahmadu Bello Way, Victoria Island** - Victoria Island, Lagos
7. **42 Awolowo Road, Ikoyi** - Ikoyi, Lagos
8. **18 Banana Island Road, Banana Island** - Banana Island, Lagos

## Error Handling

The system includes comprehensive error handling:
- Network errors
- API errors
- Validation errors
- User-friendly error messages
- Retry mechanisms

## Testing

Run the test script to verify functionality:
```bash
dart test_address_management.dart
```

## Future Enhancements

1. **Address Validation**: Add client-side validation for address fields
2. **Geocoding**: Integrate with mapping services for address verification
3. **Address Search**: Add search functionality for large address lists
4. **Address Categories**: Support for work, home, and other address types
5. **Bulk Operations**: Support for bulk address import/export
6. **Offline Support**: Cache addresses for offline access

## Dependencies

- `http`: For API calls
- `shared_preferences`: For token storage
- `google_fonts`: For typography
- `flutter_svg`: For SVG icons

## Security

- All API calls include authentication tokens
- Sensitive data is not stored locally
- Input validation on all address fields
- Secure token management 