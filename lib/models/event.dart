import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String eventId;
  final String title;
  final String description;
  final DateTime date;
  final int capacity;
  final int currentParticipants;
  final String createdBy;
  final String? imageUrl;
  final String location;

  Event({
    required this.eventId,
    required this.title,
    required this.description,
    required this.date,
    required this.capacity,
    this.currentParticipants = 0,
    required this.createdBy,
    this.imageUrl,
    this.location = '',
  });

  bool get isFull => currentParticipants >= capacity;
  int get remainingSpots => capacity - currentParticipants;

  /// FirestoreのドキュメントからEventを作成
  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      eventId: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      capacity: data['capacity'] ?? 0,
      currentParticipants: data['currentParticipants'] ?? 0,
      createdBy: data['createdBy'] ?? '',
      imageUrl: data['imageUrl'],
      location: data['location'] ?? '',
    );
  }

  /// EventをFirestore用のMapに変換
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'capacity': capacity,
      'currentParticipants': currentParticipants,
      'createdBy': createdBy,
      'imageUrl': imageUrl,
      'location': location,
    };
  }

  /// 一部のフィールドを更新したEventを作成
  Event copyWith({
    String? eventId,
    String? title,
    String? description,
    DateTime? date,
    int? capacity,
    int? currentParticipants,
    String? createdBy,
    String? imageUrl,
    String? location,
  }) {
    return Event(
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      capacity: capacity ?? this.capacity,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      createdBy: createdBy ?? this.createdBy,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
    );
  }
}
