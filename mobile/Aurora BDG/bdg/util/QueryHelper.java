package com.aurora.bdg.util;

/* JADX INFO: loaded from: classes.dex */
public class QueryHelper {
    public String daftarRute(String str, String str2, String str3) {
        return "SELECT T.bill_bl_id, (Select count(*) from DATA_METER where bill_mperiod=" + str3 + " and bill_yperiod=" + str2 + "  and bill_bl_id=T.bill_bl_id) as aktif, (Select count(*) from DATA_METER where (bill_stand2<>'' or TGL_CATAT<>'') and bill_mperiod=" + str3 + " and bill_yperiod=" + str2 + "  and bill_bl_id=T.bill_bl_id) as read,  (Select count(1) from DATA_METER where bill_stand2='' and TGL_CATAT='' and bill_mperiod=" + str3 + " and bill_yperiod=" + str2 + "  and bill_bl_id=T.bill_bl_id) as unread  from  DATA_METER T where T.bill_wr_username='" + str + "' GROUP BY T.bill_bl_id order by T.bill_bl_id";
    }

    public String daftarPelangganRead(String str, String str2, String str3, String str4) {
        return "SELECT T.BILL_ID, T.CUST_CODE, T.CUST_CODE123, T.CUST_NAME, T.ALAMAT, ifnull(T.TGL_CATAT,'') bill_date,ifnull(T.bill_stand1,'') bill_stand1, ifnull(T.bill_stand2,'') bill_stand2, T.TARIF, T.bill_longlat, ifnull(T.TGL_CATAT,'Tidak diketahui') bill_date FROM DATA_METER T WHERE T.bill_mperiod=" + str4 + " and T.bill_yperiod=" + str3 + " and T.BILL_BL_ID='" + str2 + "' and T.bill_stand2 !='' and T.bill_wr_username='" + str + "' ORDER BY T.WAKTU_CATAT ASC";
    }

    public String daftarPelangganUnRead(String str, String str2, String str3, String str4) {
        return "SELECT BILL_ID, CUST_CODE, CUST_CODE123, CUST_NAME, ALAMAT, ifnull(TGL_CATAT,'') bill_date, ifnull(bill_stand1,'') bill_stand1,ifnull(bill_stand2,'') bill_stand2, TARIF, bill_longlat, bill_nourutrute, BILL_KD_WMSIZEID, PARAM2, WAKTU_CATAT from DATA_METER WHERE bill_mperiod=" + str4 + " and bill_yperiod=" + str3 + " and bill_bl_id='" + str2 + "' and bill_stand2 ='' and bill_date='' and bill_wr_username='" + str + "' ORDER BY WAKTU_CATAT ASC";
    }

    public String pencarianData(String str, int i) {
        if (i == 0) {
            return "select BILL_ID,CUST_CODE123,CUST_NAME,ALAMAT,TARIF,BILL_STAND2,BILL_BL_ID   from DATA_METER where   CUST_NAME LIKE '%" + str + "%'  order by CUST_CODE123 asc";
        }
        if (i == 1) {
            return "select BILL_ID,CUST_CODE123,CUST_NAME,ALAMAT,TARIF,BILL_STAND2,BILL_BL_ID   from DATA_METER where   CUST_CODE123 LIKE '%" + str + "'  order by CUST_CODE123 asc";
        }
        if (i != 2) {
            return "select BILL_ID,CUST_CODE123,CUST_NAME,ALAMAT,TARIF,BILL_STAND2,BILL_BL_ID   from DATA_METER where   BILL_ISREQUEST=1 order by CUST_CODE123 asc";
        }
        return "select BILL_ID,CUST_CODE123,CUST_NAME,ALAMAT,TARIF,BILL_STAND2,BILL_BL_ID   from DATA_METER where   ALAMAT LIKE '%" + str + "%'  order by CUST_CODE123 asc";
    }

    public String currentBill(String str) {
        return "SELECT CUST_CODE123, bill_stand1, bill_stand2,bill_uangair,bill_uangadm,bill_uangtax, BILL_ALNAME, BILL_AL_CODE,bill_pakai, TGL_CATAT, WAKTU_CATAT \nFROM DATA_METER WHERE CUST_CODE123='" + str + "'";
    }

