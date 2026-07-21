package com.aurora.bdg.model;

import android.database.Cursor;
import android.database.sqlite.SQLiteStatement;
import org.greenrobot.greendao.AbstractDao;
import org.greenrobot.greendao.Property;
import org.greenrobot.greendao.database.Database;
import org.greenrobot.greendao.database.DatabaseStatement;
import org.greenrobot.greendao.internal.DaoConfig;

/* JADX INFO: loaded from: classes.dex */
public class WmsizeDao extends AbstractDao<Wmsize, Long> {
    public static final String TABLENAME = "WMSIZE";

    public static class Properties {
        public static final Property Id = new Property(0, Long.class, "id", true, "_id");
        public static final Property WmzId = new Property(1, String.class, "wmzId", false, "WMZ_ID");
        public static final Property WmzSize = new Property(2, String.class, "wmzSize", false, "WMZ_SIZE");
        public static final Property WmzCode = new Property(3, String.class, "wmzCode", false, "WMZ_CODE");
        public static final Property BiPemel = new Property(4, String.class, "biPemel", false, "BI_PEMEL");
    }

    @Override // org.greenrobot.greendao.AbstractDao
    protected final boolean isEntityUpdateable() {
        return true;
    }

    public WmsizeDao(DaoConfig daoConfig) {
        super(daoConfig);
    }

    public WmsizeDao(DaoConfig daoConfig, DaoSession daoSession) {
        super(daoConfig, daoSession);
    }

    public static void createTable(Database database, boolean z) {
        database.execSQL("CREATE TABLE " + (z ? "IF NOT EXISTS " : "") + "\"WMSIZE\" (\"_id\" INTEGER PRIMARY KEY AUTOINCREMENT ,\"WMZ_ID\" TEXT,\"WMZ_SIZE\" TEXT,\"WMZ_CODE\" TEXT,\"BI_PEMEL\" TEXT);");
    }

    public static void dropTable(Database database, boolean z) {
        StringBuilder sb = new StringBuilder();
        sb.append("DROP TABLE ");
        sb.append(z ? "IF EXISTS " : "");
        sb.append("\"WMSIZE\"");
        database.execSQL(sb.toString());
    }

    /* JADX INFO: Access modifiers changed from: protected */
    @Override // org.greenrobot.greendao.AbstractDao
    public final void bindValues(DatabaseStatement databaseStatement, Wmsize wmsize) {
        databaseStatement.clearBindings();
        Long id = wmsize.getId();
        if (id != null) {
            databaseStatement.bindLong(1, id.longValue());
        }
        String wmzId = wmsize.getWmzId();
        if (wmzId != null) {
            databaseStatement.bindString(2, wmzId);
        }
        String wmzSize = wmsize.getWmzSize();
        if (wmzSize != null) {
            databaseStatement.bindString(3, wmzSize);
        }
        String wmzCode = wmsize.getWmzCode();
        if (wmzCode != null) {
            databaseStatement.bindString(4, wmzCode);
        }
        String biPemel = wmsize.getBiPemel();
        if (biPemel != null) {
            databaseStatement.bindString(5, biPemel);
        }
    }

    /* JADX INFO: Access modifiers changed from: protected */
    @Override // org.greenrobot.greendao.AbstractDao
    public final void bindValues(SQLiteStatement sQLiteStatement, Wmsize wmsize) {
        sQLiteStatement.clearBindings();
        Long id = wmsize.getId();
        if (id != null) {
            sQLiteStatement.bindLong(1, id.longValue());
        }
        String wmzId = wmsize.getWmzId();
        if (wmzId != null) {
            sQLiteStatement.bindString(2, wmzId);
        }
        String wmzSize = wmsize.getWmzSize();
        if (wmzSize != null) {
            sQLiteStatement.bindString(3, wmzSize);
        }
        String wmzCode = wmsize.getWmzCode();
        if (wmzCode != null) {
            sQLiteStatement.bindString(4, wmzCode);
        }
        String biPemel = wmsize.getBiPemel();
        if (biPemel != null) {
            sQLiteStatement.bindString(5, biPemel);
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
    public Wmsize readEntity(Cursor cursor, int i) {
        int i2 = i + 0;
        Long lValueOf = cursor.isNull(i2) ? null : Long.valueOf(cursor.getLong(i2));
        int i3 = i + 1;
        String string = cursor.isNull(i3) ? null : cursor.getString(i3);
        int i4 = i + 2;
        String string2 = cursor.isNull(i4) ? null : cursor.getString(i4);
        int i5 = i + 3;
        int i6 = i + 4;
        return new Wmsize(lValueOf, string, string2, cursor.isNull(i5) ? null : cursor.getString(i5), cursor.isNull(i6) ? null : cursor.getString(i6));
    }

    @Override // org.greenrobot.greendao.AbstractDao
    public void readEntity(Cursor cursor, Wmsize wmsize, int i) {
        int i2 = i + 0;
        wmsize.setId(cursor.isNull(i2) ? null : Long.valueOf(cursor.getLong(i2)));
        int i3 = i + 1;
        wmsize.setWmzId(cursor.isNull(i3) ? null : cursor.getString(i3));
        int i4 = i + 2;
        wmsize.setWmzSize(cursor.isNull(i4) ? null : cursor.getString(i4));
        int i5 = i + 3;
        wmsize.setWmzCode(cursor.isNull(i5) ? null : cursor.getString(i5));
        int i6 = i + 4;
        wmsize.setBiPemel(cursor.isNull(i6) ? null : cursor.getString(i6));
    }

    /* JADX INFO: Access modifiers changed from: protected */
    @Override // org.greenrobot.greendao.AbstractDao
    public final Long updateKeyAfterInsert(Wmsize wmsize, long j) {
        wmsize.setId(Long.valueOf(j));
        return Long.valueOf(j);
    }

    @Override // org.greenrobot.greendao.AbstractDao
    public Long getKey(Wmsize wmsize) {
        if (wmsize != null) {
            return wmsize.getId();
        }
        return null;
    }

    @Override // org.greenrobot.greendao.AbstractDao
    public boolean hasKey(Wmsize wmsize) {
        return wmsize.getId() != null;
    }
}
