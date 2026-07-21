package com.aurora.bdg.screen.upload;

import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import androidx.annotation.CallSuper;
import androidx.annotation.UiThread;
import butterknife.Unbinder;
import butterknife.internal.DebouncingOnClickListener;
import butterknife.internal.Utils;
import com.aurora.bdg.R;

/* JADX INFO: loaded from: classes.dex */
public class UploadDataActionActivity_ViewBinding implements Unbinder {
    private UploadDataActionActivity target;
    private View view7f09007b;

    @UiThread
    public UploadDataActionActivity_ViewBinding(UploadDataActionActivity uploadDataActionActivity) {
        this(uploadDataActionActivity, uploadDataActionActivity.getWindow().getDecorView());
    }

    @UiThread
    public UploadDataActionActivity_ViewBinding(final UploadDataActionActivity uploadDataActionActivity, View view) {
        this.target = uploadDataActionActivity;
        uploadDataActionActivity.tvNotUpload = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_notuploaded, "field 'tvNotUpload'", TextView.class);
        View viewFindRequiredView = Utils.findRequiredView(view, R.id.btn_upload, "field 'btnUpload' and method 'onClickButtonUpload'");
        uploadDataActionActivity.btnUpload = (Button) Utils.castView(viewFindRequiredView, R.id.btn_upload, "field 'btnUpload'", Button.class);
        this.view7f09007b = viewFindRequiredView;
        viewFindRequiredView.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.upload.UploadDataActionActivity_ViewBinding.1
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                uploadDataActionActivity.onClickButtonUpload();
            }
        });
    }

    @Override // butterknife.Unbinder
    @CallSuper
    public void unbind() {
        UploadDataActionActivity uploadDataActionActivity = this.target;
        if (uploadDataActionActivity == null) {
            throw new IllegalStateException("Bindings already cleared.");
        }
        this.target = null;
        uploadDataActionActivity.tvNotUpload = null;
        uploadDataActionActivity.btnUpload = null;
        this.view7f09007b.setOnClickListener(null);
        this.view7f09007b = null;
    }
}
