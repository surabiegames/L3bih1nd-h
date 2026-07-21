package com.aurora.bdg.util;

import android.os.Environment;
import android.os.StatFs;

/* JADX INFO: loaded from: classes.dex */
public class SDCardHandler {
    public static final long SIZE_GB = 1073741824;
    public static final long SIZE_KB = 1024;
    public static final long SIZE_MB = 1048576;
    public int EXT_FREE_SPACE_GB;
    public int EXT_FREE_SPACE_KB;
    public int EXT_FREE_SPACE_MB;
    public int EXT_TOTAL_SPACE_GB;
    public int EXT_TOTAL_SPACE_KB;
    public int EXT_TOTAL_SPACE_MB;
    public int EXT_USED_SPACE_GB;
    public int EXT_USED_SPACE_KB;
    public int EXT_USED_SPACE_MB;
    public int INT_FREE_SPACE_GB;
    public int INT_FREE_SPACE_KB;
    public int INT_FREE_SPACE_MB;
    public int INT_TOTAL_SPACE_GB;
    public int INT_TOTAL_SPACE_KB;
    public int INT_TOTAL_SPACE_MB;
    public int INT_USED_SPACE_GB;
    public int INT_USED_SPACE_KB;
    public int INT_USED_SPACE_MB;
    private long extavailableSize;
    private long extblockSize;
    private long extfreeSize;
    private StatFs extstatFs;
    private long exttotalSize;
    private long inavailableSize;
    private long inblockSize;
    private long infreeSize;
    private StatFs instatFs;
    private long intotalSize;
    public String INTERNAL_SDCARD_PATH = "";
    public String EXTERNAL_SDCARD_PATH = "";
    public String EXTERNAL_CAMERA = "";
    public String EXTERNAL_DOWNLOAD = "";
    public String EXTERNAL_BLUETOOTH = "";
    public String EXTERNAL_DOCUMENTS = "";
    public String EXTERNAL_PICTURES = "";

    public long ExtSpace() {
        return 0L;
    }

    public void onCreate() {
    }

    public void InitializeAll() {
        this.instatFs = new StatFs(Environment.getRootDirectory().getAbsolutePath());
        this.inblockSize = this.instatFs.getBlockSize();
        this.intotalSize = ((long) this.instatFs.getBlockCount()) * this.inblockSize;
        this.inavailableSize = ((long) this.instatFs.getAvailableBlocks()) * this.inblockSize;
        this.infreeSize = ((long) this.instatFs.getFreeBlocks()) * this.inblockSize;
        this.INTERNAL_SDCARD_PATH = DEFAULT_INTERNAL_SDCARD();
        String externalStorageState = Environment.getExternalStorageState();
        if ("mounted".equals(externalStorageState)) {
            this.extstatFs = new StatFs(Environment.getExternalStorageDirectory().getAbsolutePath());
            this.extblockSize = this.extstatFs.getBlockSize();
            this.exttotalSize = ((long) this.extstatFs.getBlockCount()) * this.extblockSize;
            this.extavailableSize = ((long) this.extstatFs.getAvailableBlocks()) * this.extblockSize;
            this.extfreeSize = ((long) this.extstatFs.getFreeBlocks()) * this.extblockSize;
            this.EXTERNAL_SDCARD_PATH = DEFAULT_EXTERNAL_SDCARD();
            this.EXTERNAL_CAMERA = DEFAULT_EXTERNAL_CAMERA_PATH();
            this.EXTERNAL_DOWNLOAD = DEFAULT_EXTERNAL_DOWNLOAD_PATH();
            this.EXTERNAL_BLUETOOTH = DEFAULT_EXTERNAL_BLUETOOTH_PATH();
            this.EXTERNAL_DOCUMENTS = DEFAULT_EXTERNAL_DOCUMENTS_PATH();
            this.EXTERNAL_PICTURES = DEFAULT_EXTERNAL_PICTURES_PATH();
            this.EXT_TOTAL_SPACE_KB = Integer.parseInt("" + extTotalSpace(1));
            this.EXT_FREE_SPACE_KB = Integer.parseInt("" + extFreeSpace(1));
            this.EXT_USED_SPACE_KB = Integer.parseInt("" + extUsedSpace(1));
            this.EXT_TOTAL_SPACE_MB = Integer.parseInt("" + extTotalSpace(2));
            this.EXT_FREE_SPACE_MB = Integer.parseInt("" + extFreeSpace(2));
            this.EXT_USED_SPACE_MB = Integer.parseInt("" + extUsedSpace(2));
            this.EXT_TOTAL_SPACE_GB = Integer.parseInt("" + extTotalSpace(3));
            this.EXT_FREE_SPACE_GB = Integer.parseInt("" + extFreeSpace(3));
            this.EXT_USED_SPACE_GB = Integer.parseInt("" + extUsedSpace(3));
        } else {
            "mounted_ro".equals(externalStorageState);
        }
        this.INT_TOTAL_SPACE_KB = Integer.parseInt("" + inTotalSpace(1));
        this.INT_FREE_SPACE_KB = Integer.parseInt("" + inFreeSpace(1));
        this.INT_USED_SPACE_KB = Integer.parseInt("" + inUsedSpace(1));
        this.INT_TOTAL_SPACE_MB = Integer.parseInt("" + inTotalSpace(2));
        this.INT_FREE_SPACE_MB = Integer.parseInt("" + inFreeSpace(2));
        this.INT_USED_SPACE_MB = Integer.parseInt("" + inUsedSpace(2));
        this.INT_TOTAL_SPACE_GB = Integer.parseInt("" + inTotalSpace(3));
        this.INT_FREE_SPACE_GB = Integer.parseInt("" + inFreeSpace(3));
        this.INT_USED_SPACE_GB = Integer.parseInt("" + inUsedSpace(3));
    }

