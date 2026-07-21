package com.aurora.bdg.screen.gantiRute;

import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import androidx.annotation.CallSuper;
import androidx.annotation.UiThread;
import butterknife.Unbinder;
import butterknife.internal.DebouncingOnClickListener;
import butterknife.internal.Utils;
import com.aurora.bdg.R;

/* JADX INFO: loaded from: classes.dex */
public class GantiRuteActivity_ViewBinding implements Unbinder {
    private GantiRuteActivity target;
    private View view7f090078;

    @UiThread
    public GantiRuteActivity_ViewBinding(GantiRuteActivity gantiRuteActivity) {
        this(gantiRuteActivity, gantiRuteActivity.getWindow().getDecorView());
    }

    @UiThread
    public GantiRuteActivity_ViewBinding(final GantiRuteActivity gantiRuteActivity, View view) {
        this.target = gantiRuteActivity;
        gantiRuteActivity.tvName = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_pelanggan_nama, "field 'tvName'", TextView.class);
        gantiRuteActivity.tvAddress = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_pelanggan_address, "field 'tvAddress'", TextView.class);
        gantiRuteActivity.tvGolonganTarif = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_pelanggan_gol_tarif, "field 'tvGolonganTarif'", TextView.class);
        gantiRuteActivity.etNoUrutSebelum = (EditText) Utils.findRequiredViewAsType(view, R.id.txt_nourutlama, "field 'etNoUrutSebelum'", EditText.class);
        gantiRuteActivity.etNoUrutSetelah = (EditText) Utils.findRequiredViewAsType(view, R.id.txt_nourutbaru, "field 'etNoUrutSetelah'", EditText.class);
        View viewFindRequiredView = Utils.findRequiredView(view, R.id.btn_submit, "method 'onClickSubmit'");
        this.view7f090078 = viewFindRequiredView;
        viewFindRequiredView.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.gantiRute.GantiRuteActivity_ViewBinding.1
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                gantiRuteActivity.onClickSubmit();
            }
        });
    }

    @Override // butterknife.Unbinder
    @CallSuper
    public void unbind() {
        GantiRuteActivity gantiRuteActivity = this.target;
        if (gantiRuteActivity == null) {
            throw new IllegalStateException("Bindings already cleared.");
        }
        this.target = null;
        gantiRuteActivity.tvName = null;
        gantiRuteActivity.tvAddress = null;
        gantiRuteActivity.tvGolonganTarif = null;
        gantiRuteActivity.etNoUrutSebelum = null;
        gantiRuteActivity.etNoUrutSetelah = null;
        this.view7f090078.setOnClickListener(null);
        this.view7f090078 = null;
    }
}
