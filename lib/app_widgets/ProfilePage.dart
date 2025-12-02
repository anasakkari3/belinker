// lib/app_widgets/ProfilePage.dart

import 'package:flutter/material.dart';
import 'package:mediator_mvp/start_page/auth.dart';
import 'package:mediator_mvp/start_page/log_in.dart';
import 'Header.dart'; // <-- 1. IMPORT YOUR CUSTOM HEADER

// Using the same color theme
const Color primaryBlue = Color(0xFF0D47A1);
const Color accentOrange = Color(0xFFF57C00);

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Helper widget for statistics
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryBlue),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // In a real app, you would get this data from Firebase Auth and Firestore
    final String userName = "Dana Cohen";
    final String userHandle = "@danacodes";
    final String memberSince = "October 2025";
    final String avatarUrl = "https://randomuser.me/api/portraits/women/68.jpg";

    return Scaffold(
      // --- 2. REPLACE THE APPBAR WITH YOUR CUSTOM HEADER ---
      appBar: const CustomAppBar(),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              // Profile picture
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              const SizedBox(height: 16),
              // User Name and Handle
              Text(
                userName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                userHandle,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 24),

              // Stats Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem("Deals Done", "12"),
                      _buildStatItem("Rating", "4.8 ★"),
                      _buildStatItem("Requests", "5"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: primaryBlue),
                title: const Text('Edit Profile'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to an Edit Profile screen
                  print("Edit Profile tapped");
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined, color: primaryBlue),
                title: const Text('Settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to a Settings screen
                  print("Settings tapped");
                },
              ),
              const Divider(),

              // Logout Button
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    await auth().signOut();
                    // Navigate to Login and remove all previous routes
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (Route<dynamic> route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}