    public String detailPelanggan(String str) {
        return "SELECT CUST_CODE123, cust_name,ALAMAT,1,'nohp', TARIF, bill_stand1 AS stand1, bill_stand2 AS stand2, bill_longlat, bill_nourutrute, BILL_KD_WMSIZEID, bill_bl_id, ifnull(bill_isrequest,0) as bill_isrequest, bill_nohp, BILL_ID, PARAM2, WAKTU_CATAT, ifnull(BILL_IS_UPLOAD,0) as BILL_IS_UPLOAD FROM DATA_METER WHERE CUST_CODE123='" + str + "'";
    }

    public String searchPelanggan(String str, String str2, String str3, String str4) {
        return "SELECT CUST_CODE123, cust_name,ALAMAT,1,'nohp', TARIF,bill_stand1 AS stand1, bill_longlat, bill_nourutrute, BILL_KD_WMSIZEID, bill_bl_id, BILL_NOHP, BILL_LONGLATCATAT FROM DATA_METER WHERE CUST_CODE123='" + str2 + "' and bill_mperiod=" + str4 + "  and bill_yperiod=" + str3 + "  and bill_wr_username='" + str + "' and bill_stand2='' limit 1";
    }

    public String getThreeMonth(String str) {
        return "SELECT period1,period1_stand1,period1_stand2,period1_usage,period1_tagihan,period2,period2_stand1,period2_stand2,period2_usage,period2_tagihan,period3,period3_stand1,period3_stand2,period3_usage,period3_tagihan FROM DATA_METER WHERE cust_code123='" + str + "'";
    }

    public String nextPelangganUnreadTime(String str, String str2, String str3, String str4, String str5) {
        return "SELECT BILL_ID, CUST_ID, CUST_CODE123, CUST_CODE, CUST_NAME, ALAMAT, ifnull(TGL_CATAT,'') TGL_CATAT, ifnull(bill_isrequest,0)as bill_isrequest, ifnull(bill_stand1,'') bill_stand1,ifnull(bill_stand2,'') bill_stand2, TARIF, bill_longlat,BILL_NOHP,bill_bl_id,BILL_KD_WMSIZEID, bill_nourutrute, PARAM2, WAKTU_CATAT FROM DATA_METER WHERE bill_mperiod=" + str2 + " and bill_yperiod=" + str + " AND bill_wr_username='" + str3 + "' and bill_bl_id='" + str5 + "' AND BILL_STAND2 ='' and TGL_CATAT ='' AND WAKTU_CATAT = (SELECT min(WAKTU_CATAT) from DATA_METER WHERE WAKTU_CATAT > '" + str4 + "' AND bill_wr_username='" + str3 + "' and bill_bl_id='" + str5 + "' and bill_mperiod=" + str2 + " and bill_yperiod=" + str + ") order by waktu_catat LIMIT 1";
    }

    public String nextPelangganUnreadTime2(String str, String str2, String str3, String str4, String str5) {
        return "SELECT BILL_ID, CUST_ID, CUST_CODE123, CUST_CODE, CUST_NAME, ALAMAT, ifnull(TGL_CATAT,'') TGL_CATAT, ifnull(bill_isrequest,0)as bill_isrequest, ifnull(bill_stand1,'') bill_stand1,ifnull(bill_stand2,'') bill_stand2, TARIF, bill_longlat,BILL_NOHP,bill_bl_id,BILL_KD_WMSIZEID, bill_nourutrute, PARAM2, WAKTU_CATAT FROM DATA_METER WHERE bill_mperiod=" + str2 + " and bill_yperiod=" + str + " AND bill_wr_username='" + str3 + "' and bill_bl_id='" + str5 + "' AND BILL_STAND2 ='' and TGL_CATAT ='' AND WAKTU_CATAT > (SELECT min(WAKTU_CATAT) from DATA_METER WHERE WAKTU_CATAT > '" + str4 + "' AND bill_wr_username='" + str3 + "' and bill_bl_id='" + str5 + "' and bill_mperiod=" + str2 + " and bill_yperiod=" + str + ") order by waktu_catat LIMIT 1";
    }

