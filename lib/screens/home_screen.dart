import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/site.dart';
import '../services/supabase_service.dart';
import 'post_site_screen.dart';
import 'site_detail_screen.dart';
import 'login_screen.dart';
import '../widgets/post_site_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppUser? _user;
  List<Site> _sites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserAndSites();
  }

  Future<void> _loadUserAndSites() async {
    final user = await SupabaseService().getCurrentUser();
    final sites = await SupabaseService().getSites();
    if (!mounted) return;
    setState(() {
      _user = user;
      _sites = sites;
      _loading = false;
    });
  }

  void _logout() async {
    await SupabaseService().logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Center(child: CircularProgressIndicator());
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sitios turísticos'),
            if (_user != null && _user!.displayName.isNotEmpty)
              Text(
                '¡Bienvenido, ${_user!.displayName}! ',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white70),
              ),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: _logout, tooltip: 'Cerrar sesión'),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _sites.length,
        itemBuilder: (context, idx) {
          final site = _sites[idx];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SiteDetailScreen(site: site, user: _user)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (site.photoUrls.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        site.photoUrls.first,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 180,
                          color: Colors.grey[300],
                          child: Center(child: Icon(Icons.image, size: 60, color: Colors.grey)),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(site.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            // Show stars based on averageScore
                            for (int i = 1; i <= 5; i++)
                              Icon(
                                i <= site.averageScore.floor()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              ),
                            SizedBox(width: 8),
                            Text(
                              site.averageScore.toStringAsFixed(1),
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            SizedBox(width: 8),
                            Text('(${site.reviewCount})', style: TextStyle(color: Colors.black54)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(site.description, maxLines: 3, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: _user?.role == 'publisher'
          ? FloatingActionButton(
              tooltip: 'Agregar sitio',
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) => PostSiteModal(user: _user),
                ).then((_) => _loadUserAndSites());
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}
