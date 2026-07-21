package com.aurora.bdg.screen.mainmenu;

import android.view.View;
import android.widget.ProgressBar;
import android.widget.TextView;
import androidx.annotation.CallSuper;
import androidx.annotation.UiThread;
import androidx.cardview.widget.CardView;
import butterknife.Unbinder;
import butterknife.internal.DebouncingOnClickListener;
import butterknife.internal.Utils;
import com.aurora.bdg.R;

/* JADX INFO: loaded from: classes.dex */
public class MainMenuActivity_ViewBinding implements Unbinder {
    private MainMenuActivity target;
    private View view7f0900a8;
    private View view7f0900a9;
    private View view7f0900aa;
    private View view7f0900ab;
    private View view7f0900ac;
    private View view7f0900ad;
    private View view7f09023e;
    private View view7f090241;
    private View view7f09025e;

    @UiThread
    public MainMenuActivity_ViewBinding(MainMenuActivity mainMenuActivity) {
        this(mainMenuActivity, mainMenuActivity.getWindow().getDecorView());
    }

    @UiThread
    public MainMenuActivity_ViewBinding(final MainMenuActivity mainMenuActivity, View view) {
        this.target = mainMenuActivity;
        View viewFindRequiredView = Utils.findRequiredView(view, R.id.crd_dp, "field 'crdDaftarPelanggan' and method 'onClickDaftarPelanggan'");
        mainMenuActivity.crdDaftarPelanggan = (CardView) Utils.castView(viewFindRequiredView, R.id.crd_dp, "field 'crdDaftarPelanggan'", CardView.class);
        this.view7f0900a9 = viewFindRequiredView;
        viewFindRequiredView.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.mainmenu.MainMenuActivity_ViewBinding.1
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                mainMenuActivity.onClickDaftarPelanggan();
            }
        });
        View viewFindRequiredView2 = Utils.findRequiredView(view, R.id.crd_pencarian, "field 'crdPencarian' and method 'onClickDaftarPencarian'");
        mainMenuActivity.crdPencarian = (CardView) Utils.castView(viewFindRequiredView2, R.id.crd_pencarian, "field 'crdPencarian'", CardView.class);
        this.view7f0900ab = viewFindRequiredView2;
        viewFindRequiredView2.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.mainmenu.MainMenuActivity_ViewBinding.2
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                mainMenuActivity.onClickDaftarPencarian();
            }
        });
        View viewFindRequiredView3 = Utils.findRequiredView(view, R.id.crd_qrcode, "field 'crdQrcode' and method 'onClickScanQrcode'");
        mainMenuActivity.crdQrcode = (CardView) Utils.castView(viewFindRequiredView3, R.id.crd_qrcode, "field 'crdQrcode'", CardView.class);
        this.view7f0900ac = viewFindRequiredView3;
        viewFindRequiredView3.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.mainmenu.MainMenuActivity_ViewBinding.3
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                mainMenuActivity.onClickScanQrcode();
            }
        });
        View viewFindRequiredView4 = Utils.findRequiredView(view, R.id.crd_ocr, "field 'crdOcr' and method 'onClickOcr'");
        mainMenuActivity.crdOcr = (CardView) Utils.castView(viewFindRequiredView4, R.id.crd_ocr, "field 'crdOcr'", CardView.class);
        this.view7f0900aa = viewFindRequiredView4;
        viewFindRequiredView4.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.mainmenu.MainMenuActivity_ViewBinding.4
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                mainMenuActivity.onClickOcr();
            }
        });
        View viewFindRequiredView5 = Utils.findRequiredView(view, R.id.crd_scanget, "field 'crdScanGet' and method 'onClickScanNget'");
        mainMenuActivity.crdScanGet = (CardView) Utils.castView(viewFindRequiredView5, R.id.crd_scanget, "field 'crdScanGet'", CardView.class);
        this.view7f0900ad = viewFindRequiredView5;
        viewFindRequiredView5.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.mainmenu.MainMenuActivity_ViewBinding.5
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                mainMenuActivity.onClickScanNget();
            }
        });
        mainMenuActivity.tvUserName = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_user_name, "field 'tvUserName'", TextView.class);
        mainMenuActivity.tvPeriode = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_periode, "field 'tvPeriode'", TextView.class);
        mainMenuActivity.tvTodayReading = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_today_reading, "field 'tvTodayReading'", TextView.class);
        mainMenuActivity.tvNotUpload = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_not_upload, "field 'tvNotUpload'", TextView.class);
        mainMenuActivity.progressBarCatat = (ProgressBar) Utils.findRequiredViewAsType(view, R.id.progress_bar_catat, "field 'progressBarCatat'", ProgressBar.class);
        mainMenuActivity.tvProgressBarCatat = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_progressbar_catat, "field 'tvProgressBarCatat'", TextView.class);
        mainMenuActivity.progressBarMemory = (ProgressBar) Utils.findRequiredViewAsType(view, R.id.progress_bar_memory, "field 'progressBarMemory'", ProgressBar.class);
        mainMenuActivity.tvProgressBarMemory = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_progressbar_memory, "field 'tvProgressBarMemory'", TextView.class);
        View viewFindRequiredView6 = Utils.findRequiredView(view, R.id.tv_download, "method 'onClickLogin'");
        this.view7f09023e = viewFindRequiredView6;
        viewFindRequiredView6.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.mainmenu.MainMenuActivity_ViewBinding.6
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                mainMenuActivity.onClickLogin();
            }
        });
        View viewFindRequiredView7 = Utils.findRequiredView(view, R.id.tv_upload, "method 'onClickUpload'");
        this.view7f09025e = viewFindRequiredView7;
        viewFindRequiredView7.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.mainmenu.MainMenuActivity_ViewBinding.7
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                mainMenuActivity.onClickUpload();
            }
        });
        View viewFindRequiredView8 = Utils.findRequiredView(view, R.id.crd_check_tagihan, "method 'onClickCekTagihan'");
        this.view7f0900a8 = viewFindRequiredView8;
        viewFindRequiredView8.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.mainmenu.MainMenuActivity_ViewBinding.8
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                mainMenuActivity.onClickCekTagihan();
            }
        });
        View viewFindRequiredView9 = Utils.findRequiredView(view, R.id.tv_logout, "method 'onClickLogout'");
        this.view7f090241 = viewFindRequiredView9;
        viewFindRequiredView9.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.mainmenu.MainMenuActivity_ViewBinding.9
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                mainMenuActivity.onClickLogout();
            }
        });
    }

    @Override // butterknife.Unbinder
    @CallSuper
    public void unbind() {
        MainMenuActivity mainMenuActivity = this.target;
        if (mainMenuActivity == null) {
            throw new IllegalStateException("Bindings already cleared.");
        }
        this.target = null;
        mainMenuActivity.crdDaftarPelanggan = null;
        mainMenuActivity.crdPencarian = null;
        mainMenuActivity.crdQrcode = null;
        mainMenuActivity.crdOcr = null;
        mainMenuActivity.crdScanGet = null;
        mainMenuActivity.tvUserName = null;
        mainMenuActivity.tvPeriode = null;
        mainMenuActivity.tvTodayReading = null;
        mainMenuActivity.tvNotUpload = null;
        mainMenuActivity.progressBarCatat = null;
        mainMenuActivity.tvProgressBarCatat = null;
        mainMenuActivity.progressBarMemory = null;
        mainMenuActivity.tvProgressBarMemory = null;
        this.view7f0900a9.setOnClickListener(null);
        this.view7f0900a9 = null;
        this.view7f0900ab.setOnClickListener(null);
        this.view7f0900ab = null;
        this.view7f0900ac.setOnClickListener(null);
        this.view7f0900ac = null;
        this.view7f0900aa.setOnClickListener(null);
        this.view7f0900aa = null;
        this.view7f0900ad.setOnClickListener(null);
        this.view7f0900ad = null;
        this.view7f09023e.setOnClickListener(null);
        this.view7f09023e = null;
        this.view7f09025e.setOnClickListener(null);
        this.view7f09025e = null;
        this.view7f0900a8.setOnClickListener(null);
        this.view7f0900a8 = null;
        this.view7f090241.setOnClickListener(null);
        this.view7f090241 = null;
    }
}
