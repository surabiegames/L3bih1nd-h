package com.aurora.bdg.model;

import android.database.Cursor;
import android.database.sqlite.SQLiteStatement;
import org.greenrobot.greendao.AbstractDao;
import org.greenrobot.greendao.Property;
import org.greenrobot.greendao.database.Database;
import org.greenrobot.greendao.database.DatabaseStatement;
import org.greenrobot.greendao.internal.DaoConfig;

/* JADX INFO: loaded from: classes.dex */
public class DataMeterDao extends AbstractDao<DataMeter, Long> {
    public static final String TABLENAME = "DATA_METER";

    public static class Properties {
        public static final Property Id = new Property(0, Long.class, "id", true, "_id");
        public static final Property WriterId = new Property(1, String.class, "writerId", false, "WRITER_ID");
        public static final Property BillId = new Property(2, String.class, "billId", false, "BILL_ID");
        public static final Property TglCatat = new Property(3, String.class, "tglCatat", false, "TGL_CATAT");
        public static final Property WaktuCatat = new Property(4, String.class, "waktuCatat", false, "WAKTU_CATAT");
        public static final Property BillMperiod = new Property(5, String.class, "billMperiod", false, "BILL_MPERIOD");
        public static final Property BillYperiod = new Property(6, String.class, "billYperiod", false, "BILL_YPERIOD");
        public static final Property CustId = new Property(7, String.class, "custId", false, "CUST_ID");
        public static final Property CustCode = new Property(8, String.class, "custCode", false, "CUST_CODE");
        public static final Property CustCode123 = new Property(9, String.class, "custCode123", false, "CUST_CODE123");
        public static final Property CustName = new Property(10, String.class, "custName", false, "CUST_NAME");
        public static final Property Alamat = new Property(11, String.class, "alamat", false, "ALAMAT");
        public static final Property BillLonglat = new Property(12, String.class, "billLonglat", false, "BILL_LONGLAT");
        public static final Property BillKdWmsizeid = new Property(13, String.class, "billKdWmsizeid", false, "BILL_KD_WMSIZEID");
        public static final Property Tarif = new Property(14, String.class, "tarif", false, TarifDao.TABLENAME);
        public static final Property BillNourutrute = new Property(15, String.class, "billNourutrute", false, "BILL_NOURUTRUTE");
        public static final Property BillStand1 = new Property(16, String.class, "billStand1", false, "BILL_STAND1");
        public static final Property BillStand2 = new Property(17, String.class, "billStand2", false, "BILL_STAND2");
        public static final Property BillPakai = new Property(18, String.class, "billPakai", false, "BILL_PAKAI");
        public static final Property BillUangair = new Property(19, String.class, "billUangair", false, "BILL_UANGAIR");
        public static final Property BillUangadm = new Property(20, String.class, "billUangadm", false, "BILL_UANGADM");
        public static final Property BillUangtax = new Property(21, String.class, "billUangtax", false, "BILL_UANGTAX");
        public static final Property BillOfId = new Property(22, String.class, "billOfId", false, "BILL_OF_ID");
        public static final Property BillRgnId = new Property(23, String.class, "billRgnId", false, "BILL_RGN_ID");
        public static final Property BillBlId = new Property(24, String.class, "billBlId", false, "BILL_BL_ID");
        public static final Property BillAlCode = new Property(25, String.class, "billAlCode", false, "BILL_AL_CODE");
        public static final Property BillAlname = new Property(26, String.class, "billAlname", false, "BILL_ALNAME");
        public static final Property BillWrUsername = new Property(27, String.class, "billWrUsername", false, "BILL_WR_USERNAME");
        public static final Property Period1 = new Property(28, String.class, "period1", false, "PERIOD1");
        public static final Property Period1Stand1 = new Property(29, String.class, "period1Stand1", false, "PERIOD1_STAND1");
        public static final Property Period1Stand2 = new Property(30, String.class, "period1Stand2", false, "PERIOD1_STAND2");
        public static final Property Period1Usage = new Property(31, String.class, "period1Usage", false, "PERIOD1_USAGE");
        public static final Property Period1Tagihan = new Property(32, String.class, "period1Tagihan", false, "PERIOD1_TAGIHAN");
        public static final Property Period2 = new Property(33, String.class, "period2", false, "PERIOD2");
        public static final Property Period2Stand1 = new Property(34, String.class, "period2Stand1", false, "PERIOD2_STAND1");
        public static final Property Period2Stand2 = new Property(35, String.class, "period2Stand2", false, "PERIOD2_STAND2");
        public static final Property Period2Usage = new Property(36, String.class, "period2Usage", false, "PERIOD2_USAGE");
        public static final Property Period2Tagihan = new Property(37, String.class, "period2Tagihan", false, "PERIOD2_TAGIHAN");
        public static final Property Period3 = new Property(38, String.class, "period3", false, "PERIOD3");
        public static final Property Period3Stand1 = new Property(39, String.class, "period3Stand1", false, "PERIOD3_STAND1");
        public static final Property Period3Stand2 = new Property(40, String.class, "period3Stand2", false, "PERIOD3_STAND2");
        public static final Property Period3Usage = new Property(41, String.class, "period3Usage", false, "PERIOD3_USAGE");
        public static final Property Period3Tagihan = new Property(42, String.class, "period3Tagihan", false, "PERIOD3_TAGIHAN");
        public static final Property BillIsrequest = new Property(43, String.class, "billIsrequest", false, "BILL_ISREQUEST");
        public static final Property BillIsUpload = new Property(44, String.class, "billIsUpload", false, "BILL_IS_UPLOAD");
        public static final Property Bill_issegel = new Property(45, String.class, "bill_issegel", false, "BILL_ISSEGEL");
        public static final Property Bill_perubahan = new Property(46, String.class, "bill_perubahan", false, "BILL_PERUBAHAN");
        public static final Property BillNohp = new Property(47, String.class, "billNohp", false, "BILL_NOHP");
        public static final Property StatusCatat = new Property(48, String.class, "statusCatat", false, "STATUS_CATAT");
        public static final Property Bill_reqnourutbaru = new Property(49, String.class, "bill_reqnourutbaru", false, "BILL_REQNOURUTBARU");
        public static final Property Bill_longlatcatat = new Property(50, String.class, "bill_longlatcatat", false, "BILL_LONGLATCATAT");
        public static final Property Param1 = new Property(51, String.class, "param1", false, "PARAM1");
        public static final Property Param2 = new Property(52, String.class, "param2", false, "PARAM2");
        public static final Property MarginMeter = new Property(53, String.class, "marginMeter", false, "MARGIN_METER");
    }

