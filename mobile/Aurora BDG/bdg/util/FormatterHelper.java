package com.aurora.bdg.util;

import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.text.SimpleDateFormat;
import java.util.Date;

/* JADX INFO: loaded from: classes.dex */
public class FormatterHelper {
    public static String asRupiah(double d) {
        DecimalFormat decimalFormat = (DecimalFormat) DecimalFormat.getCurrencyInstance();
        DecimalFormatSymbols decimalFormatSymbols = new DecimalFormatSymbols();
        decimalFormatSymbols.setCurrencySymbol("Rp.");
        decimalFormatSymbols.setMonetaryDecimalSeparator(',');
        decimalFormatSymbols.setGroupingSeparator('.');
        decimalFormat.setDecimalFormatSymbols(decimalFormatSymbols);
        return decimalFormat.format(d);
    }

    public static String addComma(int i) {
        return String.format("%,.0f", Double.valueOf(Double.parseDouble(String.valueOf(i))));
    }

    public static String asDateTime(Date date) {
        return new SimpleDateFormat("dd/MM/yy HH:mm:ss").format(date);
    }

    public static String asDate(Date date) {
        return new SimpleDateFormat("dd/MM/yy").format(date);
    }

    public static String asDate(Date date, String str) {
        return new SimpleDateFormat(str).format(date);
    }
}
