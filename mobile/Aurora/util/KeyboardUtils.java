package com.aurora.bdg.util;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.view.View;
import android.view.inputmethod.InputMethodManager;

/* JADX INFO: loaded from: classes.dex */
public class KeyboardUtils {
    public static void hideKeyboard(Activity activity) {
        View currentFocus = activity.getCurrentFocus();
        if (currentFocus != null) {
            hideKeyboard(activity, currentFocus);
        }
    }

    public static void hideKeyboard(Context context, View view) {
        ((InputMethodManager) context.getSystemService("input_method")).hideSoftInputFromWindow(view.getWindowToken(), 0);
    }

    public static void showKeyboard(Activity activity) {
        activity.getWindow().setSoftInputMode(4);
    }

    public static void showKeyboard(Dialog dialog) {
        dialog.getWindow().setSoftInputMode(4);
    }

    public static void hideKeyboard(Dialog dialog) {
        dialog.getWindow().setSoftInputMode(2);
    }

    public static void showKeyboard(Context context) {
        ((InputMethodManager) context.getSystemService("input_method")).toggleSoftInput(2, 0);
    }

    public static void showKeyboard(Context context, View view) {
        ((InputMethodManager) context.getSystemService("input_method")).showSoftInput(view, 2);
    }
}
