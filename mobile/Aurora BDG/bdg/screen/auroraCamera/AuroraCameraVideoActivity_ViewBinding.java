package com.aurora.bdg.screen.auroraCamera;

import android.view.View;
import android.widget.ImageButton;
import android.widget.TextView;
import androidx.annotation.CallSuper;
import androidx.annotation.UiThread;
import butterknife.Unbinder;
import butterknife.internal.DebouncingOnClickListener;
import butterknife.internal.Utils;
import com.aurora.bdg.R;
import com.otaliastudios.cameraview.CameraView;

/* JADX INFO: loaded from: classes.dex */
public class AuroraCameraVideoActivity_ViewBinding implements Unbinder {
    private AuroraCameraVideoActivity target;
    private View view7f09006d;
    private View view7f09007a;

    @UiThread
    public AuroraCameraVideoActivity_ViewBinding(AuroraCameraVideoActivity auroraCameraVideoActivity) {
        this(auroraCameraVideoActivity, auroraCameraVideoActivity.getWindow().getDecorView());
    }

    @UiThread
    public AuroraCameraVideoActivity_ViewBinding(final AuroraCameraVideoActivity auroraCameraVideoActivity, View view) {
        this.target = auroraCameraVideoActivity;
        auroraCameraVideoActivity.tvCountDown = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_countDownVideo, "field 'tvCountDown'", TextView.class);
        auroraCameraVideoActivity.camera = (CameraView) Utils.findRequiredViewAsType(view, R.id.camera, "field 'camera'", CameraView.class);
        View viewFindRequiredView = Utils.findRequiredView(view, R.id.btn_flash, "field 'ibFlash' and method 'toggleFlash'");
        auroraCameraVideoActivity.ibFlash = (ImageButton) Utils.castView(viewFindRequiredView, R.id.btn_flash, "field 'ibFlash'", ImageButton.class);
        this.view7f09006d = viewFindRequiredView;
        viewFindRequiredView.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.auroraCamera.AuroraCameraVideoActivity_ViewBinding.1
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                auroraCameraVideoActivity.toggleFlash();
            }
        });
        View viewFindRequiredView2 = Utils.findRequiredView(view, R.id.btn_take_video, "field 'btnTakeVideo' and method 'onTakeVideo'");
        auroraCameraVideoActivity.btnTakeVideo = (ImageButton) Utils.castView(viewFindRequiredView2, R.id.btn_take_video, "field 'btnTakeVideo'", ImageButton.class);
        this.view7f09007a = viewFindRequiredView2;
        viewFindRequiredView2.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.auroraCamera.AuroraCameraVideoActivity_ViewBinding.2
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                auroraCameraVideoActivity.onTakeVideo();
            }
        });
    }

    @Override // butterknife.Unbinder
    @CallSuper
    public void unbind() {
        AuroraCameraVideoActivity auroraCameraVideoActivity = this.target;
        if (auroraCameraVideoActivity == null) {
            throw new IllegalStateException("Bindings already cleared.");
        }
        this.target = null;
        auroraCameraVideoActivity.tvCountDown = null;
        auroraCameraVideoActivity.camera = null;
        auroraCameraVideoActivity.ibFlash = null;
        auroraCameraVideoActivity.btnTakeVideo = null;
        this.view7f09006d.setOnClickListener(null);
        this.view7f09006d = null;
        this.view7f09007a.setOnClickListener(null);
        this.view7f09007a = null;
    }
}