    public String prevPelangganUnreadTime(String str, String str2, String str3, String str4, String str5) {
        return "SELECT BILL_ID, CUST_ID, CUST_CODE123, CUST_CODE, CUST_NAME, ALAMAT, ifnull(TGL_CATAT,'') TGL_CATAT, ifnull(bill_isrequest,0)as bill_isrequest, ifnull(bill_stand1,'') bill_stand1,ifnull(bill_stand2,'') bill_stand2, TARIF, bill_longlat,BILL_NOHP,bill_bl_id,BILL_KD_WMSIZEID, bill_nourutrute, PARAM2, WAKTU_CATAT FROM DATA_METER WHERE bill_mperiod=" + str2 + " and bill_yperiod=" + str + " AND bill_wr_username='" + str3 + "' and bill_bl_id='" + str5 + "' AND BILL_STAND2 ='' and TGL_CATAT ='' AND  WAKTU_CATAT = (SELECT max(WAKTU_CATAT) from DATA_METER WHERE WAKTU_CATAT < '" + str4 + "' AND bill_wr_username='" + str3 + "' and bill_bl_id='" + str5 + "' and bill_mperiod=" + str2 + " and bill_yperiod=" + str + ") order by waktu_catat LIMIT 1";
    }

    public String prevPelangganUnreadTime2(String str, String str2, String str3, String str4, String str5) {
        return "SELECT BILL_ID, CUST_ID, CUST_CODE123, CUST_CODE, CUST_NAME, ALAMAT, ifnull(TGL_CATAT,'') TGL_CATAT, ifnull(bill_isrequest,0)as bill_isrequest, ifnull(bill_stand1,'') bill_stand1,ifnull(bill_stand2,'') bill_stand2, TARIF, bill_longlat,BILL_NOHP,bill_bl_id,BILL_KD_WMSIZEID, bill_nourutrute, PARAM2, WAKTU_CATAT FROM DATA_METER WHERE bill_mperiod=" + str2 + " and bill_yperiod=" + str + " AND bill_wr_username='" + str3 + "' and bill_bl_id='" + str5 + "' AND BILL_STAND2 ='' and TGL_CATAT ='' AND  WAKTU_CATAT < (SELECT max(WAKTU_CATAT) from DATA_METER WHERE WAKTU_CATAT < '" + str4 + "' AND bill_wr_username='" + str3 + "' and bill_bl_id='" + str5 + "' and bill_mperiod=" + str2 + " and bill_yperiod=" + str + ") order by waktu_catat LIMIT 1";
    }

    public String nextPelangganReadTime(String str, String str2, String str3, String str4, String str5) {
        return "SELECT BILL_ID, CUST_ID, CUST_CODE123, CUST_CODE, CUST_NAME, ALAMAT, ifnull(TGL_CATAT,'') TGL_CATAT, ifnull(bill_isrequest,0)as bill_isrequest, ifnull(bill_stand1,'') bill_stand1,ifnull(bill_stand2,'') bill_stand2, TARIF, bill_longlat,BILL_NOHP,bill_bl_id,BILL_KD_WMSIZEID, bill_nourutrute, PARAM2, WAKTU_CATAT, ifnull(BILL_IS_UPLOAD,0) as BILL_IS_UPLOAD FROM DATA_METER WHERE bill_mperiod=" + str2 + " and bill_yperiod=" + str + " AND bill_wr_username='" + str3 + "' and bill_bl_id='" + str5 + "' AND BILL_STAND2 !='' and TGL_CATAT !='' AND  WAKTU_CATAT = (SELECT min(WAKTU_CATAT) from DATA_METER WHERE WAKTU_CATAT > '" + str4 + "' AND bill_wr_username='" + str3 + "' and bill_bl_id='" + str5 + "' and bill_mperiod=" + str2 + " and bill_yperiod=" + str + ") order by waktu_catat LIMIT 1";
    }

    public String prevPelangganReadTime(String str, String str2, String str3, String str4, String str5) {
        return "SELECT BILL_ID, CUST_ID, CUST_CODE123, CUST_CODE, CUST_NAME, ALAMAT, ifnull(TGL_CATAT,'') TGL_CATAT, ifnull(bill_isrequest,0)as bill_isrequest, ifnull(bill_stand1,'') bill_stand1,ifnull(bill_stand2,'') bill_stand2, TARIF, bill_longlat,BILL_NOHP,bill_bl_id,BILL_KD_WMSIZEID, bill_nourutrute, PARAM2, WAKTU_CATAT, ifnull(BILL_IS_UPLOAD,0) as BILL_IS_UPLOAD FROM DATA_METER WHERE bill_mperiod=" + str2 + " and bill_yperiod=" + str + " AND bill_wr_username='" + str3 + "' and bill_bl_id='" + str5 + "' AND BILL_STAND2 !='' and TGL_CATAT !='' AND  WAKTU_CATAT = (SELECT max(WAKTU_CATAT) from DATA_METER WHERE WAKTU_CATAT < '" + str4 + "' AND bill_wr_username='" + str3 + "' and bill_bl_id='" + str5 + "' and bill_mperiod=" + str2 + " and bill_yperiod=" + str + ") order by waktu_catat LIMIT 1";
    }

