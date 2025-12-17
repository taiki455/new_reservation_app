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
}

