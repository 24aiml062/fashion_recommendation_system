class AppEvent {
  final int id;
  final String title;
  final String eventType;
  final DateTime eventDate;
  final String location;
  final String notes;
  final bool outfitGenerated;

  AppEvent({
    required this.id,
    required this.title,
    required this.eventType,
    required this.eventDate,
    required this.location,
    required this.notes,
    required this.outfitGenerated,
  });

  factory AppEvent.fromJson(Map<String, dynamic> j) => AppEvent(
        id: j['id'],
        title: j['title'],
        eventType: j['event_type'],
        eventDate: DateTime.parse(j['event_date']),
        location: j['location'] ?? '',
        notes: j['notes'] ?? '',
        outfitGenerated: j['outfit_generated'] ?? false,
      );
}
