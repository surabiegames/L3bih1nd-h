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
public class ReUploadPhotoActivity_ViewBinding implements Unbinder {
    private ReUploadPhotoActivity target;
    private View view7f09007c;

    @UiThread
    public ReUploadPhotoActivity_ViewBinding(ReUploadPhotoActivity reUploadPhotoActivity) {
        this(reUploadPhotoActivity, reUploadPhotoActivity.getWindow().getDecorView());
    }

    @UiThread
    public ReUploadPhotoActivity_ViewBinding(final ReUploadPhotoActivity reUploadPhotoActivity, View view) {
        this.target = reUploadPhotoActivity;
        reUploadPhotoActivity.tvReUpload = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_number_of_photo, "field 'tvReUpload'", TextView.class);
        View viewFindRequiredView = Utils.findRequiredView(view, R.id.btn_upload_photo, "method 'onClickUpload'");
        this.view7f09007c = viewFindRequiredView;
        viewFindRequiredView.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.upload.ReUploadPhotoActivity_ViewBinding.1
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                reUploadPhotoActivity.onClickUpload();
            }
        });
    }

    @Override // butterknife.Unbinder
    @CallSuper
    public void unbind() {
        ReUploadPhotoActivity reUploadPhotoActivity = this.target;
        if (reUploadPhotoActivity == null) {
            throw new IllegalStateException("Bindings already cleared.");
        }
        this.target = null;
        reUploadPhotoActivity.tvReUpload = null;
        this.view7f09007c.setOnClickListener(null);
        this.view7f09007c = null;
    }
}
