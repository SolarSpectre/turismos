import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class ImageService {
  static Future<List<String>> pickImages({int minCount = 5, int maxSizeMB = 5}) async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.length < minCount) {
      throw Exception('Please select at least $minCount images.');
    }
    for (final img in picked) {
      final file = File(img.path);
      final sizeMB = await file.length() / (1024 * 1024);
      if (sizeMB > maxSizeMB) {
        throw Exception('Each image must be less than $maxSizeMB MB.');
      }
    }
    return picked.map((e) => e.path).toList();
  }

  static Future<List<String>> uploadImages(List<String> paths, String siteId) async {
    final supabase = Supabase.instance.client;
    List<String> urls = [];
    for (final path in paths) {
      final file = File(path);
      final fileName = path.split('/').last;
      final storagePath = 'sites/$siteId/$fileName';
      await supabase.storage.from('site-photos').upload(storagePath, file);
      final url = supabase.storage.from('site-photos').getPublicUrl(storagePath);
      urls.add(url);
    }
    return urls;
  }

  Future<List<String>> pickImagesDesktop() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) {
      throw Exception('No images selected');
    }
    return result.paths.whereType<String>().toList();
  }
}
