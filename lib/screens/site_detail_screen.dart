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

  void _openMaps() async {
    final geoUrl = Uri.parse('geo:${widget.site.lat},${widget.site.lng}?q=${widget.site.lat},${widget.site.lng}');
    final webUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=${widget.site.lat},${widget.site.lng}');
    print('Trying to launch geo: $geoUrl');
    if (await canLaunchUrl(geoUrl)) {
      await launchUrl(geoUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(webUrl)) {
      print('geo: failed, trying web URL: $webUrl');
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    } else {
      print('Could not launch maps for either geo: or web URL');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir la ubicación en Google Maps.')),
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
                onTap: _openMaps,
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
