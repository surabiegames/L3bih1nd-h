package com.aurora.bdg.model;

import android.database.Cursor;
import android.database.sqlite.SQLiteStatement;
import org.greenrobot.greendao.AbstractDao;
import org.greenrobot.greendao.Property;
import org.greenrobot.greendao.database.Database;
import org.greenrobot.greendao.database.DatabaseStatement;
import org.greenrobot.greendao.internal.DaoConfig;

/* JADX INFO: loaded from: classes.dex */
public class WaterTarifDao extends AbstractDao<WaterTarif, Long> {
    public static final String TABLENAME = "WATER_TARIF";

    public static class Properties {
        public static final Property Id = new Property(0, Long.class, "id", true, "_id");
        public static final Property WtId = new Property(1, String.class, "wtId", false, "WT_ID");
        public static final Property TrfTypeId = new Property(2, String.class, "trfTypeId", false, "TRF_TYPE_ID");
        public static final Property WtBottom1 = new Property(3, String.class, "wtBottom1", false, "WT_BOTTOM1");
        public static final Property WtTop1 = new Property(4, String.class, "wtTop1", false, "WT_TOP1");
        public static final Property WtCost1 = new Property(5, String.class, "wtCost1", false, "WT_COST1");
        public static final Property WtBottom2 = new Property(6, String.class, "wtBottom2", false, "WT_BOTTOM2");
        public static final Property WtTop2 = new Property(7, String.class, "wtTop2", false, "WT_TOP2");
        public static final Property WtCost2 = new Property(8, String.class, "wtCost2", false, "WT_COST2");
        public static final Property WtBottom3 = new Property(9, String.class, "wtBottom3", false, "WT_BOTTOM3");
        public static final Property WtTop3 = new Property(10, String.class, "wtTop3", false, "WT_TOP3");
        public static final Property WtCost3 = new Property(11, String.class, "wtCost3", false, "WT_COST3");
        public static final Property WtBottom4 = new Property(12, String.class, "wtBottom4", false, "WT_BOTTOM4");
        public static final Property WtTop4 = new Property(13, String.class, "wtTop4", false, "WT_TOP4");
        public static final Property WtCost4 = new Property(14, String.class, "wtCost4", false, "WT_COST4");
    }

    @Override // org.greenrobot.greendao.AbstractDao
    protected final boolean isEntityUpdateable() {
        return true;
    }

    public WaterTarifDao(DaoConfig daoConfig) {
        super(daoConfig);
    }

    public WaterTarifDao(DaoConfig daoConfig, DaoSession daoSession) {
        super(daoConfig, daoSession);
    }

    public static void createTable(Database database, boolean z) {
        database.execSQL("CREATE TABLE " + (z ? "IF NOT EXISTS " : "") + "\"WATER_TARIF\" (\"_id\" INTEGER PRIMARY KEY AUTOINCREMENT ,\"WT_ID\" TEXT,\"TRF_TYPE_ID\" TEXT,\"WT_BOTTOM1\" TEXT,\"WT_TOP1\" TEXT,\"WT_COST1\" TEXT,\"WT_BOTTOM2\" TEXT,\"WT_TOP2\" TEXT,\"WT_COST2\" TEXT,\"WT_BOTTOM3\" TEXT,\"WT_TOP3\" TEXT,\"WT_COST3\" TEXT,\"WT_BOTTOM4\" TEXT,\"WT_TOP4\" TEXT,\"WT_COST4\" TEXT);");
    }

    public static void dropTable(Database database, boolean z) {
        StringBuilder sb = new StringBuilder();
        sb.append("DROP TABLE ");
        sb.append(z ? "IF EXISTS " : "");
        sb.append("\"WATER_TARIF\"");
        database.execSQL(sb.toString());
    }

