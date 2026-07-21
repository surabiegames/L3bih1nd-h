package com.aurora.bdg.util;

/* JADX INFO: loaded from: classes.dex */
public class StringUtils {
    public static boolean isEmpty(String str) {
        return str == null || str.trim().isEmpty();
    }

    public static boolean isNotEmpty(String str) {
        return !isEmpty(str);
    }

    public static String cut(String str, int i, int i2) {
        StringBuilder sb = new StringBuilder();
        sb.append(str.substring(0, i));
        int i3 = i2 + 1;
        sb.append(i3 >= str.length() ? "" : str.substring(i3));
        return sb.toString();
    }

    public static String cutLength(String str, int i, int i2) {
        StringBuilder sb = new StringBuilder();
        sb.append(str.substring(0, i));
        int i3 = i + i2;
        sb.append(i3 >= str.length() ? "" : str.substring(i3));
        return sb.toString();
    }

    public static String substring(String str, int i, int i2) {
        int i3 = i2 + 1;
        return i3 >= str.length() ? str.substring(i) : str.substring(i, i3);
    }

    public static String capitalize(String str) {
        return Character.toUpperCase(str.charAt(0)) + str.substring(1).toLowerCase();
    }

    public static String capitalizeAndReplaceUnderscore(String str) {
        return (Character.toUpperCase(str.charAt(0)) + str.substring(1).toLowerCase()).replace("_", " ");
    }
}
