// lib/core/models/update_info.dart
//
// Respuesta cruda de ApiConstants.urlVersionCheck — JSON servido por un
// archivo estático (natcodee.net), no por el backend del CRM:
//   { "Version": "1.0.4", "DownloadUrl": "https://...apk", "ReleaseDate": "..." }

class UpdateInfo {
  final String version;
  final String downloadUrl;
  final String releaseDate;

  const UpdateInfo({
    required this.version,
    required this.downloadUrl,
    required this.releaseDate,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) => UpdateInfo(
    version: (json['Version'] as String?)?.trim() ?? '',
    downloadUrl: (json['DownloadUrl'] as String?)?.trim() ?? '',
    releaseDate: (json['ReleaseDate'] as String?)?.trim() ?? '',
  );
}