    /* JADX INFO: Access modifiers changed from: protected */
    @Override // org.greenrobot.greendao.AbstractDao
    public final void bindValues(DatabaseStatement databaseStatement, WaterTarif waterTarif) {
        databaseStatement.clearBindings();
        Long id = waterTarif.getId();
        if (id != null) {
            databaseStatement.bindLong(1, id.longValue());
        }
        String wtId = waterTarif.getWtId();
        if (wtId != null) {
            databaseStatement.bindString(2, wtId);
        }
        String trfTypeId = waterTarif.getTrfTypeId();
        if (trfTypeId != null) {
            databaseStatement.bindString(3, trfTypeId);
        }
        String wtBottom1 = waterTarif.getWtBottom1();
        if (wtBottom1 != null) {
            databaseStatement.bindString(4, wtBottom1);
        }
        String wtTop1 = waterTarif.getWtTop1();
        if (wtTop1 != null) {
            databaseStatement.bindString(5, wtTop1);
        }
        String wtCost1 = waterTarif.getWtCost1();
        if (wtCost1 != null) {
            databaseStatement.bindString(6, wtCost1);
        }
        String wtBottom2 = waterTarif.getWtBottom2();
        if (wtBottom2 != null) {
            databaseStatement.bindString(7, wtBottom2);
        }
        String wtTop2 = waterTarif.getWtTop2();
        if (wtTop2 != null) {
            databaseStatement.bindString(8, wtTop2);
        }
        String wtCost2 = waterTarif.getWtCost2();
        if (wtCost2 != null) {
            databaseStatement.bindString(9, wtCost2);
        }
        String wtBottom3 = waterTarif.getWtBottom3();
        if (wtBottom3 != null) {
            databaseStatement.bindString(10, wtBottom3);
        }
        String wtTop3 = waterTarif.getWtTop3();
        if (wtTop3 != null) {
            databaseStatement.bindString(11, wtTop3);
        }
        String wtCost3 = waterTarif.getWtCost3();
        if (wtCost3 != null) {
            databaseStatement.bindString(12, wtCost3);
        }
        String wtBottom4 = waterTarif.getWtBottom4();
        if (wtBottom4 != null) {
            databaseStatement.bindString(13, wtBottom4);
        }
        String wtTop4 = waterTarif.getWtTop4();
        if (wtTop4 != null) {
            databaseStatement.bindString(14, wtTop4);
        }
        String wtCost4 = waterTarif.getWtCost4();
        if (wtCost4 != null) {
            databaseStatement.bindString(15, wtCost4);
        }
    }

