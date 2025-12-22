import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../core/storage.dart';
import '../models/trip.dart';

class TripListScreen extends StatefulWidget {
  final String status;
  const TripListScreen({super.key, required this.status});

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  late Future<List<Trip>> _trips;

  final Color primaryColor = Colors.purple;
  final Color accentColor = Colors.pinkAccent;

  @override
  void initState() {
    super.initState();
    _trips = _fetchTrips();
  }

  Future<List<Trip>> _fetchTrips() async {
    try {
      final driverId = await Storage.getDriverId();
      final list = await ApiService.getTrips(driverId, widget.status);
      return list.map((e) => Trip.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetching trips: $e");
      return [];
    }
  }

  Future<void> _refreshTrips() async {
    setState(() {
      _trips = _fetchTrips();
    });
  }

  Future<void> _startTrip(Trip trip) async {
    final controller = TextEditingController();
    final meter = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Enter Start Meter"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Start Meter"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
            ),
            onPressed: () {
              final value = int.tryParse(controller.text);
              Navigator.pop(context, value);
            },
            child: const Text("Start", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );

    if (meter != null) {
      try {
        final res = await ApiService.startTrip(trip.tripId, meter);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['success'] == true
                ? "✅ Trip started successfully"
                : "❌ Failed to start trip: ${res['message']}"),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      } finally {
        await _refreshTrips();
      }
    }
  }

  Future<void> _endTrip(Trip trip) async {
    final controller = TextEditingController();
    final meter = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Enter End Meter"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "End Meter"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
            ),
            onPressed: () {
              final value = int.tryParse(controller.text);
              Navigator.pop(context, value);
            },
            child: const Text("End", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );

    if (meter != null) {
      try {
        final res = await ApiService.endTrip(trip.tripId, meter);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['success'] == true
                ? "✅ Trip ended successfully"
                : "❌ Failed to end trip: ${res['message']}"),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      } finally {
        await _refreshTrips();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Trip>>(
      future: _trips,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final trips = snapshot.data ?? [];
        if (trips.isEmpty) {
          return const Center(child: Text("No trips available"));
        }

        return RefreshIndicator(
          onRefresh: _refreshTrips,
          child: ListView.builder(
            itemCount: trips.length,
            itemBuilder: (_, index) {
              final trip = trips[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                shadowColor: primaryColor.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Vehicle: ${trip.vehicleNumber}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("Customer: ${trip.customerName}", style: const TextStyle(color: Colors.black87)),
                      Text("Phone: ${trip.customerPhone}", style: const TextStyle(color: Colors.black54)),
                      Text("Route: ${trip.from} → ${trip.to}", style: const TextStyle(color: Colors.black87)),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => widget.status == "Pending"
                              ? _startTrip(trip)
                              : _endTrip(trip),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.status == "Pending" ? primaryColor : accentColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            widget.status == "Pending" ? "Start Trip" : "End Trip",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
