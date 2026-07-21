import 'package:flutter/widgets.dart';

import 'app/bootstrap.dart';
import 'app/petugas_app.dart';
import 'app/publik_app.dart';

/// Entrypoint default (`flutter run` tanpa -t) — untuk pengembangan cepat.
/// Pilih aplikasi lewat dart-define: `--dart-define=APP=petugas` (default
/// publik). Build produksi memakai entrypoint eksplisit
/// `lib/main_publik.dart` / `lib/main_petugas.dart` + flavor Android.
Future<void> main() async {
  await bootstrap();
  const app = String.fromEnvironment('APP', defaultValue: 'publik');
  runApp(app == 'petugas' ? const PetugasApp() : const PublikApp());
}
