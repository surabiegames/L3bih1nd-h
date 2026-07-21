package com.aurora.bdg.util.barcodeScanner;

import android.content.Context;
import android.hardware.Camera;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import java.io.IOException;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public class CameraPreview extends ViewGroup implements SurfaceHolder.Callback {
    private final String TAG;
    Camera.AutoFocusCallback mAutoFocusCallback;
    Camera mCamera;
    SurfaceHolder mHolder;
    Camera.PreviewCallback mPreviewCallback;
    Camera.Size mPreviewSize;
    List<Camera.Size> mSupportedPreviewSizes;
    SurfaceView mSurfaceView;

    public CameraPreview(Context context, Camera.PreviewCallback previewCallback, Camera.AutoFocusCallback autoFocusCallback) {
        super(context);
        this.TAG = "CameraPreview";
        this.mPreviewCallback = previewCallback;
        this.mAutoFocusCallback = autoFocusCallback;
        this.mSurfaceView = new SurfaceView(context);
        addView(this.mSurfaceView);
        this.mHolder = this.mSurfaceView.getHolder();
        this.mHolder.addCallback(this);
        this.mHolder.setType(3);
    }

    public void setCamera(Camera camera) {
        this.mCamera = camera;
        if (this.mCamera != null) {
            this.mSupportedPreviewSizes = this.mCamera.getParameters().getSupportedPreviewSizes();
            requestLayout();
        }
    }

    @Override // android.view.View
    protected void onMeasure(int i, int i2) {
        int iResolveSize = resolveSize(getSuggestedMinimumWidth(), i);
        int iResolveSize2 = resolveSize(getSuggestedMinimumHeight(), i2);
        setMeasuredDimension(iResolveSize, iResolveSize2);
        if (this.mSupportedPreviewSizes != null) {
            this.mPreviewSize = getOptimalPreviewSize(this.mSupportedPreviewSizes, iResolveSize, iResolveSize2);
        }
    }

    @Override // android.view.ViewGroup, android.view.View
    protected void onLayout(boolean z, int i, int i2, int i3, int i4) {
        int i5;
        int i6;
        if (!z || getChildCount() <= 0) {
            return;
        }
        View childAt = getChildAt(0);
        int i7 = i3 - i;
        int i8 = i4 - i2;
        if (this.mPreviewSize != null) {
            i5 = this.mPreviewSize.width;
            i6 = this.mPreviewSize.height;
        } else {
            i5 = i7;
            i6 = i8;
        }
        int i9 = i7 * i6;
        int i10 = i8 * i5;
        if (i9 > i10) {
            int i11 = i10 / i6;
            childAt.layout((i7 - i11) / 2, 0, (i7 + i11) / 2, i8);
        } else {
            int i12 = i9 / i5;
            childAt.layout(0, (i8 - i12) / 2, i7, (i8 + i12) / 2);
        }
    }

    public void hideSurfaceView() {
        this.mSurfaceView.setVisibility(4);
    }

    public void showSurfaceView() {
        this.mSurfaceView.setVisibility(0);
    }

    @Override // android.view.SurfaceHolder.Callback
    public void surfaceCreated(SurfaceHolder surfaceHolder) {
        try {
            if (this.mCamera != null) {
                this.mCamera.setPreviewDisplay(surfaceHolder);
            }
        } catch (IOException e) {
            Log.e("CameraPreview", "IOException caused by setPreviewDisplay()", e);
        }
    }

    @Override // android.view.SurfaceHolder.Callback
    public void surfaceDestroyed(SurfaceHolder surfaceHolder) {
        if (this.mCamera != null) {
            this.mCamera.cancelAutoFocus();
            this.mCamera.stopPreview();
        }
    }

    private Camera.Size getOptimalPreviewSize(List<Camera.Size> list, int i, int i2) {
        double d = ((double) i) / ((double) i2);
        Camera.Size size = null;
        if (list == null) {
            return null;
        }
        double dAbs = Double.MAX_VALUE;
        double dAbs2 = Double.MAX_VALUE;
        for (Camera.Size size2 : list) {
            if (Math.abs((((double) size2.width) / ((double) size2.height)) - d) <= 0.1d && Math.abs(size2.height - i2) < dAbs2) {
                dAbs2 = Math.abs(size2.height - i2);
                size = size2;
            }
        }
        if (size == null) {
            for (Camera.Size size3 : list) {
                if (Math.abs(size3.height - i2) < dAbs) {
                    size = size3;
                    dAbs = Math.abs(size3.height - i2);
                }
            }
        }
        return size;
    }

    @Override // android.view.SurfaceHolder.Callback
    public void surfaceChanged(SurfaceHolder surfaceHolder, int i, int i2, int i3) {
        if (surfaceHolder.getSurface() == null || this.mCamera == null) {
            return;
        }
        Camera.Parameters parameters = this.mCamera.getParameters();
        parameters.setPreviewSize(this.mPreviewSize.width, this.mPreviewSize.height);
        requestLayout();
        this.mCamera.setParameters(parameters);
        this.mCamera.setPreviewCallback(this.mPreviewCallback);
        this.mCamera.startPreview();
        this.mCamera.autoFocus(this.mAutoFocusCallback);
    }
}