    @Override // org.greenrobot.greendao.AbstractDao
    protected final boolean isEntityUpdateable() {
        return true;
    }

    public DataMeterDao(DaoConfig daoConfig) {
        super(daoConfig);
    }

    public DataMeterDao(DaoConfig daoConfig, DaoSession daoSession) {
        super(daoConfig, daoSession);
    }

    public static void createTable(Database database, boolean z) {
        database.execSQL("CREATE TABLE " + (z ? "IF NOT EXISTS " : "") + "\"DATA_METER\" (\"_id\" INTEGER PRIMARY KEY AUTOINCREMENT ,\"WRITER_ID\" TEXT,\"BILL_ID\" TEXT,\"TGL_CATAT\" TEXT,\"WAKTU_CATAT\" TEXT,\"BILL_MPERIOD\" TEXT,\"BILL_YPERIOD\" TEXT,\"CUST_ID\" TEXT,\"CUST_CODE\" TEXT,\"CUST_CODE123\" TEXT,\"CUST_NAME\" TEXT,\"ALAMAT\" TEXT,\"BILL_LONGLAT\" TEXT,\"BILL_KD_WMSIZEID\" TEXT,\"TARIF\" TEXT,\"BILL_NOURUTRUTE\" TEXT,\"BILL_STAND1\" TEXT,\"BILL_STAND2\" TEXT,\"BILL_PAKAI\" TEXT,\"BILL_UANGAIR\" TEXT,\"BILL_UANGADM\" TEXT,\"BILL_UANGTAX\" TEXT,\"BILL_OF_ID\" TEXT,\"BILL_RGN_ID\" TEXT,\"BILL_BL_ID\" TEXT,\"BILL_AL_CODE\" TEXT,\"BILL_ALNAME\" TEXT,\"BILL_WR_USERNAME\" TEXT,\"PERIOD1\" TEXT,\"PERIOD1_STAND1\" TEXT,\"PERIOD1_STAND2\" TEXT,\"PERIOD1_USAGE\" TEXT,\"PERIOD1_TAGIHAN\" TEXT,\"PERIOD2\" TEXT,\"PERIOD2_STAND1\" TEXT,\"PERIOD2_STAND2\" TEXT,\"PERIOD2_USAGE\" TEXT,\"PERIOD2_TAGIHAN\" TEXT,\"PERIOD3\" TEXT,\"PERIOD3_STAND1\" TEXT,\"PERIOD3_STAND2\" TEXT,\"PERIOD3_USAGE\" TEXT,\"PERIOD3_TAGIHAN\" TEXT,\"BILL_ISREQUEST\" TEXT,\"BILL_IS_UPLOAD\" TEXT,\"BILL_ISSEGEL\" TEXT,\"BILL_PERUBAHAN\" TEXT,\"BILL_NOHP\" TEXT,\"STATUS_CATAT\" TEXT,\"BILL_REQNOURUTBARU\" TEXT,\"BILL_LONGLATCATAT\" TEXT,\"PARAM1\" TEXT,\"PARAM2\" TEXT,\"MARGIN_METER\" TEXT);");
    }

    public static void dropTable(Database database, boolean z) {
        StringBuilder sb = new StringBuilder();
        sb.append("DROP TABLE ");
        sb.append(z ? "IF EXISTS " : "");
        sb.append("\"DATA_METER\"");
        database.execSQL(sb.toString());
    }

