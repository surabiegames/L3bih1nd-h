package com.aurora.bdg.screen.mainmenu;

import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.widget.ProgressBar;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.cardview.widget.CardView;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.aurora.bdg.App;
import com.aurora.bdg.R;
import com.aurora.bdg.model.DaoSession;
import com.aurora.bdg.screen.ScanAndGet.ScanAndGetActivity;
import com.aurora.bdg.screen.checkTagihan.CheckTagihanActivity;
import com.aurora.bdg.screen.daftarPelanggan.DaftarPelangganActivity;
import com.aurora.bdg.screen.daftarPencarian.DaftarPencarianActivity;
import com.aurora.bdg.screen.downloadData.DownloadDataActivity;
import com.aurora.bdg.screen.login.LoginActivity;
import com.aurora.bdg.screen.ocr.MainOcrActivity;
import com.aurora.bdg.screen.scanQrcode.ScanQrcodeActivity;
import com.aurora.bdg.screen.upload.UploadMenuActivity;
import com.aurora.bdg.util.DataBaseHelper;
import com.aurora.bdg.util.DirUtil;
import com.aurora.bdg.util.GPSTracker;
import com.aurora.bdg.util.LocalStorage;
import com.aurora.bdg.util.SDCardHandler;
import com.aurora.bdg.util.TimeUtil;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.messaging.FirebaseMessaging;
import java.util.HashMap;

/* JADX INFO: loaded from: classes.dex */
public class MainMenuActivity extends AppCompatActivity {

    @BindView(R.id.crd_dp)
    CardView crdDaftarPelanggan;

    @BindView(R.id.crd_ocr)
    CardView crdOcr;

    @BindView(R.id.crd_pencarian)
    CardView crdPencarian;

    @BindView(R.id.crd_qrcode)
    CardView crdQrcode;

    @BindView(R.id.crd_scanget)
    CardView crdScanGet;
    DaoSession daoSession;
    DataBaseHelper dataBaseHelper;
    LocalStorage localStorage;

    @BindView(R.id.progress_bar_catat)
    ProgressBar progressBarCatat;

    @BindView(R.id.progress_bar_memory)
    ProgressBar progressBarMemory;

    @BindView(R.id.tv_not_upload)
    TextView tvNotUpload;

    @BindView(R.id.tv_periode)
    TextView tvPeriode;

    @BindView(R.id.txt_progressbar_catat)
    TextView tvProgressBarCatat;

    @BindView(R.id.txt_progressbar_memory)
    TextView tvProgressBarMemory;

    @BindView(R.id.tv_today_reading)
    TextView tvTodayReading;

    @BindView(R.id.tv_user_name)
    TextView tvUserName;
    TimeUtil timeUtil = new TimeUtil();
    DirUtil dirUtil = new DirUtil();

