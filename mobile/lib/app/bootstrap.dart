import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shadcn_ui/shadcn_ui.dart' show Intl;

/// Inisialisasi bersama kedua aplikasi: format tanggal/uang Indonesia
/// (labelPeriode, formatRupiah) butuh data locale id_ID sebelum frame pertama.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'id_ID';
  await initializeDateFormatting('id_ID');
}
