import 'package:flutter/material.dart';
import '../models/review.dart';
import '../models/user.dart';
import '../services/supabase_service.dart';

class ReviewScreen extends StatefulWidget {
  final String siteId;
  final AppUser user;
  ReviewScreen({required this.siteId, required this.user});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  List<Review> _reviews = [];
  final _controller = TextEditingController();
  String? _replyTo;

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
    );
    _controller.clear();
    _replyTo = null;
    _loadReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reviews')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: _reviews.map((r) => ListTile(
                title: Text(r.content),
                subtitle: r.parentReviewId != null ? Text('Reply') : null,
                trailing: IconButton(
                  icon: Icon(Icons.reply),
                  onPressed: () {
                    setState(() => _replyTo = r.id);
                  },
                ),
              )).toList(),
            ),
          ),
          if (widget.user != null && widget.user.role != 'visitor')
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: _replyTo == null ? 'Write a review...' : 'Reply...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _postReview,
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Only publishers can add reviews.'),
            ),
        ],
      ),
    );
  }
}
