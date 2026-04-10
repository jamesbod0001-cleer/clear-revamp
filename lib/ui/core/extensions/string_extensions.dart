extension StringExtensions on String {
  String get maskEmail {
    // Split into 'username' and 'domain'
    final parts = split('@');
    if (parts.length != 2) {
      return this; // Return original if not a valid email format
    }

    String username = parts[0];
    String domain = parts[1];

    // Logic: 3 chars + *** + last 2 chars
    // We check length to prevent errors on very short emails (e.g., 'ab@gmail.com')
    if (username.length >= 5) {
      String firstThree = username.substring(0, 3);
      String lastTwo = username.substring(username.length - 2);
      return "$firstThree***$lastTwo@$domain";
    } else {
      // Fallback for short usernames: just mask the middle or show what's available
      return "${username[0]}***${username[username.length - 1]}@$domain";
    }
  }

  String get maskPhoneNumber {
    // Remove any non-digit characters except '+' just in case
    String cleanPhone = replaceAll(RegExp(r'[^\d+]'), '');

    // Ensure the phone number is long enough to mask
    if (cleanPhone.length < 12) return cleanPhone;

    // Slicing the string based on your specific requirements:
    // +234 (Country Code)
    // 903 (First 3 digits of number)
    // *** (Mask)
    // 685 (Last 3 digits)

    String countryCode = cleanPhone.substring(0, 4); // +234
    String prefix = cleanPhone.substring(4, 7);      // 903
    String suffix = cleanPhone.substring(cleanPhone.length - 3); // 685

    return '$countryCode $prefix *** $suffix';
  }

  String? get extractUssd {
    // Pattern matches * followed by digits and optional *segments, ending in #
    final RegExp ussdRegex = RegExp(r'\*[\d\*]+#');

    final match = ussdRegex.firstMatch(this);
    return match?.group(0);
  }

  String get maskAccountNumber {
    String cleanAccount = replaceAll(RegExp(r'[^\d]'), '');

    if (cleanAccount.length < 6) return cleanAccount;

    String prefix = cleanAccount.substring(0, 2);
    String suffix = cleanAccount.substring(cleanAccount.length - 4);
    String mask = '*' * (cleanAccount.length - 6);

    return '$prefix$mask$suffix';
  }
}
