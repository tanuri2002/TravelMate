import '../models/trip.dart';

class TripService {
  final List<Trip> _trips = [];

  void addTrip(Trip trip) {
    _trips.add(trip);
  }

  Trip? getTripById(String id) {
    return _trips.firstWhere((t) => t.id == id, orElse: () => Trip(id: "", userId: "", destinations: []));
  }

  void addDestinationToTrip(String tripId, String destinationId) {
    final trip = _trips.firstWhere((t) => t.id == tripId, orElse: () => Trip(id: "", userId: "", destinations: []));
    if (trip.id.isNotEmpty) {
      trip.addDestination(destinationId);
    }
  }
}
