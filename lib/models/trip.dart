class Trip {
  final int tripId;
  final String from;
  final String to;
  final String status;
  final String vehicleNumber;
  final String customerName;
  final String customerPhone;

  Trip({
    required this.tripId,
    required this.from,
    required this.to,
    required this.status,
    required this.vehicleNumber,
    required this.customerName,
    required this.customerPhone,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      tripId: json['trip_id'],
      from: json['from_location'],
      to: json['to_location'],
      status: json['trip_status'],
      vehicleNumber: json['vehicle']['vehicle_number'],
      customerName: json['customer']['name'],
      customerPhone: json['customer']['phone_number'],
    );
  }
}
