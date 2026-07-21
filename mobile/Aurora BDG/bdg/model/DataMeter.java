package com.aurora.bdg.model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

/* JADX INFO: loaded from: classes.dex */
public class DataMeter {

    @SerializedName("alamat")
    @Expose
    private String alamat;

    @SerializedName("bill_al_code")
    @Expose
    private String billAlCode;

    @SerializedName("bill_alname")
    @Expose
    private String billAlname;

    @SerializedName("bill_bl_id")
    @Expose
    private String billBlId;

    @SerializedName("bill_id")
    @Expose
    private String billId;

    @SerializedName("bill_isupload")
    @Expose
    private String billIsUpload;

    @SerializedName("bill_isrequest")
    @Expose
    private String billIsrequest;

    @SerializedName("bill_kd_wmsizeid")
    @Expose
    private String billKdWmsizeid;

    @SerializedName("bill_longlat")
    @Expose
    private String billLonglat;

    @SerializedName("bill_mperiod")
    @Expose
    private String billMperiod;

    @SerializedName("bill_nohp")
    @Expose
    private String billNohp;

    @SerializedName("bill_nourutrute")
    @Expose
    private String billNourutrute;

    @SerializedName("bill_of_id")
    @Expose
    private String billOfId;

    @SerializedName("bill_pakai")
    @Expose
    private String billPakai;

    @SerializedName("bill_rgn_id")
    @Expose
    private String billRgnId;

    @SerializedName("bill_stand1")
    @Expose
    private String billStand1;

    @SerializedName("bill_stand2")
    @Expose
    private String billStand2;

    @SerializedName("bill_uangadm")
    @Expose
    private String billUangadm;

    @SerializedName("bill_uangair")
    @Expose
    private String billUangair;

    @SerializedName("bill_uangtax")
    @Expose
    private String billUangtax;

    @SerializedName("bill_wr_username")
    @Expose
    private String billWrUsername;

    @SerializedName("bill_yperiod")
    @Expose
    private String billYperiod;

    @SerializedName("bill_issegel")
    @Expose
    private String bill_issegel;

    @SerializedName("bill_longlatcatat")
    @Expose
    private String bill_longlatcatat;

    @SerializedName("bill_perubahan")
    @Expose
    private String bill_perubahan;

    @SerializedName("bill_reqnourutbaru")
    @Expose
    private String bill_reqnourutbaru;

    @SerializedName("cust_code")
    @Expose
    private String custCode;

    @SerializedName("cust_code123")
    @Expose
    private String custCode123;

    @SerializedName("cust_id")
    @Expose
    private String custId;

    @SerializedName("cust_name")
    @Expose
    private String custName;
    private Long id;

    @SerializedName("marginMeter")
    @Expose
    private String marginMeter;

    @SerializedName("param1")
    @Expose
    private String param1;

    @SerializedName("param2")
    @Expose
    private String param2;

    @SerializedName("period1")
    @Expose
    private String period1;

    @SerializedName("period1_stand1")
    @Expose
    private String period1Stand1;

    @SerializedName("period1_stand2")
    @Expose
    private String period1Stand2;

    @SerializedName("period1_tagihan")
    @Expose
    private String period1Tagihan;

    @SerializedName("period1_usage")
    @Expose
    private String period1Usage;

    @SerializedName("period2")
    @Expose
    private String period2;

    @SerializedName("period2_stand1")
    @Expose
    private String period2Stand1;

    @SerializedName("period2_stand2")
    @Expose
    private String period2Stand2;

    @SerializedName("period2_tagihan")
    @Expose
    private String period2Tagihan;

    @SerializedName("period2_usage")
    @Expose
    private String period2Usage;

    @SerializedName("period3")
    @Expose
    private String period3;

    @SerializedName("period3_stand1")
    @Expose
    private String period3Stand1;

    @SerializedName("period3_stand2")
    @Expose
    private String period3Stand2;

    @SerializedName("period3_tagihan")
    @Expose
    private String period3Tagihan;

    @SerializedName("period3_usage")
    @Expose
    private String period3Usage;

    @SerializedName("status_catat")
    @Expose
    private String statusCatat;

    @SerializedName("tarif")
    @Expose
    private String tarif;

    @SerializedName("tgl_catat")
    @Expose
    private String tglCatat;

    @SerializedName("date_time_baca_prev")
    @Expose
    private String waktuCatat;

    @SerializedName("writer_id")
    @Expose
    private String writerId;

    public DataMeter() {
    }

