import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/api_constants.dart';

/// Image storage service using ImgBB API
class StorageService {
  final Dio _dio;

  StorageService({Dio? dio}) : _dio = dio ?? Dio();

  String get _apiKey => dotenv.env[ApiConstants.imgbbApiKeyKey] ?? '';

  /// Upload an image file to ImgBB
  /// Returns the URL of the uploaded image
  Future<String> uploadImage(File file, {int? expiration}) async {
    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);

    final queryParams = <String, dynamic>{
      'key': _apiKey,
    };
    if (expiration != null) {
      queryParams['expiration'] = expiration;
    }

    final response = await _dio.post(
      ApiConstants.imgbbUploadUrl,
      queryParameters: queryParams,
      data: FormData.fromMap({
        'image': base64Image,
      }),
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data']['url'] as String;
    }

    throw StorageException('Gagal mengupload gambar');
  }

  /// Upload image from XFile (image_picker result)
  Future<String> uploadXFile(XFile xFile, {int? expiration}) async {
    final file = File(xFile.path);
    return uploadImage(file, expiration: expiration);
  }

  /// Upload multiple images
  Future<List<String>> uploadMultiple(List<File> files) async {
    final urls = <String>[];
    for (final file in files) {
      final url = await uploadImage(file);
      urls.add(url);
    }
    return urls;
  }

  /// Pick and upload image from gallery
  Future<String?> pickAndUploadFromGallery() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (xFile == null) return null;
    return uploadXFile(xFile);
  }

  /// Pick and upload image from camera
  Future<String?> pickAndUploadFromCamera() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (xFile == null) return null;
    return uploadXFile(xFile);
  }
}

class StorageException implements Exception {
  final String message;
  const StorageException(this.message);

  @override
  String toString() => message;
}
