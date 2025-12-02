import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geo;

import '../utils/service_types.dart';


// 1. أصبح الكلاس مجرد حاوية للدالة static
class ServiceDialog {
  // 2. حولنا الدالة إلى static ليتم استدعاؤها مباشرة
  static void show(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogWidth = screenWidth * 0.9;


    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.bottomSlide,
      // 3. استخدمنا الويدجت الجديدة التي أنشأناها في الأسفل لإدارة الحالة
      body: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogWidth),
        child: SizedBox(
          height: screenHeight * 0.7,
          // ✅ هنا التغيير الأساسي
          child: const _ServiceDialogContent(),
        ),
      ),
    ).show();
  }
}

// 4. أنشأنا ويدجت خاصة Stateful فقط لمحتوى الديالوج لإدارة حالته الداخلية
class _ServiceDialogContent extends StatefulWidget {
  const _ServiceDialogContent({Key? key}) : super(key: key);

  @override
  State<_ServiceDialogContent> createState() => _ServiceDialogContentState();
}

class _ServiceDialogContentState extends State<_ServiceDialogContent> {
  // ✅ نقلنا كل المتغيرات والـ Controllers إلى هنا
  File? selectedImage;
  LatLng? pickedLocation;
  final serviceNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final locationController = TextEditingController();
  final timeController = TextEditingController();
  geo.Placemark? selectedPlace;


  @override
  void dispose() {
    serviceNameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    locationController.dispose();
    timeController.dispose();
    super.dispose();
  }

  Future<void> _uploadService() async {
    // لا يوجد تغيير في هذه الدالة
    try {
      String? imageUrl;
      if (selectedImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child("services/${DateTime.now().millisecondsSinceEpoch}.jpg");
        await ref.putFile(selectedImage!);
        imageUrl = await ref.getDownloadURL();
      }

      if (selectedPlace == null || pickedLocation == null) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          title: 'Missing location',
          desc: 'Please choose a location from the map first.',
        ).show();
        return;
      }

      final data = {
        "serviceType": selectedRequestType ?? "",
        "description": descriptionController.text,
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
        "imageUrl": imageUrl ?? "",
        "createdAt": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection("services").add(data);





      // ✅ إغلاق الديالوج عند النجاح
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Service uploaded successfully ✅")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }
  String? selectedRequestType;
  // ✅ دالة الـ build الآن تبني محتوى الديالوج فقط
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
            "Add Your Service",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),

          // ✅ اسم الخدمة
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'CHOOSE THE SERVICE TYPE',
              border: OutlineInputBorder(),
            ),
            value: selectedRequestType,
            items: kOfferServiceTypes.map((type) {
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
                "Add Service Image",
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo),
                    label: const Text("Gallery"),
                    onPressed: () async {
                      final picked = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        setState(() {
                          selectedImage = File(picked.path);
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Camera"),
                    onPressed: () async {
                      final picked = await ImagePicker()
                          .pickImage(source: ImageSource.camera);
                      if (picked != null) {
                        setState(() {
                          selectedImage = File(picked.path);
                        });
                      }
                    },
                  ),
                ],
              ),
              if (selectedImage != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    selectedImage!,
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
                  : "Picked",
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
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
                // ✅ نحصل على lat و lng بطريقة آمنة
                final lat = result.geometry?.location.lat ?? 0;
                final lng = result.geometry?.location.lng ?? 0;

                if (lat == 0 && lng == 0) {
                  debugPrint("⚠️ Location not found in result.");
                  return;
                }

                setState(() {
                  pickedLocation = LatLng(lat, lng);
                });

                debugPrint("📍 Picked Location: $lat, $lng");

                try {
                  // ✅ نستخدم geocoding لتحويل الإحداثيات إلى عنوان
                  List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(lat, lng);

                  if (placemarks.isNotEmpty) {
                    final place = placemarks.first;
                    setState(() {
                      selectedPlace = place;
                      locationController.text =
                      "${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";
                    });

                    debugPrint("✅ Address: ${place.street}, ${place.locality}, ${place.country}");
                  } else {
                    debugPrint("⚠️ No address found for coordinates");
                  }
                } catch (e) {
                  debugPrint("❌ Error in geocoding: $e");
                }
              } else {
                debugPrint("⚠️ No result returned from MapLocationPicker");
              }
            },



          ),

          const SizedBox(height: 10),

          TextField(
            controller: locationController,
            readOnly: true,
            decoration: InputDecoration(
              label:  Text(
                pickedLocation == null
                    ? "Pick Location"
                    : "Picked: ${pickedLocation!.latitude.toStringAsFixed(4)}, ${pickedLocation!.longitude.toStringAsFixed(4)}",
              ),
              prefixIcon: const Icon(Icons.map),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
              labelText: "Available Date",
              prefixIcon: const Icon(Icons.access_time),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.03),

          // ✅ زر إرسال
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _uploadService,

            // استدعاء الدالة مباشرة
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