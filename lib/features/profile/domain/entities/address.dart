class Address {
  final String addressId;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String? longitude;
  final String? latitude;
  final bool isDefault;
  final String createdAt;
  final String updatedAt;

  Address({
    required this.addressId,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.longitude,
    this.latitude,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressId: json['address_id'] ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postal_code'] ?? '',
      country: json['country'] ?? '',
      longitude: json['longtitude'] ?? json['longitude'],
      latitude: json['latitude'],
      isDefault: json['is_default'] == 'true' || json['is_default'] == true,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address_id': addressId,
      'street': street,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'longtitude': longitude,
      'latitude': latitude,
      'is_default': isDefault,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Helper method to get full address string
  String get fullAddress {
    return '$street, $city, $state, $postalCode, $country';
  }

  // Helper method to get short address string
  String get shortAddress {
    return '$city $country';
  }

  // Helper method to get address for order creation
  Map<String, String> toOrderAddress() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      if (longitude != null) 'longitude': longitude!,
      if (latitude != null) 'latitude': latitude!,
    };
  }

  Address copyWith({
    String? addressId,
    String? street,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? longitude,
    String? latitude,
    bool? isDefault,
    String? createdAt,
    String? updatedAt,
  }) {
    return Address(
      addressId: addressId ?? this.addressId,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 