package com.aurora.bdg.screen.gantiRute;

import android.os.Bundle;
import android.view.MenuItem;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.aurora.bdg.R;
import com.aurora.bdg.util.DataBaseHelper;

/* JADX INFO: loaded from: classes.dex */
public class GantiRuteActivity extends AppCompatActivity {
    public static final String EXTRA_ADDRESS = "address";
    public static final String EXTRA_BLOK_ID = "blok-id";
    public static final String EXTRA_CUSTCODE = "cust-code";
    public static final String EXTRA_NAME = "name";
    public static final String EXTRA_NO_URUT = "no-urut";
    String address;
    String blokId;
    String custCode123;
    String custName;
    DataBaseHelper dataBaseHelper;

    @BindView(R.id.txt_nourutlama)
    EditText etNoUrutSebelum;

    @BindView(R.id.txt_nourutbaru)
    EditText etNoUrutSetelah;
    String noUrutSebelum;
    String noUrutSetelah;

    @BindView(R.id.tv_pelanggan_address)
    TextView tvAddress;

    @BindView(R.id.tv_pelanggan_gol_tarif)
    TextView tvGolonganTarif;

    @BindView(R.id.tv_pelanggan_nama)
    TextView tvName;

    @Override // androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setContentView(R.layout.activity_ganti_rute);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        ButterKnife.bind(this);
        this.dataBaseHelper = DataBaseHelper.getInstance(this);
        if (getIntent() != null) {
            this.custCode123 = getIntent().getStringExtra("cust-code");
            this.custName = getIntent().getStringExtra(EXTRA_NAME);
            this.address = getIntent().getStringExtra(EXTRA_ADDRESS);
            this.blokId = getIntent().getStringExtra("blok-id");
            this.noUrutSebelum = getIntent().getStringExtra(EXTRA_NO_URUT);
        }
    }

    @Override // androidx.fragment.app.FragmentActivity, android.app.Activity
    protected void onResume() {
        super.onResume();
        showInfoPelanggan();
    }

    @Override // android.app.Activity
    public boolean onOptionsItemSelected(MenuItem menuItem) {
        if (menuItem.getItemId() == 16908332) {
            finish();
            return true;
        }
        return super.onOptionsItemSelected(menuItem);
    }

    public void showInfoPelanggan() {
        this.tvName.setText(this.custCode123 + " " + this.custName);
        this.tvAddress.setText(this.address);
        this.tvGolonganTarif.setText(this.blokId);
        this.etNoUrutSebelum.setText(this.noUrutSebelum);
    }

    @OnClick({R.id.btn_submit})
    public void onClickSubmit() {
        this.noUrutSetelah = this.etNoUrutSetelah.getText().toString();
        if (this.dataBaseHelper.gantiRute(this.custCode123, this.noUrutSetelah)) {
            Toast.makeText(this, "Success", 0).show();
            finish();
        }
    }
}
