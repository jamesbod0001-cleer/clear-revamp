class IdentityUtils {
  IdentityUtils._();

  /// Compares a user's profile name against a resolved bank account name.
  /// Uses fuzzy token matching to account for different name orders and extra middle names.
  static bool isNameMatch({
    required String userName,
    required String bankAccountName,
  }) {
    if (userName.trim().isEmpty || bankAccountName.trim().isEmpty) {
      return false;
    }

    // Helper function to normalize and tokenize names
    Set<String> tokenize(String name) {
      return name
          .toLowerCase()
          // Replace hyphens and common separators with spaces
          .replaceAll(RegExp(r'[-_]'), ' ')
          // Remove all other non-alphanumeric characters
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .split(RegExp(r'\s+'))
          // Ignore 1 or 2 letter initials (e.g., "A", "O")
          // because banks often abbreviate middle names which ruins strict matching
          .where((t) => t.length > 2)
          .toSet();
    }

    final userTokens = tokenize(userName);
    final bankTokens = tokenize(bankAccountName);

    // If the user's name didn't result in any valid tokens, fail safely
    if (userTokens.isEmpty || bankTokens.isEmpty) {
      return false;
    }

    // Ensure EVERY significant word in the Cleer user's name
    // exists somewhere in the bank account name.
    return userTokens.every((token) => bankTokens.contains(token));
  }
}
