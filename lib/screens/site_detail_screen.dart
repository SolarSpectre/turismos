import 'package:flutter/material.dart';
import '../models/site.dart';
import '../models/user.dart';
import 'review_screen.dart';

class SiteDetailScreen extends StatelessWidget {
  final Site site;
  final AppUser? user;
  SiteDetailScreen({required this.site, this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(site.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (site.photoUrls.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: site.photoUrls.map((url) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(url, width: 200, fit: BoxFit.cover),
                  )).toList(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(site.description),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Location: (${site.lat}, ${site.lng})'),
            ),
            Center(
              child: ElevatedButton(
                child: Text('View/Add Reviews'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewScreen(siteId: site.id, user: user!),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
