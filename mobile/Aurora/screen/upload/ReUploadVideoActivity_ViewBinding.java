package com.aurora.bdg.screen.upload;

import android.view.View;
import android.widget.TextView;
import androidx.annotation.CallSuper;
import androidx.annotation.UiThread;
import butterknife.Unbinder;
import butterknife.internal.DebouncingOnClickListener;
import butterknife.internal.Utils;
import com.aurora.bdg.R;

/* JADX INFO: loaded from: classes.dex */
public class ReUploadVideoActivity_ViewBinding implements Unbinder {
    private ReUploadVideoActivity target;
    private View view7f09007e;

    @UiThread
    public ReUploadVideoActivity_ViewBinding(ReUploadVideoActivity reUploadVideoActivity) {
        this(reUploadVideoActivity, reUploadVideoActivity.getWindow().getDecorView());
    }

    @UiThread
    public ReUploadVideoActivity_ViewBinding(final ReUploadVideoActivity reUploadVideoActivity, View view) {
        this.target = reUploadVideoActivity;
        reUploadVideoActivity.tvReUpload = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_number_of_video, "field 'tvReUpload'", TextView.class);
        View viewFindRequiredView = Utils.findRequiredView(view, R.id.btn_upload_video, "method 'onClickUpload'");
        this.view7f09007e = viewFindRequiredView;
        viewFindRequiredView.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.upload.ReUploadVideoActivity_ViewBinding.1
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                reUploadVideoActivity.onClickUpload();
            }
        });
    }

    @Override // butterknife.Unbinder
    @CallSuper
    public void unbind() {
        ReUploadVideoActivity reUploadVideoActivity = this.target;
        if (reUploadVideoActivity == null) {
            throw new IllegalStateException("Bindings already cleared.");
        }
        this.target = null;
        reUploadVideoActivity.tvReUpload = null;
        this.view7f09007e.setOnClickListener(null);
        this.view7f09007e = null;
    }
}
