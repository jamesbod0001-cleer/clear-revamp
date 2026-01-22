part of '../theme.dart';

abstract class _Palette {
  // Base Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // Brand Colors (Functional)
  static const Color background = Color(0xFFFAFAFA); // functional bg color
  static const Color primary = Color(0xFF60E491);    // functional Light Green
  static const Color primaryBlue = Color(0xFF62AFFF); // functional Light Blue
  static const Color secondary = Color(0xFF030551);  // functional Deep Blue
  static const Color outline = Color(0xFFE2E3E4);    // functional outline 100
  static const Color grayComponent = Color(0xFFF2F3F2); // functional gray component
  static const Color navbarBg = Color(0xFFF2F2F2);   // functional Navbar Background

  // Semantic Colors (State & Feedback)
  static const Color error = Color(0xFF9F1B1D);       // semantic red 1000
  static const Color errorLight = Color(0xFFF7E1E7);  // semantic red 100
  static const Color success = Color(0xFF005833);     // semantic green 1000
  static const Color successLight = Color(0xFFEEFDF3);// semantic green 100
  static const Color warning = Color(0xFF563105);     // semantic orange 1000
  static const Color warningLight = Color(0xFFEBDBC7);// semantic orange 100
  static const Color info = Color(0xFF0144CD);        // semantic blue 1000
  static const Color infoLight = Color(0xFFEBF1FC);   // semantic blue 100

  // Green Color Ramp (light green)
  static const Color green000 = Color(0xFFEEFDF3);
  static const Color green050 = Color(0xFFEFFCF4);
  static const Color green100 = Color(0xFFDFFAE9);
  static const Color green150 = Color(0xFFCFF7DE);
  static const Color green200 = Color(0xFFBFF5D3);
  static const Color green300 = Color(0xFFA0EFBE);
  static const Color green400 = Color(0xFF80EAA8);
  static const Color green500 = Color(0xFF60E592);
  static const Color green600 = Color(0xFF4EBC77);
  static const Color green700 = Color(0xFF3B935C);
  static const Color green800 = Color(0xFF296B42);
  static const Color green850 = Color(0xFF205634);
  static const Color green900 = Color(0xFF164227);
  static const Color green950 = Color(0xFF0D2D19);
  static const Color green1000 = Color(0xFF04190C);

  // Blue Color Ramp (deep blue)
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

  // Grey Color Ramp (grey)
  static const Color grey100 = Color(0xFFE5E6E5);
  static const Color grey200 = Color(0xFFCCCDCC);
  static const Color grey300 = Color(0xFFB3B5B3);
  static const Color grey400 = Color(0xFF9B9E9B);
  static const Color grey500 = Color(0xFF848784);
  static const Color grey600 = Color(0xFF6D716D);
  static const Color grey700 = Color(0xFF575C57);
  static const Color grey800 = Color(0xFF424742);
  static const Color grey900 = Color(0xFF2E342E);
  static const Color grey1000 = Color(0xFF1C211C);
}