    public long inTotalSpace(int i) {
        long j = i == 1 ? this.intotalSize / 1024 : 0L;
        if (i == 2) {
            j = this.intotalSize / 1048576;
        }
        return i == 3 ? this.intotalSize / 1073741824 : j;
    }

    public long inUsedSpace(int i) {
        long j = i == 1 ? (this.intotalSize - this.inavailableSize) / 1024 : 0L;
        if (i == 2) {
            j = (this.intotalSize - this.inavailableSize) / 1048576;
        }
        return i == 3 ? (this.intotalSize - this.inavailableSize) / 1073741824 : j;
    }

    public long inFreeSpace(int i) {
        long j = i == 1 ? this.infreeSize / 1024 : 0L;
        if (i == 2) {
            j = this.infreeSize / 1048576;
        }
        return i == 3 ? this.infreeSize / 1073741824 : j;
    }

    public long extTotalSpace(int i) {
        long j = i == 1 ? this.exttotalSize / 1024 : 0L;
        if (i == 2) {
            j = this.exttotalSize / 1048576;
        }
        return i == 3 ? this.exttotalSize / 1073741824 : j;
    }

    public long extUsedSpace(int i) {
        long j = i == 1 ? (this.exttotalSize - this.extavailableSize) / 1024 : 0L;
        if (i == 2) {
            j = (this.exttotalSize - this.extavailableSize) / 1048576;
        }
        return i == 3 ? (this.exttotalSize - this.extavailableSize) / 1073741824 : j;
    }

    public long extFreeSpace(int i) {
        long j = i == 1 ? this.extfreeSize / 1024 : 0L;
        if (i == 2) {
            j = this.extfreeSize / 1048576;
        }
        return i == 3 ? this.extfreeSize / 1073741824 : j;
    }

    public String DEFAULT_INTERNAL_SDCARD() {
        return Environment.getRootDirectory().getAbsolutePath();
    }

    public String DEFAULT_EXTERNAL_SDCARD() {
        return Environment.getExternalStorageDirectory().getAbsolutePath();
    }

    public String DEFAULT_EXTERNAL_CAMERA_PATH() {
        return Environment.getExternalStorageDirectory().getAbsolutePath() + "/DCIM/CAMERA";
    }

    public String DEFAULT_EXTERNAL_DOWNLOAD_PATH() {
        return Environment.getExternalStorageDirectory().getAbsolutePath() + "/Download";
    }

    public String DEFAULT_EXTERNAL_BLUETOOTH_PATH() {
        return Environment.getExternalStorageDirectory().getAbsolutePath() + "/Bluetooth";
    }

    public String DEFAULT_EXTERNAL_DOCUMENTS_PATH() {
        return Environment.getExternalStorageDirectory().getAbsolutePath() + "/Documents";
    }

    public String DEFAULT_EXTERNAL_PICTURES_PATH() {
        return Environment.getExternalStorageDirectory().getAbsolutePath() + "/Pictures";
    }
}
