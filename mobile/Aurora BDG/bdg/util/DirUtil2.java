package com.aurora.bdg.util;

import android.app.Activity;
import android.os.Environment;
import android.util.Log;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;

/* JADX INFO: loaded from: classes.dex */
public class DirUtil2 {
    public static final String BACKUPHOME = "backup_rumah";
    public static final String BACKUPSEGEL = "backup_segel";
    public static final String BACKUPSTAND = "backup_stand";
    public static final String HOME = "rumah";
    public static final String OCR = "ocr";
    public static final String SEGEL = "segel";
    public static final long SIZE_GB = 1073741824;
    public static final long SIZE_KB = 1024;
    public static final long SIZE_MB = 1048576;
    public static final int SPACE_10MB = 1;
    public static final int SPACE_5MB = 2;
    public static final int SPACE_AMAN = 0;
    public static final int SPACE_TIDAK_AMAN = 3;
    public static final String STAND = "stand";
    public static String TAG = "dirUtil";
    public static final String VIDEO = "video";
    public static final TimeUtil timeUtil = new TimeUtil();
    private SDCardHandler space = null;
    public String dirName = "ABM Picture";

    public int IsSpaceAvailable() {
        this.space = new SDCardHandler();
        this.space.InitializeAll();
        long j = this.space.INT_FREE_SPACE_MB;
        if (j > 10) {
            Log.i("Space", "Space masih aman");
            return 0;
        }
        if (j > 5 && j <= 10) {
            Log.i("Space", "Space masih aman, jang 10 jepretan mah");
            return 1;
        }
        if (j > 3 && j <= 5) {
            Log.w("Space", "Warning, eta space na hampir pinuh euy. \nSesana space ngan kurang ti 5 mb deui euy");
            return 2;
        }
        if (j > 3) {
            return 0;
        }
        Log.e("space", "Parah  geus weh tong moto deui. space na geus beak");
        return 3;
    }

    public void makeDir(Activity activity, String str) {
        if (new File(Environment.getExternalStorageDirectory().getAbsolutePath() + "/" + str).mkdir()) {
            Log.i("ABM info", "Berhasil membuat folder " + str);
            return;
        }
        Log.e("ABM gagal", "Folder " + str + " sudah ada");
    }

    public void MakeDefaultDirectory(Activity activity) {
        makeDir(activity, this.dirName);
        makeDir(activity, this.dirName + "/stand");
        makeDir(activity, this.dirName + "/segel");
        makeDir(activity, this.dirName + "/rumah");
        makeDir(activity, this.dirName + "/video");
        makeDir(activity, this.dirName + "/ocr");
        makeDir(activity, this.dirName + "/backup_stand");
        makeDir(activity, this.dirName + "/backup_segel");
        makeDir(activity, this.dirName + "/backup_rumah");
    }

    public String getDir(String str) {
        return (Environment.getExternalStorageDirectory().getAbsolutePath() + "/") + this.dirName + File.separator + str + File.separator;
    }

    public String getDirHome() {
        return (Environment.getExternalStorageDirectory().getAbsolutePath() + "/") + this.dirName + File.separator + "rumah" + File.separator;
    }

    public String getDirStand() {
        return (Environment.getExternalStorageDirectory().getAbsolutePath() + "/") + this.dirName + File.separator + "stand" + File.separator;
    }

    public String getDirSegel() {
        return (Environment.getExternalStorageDirectory().getAbsolutePath() + "/") + this.dirName + File.separator + "segel" + File.separator;
    }

    public String getDirBackupStand() {
        return (Environment.getExternalStorageDirectory().getAbsolutePath() + "/") + this.dirName + File.separator + "backup_stand" + File.separator;
    }

    public String getDirBackupSegel() {
        return (Environment.getExternalStorageDirectory().getAbsolutePath() + "/") + this.dirName + File.separator + "backup_segel" + File.separator;
    }

    public String getDirBackupHome() {
        return (Environment.getExternalStorageDirectory().getAbsolutePath() + "/") + this.dirName + File.separator + "backup_rumah" + File.separator;
    }

    public String getDirVideo() {
        return (Environment.getExternalStorageDirectory().getAbsolutePath() + "/") + this.dirName + File.separator + "video" + File.separator;
    }

    public String getDirOcr() {
        return (Environment.getExternalStorageDirectory().getAbsolutePath() + "/") + this.dirName + File.separator + "ocr" + File.separator;
    }

    public void generateOcr(String str) {
        try {
            File file = new File(Environment.getExternalStorageDirectory(), "ABM OCR");
            if (!file.exists()) {
                file.mkdirs();
            }
            FileWriter fileWriter = new FileWriter(new File(file, "ocr.txt"), true);
            fileWriter.append((CharSequence) (str + "\n"));
            fileWriter.flush();
            fileWriter.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void generateNoteOnSD(String str) {
        try {
            File file = new File(Environment.getExternalStorageDirectory(), "ABM Notes");
            if (!file.exists()) {
                file.mkdirs();
            }
            FileWriter fileWriter = new FileWriter(new File(file, "log.txt"), true);
            fileWriter.append((CharSequence) (str + "\n"));
            fileWriter.flush();
            fileWriter.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void backupToTxt(String str) {
        try {
            String str2 = "data " + timeUtil.timeNow();
            File file = new File(Environment.getExternalStorageDirectory(), "ABM Backup");
            if (!file.exists()) {
                file.mkdirs();
            }
            FileWriter fileWriter = new FileWriter(new File(file, str2));
            fileWriter.append((CharSequence) (str + "\n"));
            fileWriter.flush();
            fileWriter.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void catatTxt(String str) {
        try {
            String str2 = "catat " + timeUtil.dateNow() + ".txt";
            File file = new File(Environment.getExternalStorageDirectory(), "ABM Catat");
            if (!file.exists()) {
                file.mkdirs();
            }
            FileWriter fileWriter = new FileWriter(new File(file, str2), true);
            fileWriter.append((CharSequence) (str + "\n"));
            fileWriter.flush();
            fileWriter.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void copyFile(String str, String str2, String str3) {
        try {
            File file = new File(str3);
            if (!file.exists()) {
                file.mkdirs();
            }
            FileInputStream fileInputStream = new FileInputStream(str);
            FileOutputStream fileOutputStream = new FileOutputStream(str3 + "/" + str2);
            byte[] bArr = new byte[1024];
            while (true) {
                int i = fileInputStream.read(bArr);
                if (i != -1) {
                    fileOutputStream.write(bArr, 0, i);
                } else {
                    fileInputStream.close();
                    fileOutputStream.flush();
                    fileOutputStream.close();
                    return;
                }
            }
        } catch (FileNotFoundException e) {
            Log.e("tag", e.getMessage());
        } catch (Exception e2) {
            Log.e("tag", e2.getMessage());
        }
    }
}
