package com.aurora.bdg.util;

import android.content.Context;
import android.content.SharedPreferences;

/* JADX INFO: loaded from: classes.dex */
public class LocalStorage {
    private static final String IS_LOGIN = "IsLoggedIn";
    public static final String PASSWORD = "password";
    public static final String PERIODE = "periode";
    private static final String PREF_NAME = "AuroraSession";
    public static final String SERVER_DATA_OFFLINE = "serverDataOffline";
    public static final String SERVER_DATA_ONLINE = "serverDataOnline";
    public static final String SERVER_PHOTO_OFFLINE = "serverPhotoOffline";
    public static final String SERVER_PHOTO_ONLINE = "serverPhotoOnline";
    public static final String STATUS_DATA = "statusDownload";
    public static final String STATUS_PHOTO = "statusUpload";
    public static final String USERNAME = "username";
    private Context _context;
    private SharedPreferences.Editor editor;
    private SharedPreferences pref;

    public LocalStorage(Context context) {
        this._context = context;
        this.pref = this._context.getSharedPreferences(PREF_NAME, 0);
        this.editor = this.pref.edit();
    }

    public void createLoginSession(String str, String str2) {
        this.editor.putBoolean(IS_LOGIN, true);
        this.editor.putString(USERNAME, str);
        this.editor.putString(PASSWORD, str2);
        this.editor.commit();
    }

    public void setServerDataOnline(String str) {
        this.editor.putString(SERVER_DATA_ONLINE, str);
        this.editor.commit();
    }

    public void setServerPhotoOnline(String str) {
        this.editor.putString(SERVER_PHOTO_ONLINE, str);
        this.editor.commit();
    }

    public void setServerDataOffline(String str) {
        this.editor.putString(SERVER_DATA_OFFLINE, str);
        this.editor.commit();
    }

    public void setServerPhotoOffline(String str) {
        this.editor.putString(SERVER_PHOTO_OFFLINE, str);
        this.editor.commit();
    }

    public void setStatusData(boolean z) {
        this.editor.putBoolean(STATUS_DATA, z);
        this.editor.commit();
    }

    public void setPeriode(String str) {
        this.editor.putString(PERIODE, str);
        this.editor.commit();
    }

    public void setStatusPhoto(boolean z) {
        this.editor.putBoolean(STATUS_PHOTO, z);
        this.editor.commit();
    }

    public String getUserName() {
        return this.pref.getString(USERNAME, null);
    }

    public String getPassword() {
        return this.pref.getString(PASSWORD, null);
    }

    public String getServerData() {
        if (isStatusData()) {
            return getServerDataOnline();
        }
        return getServerDataOffline();
    }

    public String getServerPhoto() {
        if (isStatusPhoto()) {
            return getServerPhotoOnline();
        }
        return getServerDataOffline();
    }

    public String getPeriodeY() {
        return this.pref.getString(PERIODE, "").substring(0, 4);
    }

    public String getPeriodeM() {
        return this.pref.getString(PERIODE, "").substring(4, 6);
    }

    public String getServerDataOnline() {
        return "http://" + this.pref.getString(SERVER_DATA_ONLINE, "103.151.226.195") + "/";
    }

    public String getServerPhotoOnline() {
        return "http://" + this.pref.getString(SERVER_PHOTO_ONLINE, "103.151.226.195") + "/";
    }

    public String getServerDataOffline() {
        return "http://" + this.pref.getString(SERVER_DATA_OFFLINE, "192.168.100.30") + "/";
    }

    public String getServerPhotoOffline() {
        return "http://" + this.pref.getString(SERVER_PHOTO_OFFLINE, "192.168.100.30") + "/";
    }

    public boolean isStatusPhoto() {
        return this.pref.getBoolean(STATUS_PHOTO, false);
    }

    public boolean isStatusData() {
        return this.pref.getBoolean(STATUS_DATA, false);
    }

    public void logoutUser() {
        this.editor.remove(USERNAME);
        this.editor.remove(PASSWORD);
        this.editor.remove(IS_LOGIN);
        this.editor.remove(PERIODE);
        this.editor.commit();
    }

    public boolean isLoggedIn() {
        return this.pref.getBoolean(IS_LOGIN, false);
    }
}
