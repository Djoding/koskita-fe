import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:kosan_euy/services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String _fullName = 'Memuat...';
  String _userRole = 'Memuat...';
  String? _avatarUrl;
  File? _selectedAvatarFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userData = await _authService.getStoredUserData();
      if (userData != null) {
        setState(() {
          _fullName = userData['full_name'] ?? 'Nama Lengkap';
          _userRole = userData['role'] ?? 'Peran Pengguna';
          String? rawAvatarPath = userData['avatar_url'] ?? userData['avatar'];

          if (rawAvatarPath != null && rawAvatarPath.isNotEmpty) {
            _avatarUrl =
                rawAvatarPath.startsWith('http://') ||
                        rawAvatarPath.startsWith('https://')
                    ? rawAvatarPath
                    : 'http://localhost:3000$rawAvatarPath';
          } else {
            _avatarUrl = null;
          }

          _selectedAvatarFile = null;

          if (_userRole == 'ADMIN' || _userRole == 'PENGELOLA') {
            _userRole = 'Pengelola Kost';
          } else if (_userRole == 'PENGHUNI') {
            _userRole = 'Penghuni Kost';
          }

          _nameController.text = _fullName;
          _emailController.text = userData['email'] ?? '';
          _phoneController.text = userData['whatsapp_number'] ?? '';
        });
      }
    } catch (e) {
      setState(() {
        _fullName = 'Error';
        _userRole = 'Error';
        _avatarUrl = null;
        _selectedAvatarFile = null;
        _nameController.text = 'Error';
        _emailController.text = 'Error';
        _phoneController.text = 'Error';
      });
      _showSnackBar('Gagal memuat data pengguna: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedAvatarFile = File(pickedFile.path);
        _avatarUrl = null;
      });
    }
  }

  void _clearAvatar() {
    setState(() {
      _selectedAvatarFile = null;
      _avatarUrl = null;
    });
  }

  Future<void> _handleUpdateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.updateProfile(
        fullName: _nameController.text.isNotEmpty ? _nameController.text : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        whatsappNumber:
            _phoneController.text.isNotEmpty ? _phoneController.text : null,
        avatarFile: _selectedAvatarFile,
        clearAvatar: _selectedAvatarFile == null && _avatarUrl != null,
      );

      await _loadUserData();

      _showSnackBar('Profil berhasil diperbarui!');
    } catch (e) {
      _showSnackBar('Gagal memperbarui profil: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
        showCloseIcon: true,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Show loading indicator
              : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF3C4D82), Color(0xFF6A82FB)],
                  ),
                ),
                child: SafeArea(
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 10.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                              Text(
                                'Edit Profil',
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 100,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(241, 255, 243, 1.0),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 30.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildProfileInfo(),
                                const SizedBox(height: 30),
                                _buildInputField(
                                  controller: _nameController,
                                  label: 'Nama Lengkap',
                                  keyboardType: TextInputType.text,
                                ),
                                const SizedBox(height: 20),
                                _buildInputField(
                                  controller: _phoneController,
                                  label: 'Nomor Telepon (WhatsApp)',
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 20),
                                _buildInputField(
                                  controller: _emailController,
                                  label: 'Email',
                                  keyboardType: TextInputType.emailAddress,
                                  readOnly: true,
                                ),
                                const SizedBox(height: 30),
                                Center(
                                  child: ElevatedButton(
                                    onPressed:
                                        _handleUpdateProfile, // Call the update function
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4A99BD),
                                      minimumSize: const Size(200, 50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: Text(
                                      'Perbarui Profil',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                if (_avatarUrl != null ||
                                    _selectedAvatarFile !=
                                        null) // Show clear button only if avatar exists
                                  Center(
                                    child: TextButton(
                                      onPressed: _clearAvatar,
                                      child: Text(
                                        'Hapus Avatar',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 30),
                              ],
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

  Widget _buildProfileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    _selectedAvatarFile != null
                        ? FileImage(_selectedAvatarFile!)
                            as ImageProvider<Object>?
                        : (_avatarUrl != null &&
                            _avatarUrl!.isNotEmpty &&
                            (_avatarUrl!.startsWith('http://') ||
                                _avatarUrl!.startsWith('https://')))
                        ? NetworkImage(_avatarUrl!) as ImageProvider<Object>?
                        : null,
                child:
                    (_selectedAvatarFile == null &&
                            (_avatarUrl == null ||
                                _avatarUrl!.isEmpty ||
                                !(_avatarUrl!.startsWith('http://') ||
                                    _avatarUrl!.startsWith('https://'))))
                        ? Icon(
                          Icons.person,
                          size: 70,
                          color: Colors.grey[600],
                        ) // Default icon
                        : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: () {
                    // Show options to pick from gallery or camera
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext bc) {
                        return SafeArea(
                          child: Wrap(
                            children: <Widget>[
                              ListTile(
                                leading: const Icon(Icons.photo_library),
                                title: const Text('Galeri'),
                                onTap: () {
                                  _pickImage(ImageSource.gallery);
                                  Navigator.of(context).pop();
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo_camera),
                                title: const Text('Kamera'),
                                onTap: () {
                                  _pickImage(ImageSource.camera);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _fullName,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        Text(
          _userRole,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          style: GoogleFonts.poppins(
            color: readOnly ? Colors.grey[700] : Colors.black87,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF4A99BD),
                width: 2.0,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
