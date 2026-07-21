package com.aurora.bdg.model;

import android.database.Cursor;
import android.database.sqlite.SQLiteStatement;
import org.greenrobot.greendao.AbstractDao;
import org.greenrobot.greendao.Property;
import org.greenrobot.greendao.database.Database;
import org.greenrobot.greendao.database.DatabaseStatement;
import org.greenrobot.greendao.internal.DaoConfig;

/* JADX INFO: loaded from: classes.dex */
public class TarifDao extends AbstractDao<Tarif, Long> {
    public static final String TABLENAME = "TARIF";

    public static class Properties {
        public static final Property Id = new Property(0, Long.class, "id", true, "_id");
        public static final Property TrfId = new Property(1, String.class, "trfId", false, "TRF_ID");
        public static final Property TrfCode = new Property(2, String.class, "trfCode", false, "TRF_CODE");
        public static final Property TrfName = new Property(3, String.class, "trfName", false, "TRF_NAME");
        public static final Property TrfInit = new Property(4, String.class, "trfInit", false, "TRF_INIT");
        public static final Property TrfAdm = new Property(5, String.class, "trfAdm", false, "TRF_ADM");
    }

    @Override // org.greenrobot.greendao.AbstractDao
    protected final boolean isEntityUpdateable() {
        return true;
    }

    public TarifDao(DaoConfig daoConfig) {
        super(daoConfig);
    }

    public TarifDao(DaoConfig daoConfig, DaoSession daoSession) {
        super(daoConfig, daoSession);
    }

    public static void createTable(Database database, boolean z) {
        database.execSQL("CREATE TABLE " + (z ? "IF NOT EXISTS " : "") + "\"TARIF\" (\"_id\" INTEGER PRIMARY KEY AUTOINCREMENT ,\"TRF_ID\" TEXT,\"TRF_CODE\" TEXT,\"TRF_NAME\" TEXT,\"TRF_INIT\" TEXT,\"TRF_ADM\" TEXT);");
    }

    public static void dropTable(Database database, boolean z) {
        StringBuilder sb = new StringBuilder();
        sb.append("DROP TABLE ");
        sb.append(z ? "IF EXISTS " : "");
        sb.append("\"TARIF\"");
        database.execSQL(sb.toString());
    }

    /* JADX INFO: Access modifiers changed from: protected */
    @Override // org.greenrobot.greendao.AbstractDao
    public final void bindValues(DatabaseStatement databaseStatement, Tarif tarif) {
        databaseStatement.clearBindings();
        Long id = tarif.getId();
        if (id != null) {
            databaseStatement.bindLong(1, id.longValue());
        }
        String trfId = tarif.getTrfId();
        if (trfId != null) {
            databaseStatement.bindString(2, trfId);
        }
        String trfCode = tarif.getTrfCode();
        if (trfCode != null) {
            databaseStatement.bindString(3, trfCode);
        }
        String trfName = tarif.getTrfName();
        if (trfName != null) {
            databaseStatement.bindString(4, trfName);
        }
        String trfInit = tarif.getTrfInit();
        if (trfInit != null) {
            databaseStatement.bindString(5, trfInit);
        }
        String trfAdm = tarif.getTrfAdm();
        if (trfAdm != null) {
            databaseStatement.bindString(6, trfAdm);
        }
    }

    /* JADX INFO: Access modifiers changed from: protected */
    @Override // org.greenrobot.greendao.AbstractDao
    public final void bindValues(SQLiteStatement sQLiteStatement, Tarif tarif) {
        sQLiteStatement.clearBindings();
        Long id = tarif.getId();
        if (id != null) {
            sQLiteStatement.bindLong(1, id.longValue());
        }
        String trfId = tarif.getTrfId();
        if (trfId != null) {
            sQLiteStatement.bindString(2, trfId);
        }
        String trfCode = tarif.getTrfCode();
        if (trfCode != null) {
            sQLiteStatement.bindString(3, trfCode);
        }
        String trfName = tarif.getTrfName();
        if (trfName != null) {
            sQLiteStatement.bindString(4, trfName);
        }
        String trfInit = tarif.getTrfInit();
        if (trfInit != null) {
            sQLiteStatement.bindString(5, trfInit);
        }
        String trfAdm = tarif.getTrfAdm();
        if (trfAdm != null) {
            sQLiteStatement.bindString(6, trfAdm);
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
    public Tarif readEntity(Cursor cursor, int i) {
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
        return new Tarif(lValueOf, string, string2, string3, cursor.isNull(i6) ? null : cursor.getString(i6), cursor.isNull(i7) ? null : cursor.getString(i7));
    }

    @Override // org.greenrobot.greendao.AbstractDao
    public void readEntity(Cursor cursor, Tarif tarif, int i) {
        int i2 = i + 0;
        tarif.setId(cursor.isNull(i2) ? null : Long.valueOf(cursor.getLong(i2)));
        int i3 = i + 1;
        tarif.setTrfId(cursor.isNull(i3) ? null : cursor.getString(i3));
        int i4 = i + 2;
        tarif.setTrfCode(cursor.isNull(i4) ? null : cursor.getString(i4));
        int i5 = i + 3;
        tarif.setTrfName(cursor.isNull(i5) ? null : cursor.getString(i5));
        int i6 = i + 4;
        tarif.setTrfInit(cursor.isNull(i6) ? null : cursor.getString(i6));
        int i7 = i + 5;
        tarif.setTrfAdm(cursor.isNull(i7) ? null : cursor.getString(i7));
    }

    /* JADX INFO: Access modifiers changed from: protected */
    @Override // org.greenrobot.greendao.AbstractDao
    public final Long updateKeyAfterInsert(Tarif tarif, long j) {
        tarif.setId(Long.valueOf(j));
        return Long.valueOf(j);
    }

    @Override // org.greenrobot.greendao.AbstractDao
    public Long getKey(Tarif tarif) {
        if (tarif != null) {
            return tarif.getId();
        }
        return null;
    }

    @Override // org.greenrobot.greendao.AbstractDao
    public boolean hasKey(Tarif tarif) {
        return tarif.getId() != null;
    }
}
