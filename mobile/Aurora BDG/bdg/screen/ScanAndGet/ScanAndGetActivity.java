package com.aurora.bdg.screen.ScanAndGet;

import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Environment;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import butterknife.ButterKnife;
import com.aurora.bdg.R;
import com.aurora.bdg.model.Pelanggan;
import com.aurora.bdg.screen.catatStand.CatatStandActivity;
import com.aurora.bdg.util.DataBaseHelper;
import com.aurora.bdg.util.DirUtil;
import com.aurora.bdg.util.LocalStorage;
import com.aurora.bdg.util.barcodeScanner.ZBarConstants;
import java.io.File;

/* JADX INFO: loaded from: classes.dex */
public class ScanAndGetActivity extends AppCompatActivity {
    private static final int AURORA_SCANNER_REQUEST = 99;
    private static final String STAND = "stand";
    private static final int ZBAR_QR_SCANNER_REQUEST = 1;
    private static final int ZBAR_SCANNER_REQUEST = 0;
    private String custCode;
    DataBaseHelper dataBaseHelper;
    DirUtil dirUtil = new DirUtil();
    LocalStorage localStorage;
    private String period;

    @Override // androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setContentView(R.layout.activity_scan_and_get);
        getSupportActionBar().setSubtitle("Scan and Get");
        ButterKnife.bind(this);
        this.dataBaseHelper = DataBaseHelper.getInstance(this);
        this.localStorage = new LocalStorage(this);
        this.period = this.localStorage.getPeriodeY() + "" + this.localStorage.getPeriodeM();
        launchQRScanner();
    }

    public void launchQRScanner() {
        if (isCameraAvailable()) {
            startActivityForResult(new Intent(this, (Class<?>) ScanNgetCameraActivity.class), 99);
        }
    }

    public boolean isCameraAvailable() {
        return getPackageManager().hasSystemFeature("android.hardware.camera");
    }

    @Override // androidx.fragment.app.FragmentActivity, android.app.Activity
    protected void onActivityResult(int i, int i2, Intent intent) {
        if (i != 99) {
            return;
        }
        if (i2 != -1) {
            if (i2 == 0) {
                promtPelangganNotFound();
                return;
            }
            return;
        }
        this.custCode = intent.getStringExtra(ZBarConstants.SCAN_RESULT);
        Pelanggan pelangganSearchPelanggan = this.dataBaseHelper.searchPelanggan(this.localStorage.getUserName(), this.custCode, this.localStorage.getPeriodeY(), this.localStorage.getPeriodeM());
        if (pelangganSearchPelanggan != null) {
            Intent intent2 = new Intent(this, (Class<?>) CatatStandActivity.class);
            intent2.putExtra(CatatStandActivity.ARG_CUST_CODE_ID, pelangganSearchPelanggan.getCustCode123());
            intent2.putExtra(CatatStandActivity.ARG_STATUS_READ, getString(R.string.scanAndGet));
            intent2.setFlags(67108864);
            startActivity(intent2);
            finish();
            return;
        }
        try {
            new File(getImagePath("stand")).delete();
        } catch (Exception e) {
            e.printStackTrace();
        }
        promtPelangganNotFound();
    }

    private void promtPelangganNotFound() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Pelanggan tidak ditemukan");
        builder.setCancelable(false);
        builder.setPositiveButton("Scan ulang", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.ScanAndGet.ScanAndGetActivity.1
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i) {
                ScanAndGetActivity.this.launchQRScanner();
            }
        });
        builder.setNegativeButton("Keluar", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.ScanAndGet.ScanAndGetActivity.2
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i) {
                ScanAndGetActivity.this.finish();
            }
        });
        builder.show();
    }

    public String getImagePath(String str) {
        return Environment.getExternalStorageDirectory() + File.separator + this.dirUtil.dirName + File.separator + str + File.separator + (this.period + "_" + str + "_" + this.custCode) + ".jpg";
    }
}
