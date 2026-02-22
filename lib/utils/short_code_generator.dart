import 'dart:math';

class ShortCodeGenerator {
  static String generate() {
    const letters = 'ABCDEFGHJKLMNPQRSTUVWXYZ'; // Removed confusing O, I
    const numbers = '23456789'; // Removed 0, 1

    final random = Random();

    String randomString(String source, int length) =>
        List.generate(length, (index) => source[random.nextInt(source.length)]).join();

    return '${randomString(letters, 3)}-${randomString(numbers, 3)}';
  }
}