import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase [LocalStorage] implementation backed by [FlutterSecureStorage].
///
/// Replaces the default SharedPreferences storage so auth tokens are encrypted
/// at rest on both Android (EncryptedSharedPreferences) and iOS (Keychain).
class SecureLocalStorage extends LocalStorage {
  static const _sessionKey = 'forja_supabase_session';

  final FlutterSecureStorage _storage;

  SecureLocalStorage()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        );

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() =>
      _storage.containsKey(key: _sessionKey);

  @override
  Future<String?> accessToken() =>
      _storage.read(key: _sessionKey);

  @override
  Future<void> persistSession(String persistSessionString) =>
      _storage.write(key: _sessionKey, value: persistSessionString);

  @override
  Future<void> removePersistedSession() =>
      _storage.delete(key: _sessionKey);
}