    /* JADX INFO: Access modifiers changed from: protected */
    @Override // org.greenrobot.greendao.AbstractDao
    public final void bindValues(SQLiteStatement sQLiteStatement, WaterTarif waterTarif) {
        sQLiteStatement.clearBindings();
        Long id = waterTarif.getId();
        if (id != null) {
            sQLiteStatement.bindLong(1, id.longValue());
        }
        String wtId = waterTarif.getWtId();
        if (wtId != null) {
            sQLiteStatement.bindString(2, wtId);
        }
        String trfTypeId = waterTarif.getTrfTypeId();
        if (trfTypeId != null) {
            sQLiteStatement.bindString(3, trfTypeId);
        }
        String wtBottom1 = waterTarif.getWtBottom1();
        if (wtBottom1 != null) {
            sQLiteStatement.bindString(4, wtBottom1);
        }
        String wtTop1 = waterTarif.getWtTop1();
        if (wtTop1 != null) {
            sQLiteStatement.bindString(5, wtTop1);
        }
        String wtCost1 = waterTarif.getWtCost1();
        if (wtCost1 != null) {
            sQLiteStatement.bindString(6, wtCost1);
        }
        String wtBottom2 = waterTarif.getWtBottom2();
        if (wtBottom2 != null) {
            sQLiteStatement.bindString(7, wtBottom2);
        }
        String wtTop2 = waterTarif.getWtTop2();
        if (wtTop2 != null) {
            sQLiteStatement.bindString(8, wtTop2);
        }
        String wtCost2 = waterTarif.getWtCost2();
        if (wtCost2 != null) {
            sQLiteStatement.bindString(9, wtCost2);
        }
        String wtBottom3 = waterTarif.getWtBottom3();
        if (wtBottom3 != null) {
            sQLiteStatement.bindString(10, wtBottom3);
        }
        String wtTop3 = waterTarif.getWtTop3();
        if (wtTop3 != null) {
            sQLiteStatement.bindString(11, wtTop3);
        }
        String wtCost3 = waterTarif.getWtCost3();
        if (wtCost3 != null) {
            sQLiteStatement.bindString(12, wtCost3);
        }
        String wtBottom4 = waterTarif.getWtBottom4();
        if (wtBottom4 != null) {
            sQLiteStatement.bindString(13, wtBottom4);
        }
        String wtTop4 = waterTarif.getWtTop4();
        if (wtTop4 != null) {
            sQLiteStatement.bindString(14, wtTop4);
        }
        String wtCost4 = waterTarif.getWtCost4();
        if (wtCost4 != null) {
            sQLiteStatement.bindString(15, wtCost4);
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
    public WaterTarif readEntity(Cursor cursor, int i) {
        int i2 = i + 0;
        int i3 = i + 1;
        int i4 = i + 2;
        int i5 = i + 3;
        int i6 = i + 4;
        int i7 = i + 5;
        int i8 = i + 6;
        int i9 = i + 7;
        int i10 = i + 8;
        int i11 = i + 9;
        int i12 = i + 10;
        int i13 = i + 11;
        int i14 = i + 12;
        int i15 = i + 13;
        int i16 = i + 14;
        return new WaterTarif(cursor.isNull(i2) ? null : Long.valueOf(cursor.getLong(i2)), cursor.isNull(i3) ? null : cursor.getString(i3), cursor.isNull(i4) ? null : cursor.getString(i4), cursor.isNull(i5) ? null : cursor.getString(i5), cursor.isNull(i6) ? null : cursor.getString(i6), cursor.isNull(i7) ? null : cursor.getString(i7), cursor.isNull(i8) ? null : cursor.getString(i8), cursor.isNull(i9) ? null : cursor.getString(i9), cursor.isNull(i10) ? null : cursor.getString(i10), cursor.isNull(i11) ? null : cursor.getString(i11), cursor.isNull(i12) ? null : cursor.getString(i12), cursor.isNull(i13) ? null : cursor.getString(i13), cursor.isNull(i14) ? null : cursor.getString(i14), cursor.isNull(i15) ? null : cursor.getString(i15), cursor.isNull(i16) ? null : cursor.getString(i16));
    }

    @Override // org.greenrobot.greendao.AbstractDao
    public void readEntity(Cursor cursor, WaterTarif waterTarif, int i) {
        int i2 = i + 0;
        waterTarif.setId(cursor.isNull(i2) ? null : Long.valueOf(cursor.getLong(i2)));
        int i3 = i + 1;
        waterTarif.setWtId(cursor.isNull(i3) ? null : cursor.getString(i3));
        int i4 = i + 2;
        waterTarif.setTrfTypeId(cursor.isNull(i4) ? null : cursor.getString(i4));
        int i5 = i + 3;
        waterTarif.setWtBottom1(cursor.isNull(i5) ? null : cursor.getString(i5));
        int i6 = i + 4;
        waterTarif.setWtTop1(cursor.isNull(i6) ? null : cursor.getString(i6));
        int i7 = i + 5;
        waterTarif.setWtCost1(cursor.isNull(i7) ? null : cursor.getString(i7));
        int i8 = i + 6;
        waterTarif.setWtBottom2(cursor.isNull(i8) ? null : cursor.getString(i8));
        int i9 = i + 7;
        waterTarif.setWtTop2(cursor.isNull(i9) ? null : cursor.getString(i9));
        int i10 = i + 8;
        waterTarif.setWtCost2(cursor.isNull(i10) ? null : cursor.getString(i10));
        int i11 = i + 9;
        waterTarif.setWtBottom3(cursor.isNull(i11) ? null : cursor.getString(i11));
        int i12 = i + 10;
        waterTarif.setWtTop3(cursor.isNull(i12) ? null : cursor.getString(i12));
        int i13 = i + 11;
        waterTarif.setWtCost3(cursor.isNull(i13) ? null : cursor.getString(i13));
        int i14 = i + 12;
        waterTarif.setWtBottom4(cursor.isNull(i14) ? null : cursor.getString(i14));
        int i15 = i + 13;
        waterTarif.setWtTop4(cursor.isNull(i15) ? null : cursor.getString(i15));
        int i16 = i + 14;
        waterTarif.setWtCost4(cursor.isNull(i16) ? null : cursor.getString(i16));
    }

    /* JADX INFO: Access modifiers changed from: protected */
    @Override // org.greenrobot.greendao.AbstractDao
    public final Long updateKeyAfterInsert(WaterTarif waterTarif, long j) {
        waterTarif.setId(Long.valueOf(j));
        return Long.valueOf(j);
    }

    @Override // org.greenrobot.greendao.AbstractDao
    public Long getKey(WaterTarif waterTarif) {
        if (waterTarif != null) {
            return waterTarif.getId();
        }
        return null;
    }

    @Override // org.greenrobot.greendao.AbstractDao
    public boolean hasKey(WaterTarif waterTarif) {
        return waterTarif.getId() != null;
    }
}
