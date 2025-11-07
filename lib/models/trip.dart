class Trip {
  String id;
  String userId;
  List<String> destinations;

  Trip({
    required this.id,
    required this.userId,
    required this.destinations,
  });

  void addDestination(String destinationId) {
    destinations.add(destinationId);
  }
}
