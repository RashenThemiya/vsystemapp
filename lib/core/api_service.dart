import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage.dart';
import 'api_config.dart';
import '../models/vehicle.dart';
import 'package:flutter/foundation.dart'; // <-- add this

class ApiService {
  /// Login user
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse(ApiConfig.baseUrl + ApiConfig.login),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Login failed: ${res.body}");
    }
  }

  /// Get trips for a driver with status
  static Future<List<dynamic>> getTrips(int driverId, String status) async {
  final token = await Storage.getToken();
  if (token == null) throw Exception("Token not found");

  final uri = Uri.parse(ApiConfig.baseUrl + "/drivers/$driverId/trips")
      .replace(queryParameters: {"status": status});

  final res = await http.get(
    uri,
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  if (res.statusCode != 200) {
    throw Exception("Error fetching trips: ${res.statusCode} ${res.body}");
  }

  final data = jsonDecode(res.body)["data"];
  if (data == null) return [];
  return data;
}


  /// Get vehicles list
  static Future<List<Vehicle>> getVehicles() async {
    final token = await Storage.getToken();
    final res = await http.get(
      Uri.parse(ApiConfig.baseUrl + "/vehicles"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Vehicle.fromJson(e)).toList();
    } else {
      debugPrint("Error fetching vehicles: ${res.statusCode} ${res.body}");
      return [];
    }
  }

  /// Start trip API call
  static Future<Map<String, dynamic>> startTrip(int tripId, int startMeter) async {
    final token = await Storage.getToken();
    final res = await http.patch(
      Uri.parse("${ApiConfig.baseUrl}/trips/$tripId/start"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"start_meter": startMeter}),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to start trip: ${res.body}");
    }
  }

  /// End trip API call
  static Future<Map<String, dynamic>> endTrip(int tripId, int endMeter) async {
    final token = await Storage.getToken();
    final res = await http.patch(
      Uri.parse("${ApiConfig.baseUrl}/trips/$tripId/end"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"end_meter": endMeter}),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to end trip: ${res.body}");
    }
  }

  /// Upload bill API
  static Future<Map<String, dynamic>> uploadBill({
    required int vehicleId,
    required int driverId,
    required String billType,
    required DateTime billDate,
    required String billImageBase64,
  }) async {
    final token = await Storage.getToken();
    final res = await http.post(
      Uri.parse(ApiConfig.baseUrl + "/bill-uploads"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "vehicle_id": vehicleId,
        "driver_id": driverId,
        "bill_type": billType,
        "bill_date": billDate.toIso8601String(),
        "bill_status": "pending",
        "bill_image_base64": billImageBase64,
        "vehicle_other_cost_id": null,
      }),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to upload bill: ${res.body}");
    }
  }
}
