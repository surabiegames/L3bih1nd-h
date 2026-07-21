import 'package:flutter/widgets.dart';

import 'app/bootstrap.dart';
import 'app/publik_app.dart';

/// Entrypoint aplikasi PUBLIK.
/// Android: flutter run --flavor publik -t lib/main_publik.dart
Future<void> main() async {
  await bootstrap();
  runApp(const PublikApp());
}
