package com.aurora.bdg.screen.infoPelangganRead;

import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.CallSuper;
import androidx.annotation.UiThread;
import butterknife.Unbinder;
import butterknife.internal.DebouncingOnClickListener;
import butterknife.internal.Utils;
import com.aurora.bdg.R;

/* JADX INFO: loaded from: classes.dex */
public class InfoPelangganReadActivity_ViewBinding implements Unbinder {
    private InfoPelangganReadActivity target;
    private View view7f090070;
    private View view7f090072;
    private View view7f090073;
    private View view7f0900b6;
    private View view7f0900b7;
    private View view7f0900b8;
    private View view7f0900b9;

    @UiThread
    public InfoPelangganReadActivity_ViewBinding(InfoPelangganReadActivity infoPelangganReadActivity) {
        this(infoPelangganReadActivity, infoPelangganReadActivity.getWindow().getDecorView());
    }

    @UiThread
    public InfoPelangganReadActivity_ViewBinding(final InfoPelangganReadActivity infoPelangganReadActivity, View view) {
        this.target = infoPelangganReadActivity;
        infoPelangganReadActivity.tvCustName = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_namacustcode, "field 'tvCustName'", TextView.class);
        infoPelangganReadActivity.tvAlamat = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_alamat, "field 'tvAlamat'", TextView.class);
        infoPelangganReadActivity.tvTarif = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_tarif, "field 'tvTarif'", TextView.class);
        infoPelangganReadActivity.tvPeriode1 = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_periode1, "field 'tvPeriode1'", TextView.class);
        infoPelangganReadActivity.tvPeriode2 = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_periode2, "field 'tvPeriode2'", TextView.class);
        infoPelangganReadActivity.tvPeriode3 = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_periode3, "field 'tvPeriode3'", TextView.class);
        infoPelangganReadActivity.txtUsage1 = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_usage1, "field 'txtUsage1'", TextView.class);
        infoPelangganReadActivity.txtUsage2 = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_usage2, "field 'txtUsage2'", TextView.class);
        infoPelangganReadActivity.txtUsage3 = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_usage3, "field 'txtUsage3'", TextView.class);
        infoPelangganReadActivity.txtHarga1 = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_harga1, "field 'txtHarga1'", TextView.class);
        infoPelangganReadActivity.txtHarga2 = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_harga2, "field 'txtHarga2'", TextView.class);
        infoPelangganReadActivity.txtHarga3 = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_harga3, "field 'txtHarga3'", TextView.class);
        infoPelangganReadActivity.ivStand = (ImageView) Utils.findRequiredViewAsType(view, R.id.iv_stand, "field 'ivStand'", ImageView.class);
        infoPelangganReadActivity.ivRumah = (ImageView) Utils.findRequiredViewAsType(view, R.id.iv_rumah, "field 'ivRumah'", ImageView.class);
        infoPelangganReadActivity.ivSegel = (ImageView) Utils.findRequiredViewAsType(view, R.id.iv_segel, "field 'ivSegel'", ImageView.class);
        View viewFindRequiredView = Utils.findRequiredView(view, R.id.btn_lanjutkan, "field 'btnLanjutkan' and method 'onClickLanjutkan'");
        infoPelangganReadActivity.btnLanjutkan = (Button) Utils.castView(viewFindRequiredView, R.id.btn_lanjutkan, "field 'btnLanjutkan'", Button.class);
        this.view7f090070 = viewFindRequiredView;
        viewFindRequiredView.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.infoPelangganRead.InfoPelangganReadActivity_ViewBinding.1
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                infoPelangganReadActivity.onClickLanjutkan();
            }
        });
        infoPelangganReadActivity.tvPenggunaan = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_penggunaan, "field 'tvPenggunaan'", TextView.class);
        infoPelangganReadActivity.tvTagihan = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_tagihan, "field 'tvTagihan'", TextView.class);
        infoPelangganReadActivity.tvWaktuCatat = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_waktu_catat, "field 'tvWaktuCatat'", TextView.class);
        infoPelangganReadActivity.tvKelainan = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_kelainan, "field 'tvKelainan'", TextView.class);
        View viewFindRequiredView2 = Utils.findRequiredView(view, R.id.btn_prev, "method 'onClickPrev'");
        this.view7f090073 = viewFindRequiredView2;
        viewFindRequiredView2.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.infoPelangganRead.InfoPelangganReadActivity_ViewBinding.2
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                infoPelangganReadActivity.onClickPrev();
            }
        });
        View viewFindRequiredView3 = Utils.findRequiredView(view, R.id.btn_next, "method 'onClickNext'");
        this.view7f090072 = viewFindRequiredView3;
        viewFindRequiredView3.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.infoPelangganRead.InfoPelangganReadActivity_ViewBinding.3
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                infoPelangganReadActivity.onClickNext();
            }
        });
        View viewFindRequiredView4 = Utils.findRequiredView(view, R.id.cv_stand, "method 'onClickPreviewStand'");
        this.view7f0900b8 = viewFindRequiredView4;
        viewFindRequiredView4.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.infoPelangganRead.InfoPelangganReadActivity_ViewBinding.4
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                infoPelangganReadActivity.onClickPreviewStand();
            }
        });
        View viewFindRequiredView5 = Utils.findRequiredView(view, R.id.cv_segel, "method 'onClickPreviewSegel'");
        this.view7f0900b7 = viewFindRequiredView5;
        viewFindRequiredView5.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.infoPelangganRead.InfoPelangganReadActivity_ViewBinding.5
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                infoPelangganReadActivity.onClickPreviewSegel();
            }
        });
        View viewFindRequiredView6 = Utils.findRequiredView(view, R.id.cv_rumah, "method 'onClickPreviewRumah'");
        this.view7f0900b6 = viewFindRequiredView6;
        viewFindRequiredView6.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.infoPelangganRead.InfoPelangganReadActivity_ViewBinding.6
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                infoPelangganReadActivity.onClickPreviewRumah();
            }
        });
        View viewFindRequiredView7 = Utils.findRequiredView(view, R.id.cv_video, "method 'onClickPreview'");
        this.view7f0900b9 = viewFindRequiredView7;
        viewFindRequiredView7.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.infoPelangganRead.InfoPelangganReadActivity_ViewBinding.7
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                infoPelangganReadActivity.onClickPreview();
            }
        });
    }

    @Override // butterknife.Unbinder
    @CallSuper
    public void unbind() {
        InfoPelangganReadActivity infoPelangganReadActivity = this.target;
        if (infoPelangganReadActivity == null) {
            throw new IllegalStateException("Bindings already cleared.");
        }
        this.target = null;
        infoPelangganReadActivity.tvCustName = null;
        infoPelangganReadActivity.tvAlamat = null;
        infoPelangganReadActivity.tvTarif = null;
        infoPelangganReadActivity.tvPeriode1 = null;
        infoPelangganReadActivity.tvPeriode2 = null;
        infoPelangganReadActivity.tvPeriode3 = null;
        infoPelangganReadActivity.txtUsage1 = null;
        infoPelangganReadActivity.txtUsage2 = null;
        infoPelangganReadActivity.txtUsage3 = null;
        infoPelangganReadActivity.txtHarga1 = null;
        infoPelangganReadActivity.txtHarga2 = null;
        infoPelangganReadActivity.txtHarga3 = null;
        infoPelangganReadActivity.ivStand = null;
        infoPelangganReadActivity.ivRumah = null;
        infoPelangganReadActivity.ivSegel = null;
        infoPelangganReadActivity.btnLanjutkan = null;
        infoPelangganReadActivity.tvPenggunaan = null;
        infoPelangganReadActivity.tvTagihan = null;
        infoPelangganReadActivity.tvWaktuCatat = null;
        infoPelangganReadActivity.tvKelainan = null;
        this.view7f090070.setOnClickListener(null);
        this.view7f090070 = null;
        this.view7f090073.setOnClickListener(null);
        this.view7f090073 = null;
        this.view7f090072.setOnClickListener(null);
        this.view7f090072 = null;
        this.view7f0900b8.setOnClickListener(null);
        this.view7f0900b8 = null;
        this.view7f0900b7.setOnClickListener(null);
        this.view7f0900b7 = null;
        this.view7f0900b6.setOnClickListener(null);
        this.view7f0900b6 = null;
        this.view7f0900b9.setOnClickListener(null);
        this.view7f0900b9 = null;
    }
}
