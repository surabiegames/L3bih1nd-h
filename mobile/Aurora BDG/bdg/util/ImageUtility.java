package com.aurora.bdg.util;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.net.Uri;
import androidx.core.view.InputDeviceCompat;
import com.aurora.bdg.R;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import org.opencv.videoio.Videoio;

/* JADX INFO: loaded from: classes.dex */
public class ImageUtility {
    public static DirUtil dirUtil = new DirUtil();

    public static void compressPhoto(Context context, String str, String str2) {
        Uri uri = Uri.parse(str);
        Bitmap bitmapWaterMarkImage2 = waterMarkImage2(context, waterMarkText(BitmapScaler.scaleToFitWidth(BitmapFactory.decodeFile(uri.getPath()), Videoio.CAP_UNICAP), str2));
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        bitmapWaterMarkImage2.compress(Bitmap.CompressFormat.JPEG, 80, byteArrayOutputStream);
        File file = new File(uri.getPath());
        try {
            file.createNewFile();
        } catch (IOException e) {
            e.printStackTrace();
        }
        FileOutputStream fileOutputStream = null;
        try {
            fileOutputStream = new FileOutputStream(file);
        } catch (FileNotFoundException e2) {
            e2.printStackTrace();
        }
        if (fileOutputStream != null) {
            try {
                fileOutputStream.write(byteArrayOutputStream.toByteArray());
            } catch (IOException e3) {
                e3.printStackTrace();
            }
        }
        try {
            fileOutputStream.close();
        } catch (IOException e4) {
            e4.printStackTrace();
        }
    }

    public static void compressPhoto(String str) {
        Uri uri = Uri.parse(str);
        Bitmap bitmapScaleToFitWidth = BitmapScaler.scaleToFitWidth(BitmapFactory.decodeFile(uri.getPath()), 400);
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        bitmapScaleToFitWidth.compress(Bitmap.CompressFormat.JPEG, 60, byteArrayOutputStream);
        File file = new File(uri.getPath());
        try {
            file.createNewFile();
        } catch (IOException e) {
            e.printStackTrace();
        }
        FileOutputStream fileOutputStream = null;
        try {
            fileOutputStream = new FileOutputStream(file);
        } catch (FileNotFoundException e2) {
            e2.printStackTrace();
        }
        if (fileOutputStream != null) {
            try {
                fileOutputStream.write(byteArrayOutputStream.toByteArray());
            } catch (IOException e3) {
                e3.printStackTrace();
            }
        }
        try {
            fileOutputStream.close();
        } catch (IOException e4) {
            e4.printStackTrace();
        }
    }

    public static Bitmap waterMarkText(Bitmap bitmap, String str) {
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        Bitmap bitmapCreateBitmap = Bitmap.createBitmap(width, height, bitmap.getConfig());
        Canvas canvas = new Canvas(bitmapCreateBitmap);
        canvas.drawBitmap(bitmap, 0.0f, 0.0f, (Paint) null);
        Paint paint = new Paint();
        paint.setColor(InputDeviceCompat.SOURCE_ANY);
        paint.setAlpha(100);
        paint.setTextSize(25.0f);
        paint.setAntiAlias(true);
        float f = width / 3;
        int i = (height / 3) * 2;
        canvas.drawText(new SimpleDateFormat("yyyy-MM-dd kk:mm").format(new Date()), f, i, paint);
        canvas.drawText(str, f, i + 35, paint);
        return bitmapCreateBitmap;
    }

    public static Bitmap waterMarkImage(Context context, Bitmap bitmap) {
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        Bitmap bitmapDecodeResource = BitmapFactory.decodeResource(context.getResources(), R.drawable.aurora_85);
        Bitmap bitmapCreateBitmap = Bitmap.createBitmap(bitmap.getWidth(), bitmap.getHeight(), bitmap.getConfig());
        Canvas canvas = new Canvas(bitmapCreateBitmap);
        canvas.drawBitmap(bitmap, 0.0f, 0.0f, (Paint) null);
        canvas.drawBitmap(bitmapDecodeResource, width - bitmapDecodeResource.getWidth(), height - bitmapDecodeResource.getHeight(), (Paint) null);
        return bitmapCreateBitmap;
    }

    public static Bitmap waterMarkImage2(Context context, Bitmap bitmap) {
        bitmap.getWidth();
        int height = bitmap.getHeight();
        Bitmap bitmapDecodeResource = BitmapFactory.decodeResource(context.getResources(), R.drawable.water_mark);
        Bitmap bitmapCreateBitmap = Bitmap.createBitmap(bitmap.getWidth(), bitmap.getHeight(), bitmap.getConfig());
        Canvas canvas = new Canvas(bitmapCreateBitmap);
        canvas.drawBitmap(bitmap, 0.0f, 0.0f, (Paint) null);
        canvas.drawBitmap(bitmapDecodeResource, 0.0f, height - bitmapDecodeResource.getHeight(), (Paint) null);
        return bitmapCreateBitmap;
    }
}
