import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/image_service.dart';
import '../services/supabase_service.dart';
import '../models/user.dart';

class PostSiteModal extends StatefulWidget {
  final AppUser? user;
  const PostSiteModal({super.key, this.user});
  @override
  State<PostSiteModal> createState() => _PostSiteModalState();
}

class _PostSiteModalState extends State<PostSiteModal> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  List<String> _photoPaths = [];
  Position? _position;
  bool _loading = false;

  Future<void> _getLocation() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('¡Se requieren permisos de ubicación!')),
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Los permisos de ubicación están permanentemente denegados. Por favor actívalos en la configuración.',
          ),
        ),
      );
      return;
    }
    _position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {});
  }

  Future<void> _pickPhotos() async {
    setState(() => _loading = true);
    try {
      final photos = await ImageService.pickImages(minCount: 5);
      setState(() {
        _photoPaths = photos;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar fotos: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (_photoPaths.length < 5 || _position == null || widget.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debes seleccionar al menos 5 fotos y una ubicación.')),
      );
      return;
    }
    setState(() {
      _loading = true;
    });
    final supabase = SupabaseService();
    try {
      final siteId = await supabase.createSite(
        title: _titleController.text,
        description: _descController.text,
        lat: _position!.latitude,
        lng: _position!.longitude,
        publisherId: widget.user!.id,
      );
      final urls = await ImageService.uploadImages(_photoPaths, siteId);
      await supabase.addSitePhotos(siteId, urls);
      setState(() {
        _loading = false;
      });
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el sitio: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Agregar nuevo sitio', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _descController,
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _getLocation,
                    icon: Icon(Icons.location_on),
                    label: Text(_position == null ? 'Obtener ubicación' : 'Ubicación lista'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickPhotos,
                    icon: Icon(Icons.photo_library),
                    label: Text('Seleccionar al menos 5 fotos'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: _loading ? null : _submit,
                    icon: Icon(Icons.save, color: Theme.of(context).primaryColor),
                    label: _loading
                        ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).primaryColor))
                        : Text('Guardar', style: TextStyle(color: Theme.of(context).primaryColor)),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Theme.of(context).colorScheme.error),
                    label: Text('Cancelar', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error, // use theme red
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
