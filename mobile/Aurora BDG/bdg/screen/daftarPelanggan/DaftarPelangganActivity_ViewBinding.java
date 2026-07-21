package com.aurora.bdg.screen.daftarPelanggan;

import android.view.View;
import androidx.annotation.CallSuper;
import androidx.annotation.UiThread;
import androidx.recyclerview.widget.RecyclerView;
import butterknife.Unbinder;
import butterknife.internal.Utils;
import com.aurora.bdg.R;

/* JADX INFO: loaded from: classes.dex */
public class DaftarPelangganActivity_ViewBinding implements Unbinder {
    private DaftarPelangganActivity target;

    @UiThread
    public DaftarPelangganActivity_ViewBinding(DaftarPelangganActivity daftarPelangganActivity) {
        this(daftarPelangganActivity, daftarPelangganActivity.getWindow().getDecorView());
    }

    @UiThread
    public DaftarPelangganActivity_ViewBinding(DaftarPelangganActivity daftarPelangganActivity, View view) {
        this.target = daftarPelangganActivity;
        daftarPelangganActivity.rvListRute = (RecyclerView) Utils.findRequiredViewAsType(view, R.id.rv_list_rute, "field 'rvListRute'", RecyclerView.class);
    }

    @Override // butterknife.Unbinder
    @CallSuper
    public void unbind() {
        DaftarPelangganActivity daftarPelangganActivity = this.target;
        if (daftarPelangganActivity == null) {
            throw new IllegalStateException("Bindings already cleared.");
        }
        this.target = null;
        daftarPelangganActivity.rvListRute = null;
    }
}
