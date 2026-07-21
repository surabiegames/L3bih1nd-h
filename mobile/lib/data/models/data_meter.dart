import 'json_utils.dart';

/// Satu baris data meter pelanggan dari
/// `GET aurora_api/dev/download_datameter.php?periode=yyyyMM&writer_id=...` —
/// model terbesar di API legacy: identitas pelanggan, tagihan periode
/// berjalan, riwayat 3 periode terakhir, dan status pencatatan lapangan.
///
/// `toJson` menghasilkan kunci persis seperti kontrak legacy sehingga bisa
/// dipakai ulang untuk membangun payload `usersJSON` saat upload
/// (`POST aurora_api/sync/dev_store_data.php`).
class DataMeter {
  const DataMeter({
    this.writerId,
    this.billId,
    this.tglCatat,
    this.waktuCatat,
    this.billMperiod,
    this.billYperiod,
    this.custId,
    this.custCode,
    this.custCode123,
    this.custName,
    this.alamat,
    this.billLonglat,
    this.billKdWmsizeid,
    this.tarif,
    this.billNourutrute,
    this.billStand1,
    this.billStand2,
    this.billPakai,
    this.billUangair,
    this.billUangadm,
    this.billUangtax,
    this.billOfId,
    this.billRgnId,
    this.billBlId,
    this.billAlCode,
    this.billAlname,
    this.billWrUsername,
    this.period1,
    this.period1Stand1,
    this.period1Stand2,
    this.period1Usage,
    this.period1Tagihan,
    this.period2,
    this.period2Stand1,
    this.period2Stand2,
    this.period2Usage,
    this.period2Tagihan,
    this.period3,
    this.period3Stand1,
    this.period3Stand2,
    this.period3Usage,
    this.period3Tagihan,
    this.billIsrequest,
    this.billIsUpload,
    this.billIssegel,
    this.billPerubahan,
    this.billNohp,
    this.statusCatat,
    this.billReqnourutbaru,
    this.billLonglatcatat,
    this.param1,
    this.param2,
    this.marginMeter,
  });

  final String? writerId;
  final String? billId;
  final String? tglCatat;

  /// Kunci JSON legacy-nya `date_time_baca_prev`.
  final String? waktuCatat;
  final String? billMperiod;
  final String? billYperiod;
  final String? custId;
  final String? custCode;
  final String? custCode123;
  final String? custName;
  final String? alamat;
  final String? billLonglat;
  final String? billKdWmsizeid;
  final String? tarif;
  final String? billNourutrute;
  final String? billStand1;
  final String? billStand2;
  final String? billPakai;
  final String? billUangair;
  final String? billUangadm;
  final String? billUangtax;
  final String? billOfId;
  final String? billRgnId;
  final String? billBlId;
  final String? billAlCode;
  final String? billAlname;
  final String? billWrUsername;
  final String? period1;
  final String? period1Stand1;
  final String? period1Stand2;
  final String? period1Usage;
  final String? period1Tagihan;
  final String? period2;
  final String? period2Stand1;
  final String? period2Stand2;
  final String? period2Usage;
  final String? period2Tagihan;
  final String? period3;
  final String? period3Stand1;
  final String? period3Stand2;
  final String? period3Usage;
  final String? period3Tagihan;
  final String? billIsrequest;
  final String? billIsUpload;
  final String? billIssegel;
  final String? billPerubahan;
  final String? billNohp;
  final String? statusCatat;
  final String? billReqnourutbaru;
  final String? billLonglatcatat;
  final String? param1;
  final String? param2;
  final String? marginMeter;

