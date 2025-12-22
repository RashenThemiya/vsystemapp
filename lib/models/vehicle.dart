class Vehicle {
  final int vehicleId;
  final String vehicleNumber;
  final String name;

  Vehicle({required this.vehicleId, required this.vehicleNumber, required this.name});

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vehicleId: json['vehicle_id'],
      vehicleNumber: json['vehicle_number'],
      name: json['name'],
    );
  }
}
