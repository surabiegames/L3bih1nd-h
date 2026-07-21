package com.aurora.bdg.model;

import android.database.Cursor;
import android.database.sqlite.SQLiteStatement;
import org.greenrobot.greendao.AbstractDao;
import org.greenrobot.greendao.Property;
import org.greenrobot.greendao.database.Database;
import org.greenrobot.greendao.database.DatabaseStatement;
import org.greenrobot.greendao.internal.DaoConfig;

/* JADX INFO: loaded from: classes.dex */
public class AlasanDao extends AbstractDao<Alasan, Long> {
    public static final String TABLENAME = "ALASAN";

    public static class Properties {
        public static final Property Id = new Property(0, Long.class, "id", true, "_id");
        public static final Property AlId = new Property(1, String.class, "alId", false, "AL_ID");
        public static final Property AlName = new Property(2, String.class, "alName", false, "AL_NAME");
    }

    @Override // org.greenrobot.greendao.AbstractDao
    protected final boolean isEntityUpdateable() {
        return true;
    }

    public AlasanDao(DaoConfig daoConfig) {
        super(daoConfig);
    }

    public AlasanDao(DaoConfig daoConfig, DaoSession daoSession) {
        super(daoConfig, daoSession);
    }

    public static void createTable(Database database, boolean z) {
        database.execSQL("CREATE TABLE " + (z ? "IF NOT EXISTS " : "") + "\"ALASAN\" (\"_id\" INTEGER PRIMARY KEY AUTOINCREMENT ,\"AL_ID\" TEXT,\"AL_NAME\" TEXT);");
    }

    public static void dropTable(Database database, boolean z) {
        StringBuilder sb = new StringBuilder();
        sb.append("DROP TABLE ");
        sb.append(z ? "IF EXISTS " : "");
        sb.append("\"ALASAN\"");
        database.execSQL(sb.toString());
    }

    /* JADX INFO: Access modifiers changed from: protected */
    @Override // org.greenrobot.greendao.AbstractDao
    public final void bindValues(DatabaseStatement databaseStatement, Alasan alasan) {
        databaseStatement.clearBindings();
        Long id = alasan.getId();
        if (id != null) {
            databaseStatement.bindLong(1, id.longValue());
        }
        String alId = alasan.getAlId();
        if (alId != null) {
            databaseStatement.bindString(2, alId);
        }
        String alName = alasan.getAlName();
        if (alName != null) {
            databaseStatement.bindString(3, alName);
        }
    }

    /* JADX INFO: Access modifiers changed from: protected */
    @Override // org.greenrobot.greendao.AbstractDao
    public final void bindValues(SQLiteStatement sQLiteStatement, Alasan alasan) {
        sQLiteStatement.clearBindings();
        Long id = alasan.getId();
        if (id != null) {
            sQLiteStatement.bindLong(1, id.longValue());
        }
        String alId = alasan.getAlId();
        if (alId != null) {
            sQLiteStatement.bindString(2, alId);
        }
        String alName = alasan.getAlName();
        if (alName != null) {
            sQLiteStatement.bindString(3, alName);
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
    public Alasan readEntity(Cursor cursor, int i) {
        int i2 = i + 0;
        int i3 = i + 1;
        int i4 = i + 2;
        return new Alasan(cursor.isNull(i2) ? null : Long.valueOf(cursor.getLong(i2)), cursor.isNull(i3) ? null : cursor.getString(i3), cursor.isNull(i4) ? null : cursor.getString(i4));
    }

    @Override // org.greenrobot.greendao.AbstractDao
    public void readEntity(Cursor cursor, Alasan alasan, int i) {
        int i2 = i + 0;
        alasan.setId(cursor.isNull(i2) ? null : Long.valueOf(cursor.getLong(i2)));
        int i3 = i + 1;
        alasan.setAlId(cursor.isNull(i3) ? null : cursor.getString(i3));
        int i4 = i + 2;
        alasan.setAlName(cursor.isNull(i4) ? null : cursor.getString(i4));
    }

    /* JADX INFO: Access modifiers changed from: protected */
    @Override // org.greenrobot.greendao.AbstractDao
    public final Long updateKeyAfterInsert(Alasan alasan, long j) {
        alasan.setId(Long.valueOf(j));
        return Long.valueOf(j);
    }

    @Override // org.greenrobot.greendao.AbstractDao
    public Long getKey(Alasan alasan) {
        if (alasan != null) {
            return alasan.getId();
        }
        return null;
    }

    @Override // org.greenrobot.greendao.AbstractDao
    public boolean hasKey(Alasan alasan) {
        return alasan.getId() != null;
    }
}
