package com.aurora.bdg.screen.scanQrcode;

import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import butterknife.ButterKnife;
import com.aurora.bdg.R;
import com.aurora.bdg.model.Pelanggan;
import com.aurora.bdg.screen.catatStand.CatatStandActivity;
import com.aurora.bdg.util.DataBaseHelper;
import com.aurora.bdg.util.DirUtil;
import com.aurora.bdg.util.LocalStorage;
import com.google.zxing.Result;
import me.dm7.barcodescanner.zxing.ZXingScannerView;

/* JADX INFO: loaded from: classes.dex */
public class ScanQrcodeActivity extends AppCompatActivity implements ZXingScannerView.ResultHandler {
    private static final String STAND = "stand";
    public static String TAG = "ScanAndGet";
    String custCode;
    DataBaseHelper dataBaseHelper;
    LocalStorage localStorage;
    private ZXingScannerView mScannerView;
    String period;
    DirUtil dirUtil = new DirUtil();
    boolean stateFlash = false;

    @Override // androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setContentView(R.layout.activity_scan_qrcode);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setSubtitle("Scan Qrcode");
        ButterKnife.bind(this);
        this.dataBaseHelper = DataBaseHelper.getInstance(this);
        this.localStorage = new LocalStorage(this);
        this.period = this.localStorage.getPeriodeY() + "" + this.localStorage.getPeriodeM();
        this.mScannerView = new ZXingScannerView(this);
        setContentView(this.mScannerView);
    }

    @Override // androidx.fragment.app.FragmentActivity, android.app.Activity
    public void onResume() {
        super.onResume();
        this.mScannerView.setResultHandler(this);
        this.mScannerView.startCamera();
    }

    @Override // androidx.fragment.app.FragmentActivity, android.app.Activity
    public void onPause() {
        super.onPause();
        this.mScannerView.stopCamera();
    }

    @Override // android.app.Activity
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.qrcode_menu, menu);
        return super.onCreateOptionsMenu(menu);
    }

    @Override // android.app.Activity
    public boolean onOptionsItemSelected(MenuItem menuItem) {
        int itemId = menuItem.getItemId();
        if (itemId == R.id.action_home) {
            finish();
        } else {
            if (itemId == R.id.qrcode) {
            }
            return super.onOptionsItemSelected(menuItem);
        }
        if (this.stateFlash) {
            this.mScannerView.setFlash(false);
            this.stateFlash = false;
        } else {
            this.mScannerView.setFlash(true);
            this.stateFlash = true;
        }
        return super.onOptionsItemSelected(menuItem);
    }

    @Override // me.dm7.barcodescanner.zxing.ZXingScannerView.ResultHandler
    public void handleResult(Result result) {
        Log.i(TAG, "value: " + result.getText());
        this.custCode = result.getText();
        Pelanggan pelangganSearchPelanggan = this.dataBaseHelper.searchPelanggan(this.localStorage.getUserName(), this.custCode, this.localStorage.getPeriodeY(), this.localStorage.getPeriodeM());
        if (pelangganSearchPelanggan != null) {
            Intent intent = new Intent(this, (Class<?>) CatatStandActivity.class);
            intent.putExtra(CatatStandActivity.ARG_CUST_CODE_ID, pelangganSearchPelanggan.getCustCode123());
            intent.putExtra(CatatStandActivity.ARG_STATUS_READ, getString(R.string.qrcode));
            intent.setFlags(67108864);
            startActivity(intent);
            finish();
            return;
        }
        promtPelangganNotFound();
    }

    private void promtPelangganNotFound() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Pelanggan tidak ditemukan");
        builder.setPositiveButton("Scan ulang", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.scanQrcode.ScanQrcodeActivity.1
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i) {
                ScanQrcodeActivity.this.mScannerView.resumeCameraPreview(ScanQrcodeActivity.this);
            }
        });
        builder.show();
    }
}
