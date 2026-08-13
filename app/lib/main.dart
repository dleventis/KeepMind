import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  // ProviderScope roots the Riverpod graph — repositories, the AI router,
  // and the database are all wired as providers under app_providers.dart
  // rather than constructed ad hoc in widgets.
  runApp(const ProviderScope(child: KeepMindApp()));
}