    public DataMeter(Long l, String str, String str2, String str3, String str4, String str5, String str6, String str7, String str8, String str9, String str10, String str11, String str12, String str13, String str14, String str15, String str16, String str17, String str18, String str19, String str20, String str21, String str22, String str23, String str24, String str25, String str26, String str27, String str28, String str29, String str30, String str31, String str32, String str33, String str34, String str35, String str36, String str37, String str38, String str39, String str40, String str41, String str42, String str43, String str44, String str45, String str46, String str47, String str48, String str49, String str50, String str51, String str52, String str53) {
        this.id = l;
        this.writerId = str;
        this.billId = str2;
        this.tglCatat = str3;
        this.waktuCatat = str4;
        this.billMperiod = str5;
        this.billYperiod = str6;
        this.custId = str7;
        this.custCode = str8;
        this.custCode123 = str9;
        this.custName = str10;
        this.alamat = str11;
        this.billLonglat = str12;
        this.billKdWmsizeid = str13;
        this.tarif = str14;
        this.billNourutrute = str15;
        this.billStand1 = str16;
        this.billStand2 = str17;
        this.billPakai = str18;
        this.billUangair = str19;
        this.billUangadm = str20;
        this.billUangtax = str21;
        this.billOfId = str22;
        this.billRgnId = str23;
        this.billBlId = str24;
        this.billAlCode = str25;
        this.billAlname = str26;
        this.billWrUsername = str27;
        this.period1 = str28;
        this.period1Stand1 = str29;
        this.period1Stand2 = str30;
        this.period1Usage = str31;
        this.period1Tagihan = str32;
        this.period2 = str33;
        this.period2Stand1 = str34;
        this.period2Stand2 = str35;
        this.period2Usage = str36;
        this.period2Tagihan = str37;
        this.period3 = str38;
        this.period3Stand1 = str39;
        this.period3Stand2 = str40;
        this.period3Usage = str41;
        this.period3Tagihan = str42;
        this.billIsrequest = str43;
        this.billIsUpload = str44;
        this.bill_issegel = str45;
        this.bill_perubahan = str46;
        this.billNohp = str47;
        this.statusCatat = str48;
        this.bill_reqnourutbaru = str49;
        this.bill_longlatcatat = str50;
        this.param1 = str51;
        this.param2 = str52;
        this.marginMeter = str53;
    }

    public Long getId() {
        return this.id;
    }

    public void setId(Long l) {
        this.id = l;
    }

    public String getWriterId() {
        return this.writerId;
    }

    public void setWriterId(String str) {
        this.writerId = str;
    }

    public String getBillId() {
        return this.billId;
    }

    public void setBillId(String str) {
        this.billId = str;
    }

    public String getTglCatat() {
        return this.tglCatat;
    }

    public void setTglCatat(String str) {
        this.tglCatat = str;
    }

    public String getWaktuCatat() {
        return this.waktuCatat;
    }

    public void setWaktuCatat(String str) {
        this.waktuCatat = str;
    }

    public String getBillMperiod() {
        return this.billMperiod;
    }

    public void setBillMperiod(String str) {
        this.billMperiod = str;
    }

    public String getBillYperiod() {
        return this.billYperiod;
    }

    public void setBillYperiod(String str) {
        this.billYperiod = str;
    }

    public String getCustId() {
        return this.custId;
    }

    public void setCustId(String str) {
        this.custId = str;
    }

    public String getCustCode() {
        return this.custCode;
    }

    public void setCustCode(String str) {
        this.custCode = str;
    }

    public String getCustCode123() {
        return this.custCode123;
    }

    public void setCustCode123(String str) {
        this.custCode123 = str;
    }

    public String getCustName() {
        return this.custName;
    }

    public void setCustName(String str) {
        this.custName = str;
    }

    public String getAlamat() {
        return this.alamat;
    }

    public void setAlamat(String str) {
        this.alamat = str;
    }

    public String getBillLonglat() {
        return this.billLonglat;
    }

    public void setBillLonglat(String str) {
        this.billLonglat = str;
    }

    public String getBillKdWmsizeid() {
        return this.billKdWmsizeid;
    }

    public void setBillKdWmsizeid(String str) {
        this.billKdWmsizeid = str;
    }

    public String getTarif() {
        return this.tarif;
    }

    public void setTarif(String str) {
        this.tarif = str;
    }

    public String getBillNourutrute() {
        return this.billNourutrute;
    }

    public void setBillNourutrute(String str) {
        this.billNourutrute = str;
    }

    public String getBillStand1() {
        return this.billStand1;
    }

    public void setBillStand1(String str) {
        this.billStand1 = str;
    }

    public String getBillStand2() {
        return this.billStand2;
    }

    public void setBillStand2(String str) {
        this.billStand2 = str;
    }

    public String getBillPakai() {
        return this.billPakai;
    }

    public void setBillPakai(String str) {
        this.billPakai = str;
    }

    public String getBillUangair() {
        return this.billUangair;
    }

    public void setBillUangair(String str) {
        this.billUangair = str;
    }

    public String getBillUangadm() {
        return this.billUangadm;
    }

    public void setBillUangadm(String str) {
        this.billUangadm = str;
    }

    public String getBillUangtax() {
        return this.billUangtax;
    }

    public void setBillUangtax(String str) {
        this.billUangtax = str;
    }

