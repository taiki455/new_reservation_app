class Reservation {
  final String reservationId;
  final String eventId;
  final String userId;
  final DateTime reservedAt;
  final bool attended;

  Reservation({
    required this.reservationId,
    required this.eventId,
    required this.userId,
    required this.reservedAt,
    this.attended = false,
  });
}

