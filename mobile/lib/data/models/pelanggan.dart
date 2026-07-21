import 'json_utils.dart';

/// Ringkasan pelanggan untuk daftar/pencarian di aplikasi petugas —
/// di aplikasi lama ini model lokal (hasil query SQLite), bukan payload API.
/// Kunci JSON di bawah untuk cache lokal.
class Pelanggan {
  const Pelanggan({
    this.custId,
    this.billId,
    this.custCode,
    this.custCode123,
    this.custName,
    this.alamat,
    this.billBlId,
    this.billDate,
    this.billDate1,
    this.billStand1,
    this.billStand2,
    this.tarif,
    this.billLonglat,
    this.billNoUrutRute,
    this.billKdWmsizeid,
    this.billIsRequest,
    this.noHp,
    this.wmsn,
    this.waktuCatat,
    this.latLong,
    this.isUpload,
  });

  final String? custId;
  final String? billId;
  final String? custCode;
  final String? custCode123;
  final String? custName;
  final String? alamat;
  final String? billBlId;
  final String? billDate;
  final String? billDate1;
  final String? billStand1;
  final String? billStand2;
  final String? tarif;
  final String? billLonglat;
  final String? billNoUrutRute;
  final String? billKdWmsizeid;
  final String? billIsRequest;
  final String? noHp;
  final String? wmsn;
  final String? waktuCatat;
  final String? latLong;
  final String? isUpload;

  factory Pelanggan.fromJson(Map<String, dynamic> json) => Pelanggan(
    custId: asString(json['custId']),
    billId: asString(json['billId']),
    custCode: asString(json['custCode']),
    custCode123: asString(json['custCode123']),
    custName: asString(json['custName']),
    alamat: asString(json['alamat']),
    billBlId: asString(json['billBlId']),
    billDate: asString(json['billDate']),
    billDate1: asString(json['billDate1']),
    billStand1: asString(json['billStand1']),
    billStand2: asString(json['billStand2']),
    tarif: asString(json['tarif']),
    billLonglat: asString(json['billLonglat']),
    billNoUrutRute: asString(json['billNoUrutRute']),
    billKdWmsizeid: asString(json['billKdWmsizeid']),
    billIsRequest: asString(json['billIsRequest']),
    noHp: asString(json['noHp']),
    wmsn: asString(json['wmsn']),
    waktuCatat: asString(json['waktuCatat']),
    latLong: asString(json['latLong']),
    isUpload: asString(json['isUpload']),
  );

  Map<String, dynamic> toJson() => {
    'custId': custId,
    'billId': billId,
    'custCode': custCode,
    'custCode123': custCode123,
    'custName': custName,
    'alamat': alamat,
    'billBlId': billBlId,
    'billDate': billDate,
    'billDate1': billDate1,
    'billStand1': billStand1,
    'billStand2': billStand2,
    'tarif': tarif,
    'billLonglat': billLonglat,
    'billNoUrutRute': billNoUrutRute,
    'billKdWmsizeid': billKdWmsizeid,
    'billIsRequest': billIsRequest,
    'noHp': noHp,
    'wmsn': wmsn,
    'waktuCatat': waktuCatat,
    'latLong': latLong,
    'isUpload': isUpload,
  };
}
