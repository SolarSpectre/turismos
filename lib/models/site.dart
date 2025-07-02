class Site {
  final String id;
  final String title;
  final String description;
  final double lat;
  final double lng;
  final String publisherId;
  final List<String> photoUrls;
  final double averageScore;
  final int reviewCount;

  Site({
    required this.id,
    required this.title,
    required this.description,
    required this.lat,
    required this.lng,
    required this.publisherId,
    required this.photoUrls,
    required this.averageScore,
    required this.reviewCount,
  });

  factory Site.fromMap(Map<String, dynamic> map, List<String> photoUrls) {
    double avgScore = 0;
    int revCount = 0;
    if (map['averageScore'] != null) {
      avgScore = (map['averageScore'] as num).toDouble();
    } else if (map['average_score'] != null) {
      avgScore = (map['average_score'] as num).toDouble();
    }
    if (map['reviewCount'] != null) {
      revCount = (map['reviewCount'] as num).toInt();
    } else if (map['review_count'] != null) {
      revCount = (map['review_count'] as num).toInt();
    }
    return Site(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      lat: map['lat'],
      lng: map['lng'],
      publisherId: map['publisher_id'],
      photoUrls: photoUrls,
      averageScore: avgScore,
      reviewCount: revCount,
    );
  }
}