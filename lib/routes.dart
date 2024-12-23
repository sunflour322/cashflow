import 'package:cashflow/auth_screens/auth_screen.dart';
import 'package:cashflow/auth_screens/landing.dart';
import 'package:cashflow/navigation_screen.dart';

final routes = {
  '/': (context) => LandingScreen(),
  '/auth': (context) => const AuthScreen(),
//   '/reg': (context) => const RegPage(),
//   '/meets': (context) => const MeetPage(),
//   '/acc': (context) => const AccountPage()
};
