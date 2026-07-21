package com.aurora.bdg.util;

import android.graphics.Bitmap;

/* JADX INFO: loaded from: classes.dex */
public class BitmapScaler {
    public static Bitmap scaleToFitWidth(Bitmap bitmap, int i) {
        return Bitmap.createScaledBitmap(bitmap, i, (int) (bitmap.getHeight() * (i / bitmap.getWidth())), true);
    }

    public static Bitmap scaleToFitHeight(Bitmap bitmap, int i) {
        return Bitmap.createScaledBitmap(bitmap, (int) (bitmap.getWidth() * (i / bitmap.getHeight())), i, true);
    }

    public static Bitmap scaleToFill(Bitmap bitmap, int i, int i2) {
        float width = i2 / bitmap.getWidth();
        float width2 = i / bitmap.getWidth();
        if (width <= width2) {
            width2 = width;
        }
        return Bitmap.createScaledBitmap(bitmap, (int) (bitmap.getWidth() * width2), (int) (bitmap.getHeight() * width2), true);
    }

    public static Bitmap strechToFill(Bitmap bitmap, int i, int i2) {
        return Bitmap.createScaledBitmap(bitmap, (int) (bitmap.getWidth() * (i / bitmap.getWidth())), (int) (bitmap.getHeight() * (i2 / bitmap.getHeight())), true);
    }
}