    /* JADX INFO: Access modifiers changed from: protected */
    @Override // org.greenrobot.greendao.AbstractDao
    public final void bindValues(DatabaseStatement databaseStatement, DataMeter dataMeter) {
        databaseStatement.clearBindings();
        Long id = dataMeter.getId();
        if (id != null) {
            databaseStatement.bindLong(1, id.longValue());
        }
        String writerId = dataMeter.getWriterId();
        if (writerId != null) {
            databaseStatement.bindString(2, writerId);
        }
        String billId = dataMeter.getBillId();
        if (billId != null) {
            databaseStatement.bindString(3, billId);
        }
        String tglCatat = dataMeter.getTglCatat();
        if (tglCatat != null) {
            databaseStatement.bindString(4, tglCatat);
        }
        String waktuCatat = dataMeter.getWaktuCatat();
        if (waktuCatat != null) {
            databaseStatement.bindString(5, waktuCatat);
        }
        String billMperiod = dataMeter.getBillMperiod();
        if (billMperiod != null) {
            databaseStatement.bindString(6, billMperiod);
        }
        String billYperiod = dataMeter.getBillYperiod();
        if (billYperiod != null) {
            databaseStatement.bindString(7, billYperiod);
        }
        String custId = dataMeter.getCustId();
        if (custId != null) {
            databaseStatement.bindString(8, custId);
        }
        String custCode = dataMeter.getCustCode();
        if (custCode != null) {
            databaseStatement.bindString(9, custCode);
        }
        String custCode123 = dataMeter.getCustCode123();
        if (custCode123 != null) {
            databaseStatement.bindString(10, custCode123);
        }
        String custName = dataMeter.getCustName();
        if (custName != null) {
            databaseStatement.bindString(11, custName);
        }
        String alamat = dataMeter.getAlamat();
        if (alamat != null) {
            databaseStatement.bindString(12, alamat);
        }
        String billLonglat = dataMeter.getBillLonglat();
        if (billLonglat != null) {
            databaseStatement.bindString(13, billLonglat);
        }
        String billKdWmsizeid = dataMeter.getBillKdWmsizeid();
        if (billKdWmsizeid != null) {
            databaseStatement.bindString(14, billKdWmsizeid);
        }
        String tarif = dataMeter.getTarif();
        if (tarif != null) {
            databaseStatement.bindString(15, tarif);
        }
        String billNourutrute = dataMeter.getBillNourutrute();
        if (billNourutrute != null) {
            databaseStatement.bindString(16, billNourutrute);
        }
        String billStand1 = dataMeter.getBillStand1();
        if (billStand1 != null) {
            databaseStatement.bindString(17, billStand1);
        }
        String billStand2 = dataMeter.getBillStand2();
        if (billStand2 != null) {
            databaseStatement.bindString(18, billStand2);
        }
        String billPakai = dataMeter.getBillPakai();
        if (billPakai != null) {
            databaseStatement.bindString(19, billPakai);
        }
        String billUangair = dataMeter.getBillUangair();
        if (billUangair != null) {
            databaseStatement.bindString(20, billUangair);
        }
        String billUangadm = dataMeter.getBillUangadm();
        if (billUangadm != null) {
            databaseStatement.bindString(21, billUangadm);
        }
        String billUangtax = dataMeter.getBillUangtax();
        if (billUangtax != null) {
            databaseStatement.bindString(22, billUangtax);
        }
        String billOfId = dataMeter.getBillOfId();
        if (billOfId != null) {
            databaseStatement.bindString(23, billOfId);
        }
        String billRgnId = dataMeter.getBillRgnId();
        if (billRgnId != null) {
            databaseStatement.bindString(24, billRgnId);
        }
        String billBlId = dataMeter.getBillBlId();
        if (billBlId != null) {
            databaseStatement.bindString(25, billBlId);
        }
        String billAlCode = dataMeter.getBillAlCode();
        if (billAlCode != null) {
            databaseStatement.bindString(26, billAlCode);
        }
        String billAlname = dataMeter.getBillAlname();
        if (billAlname != null) {
            databaseStatement.bindString(27, billAlname);
        }
        String billWrUsername = dataMeter.getBillWrUsername();
        if (billWrUsername != null) {
            databaseStatement.bindString(28, billWrUsername);
        }
        String period1 = dataMeter.getPeriod1();
        if (period1 != null) {
            databaseStatement.bindString(29, period1);
        }
        String period1Stand1 = dataMeter.getPeriod1Stand1();
        if (period1Stand1 != null) {
            databaseStatement.bindString(30, period1Stand1);
        }
        String period1Stand2 = dataMeter.getPeriod1Stand2();
        if (period1Stand2 != null) {
            databaseStatement.bindString(31, period1Stand2);
        }
        String period1Usage = dataMeter.getPeriod1Usage();
        if (period1Usage != null) {
            databaseStatement.bindString(32, period1Usage);
        }
        String period1Tagihan = dataMeter.getPeriod1Tagihan();
        if (period1Tagihan != null) {
            databaseStatement.bindString(33, period1Tagihan);
        }
        String period2 = dataMeter.getPeriod2();
        if (period2 != null) {
            databaseStatement.bindString(34, period2);
        }
        String period2Stand1 = dataMeter.getPeriod2Stand1();
        if (period2Stand1 != null) {
            databaseStatement.bindString(35, period2Stand1);
        }
        String period2Stand2 = dataMeter.getPeriod2Stand2();
        if (period2Stand2 != null) {
            databaseStatement.bindString(36, period2Stand2);
        }
        String period2Usage = dataMeter.getPeriod2Usage();
        if (period2Usage != null) {
            databaseStatement.bindString(37, period2Usage);
        }
        String period2Tagihan = dataMeter.getPeriod2Tagihan();
        if (period2Tagihan != null) {
            databaseStatement.bindString(38, period2Tagihan);
        }
        String period3 = dataMeter.getPeriod3();
        if (period3 != null) {
            databaseStatement.bindString(39, period3);
        }
        String period3Stand1 = dataMeter.getPeriod3Stand1();
        if (period3Stand1 != null) {
            databaseStatement.bindString(40, period3Stand1);
        }
        String period3Stand2 = dataMeter.getPeriod3Stand2();
        if (period3Stand2 != null) {
            databaseStatement.bindString(41, period3Stand2);
        }
        String period3Usage = dataMeter.getPeriod3Usage();
        if (period3Usage != null) {
            databaseStatement.bindString(42, period3Usage);
        }
        String period3Tagihan = dataMeter.getPeriod3Tagihan();
        if (period3Tagihan != null) {
            databaseStatement.bindString(43, period3Tagihan);
        }
        String billIsrequest = dataMeter.getBillIsrequest();
        if (billIsrequest != null) {
            databaseStatement.bindString(44, billIsrequest);
        }
        String billIsUpload = dataMeter.getBillIsUpload();
        if (billIsUpload != null) {
            databaseStatement.bindString(45, billIsUpload);
        }
        String bill_issegel = dataMeter.getBill_issegel();
        if (bill_issegel != null) {
            databaseStatement.bindString(46, bill_issegel);
        }
        String bill_perubahan = dataMeter.getBill_perubahan();
        if (bill_perubahan != null) {
            databaseStatement.bindString(47, bill_perubahan);
        }
        String billNohp = dataMeter.getBillNohp();
        if (billNohp != null) {
            databaseStatement.bindString(48, billNohp);
        }
        String statusCatat = dataMeter.getStatusCatat();
        if (statusCatat != null) {
            databaseStatement.bindString(49, statusCatat);
        }
        String bill_reqnourutbaru = dataMeter.getBill_reqnourutbaru();
        if (bill_reqnourutbaru != null) {
            databaseStatement.bindString(50, bill_reqnourutbaru);
        }
        String bill_longlatcatat = dataMeter.getBill_longlatcatat();
        if (bill_longlatcatat != null) {
            databaseStatement.bindString(51, bill_longlatcatat);
        }
        String param1 = dataMeter.getParam1();
        if (param1 != null) {
            databaseStatement.bindString(52, param1);
        }
        String param2 = dataMeter.getParam2();
        if (param2 != null) {
            databaseStatement.bindString(53, param2);
        }
        String marginMeter = dataMeter.getMarginMeter();
        if (marginMeter != null) {
            databaseStatement.bindString(54, marginMeter);
        }
    }

