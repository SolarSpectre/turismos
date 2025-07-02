class Review {
  final String id;
  final String siteId;
  final String userId;
  final String content;
  final String? parentReviewId;
  final DateTime createdAt;
  final int score;
  final String? userDisplayName;

  Review({
    required this.id,
    required this.siteId,
    required this.userId,
    required this.content,
    this.parentReviewId,
    required this.createdAt,
    required this.score,
    this.userDisplayName,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'],
      siteId: map['site_id'],
      userId: map['user_id'],
      content: map['content'],
      parentReviewId: map['parent_review_id'],
      createdAt: DateTime.parse(map['created_at']),
      score: map['score'] ?? 5,
      userDisplayName: map['user_display_name'] ?? map['display_name'],
    );
  }
}