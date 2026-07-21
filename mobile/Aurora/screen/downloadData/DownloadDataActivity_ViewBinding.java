package com.aurora.bdg.screen.downloadData;

import android.view.View;
import android.widget.TextView;
import androidx.annotation.CallSuper;
import androidx.annotation.UiThread;
import butterknife.Unbinder;
import butterknife.internal.DebouncingOnClickListener;
import butterknife.internal.Utils;
import com.aurora.bdg.R;

/* JADX INFO: loaded from: classes.dex */
public class DownloadDataActivity_ViewBinding implements Unbinder {
    private DownloadDataActivity target;
    private View view7f09006b;
    private View view7f09006c;

    @UiThread
    public DownloadDataActivity_ViewBinding(DownloadDataActivity downloadDataActivity) {
        this(downloadDataActivity, downloadDataActivity.getWindow().getDecorView());
    }

    @UiThread
    public DownloadDataActivity_ViewBinding(final DownloadDataActivity downloadDataActivity, View view) {
        this.target = downloadDataActivity;
        downloadDataActivity.tvUsername = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_user_name, "field 'tvUsername'", TextView.class);
        downloadDataActivity.tvPeriode = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_periode, "field 'tvPeriode'", TextView.class);
        View viewFindRequiredView = Utils.findRequiredView(view, R.id.btn_download_kelainan, "method 'onClickDownloadAlasan'");
        this.view7f09006c = viewFindRequiredView;
        viewFindRequiredView.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.downloadData.DownloadDataActivity_ViewBinding.1
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                downloadDataActivity.onClickDownloadAlasan();
            }
        });
        View viewFindRequiredView2 = Utils.findRequiredView(view, R.id.btn_download_data, "method 'onClickDownloadData'");
        this.view7f09006b = viewFindRequiredView2;
        viewFindRequiredView2.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.downloadData.DownloadDataActivity_ViewBinding.2
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                downloadDataActivity.onClickDownloadData();
            }
        });
    }

    @Override // butterknife.Unbinder
    @CallSuper
    public void unbind() {
        DownloadDataActivity downloadDataActivity = this.target;
        if (downloadDataActivity == null) {
            throw new IllegalStateException("Bindings already cleared.");
        }
        this.target = null;
        downloadDataActivity.tvUsername = null;
        downloadDataActivity.tvPeriode = null;
        this.view7f09006c.setOnClickListener(null);
        this.view7f09006c = null;
        this.view7f09006b.setOnClickListener(null);
        this.view7f09006b = null;
    }
}
