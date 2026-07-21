package com.aurora.bdg.util;

import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Rect;

/* JADX INFO: loaded from: classes.dex */
public class ScalingUtilities {

    public enum ScalingLogic {
        CROP,
        FIT
    }

    public static Bitmap decodeResource(Resources resources, int i, int i2, int i3, ScalingLogic scalingLogic) {
        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inJustDecodeBounds = true;
        BitmapFactory.decodeResource(resources, i, options);
        options.inJustDecodeBounds = false;
        options.inSampleSize = calculateSampleSize(options.outWidth, options.outHeight, i2, i3, scalingLogic);
        return BitmapFactory.decodeResource(resources, i, options);
    }

    public static Bitmap decodeFile(String str, int i, int i2, ScalingLogic scalingLogic) {
        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inJustDecodeBounds = true;
        BitmapFactory.decodeFile(str, options);
        options.inJustDecodeBounds = false;
        options.inSampleSize = calculateSampleSize(options.outWidth, options.outHeight, i, i2, scalingLogic);
        return BitmapFactory.decodeFile(str, options);
    }

    public static Bitmap createScaledBitmap(Bitmap bitmap, int i, int i2, ScalingLogic scalingLogic) {
        Rect rectCalculateSrcRect = calculateSrcRect(bitmap.getWidth(), bitmap.getHeight(), i, i2, scalingLogic);
        Rect rectCalculateDstRect = calculateDstRect(bitmap.getWidth(), bitmap.getHeight(), i, i2, scalingLogic);
        Bitmap bitmapCreateBitmap = Bitmap.createBitmap(rectCalculateDstRect.width(), rectCalculateDstRect.height(), Bitmap.Config.ARGB_8888);
        new Canvas(bitmapCreateBitmap).drawBitmap(bitmap, rectCalculateSrcRect, rectCalculateDstRect, new Paint(2));
        return bitmapCreateBitmap;
    }

    public static int calculateSampleSize(int i, int i2, int i3, int i4, ScalingLogic scalingLogic) {
        if (scalingLogic == ScalingLogic.FIT) {
            if (i / i2 > i3 / i4) {
                return i / i3;
            }
            return i2 / i4;
        }
        if (i / i2 > i3 / i4) {
            return i2 / i4;
        }
        return i / i3;
    }

    public static Rect calculateSrcRect(int i, int i2, int i3, int i4, ScalingLogic scalingLogic) {
        if (scalingLogic != ScalingLogic.CROP) {
            return new Rect(0, 0, i, i2);
        }
        float f = i;
        float f2 = i2;
        float f3 = i3 / i4;
        if (f / f2 > f3) {
            int i5 = (int) (f2 * f3);
            int i6 = (i - i5) / 2;
            return new Rect(i6, 0, i5 + i6, i2);
        }
        int i7 = (int) (f / f3);
        int i8 = (i2 - i7) / 2;
        return new Rect(0, i8, i, i7 + i8);
    }

    public static Rect calculateDstRect(int i, int i2, int i3, int i4, ScalingLogic scalingLogic) {
        if (scalingLogic != ScalingLogic.FIT) {
            return new Rect(0, 0, i3, i4);
        }
        float f = i / i2;
        float f2 = i3;
        float f3 = i4;
        if (f > f2 / f3) {
            return new Rect(0, 0, i3, (int) (f2 / f));
        }
        return new Rect(0, 0, (int) (f3 * f), i4);
    }
}
