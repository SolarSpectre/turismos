import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';
import '../models/site.dart';
import '../models/review.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<void> signUp(String email, String password, String role, String displayName) async {
    final response = await supabase.auth.signUp(email: email, password: password);
    if (response.user != null) {
      await supabase.from('users').insert({
        'id': response.user!.id,
        'email': email,
        'role': role,
        'display_name': displayName,
      });
    }
  }

  Future<void> signIn(String email, String password) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  Future<AppUser?> getCurrentUser() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;
    final data = await supabase.from('users').select().eq('id', user.id).single();
    if (data == null) return null;
    return AppUser.fromMap(data);
  }

  Future<List<Site>> getSites() async {
    final data = await supabase.from('sites').select();
    List<Site> sites = [];
    for (final site in data) {
      final photos = await supabase.from('site_photos').select('url').eq('site_id', site['id']);
      final photoUrls = List<String>.from(photos.map((p) => p['url']));
      sites.add(Site.fromMap(site, photoUrls));
    }
    return sites;
  }

  Future<List<Review>> getReviews(String siteId) async {
    final data = await supabase.from('reviews').select().eq('site_id', siteId).order('created_at');
    return List<Review>.from(data.map((r) => Review.fromMap(r)));
  }

  Future<void> postReview({required String siteId, required String userId, required String content, String? parentReviewId}) async {
    await supabase.from('reviews').insert({
      'site_id': siteId,
      'user_id': userId,
      'content': content,
      'parent_review_id': parentReviewId,
    });
  }

  Future<String> createSite({required String title, required String description, required double lat, required double lng, required String publisherId}) async {
    final response = await supabase.from('sites').insert({
      'title': title,
      'description': description,
      'lat': lat,
      'lng': lng,
      'publisher_id': publisherId,
    }).select().single();
    return response['id'];
  }

  Future<void> addSitePhotos(String siteId, List<String> urls) async {
    final photoRows = urls.map((url) => {'site_id': siteId, 'url': url}).toList();
    await supabase.from('site_photos').insert(photoRows);
  }

  // Add more methods for CRUD operations on sites, reviews, etc.
}
