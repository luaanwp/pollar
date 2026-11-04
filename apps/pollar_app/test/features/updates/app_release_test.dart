import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/features/updates/domain/app_release.dart';

void main() {
  const current = AppVersion('1.0.0', 10);
  Map<String, dynamic> release({
    String tag = 'v1.0.0+1001',
    String? url,
    String? digest,
  }) => {
    'tag_name': tag,
    'draft': false,
    'prerelease': false,
    'assets': [
      {
        'name': 'pollar-android.apk',
        'state': 'uploaded',
        'size': 123,
        'digest': digest ?? 'sha256:${'a' * 64}',
        'browser_download_url':
            url ??
            'https://github.com/luaanwp/pollar/releases/download/$tag/pollar-android.apk',
      },
    ],
  };
  test('versions compare numeric components and build without downgrades', () {
    expect(AppVersion.parse('v1.0.0+1001')!.compareTo(current), greaterThan(0));
    expect(const AppVersion('1.0.0', 9).compareTo(current), lessThan(0));
    expect(const AppVersion('1.0.0', 10).compareTo(current), 0);
    expect(const AppVersion('1.0.1', 1).compareTo(current), greaterThan(0));
    expect(const AppVersion('0.9.9', 9999).compareTo(current), lessThan(0));
    expect(AppVersion.parse('1.0.0-beta+1002'), isNull);
  });
  test('selects uploaded asset for this platform and accepts encoded tag', () {
    final result = AppRelease.fromGitHub(
      release(
        url: 'https://github.com/luaanwp/pollar/releases/download/v1.0.0%2B1001/pollar-android.apk',
      ),
      current,
      UpdatePlatform.android,
    )!;
    expect(result.version.build, 1001);
    expect(result.bytes, 123);
    expect(result.sha256, 'a' * 64);
    expect(
      AppRelease.fromGitHub(release(), current, UpdatePlatform.windows),
      isNull,
    );
  });
  test('ignores drafts, prereleases, equal and older releases', () {
    for (final json in [
      release()..['draft'] = true,
      release()..['prerelease'] = true,
      release(tag: 'v1.0.0+10'),
      release(tag: 'v1.0.0+9'),
      release(tag: 'v0.9.0+9999'),
    ]) {
      expect(
        AppRelease.fromGitHub(json, current, UpdatePlatform.android),
        isNull,
      );
    }
  });
  test(
    'rejects missing integrity, foreign hosts/repos and mismatched assets',
    () {
      for (final json in [
        release(digest: ''),
        release(digest: 'sha256:123'),
        release(
          url: 'http://github.com/luaanwp/pollar/releases/download/v1.0.0+1001/pollar-android.apk',
        ),
        release(
          url: 'https://github.com/other/repo/releases/download/v1.0.0+1001/pollar-android.apk',
        ),
        release(
          url: 'https://evil.example/luaanwp/pollar/releases/download/v1.0.0+1001/pollar-android.apk',
        ),
        release(
          url: 'https://github.com/luaanwp/pollar/releases/download/v1.0.0+1000/pollar-android.apk',
        ),
        release()..['assets'][0]['size'] = 1024 * 1024 * 1024,
      ]) {
        expect(
          () => AppRelease.fromGitHub(json, current, UpdatePlatform.android),
          throwsFormatException,
        );
      }
    },
  );
}