    /* JADX INFO: Access modifiers changed from: protected */
    @Override // org.greenrobot.greendao.AbstractDao
    public final void bindValues(SQLiteStatement sQLiteStatement, DataMeter dataMeter) {
        sQLiteStatement.clearBindings();
        Long id = dataMeter.getId();
        if (id != null) {
            sQLiteStatement.bindLong(1, id.longValue());
        }
        String writerId = dataMeter.getWriterId();
        if (writerId != null) {
            sQLiteStatement.bindString(2, writerId);
        }
        String billId = dataMeter.getBillId();
        if (billId != null) {
            sQLiteStatement.bindString(3, billId);
        }
        String tglCatat = dataMeter.getTglCatat();
        if (tglCatat != null) {
            sQLiteStatement.bindString(4, tglCatat);
        }
        String waktuCatat = dataMeter.getWaktuCatat();
        if (waktuCatat != null) {
            sQLiteStatement.bindString(5, waktuCatat);
        }
        String billMperiod = dataMeter.getBillMperiod();
        if (billMperiod != null) {
            sQLiteStatement.bindString(6, billMperiod);
        }
        String billYperiod = dataMeter.getBillYperiod();
        if (billYperiod != null) {
            sQLiteStatement.bindString(7, billYperiod);
        }
        String custId = dataMeter.getCustId();
        if (custId != null) {
            sQLiteStatement.bindString(8, custId);
        }
        String custCode = dataMeter.getCustCode();
        if (custCode != null) {
            sQLiteStatement.bindString(9, custCode);
        }
        String custCode123 = dataMeter.getCustCode123();
        if (custCode123 != null) {
            sQLiteStatement.bindString(10, custCode123);
        }
        String custName = dataMeter.getCustName();
        if (custName != null) {
            sQLiteStatement.bindString(11, custName);
        }
        String alamat = dataMeter.getAlamat();
        if (alamat != null) {
            sQLiteStatement.bindString(12, alamat);
        }
        String billLonglat = dataMeter.getBillLonglat();
        if (billLonglat != null) {
            sQLiteStatement.bindString(13, billLonglat);
        }
        String billKdWmsizeid = dataMeter.getBillKdWmsizeid();
        if (billKdWmsizeid != null) {
            sQLiteStatement.bindString(14, billKdWmsizeid);
        }
        String tarif = dataMeter.getTarif();
        if (tarif != null) {
            sQLiteStatement.bindString(15, tarif);
        }
        String billNourutrute = dataMeter.getBillNourutrute();
        if (billNourutrute != null) {
            sQLiteStatement.bindString(16, billNourutrute);
        }
        String billStand1 = dataMeter.getBillStand1();
        if (billStand1 != null) {
            sQLiteStatement.bindString(17, billStand1);
        }
        String billStand2 = dataMeter.getBillStand2();
        if (billStand2 != null) {
            sQLiteStatement.bindString(18, billStand2);
        }
        String billPakai = dataMeter.getBillPakai();
        if (billPakai != null) {
            sQLiteStatement.bindString(19, billPakai);
        }
        String billUangair = dataMeter.getBillUangair();
        if (billUangair != null) {
            sQLiteStatement.bindString(20, billUangair);
        }
        String billUangadm = dataMeter.getBillUangadm();
        if (billUangadm != null) {
            sQLiteStatement.bindString(21, billUangadm);
        }
        String billUangtax = dataMeter.getBillUangtax();
        if (billUangtax != null) {
            sQLiteStatement.bindString(22, billUangtax);
        }
        String billOfId = dataMeter.getBillOfId();
        if (billOfId != null) {
            sQLiteStatement.bindString(23, billOfId);
        }
        String billRgnId = dataMeter.getBillRgnId();
        if (billRgnId != null) {
            sQLiteStatement.bindString(24, billRgnId);
        }
        String billBlId = dataMeter.getBillBlId();
        if (billBlId != null) {
            sQLiteStatement.bindString(25, billBlId);
        }
        String billAlCode = dataMeter.getBillAlCode();
        if (billAlCode != null) {
            sQLiteStatement.bindString(26, billAlCode);
        }
        String billAlname = dataMeter.getBillAlname();
        if (billAlname != null) {
            sQLiteStatement.bindString(27, billAlname);
        }
        String billWrUsername = dataMeter.getBillWrUsername();
        if (billWrUsername != null) {
            sQLiteStatement.bindString(28, billWrUsername);
        }
        String period1 = dataMeter.getPeriod1();
        if (period1 != null) {
            sQLiteStatement.bindString(29, period1);
        }
        String period1Stand1 = dataMeter.getPeriod1Stand1();
        if (period1Stand1 != null) {
            sQLiteStatement.bindString(30, period1Stand1);
        }
        String period1Stand2 = dataMeter.getPeriod1Stand2();
        if (period1Stand2 != null) {
            sQLiteStatement.bindString(31, period1Stand2);
        }
        String period1Usage = dataMeter.getPeriod1Usage();
        if (period1Usage != null) {
            sQLiteStatement.bindString(32, period1Usage);
        }
        String period1Tagihan = dataMeter.getPeriod1Tagihan();
        if (period1Tagihan != null) {
            sQLiteStatement.bindString(33, period1Tagihan);
        }
        String period2 = dataMeter.getPeriod2();
        if (period2 != null) {
            sQLiteStatement.bindString(34, period2);
        }
        String period2Stand1 = dataMeter.getPeriod2Stand1();
        if (period2Stand1 != null) {
            sQLiteStatement.bindString(35, period2Stand1);
        }
        String period2Stand2 = dataMeter.getPeriod2Stand2();
        if (period2Stand2 != null) {
            sQLiteStatement.bindString(36, period2Stand2);
        }
        String period2Usage = dataMeter.getPeriod2Usage();
        if (period2Usage != null) {
            sQLiteStatement.bindString(37, period2Usage);
        }
        String period2Tagihan = dataMeter.getPeriod2Tagihan();
        if (period2Tagihan != null) {
            sQLiteStatement.bindString(38, period2Tagihan);
        }
        String period3 = dataMeter.getPeriod3();
        if (period3 != null) {
            sQLiteStatement.bindString(39, period3);
        }
        String period3Stand1 = dataMeter.getPeriod3Stand1();
        if (period3Stand1 != null) {
            sQLiteStatement.bindString(40, period3Stand1);
        }
        String period3Stand2 = dataMeter.getPeriod3Stand2();
        if (period3Stand2 != null) {
            sQLiteStatement.bindString(41, period3Stand2);
        }
        String period3Usage = dataMeter.getPeriod3Usage();
        if (period3Usage != null) {
            sQLiteStatement.bindString(42, period3Usage);
        }
        String period3Tagihan = dataMeter.getPeriod3Tagihan();
        if (period3Tagihan != null) {
            sQLiteStatement.bindString(43, period3Tagihan);
        }
        String billIsrequest = dataMeter.getBillIsrequest();
        if (billIsrequest != null) {
            sQLiteStatement.bindString(44, billIsrequest);
        }
        String billIsUpload = dataMeter.getBillIsUpload();
        if (billIsUpload != null) {
            sQLiteStatement.bindString(45, billIsUpload);
        }
        String bill_issegel = dataMeter.getBill_issegel();
        if (bill_issegel != null) {
            sQLiteStatement.bindString(46, bill_issegel);
        }
        String bill_perubahan = dataMeter.getBill_perubahan();
        if (bill_perubahan != null) {
            sQLiteStatement.bindString(47, bill_perubahan);
        }
        String billNohp = dataMeter.getBillNohp();
        if (billNohp != null) {
            sQLiteStatement.bindString(48, billNohp);
        }
        String statusCatat = dataMeter.getStatusCatat();
        if (statusCatat != null) {
            sQLiteStatement.bindString(49, statusCatat);
        }
        String bill_reqnourutbaru = dataMeter.getBill_reqnourutbaru();
        if (bill_reqnourutbaru != null) {
            sQLiteStatement.bindString(50, bill_reqnourutbaru);
        }
        String bill_longlatcatat = dataMeter.getBill_longlatcatat();
        if (bill_longlatcatat != null) {
            sQLiteStatement.bindString(51, bill_longlatcatat);
        }
        String param1 = dataMeter.getParam1();
        if (param1 != null) {
            sQLiteStatement.bindString(52, param1);
        }
        String param2 = dataMeter.getParam2();
        if (param2 != null) {
            sQLiteStatement.bindString(53, param2);
        }
        String marginMeter = dataMeter.getMarginMeter();
        if (marginMeter != null) {
            sQLiteStatement.bindString(54, marginMeter);
        }
    }

