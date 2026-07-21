package com.aurora.bdg.util;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;
import com.aurora.bdg.model.DataMeter;
import com.aurora.bdg.model.DataMeterDao;
import com.aurora.bdg.model.Pelanggan;
import com.aurora.bdg.model.Rute;
import com.aurora.bdg.model.RuteUpload;
import com.aurora.bdg.model.TarifDao;
import com.aurora.bdg.model.ThreeMonth;
import com.google.gson.GsonBuilder;
import java.util.ArrayList;
import java.util.HashMap;

/* JADX INFO: loaded from: classes.dex */
public class DataBaseHelper extends SQLiteOpenHelper {
    private static final String DATABASE_NAME = "aurora-db";
    private static final int DATABASE_VERSION = 3;
    private static DataBaseHelper sInstance;
    private String TAG;
    DirUtil dirUtil;
    private QueryHelper queryHelper;

    @Override // android.database.sqlite.SQLiteOpenHelper
    public void onCreate(SQLiteDatabase sQLiteDatabase) {
    }

    @Override // android.database.sqlite.SQLiteOpenHelper
    public void onUpgrade(SQLiteDatabase sQLiteDatabase, int i, int i2) {
    }

    public static synchronized DataBaseHelper getInstance(Context context) {
        if (sInstance == null) {
            sInstance = new DataBaseHelper(context.getApplicationContext());
        }
        return sInstance;
    }

    private DataBaseHelper(Context context) {
        super(context, DATABASE_NAME, (SQLiteDatabase.CursorFactory) null, 3);
        this.TAG = "DataBaseHelper";
        this.queryHelper = new QueryHelper();
        this.dirUtil = new DirUtil();
    }

