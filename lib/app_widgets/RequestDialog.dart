import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../utils/service_types.dart';
import 'dart:typed_data';

class RequestDialog {
  static void show(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogWidth = screenWidth * 0.9;

    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.bottomSlide,
      body: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogWidth),
        child: SizedBox(
          height: screenHeight * 0.8,
          child: const _RequestDialogContent(),
        ),
      ),
    ).show();
  }
}

class _RequestDialogContent extends StatefulWidget {
  const _RequestDialogContent({Key? key}) : super(key: key);

  @override
  State<_RequestDialogContent> createState() => _RequestDialogContentState();
}

class _RequestDialogContentState extends State<_RequestDialogContent> {
  String? selectedService;
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final locationController = TextEditingController();
  final timeController = TextEditingController();

  Uint8List? _selectedImageBytes;
  LatLng? pickedLocation;
  geo.Placemark? selectedPlace;

  @override
  void dispose() {
    descriptionController.dispose();
    priceController.dispose();
    locationController.dispose();
    timeController.dispose();
    super.dispose();
  }
// The corrected _uploadRequest method
  Future<void> _uploadRequest() async {
    try {
      // ✅ Check if the user is logged in
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          title: 'Not logged in',
          desc: 'Please log in before creating a request.',
        ).show();
        return;
      }

      String imageUrl = "";
      if (_selectedImageBytes != null) {
        try {
          debugPrint("🖼 Bytes length: ${_selectedImageBytes!.lengthInBytes}");

          final storageRef = FirebaseStorage.instance
              .ref()
              .child("requests/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg");

          final taskSnapshot = await storageRef.putData(_selectedImageBytes!);
          imageUrl = await taskSnapshot.ref.getDownloadURL();

          debugPrint("✅ Image uploaded, URL = $imageUrl");
        } catch (e) {
          debugPrint("❌ Error uploading image: $e");
          // اختياري: وقف العملية لو رفع الصورة فشل
          // return;
        }
      } else {
        debugPrint("⚠️ No image bytes selected at submit time!");
      }


      // ✅ Make sure a location is selected
      if (selectedPlace == null || pickedLocation == null) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          title: 'Missing location',
          desc: 'Please choose a location from the map first.',
        ).show();
        return;
      }

      // Prepare data for Firestore
      final data = {
        "userId": user.uid,
        "serviceType": selectedRequestType ?? "",
        "description": descriptionController.text.trim(),
        "price": double.tryParse(priceController.text) ?? 0,
        "date": timeController.text,
        "location": {
          "geo": GeoPoint(pickedLocation!.latitude, pickedLocation!.longitude),
          "address": {
            "street": selectedPlace?.street ?? "",
            "city": selectedPlace?.locality ?? "",
            "state": selectedPlace?.administrativeArea ?? "",
            "country": selectedPlace?.country ?? "",
            "postalCode": selectedPlace?.postalCode ?? "",
          }
        },
        "imageUrl": imageUrl,
        "createdAt": FieldValue.serverTimestamp(),
      };

      // Add the request to Firestore
      await FirebaseFirestore.instance.collection("requests").add(data);

      // ✅ Success
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Request submitted successfully ✅")),
        );
      }

    } catch (e) {
      debugPrint("❌ Unexpected error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }
  String? selectedRequestType;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Create Request",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),

          // ✅ نوع الخدمة
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'select service type',
              border: OutlineInputBorder(),
            ),
            value: selectedRequestType,
            items: kRequestServiceTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedRequestType = value;
              });
            },
            validator: (value) =>
            value == null ? 'select service type' : null,
          ),
          SizedBox(height: screenHeight * 0.02),

          // ✅ الوصف
          TextField(
            controller: descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: "Description",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),

          // ✅ السعر
          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Price",
              prefixIcon: const Icon(Icons.attach_money),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),

          // ✅ رفع صورة
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add Image",
                style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: screenHeight * 0.01),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo),
                    label: const Text("Gallery"),
                    // Inside your Gallery and Camera onPressed methods

                    onPressed: () async {
                      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        // Read the file's data into memory
                        final bytes = await picked.readAsBytes();
                        setState(() {
                          _selectedImageBytes = bytes;
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Camera"),
                    // Inside your Gallery and Camera onPressed methods

                    onPressed: () async {
                      final picked = await ImagePicker().pickImage(source: ImageSource.camera);
                      if (picked != null) {
                        // Read the file's data into memory
                        final bytes = await picked.readAsBytes();
                        setState(() {
                          _selectedImageBytes = bytes;
                        });
                      }
                    },
                  ),
                ],
              ),
              if (_selectedImageBytes != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    _selectedImageBytes!,
                    height: screenHeight * 0.2,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ]
            ],
          ),
          SizedBox(height: screenHeight * 0.02),

          // ✅ زر اختيار الموقع
          ElevatedButton.icon(
            icon: const Icon(Icons.location_on),
            label: Text(
              pickedLocation == null
                  ? "Pick Location"
                  : "Picked: ${pickedLocation!.latitude.toStringAsFixed(4)}, ${pickedLocation!.longitude.toStringAsFixed(4)}",
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final result = await Navigator.push<GeocodingResult?>(
                context,
                MaterialPageRoute(
                  builder: (context) => MapLocationPicker(
                    config: MapLocationPickerConfig(
                      apiKey: "AIzaSyAiTMUwNHc0sZ5O0MX7DvwV4awYc1mmCfs",
                      initialPosition: const LatLng(31.9539, 35.9106),
                      onNext: (geoResult) {
                        Navigator.pop(context, geoResult);
                      },
                    ),
                  ),
                ),
              );

              if (result != null) {
                final lat = result.geometry?.location.lat ?? 0;
                final lng = result.geometry?.location.lng ?? 0;

                setState(() {
                  pickedLocation = LatLng(lat, lng);
                });

                try {
                  List<geo.Placemark> placemarks =
                  await geo.placemarkFromCoordinates(lat, lng);

                  if (placemarks.isNotEmpty) {
                    final place = placemarks.first;
                    setState(() {
                      selectedPlace = place;
                      locationController.text =
                      "${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";
                    });
                    debugPrint("✅ Address: ${place.street}, ${place.locality}, ${place.country}");
                  }
                } catch (e) {
                  debugPrint("❌ Error in geocoding: $e");
                }
              }
            },
          ),
          const SizedBox(height: 10),

          TextField(
            controller: locationController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: "Selected Location",
              prefixIcon: const Icon(Icons.map),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),

          // ✅ الوقت
          TextField(
            controller: timeController,
            readOnly: true,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
                initialDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  timeController.text = picked.toString().split(" ")[0];
                });
              }
            },
            decoration: InputDecoration(
              labelText: "Select Date",
              prefixIcon: const Icon(Icons.access_time),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.03),

          // ✅ زر الإرسال
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _uploadRequest,
            child: Text(
              "Submit",
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.045,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