    /* JADX WARN: Can't rename method to resolve collision */
    @Override // org.greenrobot.greendao.AbstractDao
    public Long readKey(Cursor cursor, int i) {
        int i2 = i + 0;
        if (cursor.isNull(i2)) {
            return null;
        }
        return Long.valueOf(cursor.getLong(i2));
    }

    /* JADX WARN: Can't rename method to resolve collision */
    @Override // org.greenrobot.greendao.AbstractDao
    public DataMeter readEntity(Cursor cursor, int i) {
        int i2 = i + 0;
        Long lValueOf = cursor.isNull(i2) ? null : Long.valueOf(cursor.getLong(i2));
        int i3 = i + 1;
        String string = cursor.isNull(i3) ? null : cursor.getString(i3);
        int i4 = i + 2;
        String string2 = cursor.isNull(i4) ? null : cursor.getString(i4);
        int i5 = i + 3;
        String string3 = cursor.isNull(i5) ? null : cursor.getString(i5);
        int i6 = i + 4;
        String string4 = cursor.isNull(i6) ? null : cursor.getString(i6);
        int i7 = i + 5;
        String string5 = cursor.isNull(i7) ? null : cursor.getString(i7);
        int i8 = i + 6;
        String string6 = cursor.isNull(i8) ? null : cursor.getString(i8);
        int i9 = i + 7;
        String string7 = cursor.isNull(i9) ? null : cursor.getString(i9);
        int i10 = i + 8;
        String string8 = cursor.isNull(i10) ? null : cursor.getString(i10);
        int i11 = i + 9;
        String string9 = cursor.isNull(i11) ? null : cursor.getString(i11);
        int i12 = i + 10;
        String string10 = cursor.isNull(i12) ? null : cursor.getString(i12);
        int i13 = i + 11;
        String string11 = cursor.isNull(i13) ? null : cursor.getString(i13);
        int i14 = i + 12;
        String string12 = cursor.isNull(i14) ? null : cursor.getString(i14);
        int i15 = i + 13;
        String string13 = cursor.isNull(i15) ? null : cursor.getString(i15);
        int i16 = i + 14;
        String string14 = cursor.isNull(i16) ? null : cursor.getString(i16);
        int i17 = i + 15;
        String string15 = cursor.isNull(i17) ? null : cursor.getString(i17);
        int i18 = i + 16;
        String string16 = cursor.isNull(i18) ? null : cursor.getString(i18);
        int i19 = i + 17;
        String string17 = cursor.isNull(i19) ? null : cursor.getString(i19);
        int i20 = i + 18;
        String string18 = cursor.isNull(i20) ? null : cursor.getString(i20);
        int i21 = i + 19;
        String string19 = cursor.isNull(i21) ? null : cursor.getString(i21);
        int i22 = i + 20;
        String string20 = cursor.isNull(i22) ? null : cursor.getString(i22);
        int i23 = i + 21;
        String string21 = cursor.isNull(i23) ? null : cursor.getString(i23);
        int i24 = i + 22;
        String string22 = cursor.isNull(i24) ? null : cursor.getString(i24);
        int i25 = i + 23;
        String string23 = cursor.isNull(i25) ? null : cursor.getString(i25);
        int i26 = i + 24;
        String string24 = cursor.isNull(i26) ? null : cursor.getString(i26);
        int i27 = i + 25;
        String string25 = cursor.isNull(i27) ? null : cursor.getString(i27);
        int i28 = i + 26;
        String string26 = cursor.isNull(i28) ? null : cursor.getString(i28);
        int i29 = i + 27;
        String string27 = cursor.isNull(i29) ? null : cursor.getString(i29);
        int i30 = i + 28;
        String string28 = cursor.isNull(i30) ? null : cursor.getString(i30);
        int i31 = i + 29;
        String string29 = cursor.isNull(i31) ? null : cursor.getString(i31);
        int i32 = i + 30;
        String string30 = cursor.isNull(i32) ? null : cursor.getString(i32);
        int i33 = i + 31;
        String string31 = cursor.isNull(i33) ? null : cursor.getString(i33);
        int i34 = i + 32;
        String string32 = cursor.isNull(i34) ? null : cursor.getString(i34);
        int i35 = i + 33;
        String string33 = cursor.isNull(i35) ? null : cursor.getString(i35);
        int i36 = i + 34;
        String string34 = cursor.isNull(i36) ? null : cursor.getString(i36);
        int i37 = i + 35;
        String string35 = cursor.isNull(i37) ? null : cursor.getString(i37);
        int i38 = i + 36;
        String string36 = cursor.isNull(i38) ? null : cursor.getString(i38);
        int i39 = i + 37;
        String string37 = cursor.isNull(i39) ? null : cursor.getString(i39);
        int i40 = i + 38;
        String string38 = cursor.isNull(i40) ? null : cursor.getString(i40);
        int i41 = i + 39;
        String string39 = cursor.isNull(i41) ? null : cursor.getString(i41);
        int i42 = i + 40;
        String string40 = cursor.isNull(i42) ? null : cursor.getString(i42);
        int i43 = i + 41;
        String string41 = cursor.isNull(i43) ? null : cursor.getString(i43);
        int i44 = i + 42;
        String string42 = cursor.isNull(i44) ? null : cursor.getString(i44);
        int i45 = i + 43;
        String string43 = cursor.isNull(i45) ? null : cursor.getString(i45);
        int i46 = i + 44;
        String string44 = cursor.isNull(i46) ? null : cursor.getString(i46);
        int i47 = i + 45;
        String string45 = cursor.isNull(i47) ? null : cursor.getString(i47);
        int i48 = i + 46;
        String string46 = cursor.isNull(i48) ? null : cursor.getString(i48);
        int i49 = i + 47;
        String string47 = cursor.isNull(i49) ? null : cursor.getString(i49);
        int i50 = i + 48;
        String string48 = cursor.isNull(i50) ? null : cursor.getString(i50);
        int i51 = i + 49;
        String string49 = cursor.isNull(i51) ? null : cursor.getString(i51);
        int i52 = i + 50;
        String string50 = cursor.isNull(i52) ? null : cursor.getString(i52);
        int i53 = i + 51;
        String string51 = cursor.isNull(i53) ? null : cursor.getString(i53);
        int i54 = i + 52;
        int i55 = i + 53;
        return new DataMeter(lValueOf, string, string2, string3, string4, string5, string6, string7, string8, string9, string10, string11, string12, string13, string14, string15, string16, string17, string18, string19, string20, string21, string22, string23, string24, string25, string26, string27, string28, string29, string30, string31, string32, string33, string34, string35, string36, string37, string38, string39, string40, string41, string42, string43, string44, string45, string46, string47, string48, string49, string50, string51, cursor.isNull(i54) ? null : cursor.getString(i54), cursor.isNull(i55) ? null : cursor.getString(i55));
    }