    public String getBillOfId() {
        return this.billOfId;
    }

    public void setBillOfId(String str) {
        this.billOfId = str;
    }

    public String getBillRgnId() {
        return this.billRgnId;
    }

    public void setBillRgnId(String str) {
        this.billRgnId = str;
    }

    public String getBillBlId() {
        return this.billBlId;
    }

    public void setBillBlId(String str) {
        this.billBlId = str;
    }

    public String getBillAlCode() {
        return this.billAlCode;
    }

    public void setBillAlCode(String str) {
        this.billAlCode = str;
    }

    public String getBillAlname() {
        return this.billAlname;
    }

    public void setBillAlname(String str) {
        this.billAlname = str;
    }

    public String getBillWrUsername() {
        return this.billWrUsername;
    }

    public void setBillWrUsername(String str) {
        this.billWrUsername = str;
    }

    public String getPeriod1() {
        return this.period1;
    }

    public void setPeriod1(String str) {
        this.period1 = str;
    }

    public String getPeriod1Stand1() {
        return this.period1Stand1;
    }

    public void setPeriod1Stand1(String str) {
        this.period1Stand1 = str;
    }

    public String getPeriod1Stand2() {
        return this.period1Stand2;
    }

    public void setPeriod1Stand2(String str) {
        this.period1Stand2 = str;
    }

    public String getPeriod1Usage() {
        return this.period1Usage;
    }

    public void setPeriod1Usage(String str) {
        this.period1Usage = str;
    }

    public String getPeriod1Tagihan() {
        return this.period1Tagihan;
    }

    public void setPeriod1Tagihan(String str) {
        this.period1Tagihan = str;
    }

    public String getPeriod2() {
        return this.period2;
    }

    public void setPeriod2(String str) {
        this.period2 = str;
    }

    public String getPeriod2Stand1() {
        return this.period2Stand1;
    }

    public void setPeriod2Stand1(String str) {
        this.period2Stand1 = str;
    }

    public String getPeriod2Stand2() {
        return this.period2Stand2;
    }

    public void setPeriod2Stand2(String str) {
        this.period2Stand2 = str;
    }

    public String getPeriod2Usage() {
        return this.period2Usage;
    }

    public void setPeriod2Usage(String str) {
        this.period2Usage = str;
    }

    public String getPeriod2Tagihan() {
        return this.period2Tagihan;
    }

    public void setPeriod2Tagihan(String str) {
        this.period2Tagihan = str;
    }

    public String getPeriod3() {
        return this.period3;
    }

    public void setPeriod3(String str) {
        this.period3 = str;
    }

    public String getPeriod3Stand1() {
        return this.period3Stand1;
    }

    public void setPeriod3Stand1(String str) {
        this.period3Stand1 = str;
    }

    public String getPeriod3Stand2() {
        return this.period3Stand2;
    }

    public void setPeriod3Stand2(String str) {
        this.period3Stand2 = str;
    }

    public String getPeriod3Usage() {
        return this.period3Usage;
    }

    public void setPeriod3Usage(String str) {
        this.period3Usage = str;
    }

    public String getPeriod3Tagihan() {
        return this.period3Tagihan;
    }

    public void setPeriod3Tagihan(String str) {
        this.period3Tagihan = str;
    }

    public String getBillIsrequest() {
        return this.billIsrequest;
    }

    public void setBillIsrequest(String str) {
        this.billIsrequest = str;
    }

    public String getBillIsUpload() {
        return this.billIsUpload;
    }

    public void setBillIsUpload(String str) {
        this.billIsUpload = str;
    }

    public String getBill_issegel() {
        return this.bill_issegel;
    }

    public void setBill_issegel(String str) {
        this.bill_issegel = str;
    }

    public String getBill_perubahan() {
        return this.bill_perubahan;
    }

    public void setBill_perubahan(String str) {
        this.bill_perubahan = str;
    }

    public String getBillNohp() {
        return this.billNohp;
    }

    public void setBillNohp(String str) {
        this.billNohp = str;
    }

    public String getStatusCatat() {
        return this.statusCatat;
    }

    public void setStatusCatat(String str) {
        this.statusCatat = str;
    }

    public String getBill_reqnourutbaru() {
        return this.bill_reqnourutbaru;
    }

    public void setBill_reqnourutbaru(String str) {
        this.bill_reqnourutbaru = str;
    }

    public String getBill_longlatcatat() {
        return this.bill_longlatcatat;
    }

    public void setBill_longlatcatat(String str) {
        this.bill_longlatcatat = str;
    }

    public String getParam1() {
        return this.param1;
    }

    public void setParam1(String str) {
        this.param1 = str;
    }

    public String getParam2() {
        return this.param2;
    }

    public void setParam2(String str) {
        this.param2 = str;
    }

    public String getMarginMeter() {
        return this.marginMeter;
    }

    public void setMarginMeter(String str) {
        this.marginMeter = str;
    }
}
