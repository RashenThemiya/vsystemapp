class Driver {
  final int driverId;
  final String name;
  final String phone;

  Driver({
    required this.driverId,
    required this.name,
    required this.phone,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      driverId: json['driver_id'],
      name: json['name'],
      phone: json['phone_number'],
    );
  }
}
