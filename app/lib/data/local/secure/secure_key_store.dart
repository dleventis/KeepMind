import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper around [FlutterSecureStorage] — Keychain on iOS,
/// Keystore-backed encrypted storage on Android. This is the ONLY class
/// in the app allowed to touch raw secret values (the database encryption
/// key, and BYOK provider API keys). See docs/SECURITY.md.
///
/// Deliberately not a singleton holding decrypted values in memory beyond
/// a single call — every read goes back to secure storage.
///
/// No `AndroidOptions(encryptedSharedPreferences: true)`: that parameter
/// was deprecated in flutter_secure_storage 10 (the Jetpack Crypto
/// library it relied on was itself deprecated) and **removed** in 11.
/// The v11 default already uses modern ciphers, so the plain constructor
/// is both correct and stronger than the old opt-in.
class SecureKeyStore {
  SecureKeyStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

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
