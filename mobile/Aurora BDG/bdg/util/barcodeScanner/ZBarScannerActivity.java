package com.aurora.bdg.util.barcodeScanner;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Rect;
import android.graphics.YuvImage;
import android.hardware.Camera;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.text.TextUtils;
import com.aurora.bdg.util.DirUtil;
import com.aurora.bdg.util.ImageUtility;
import com.aurora.bdg.util.LocalStorage;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import net.sourceforge.zbar.Image;
import net.sourceforge.zbar.ImageScanner;
import net.sourceforge.zbar.Symbol;

/* JADX INFO: loaded from: classes.dex */
public class ZBarScannerActivity extends Activity implements Camera.PreviewCallback, ZBarConstants {
    private static final String STAND = "stand";
    private static final String TAG = "ZBarScannerActivity";
    String custCode;
    LocalStorage localStorage;
    private Handler mAutoFocusHandler;
    private Camera mCamera;
    private CameraPreview mPreview;
    private ImageScanner mScanner;
    public String period;
    DirUtil dirUtil = new DirUtil();
    private boolean mPreviewing = true;
    private Runnable doAutoFocus = new Runnable() { // from class: com.aurora.bdg.util.barcodeScanner.ZBarScannerActivity.1
        @Override // java.lang.Runnable
        public void run() {
            if (ZBarScannerActivity.this.mCamera == null || !ZBarScannerActivity.this.mPreviewing) {
                return;
            }
            ZBarScannerActivity.this.mCamera.autoFocus(ZBarScannerActivity.this.autoFocusCB);
        }
    };
    Camera.AutoFocusCallback autoFocusCB = new Camera.AutoFocusCallback() { // from class: com.aurora.bdg.util.barcodeScanner.ZBarScannerActivity.2
        @Override // android.hardware.Camera.AutoFocusCallback
        public void onAutoFocus(boolean z, Camera camera) {
            ZBarScannerActivity.this.mAutoFocusHandler.postDelayed(ZBarScannerActivity.this.doAutoFocus, 1000L);
        }
    };

    @Override // android.app.Activity
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        this.localStorage = new LocalStorage(this);
        this.period = this.localStorage.getPeriodeY() + "" + this.localStorage.getPeriodeM();
        if (!isCameraAvailable()) {
            cancelRequest();
            return;
        }
        requestWindowFeature(1);
        getWindow().addFlags(1024);
        this.mAutoFocusHandler = new Handler();
        setupScanner();
        this.mPreview = new CameraPreview(this, this, this.autoFocusCB);
        setContentView(this.mPreview);
    }

    public void setupScanner() {
        this.mScanner = new ImageScanner();
        this.mScanner.setConfig(0, 256, 3);
        this.mScanner.setConfig(0, 257, 3);
        int[] intArrayExtra = getIntent().getIntArrayExtra(ZBarConstants.SCAN_MODES);
        if (intArrayExtra != null) {
            this.mScanner.setConfig(0, 0, 0);
            for (int i : intArrayExtra) {
                this.mScanner.setConfig(i, 0, 1);
            }
        }
    }

    @Override // android.app.Activity
    protected void onResume() {
        super.onResume();
        this.mCamera = Camera.open();
        if (this.mCamera == null) {
            cancelRequest();
            return;
        }
        this.mPreview.setCamera(this.mCamera);
        this.mPreview.showSurfaceView();
        this.mPreviewing = true;
    }

    @Override // android.app.Activity
    protected void onPause() {
        super.onPause();
        if (this.mCamera != null) {
            this.mPreview.setCamera(null);
            this.mCamera.cancelAutoFocus();
            this.mCamera.setPreviewCallback(null);
            this.mCamera.stopPreview();
            this.mCamera.release();
            this.mPreview.hideSurfaceView();
            this.mPreviewing = false;
            this.mCamera = null;
        }
    }

    public boolean isCameraAvailable() {
        return getPackageManager().hasSystemFeature("android.hardware.camera");
    }

    public void cancelRequest() {
        Intent intent = new Intent();
        intent.putExtra(ZBarConstants.ERROR_INFO, "Camera unavailable");
        setResult(0, intent);
        finish();
    }

    @Override // android.hardware.Camera.PreviewCallback
    public void onPreviewFrame(byte[] bArr, Camera camera) {
        Camera.Size previewSize = camera.getParameters().getPreviewSize();
        Image image = new Image(previewSize.width, previewSize.height, "Y800");
        image.setData(bArr);
        if (this.mScanner.scanImage(image) != 0) {
            int i = previewSize.width;
            int i2 = previewSize.height;
            YuvImage yuvImage = new YuvImage(bArr, 17, i, i2, null);
            ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream(bArr.length);
            if (yuvImage.compressToJpeg(new Rect(0, 0, i, i2), 100, byteArrayOutputStream)) {
                byte[] byteArray = byteArrayOutputStream.toByteArray();
                this.mCamera.cancelAutoFocus();
                this.mCamera.setPreviewCallback(null);
                this.mCamera.stopPreview();
                this.mPreviewing = false;
                for (Symbol symbol : this.mScanner.getResults()) {
                    String data = symbol.getData();
                    if (!TextUtils.isEmpty(data)) {
                        Intent intent = new Intent();
                        this.custCode = data;
                        intent.putExtra(ZBarConstants.SCAN_RESULT, data);
                        intent.putExtra(ZBarConstants.SCAN_RESULT_TYPE, symbol.getType());
                        setResult(-1, intent);
                        finish();
                        break;
                    }
                }
                try {
                    FileOutputStream fileOutputStream = new FileOutputStream(getImagePath("stand"));
                    fileOutputStream.write(byteArray);
                    fileOutputStream.flush();
                    fileOutputStream.close();
                    ImageUtility.compressPhoto(getImagePath("stand"));
                } catch (FileNotFoundException unused) {
                    System.out.println("Saving to file failed");
                } catch (IOException unused2) {
                    System.out.println("Saving to file failed");
                }
            }
        }
    }

    public String getImagePath(String str) {
        return Environment.getExternalStorageDirectory() + File.separator + this.dirUtil.dirName + File.separator + str + File.separator + (this.period + "_" + str + "_" + this.custCode) + ".jpg";
    }
}
