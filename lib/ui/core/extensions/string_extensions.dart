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

  String? get extractUssd {
    // Pattern matches * followed by digits and optional *segments, ending in #
    final RegExp ussdRegex = RegExp(r'\*[\d\*]+#');

    final match = ussdRegex.firstMatch(this);
    return match?.group(0);
  }
}