    public String daftarRuteUpload(String str, String str2) {
        return " Select b.bill_bl_id,   ifnull((select count(1) from DATA_METER where bill_is_upload=1 and bill_mperiod=" + str2 + " and bill_yperiod=" + str + " and bill_bl_id=b.bill_bl_id),0)as blm_upload,  ifnull((select count(1) from DATA_METER where bill_is_upload=2 and bill_mperiod=" + str2 + " and bill_yperiod=" + str + " and bill_bl_id=b.bill_bl_id),0)as sdh_upload,  ifnull((select count(1) from DATA_METER where bill_stand2!='' and bill_mperiod=" + str2 + " and bill_yperiod=" + str + " and bill_bl_id=b.bill_bl_id),0)as total_catat  from DATA_METER b\tgroup by b.bill_bl_id";
    }

    public String queryUpload(String str, String str2, String str3, String str4) {
        String str5 = str + "" + str2;
        String[] strArrSplit = str4.split(",");
        StringBuilder sb = new StringBuilder();
        for (String str6 : strArrSplit) {
            if (sb.length() > 0) {
                sb.append("','");
            }
            sb.append(str6);
        }
        return "SELECT DATA_METER.BILL_ID, DATA_METER.CUST_ID, DATA_METER.cust_code123, DATA_METER.margin_meter, DATA_METER.bill_stand1, DATA_METER.bill_stand2, DATA_METER.bill_pakai, DATA_METER.bill_uangair, DATA_METER.bill_uangadm, DATA_METER.bill_uangtax, ifnull(STATUS_CATAT,0) as STATUS_CATAT, bill_al_code, BILL_ALNAME, " + str5 + " as PERIODE,DATA_METER.bill_mperiod, DATA_METER.bill_yperiod, DATA_METER.TGL_CATAT,DATA_METER.WAKTU_CATAT, DATA_METER.BILL_LONGLATCATAT, DATA_METER.bill_wr_username,DATA_METER.bill_issegel,DATA_METER.bill_perubahan,DATA_METER.bill_nohp, DATA_METER.BILL_REQNOURUTBARU from DATA_METER where DATA_METER.bill_bl_id in(" + ("'" + sb.toString() + "'") + ") and DATA_METER.bill_wr_username='" + str3 + "' and DATA_METER.bill_mperiod=" + str2 + " and DATA_METER.bill_yperiod=" + str + " and DATA_METER.BILL_IS_UPLOAD=1";
    }

    public String todayReading(String str, String str2) {
        return "SELECT count(*) as TODAY_READING from DATA_METER WHERE BILL_WR_USERNAME='" + str + "' AND TGL_CATAT='" + str2 + "'";
    }

    public String notUpload(String str) {
        return "SELECT count(*) as NOT_UPLOAD from DATA_METER WHERE BILL_WR_USERNAME='" + str + "' AND BILL_IS_UPLOAD=1 AND TGL_CATAT!=''";
    }

    public String progressWriter(String str, String str2, String str3) {
        return "select 1 as jenis,'Total Billing' as param2,tb.* from (select(select count(1) from DATA_METER where bill_wr_username='" + str + "' and bill_mperiod=" + str2 + " and bill_yperiod=" + str3 + ")as 'param3') tb union ALL select 2 as jenis,'Total Billing Read' as param2,tb.* from (select(select count(1) from DATA_METER where bill_wr_username='" + str + "' and bill_mperiod=" + str2 + " and bill_yperiod=" + str3 + " and bill_stand2 !='' )as 'total') tb union ALL select 3 as jenis,'Total Billing Unread' as param2,tb.* from (select(select count(1) from DATA_METER where bill_wr_username='" + str + "' and bill_mperiod=" + str2 + " and bill_yperiod=" + str3 + " and bill_stand2 ='' )as 'total') tb";
    }
}
