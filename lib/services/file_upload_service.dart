import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:mime/mime.dart';
import '../utils/app_theme.dart';

class FileUploadService {
  static final ImagePicker _imagePicker = ImagePicker();
  static const String baseUrl = 'http://10.26.147.150:6061/api/upload';

  /// Pick image from camera or gallery
  static Future<File?> pickImage(BuildContext context,
      {String title = 'Select Image'}) async {
    return showDialog<File?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.secondaryGray,
          title: Text(
            title,
            style: AppTheme.headingSmall,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading:
                    const Icon(Icons.camera_alt, color: AppTheme.accentGold),
                title: const Text('Take Photo', style: AppTheme.bodyMedium),
                onTap: () async {
                  final image = await _imagePicker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1024,
                    maxHeight: 1024,
                    imageQuality: 85,
                  );
                  Navigator.pop(
                      context, image != null ? File(image.path) : null);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: AppTheme.accentGold),
                title: const Text('Choose from Gallery',
                    style: AppTheme.bodyMedium),
                onTap: () async {
                  final image = await _imagePicker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1024,
                    maxHeight: 1024,
                    imageQuality: 85,
                  );
                  Navigator.pop(
                      context, image != null ? File(image.path) : null);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textGray)),
            ),
          ],
        );
      },
    );
  }

  /// Pick PDF file
  static Future<File?> pickPDF(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      _showErrorDialog(context, 'Error picking PDF file: $e');
      return null;
    }
  }

  Future<String> uploadFile(File file, String folder, String userId) async {
    try {
      // Construct full URL with folder
      final uploadUrl = Uri.parse('$baseUrl/$folder/$userId');

      final mimeType =
          lookupMimeType(file.path)?.split('/') ?? ['image', 'jpeg'];

      final request = http.MultipartRequest('POST', uploadUrl)
        ..files.add(
          http.MultipartFile(
            'file',
            file.readAsBytes().asStream(),
            file.lengthSync(),
            filename: basename(file.path),
            contentType: MediaType(mimeType[0], mimeType[1]),
          ),
        );

      final response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final respJson = jsonDecode(respStr);
        return respJson['filePath'];
      } else {
        throw Exception('File upload failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('File upload error: $e');
    }
  }

  /// Show error dialog
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.secondaryGray,
          title: const Text('Error', style: AppTheme.headingSmall),
          content: Text(message, style: AppTheme.bodyMedium),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK',
                  style: TextStyle(color: AppTheme.accentGold)),
            ),
          ],
        );
      },
    );
  }

  /// Get file size in readable format
  static String getFileSize(File file) {
    int bytes = file.lengthSync();
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = (bytes.bitLength - 1) ~/ 10;
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(1)} ${suffixes[i]}';
  }

  /// Get file name from path
  static String getFileName(String path) {
    return path.split('/').last;
  }
}
