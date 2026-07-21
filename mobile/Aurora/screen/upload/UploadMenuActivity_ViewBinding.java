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
public class UploadMenuActivity_ViewBinding implements Unbinder {
    private UploadMenuActivity target;
    private View view7f090074;
    private View view7f090075;
    private View view7f09007f;

    @UiThread
    public UploadMenuActivity_ViewBinding(UploadMenuActivity uploadMenuActivity) {
        this(uploadMenuActivity, uploadMenuActivity.getWindow().getDecorView());
    }

    @UiThread
    public UploadMenuActivity_ViewBinding(final UploadMenuActivity uploadMenuActivity, View view) {
        this.target = uploadMenuActivity;
        uploadMenuActivity.tvUsername = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_user_name, "field 'tvUsername'", TextView.class);
        uploadMenuActivity.tvPeriode = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_periode, "field 'tvPeriode'", TextView.class);
        uploadMenuActivity.txt_judulupload = (TextView) Utils.findRequiredViewAsType(view, R.id.jdl_txtupload, "field 'txt_judulupload'", TextView.class);
        uploadMenuActivity.tvUploadData = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_upload_data, "field 'tvUploadData'", TextView.class);
        uploadMenuActivity.tvUploadFoto = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_upload_foto, "field 'tvUploadFoto'", TextView.class);
        View viewFindRequiredView = Utils.findRequiredView(view, R.id.btn_uploaddata, "method 'uploadDataFoto'");
        this.view7f09007f = viewFindRequiredView;
        viewFindRequiredView.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.upload.UploadMenuActivity_ViewBinding.1
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                uploadMenuActivity.uploadDataFoto();
            }
        });
        View viewFindRequiredView2 = Utils.findRequiredView(view, R.id.btn_reupload_photo, "method 'reuploadPhoto'");
        this.view7f090074 = viewFindRequiredView2;
        viewFindRequiredView2.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.upload.UploadMenuActivity_ViewBinding.2
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                uploadMenuActivity.reuploadPhoto();
            }
        });
        View viewFindRequiredView3 = Utils.findRequiredView(view, R.id.btn_reupload_video, "method 'reuploadVideo'");
        this.view7f090075 = viewFindRequiredView3;
        viewFindRequiredView3.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.upload.UploadMenuActivity_ViewBinding.3
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                uploadMenuActivity.reuploadVideo();
            }
        });
    }

    @Override // butterknife.Unbinder
    @CallSuper
    public void unbind() {
        UploadMenuActivity uploadMenuActivity = this.target;
        if (uploadMenuActivity == null) {
            throw new IllegalStateException("Bindings already cleared.");
        }
        this.target = null;
        uploadMenuActivity.tvUsername = null;
        uploadMenuActivity.tvPeriode = null;
        uploadMenuActivity.txt_judulupload = null;
        uploadMenuActivity.tvUploadData = null;
        uploadMenuActivity.tvUploadFoto = null;
        this.view7f09007f.setOnClickListener(null);
        this.view7f09007f = null;
        this.view7f090074.setOnClickListener(null);
        this.view7f090074 = null;
        this.view7f090075.setOnClickListener(null);
        this.view7f090075 = null;
    }
}
