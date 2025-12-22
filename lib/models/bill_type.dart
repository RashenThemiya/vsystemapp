enum BillType {
  Lease_Cost,
  Service_Cost,
  Repairs_Cost,
  Insurance_Amount,
  Revenue_License,
  Eco_Test_Cost,
  Fuel_Cost,
}

extension BillTypeExtension on BillType {
  String get name {
    return toString().split('.').last; // returns enum value as string
  }
}
