import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/features/auth/data/supabase_auth_gateway.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  final now = DateTime.utc(2026, 9, 28, 12);

  test(
    'accepts a confirmed first-time email signup as a recent email code',
    () {
      expect(
        SupabaseAuthGateway.hasRecentEmailMethod([
          AMREntry(
            method: AMRMethod.emailSignUp,
            timestamp: now.subtract(const Duration(minutes: 1)),
          ),
        ], now: now),
        isTrue,
      );
    },
  );

  test('accepts existing OTP and magic-link sessions for ten days', () {
    for (final method in [AMRMethod.otp, AMRMethod.magiclink]) {
      expect(
        SupabaseAuthGateway.hasRecentEmailMethod([
          AMREntry(
            method: method,
            timestamp: now.subtract(const Duration(days: 10)),
          ),
        ], now: now),
        isTrue,
      );
    }
  });

  test('rejects an old email code or TOTP without a recent email code', () {
    expect(
      SupabaseAuthGateway.hasRecentEmailMethod([
        AMREntry(
          method: AMRMethod.emailSignUp,
          timestamp: now.subtract(const Duration(days: 11)),
        ),
        AMREntry(method: AMRMethod.totp, timestamp: now),
      ], now: now),
      isFalse,
    );
  });
}
