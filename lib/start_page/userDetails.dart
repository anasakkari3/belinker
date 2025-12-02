// lib/screens/user_details.dart

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediator_mvp/app_widgets/MainScreen.dart';

import '../app_widgets/home_page.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({Key? key}) : super(key: key);

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  Uint8List? _profileImageBytes;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _profileImageBytes = bytes;
      });
    }
  }

  Future<void> _saveDetails() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in first.")),
      );
      return;
    }

    setState(() => _isSaving = true);

    String? photoUrl;

    try {
      // 1) رفع صورة البروفايل لو موجودة
      if (_profileImageBytes != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_profile_images/${user.uid}.jpg');

        final uploadTask = await storageRef.putData(_profileImageBytes!);
        photoUrl = await uploadTask.ref.getDownloadURL();
      }

      // 2) حفظ البيانات في كولكشن users
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fullName': _nameController.text.trim(),
        'city': _cityController.text.trim(),
        'country': _countryController.text.trim(),
        'address': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
        'photoUrl': photoUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 3) الذهاب للـ HomePage
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving details: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // نفس فكرة _buildLabel الموجودة في RegisterScreen
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.readexPro(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: 600,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 60,
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(2, 2),
                      spreadRadius: 20,
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // 🔹 Logo
                      Image.asset("assets/logo.png"),
                      const SizedBox(height: 16),

                      // 🔹 Title
                      Text(
                        'Complete your profile',
                        style: GoogleFonts.readexPro(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'Just a few more details to get started.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.readexPro(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 🔹 Profile Image
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: media.width * 0.18,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _profileImageBytes != null
                              ? MemoryImage(_profileImageBytes!)
                              : null,
                          child: _profileImageBytes == null
                              ? Icon(
                            Icons.camera_alt,
                            size: media.width * 0.15,
                            color: Colors.grey.shade700,
                          )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 🔹 Full name
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _buildLabel("Full name"),
                      ),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: "Enter your full name...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                        ),
                        validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? "Please enter your name"
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // 🔹 City
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _buildLabel("City"),
                      ),
                      TextFormField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          hintText: "City...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 🔹 Country
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _buildLabel("Country"),
                      ),
                      TextFormField(
                        controller: _countryController,
                        decoration: InputDecoration(
                          hintText: "Country...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 🔹 Address
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _buildLabel("Address"),
                      ),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          hintText: "Street, building, etc...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 🔹 Phone
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _buildLabel("Phone"),
                      ),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: "Phone number...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 🔹 Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveDetails,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0057D9),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Text("Save & Continue"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>   MaterialPageRoute(builder: (context) => const MainScreen()),
        ),
      ),
    );
  }
}
