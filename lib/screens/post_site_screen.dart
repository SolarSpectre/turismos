import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/image_service.dart';
import '../services/supabase_service.dart';
import '../models/user.dart';

class PostSiteScreen extends StatefulWidget {
  final AppUser? user;
  PostSiteScreen({this.user});
  @override
  State<PostSiteScreen> createState() => _PostSiteScreenState();
}

class _PostSiteScreenState extends State<PostSiteScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  List<String> _photoPaths = [];
  Position? _position;
  bool _loading = false;

  Future<void> _getLocation() async {
    LocationPermission permission;

    // Check permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, show a message and return
        print('Location permissions are denied');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permission is required!')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately
      print('Location permissions are permanently denied');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location permissions are permanently denied. Please enable them in settings.',
          ),
        ),
      );
      return;
    }

    // If permissions are granted, get the position
    _position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {});
  }

  Future<void> _pickPhotos() async {
    print('Starting to pick photos');
    setState(() => _loading = true);
    try {
      final photos = await ImageService.pickImages(minCount: 5);
      print('Picked photos: ' + photos.toString());
      setState(() {
        _photoPaths = photos;
      });
    } catch (e) {
      print('Error picking photos: ' + e.toString());
      // Show error
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    print('Submit started');
    if (_photoPaths.length < 5 || _position == null || widget.user == null) {
      print('Not enough photos or location/user missing');
      return;
    }
    setState(() {
      _loading = true;
    });
    final supabase = SupabaseService();
    try {
      print('Creating site...');
      final siteId = await supabase.createSite(
        title: _titleController.text,
        description: _descController.text,
        lat: _position!.latitude,
        lng: _position!.longitude,
        publisherId: widget.user!.id,
      );
      print('Site created with id: ' + siteId);
      print('Uploading images...');
      final urls = await ImageService.uploadImages(_photoPaths, siteId);
      print('Uploaded image URLs: ' + urls.toString());
      print('Saving photo URLs to DB...');
      await supabase.addSitePhotos(siteId, urls);
      print('Site and photos saved successfully');
      setState(() {
        _loading = false;
      });
      Navigator.pop(context);
    } catch (e) {
      print('Error in submit: ' + e.toString());
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Center(child: CircularProgressIndicator());
    return Scaffold(
      appBar: AppBar(title: Text('Post New Site')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            ElevatedButton(
              onPressed: _getLocation,
              child: Text(_position == null ? 'Get Location' : 'Location Set'),
            ),
            ElevatedButton(
              onPressed: _pickPhotos,
              child: Text('Pick at least 5 Photos'),
            ),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading ? CircularProgressIndicator() : Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
