class Trip {
  final int tripId;
  final String from;
  final String to;
  final String status;
  final String vehicleNumber;
  final String customerName;
  final String customerPhone;
  final DateTime leavingDateTime;

  Trip({
    required this.tripId,
    required this.from,
    required this.to,
    required this.status,
    required this.vehicleNumber,
    required this.customerName,
    required this.customerPhone,
    required this.leavingDateTime,
    re
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      tripId: json['trip_id'] ?? 0,
      from: json['from_location'] ?? '',
      to: json['to_location'] ?? '',
      status: json['trip_status'] ?? '',

      vehicleNumber: json['vehicle']?['vehicle_number'] ?? '',
      customerName: json['customer']?['name'] ?? '',
      customerPhone: json['customer']?['phone_number'] ?? '',

      // ✅ FIXED KEY NAME
      leavingDateTime: DateTime.parse(json['leaving_datetime']),
    );
  }
}