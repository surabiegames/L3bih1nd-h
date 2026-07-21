package com.aurora.bdg.model;

import android.database.Cursor;
import android.database.sqlite.SQLiteStatement;
import org.greenrobot.greendao.AbstractDao;
import org.greenrobot.greendao.Property;
import org.greenrobot.greendao.database.Database;
import org.greenrobot.greendao.database.DatabaseStatement;
import org.greenrobot.greendao.internal.DaoConfig;

/* JADX INFO: loaded from: classes.dex */
public class PetugasDao extends AbstractDao<Petugas, Long> {
    public static final String TABLENAME = "PETUGAS";

    public static class Properties {
        public static final Property Id = new Property(0, Long.class, "id", true, "_id");
        public static final Property WrId = new Property(1, String.class, "wrId", false, "WR_ID");
        public static final Property WrUserName = new Property(2, String.class, "wrUserName", false, "WR_USER_NAME");
        public static final Property WrName = new Property(3, String.class, "wrName", false, "WR_NAME");
        public static final Property WrPass = new Property(4, String.class, "wrPass", false, "WR_PASS");
        public static final Property WrIsLogin = new Property(5, String.class, "wrIsLogin", false, "WR_IS_LOGIN");
    }

    @Override // org.greenrobot.greendao.AbstractDao
    protected final boolean isEntityUpdateable() {
        return true;
    }

    public PetugasDao(DaoConfig daoConfig) {
        super(daoConfig);
    }

    public PetugasDao(DaoConfig daoConfig, DaoSession daoSession) {
        super(daoConfig, daoSession);
    }

    public static void createTable(Database database, boolean z) {
        database.execSQL("CREATE TABLE " + (z ? "IF NOT EXISTS " : "") + "\"PETUGAS\" (\"_id\" INTEGER PRIMARY KEY AUTOINCREMENT ,\"WR_ID\" TEXT,\"WR_USER_NAME\" TEXT,\"WR_NAME\" TEXT,\"WR_PASS\" TEXT,\"WR_IS_LOGIN\" TEXT);");
    }

    public static void dropTable(Database database, boolean z) {
        StringBuilder sb = new StringBuilder();
        sb.append("DROP TABLE ");
        sb.append(z ? "IF EXISTS " : "");
        sb.append("\"PETUGAS\"");
        database.execSQL(sb.toString());
    }

    /* JADX INFO: Access modifiers changed from: protected */
    @Override // org.greenrobot.greendao.AbstractDao
    public final void bindValues(DatabaseStatement databaseStatement, Petugas petugas) {
        databaseStatement.clearBindings();
        Long id = petugas.getId();
        if (id != null) {
            databaseStatement.bindLong(1, id.longValue());
        }
        String wrId = petugas.getWrId();
        if (wrId != null) {
            databaseStatement.bindString(2, wrId);
        }
        String wrUserName = petugas.getWrUserName();
        if (wrUserName != null) {
            databaseStatement.bindString(3, wrUserName);
        }
        String wrName = petugas.getWrName();
        if (wrName != null) {
            databaseStatement.bindString(4, wrName);
        }
        String wrPass = petugas.getWrPass();
        if (wrPass != null) {
            databaseStatement.bindString(5, wrPass);
        }
        String wrIsLogin = petugas.getWrIsLogin();
        if (wrIsLogin != null) {
            databaseStatement.bindString(6, wrIsLogin);
        }
    }

    /* JADX INFO: Access modifiers changed from: protected */
    @Override // org.greenrobot.greendao.AbstractDao
    public final void bindValues(SQLiteStatement sQLiteStatement, Petugas petugas) {
        sQLiteStatement.clearBindings();
        Long id = petugas.getId();
        if (id != null) {
            sQLiteStatement.bindLong(1, id.longValue());
        }
        String wrId = petugas.getWrId();
        if (wrId != null) {
            sQLiteStatement.bindString(2, wrId);
        }
        String wrUserName = petugas.getWrUserName();
        if (wrUserName != null) {
            sQLiteStatement.bindString(3, wrUserName);
        }
        String wrName = petugas.getWrName();
        if (wrName != null) {
            sQLiteStatement.bindString(4, wrName);
        }
        String wrPass = petugas.getWrPass();
        if (wrPass != null) {
            sQLiteStatement.bindString(5, wrPass);
        }
        String wrIsLogin = petugas.getWrIsLogin();
        if (wrIsLogin != null) {
            sQLiteStatement.bindString(6, wrIsLogin);
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
    public Petugas readEntity(Cursor cursor, int i) {
        int i2 = i + 0;
        Long lValueOf = cursor.isNull(i2) ? null : Long.valueOf(cursor.getLong(i2));
        int i3 = i + 1;
        String string = cursor.isNull(i3) ? null : cursor.getString(i3);
        int i4 = i + 2;
        String string2 = cursor.isNull(i4) ? null : cursor.getString(i4);
        int i5 = i + 3;
        String string3 = cursor.isNull(i5) ? null : cursor.getString(i5);
        int i6 = i + 4;
        int i7 = i + 5;
        return new Petugas(lValueOf, string, string2, string3, cursor.isNull(i6) ? null : cursor.getString(i6), cursor.isNull(i7) ? null : cursor.getString(i7));
    }

    @Override // org.greenrobot.greendao.AbstractDao
    public void readEntity(Cursor cursor, Petugas petugas, int i) {
        int i2 = i + 0;
        petugas.setId(cursor.isNull(i2) ? null : Long.valueOf(cursor.getLong(i2)));
        int i3 = i + 1;
        petugas.setWrId(cursor.isNull(i3) ? null : cursor.getString(i3));
        int i4 = i + 2;
        petugas.setWrUserName(cursor.isNull(i4) ? null : cursor.getString(i4));
        int i5 = i + 3;
        petugas.setWrName(cursor.isNull(i5) ? null : cursor.getString(i5));
        int i6 = i + 4;
        petugas.setWrPass(cursor.isNull(i6) ? null : cursor.getString(i6));
        int i7 = i + 5;
        petugas.setWrIsLogin(cursor.isNull(i7) ? null : cursor.getString(i7));
    }

    /* JADX INFO: Access modifiers changed from: protected */
    @Override // org.greenrobot.greendao.AbstractDao
    public final Long updateKeyAfterInsert(Petugas petugas, long j) {
        petugas.setId(Long.valueOf(j));
        return Long.valueOf(j);
    }

    @Override // org.greenrobot.greendao.AbstractDao
    public Long getKey(Petugas petugas) {
        if (petugas != null) {
            return petugas.getId();
        }
        return null;
    }

    @Override // org.greenrobot.greendao.AbstractDao
    public boolean hasKey(Petugas petugas) {
        return petugas.getId() != null;
    }
}
