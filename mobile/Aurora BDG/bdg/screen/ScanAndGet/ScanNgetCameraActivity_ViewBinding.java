package com.aurora.bdg.screen.ScanAndGet;

import android.view.View;
import android.widget.ImageButton;
import androidx.annotation.CallSuper;
import androidx.annotation.UiThread;
import butterknife.Unbinder;
import butterknife.internal.DebouncingOnClickListener;
import butterknife.internal.Utils;
import com.aurora.bdg.R;
import com.otaliastudios.cameraview.CameraView;

/* JADX INFO: loaded from: classes.dex */
public class ScanNgetCameraActivity_ViewBinding implements Unbinder {
    private ScanNgetCameraActivity target;
    private View view7f09006d;

    @UiThread
    public ScanNgetCameraActivity_ViewBinding(ScanNgetCameraActivity scanNgetCameraActivity) {
        this(scanNgetCameraActivity, scanNgetCameraActivity.getWindow().getDecorView());
    }

    @UiThread
    public ScanNgetCameraActivity_ViewBinding(final ScanNgetCameraActivity scanNgetCameraActivity, View view) {
        this.target = scanNgetCameraActivity;
        scanNgetCameraActivity.camera = (CameraView) Utils.findRequiredViewAsType(view, R.id.camera, "field 'camera'", CameraView.class);
        View viewFindRequiredView = Utils.findRequiredView(view, R.id.btn_flash, "field 'ibFlash' and method 'toggleFlash'");
        scanNgetCameraActivity.ibFlash = (ImageButton) Utils.castView(viewFindRequiredView, R.id.btn_flash, "field 'ibFlash'", ImageButton.class);
        this.view7f09006d = viewFindRequiredView;
        viewFindRequiredView.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.ScanAndGet.ScanNgetCameraActivity_ViewBinding.1
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                scanNgetCameraActivity.toggleFlash();
            }
        });
    }

    @Override // butterknife.Unbinder
    @CallSuper
    public void unbind() {
        ScanNgetCameraActivity scanNgetCameraActivity = this.target;
        if (scanNgetCameraActivity == null) {
            throw new IllegalStateException("Bindings already cleared.");
        }
        this.target = null;
        scanNgetCameraActivity.camera = null;
        scanNgetCameraActivity.ibFlash = null;
        this.view7f09006d.setOnClickListener(null);
        this.view7f09006d = null;
    }
}
