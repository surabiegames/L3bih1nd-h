package com.aurora.bdg.screen.catatStand;

import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.Spinner;
import android.widget.TextView;
import androidx.annotation.CallSuper;
import androidx.annotation.UiThread;
import butterknife.Unbinder;
import butterknife.internal.DebouncingOnClickListener;
import butterknife.internal.Utils;
import com.aurora.bdg.R;

/* JADX INFO: loaded from: classes.dex */
public class CatatStandFragment_ViewBinding implements Unbinder {
    private CatatStandFragment target;
    private View view7f090065;
    private View view7f090066;
    private View view7f090067;
    private View view7f090068;
    private View view7f090077;
    private View view7f0900b6;
    private View view7f0900b7;
    private View view7f0900b8;

    @UiThread
    public CatatStandFragment_ViewBinding(final CatatStandFragment catatStandFragment, View view) {
        this.target = catatStandFragment;
        catatStandFragment.tvName = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_pelanggan_nama, "field 'tvName'", TextView.class);
        catatStandFragment.tvAddress = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_pelanggan_address, "field 'tvAddress'", TextView.class);
        catatStandFragment.tvGolonganTarif = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_pelanggan_gol_tarif, "field 'tvGolonganTarif'", TextView.class);
        catatStandFragment.etStandAwal = (EditText) Utils.findRequiredViewAsType(view, R.id.txt_standawal, "field 'etStandAwal'", EditText.class);
        catatStandFragment.etStandAkhir = (EditText) Utils.findRequiredViewAsType(view, R.id.txt_standakhir, "field 'etStandAkhir'", EditText.class);
        catatStandFragment.etKubikasi = (EditText) Utils.findRequiredViewAsType(view, R.id.txt_kubikasi, "field 'etKubikasi'", EditText.class);
        catatStandFragment.etNoHp = (EditText) Utils.findRequiredViewAsType(view, R.id.txt_nohp, "field 'etNoHp'", EditText.class);
        catatStandFragment.spListAlasan = (Spinner) Utils.findRequiredViewAsType(view, R.id.sp_kelainan, "field 'spListAlasan'", Spinner.class);
        catatStandFragment.spSegel = (Spinner) Utils.findRequiredViewAsType(view, R.id.sp_issegel, "field 'spSegel'", Spinner.class);
        catatStandFragment.spPerubahan = (Spinner) Utils.findRequiredViewAsType(view, R.id.sp_perubahan, "field 'spPerubahan'", Spinner.class);
        catatStandFragment.ivStand = (ImageView) Utils.findRequiredViewAsType(view, R.id.iv_stand, "field 'ivStand'", ImageView.class);
        catatStandFragment.ivRumah = (ImageView) Utils.findRequiredViewAsType(view, R.id.iv_rumah, "field 'ivRumah'", ImageView.class);
        catatStandFragment.ivSegel = (ImageView) Utils.findRequiredViewAsType(view, R.id.iv_segel, "field 'ivSegel'", ImageView.class);
        catatStandFragment.tvRangeLocation = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_range_location, "field 'tvRangeLocation'", TextView.class);
        View viewFindRequiredView = Utils.findRequiredView(view, R.id.btn_simpan, "method 'onClickSubmit'");
        this.view7f090077 = viewFindRequiredView;
        viewFindRequiredView.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.catatStand.CatatStandFragment_ViewBinding.1
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                catatStandFragment.onClickSubmit();
            }
        });
        View viewFindRequiredView2 = Utils.findRequiredView(view, R.id.btn_camera_ocr, "method 'onClickCameraOcr'");
        this.view7f090065 = viewFindRequiredView2;
        viewFindRequiredView2.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.catatStand.CatatStandFragment_ViewBinding.2
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                catatStandFragment.onClickCameraOcr();
            }
        });
        View viewFindRequiredView3 = Utils.findRequiredView(view, R.id.btn_camera_stand, "method 'onClickCameraStand'");
        this.view7f090068 = viewFindRequiredView3;
        viewFindRequiredView3.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.catatStand.CatatStandFragment_ViewBinding.3
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                catatStandFragment.onClickCameraStand();
            }
        });
        View viewFindRequiredView4 = Utils.findRequiredView(view, R.id.btn_camera_segel, "method 'onClickCameraSegel'");
        this.view7f090067 = viewFindRequiredView4;
        viewFindRequiredView4.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.catatStand.CatatStandFragment_ViewBinding.4
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                catatStandFragment.onClickCameraSegel();
            }
        });
        View viewFindRequiredView5 = Utils.findRequiredView(view, R.id.btn_camera_rumah, "method 'onClickCameraRumah'");
        this.view7f090066 = viewFindRequiredView5;
        viewFindRequiredView5.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.catatStand.CatatStandFragment_ViewBinding.5
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                catatStandFragment.onClickCameraRumah();
            }
        });
        View viewFindRequiredView6 = Utils.findRequiredView(view, R.id.cv_stand, "method 'onClickPreviewStand'");
        this.view7f0900b8 = viewFindRequiredView6;
        viewFindRequiredView6.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.catatStand.CatatStandFragment_ViewBinding.6
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                catatStandFragment.onClickPreviewStand();
            }
        });
        View viewFindRequiredView7 = Utils.findRequiredView(view, R.id.cv_segel, "method 'onClickPreviewSegel'");
        this.view7f0900b7 = viewFindRequiredView7;
        viewFindRequiredView7.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.catatStand.CatatStandFragment_ViewBinding.7
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                catatStandFragment.onClickPreviewSegel();
            }
        });
        View viewFindRequiredView8 = Utils.findRequiredView(view, R.id.cv_rumah, "method 'onClickPreviewRumah'");
        this.view7f0900b6 = viewFindRequiredView8;
        viewFindRequiredView8.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.catatStand.CatatStandFragment_ViewBinding.8
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                catatStandFragment.onClickPreviewRumah();
            }
        });
    }

    @Override // butterknife.Unbinder
    @CallSuper
    public void unbind() {
        CatatStandFragment catatStandFragment = this.target;
        if (catatStandFragment == null) {
            throw new IllegalStateException("Bindings already cleared.");
        }
        this.target = null;
        catatStandFragment.tvName = null;
        catatStandFragment.tvAddress = null;
        catatStandFragment.tvGolonganTarif = null;
        catatStandFragment.etStandAwal = null;
        catatStandFragment.etStandAkhir = null;
        catatStandFragment.etKubikasi = null;
        catatStandFragment.etNoHp = null;
        catatStandFragment.spListAlasan = null;
        catatStandFragment.spSegel = null;
        catatStandFragment.spPerubahan = null;
        catatStandFragment.ivStand = null;
        catatStandFragment.ivRumah = null;
        catatStandFragment.ivSegel = null;
        catatStandFragment.tvRangeLocation = null;
        this.view7f090077.setOnClickListener(null);
        this.view7f090077 = null;
        this.view7f090065.setOnClickListener(null);
        this.view7f090065 = null;
        this.view7f090068.setOnClickListener(null);
        this.view7f090068 = null;
        this.view7f090067.setOnClickListener(null);
        this.view7f090067 = null;
        this.view7f090066.setOnClickListener(null);
        this.view7f090066 = null;
        this.view7f0900b8.setOnClickListener(null);
        this.view7f0900b8 = null;
        this.view7f0900b7.setOnClickListener(null);
        this.view7f0900b7 = null;
        this.view7f0900b6.setOnClickListener(null);
        this.view7f0900b6 = null;
    }
}