  factory DataMeter.fromJson(Map<String, dynamic> json) => DataMeter(
    writerId: asString(json['writer_id']),
    billId: asString(json['bill_id']),
    tglCatat: asString(json['tgl_catat']),
    waktuCatat: asString(json['date_time_baca_prev']),
    billMperiod: asString(json['bill_mperiod']),
    billYperiod: asString(json['bill_yperiod']),
    custId: asString(json['cust_id']),
    custCode: asString(json['cust_code']),
    custCode123: asString(json['cust_code123']),
    custName: asString(json['cust_name']),
    alamat: asString(json['alamat']),
    billLonglat: asString(json['bill_longlat']),
    billKdWmsizeid: asString(json['bill_kd_wmsizeid']),
    tarif: asString(json['tarif']),
    billNourutrute: asString(json['bill_nourutrute']),
    billStand1: asString(json['bill_stand1']),
    billStand2: asString(json['bill_stand2']),
    billPakai: asString(json['bill_pakai']),
    billUangair: asString(json['bill_uangair']),
    billUangadm: asString(json['bill_uangadm']),
    billUangtax: asString(json['bill_uangtax']),
    billOfId: asString(json['bill_of_id']),
    billRgnId: asString(json['bill_rgn_id']),
    billBlId: asString(json['bill_bl_id']),
    billAlCode: asString(json['bill_al_code']),
    billAlname: asString(json['bill_alname']),
    billWrUsername: asString(json['bill_wr_username']),
    period1: asString(json['period1']),
    period1Stand1: asString(json['period1_stand1']),
    period1Stand2: asString(json['period1_stand2']),
    period1Usage: asString(json['period1_usage']),
    period1Tagihan: asString(json['period1_tagihan']),
    period2: asString(json['period2']),
    period2Stand1: asString(json['period2_stand1']),
    period2Stand2: asString(json['period2_stand2']),
    period2Usage: asString(json['period2_usage']),
    period2Tagihan: asString(json['period2_tagihan']),
    period3: asString(json['period3']),
    period3Stand1: asString(json['period3_stand1']),
    period3Stand2: asString(json['period3_stand2']),
    period3Usage: asString(json['period3_usage']),
    period3Tagihan: asString(json['period3_tagihan']),
    billIsrequest: asString(json['bill_isrequest']),
    billIsUpload: asString(json['bill_isupload']),
    billIssegel: asString(json['bill_issegel']),
    billPerubahan: asString(json['bill_perubahan']),
    billNohp: asString(json['bill_nohp']),
    statusCatat: asString(json['status_catat']),
    billReqnourutbaru: asString(json['bill_reqnourutbaru']),
    billLonglatcatat: asString(json['bill_longlatcatat']),
    param1: asString(json['param1']),
    param2: asString(json['param2']),
    marginMeter: asString(json['marginMeter']),
  );

  Map<String, dynamic> toJson() => {
    'writer_id': writerId,
    'bill_id': billId,
    'tgl_catat': tglCatat,
    'date_time_baca_prev': waktuCatat,
    'bill_mperiod': billMperiod,
    'bill_yperiod': billYperiod,
    'cust_id': custId,
    'cust_code': custCode,
    'cust_code123': custCode123,
    'cust_name': custName,
    'alamat': alamat,
    'bill_longlat': billLonglat,
    'bill_kd_wmsizeid': billKdWmsizeid,
    'tarif': tarif,
    'bill_nourutrute': billNourutrute,
    'bill_stand1': billStand1,
    'bill_stand2': billStand2,
    'bill_pakai': billPakai,
    'bill_uangair': billUangair,
    'bill_uangadm': billUangadm,
    'bill_uangtax': billUangtax,
    'bill_of_id': billOfId,
    'bill_rgn_id': billRgnId,
    'bill_bl_id': billBlId,
    'bill_al_code': billAlCode,
    'bill_alname': billAlname,
    'bill_wr_username': billWrUsername,
    'period1': period1,
    'period1_stand1': period1Stand1,
    'period1_stand2': period1Stand2,
    'period1_usage': period1Usage,
    'period1_tagihan': period1Tagihan,
    'period2': period2,
    'period2_stand1': period2Stand1,
    'period2_stand2': period2Stand2,
    'period2_usage': period2Usage,
    'period2_tagihan': period2Tagihan,
    'period3': period3,
    'period3_stand1': period3Stand1,
    'period3_stand2': period3Stand2,
    'period3_usage': period3Usage,
    'period3_tagihan': period3Tagihan,
    'bill_isrequest': billIsrequest,
    'bill_isupload': billIsUpload,
    'bill_issegel': billIssegel,
    'bill_perubahan': billPerubahan,
    'bill_nohp': billNohp,
    'status_catat': statusCatat,
    'bill_reqnourutbaru': billReqnourutbaru,
    'bill_longlatcatat': billLonglatcatat,
    'param1': param1,
    'param2': param2,
    'marginMeter': marginMeter,
  };
}
