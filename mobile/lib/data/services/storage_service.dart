import 'dart:convert';
import 'dart:io';

import 'supabase_service.dart';

/// Uploads files (audio, covers) to Cloudflare R2 without ever holding
/// R2 secret keys on-device: it asks the `get-upload-url` Supabase Edge
/// Function for a short-lived presigned PUT URL, then uploads directly
/// to R2 with that URL.
class StorageService {
  StorageService._();

  static Future<String> upload({
    required String bucketPath,
    required File file,
    required String contentType,
  }) async {
    final presigned = await _requestPresignedUrl(
      bucketPath: bucketPath,
      contentType: contentType,
    );

    final request = await HttpClient().putUrl(Uri.parse(presigned.uploadUrl));
    request.headers.set(HttpHeaders.contentTypeHeader, contentType);
    request.contentLength = await file.length();
    await request.addStream(file.openRead());
    final response = await request.close();

    if (response.statusCode >= 400) {
      throw Exception('R2 upload failed with status ${response.statusCode}');
    }

    return presigned.publicUrl;
  }

  static Future<_PresignedUpload> _requestPresignedUrl({
    required String bucketPath,
    required String contentType,
  }) async {
    final response = await SupabaseService.client.functions.invoke(
      'get-upload-url',
      body: {'path': bucketPath, 'contentType': contentType},
    );

    if (response.status >= 400) {
      throw Exception('get-upload-url failed with status ${response.status}');
    }

    final data = response.data is String
        ? jsonDecode(response.data as String)
        : response.data as Map<String, dynamic>;

    return _PresignedUpload(
      uploadUrl: data['uploadUrl'] as String,
      publicUrl: data['publicUrl'] as String,
    );
  }
}

class _PresignedUpload {
  const _PresignedUpload({required this.uploadUrl, required this.publicUrl});

  final String uploadUrl;
  final String publicUrl;
}
