class AddressNormalizer {
  // Nigerian states mapping
  static const Map<String, String> stateMapping = {
    'lagos': 'Lagos',
    'abuja': 'FCT',
    'abia': 'Abia',
    'adamawa': 'Adamawa',
    'akwa ibom': 'Akwa Ibom',
    'anambra': 'Anambra',
    'bauchi': 'Bauchi',
    'bayelsa': 'Bayelsa',
    'benue': 'Benue',
    'borno': 'Borno',
    'cross river': 'Cross River',
    'delta': 'Delta',
    'ebonyi': 'Ebonyi',
    'edo': 'Edo',
    'ekiti': 'Ekiti',
    'enugu': 'Enugu',
    'gombe': 'Gombe',
    'imo': 'Imo',
    'jigawa': 'Jigawa',
    'kaduna': 'Kaduna',
    'kano': 'Kano',
    'katsina': 'Katsina',
    'kebbi': 'Kebbi',
    'kogi': 'Kogi',
    'kwara': 'Kwara',
    'nasarawa': 'Nasarawa',
    'niger': 'Niger',
    'ogun': 'Ogun',
    'ondo': 'Ondo',
    'osun': 'Osun',
    'oyo': 'Oyo',
    'plateau': 'Plateau',
    'rivers': 'Rivers',
    'sokoto': 'Sokoto',
    'taraba': 'Taraba',
    'yobe': 'Yobe',
    'zamfara': 'Zamfara',
  };

  // Common Nigerian cities mapping
  static const Map<String, String> cityMapping = {
    'lagos': 'Lagos',
    'ikeja': 'Ikeja',
    'victoria island': 'Victoria Island',
    'lekki': 'Lekki',
    'ajah': 'Ajah',
    'surulere': 'Surulere',
    'yaba': 'Yaba',
    'oshodi': 'Oshodi',
    'alimosho': 'Alimosho',
    'agege': 'Agege',
    'ifako': 'Ifako',
    'abuja': 'Abuja',
    'gwagwalada': 'Gwagwalada',
    'kubwa': 'Kubwa',
    'karu': 'Karu',
    'nyanya': 'Nyanya',
    'port harcourt': 'Port Harcourt',
    'calabar': 'Calabar',
    'uyo': 'Uyo',
    'benin city': 'Benin City',
    'warri': 'Warri',
    'asaba': 'Asaba',
    'enugu': 'Enugu',
    'awka': 'Awka',
    'onitsha': 'Onitsha',
    'aba': 'Aba',
    'owerri': 'Owerri',
    'kaduna': 'Kaduna',
    'kano': 'Kano',
    'maiduguri': 'Maiduguri',
    'jalingo': 'Jalingo',
    'gombe': 'Gombe',
    'bauchi': 'Bauchi',
    'jos': 'Jos',
    'makurdi': 'Makurdi',
    'lafia': 'Lafia',
    'minna': 'Minna',
    'sokoto': 'Sokoto',
    'katsina': 'Katsina',
    'dutse': 'Dutse',
    'damaturu': 'Damaturu',
    'yola': 'Yola',
    'birnin kebbi': 'Birnin Kebbi',
    'lokoja': 'Lokoja',
    'ilorin': 'Ilorin',
    'osogbo': 'Osogbo',
    'akure': 'Akure',
    'ado ekiti': 'Ado Ekiti',
    'abeokuta': 'Abeokuta',
    'ibadan': 'Ibadan',
    'oyo': 'Oyo',
  };

  // Normalize state name
  static String normalizeState(String state) {
    final normalized = state.toLowerCase().trim();
    return stateMapping[normalized] ?? 'Lagos'; // Default to Lagos if not found
  }

  // Normalize city name
  static String normalizeCity(String city) {
    final normalized = city.toLowerCase().trim();
    return cityMapping[normalized] ?? city; // Return original if not found
  }

  // Parse and normalize address
  static Map<String, String> parseAndNormalizeAddress(String inputAddress) {
    final addressText = inputAddress.trim();
    
    if (addressText.isEmpty) {
      return {
        'street': 'Current Location',
        'city': 'Lagos',
        'state': 'Lagos',
      };
    }

    final parts = addressText.split(',').map((part) => part.trim()).toList();
    
    String street, city, state;
    
    if (parts.length >= 3) {
      // Full address provided: street, city, state
      street = parts[0];
      city = normalizeCity(parts[1]);
      state = normalizeState(parts[2]);
    } else if (parts.length == 2) {
      // Street and city provided
      street = parts[0];
      city = normalizeCity(parts[1]);
      state = 'Lagos'; // Default to Lagos
    } else {
      // Only street provided
      street = parts[0];
      city = 'Lagos'; // Default to Lagos
      state = 'Lagos'; // Default to Lagos
    }

    return {
      'street': street,
      'city': city,
      'state': state,
    };
  }

  // Validate address data
  static List<String> validateAddress({
    required String street,
    required String city,
    required String state,
    required String postalCode,
    required String country,
    required String longitude,
    required String latitude,
  }) {
    final errors = <String>[];
    
    if (street.trim().isEmpty) errors.add('Street is required');
    if (city.trim().isEmpty) errors.add('City is required');
    if (state.trim().isEmpty) errors.add('State is required');
    if (postalCode.trim().isEmpty) errors.add('Postal code is required');
    if (country.trim().isEmpty) errors.add('Country is required');
    if (longitude.trim().isEmpty) errors.add('Longitude is required');
    if (latitude.trim().isEmpty) errors.add('Latitude is required');
    
    // Validate coordinates
    try {
      final lon = double.parse(longitude);
      final lat = double.parse(latitude);
      
      if (lon < -180 || lon > 180) errors.add('Invalid longitude value');
      if (lat < -90 || lat > 90) errors.add('Invalid latitude value');
    } catch (e) {
      errors.add('Invalid coordinate format');
    }
    
    return errors;
  }

  // Format address for display
  static String formatAddressForDisplay({
    required String street,
    required String city,
    required String state,
    String? postalCode,
    String? country,
  }) {
    final parts = <String>[street, city, state];
    if (postalCode != null && postalCode.isNotEmpty) parts.add(postalCode);
    if (country != null && country.isNotEmpty) parts.add(country);
    
    return parts.join(', ');
  }

  // Get standardized address for API
  static Map<String, dynamic> getStandardizedAddress({
    required String street,
    required String city,
    required String state,
    required String postalCode,
    required String country,
    required String longitude,
    required String latitude,
  }) {
    return {
      'street': street.trim(),
      'city': normalizeCity(city),
      'state': normalizeState(state),
      'postal_code': postalCode.trim(),
      'country': country.trim(),
      'longtitude': longitude.trim(),
      'latitude': latitude.trim(),
    };
  }
} 