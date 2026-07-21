import 'json_utils.dart';

/// Golongan tarif dari `GET aurora_api/dev/download_tarif.php`.
/// (Kolom `id` greenDAO lokal di aplikasi lama sengaja tidak dibawa —
/// itu primary key database on-device, bukan bagian kontrak API.)
class Tarif {
  const Tarif({
    this.trfId,
    this.trfCode,
    this.trfName,
    this.trfInit,
    this.trfAdm,
  });

  final String? trfId;
  final String? trfCode;
  final String? trfName;
  final String? trfInit;

  /// Biaya administrasi golongan tarif ini.
  final String? trfAdm;

  factory Tarif.fromJson(Map<String, dynamic> json) => Tarif(
    trfId: asString(json['trf_id']),
    trfCode: asString(json['trf_code']),
    trfName: asString(json['trf_name']),
    trfInit: asString(json['trf_init']),
    trfAdm: asString(json['trf_adm']),
  );

  Map<String, dynamic> toJson() => {
    'trf_id': trfId,
    'trf_code': trfCode,
    'trf_name': trfName,
    'trf_init': trfInit,
    'trf_adm': trfAdm,
  };
}
