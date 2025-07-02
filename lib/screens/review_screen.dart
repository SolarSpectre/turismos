import 'package:flutter/material.dart';
import '../models/review.dart';
import '../models/user.dart';
import '../services/supabase_service.dart';

class ReviewScreen extends StatefulWidget {
  final String siteId;
  final AppUser user;
  const ReviewScreen({super.key, required this.siteId, required this.user});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  List<Review> _reviews = [];
  final _controller = TextEditingController();
  String? _replyTo;
  int _selectedStars = 1;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final reviews = await SupabaseService().getReviews(widget.siteId);
    setState(() => _reviews = reviews);
  }

  Future<void> _postReview() async {
    if (_controller.text.isEmpty) return;
    await SupabaseService().postReview(
      siteId: widget.siteId,
      userId: widget.user.id,
      content: _controller.text,
      parentReviewId: _replyTo,
      score: _selectedStars
    );
    _controller.clear();
    _replyTo = null;
    _loadReviews();
  }

  Future<void> _postReviewWithScore() async {
    if (_controller.text.isEmpty) return;
    await SupabaseService().postReview(
      siteId: widget.siteId,
      userId: widget.user.id,
      content: _controller.text,
      parentReviewId: _replyTo,
      score: _selectedStars,
    );
    _controller.clear();
    _replyTo = null;
    setState(() {
      _selectedStars = 5;
    });
    _loadReviews();
  }

  String _formatReviewDate(DateTime date) {
    // Example: 'junio de 2025'
    final months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${months[date.month - 1]} de ${date.year}';
  }

  String _formatWrittenDate(DateTime date) {
    // Example: '26 de junio de 2025'
    final months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reseñas')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: _reviews.map((r) {
                // Find parent review if this is a reply
                final parent = (r.parentReviewId != null && r.parentReviewId!.isNotEmpty)
                  ? _reviews.firstWhere(
                      (p) => p.id == r.parentReviewId,
                      orElse: () => Review(
                        id: '', siteId: '', userId: '', content: '', createdAt: DateTime.now(), score: 0
                      ),
                    )
                  : null;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Card(
                    elevation: 2,
                    color: r.parentReviewId != null && r.parentReviewId!.isNotEmpty ? Colors.blue[50] : null,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (parent != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    parent.userDisplayName ?? 'Usuario',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue[900]),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    parent.content.split('\n').first,
                                    style: TextStyle(fontSize: 13, color: Colors.blue[900]),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          if ((r.parentReviewId ?? '').isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Row(
                                children: [
                                  Icon(Icons.reply, color: Colors.blue, size: 18),
                                  SizedBox(width: 4),
                                  Text('Respuesta', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          Row(
                            children: [
                              Text(
                                r.userDisplayName ?? 'Usuario',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(width: 8),
                              Text('1 contribución', style: TextStyle(fontSize: 12, color: Colors.black54)),
                              if (widget.user.role != 'visitor' && (r.parentReviewId == null || r.parentReviewId!.isEmpty))
                                IconButton(
                                  icon: Icon(Icons.reply, color: Colors.blue),
                                  tooltip: 'Responder',
                                  onPressed: () {
                                    setState(() => _replyTo = r.id);
                                  },
                                ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: List.generate(5, (i) => Icon(
                              i < r.score ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            )),
                          ),
                          SizedBox(height: 8),
                          Text(
                            r.content.split('\n').first,
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Escrita el ${_formatWrittenDate(r.createdAt)}',
                            style: TextStyle(fontSize: 12, color: Colors.black54, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (widget.user.role != 'visitor')
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Row(
                    children: List.generate(5, (i) => IconButton(
                      icon: Icon(
                        i < _selectedStars ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedStars = i + 1;
                        });
                      },
                    )),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: _replyTo == null ? 'Escribe una reseña...' : 'Responder...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      _postReviewWithScore();
                    },
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Solo los publicadores pueden agregar reseñas.'),
            ),
        ],
      ),
    );
  }
}
