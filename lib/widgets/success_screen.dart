import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SuccessScreen extends StatefulWidget {
  final String title;
  final String subtitle;

  const SuccessScreen({super.key, required this.title, this.subtitle = ''});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // House illustration
                    Image.asset('assets/yes.png', width: 200, height: 200),

                    const SizedBox(height: 20),

                    // Success text
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),

                    if (widget.subtitle.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          widget.subtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withAlpha((0.85 * 255).toInt()),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 16.0,
              right: 16.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.1 * 255).toInt()),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    // Pop back to settings screen
                    Navigator.popUntil(
                      context,
                      (route) =>
                          route.isFirst || route.settings.name == '/settings',
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
