package com.aurora.bdg.screen.daftarPencarian;

import android.view.View;
import android.widget.Spinner;
import android.widget.TextView;
import androidx.annotation.CallSuper;
import androidx.annotation.UiThread;
import androidx.recyclerview.widget.RecyclerView;
import butterknife.Unbinder;
import butterknife.internal.DebouncingOnClickListener;
import butterknife.internal.Utils;
import com.aurora.bdg.R;

/* JADX INFO: loaded from: classes.dex */
public class DaftarPencarianActivity_ViewBinding implements Unbinder {
    private DaftarPencarianActivity target;
    private View view7f090069;

    @UiThread
    public DaftarPencarianActivity_ViewBinding(DaftarPencarianActivity daftarPencarianActivity) {
        this(daftarPencarianActivity, daftarPencarianActivity.getWindow().getDecorView());
    }

    @UiThread
    public DaftarPencarianActivity_ViewBinding(final DaftarPencarianActivity daftarPencarianActivity, View view) {
        this.target = daftarPencarianActivity;
        daftarPencarianActivity.spnFilter = (Spinner) Utils.findRequiredViewAsType(view, R.id.spinner_filter, "field 'spnFilter'", Spinner.class);
        daftarPencarianActivity.txtKeyword = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_keyword, "field 'txtKeyword'", TextView.class);
        daftarPencarianActivity.listData = (RecyclerView) Utils.findRequiredViewAsType(view, R.id.rv_list_pelanggan, "field 'listData'", RecyclerView.class);
        daftarPencarianActivity.tvUsername = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_user_name, "field 'tvUsername'", TextView.class);
        daftarPencarianActivity.tvPeriode = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_periode, "field 'tvPeriode'", TextView.class);
        View viewFindRequiredView = Utils.findRequiredView(view, R.id.btn_cari, "method 'cariPelanggan'");
        this.view7f090069 = viewFindRequiredView;
        viewFindRequiredView.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.daftarPencarian.DaftarPencarianActivity_ViewBinding.1
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                daftarPencarianActivity.cariPelanggan();
            }
        });
    }

    @Override // butterknife.Unbinder
    @CallSuper
    public void unbind() {
        DaftarPencarianActivity daftarPencarianActivity = this.target;
        if (daftarPencarianActivity == null) {
            throw new IllegalStateException("Bindings already cleared.");
        }
        this.target = null;
        daftarPencarianActivity.spnFilter = null;
        daftarPencarianActivity.txtKeyword = null;
        daftarPencarianActivity.listData = null;
        daftarPencarianActivity.tvUsername = null;
        daftarPencarianActivity.tvPeriode = null;
        this.view7f090069.setOnClickListener(null);
        this.view7f090069 = null;
    }
}
