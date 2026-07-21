package com.aurora.bdg.screen.infoPelangganUnread;

import android.view.View;
import android.widget.TextView;
import androidx.annotation.CallSuper;
import androidx.annotation.UiThread;
import butterknife.Unbinder;
import butterknife.internal.DebouncingOnClickListener;
import butterknife.internal.Utils;
import com.aurora.bdg.R;

/* JADX INFO: loaded from: classes.dex */
public class InfoPelangganUnreadActivity_ViewBinding implements Unbinder {
    private InfoPelangganUnreadActivity target;
    private View view7f090064;
    private View view7f09006e;
    private View view7f090070;
    private View view7f090072;
    private View view7f090073;
    private View view7f090076;

    @UiThread
    public InfoPelangganUnreadActivity_ViewBinding(InfoPelangganUnreadActivity infoPelangganUnreadActivity) {
        this(infoPelangganUnreadActivity, infoPelangganUnreadActivity.getWindow().getDecorView());
    }

    @UiThread
    public InfoPelangganUnreadActivity_ViewBinding(final InfoPelangganUnreadActivity infoPelangganUnreadActivity, View view) {
        this.target = infoPelangganUnreadActivity;
        infoPelangganUnreadActivity.tvCustName = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_namacustcode, "field 'tvCustName'", TextView.class);
        infoPelangganUnreadActivity.tvAlamat = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_alamat, "field 'tvAlamat'", TextView.class);
        infoPelangganUnreadActivity.tvTarif = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_tarif, "field 'tvTarif'", TextView.class);
        infoPelangganUnreadActivity.tvWMSN = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_nosn, "field 'tvWMSN'", TextView.class);
        infoPelangganUnreadActivity.tvHp = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_nohp, "field 'tvHp'", TextView.class);
        infoPelangganUnreadActivity.tvPeriode1 = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_periode1, "field 'tvPeriode1'", TextView.class);
        infoPelangganUnreadActivity.tvPeriode2 = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_periode2, "field 'tvPeriode2'", TextView.class);
        infoPelangganUnreadActivity.tvPeriode3 = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_periode3, "field 'tvPeriode3'", TextView.class);
        infoPelangganUnreadActivity.txtUsage1 = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_usage1, "field 'txtUsage1'", TextView.class);
        infoPelangganUnreadActivity.txtUsage2 = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_usage2, "field 'txtUsage2'", TextView.class);
        infoPelangganUnreadActivity.txtUsage3 = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_usage3, "field 'txtUsage3'", TextView.class);
        infoPelangganUnreadActivity.txtHarga1 = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_harga1, "field 'txtHarga1'", TextView.class);
        infoPelangganUnreadActivity.txtHarga2 = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_harga2, "field 'txtHarga2'", TextView.class);
        infoPelangganUnreadActivity.txtHarga3 = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_harga3, "field 'txtHarga3'", TextView.class);
        View viewFindRequiredView = Utils.findRequiredView(view, R.id.btn_next, "method 'onClickNext'");
        this.view7f090072 = viewFindRequiredView;
        viewFindRequiredView.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.infoPelangganUnread.InfoPelangganUnreadActivity_ViewBinding.1
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                infoPelangganUnreadActivity.onClickNext();
            }
        });
        View viewFindRequiredView2 = Utils.findRequiredView(view, R.id.btn_lanjutkan, "method 'onClickLanjutkan'");
        this.view7f090070 = viewFindRequiredView2;
        viewFindRequiredView2.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.infoPelangganUnread.InfoPelangganUnreadActivity_ViewBinding.2
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                infoPelangganUnreadActivity.onClickLanjutkan();
            }
        });
        View viewFindRequiredView3 = Utils.findRequiredView(view, R.id.btn_prev, "method 'onClickPrev'");
        this.view7f090073 = viewFindRequiredView3;
        viewFindRequiredView3.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.infoPelangganUnread.InfoPelangganUnreadActivity_ViewBinding.3
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                infoPelangganUnreadActivity.onClickPrev();
            }
        });
        View viewFindRequiredView4 = Utils.findRequiredView(view, R.id.btn_setpermintaannourut, "method 'onClickGantiNoUrut'");
        this.view7f090076 = viewFindRequiredView4;
        viewFindRequiredView4.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.infoPelangganUnread.InfoPelangganUnreadActivity_ViewBinding.4
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                infoPelangganUnreadActivity.onClickGantiNoUrut();
            }
        });
        View viewFindRequiredView5 = Utils.findRequiredView(view, R.id.btn_getmap, "method 'onClickShowMap'");
        this.view7f09006e = viewFindRequiredView5;
        viewFindRequiredView5.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.infoPelangganUnread.InfoPelangganUnreadActivity_ViewBinding.5
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                infoPelangganUnreadActivity.onClickShowMap();
            }
        });
        View viewFindRequiredView6 = Utils.findRequiredView(view, R.id.btn_call, "method 'onClickCall'");
        this.view7f090064 = viewFindRequiredView6;
        viewFindRequiredView6.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.infoPelangganUnread.InfoPelangganUnreadActivity_ViewBinding.6
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                infoPelangganUnreadActivity.onClickCall();
            }
        });
    }

    @Override // butterknife.Unbinder
    @CallSuper
    public void unbind() {
        InfoPelangganUnreadActivity infoPelangganUnreadActivity = this.target;
        if (infoPelangganUnreadActivity == null) {
            throw new IllegalStateException("Bindings already cleared.");
        }
        this.target = null;
        infoPelangganUnreadActivity.tvCustName = null;
        infoPelangganUnreadActivity.tvAlamat = null;
        infoPelangganUnreadActivity.tvTarif = null;
        infoPelangganUnreadActivity.tvWMSN = null;
        infoPelangganUnreadActivity.tvHp = null;
        infoPelangganUnreadActivity.tvPeriode1 = null;
        infoPelangganUnreadActivity.tvPeriode2 = null;
        infoPelangganUnreadActivity.tvPeriode3 = null;
        infoPelangganUnreadActivity.txtUsage1 = null;
        infoPelangganUnreadActivity.txtUsage2 = null;
        infoPelangganUnreadActivity.txtUsage3 = null;
        infoPelangganUnreadActivity.txtHarga1 = null;
        infoPelangganUnreadActivity.txtHarga2 = null;
        infoPelangganUnreadActivity.txtHarga3 = null;
        this.view7f090072.setOnClickListener(null);
        this.view7f090072 = null;
        this.view7f090070.setOnClickListener(null);
        this.view7f090070 = null;
        this.view7f090073.setOnClickListener(null);
        this.view7f090073 = null;
        this.view7f090076.setOnClickListener(null);
        this.view7f090076 = null;
        this.view7f09006e.setOnClickListener(null);
        this.view7f09006e = null;
        this.view7f090064.setOnClickListener(null);
        this.view7f090064 = null;
    }
}
