package com.aurora.bdg.screen.upload;

import android.view.View;
import android.widget.CheckBox;
import androidx.annotation.CallSuper;
import androidx.annotation.UiThread;
import androidx.recyclerview.widget.RecyclerView;
import butterknife.Unbinder;
import butterknife.internal.DebouncingOnClickListener;
import butterknife.internal.Utils;
import com.aurora.bdg.R;

/* JADX INFO: loaded from: classes.dex */
public class UploadDataDaftarRuteActivity_ViewBinding implements Unbinder {
    private UploadDataDaftarRuteActivity target;
    private View view7f09007d;

    @UiThread
    public UploadDataDaftarRuteActivity_ViewBinding(UploadDataDaftarRuteActivity uploadDataDaftarRuteActivity) {
        this(uploadDataDaftarRuteActivity, uploadDataDaftarRuteActivity.getWindow().getDecorView());
    }

    @UiThread
    public UploadDataDaftarRuteActivity_ViewBinding(final UploadDataDaftarRuteActivity uploadDataDaftarRuteActivity, View view) {
        this.target = uploadDataDaftarRuteActivity;
        uploadDataDaftarRuteActivity.rvListJalan = (RecyclerView) Utils.findRequiredViewAsType(view, R.id.rv_list_jalan, "field 'rvListJalan'", RecyclerView.class);
        uploadDataDaftarRuteActivity.cbSelectAll = (CheckBox) Utils.findRequiredViewAsType(view, R.id.cb_select_all, "field 'cbSelectAll'", CheckBox.class);
        View viewFindRequiredView = Utils.findRequiredView(view, R.id.btn_upload_rute, "method 'checkUpload'");
        this.view7f09007d = viewFindRequiredView;
        viewFindRequiredView.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.upload.UploadDataDaftarRuteActivity_ViewBinding.1
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                uploadDataDaftarRuteActivity.checkUpload();
            }
        });
    }

    @Override // butterknife.Unbinder
    @CallSuper
    public void unbind() {
        UploadDataDaftarRuteActivity uploadDataDaftarRuteActivity = this.target;
        if (uploadDataDaftarRuteActivity == null) {
            throw new IllegalStateException("Bindings already cleared.");
        }
        this.target = null;
        uploadDataDaftarRuteActivity.rvListJalan = null;
        uploadDataDaftarRuteActivity.cbSelectAll = null;
        this.view7f09007d.setOnClickListener(null);
        this.view7f09007d = null;
    }
}
