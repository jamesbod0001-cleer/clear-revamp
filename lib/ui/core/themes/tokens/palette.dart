part of '../theme.dart';

abstract class _Palette {
  // Base Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // Brand Colors (Functional)
  static const Color background = Color(0xFFFAFAFA);
  static const Color primary = Color(0xFF62E393); // Cleer Green
  static const Color secondary = Color(0xFF030551); // Deep Cleer Blue
  static const Color outline = Color(0xFFE2E3E4);
  static const Color grayComponent = Color(0xFFF2F3F2);
  static const Color navbarGreen = Color(0xFFC7E7D3);

  // Semantic Colors (State & Feedback)
  static const Color error = Color(0xFF9F1B1D);
  static const Color errorLight = Color(0xFFF7E1E7);
  static const Color success = Color(0xFF005833);
  static const Color successLight = Color(0xFFEEFDF3);
  static const Color warning = Color(0xFF563105);
  static const Color warningLight = Color(0xFFEBDBC7);
  static const Color info = Color(0xFF0144CD);
  static const Color infoLight = Color(0xFFEBF1FC);

  // Green Color Ramp
  static const Color green100 = Color(0xFFEEFDF3);
  static const Color green200 = Color(0xFFDEFCE8);
  static const Color green300 = Color(0xFFCFF9DD);
  static const Color green400 = Color(0xFFBBF7D2);
  static const Color green500 = Color(0xFFA8F5C5);
  static const Color green600 = Color(0xFF94F1BB);
  static const Color green700 = Color(0xFF7FEFB0);
  static const Color green800 = Color(0xFF62ECA3);
  static const Color green900 = Color(0xFF3AEA97);
  static const Color green1000 = Color(0xFF62E393);
  static const Color green1100 = Color(0xFF00C978);
  static const Color green1200 = Color(0xFF00AB66);
  static const Color green1300 = Color(0xFF008E55);
  static const Color green1400 = Color(0xFF007443);
  static const Color green1600 = Color(0xFF004022);
  static const Color green1700 = Color(0xFF002814);
  static const Color green1800 = Color(0xFF001107);
  static const Color green1900 = Color(0xFF010301);

  // Blue Color Ramp
  static const Color blue100 = Color(0xFFE0E5EE);
  static const Color blue200 = Color(0xFFC2CBDE);
  static const Color blue300 = Color(0xFFA3B1CC);
  static const Color blue400 = Color(0xFF8799BB);
  static const Color blue500 = Color(0xFF6A82A9);
  static const Color blue600 = Color(0xFF4E6A98);
  static const Color blue700 = Color(0xFF365287);
  static const Color blue800 = Color(0xFF1D3B75);
  static const Color blue900 = Color(0xFF052464);
  static const Color blue1000 = Color(0xFF030551);
  static const Color blue1100 = Color(0xFF020445);
  static const Color blue1200 = Color(0xFF01033B);
  static const Color blue1300 = Color(0xFF01022E);
  static const Color blue1400 = Color(0xFF000010);

  // Grey Color Ramp
  static const Color grey100 = Color(0xFFE5E6E5);
  static const Color grey200 = Color(0xFFCCCDCC);
  static const Color grey300 = Color(0xFFB3B5B3);
  static const Color grey400 = Color(0xFF9B9E9B);
  static const Color grey500 = Color(0xFF848784);
  static const Color grey600 = Color(
    0xFF6D716D,
  ); // Matches functional - text600
  static const Color grey700 = Color(0xFF575C57);
  static const Color grey800 = Color(
    0xFF424742,
  ); // Matches functional - text800
  static const Color grey900 = Color(0xFF2E342E);
  static const Color grey1000 = Color(
    0xFF1C211C,
  ); // Matches functional - text1000
}