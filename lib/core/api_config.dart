class ApiConfig {
  static const String baseUrl = "https://rashen.sceniccottage.com/api";

  static const login = "/admin/login";
  static String driverDetails(int id) => "/drivers/$id/details";
  static String trips(int driverId, String status) =>
      "/drivers/$driverId/trips?status=$status";
}
