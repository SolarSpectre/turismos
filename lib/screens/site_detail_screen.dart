import 'package:flutter/material.dart';
import '../models/site.dart';
import '../models/user.dart';
import 'review_screen.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';

class SiteDetailScreen extends StatefulWidget {
  final Site site;
  final AppUser? user;
  SiteDetailScreen({required this.site, this.user});

  @override
  State<SiteDetailScreen> createState() => _SiteDetailScreenState();
}

class _SiteDetailScreenState extends State<SiteDetailScreen> {
  String? _placeName;

  @override
  void initState() {
    super.initState();
    _getPlaceName();
  }

  Future<void> _getPlaceName() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(widget.site.lat, widget.site.lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          _placeName = [p.name, p.locality, p.administrativeArea, p.country].where((e) => e != null && e.isNotEmpty).join(', ');
        });
      }
    } catch (e) {
      setState(() {
        _placeName = null;
      });
    }
  }

  Future<void> _openInGoogleMaps() async {
    if (widget.site.lat == null || widget.site.lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Obten tu ubicacion primero')),
      );
      return;
    }

    // Try multiple URL schemes for better compatibility
    final urls = [
      // Google Maps app URL scheme with proper format
      'geo:${widget.site.lat},${widget.site.lng}?q=${widget.site.lat},${widget.site.lng}',
      // Google Maps navigation URL
      'google.navigation:q=${widget.site.lat},${widget.site.lng}',
      // Google Maps web URL (fallback)
      'https://www.google.com/maps?q=${widget.site.lat},${widget.site.lng}&z=15',
      // Alternative Google Maps URL
      'https://maps.google.com/?q=${widget.site.lat},${widget.site.lng}&z=15',
    ];

    bool launched = false;
    
    for (String url in urls) {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          final result = await launchUrl(
            uri, 
            mode: LaunchMode.externalApplication,
          );
          if (result) {
            launched = true;
            break;
          }
        }
      } catch (e) {
        // Continue to next URL if this one fails
        continue;
      }
    }

    if (!launched) {
      // Show a more helpful message with the coordinates
      final coordinates = '${widget.site.lat}, ${widget.site.lng}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo abrir Google Maps. Coordenadas: $coordinates'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVisitor = widget.user == null || widget.user!.role == 'visitor';
    return Scaffold(
      appBar: AppBar(title: Text(widget.site.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.site.photoUrls.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: widget.site.photoUrls.map((url) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(url, width: 200, fit: BoxFit.cover),
                  )).toList(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(widget.site.description),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: _openInGoogleMaps,
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _placeName != null && _placeName!.isNotEmpty
                          ? _placeName!
                          : 'Ubicación: (${widget.site.lat}, ${widget.site.lng})',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: ElevatedButton(
                child: Text(isVisitor ? 'Ver Reseñas' : 'Ver/Agregar reseñas'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewScreen(siteId: widget.site.id, user: widget.user!),
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
