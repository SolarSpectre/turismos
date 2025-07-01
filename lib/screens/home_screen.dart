import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/site.dart';
import '../services/supabase_service.dart';
import 'post_site_screen.dart';
import 'site_detail_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
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
        title: Text('Touristic Sites'),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: ListView.builder(
        itemCount: _sites.length,
        itemBuilder: (context, idx) {
          final site = _sites[idx];
          return ListTile(
            title: Text(site.title),
            subtitle: Text(site.description),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SiteDetailScreen(site: site, user: _user)),
            ),
          );
        },
      ),
      floatingActionButton: _user?.role == 'publisher'
          ? FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PostSiteScreen(user: _user)),
                );
                _loadUserAndSites();
              },
            )
          : null,
    );
  }
}
