package com.aurora.bdg.util;

import android.annotation.SuppressLint;
import java.text.SimpleDateFormat;
import java.util.Date;

/* JADX INFO: loaded from: classes.dex */
public class TimeUtil {
    public String getMonth(int i) {
        switch (i) {
            case 1:
                return "Jan";
            case 2:
                return "Feb";
            case 3:
                return "Mar";
            case 4:
                return "Apr";
            case 5:
                return "Mei";
            case 6:
                return "Jun";
            case 7:
                return "Jul";
            case 8:
                return "Ags";
            case 9:
                return "Sep";
            case 10:
                return "Oct";
            case 11:
                return "Nov";
            case 12:
                return "Des";
            default:
                return "";
        }
    }

    @SuppressLint({"SimpleDateFormat"})
    public String formatdate(String str) {
        return new SimpleDateFormat(str).format(new Date());
    }

    public String dateNow() {
        return formatdate("yyyy-MM-dd");
    }

    public String timeNow() {
        return formatdate("kk:mm:ss");
    }

    public String timeNowYm() {
        return formatdate("yyyyMM");
    }

    public String timeNowD() {
        return formatdate("dd");
    }

    public String timeNowM() {
        return formatdate("MM");
    }

    public String timeNowY() {
        return formatdate("yyyy");
    }
}
