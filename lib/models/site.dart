class Site {
  final String id;
  final String title;
  final String description;
  final double lat;
  final double lng;
  final String publisherId;
  final List<String> photoUrls;

  Site({
    required this.id,
    required this.title,
    required this.description,
    required this.lat,
    required this.lng,
    required this.publisherId,
    required this.photoUrls,
  });

  factory Site.fromMap(Map<String, dynamic> map, List<String> photoUrls) {
    return Site(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      lat: map['lat'],
      lng: map['lng'],
      publisherId: map['publisher_id'],
      photoUrls: photoUrls,
    );
  }
}