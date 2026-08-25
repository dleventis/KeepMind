/// Application-level error types (brief section 33). Every error carries a
/// technical [debugMessage] for logs and a [userMessage] safe to show
/// directly to a non-technical user — provider/HTTP errors are translated
/// here, never surfaced raw (e.g. an HTTP 429 becomes a plain-language
/// "temporarily reached its usage limit", not the raw status code).
///
/// CRITICAL: no subclass may ever embed a secret (API key, token) in either
/// message. Callers constructing these from provider responses must strip
/// credentials before they reach this layer.
sealed class AppError implements Exception {
  const AppError({required this.userMessage, required this.debugMessage});

  final String userMessage;
  final String debugMessage;

  @override
  String toString() => 'AppError: $debugMessage';
}

class NetworkError extends AppError {
  const NetworkError({String? debugMessage})
    : super(
        userMessage:
            "Couldn't connect. Check your internet connection and try again.",
        debugMessage: debugMessage ?? 'Network request failed',
      );
}

class ProviderAuthenticationError extends AppError {
  const ProviderAuthenticationError({required String providerId})
    : super(
        userMessage:
            'Your AI provider rejected the connection. Check your API key in Settings.',
        debugMessage: 'Authentication failed for provider: $providerId',
      );
}

class ProviderQuotaError extends AppError {
  const ProviderQuotaError({required String providerId})
    : super(
        userMessage:
            'Your AI provider has temporarily reached its usage limit. Try again later.',
        debugMessage: 'Quota/rate-limit hit for provider: $providerId',
      );
}

class OCRFailure extends AppError {
  const OCRFailure({String? debugMessage})
    : super(
        userMessage:
            "Couldn't read that image clearly. Try retaking the photo with better lighting.",
        debugMessage: debugMessage ?? 'OCR pipeline failed',
      );
}

class InvalidAIResponse extends AppError {
  const InvalidAIResponse({required String providerId, String? reason})
    : super(
        userMessage:
            "The AI provider's response didn't look right, so nothing was saved automatically. You can enter the details manually.",
        debugMessage:
            'Invalid/unparseable structured response from $providerId'
            '${reason != null ? ': $reason' : ''}',
      );
}

class StorageError extends AppError {
  const StorageError({String? debugMessage})
    : super(
        userMessage: "Couldn't save that. Please try again.",
        debugMessage: debugMessage ?? 'Local storage operation failed',
      );
}

class PermissionError extends AppError {
  const PermissionError({required String permission})
    : super(
        userMessage:
            'Mindkeep needs permission to do that. You can grant it in Settings.',
        debugMessage: 'Permission denied: $permission',
      );
}

class NotificationPermissionError extends AppError {
  const NotificationPermissionError()
    : super(
        userMessage:
            "Mindkeep can't remind you without notification permission. "
            'You can enable it in Settings.',
        debugMessage: 'Notification permission denied',
      );
}
