import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper around [FlutterSecureStorage] — Keychain on iOS,
/// Keystore/EncryptedSharedPreferences on Android. This is the ONLY class
/// in the app allowed to touch raw secret values (the database encryption
/// key, and BYOK provider API keys). See docs/SECURITY.md.
///
/// Deliberately not a singleton holding decrypted values in memory beyond
/// a single call — every read goes back to secure storage.
class SecureKeyStore {
  SecureKeyStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  static const String _dbEncryptionKeyKey = 'keepmind.db_encryption_key';
  static String _providerApiKeyKey(String providerId) =>
      'keepmind.provider_api_key.$providerId';

  Future<String?> readDatabaseEncryptionKey() =>
      _storage.read(key: _dbEncryptionKeyKey);

  Future<void> writeDatabaseEncryptionKey(String key) =>
      _storage.write(key: _dbEncryptionKeyKey, value: key);

  Future<String?> readProviderApiKey(String providerId) =>
      _storage.read(key: _providerApiKeyKey(providerId));

  Future<void> writeProviderApiKey(String providerId, String apiKey) =>
      _storage.write(key: _providerApiKeyKey(providerId), value: apiKey);

  Future<void> deleteProviderApiKey(String providerId) =>
      _storage.delete(key: _providerApiKeyKey(providerId));
}
