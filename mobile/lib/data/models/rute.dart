import 'json_utils.dart';

/// Progres pencatatan per rute (blok) — model lokal aplikasi petugas,
/// bukan payload API. Kunci JSON di bawah untuk cache lokal.
class Rute {
  const Rute({this.ruteId, this.aktif, this.read, this.unRead});

  final String? ruteId;
  final String? aktif;
  final String? read;
  final String? unRead;

  factory Rute.fromJson(Map<String, dynamic> json) => Rute(
    ruteId: asString(json['ruteId']),
    aktif: asString(json['aktif']),
    read: asString(json['read']),
    unRead: asString(json['unRead']),
  );

  Map<String, dynamic> toJson() => {
    'ruteId': ruteId,
    'aktif': aktif,
    'read': read,
    'unRead': unRead,
  };
}

/// Status upload per blok pada layar upload data — model lokal UI.
class RuteUpload {
  RuteUpload({
    this.nomor,
    this.blockId,
    this.blockName,
    this.blockCode,
    this.totalCatat,
    this.belumUpload,
    this.selected = false,
  });

  final int? nomor;
  final String? blockId;
  final String? blockName;
  final String? blockCode;
  final String? totalCatat;
  final String? belumUpload;

  /// Dicentang untuk ikut di-upload — state UI, boleh berubah.
  bool selected;

  factory RuteUpload.fromJson(Map<String, dynamic> json) => RuteUpload(
    nomor: asInt(json['nomor']),
    blockId: asString(json['blockId']),
    blockName: asString(json['blockName']),
    blockCode: asString(json['blockCode']),
    totalCatat: asString(json['totalCatat']),
    belumUpload: asString(json['belumUpload']),
    selected: json['selected'] == true,
  );

  Map<String, dynamic> toJson() => {
    'nomor': nomor,
    'blockId': blockId,
    'blockName': blockName,
    'blockCode': blockCode,
    'totalCatat': totalCatat,
    'belumUpload': belumUpload,
    'selected': selected,
  };
}
