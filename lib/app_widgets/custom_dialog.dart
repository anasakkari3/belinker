import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '/app_widgets/RequestDialog.dart';
import '/app_widgets/ServiceDialog.dart';

class CustomDialogWidget {
  static void show(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth * 0.85;

    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.bottomSlide,
      dialogBackgroundColor: Colors.white.withOpacity(0.9), // 👈 خلي الخلفية شفافة شوي
      body: BackdropFilter(
        // 👈 ضبابية
        filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: dialogWidth,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Create new post",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),

                // ✅ زر Request
                ListTile(
                  leading: const Icon(Icons.request_page, color: Color(0xFFFF6600)),
                  title: const Text("Request a service"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    RequestDialog.show(context);
                  },
                ),
                const Divider(),

                // ✅ زر Service
                ListTile(
                  leading: const Icon(Icons.miscellaneous_services, color: Color(0xFF0057D9)),
                  title: const Text("Add a service"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ServiceDialog.show(context);

                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    ).show();
  }
}
