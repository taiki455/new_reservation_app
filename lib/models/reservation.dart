import 'package:cloud_firestore/cloud_firestore.dart';

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

  /// FirestoreのドキュメントからReservationを作成
  factory Reservation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Reservation(
      reservationId: doc.id,
      eventId: data['eventId'] ?? '',
      userId: data['userId'] ?? '',
      reservedAt: (data['reservedAt'] as Timestamp).toDate(),
      attended: data['attended'] ?? false,
    );
  }

  /// ReservationをFirestore用のMapに変換
  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'userId': userId,
      'reservedAt': Timestamp.fromDate(reservedAt),
      'attended': attended,
    };
  }

  /// attendedを更新したReservationを作成
  Reservation copyWith({
    String? reservationId,
    String? eventId,
    String? userId,
    DateTime? reservedAt,
    bool? attended,
  }) {
    return Reservation(
      reservationId: reservationId ?? this.reservationId,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      reservedAt: reservedAt ?? this.reservedAt,
      attended: attended ?? this.attended,
    );
  }
}