    public ArrayList<Pelanggan> getListDataCari(String str, int i) {
        ArrayList<Pelanggan> arrayList = new ArrayList<>();
        Cursor cursorRawQuery = getReadableDatabase().rawQuery(this.queryHelper.pencarianData(str, i), null);
        try {
            try {
                if (cursorRawQuery.moveToFirst()) {
                    do {
                        Pelanggan pelanggan = new Pelanggan();
                        pelanggan.setBillBlId(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_ID")));
                        pelanggan.setCustCode123(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_CODE123")));
                        pelanggan.setCustName(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_NAME")));
                        pelanggan.setAlamat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("ALAMAT")));
                        pelanggan.setTarif(cursorRawQuery.getString(cursorRawQuery.getColumnIndex(TarifDao.TABLENAME)));
                        pelanggan.setBillStand2(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_STAND2")));
                        pelanggan.setBillBlId(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_BL_ID")));
                        arrayList.add(pelanggan);
                    } while (cursorRawQuery.moveToNext());
                }
            } catch (Exception e) {
                Log.d(this.TAG, "Error while trying to get posts from database" + e.getMessage());
            }
            return arrayList;
        } finally {
            if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                cursorRawQuery.close();
            }
        }
    }

    public ArrayList<Rute> getListRute(String str, String str2, String str3) {
        ArrayList<Rute> arrayList = new ArrayList<>();
        Cursor cursorRawQuery = getReadableDatabase().rawQuery(this.queryHelper.daftarRute(str, str2, str3), null);
        try {
            try {
                if (cursorRawQuery.moveToFirst()) {
                    do {
                        Rute rute = new Rute();
                        rute.setRuteId(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_BL_ID")));
                        rute.setAktif(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("aktif")));
                        rute.setRead(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("read")));
                        rute.setUnRead(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("unread")));
                        arrayList.add(rute);
                    } while (cursorRawQuery.moveToNext());
                }
            } catch (Exception unused) {
                Log.d(this.TAG, "Error while trying to get posts from database");
            }
            return arrayList;
        } finally {
            if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                cursorRawQuery.close();
            }
        }
    }

    public ArrayList<RuteUpload> getListRuteUpload(String str, String str2) {
        ArrayList<RuteUpload> arrayList = new ArrayList<>();
        Cursor cursorRawQuery = getReadableDatabase().rawQuery(this.queryHelper.daftarRuteUpload(str, str2), null);
        try {
            try {
                if (cursorRawQuery.moveToFirst()) {
                    do {
                        RuteUpload ruteUpload = new RuteUpload();
                        ruteUpload.setBlockCode(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_BL_ID")));
                        ruteUpload.setBlockId(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_BL_ID")));
                        ruteUpload.setBlockName(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_BL_ID")));
                        ruteUpload.setBelumUpload(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("blm_upload")));
                        ruteUpload.setTotalCatat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("total_catat")));
                        arrayList.add(ruteUpload);
                    } while (cursorRawQuery.moveToNext());
                }
                if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                    cursorRawQuery.close();
                }
            } catch (Exception unused) {
                Log.d(this.TAG, "Error while trying to get posts from database");
                if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                }
            }
            return arrayList;
        } catch (Throwable th) {
            if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                cursorRawQuery.close();
            }
            throw th;
        }
    }

    public ArrayList<Pelanggan> getPelangganRead(String str, String str2, String str3, String str4) {
        ArrayList<Pelanggan> arrayList = new ArrayList<>();
        Cursor cursorRawQuery = getReadableDatabase().rawQuery(this.queryHelper.daftarPelangganRead(str, str2, str3, str4), null);
        try {
            try {
                if (cursorRawQuery.moveToFirst()) {
                    do {
                        Pelanggan pelanggan = new Pelanggan();
                        pelanggan.setBillId(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_ID")));
                        pelanggan.setCustCode(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_CODE")));
                        pelanggan.setCustCode123(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_CODE123")));
                        pelanggan.setCustName(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_NAME")));
                        pelanggan.setAlamat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("ALAMAT")));
                        pelanggan.setBillDate(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("bill_date")));
                        pelanggan.setBillStand1(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("bill_stand1")));
                        pelanggan.setBillStand2(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("bill_stand2")));
                        pelanggan.setTarif(cursorRawQuery.getString(cursorRawQuery.getColumnIndex(TarifDao.TABLENAME)));
                        pelanggan.setBillLonglat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_LONGLAT")));
                        arrayList.add(pelanggan);
                    } while (cursorRawQuery.moveToNext());
                }
                if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                    cursorRawQuery.close();
                }
            } catch (Exception unused) {
                Log.d(this.TAG, "Error while trying to get posts from database");
                if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                }
            }
            return arrayList;
        } catch (Throwable th) {
            if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                cursorRawQuery.close();
            }
            throw th;
        }
    }

    public ArrayList<Pelanggan> getPelangganUnRead(String str, String str2, String str3, String str4) {
        ArrayList<Pelanggan> arrayList = new ArrayList<>();
        Cursor cursorRawQuery = getReadableDatabase().rawQuery(this.queryHelper.daftarPelangganUnRead(str, str2, str3, str4), null);
        try {
            try {
                if (cursorRawQuery.moveToFirst()) {
                    do {
                        Pelanggan pelanggan = new Pelanggan();
                        pelanggan.setBillId(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_ID")));
                        pelanggan.setCustCode(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_CODE")));
                        pelanggan.setCustCode123(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_CODE123")));
                        pelanggan.setCustName(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_NAME")));
                        pelanggan.setAlamat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("ALAMAT")));
                        pelanggan.setBillDate(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("bill_date")));
                        pelanggan.setBillStand1(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("bill_stand1")));
                        pelanggan.setBillStand2(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("bill_stand2")));
                        pelanggan.setBillKdWmsizeid(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_KD_WMSIZEID")));
                        pelanggan.setTarif(cursorRawQuery.getString(cursorRawQuery.getColumnIndex(TarifDao.TABLENAME)));
                        pelanggan.setBillLonglat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_LONGLAT")));
                        pelanggan.setBillNoUrutRute(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_NOURUTRUTE")));
                        pelanggan.setWmsn(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("PARAM2")));
                        pelanggan.setWaktuCatat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("WAKTU_CATAT")));
                        arrayList.add(pelanggan);
                    } while (cursorRawQuery.moveToNext());
                }
            } catch (Exception unused) {
                Log.d(this.TAG, "Error while trying to get posts from database");
            }
            return arrayList;
        } finally {
            if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                cursorRawQuery.close();
            }
        }
    }

    /* JADX WARN: Code duplicated, block: B:24:0x00a2  */
    public Pelanggan searchPelanggan(String str, String str2, String str3, String str4) {
        Pelanggan pelanggan;
        String strSearchPelanggan = this.queryHelper.searchPelanggan(str, str2, str3, str4);
        Pelanggan pelanggan2 = null;
        Cursor cursorRawQuery = getReadableDatabase().rawQuery(strSearchPelanggan, null);
        try {
            if (cursorRawQuery != null) {
                try {
                    if (cursorRawQuery.moveToFirst()) {
                        while (true) {
                            pelanggan = new Pelanggan();
                            try {
                                pelanggan.setCustCode123(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_CODE123")));
                                pelanggan.setAlamat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("ALAMAT")));
                                pelanggan.setCustName(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_NAME")));
                                pelanggan.setBillLonglat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_LONGLAT")));
                                pelanggan.setNoHp(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_NOHP")));
                                pelanggan.setBillKdWmsizeid(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_KD_WMSIZEID")));
                                pelanggan.setBillId(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_ID")));
                                if (!cursorRawQuery.moveToNext()) {
                                    break;
                                }
                                pelanggan2 = pelanggan;
                            } catch (Exception unused) {
                                Log.d(this.TAG, "Error while trying to get posts from database");
                                if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                                }
                                return pelanggan;
                            }
                        }
                    } else {
                        pelanggan = null;
                    }
                    if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                        cursorRawQuery.close();
                    }
                } catch (Exception unused2) {
                    pelanggan = pelanggan2;
                }
            } else {
                pelanggan = null;
                if (cursorRawQuery != null) {
                    cursorRawQuery.close();
                }
            }
            return pelanggan;
        } catch (Throwable th) {
            if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                cursorRawQuery.close();
            }
            throw th;
        }
    }

    /* JADX WARN: Code duplicated, block: B:24:0x0118  */
    public Pelanggan getPelanggan(String str) {
        Pelanggan pelanggan;
        Pelanggan pelanggan2 = null;
        Cursor cursorRawQuery = getReadableDatabase().rawQuery(this.queryHelper.detailPelanggan(str), null);
        try {
            if (cursorRawQuery != null) {
                try {
                    if (cursorRawQuery.moveToFirst()) {
                        while (true) {
                            pelanggan = new Pelanggan();
                            try {
                                pelanggan.setCustCode123(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_CODE123")));
                                pelanggan.setAlamat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("ALAMAT")));
                                pelanggan.setCustName(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_NAME")));
                                pelanggan.setTarif(cursorRawQuery.getString(cursorRawQuery.getColumnIndex(TarifDao.TABLENAME)));
                                pelanggan.setBillStand1(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("stand1")));
                                pelanggan.setBillStand2(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("stand2")));
                                pelanggan.setBillLonglat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_LONGLAT")));
                                pelanggan.setBillBlId(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_BL_ID")));
                                pelanggan.setBillNoUrutRute(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_NOURUTRUTE")));
                                pelanggan.setNoHp(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_NOHP")));
                                pelanggan.setBillKdWmsizeid(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_KD_WMSIZEID")));
                                pelanggan.setBillId(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_ID")));
                                pelanggan.setBillIsRequest(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("bill_isrequest")));
                                pelanggan.setWmsn(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("PARAM2")));
                                pelanggan.setWaktuCatat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("WAKTU_CATAT")));
                                pelanggan.setIsUpload(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_IS_UPLOAD")));
                                if (!cursorRawQuery.moveToNext()) {
                                    break;
                                }
                                pelanggan2 = pelanggan;
                            } catch (Exception unused) {
                                Log.d(this.TAG, "Error while trying to get posts from database");
                                if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                                }
                                return pelanggan;
                            }
                        }
                    } else {
                        pelanggan = null;
                    }
                    if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                        cursorRawQuery.close();
                    }
                } catch (Exception unused2) {
                    pelanggan = pelanggan2;
                }
            } else {
                pelanggan = null;
                if (cursorRawQuery != null) {
                    cursorRawQuery.close();
                }
            }
            return pelanggan;
        } catch (Throwable th) {
            if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                cursorRawQuery.close();
            }
            throw th;
        }
    }

    /* JADX WARN: Code duplicated, block: B:24:0x0110  */
    public Pelanggan getNextPelangganUnRead(String str, String str2, String str3, String str4, String str5) {
        Pelanggan pelanggan;
        String strNextPelangganUnreadTime = this.queryHelper.nextPelangganUnreadTime(str, str2, str3, str4, str5);
        Pelanggan pelanggan2 = null;
        Cursor cursorRawQuery = getReadableDatabase().rawQuery(strNextPelangganUnreadTime, null);
        if (cursorRawQuery != null) {
            try {
                try {
                    if (cursorRawQuery.moveToFirst()) {
                        while (true) {
                            pelanggan = new Pelanggan();
                            try {
                                pelanggan.setCustCode(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_CODE")));
                                pelanggan.setCustName(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_NAME")));
                                pelanggan.setCustCode123(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_CODE123")));
                                pelanggan.setCustId(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_ID")));
                                pelanggan.setAlamat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("ALAMAT")));
                                pelanggan.setBillDate(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("TGL_CATAT")));
                                pelanggan.setBillStand1(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("bill_stand1")));
                                pelanggan.setTarif(cursorRawQuery.getString(cursorRawQuery.getColumnIndex(TarifDao.TABLENAME)));
                                pelanggan.setBillLonglat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_LONGLAT")));
                                pelanggan.setNoHp(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_NOHP")));
                                pelanggan.setBillBlId(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_BL_ID")));
                                pelanggan.setBillKdWmsizeid(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_KD_WMSIZEID")));
                                pelanggan.setBillNoUrutRute(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_NOURUTRUTE")));
                                pelanggan.setWmsn(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("PARAM2")));
                                pelanggan.setWaktuCatat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("WAKTU_CATAT")));
                                if (!cursorRawQuery.moveToNext()) {
                                    break;
                                }
                                pelanggan2 = pelanggan;
                            } catch (Exception unused) {
                                Log.d(this.TAG, "Error while trying to get posts from database");
                                if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                                }
                                return pelanggan;
                            }
                        }
                    } else {
                        pelanggan = null;
                    }
                    if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                        cursorRawQuery.close();
                    }
                } catch (Throwable th) {
                    if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                        cursorRawQuery.close();
                    }
                    throw th;
                }
            } catch (Exception unused2) {
                pelanggan = pelanggan2;
            }
        } else {
            pelanggan = null;
            if (cursorRawQuery != null) {
                cursorRawQuery.close();
            }
        }
        return pelanggan;
    }

    /* JADX WARN: Code duplicated, block: B:24:0x0110  */
    public Pelanggan getNextPelangganUnRead2(String str, String str2, String str3, String str4, String str5) {
        Pelanggan pelanggan;
        String strNextPelangganUnreadTime2 = this.queryHelper.nextPelangganUnreadTime2(str, str2, str3, str4, str5);
        Pelanggan pelanggan2 = null;
        Cursor cursorRawQuery = getReadableDatabase().rawQuery(strNextPelangganUnreadTime2, null);
        if (cursorRawQuery != null) {
            try {
                try {
                    if (cursorRawQuery.moveToFirst()) {
                        while (true) {
                            pelanggan = new Pelanggan();
                            try {
                                pelanggan.setCustCode(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_CODE")));
                                pelanggan.setCustName(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_NAME")));
                                pelanggan.setCustCode123(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_CODE123")));
                                pelanggan.setCustId(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_ID")));
                                pelanggan.setAlamat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("ALAMAT")));
                                pelanggan.setBillDate(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("TGL_CATAT")));
                                pelanggan.setBillStand1(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("bill_stand1")));
                                pelanggan.setTarif(cursorRawQuery.getString(cursorRawQuery.getColumnIndex(TarifDao.TABLENAME)));
                                pelanggan.setBillLonglat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_LONGLAT")));
                                pelanggan.setNoHp(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_NOHP")));
                                pelanggan.setBillBlId(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_BL_ID")));
                                pelanggan.setBillKdWmsizeid(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_KD_WMSIZEID")));
                                pelanggan.setBillNoUrutRute(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_NOURUTRUTE")));
                                pelanggan.setWmsn(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("PARAM2")));
                                pelanggan.setWaktuCatat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("WAKTU_CATAT")));
                                if (!cursorRawQuery.moveToNext()) {
                                    break;
                                }
                                pelanggan2 = pelanggan;
                            } catch (Exception unused) {
                                Log.d(this.TAG, "Error while trying to get posts from database");
                                if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                                }
                                return pelanggan;
                            }
                        }
                    } else {
                        pelanggan = null;
                    }
                    if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                        cursorRawQuery.close();
                    }
                } catch (Throwable th) {
                    if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                        cursorRawQuery.close();
                    }
                    throw th;
                }
            } catch (Exception unused2) {
                pelanggan = pelanggan2;
            }
        } else {
            pelanggan = null;
            if (cursorRawQuery != null) {
                cursorRawQuery.close();
            }
        }
        return pelanggan;
    }

    public Pelanggan getPrevPelangganUnRead(String str, String str2, String str3, String str4, String str5) {
        Pelanggan pelanggan;
        String strPrevPelangganUnreadTime = this.queryHelper.prevPelangganUnreadTime(str, str2, str3, str4, str5);
        Pelanggan pelanggan2 = null;
        Cursor cursorRawQuery = getReadableDatabase().rawQuery(strPrevPelangganUnreadTime, null);
        try {
            try {
                if (cursorRawQuery.moveToFirst()) {
                    while (true) {
                        pelanggan = new Pelanggan();
                        try {
                            pelanggan.setCustCode(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_CODE")));
                            pelanggan.setCustName(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_NAME")));
                            pelanggan.setCustCode123(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_CODE123")));
                            pelanggan.setCustId(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_ID")));
                            pelanggan.setAlamat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("ALAMAT")));
                            pelanggan.setBillDate(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("TGL_CATAT")));
                            pelanggan.setBillStand1(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("bill_stand1")));
                            pelanggan.setTarif(cursorRawQuery.getString(cursorRawQuery.getColumnIndex(TarifDao.TABLENAME)));
                            pelanggan.setBillLonglat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_LONGLAT")));
                            pelanggan.setNoHp(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_NOHP")));
                            pelanggan.setBillKdWmsizeid(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_KD_WMSIZEID")));
                            pelanggan.setBillBlId(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_BL_ID")));
                            pelanggan.setBillNoUrutRute(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_NOURUTRUTE")));
                            pelanggan.setWmsn(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("PARAM2")));
                            pelanggan.setWaktuCatat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("WAKTU_CATAT")));
                            if (!cursorRawQuery.moveToNext()) {
                                break;
                            }
                            pelanggan2 = pelanggan;
                        } catch (Exception unused) {
                            Log.d(this.TAG, "Error while trying to get posts from database");
                            if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                            }
                            return pelanggan;
                        }
                    }
                } else {
                    pelanggan = null;
                }
                if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                    cursorRawQuery.close();
                }
            } catch (Throwable th) {
                if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                    cursorRawQuery.close();
                }
                throw th;
            }
        } catch (Exception unused2) {
            pelanggan = pelanggan2;
        }
        return pelanggan;
    }

    public Pelanggan getPrevPelangganUnRead2(String str, String str2, String str3, String str4, String str5) {
        Pelanggan pelanggan;
        String strPrevPelangganUnreadTime2 = this.queryHelper.prevPelangganUnreadTime2(str, str2, str3, str4, str5);
        Pelanggan pelanggan2 = null;
        Cursor cursorRawQuery = getReadableDatabase().rawQuery(strPrevPelangganUnreadTime2, null);
        try {
            try {
                if (cursorRawQuery.moveToFirst()) {
                    while (true) {
                        pelanggan = new Pelanggan();
                        try {
                            pelanggan.setCustCode(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_CODE")));
                            pelanggan.setCustName(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_NAME")));
                            pelanggan.setCustCode123(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_CODE123")));
                            pelanggan.setCustId(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_ID")));
                            pelanggan.setAlamat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("ALAMAT")));
                            pelanggan.setBillDate(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("TGL_CATAT")));
                            pelanggan.setBillStand1(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("bill_stand1")));
                            pelanggan.setTarif(cursorRawQuery.getString(cursorRawQuery.getColumnIndex(TarifDao.TABLENAME)));
                            pelanggan.setBillLonglat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_LONGLAT")));
                            pelanggan.setNoHp(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_NOHP")));
                            pelanggan.setBillKdWmsizeid(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_KD_WMSIZEID")));
                            pelanggan.setBillBlId(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_BL_ID")));
                            pelanggan.setBillNoUrutRute(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_NOURUTRUTE")));
                            pelanggan.setWmsn(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("PARAM2")));
                            pelanggan.setWaktuCatat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("WAKTU_CATAT")));
                            if (!cursorRawQuery.moveToNext()) {
                                break;
                            }
                            pelanggan2 = pelanggan;
                        } catch (Exception unused) {
                            Log.d(this.TAG, "Error while trying to get posts from database");
                            if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                            }
                            return pelanggan;
                        }
                    }
                } else {
                    pelanggan = null;
                }
                if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                    cursorRawQuery.close();
                }
            } catch (Throwable th) {
                if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                    cursorRawQuery.close();
                }
                throw th;
            }
        } catch (Exception unused2) {
            pelanggan = pelanggan2;
        }
        return pelanggan;
    }

    /* JADX WARN: Code duplicated, block: B:24:0x011d  */
    public Pelanggan getNextPelangganRead(String str, String str2, String str3, String str4, String str5) {
        Pelanggan pelanggan;
        String strNextPelangganReadTime = this.queryHelper.nextPelangganReadTime(str, str2, str3, str4, str5);
        Pelanggan pelanggan2 = null;
        Cursor cursorRawQuery = getReadableDatabase().rawQuery(strNextPelangganReadTime, null);
        if (cursorRawQuery != null) {
            try {
                try {
                    if (cursorRawQuery.moveToFirst()) {
                        while (true) {
                            pelanggan = new Pelanggan();
                            try {
                                pelanggan.setCustCode(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_CODE")));
                                pelanggan.setCustName(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_NAME")));
                                pelanggan.setCustCode123(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_CODE123")));
                                pelanggan.setCustId(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_ID")));
                                pelanggan.setAlamat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("ALAMAT")));
                                pelanggan.setBillDate(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("TGL_CATAT")));
                                pelanggan.setBillStand1(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("bill_stand1")));
                                pelanggan.setTarif(cursorRawQuery.getString(cursorRawQuery.getColumnIndex(TarifDao.TABLENAME)));
                                pelanggan.setBillLonglat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_LONGLAT")));
                                pelanggan.setNoHp(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_NOHP")));
                                pelanggan.setBillBlId(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_BL_ID")));
                                pelanggan.setBillNoUrutRute(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_NOURUTRUTE")));
                                pelanggan.setBillIsRequest(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("bill_isrequest")));
                                pelanggan.setWmsn(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("PARAM2")));
                                pelanggan.setWaktuCatat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("WAKTU_CATAT")));
                                pelanggan.setIsUpload(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_IS_UPLOAD")));
                                if (!cursorRawQuery.moveToNext()) {
                                    break;
                                }
                                pelanggan2 = pelanggan;
                            } catch (Exception unused) {
                                Log.d(this.TAG, "Error while trying to get posts from database");
                                if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                                }
                                return pelanggan;
                            }
                        }
                    } else {
                        pelanggan = null;
                    }
                    if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                        cursorRawQuery.close();
                    }
                } catch (Throwable th) {
                    if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                        cursorRawQuery.close();
                    }
                    throw th;
                }
            } catch (Exception unused2) {
                pelanggan = pelanggan2;
            }
        } else {
            pelanggan = null;
            if (cursorRawQuery != null) {
                cursorRawQuery.close();
            }
        }
        return pelanggan;
    }

    public Pelanggan getPrevPelangganRead(String str, String str2, String str3, String str4, String str5) {
        Pelanggan pelanggan;
        String strPrevPelangganReadTime = this.queryHelper.prevPelangganReadTime(str, str2, str3, str4, str5);
        Pelanggan pelanggan2 = null;
        Cursor cursorRawQuery = getReadableDatabase().rawQuery(strPrevPelangganReadTime, null);
        try {
            try {
                if (cursorRawQuery.moveToFirst()) {
                    while (true) {
                        pelanggan = new Pelanggan();
                        try {
                            pelanggan.setCustCode(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_CODE")));
                            pelanggan.setCustName(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_NAME")));
                            pelanggan.setCustCode123(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_CODE123")));
                            pelanggan.setCustId(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_ID")));
                            pelanggan.setAlamat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("ALAMAT")));
                            pelanggan.setBillDate(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("TGL_CATAT")));
                            pelanggan.setBillStand1(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("bill_stand1")));
                            pelanggan.setTarif(cursorRawQuery.getString(cursorRawQuery.getColumnIndex(TarifDao.TABLENAME)));
                            pelanggan.setBillLonglat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_LONGLAT")));
                            pelanggan.setNoHp(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_NOHP")));
                            pelanggan.setBillBlId(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_BL_ID")));
                            pelanggan.setBillNoUrutRute(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_NOURUTRUTE")));
                            pelanggan.setBillIsRequest(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("bill_isrequest")));
                            pelanggan.setWaktuCatat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("WAKTU_CATAT")));
                            pelanggan.setIsUpload(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_IS_UPLOAD")));
                            if (!cursorRawQuery.moveToNext()) {
                                break;
                            }
                            pelanggan2 = pelanggan;
                        } catch (Exception unused) {
                            Log.d(this.TAG, "Error while trying to get posts from database");
                            if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                            }
                            return pelanggan;
                        }
                    }
                } else {
                    pelanggan = null;
                }
                if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                    cursorRawQuery.close();
                }
            } catch (Throwable th) {
                if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                    cursorRawQuery.close();
                }
                throw th;
            }
        } catch (Exception unused2) {
            pelanggan = pelanggan2;
        }
        return pelanggan;
    }

    public ArrayList<DataMeter> getDataMeterUpload(String str, String str2, String str3, String str4) {
        ArrayList<DataMeter> arrayList = new ArrayList<>();
        Cursor cursorRawQuery = getReadableDatabase().rawQuery(this.queryHelper.queryUpload(str, str2, str3, str4), null);
        try {
            try {
                if (cursorRawQuery.moveToFirst()) {
                    do {
                        DataMeter dataMeter = new DataMeter();
                        dataMeter.setBillId(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_ID")));
                        dataMeter.setCustId(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_ID")));
                        dataMeter.setCustCode123(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_CODE123")));
                        dataMeter.setBillStand1(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_STAND1")));
                        dataMeter.setBillStand2(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_STAND2")));
                        dataMeter.setBillPakai(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_PAKAI")));
                        dataMeter.setBillUangair(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_UANGAIR")));
                        dataMeter.setBillUangadm(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_UANGADM")));
                        dataMeter.setBillUangtax(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_UANGTAX")));
                        dataMeter.setBillAlCode(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_AL_CODE")));
                        dataMeter.setParam2(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("PERIODE")));
                        dataMeter.setBillMperiod(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_MPERIOD")));
                        dataMeter.setBillYperiod(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_YPERIOD")));
                        dataMeter.setTglCatat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("TGL_CATAT")));
                        dataMeter.setWaktuCatat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("WAKTU_CATAT")));
                        dataMeter.setBill_longlatcatat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_LONGLATCATAT")));
                        dataMeter.setBillWrUsername(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_WR_USERNAME")));
                        dataMeter.setBill_issegel(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_ISSEGEL")));
                        dataMeter.setBill_perubahan(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_PERUBAHAN")));
                        dataMeter.setBillNohp(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_NOHP")));
                        arrayList.add(dataMeter);
                    } while (cursorRawQuery.moveToNext());
                }
            } catch (Exception unused) {
                Log.d(this.TAG, "Error while trying to get posts from database");
            }
            return arrayList;
        } finally {
            if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                cursorRawQuery.close();
            }
        }
    }

    public String getStringListPelanggan(String str, String str2, String str3, String str4) {
        ArrayList arrayList = new ArrayList();
        Cursor cursorRawQuery = getReadableDatabase().rawQuery(this.queryHelper.queryUpload(str, str2, str3, str4), null);
        try {
            try {
                if (cursorRawQuery.moveToFirst()) {
                    do {
                        HashMap map = new HashMap();
                        map.put("bill_id", cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_ID")));
                        map.put("cust_id", cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_ID")));
                        map.put("cust_code", cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_CODE123")));
                        map.put("stand1", cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_STAND1")));
                        String string = cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_STAND2"));
                        if (string.equals("0")) {
                            map.put("stand2", string);
                            map.put("stand", "0");
                            map.put("pakai", "0");
                            map.put("uangair", "0");
                            map.put("uangadm", "0");
                        } else {
                            map.put("stand2", cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_STAND2")));
                            map.put("stand", cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_STAND2")));
                            map.put("pakai", cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_PAKAI")));
                            map.put("uangair", cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_UANGAIR")));
                            map.put("uangadm", cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_UANGADM")));
                        }
                        String string2 = cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_UANGTAX"));
                        if (string2.equals("")) {
                            string2 = "0";
                        }
                        map.put("uangtax", string2);
                        map.put("bill_status", cursorRawQuery.getString(cursorRawQuery.getColumnIndex("STATUS_CATAT")));
                        map.put("pengajuan", cursorRawQuery.isNull(cursorRawQuery.getColumnIndex("BILL_REQNOURUTBARU")) ? "" : cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_REQNOURUTBARU")));
                        map.put("selisih_meter", cursorRawQuery.getString(cursorRawQuery.getColumnIndex("MARGIN_METER")));
                        map.put("alasan_id", cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_AL_CODE")));
                        map.put("alasan_name", cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_ALNAME")));
                        map.put(LocalStorage.PERIODE, cursorRawQuery.getString(cursorRawQuery.getColumnIndex("PERIODE")));
                        map.put("m_period", cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_MPERIOD")));
                        map.put("y_period", cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_YPERIOD")));
                        map.put("tglcatat", cursorRawQuery.getString(cursorRawQuery.getColumnIndex("TGL_CATAT")));
                        map.put("waktucatat", cursorRawQuery.getString(cursorRawQuery.getColumnIndex("WAKTU_CATAT")));
                        String string3 = cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_LONGLATCATAT"));
                        if (string3 != null) {
                            map.put("longlat", string3);
                        } else {
                            map.put("longlat", "kosong");
                        }
                        map.put("writer", cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_WR_USERNAME")));
                        map.put("issegel", cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_ISSEGEL")));
                        map.put("perubahan", cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_PERUBAHAN")));
                        map.put("nohp", cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_NOHP")));
                        arrayList.add(map);
                    } while (cursorRawQuery.moveToNext());
                }
                if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                    cursorRawQuery.close();
                }
            } catch (Exception unused) {
                Log.d(this.TAG, "Error while trying to get posts from database");
                if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                }
            }
            return new GsonBuilder().create().toJson(arrayList);
        } catch (Throwable th) {
            if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                cursorRawQuery.close();
            }
            throw th;
        }
    }

    /* JADX WARN: Code duplicated, block: B:24:0x010b  */
    public ThreeMonth getThreeMonth(String str) {
        ThreeMonth threeMonth;
        ThreeMonth threeMonth2 = null;
        Cursor cursorRawQuery = getReadableDatabase().rawQuery(this.queryHelper.getThreeMonth(str), null);
        if (cursorRawQuery != null) {
            try {
                try {
                    if (cursorRawQuery.moveToFirst()) {
                        while (true) {
                            threeMonth = new ThreeMonth();
                            try {
                                threeMonth.setPeriod1(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("PERIOD1")));
                                threeMonth.setPeriod1Stand1(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("PERIOD1_STAND1")));
                                threeMonth.setPeriod1Stand2(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("PERIOD1_STAND2")));
                                threeMonth.setPeriod1Usage(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("PERIOD1_USAGE")));
                                threeMonth.setPeriod1Tagihan(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("PERIOD1_TAGIHAN")));
                                threeMonth.setPeriod2(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("PERIOD2")));
                                threeMonth.setPeriod2Stand1(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("PERIOD2_STAND1")));
                                threeMonth.setPeriod2Stand2(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("PERIOD2_STAND2")));
                                threeMonth.setPeriod2Usage(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("PERIOD2_USAGE")));
                                threeMonth.setPeriod2Tagihan(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("PERIOD2_TAGIHAN")));
                                threeMonth.setPeriod3(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("PERIOD3")));
                                threeMonth.setPeriod3Stand1(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("PERIOD3_STAND1")));
                                threeMonth.setPeriod3Stand2(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("PERIOD3_STAND2")));
                                threeMonth.setPeriod3Usage(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("PERIOD3_USAGE")));
                                threeMonth.setPeriod3Tagihan(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("PERIOD3_TAGIHAN")));
                                if (!cursorRawQuery.moveToNext()) {
                                    break;
                                }
                                threeMonth2 = threeMonth;
                            } catch (Exception unused) {
                                Log.d(this.TAG, "Error while trying to get posts from database");
                                if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                                }
                                return threeMonth;
                            }
                        }
                    } else {
                        threeMonth = null;
                    }
                    if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                        cursorRawQuery.close();
                    }
                } catch (Throwable th) {
                    if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                        cursorRawQuery.close();
                    }
                    throw th;
                }
            } catch (Exception unused2) {
                threeMonth = threeMonth2;
            }
        } else {
            threeMonth = null;
            if (cursorRawQuery != null) {
                cursorRawQuery.close();
            }
        }
        return threeMonth;
    }

    public boolean gantiRute(String str, String str2) {
        SQLiteDatabase readableDatabase = getReadableDatabase();
        try {
            ContentValues contentValues = new ContentValues();
            contentValues.put("BILL_REQNOURUTBARU", str2);
            readableDatabase.update(DataMeterDao.TABLENAME, contentValues, "CUST_CODE123=?", new String[]{str});
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            Log.e(this.TAG, "gantiRute: " + e.getMessage());
            this.dirUtil.generateNoteOnSD("ActivityCatatStand Ganti No urut() (7) : " + e.getMessage());
            return false;
        }
    }

    public void updateSyncStatus(Integer num, Integer num2) {
        SQLiteDatabase writableDatabase = getWritableDatabase();
        String str = "UPDATE DATA_METER set bill_isrequest=0, bill_is_upload=" + num2 + " WHERE bill_id=" + num + "";
        Log.d("UpdateSyncStatus", str);
        writableDatabase.execSQL(str);
        writableDatabase.close();
    }

    public boolean updateStandNormal(DataMeter dataMeter, String str) {
        SQLiteDatabase readableDatabase = getReadableDatabase();
        try {
            ContentValues contentValues = new ContentValues();
            contentValues.put("TGL_CATAT", dataMeter.getTglCatat());
            contentValues.put("WAKTU_CATAT", dataMeter.getWaktuCatat());
            if (dataMeter.getBillStand2().isEmpty()) {
                contentValues.put("BILL_STAND2", dataMeter.getBillStand1());
                contentValues.put("BILL_PAKAI", "");
                contentValues.put("BILL_UANGAIR", "");
                contentValues.put("BILL_UANGADM", "");
                contentValues.put("BILL_UANGTAX", "");
            } else {
                contentValues.put("BILL_STAND2", dataMeter.getBillStand2());
                contentValues.put("BILL_PAKAI", dataMeter.getBillPakai());
                contentValues.put("BILL_UANGAIR", dataMeter.getBillUangair());
                contentValues.put("BILL_UANGADM", dataMeter.getBillUangadm());
                contentValues.put("BILL_UANGTAX", dataMeter.getBillUangtax());
            }
            contentValues.put("BILL_NOHP", dataMeter.getBillNohp());
            contentValues.put("STATUS_CATAT", dataMeter.getParam1());
            contentValues.put("BILL_AL_CODE", dataMeter.getBillAlCode());
            contentValues.put("BILL_ALNAME", dataMeter.getBillAlname());
            contentValues.put("BILL_WR_USERNAME", dataMeter.getBillWrUsername());
            contentValues.put("BILL_IS_UPLOAD", dataMeter.getBillIsUpload());
            contentValues.put("bill_isrequest", dataMeter.getBillIsrequest());
            contentValues.put("BILL_LONGLATCATAT", dataMeter.getBillLonglat());
            contentValues.put("BILL_PERUBAHAN", dataMeter.getBill_perubahan());
            contentValues.put("BILL_ISSEGEL", dataMeter.getBill_issegel());
            readableDatabase.update(DataMeterDao.TABLENAME, contentValues, "BILL_ID =?", new String[]{str});
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            this.dirUtil.generateNoteOnSD("Activity CatatStand SimpanNormally() (7) : " + e.getMessage());
            return false;
        }
    }

    /* JADX WARN: Code duplicated, block: B:27:0x00f2  */
    public DataMeter getCurrentMonth(String str) {
        Exception e;
        DataMeter dataMeter;
        DataMeter dataMeter2 = null;
        Cursor cursorRawQuery = getReadableDatabase().rawQuery(this.queryHelper.currentBill(str), null);
        if (cursorRawQuery != null) {
            try {
                try {
                    if (cursorRawQuery.moveToFirst()) {
                        while (true) {
                            dataMeter = new DataMeter();
                            try {
                                dataMeter.setCustCode123(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("CUST_CODE123")));
                                dataMeter.setBillStand1(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_STAND1")));
                                dataMeter.setBillStand2(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_STAND2")));
                                dataMeter.setBillUangair(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_UANGAIR")));
                                dataMeter.setBillUangadm(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_UANGADM")));
                                dataMeter.setBillUangtax(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_UANGTAX")));
                                dataMeter.setBillAlCode(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_AL_CODE")));
                                dataMeter.setBillAlname(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_ALNAME")));
                                dataMeter.setBillPakai(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("BILL_PAKAI")));
                                dataMeter.setTglCatat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("TGL_CATAT")));
                                dataMeter.setWaktuCatat(cursorRawQuery.getString(cursorRawQuery.getColumnIndex("WAKTU_CATAT")));
                                if (!cursorRawQuery.moveToNext()) {
                                    break;
                                }
                                dataMeter2 = dataMeter;
                            } catch (Exception e2) {
                                e = e2;
                                e.printStackTrace();
                                this.dirUtil.generateNoteOnSD("currentbil" + e.getMessage());
                                if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                                }
                                return dataMeter;
                            }
                        }
                    } else {
                        dataMeter = null;
                    }
                    if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                        cursorRawQuery.close();
                    }
                } catch (Throwable th) {
                    if (cursorRawQuery != null && !cursorRawQuery.isClosed()) {
                        cursorRawQuery.close();
                    }
                    throw th;
                }
            } catch (Exception e3) {
                DataMeter dataMeter3 = dataMeter2;
                e = e3;
                dataMeter = dataMeter3;
            }
        } else {
            dataMeter = null;
            if (cursorRawQuery != null) {
                cursorRawQuery.close();
            }
        }
        return dataMeter;
    }

    public HashMap<String, Integer> getDashboardPorgress(String str, String str2, String str3) {
        HashMap<String, Integer> map = new HashMap<>();
        Cursor cursorRawQuery = getReadableDatabase().rawQuery(this.queryHelper.progressWriter(str, str2, str3), null);
        if (cursorRawQuery != null && cursorRawQuery.moveToFirst()) {
            do {
                if (cursorRawQuery.getInt(0) == 1) {
                    map.put("totalBilling", Integer.valueOf(cursorRawQuery.getInt(2)));
                } else if (cursorRawQuery.getInt(0) == 2) {
                    map.put("readBilling", Integer.valueOf(cursorRawQuery.getInt(2)));
                }
            } while (cursorRawQuery.moveToNext());
        }
        return map;
    }

    public int getTodayReading(String str, String str2) {
        int i;
        Cursor cursorRawQuery = getReadableDatabase().rawQuery(this.queryHelper.todayReading(str, str2), null);
        if (cursorRawQuery == null || !cursorRawQuery.moveToFirst()) {
            return 0;
        }
        do {
            i = cursorRawQuery.getInt(cursorRawQuery.getColumnIndex("TODAY_READING"));
        } while (cursorRawQuery.moveToNext());
        return i;
    }

    public int getNotUpload(String str) {
        int i;
        Cursor cursorRawQuery = getReadableDatabase().rawQuery(this.queryHelper.notUpload(str), null);
        if (cursorRawQuery == null || !cursorRawQuery.moveToFirst()) {
            return 0;
        }
        do {
            i = cursorRawQuery.getInt(cursorRawQuery.getColumnIndex("NOT_UPLOAD"));
        } while (cursorRawQuery.moveToNext());
        return i;
    }
}
