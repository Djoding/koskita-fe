import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/penghuni/auth/penghuni_login_screen.dart';

class PenghuniForgetpasswordScreen extends StatefulWidget {
  const PenghuniForgetpasswordScreen({super.key});

  @override
  State<PenghuniForgetpasswordScreen> createState() =>
      _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<PenghuniForgetpasswordScreen> {
  final TextEditingController _forgetPasswordController =
      TextEditingController();

  void _submitEmail() {
    // Tampilkan dialog sukses
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Berhasil'),
            content: const Text('Password berhasil dirubah'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Routing ke LoginScreen pakai GetX
                  Get.offAll(() => const PenghuniLoginScreen());
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Image Assets
                Image.asset('assets/home.png', width: 150),
                SizedBox(height: 8),

                //Lupa password text
                Text(
                  'Lupa Password',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),

                TextField(
                  controller: _forgetPasswordController,
                  keyboardType: TextInputType.emailAddress,
                  obscureText: true,
                  style: GoogleFonts.poppins(color: Colors.black87),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'johndoe@gmail.com',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey),
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                    suffixIcon:
                        _forgetPasswordController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed:
                                  () => setState(
                                    () => _forgetPasswordController.clear(),
                                  ),
                            )
                            : null,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
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
                      borderSide: const BorderSide(
                        color: Color.fromRGBO(144, 122, 204, 1.0),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                //Button kirim
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitEmail,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromRGBO(175, 137, 240, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'Kirim',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Back to login link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      _forgetPasswordController.clear();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PenghuniLoginScreen(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.arrow_back_ios_new,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'kembali ke login',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