    @Override // androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setContentView(R.layout.activity_main_menu);
        ButterKnife.bind(this);
        this.localStorage = new LocalStorage(this);
        this.dataBaseHelper = DataBaseHelper.getInstance(this);
        this.dirUtil.MakeDefaultDirectory(this);
        this.daoSession = ((App) getApplication()).getDaoSession();
    }

    @Override // androidx.fragment.app.FragmentActivity, android.app.Activity
    protected void onResume() {
        super.onResume();
        this.dirUtil.generateNoMedia();
        isLogin(this.localStorage.isLoggedIn());
    }

    @Override // androidx.activity.ComponentActivity, android.app.Activity
    public void onBackPressed() {
        exitDialogPromt();
    }

    @OnClick({R.id.crd_dp})
    public void onClickDaftarPelanggan() {
        startActivity(new Intent(this, (Class<?>) DaftarPelangganActivity.class));
    }

    @OnClick({R.id.crd_pencarian})
    public void onClickDaftarPencarian() {
        startActivity(new Intent(this, (Class<?>) DaftarPencarianActivity.class));
    }

    @OnClick({R.id.crd_ocr})
    public void onClickOcr() {
        startActivity(new Intent(this, (Class<?>) MainOcrActivity.class));
    }

    @OnClick({R.id.crd_scanget})
    public void onClickScanNget() {
        startActivity(new Intent(this, (Class<?>) ScanAndGetActivity.class));
    }

    @OnClick({R.id.crd_qrcode})
    public void onClickScanQrcode() {
        startActivity(new Intent(this, (Class<?>) ScanQrcodeActivity.class));
    }

    @OnClick({R.id.tv_download})
    public void onClickLogin() {
        startActivity(new Intent(this, (Class<?>) DownloadDataActivity.class));
    }

    @OnClick({R.id.tv_upload})
    public void onClickUpload() {
        startActivity(new Intent(this, (Class<?>) UploadMenuActivity.class));
    }

    @OnClick({R.id.crd_check_tagihan})
    public void onClickCekTagihan() {
        startActivity(new Intent(this, (Class<?>) CheckTagihanActivity.class));
    }

    @OnClick({R.id.tv_logout})
    public void onClickLogout() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Keluar Aplikasi ");
        builder.setPositiveButton("Ya", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.mainmenu.MainMenuActivity.1
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i) {
                MainMenuActivity.this.logout();
            }
        });
        builder.setNegativeButton("Tidak", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.mainmenu.MainMenuActivity.2
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i) {
            }
        });
        builder.show();
    }

    public void showDataUser() {
        this.tvUserName.setText(this.localStorage.getUserName());
        this.tvPeriode.setText(this.localStorage.getPeriodeY() + "" + this.localStorage.getPeriodeM());
    }

    public void showTodayReading() {
        this.tvTodayReading.setText(String.valueOf(this.dataBaseHelper.getTodayReading(this.localStorage.getUserName(), this.timeUtil.dateNow())));
        this.tvNotUpload.setText(String.valueOf(this.dataBaseHelper.getNotUpload(this.localStorage.getUserName())));
    }

    public void checkGPS() {
        GPSTracker gPSTracker = new GPSTracker(this);
        if (gPSTracker.canGetLocation()) {
            return;
        }
        gPSTracker.showSettingsAlert();
    }

    public void showProgressBar() {
        HashMap<String, Integer> dashboardPorgress = this.dataBaseHelper.getDashboardPorgress(this.localStorage.getUserName(), this.localStorage.getPeriodeM(), this.localStorage.getPeriodeY());
        int iIntValue = dashboardPorgress.get("totalBilling").intValue();
        int iIntValue2 = dashboardPorgress.get("readBilling").intValue();
        double dFloor = Math.floor((((double) (iIntValue2 * 100)) / ((double) iIntValue)) * 100.0d) / 100.0d;
        this.tvProgressBarCatat.setText("Progress : " + iIntValue2 + "/" + iIntValue + "  ( " + dFloor + "% )");
        this.progressBarCatat.setMax(iIntValue);
        this.progressBarCatat.setProgress(iIntValue2);
        int iIsSpaceAvailable = this.dirUtil.IsSpaceAvailable();
        DirUtil dirUtil = this.dirUtil;
        if (iIsSpaceAvailable == 0) {
            this.tvProgressBarMemory.setText("Memory Aman");
        } else {
            DirUtil dirUtil2 = this.dirUtil;
            if (iIsSpaceAvailable == 1) {
                this.tvProgressBarMemory.setText("Memory 10 MB");
            } else {
                DirUtil dirUtil3 = this.dirUtil;
                if (iIsSpaceAvailable == 2) {
                    this.tvProgressBarMemory.setText("Memory 5 MB");
                } else {
                    DirUtil dirUtil4 = this.dirUtil;
                    if (iIsSpaceAvailable == 3) {
                        this.tvProgressBarMemory.setText("Memory Tidak Aman");
                    }
                }
            }
        }
        SDCardHandler sDCardHandler = new SDCardHandler();
        sDCardHandler.InitializeAll();
        int i = Integer.parseInt("" + sDCardHandler.EXT_TOTAL_SPACE_MB);
        int i2 = Integer.parseInt("" + sDCardHandler.EXT_USED_SPACE_MB);
        this.progressBarMemory.setMax(i);
        this.progressBarMemory.setProgress(i2);
        float f = (float) (100 - ((i2 * 100) / i));
        this.tvProgressBarMemory.setText("Sisa memory : " + sDCardHandler.EXT_FREE_SPACE_MB + " Mb (" + f + " %)");
    }

    public void logout() {
        FirebaseMessaging.getInstance().unsubscribeFromTopic(this.localStorage.getUserName());
        this.localStorage.logoutUser();
        Intent intent = new Intent(this, (Class<?>) LoginActivity.class);
        intent.setFlags(67108864);
        startActivity(intent);
        finish();
    }

    private void exitDialogPromt() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Keluar Aplikasi? ");
        builder.setPositiveButton("Ya", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.mainmenu.MainMenuActivity.3
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i) {
                MainMenuActivity.this.finish();
            }
        });
        builder.setNegativeButton("Tidak", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.mainmenu.MainMenuActivity.4
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i) {
            }
        });
        builder.show();
    }

    public void isLogin(boolean z) {
        if (!z) {
            Intent intent = new Intent(this, (Class<?>) LoginActivity.class);
            intent.setFlags(67108864);
            startActivity(intent);
            finish();
            return;
        }
        this.localStorage.setPeriode(this.timeUtil.timeNowYm());
        checkGPS();
        showDataUser();
        showProgressBar();
        showTodayReading();
        subscribeTopic(this.localStorage.getUserName());
    }

    public static void subscribeTopic(String str) {
        FirebaseMessaging.getInstance().subscribeToTopic(str).addOnCompleteListener(new OnCompleteListener<Void>() { // from class: com.aurora.bdg.screen.mainmenu.MainMenuActivity.5
            @Override // com.google.android.gms.tasks.OnCompleteListener
            public void onComplete(@NonNull Task<Void> task) {
                task.isSuccessful();
            }
        });
    }
}
