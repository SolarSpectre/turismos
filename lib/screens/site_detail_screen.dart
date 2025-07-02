import 'package:flutter/material.dart';
import '../models/site.dart';
import '../models/user.dart';
import 'review_screen.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';

class SiteDetailScreen extends StatefulWidget {
  final Site site;
  final AppUser? user;
  const SiteDetailScreen({super.key, required this.site, this.user});

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
    final images = widget.site.photoUrls;
    final isVisitor = widget.user == null || widget.user!.role == 'visitor';
    return Scaffold(
      appBar: AppBar(title: Text(widget.site.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (images.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) {
                            int currentPage = 0;
                            PageController controller = PageController();
                            return StatefulBuilder(
                              builder: (context, setState) => Dialog(
                                insetPadding: EdgeInsets.all(16),
                                backgroundColor: Colors.transparent,
                                child: Container(
                                  constraints: BoxConstraints(maxHeight: 400),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      PageView.builder(
                                        controller: controller,
                                        itemCount: images.length,
                                        onPageChanged: (i) => setState(() => currentPage = i),
                                        itemBuilder: (context, index) => ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            images[index],
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      if (images.length > 1 && currentPage > 0)
                                        Positioned(
                                          left: 8,
                                          child: IconButton(
                                            icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 32),
                                            onPressed: () {
                                              if (currentPage > 0) {
                                                controller.previousPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
                                              }
                                            },
                                          ),
                                        ),
                                      if (images.length > 1 && currentPage < images.length - 1)
                                        Positioned(
                                          right: 8,
                                          child: IconButton(
                                            icon: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 32),
                                            onPressed: () {
                                              if (currentPage < images.length - 1) {
                                                controller.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
                                              }
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: SizedBox(
                        height: 220,
                        child: Row(
                          children: [
                            // Left: Large image
                            Expanded(
                              flex: 2,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                                child: Image.network(
                                  images[0],
                                  fit: BoxFit.cover,
                                  height: double.infinity,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            if (images.length > 1) ...[
                              SizedBox(width: 4), // Small gap between columns
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(12),
                                        ),
                                        child: Image.network(
                                          images[1],
                                          fit: BoxFit.cover,
                                          height: double.infinity,
                                          width: double.infinity,
                                        ),
                                      ),
                                    ),
                                    if (images.length > 2)
                                      SizedBox(height: 4),
                                    if (images.length > 2)
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(12),
                                          ),
                                          child: Image.network(
                                            images[2],
                                            fit: BoxFit.cover,
                                            height: double.infinity,
                                            width: double.infinity,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) {
                              int currentPage = 0;
                              PageController controller = PageController();
                              return StatefulBuilder(
                                builder: (context, setState) => Dialog(
                                  insetPadding: EdgeInsets.all(16),
                                  backgroundColor: Colors.transparent,
                                  child: Container(
                                    constraints: BoxConstraints(maxHeight: 400),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        PageView.builder(
                                          controller: controller,
                                          itemCount: images.length,
                                          onPageChanged: (i) => setState(() => currentPage = i),
                                          itemBuilder: (context, index) => ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.network(
                                              images[index],
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                        if (images.length > 1 && currentPage > 0)
                                          Positioned(
                                            left: 8,
                                            child: IconButton(
                                              icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 32),
                                              onPressed: () {
                                                if (currentPage > 0) {
                                                  controller.previousPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
                                                }
                                              },
                                            ),
                                          ),
                                        if (images.length > 1 && currentPage < images.length - 1)
                                          Positioned(
                                            right: 8,
                                            child: IconButton(
                                              icon: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 32),
                                              onPressed: () {
                                                if (currentPage < images.length - 1) {
                                                  controller.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
                                                }
                                              },
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.photo_library, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                '${images.length}',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Acerca de",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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
