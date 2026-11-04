enum UpdatePlatform {
  android('pollar-android.apk'),
  windows('pollar-windows.zip');

  const UpdatePlatform(this.assetName);
  final String assetName;
}

class AppVersion implements Comparable<AppVersion> {
  const AppVersion(this.name, this.build);
  final String name;
  final int build;

  static AppVersion? parse(String value) {
    final match = RegExp(r'^v?(\d+\.\d+\.\d+)\+(\d+)$').firstMatch(value);
    if (match == null) return null;
    return AppVersion(match[1]!, int.parse(match[2]!));
  }

  @override
  int compareTo(AppVersion other) {
    final ours = name.split('.').map(int.parse).toList();
    final theirs = other.name.split('.').map(int.parse).toList();
    for (var i = 0; i < 3; i++) {
      final comparison = ours[i].compareTo(theirs[i]);
      if (comparison != 0) return comparison;
    }
    return build.compareTo(other.build);
  }

  @override
  String toString() => '$name+$build';
}

class AppRelease {
  const AppRelease({
    required this.version,
    required this.platform,
    required this.downloadUrl,
    required this.sha256,
    required this.bytes,
  });

  final AppVersion version;
  final UpdatePlatform platform;
  final Uri downloadUrl;
  final String sha256;
  final int bytes;

  static AppRelease? fromGitHub(
    Map<String, dynamic> json,
    AppVersion installed,
    UpdatePlatform platform,
  ) {
    if (json['draft'] != false || json['prerelease'] != false) return null;
    final tag = json['tag_name'];
    if (tag is! String) return null;
    final version = AppVersion.parse(tag);
    if (version == null || version.compareTo(installed) <= 0) return null;
    final assets = json['assets'];
    if (assets is! List) return null;
    for (final asset in assets.whereType<Map<String, dynamic>>()) {
      if (asset['name'] != platform.assetName || asset['state'] != 'uploaded') {
        continue;
      }
      final digest = asset['digest'];
      final size = asset['size'];
      final url = Uri.tryParse(asset['browser_download_url'] as String? ?? '');
      final expectedPath =
          '/luaanwp/pollar/releases/download/$tag/${platform.assetName}';
      if (digest is! String ||
          !RegExp(r'^sha256:[a-fA-F0-9]{64}$').hasMatch(digest) ||
          size is! int ||
          size <= 0 ||
          size > 512 * 1024 * 1024 ||
          url == null ||
          url.scheme != 'https' ||
          url.host != 'github.com' ||
          url.port != 443 ||
          url.userInfo.isNotEmpty ||
          url.hasQuery ||
          url.hasFragment ||
          Uri.decodeComponent(url.path) != expectedPath) {
        throw const FormatException('Invalid update asset');
      }
      return AppRelease(
        version: version,
        platform: platform,
        downloadUrl: url,
        sha256: digest.substring(7).toLowerCase(),
        bytes: size,
      );
    }
    return null;
  }
}
