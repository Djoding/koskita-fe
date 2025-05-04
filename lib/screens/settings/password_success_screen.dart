import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordSuccessScreen extends StatelessWidget {
  const PasswordSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9EBFE4),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Close button (X) at the top right
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        // Pop back to settings screen
                        Navigator.popUntil(
                            context,
                                (route) => route.isFirst || route.settings.name == '/settings'
                        );
                      },
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // House illustration
              Image.asset(
                'assets/home.png', // Make sure to add this asset to your pubspec.yaml
                width: 200,
                height: 200,
              ),

              const SizedBox(height: 20),

              // Success text
              Text(
                'Password Telah\nBerhasil Diubah',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}