package com.aurora.bdg.screen.downloadPetugas;

import android.view.View;
import androidx.annotation.CallSuper;
import androidx.annotation.UiThread;
import butterknife.Unbinder;
import butterknife.internal.DebouncingOnClickListener;
import butterknife.internal.Utils;
import com.aurora.bdg.R;

/* JADX INFO: loaded from: classes.dex */
public class DownloadPetugasActivity_ViewBinding implements Unbinder {
    private DownloadPetugasActivity target;
    private View view7f09006b;

    @UiThread
    public DownloadPetugasActivity_ViewBinding(DownloadPetugasActivity downloadPetugasActivity) {
        this(downloadPetugasActivity, downloadPetugasActivity.getWindow().getDecorView());
    }

    @UiThread
    public DownloadPetugasActivity_ViewBinding(final DownloadPetugasActivity downloadPetugasActivity, View view) {
        this.target = downloadPetugasActivity;
        View viewFindRequiredView = Utils.findRequiredView(view, R.id.btn_download_data, "method 'onClickDownloadData'");
        this.view7f09006b = viewFindRequiredView;
        viewFindRequiredView.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.downloadPetugas.DownloadPetugasActivity_ViewBinding.1
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                downloadPetugasActivity.onClickDownloadData();
            }
        });
    }

    @Override // butterknife.Unbinder
    @CallSuper
    public void unbind() {
        if (this.target == null) {
            throw new IllegalStateException("Bindings already cleared.");
        }
        this.target = null;
        this.view7f09006b.setOnClickListener(null);
        this.view7f09006b = null;
    }
}
