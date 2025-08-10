// models/shipment.dart
class Shipment {
  final String id;
  final String destination;
  final String status;
  final String lastUpdate;

  Shipment({
    required this.id,
    required this.destination,
    required this.status,
    required this.lastUpdate,
  });
}
