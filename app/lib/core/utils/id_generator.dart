import 'dart:math';

/// Generates opaque, unguessable local IDs (memory IDs, reminder IDs).
///
/// Deliberately hand-rolled instead of adding the `uuid` package: this
/// keeps the Phase A/B dependency surface to only what's already verified
/// against pub.dev (see docs/TECHNICAL_FOUNDATION_PLAN.md section 13). If
/// a real RFC-4122 UUID becomes genuinely necessary (e.g. for a future
/// sync/backend phase that expects standard UUIDs), swap this for the
/// `uuid` package then — this is not a hill to defend past Phase B.
class IdGenerator {
  IdGenerator._();

  static final Random _random = Random.secure();

  /// A 128-bit random ID, hex-encoded (32 chars). Collision probability is
  /// negligible for a single-user local database.
  static String generate() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
