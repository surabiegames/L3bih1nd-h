import 'package:flutter/widgets.dart';

import 'app/bootstrap.dart';
import 'app/petugas_app.dart';

/// Entrypoint aplikasi PETUGAS.
/// Android: flutter run --flavor petugas -t lib/main_petugas.dart
Future<void> main() async {
  await bootstrap();
  runApp(const PetugasApp());
}
