import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: const Color.fromRGBO(175, 137, 240, 1),
          child: Text(
            "U",
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16), // Spacing
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Kapling40",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "Pengelola Kost Kapling40",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}
