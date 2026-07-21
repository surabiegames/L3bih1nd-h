package com.aurora.bdg;

import android.app.Application;
import com.aurora.bdg.model.DaoMaster;
import com.aurora.bdg.model.DaoSession;

/* JADX INFO: loaded from: classes.dex */
public class App extends Application {
    public static final boolean ENCRYPTED = true;
    private DaoSession daoSession;

    @Override // android.app.Application
    public void onCreate() {
        super.onCreate();
        this.daoSession = new DaoMaster(new DaoMaster.DevOpenHelper(this, "aurora-db", null).getWritableDb()).newSession();
    }

    public DaoSession getDaoSession() {
        return this.daoSession;
    }
}
