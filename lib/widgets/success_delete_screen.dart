import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SuccessDeleteScreen extends StatelessWidget {
  final String title;
  final String? buttonText;
  final VoidCallback? onBack;

  const SuccessDeleteScreen({
    super.key,
    required this.title,
    this.buttonText,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF91B7DE),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon silang merah besar
              Container(
                width: 180,
                height: 180,
                decoration: const BoxDecoration(
                  color: Color(0xFFA51B1B),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.close, color: Colors.white, size: 100),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFA51B1B),
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 260,
                height: 50,
                child: ElevatedButton(
                  onPressed: onBack ?? () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA51B1B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    buttonText ?? 'Kembali',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
