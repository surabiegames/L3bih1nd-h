package com.aurora.bdg.screen.catatStand;

import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.VideoView;
import androidx.annotation.CallSuper;
import androidx.annotation.UiThread;
import butterknife.Unbinder;
import butterknife.internal.DebouncingOnClickListener;
import butterknife.internal.Utils;
import com.aurora.bdg.R;

/* JADX INFO: loaded from: classes.dex */
public class CatatStandRecordVideoFragment_ViewBinding implements Unbinder {
    private CatatStandRecordVideoFragment target;
    private View view7f09006a;
    private View view7f090080;
    private View view7f0900b9;

    @UiThread
    public CatatStandRecordVideoFragment_ViewBinding(final CatatStandRecordVideoFragment catatStandRecordVideoFragment, View view) {
        this.target = catatStandRecordVideoFragment;
        catatStandRecordVideoFragment.videoThumbnail = (VideoView) Utils.findRequiredViewAsType(view, R.id.video_thumbnail, "field 'videoThumbnail'", VideoView.class);
        View viewFindRequiredView = Utils.findRequiredView(view, R.id.btn_delete_video, "field 'btnDeleteVideo' and method 'onClickDeleteVideo'");
        catatStandRecordVideoFragment.btnDeleteVideo = (Button) Utils.castView(viewFindRequiredView, R.id.btn_delete_video, "field 'btnDeleteVideo'", Button.class);
        this.view7f09006a = viewFindRequiredView;
        viewFindRequiredView.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.catatStand.CatatStandRecordVideoFragment_ViewBinding.1
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                catatStandRecordVideoFragment.onClickDeleteVideo();
            }
        });
        catatStandRecordVideoFragment.ivNoVideo = (ImageView) Utils.findRequiredViewAsType(view, R.id.video_box, "field 'ivNoVideo'", ImageView.class);
        View viewFindRequiredView2 = Utils.findRequiredView(view, R.id.btn_video, "method 'onClickRecordeVideo'");
        this.view7f090080 = viewFindRequiredView2;
        viewFindRequiredView2.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.catatStand.CatatStandRecordVideoFragment_ViewBinding.2
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                catatStandRecordVideoFragment.onClickRecordeVideo();
            }
        });
        View viewFindRequiredView3 = Utils.findRequiredView(view, R.id.cv_video, "method 'onClickPreview'");
        this.view7f0900b9 = viewFindRequiredView3;
        viewFindRequiredView3.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.catatStand.CatatStandRecordVideoFragment_ViewBinding.3
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                catatStandRecordVideoFragment.onClickPreview();
            }
        });
    }

    @Override // butterknife.Unbinder
    @CallSuper
    public void unbind() {
        CatatStandRecordVideoFragment catatStandRecordVideoFragment = this.target;
        if (catatStandRecordVideoFragment == null) {
            throw new IllegalStateException("Bindings already cleared.");
        }
        this.target = null;
        catatStandRecordVideoFragment.videoThumbnail = null;
        catatStandRecordVideoFragment.btnDeleteVideo = null;
        catatStandRecordVideoFragment.ivNoVideo = null;
        this.view7f09006a.setOnClickListener(null);
        this.view7f09006a = null;
        this.view7f090080.setOnClickListener(null);
        this.view7f090080 = null;
        this.view7f0900b9.setOnClickListener(null);
        this.view7f0900b9 = null;
    }
}
