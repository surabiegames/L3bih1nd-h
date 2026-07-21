package com.aurora.bdg.screen.auroraCamera;

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
public class AuroraCameraPictureActivity_ViewBinding implements Unbinder {
    private AuroraCameraPictureActivity target;
    private View view7f09006d;
    private View view7f090079;

    @UiThread
    public AuroraCameraPictureActivity_ViewBinding(AuroraCameraPictureActivity auroraCameraPictureActivity) {
        this(auroraCameraPictureActivity, auroraCameraPictureActivity.getWindow().getDecorView());
    }

    @UiThread
    public AuroraCameraPictureActivity_ViewBinding(final AuroraCameraPictureActivity auroraCameraPictureActivity, View view) {
        this.target = auroraCameraPictureActivity;
        auroraCameraPictureActivity.camera = (CameraView) Utils.findRequiredViewAsType(view, R.id.camera, "field 'camera'", CameraView.class);
        View viewFindRequiredView = Utils.findRequiredView(view, R.id.btn_flash, "field 'ibFlash' and method 'toggleFlash'");
        auroraCameraPictureActivity.ibFlash = (ImageButton) Utils.castView(viewFindRequiredView, R.id.btn_flash, "field 'ibFlash'", ImageButton.class);
        this.view7f09006d = viewFindRequiredView;
        viewFindRequiredView.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.auroraCamera.AuroraCameraPictureActivity_ViewBinding.1
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                auroraCameraPictureActivity.toggleFlash();
            }
        });
        View viewFindRequiredView2 = Utils.findRequiredView(view, R.id.btn_take_picture, "method 'onTakePicture'");
        this.view7f090079 = viewFindRequiredView2;
        viewFindRequiredView2.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.auroraCamera.AuroraCameraPictureActivity_ViewBinding.2
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                auroraCameraPictureActivity.onTakePicture();
            }
        });
    }

    @Override // butterknife.Unbinder
    @CallSuper
    public void unbind() {
        AuroraCameraPictureActivity auroraCameraPictureActivity = this.target;
        if (auroraCameraPictureActivity == null) {
            throw new IllegalStateException("Bindings already cleared.");
        }
        this.target = null;
        auroraCameraPictureActivity.camera = null;
        auroraCameraPictureActivity.ibFlash = null;
        this.view7f09006d.setOnClickListener(null);
        this.view7f09006d = null;
        this.view7f090079.setOnClickListener(null);
        this.view7f090079 = null;
    }
}
