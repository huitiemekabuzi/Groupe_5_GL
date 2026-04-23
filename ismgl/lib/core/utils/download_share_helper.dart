import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ismgl/core/services/api_service.dart';

/// Téléchargement de fichiers (octets) et partage sur l’appareil.
class DownloadShareHelper {
  DownloadShareHelper._();

  /// Extrait une URL ou un chemin relatif renvoyé par l’API d’export.
  static String? extractExportFileRef(dynamic data) {
    if (data == null) return null;
    if (data is String) return data.trim().isEmpty ? null : data.trim();
    if (data is Map) {
      final m = Map<String, dynamic>.from(data);
      for (final key in [
        'pdf_url',
        'file_url',
        'url',
        'fichier',
        'path',
        'download_url',
        'html_url',
        'file',
        'lien_fichier',
      ]) {
        final v = m[key]?.toString().trim();
        if (v != null && v.isNotEmpty) return v;
      }
    }
    return null;
  }

  static String exportFilename(String type, String format) {
    final t = type.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final ext = format.toLowerCase();
    return 'rapport_${t}_${DateTime.now().millisecondsSinceEpoch}.$ext';
  }

  /// Résout [ref] (URL absolue ou chemin) puis télécharge et ouvre le partage.
  static Future<bool> downloadExportAndShare(
    ApiService api,
    String ref,
    String filename,
  ) async {
    final url = api.resolvePublicUrl(ref);
    debugPrint('📥 Export: fetch $url');
    final bytes = await api.fetchBytesUri(url);
    if (bytes == null || bytes.isEmpty) {
      debugPrint('📥 Export: octets vides');
      return false;
    }
    return shareBytes(bytes, filename);
  }

  static Future<bool> shareBytes(Uint8List bytes, String filename) async {
    try {
      final dir = await getTemporaryDirectory();
      final safeName =
          filename.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final filePath = '${dir.path}/$safeName';
      await File(filePath).writeAsBytes(bytes, flush: true);
      await Share.shareXFiles(
        [XFile(filePath, mimeType: _guessMime(safeName))],
        text: safeName,
      );
      return true;
    } catch (e) {
      debugPrint('❌ shareBytes: $e');
      return false;
    }
  }

  static String? _guessMime(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.html') || lower.endsWith('.htm')) {
      return 'text/html';
    }
    if (lower.endsWith('.csv')) return 'text/csv';
    if (lower.endsWith('.xlsx')) {
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    }
    if (lower.endsWith('.xls')) return 'application/vnd.ms-excel';
    return null;
  }
}
