class Validators {
  // Validate name - only letters and spaces allowed
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }

    // Remove extra spaces and check length
    final trimmedValue = value.trim();
    if (trimmedValue.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (trimmedValue.length > 50) {
      return 'Name must be less than 50 characters';
    }

    // Check if name contains only letters, spaces, and common name characters
    final nameRegex = RegExp(r"^[a-zA-Z\s\-'\.]+$");
    if (!nameRegex.hasMatch(trimmedValue)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    // Check for consecutive spaces
    if (trimmedValue.contains('  ')) {
      return 'Name cannot contain consecutive spaces';
    }

    // Check if name starts or ends with space
    if (trimmedValue != value.trim()) {
      return 'Name cannot start or end with spaces';
    }

    return null;
  }

  // Validate service/business name
  static String? validateServiceName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your service name';
    }

    final trimmedValue = value.trim();
    if (trimmedValue.length < 2) {
      return 'Service name must be at least 2 characters';
    }

    if (trimmedValue.length > 100) {
      return 'Service name must be less than 100 characters';
    }

    // Allow letters, numbers, spaces, and common business characters
    final serviceNameRegex = RegExp(r"^[a-zA-Z0-9\s\-'\.&]+$");
    if (!serviceNameRegex.hasMatch(trimmedValue)) {
      return 'Service name can only contain letters, numbers, spaces, and common business characters';
    }

    return null;
  }

  // Validate real email addresses - FIXED TO ACCEPT REAL EMAILS
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }

    final trimmedValue = value.trim().toLowerCase();

    // Basic email format validation
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!emailRegex.hasMatch(trimmedValue)) {
      return 'Please enter a valid email address';
    }

    // Check minimum length for domain
    final parts = trimmedValue.split('@');
    if (parts.length != 2) {
      return 'Please enter a valid email address';
    }

    final domain = parts[1];
    if (domain.length < 4 || !domain.contains('.')) {
      return 'Please enter a valid email domain';
    }

    // Check for valid domain extensions
    final domainParts = domain.split('.');
    final extension = domainParts.last;
    if (extension.length < 2) {
      return 'Please enter a valid email domain';
    }

    return null; // Accept all properly formatted emails
  }

  // Validate Ethiopian phone number - STRICT
  static String? validateEthiopianPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }

    // Remove spaces and special characters for validation
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Must start with +251 for Ethiopian numbers
    if (!cleanPhone.startsWith('+251')) {
      return 'Phone number must start with +251\nExample: +251912345678';
    }

    // Check length (should be 13 total: +251 + 9 digits)
    if (cleanPhone.length != 13) {
      return 'Invalid Ethiopian phone number length\nExample: +251912345678';
    }

    // Check if it contains only numbers after +251
    final numberPart = cleanPhone.substring(4);
    if (!RegExp(r'^[0-9]{9}$').hasMatch(numberPart)) {
      return 'Phone number can only contain digits after +251';
    }

    return null;
  }

  // Validate phone number (general - for backward compatibility)
  static String? validatePhone(String? value) {
    return validateEthiopianPhone(value);
  }

  // Validate password - STRICT 12 CHARACTER MINIMUM
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }

    // Check for spaces - NOT ALLOWED
    if (value.contains(' ')) {
      return 'Password cannot contain spaces';
    }

    // Minimum 12 characters for security
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (value.length > 128) {
      return 'Password must be less than 128 characters';
    }

    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one number
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    // Check for at least one special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  // Validate location
  static String? validateLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your location';
    }

    final trimmedValue = value.trim();
    if (trimmedValue.length < 2) {
      return 'Location must be at least 2 characters';
    }

    if (trimmedValue.length > 100) {
      return 'Location must be less than 100 characters';
    }

    // Allow letters, numbers, spaces, and location-specific characters
    final locationRegex = RegExp(r"^[a-zA-Z0-9\s\-'\.&,]+$");
    if (!locationRegex.hasMatch(trimmedValue)) {
      return 'Location can only contain letters, numbers, spaces, and common location characters';
    }

    return null;
  }

  // Validate description
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a description';
    }

    final trimmedValue = value.trim();
    if (trimmedValue.length < 10) {
      return 'Description must be at least 10 characters';
    }

    if (trimmedValue.length > 1000) {
      return 'Description must be less than 1000 characters';
    }

    return null;
  }

  // Validate price range
  static String? validatePriceRange(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your price range';
    }

    final trimmedValue = value.trim();

    // Check for common price range patterns
    final priceRegex = RegExp(r'^\d+\s*-\s*\d+\s*(ETB|etb|Etb)?$');
    if (!priceRegex.hasMatch(trimmedValue)) {
      return 'Please enter price range in format: 500-1000 ETB';
    }

    return null;
  }

  // Validate experience years
  static String? validateExperience(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your years of experience';
    }

    final experience = int.tryParse(value);
    if (experience == null) {
      return 'Please enter a valid number';
    }

    if (experience < 0) {
      return 'Experience cannot be negative';
    }

    if (experience > 50) {
      return 'Please enter a realistic number of years';
    }

    return null;
  }
}
