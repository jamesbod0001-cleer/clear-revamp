import 'dart:math';

abstract class PasswordGenerator {
  static String generateSecureTempPassword() {
    const length = 20;
    const letterLowerCase = "abcdefghijklmnopqrstuvwxyz";
    const letterUpperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const number = "0123456789";
    const special = "@#%^&*!_";

    const allChars = "$letterLowerCase$letterUpperCase$number$special";
    final random = Random.secure();

    // Ensure we have at least one of each required type
    List<String> password = [
      letterLowerCase[random.nextInt(letterLowerCase.length)],
      letterUpperCase[random.nextInt(letterUpperCase.length)],
      number[random.nextInt(number.length)],
      special[random.nextInt(special.length)],
    ];

    // Fill the rest of the length with random characters
    password.addAll(
      List.generate(length - 4, (index) {
        return allChars[random.nextInt(allChars.length)];
      }),
    );

    // Shuffle the list so the required characters aren't always at the start
    password.shuffle(random);
    return password.join();
  }
}
