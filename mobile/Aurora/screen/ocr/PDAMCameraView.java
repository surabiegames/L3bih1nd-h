package com.aurora.bdg.screen.ocr;

import android.R;
import android.content.Context;
import android.hardware.Camera;
import android.os.Handler;
import android.util.AttributeSet;
import android.util.Log;
import java.io.FileOutputStream;
import java.io.IOException;
import org.opencv.android.JavaCameraView;

/* JADX INFO: loaded from: classes.dex */
public class PDAMCameraView extends JavaCameraView implements Camera.PictureCallback {
    private static final String TAG = "PDAMCameraView";
    private Handler mAutoFocusHandler;
    private String picturefileName;

    public PDAMCameraView(Context context, AttributeSet attributeSet) {
        super(context, attributeSet);
        Log.i(TAG, "PDAMCameraView: Handler");
    }

    public void flashOn() {
        Camera.Parameters parameters = this.mCamera.getParameters();
        parameters.setFlashMode("torch");
        this.mCamera.setParameters(parameters);
    }

    public void flashOff() {
        Camera.Parameters parameters = this.mCamera.getParameters();
        parameters.setFlashMode("off");
        this.mCamera.setParameters(parameters);
    }

    @Override // android.hardware.Camera.PictureCallback
    public void onPictureTaken(byte[] bArr, Camera camera) {
        Log.i(TAG, "Saving a bitmap to file");
        this.mCamera.startPreview();
        this.mCamera.setPreviewCallback(this);
        try {
            FileOutputStream fileOutputStream = new FileOutputStream(this.picturefileName);
            fileOutputStream.write(R.attr.data);
            fileOutputStream.close();
        } catch (IOException e) {
            Log.e("PictureDemo", "Exception in photoCallback", e);
        }
    }

    public void setFocusDelay() {
        Camera.Parameters parameters = this.mCamera.getParameters();
        if (parameters.getSupportedFocusModes().contains("continuous-picture")) {
            parameters.setFocusMode("continuous-picture");
        }
        this.mCamera.setParameters(parameters);
    }
}
