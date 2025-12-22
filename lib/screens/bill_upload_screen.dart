import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/api_service.dart';
import '../core/storage.dart';
import '../models/vehicle.dart';
import '../models/bill_type.dart';

class BillUploadScreen extends StatefulWidget {
  const BillUploadScreen({super.key});

  @override
  State<BillUploadScreen> createState() => _BillUploadScreenState();
}

class _BillUploadScreenState extends State<BillUploadScreen> {
  List<Vehicle> vehicles = [];
  Vehicle? selectedVehicle;
  BillType? selectedBillType;
  DateTime? billDate;
  File? billImage;
  bool loading = false;

  final Color primaryColor = Colors.purple;
  final Color accentColor = Colors.pinkAccent;
  final TextStyle dropdownTextStyle = const TextStyle(color: Colors.black, fontWeight: FontWeight.w500);

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  Future<void> _fetchVehicles() async {
    try {
      final list = await ApiService.getVehicles();
      setState(() => vehicles = list);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching vehicles: $e")),
      );
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => billImage = File(image.path));
    }
  }

  Future<void> uploadBill() async {
    if (selectedVehicle == null || billImage == null || selectedBillType == null || billDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and select an image")),
      );
      return;
    }

    setState(() => loading = true);

    final bytes = await billImage!.readAsBytes();
    final base64Image = base64Encode(bytes);

    try {
      final driverId = await Storage.getDriverId();
      final res = await ApiService.uploadBill(
        vehicleId: selectedVehicle!.vehicleId,
        driverId: driverId,
        billType: selectedBillType!.name,
        billDate: billDate!,
        billImageBase64: base64Image,
      );

      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Bill uploaded successfully")),
        );
        setState(() {
          selectedVehicle = null;
          billImage = null;
          selectedBillType = null;
          billDate = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Upload failed: ${res['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading bill: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Vehicle Dropdown
          DropdownButtonFormField<Vehicle>(
            decoration: _inputDecoration("Select Vehicle"),
            value: selectedVehicle,
            style: dropdownTextStyle,
            dropdownColor: Colors.white,
            items: vehicles
                .map((v) => DropdownMenuItem(
                      value: v,
                      child: Text("${v.vehicleNumber} (${v.name})", style: dropdownTextStyle),
                    ))
                .toList(),
            onChanged: (v) => setState(() => selectedVehicle = v),
          ),
          const SizedBox(height: 16),

          // Bill Type Dropdown
          DropdownButtonFormField<BillType>(
            decoration: _inputDecoration("Select Bill Type"),
            value: selectedBillType,
            style: dropdownTextStyle,
            dropdownColor: Colors.white,
            items: BillType.values
                .map((bt) => DropdownMenuItem(
                      value: bt,
                      child: Text(bt.name.replaceAll("_", " "), style: dropdownTextStyle),
                    ))
                .toList(),
            onChanged: (bt) => setState(() => selectedBillType = bt),
          ),
          const SizedBox(height: 16),

          // Bill Date Picker
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              billDate == null ? "Select Bill Date" : "Bill Date: ${billDate!.toLocal()}".split(' ')[0],
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
            ),
            trailing: Icon(Icons.calendar_today, color: primaryColor),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) setState(() => billDate = picked);
            },
          ),
          const SizedBox(height: 16),

          // Image Picker & Preview
          billImage == null
              ? ElevatedButton.icon(
                  onPressed: pickImage,
                  icon: const Icon(Icons.upload_file, color: Colors.white),
                  label: const Text("Select Bill Image", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )
              : Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 6,
                  shadowColor: primaryColor.withOpacity(0.5),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.file(billImage!, height: 200, width: double.infinity, fit: BoxFit.cover),
                      ),
                      TextButton.icon(
                        onPressed: pickImage,
                        icon: Icon(Icons.edit, color: primaryColor),
                        label: const Text("Change Image"),
                      ),
                    ],
                  ),
                ),
          const SizedBox(height: 24),

          // Upload Button
          ElevatedButton.icon(
            onPressed: loading ? null : uploadBill,
            icon: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload),
            label: Text(loading ? "Uploading..." : "Upload Bill", style: const TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