    @Override // org.greenrobot.greendao.AbstractDao
    public void readEntity(Cursor cursor, DataMeter dataMeter, int i) {
        int i2 = i + 0;
        dataMeter.setId(cursor.isNull(i2) ? null : Long.valueOf(cursor.getLong(i2)));
        int i3 = i + 1;
        dataMeter.setWriterId(cursor.isNull(i3) ? null : cursor.getString(i3));
        int i4 = i + 2;
        dataMeter.setBillId(cursor.isNull(i4) ? null : cursor.getString(i4));
        int i5 = i + 3;
        dataMeter.setTglCatat(cursor.isNull(i5) ? null : cursor.getString(i5));
        int i6 = i + 4;
        dataMeter.setWaktuCatat(cursor.isNull(i6) ? null : cursor.getString(i6));
        int i7 = i + 5;
        dataMeter.setBillMperiod(cursor.isNull(i7) ? null : cursor.getString(i7));
        int i8 = i + 6;
        dataMeter.setBillYperiod(cursor.isNull(i8) ? null : cursor.getString(i8));
        int i9 = i + 7;
        dataMeter.setCustId(cursor.isNull(i9) ? null : cursor.getString(i9));
        int i10 = i + 8;
        dataMeter.setCustCode(cursor.isNull(i10) ? null : cursor.getString(i10));
        int i11 = i + 9;
        dataMeter.setCustCode123(cursor.isNull(i11) ? null : cursor.getString(i11));
        int i12 = i + 10;
        dataMeter.setCustName(cursor.isNull(i12) ? null : cursor.getString(i12));
        int i13 = i + 11;
        dataMeter.setAlamat(cursor.isNull(i13) ? null : cursor.getString(i13));
        int i14 = i + 12;
        dataMeter.setBillLonglat(cursor.isNull(i14) ? null : cursor.getString(i14));
        int i15 = i + 13;
        dataMeter.setBillKdWmsizeid(cursor.isNull(i15) ? null : cursor.getString(i15));
        int i16 = i + 14;
        dataMeter.setTarif(cursor.isNull(i16) ? null : cursor.getString(i16));
        int i17 = i + 15;
        dataMeter.setBillNourutrute(cursor.isNull(i17) ? null : cursor.getString(i17));
        int i18 = i + 16;
        dataMeter.setBillStand1(cursor.isNull(i18) ? null : cursor.getString(i18));
        int i19 = i + 17;
        dataMeter.setBillStand2(cursor.isNull(i19) ? null : cursor.getString(i19));
        int i20 = i + 18;
        dataMeter.setBillPakai(cursor.isNull(i20) ? null : cursor.getString(i20));
        int i21 = i + 19;
        dataMeter.setBillUangair(cursor.isNull(i21) ? null : cursor.getString(i21));
        int i22 = i + 20;
        dataMeter.setBillUangadm(cursor.isNull(i22) ? null : cursor.getString(i22));
        int i23 = i + 21;
        dataMeter.setBillUangtax(cursor.isNull(i23) ? null : cursor.getString(i23));
        int i24 = i + 22;
        dataMeter.setBillOfId(cursor.isNull(i24) ? null : cursor.getString(i24));
        int i25 = i + 23;
        dataMeter.setBillRgnId(cursor.isNull(i25) ? null : cursor.getString(i25));
        int i26 = i + 24;
        dataMeter.setBillBlId(cursor.isNull(i26) ? null : cursor.getString(i26));
        int i27 = i + 25;
        dataMeter.setBillAlCode(cursor.isNull(i27) ? null : cursor.getString(i27));
        int i28 = i + 26;
        dataMeter.setBillAlname(cursor.isNull(i28) ? null : cursor.getString(i28));
        int i29 = i + 27;
        dataMeter.setBillWrUsername(cursor.isNull(i29) ? null : cursor.getString(i29));
        int i30 = i + 28;
        dataMeter.setPeriod1(cursor.isNull(i30) ? null : cursor.getString(i30));
        int i31 = i + 29;
        dataMeter.setPeriod1Stand1(cursor.isNull(i31) ? null : cursor.getString(i31));
        int i32 = i + 30;
        dataMeter.setPeriod1Stand2(cursor.isNull(i32) ? null : cursor.getString(i32));
        int i33 = i + 31;
        dataMeter.setPeriod1Usage(cursor.isNull(i33) ? null : cursor.getString(i33));
        int i34 = i + 32;
        dataMeter.setPeriod1Tagihan(cursor.isNull(i34) ? null : cursor.getString(i34));
        int i35 = i + 33;
        dataMeter.setPeriod2(cursor.isNull(i35) ? null : cursor.getString(i35));
        int i36 = i + 34;
        dataMeter.setPeriod2Stand1(cursor.isNull(i36) ? null : cursor.getString(i36));
        int i37 = i + 35;
        dataMeter.setPeriod2Stand2(cursor.isNull(i37) ? null : cursor.getString(i37));
        int i38 = i + 36;
        dataMeter.setPeriod2Usage(cursor.isNull(i38) ? null : cursor.getString(i38));
        int i39 = i + 37;
        dataMeter.setPeriod2Tagihan(cursor.isNull(i39) ? null : cursor.getString(i39));
        int i40 = i + 38;
        dataMeter.setPeriod3(cursor.isNull(i40) ? null : cursor.getString(i40));
        int i41 = i + 39;
        dataMeter.setPeriod3Stand1(cursor.isNull(i41) ? null : cursor.getString(i41));
        int i42 = i + 40;
        dataMeter.setPeriod3Stand2(cursor.isNull(i42) ? null : cursor.getString(i42));
        int i43 = i + 41;
        dataMeter.setPeriod3Usage(cursor.isNull(i43) ? null : cursor.getString(i43));
        int i44 = i + 42;
        dataMeter.setPeriod3Tagihan(cursor.isNull(i44) ? null : cursor.getString(i44));
        int i45 = i + 43;
        dataMeter.setBillIsrequest(cursor.isNull(i45) ? null : cursor.getString(i45));
        int i46 = i + 44;
        dataMeter.setBillIsUpload(cursor.isNull(i46) ? null : cursor.getString(i46));
        int i47 = i + 45;
        dataMeter.setBill_issegel(cursor.isNull(i47) ? null : cursor.getString(i47));
        int i48 = i + 46;
        dataMeter.setBill_perubahan(cursor.isNull(i48) ? null : cursor.getString(i48));
        int i49 = i + 47;
        dataMeter.setBillNohp(cursor.isNull(i49) ? null : cursor.getString(i49));
        int i50 = i + 48;
        dataMeter.setStatusCatat(cursor.isNull(i50) ? null : cursor.getString(i50));
        int i51 = i + 49;
        dataMeter.setBill_reqnourutbaru(cursor.isNull(i51) ? null : cursor.getString(i51));
        int i52 = i + 50;
        dataMeter.setBill_longlatcatat(cursor.isNull(i52) ? null : cursor.getString(i52));
        int i53 = i + 51;
        dataMeter.setParam1(cursor.isNull(i53) ? null : cursor.getString(i53));
        int i54 = i + 52;
        dataMeter.setParam2(cursor.isNull(i54) ? null : cursor.getString(i54));
        int i55 = i + 53;
        dataMeter.setMarginMeter(cursor.isNull(i55) ? null : cursor.getString(i55));
    }

    /* JADX INFO: Access modifiers changed from: protected */
    @Override // org.greenrobot.greendao.AbstractDao
    public final Long updateKeyAfterInsert(DataMeter dataMeter, long j) {
        dataMeter.setId(Long.valueOf(j));
        return Long.valueOf(j);
    }

    @Override // org.greenrobot.greendao.AbstractDao
    public Long getKey(DataMeter dataMeter) {
        if (dataMeter != null) {
            return dataMeter.getId();
        }
        return null;
    }

    @Override // org.greenrobot.greendao.AbstractDao
    public boolean hasKey(DataMeter dataMeter) {
        return dataMeter.getId() != null;
    }
}
