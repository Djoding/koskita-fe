import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/screens/home_screen.dart';
import 'package:kosan_euy/screens/makanan/makanan_screen.dart';
import 'package:kosan_euy/screens/owner/add_penghuni_screen.dart';
import 'package:kosan_euy/screens/owner/dashboard_owner_screen.dart';
import 'package:kosan_euy/screens/owner/edit_penghuni_screen.dart';
import 'package:kosan_euy/screens/owner/notification/notification_owner.dart';
import 'package:kosan_euy/screens/owner/notification/notification_reservasi.dart';
import 'package:kosan_euy/screens/owner/notification/notification_reservasi_detail.dart';
import 'package:kosan_euy/screens/owner/penghuni_screen.dart';
import 'package:kosan_euy/screens/owner/reservasi/reservasi_screen.dart';
import 'package:kosan_euy/screens/settings//notification_screen.dart';
import 'package:kosan_euy/screens/settings/setting_screen.dart';
import 'package:kosan_euy/widgets/success_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KostKita',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(75, 44, 153, 1.0),
          primary: const Color.fromRGBO(75, 44, 153, 1.0),
          secondary: const Color.fromRGBO(144, 122, 204, 1.0),
        ),
        scaffoldBackgroundColor: const Color.fromRGBO(134, 176, 221, 1.000),
        textTheme: GoogleFonts.poppinsTextTheme(),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Color.fromRGBO(144, 122, 204, 1.0), width: 2),
          ),
          hintStyle: GoogleFonts.poppins(color: Colors.grey),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color.fromRGBO(175, 137, 240, 1),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        )
      ),
      // initialRoute: '/',
      // routes: {
      //   '/': (context) => HomeScreenPage(),
      //   '/'
      // },
      home: Scaffold(
        // body: HomeScreenPage(),
        // body: NotificationReservasiScreen()
        // body: SuccessScreen(title: 'test', subtitle: 'test')
        body: DashboardOwnerScreen()
        // body: SettingScreen(),
        // body: FoodListScreen(),
      ),
    );
  }
}

