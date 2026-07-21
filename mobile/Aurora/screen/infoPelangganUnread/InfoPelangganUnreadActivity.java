package com.aurora.bdg.screen.infoPelangganUnread;

import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.TextView;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.aurora.bdg.R;
import com.aurora.bdg.model.Pelanggan;
import com.aurora.bdg.model.ThreeMonth;
import com.aurora.bdg.screen.catatStand.CatatStandActivity;
import com.aurora.bdg.screen.gantiRute.GantiRuteActivity;
import com.aurora.bdg.screen.mainmenu.MainMenuActivity;
import com.aurora.bdg.util.DataBaseHelper;
import com.aurora.bdg.util.FormatterHelper;
import com.aurora.bdg.util.LocalStorage;

/* JADX INFO: loaded from: classes.dex */
public class InfoPelangganUnreadActivity extends AppCompatActivity {
    public static final String ARG_BLOK_ID = "blok-id";
    public static final String ARG_CUST_CODE = "cust-code";
    public static final String ARG_WAKTU_CATAT = "new-no-urut";
    public static final int RESPONSE_CATAT = 100;
    private String TAG = "InfoPelangganUnreadActivity";
    String blokId;
    String custCode;
    DataBaseHelper dataBaseHelper;
    LocalStorage localStorage;
    Pelanggan pelanggan;

    @BindView(R.id.txt_alamat)
    TextView tvAlamat;

    @BindView(R.id.txt_namacustcode)
    TextView tvCustName;

    @BindView(R.id.txt_nohp)
    TextView tvHp;

    @BindView(R.id.txt_periode1)
    TextView tvPeriode1;

    @BindView(R.id.txt_periode2)
    TextView tvPeriode2;

    @BindView(R.id.txt_periode3)
    TextView tvPeriode3;

    @BindView(R.id.txt_tarif)
    TextView tvTarif;

    @BindView(R.id.txt_nosn)
    TextView tvWMSN;

    @BindView(R.id.txt_harga1)
    TextView txtHarga1;

    @BindView(R.id.txt_harga2)
    TextView txtHarga2;

    @BindView(R.id.txt_harga3)
    TextView txtHarga3;

    @BindView(R.id.txt_usage1)
    TextView txtUsage1;

    @BindView(R.id.txt_usage2)
    TextView txtUsage2;

    @BindView(R.id.txt_usage3)
    TextView txtUsage3;

    @Override // androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setContentView(R.layout.activity_info_pelanggan_unread);
        ButterKnife.bind(this);
        this.dataBaseHelper = DataBaseHelper.getInstance(this);
        this.localStorage = new LocalStorage(this);
        getSupportActionBar().setSubtitle("Info Pelanggan");
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        if (getIntent() != null) {
            this.custCode = getIntent().getStringExtra("cust-code");
            this.blokId = getIntent().getStringExtra("blok-id");
        }
        this.pelanggan = this.dataBaseHelper.getPelanggan(this.custCode);
        showInfoPelanggan(this.pelanggan);
    }

    @Override // android.app.Activity
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.home_menu, menu);
        return super.onCreateOptionsMenu(menu);
    }

    @Override // android.app.Activity
    public boolean onOptionsItemSelected(MenuItem menuItem) {
        int itemId = menuItem.getItemId();
        if (itemId == 16908332) {
            finish();
            return true;
        }
        if (itemId == R.id.action_home) {
            Intent intent = new Intent(this, (Class<?>) MainMenuActivity.class);
            intent.setFlags(67108864);
            startActivity(intent);
            finish();
        }
        return super.onOptionsItemSelected(menuItem);
    }

    @Override // androidx.fragment.app.FragmentActivity, android.app.Activity
    protected void onActivityResult(int i, int i2, Intent intent) {
        String stringExtra;
        super.onActivityResult(i, i2, intent);
        if (i2 == -1 && i == 100 && (stringExtra = intent.getStringExtra(ARG_WAKTU_CATAT)) != null) {
            Pelanggan nextPelangganUnRead = this.dataBaseHelper.getNextPelangganUnRead(this.localStorage.getPeriodeY(), this.localStorage.getPeriodeM(), this.localStorage.getUserName(), stringExtra, this.blokId);
            if (nextPelangganUnRead != null) {
                this.pelanggan = nextPelangganUnRead;
                showInfoPelanggan(this.pelanggan);
                return;
            }
            Pelanggan nextPelangganUnRead2 = this.dataBaseHelper.getNextPelangganUnRead2(this.localStorage.getPeriodeY(), this.localStorage.getPeriodeM(), this.localStorage.getUserName(), stringExtra, this.blokId);
            if (nextPelangganUnRead2 != null) {
                this.pelanggan = nextPelangganUnRead2;
                showInfoPelanggan(this.pelanggan);
                return;
            }
            Pelanggan prevPelangganUnRead = this.dataBaseHelper.getPrevPelangganUnRead(this.localStorage.getPeriodeY(), this.localStorage.getPeriodeM(), this.localStorage.getUserName(), stringExtra, this.blokId);
            if (prevPelangganUnRead != null) {
                this.pelanggan = prevPelangganUnRead;
                showInfoPelanggan(this.pelanggan);
            } else {
                finish();
            }
        }
    }

    @OnClick({R.id.btn_next})
    public void onClickNext() {
        nextPelanggan(this.pelanggan.getWaktuCatat());
    }

    @OnClick({R.id.btn_lanjutkan})
    public void onClickLanjutkan() {
        Intent intent = new Intent(this, (Class<?>) CatatStandActivity.class);
        intent.putExtra(CatatStandActivity.ARG_CUST_CODE_ID, this.pelanggan.getCustCode123());
        intent.putExtra(CatatStandActivity.ARG_STATUS_READ, getString(R.string.daftar_pelanggan));
        startActivityForResult(intent, 100);
    }

    @OnClick({R.id.btn_prev})
    public void onClickPrev() {
        prevPelanggan(this.pelanggan.getWaktuCatat());
    }

    private void prevPelanggan(String str) {
        Pelanggan prevPelangganUnRead = this.dataBaseHelper.getPrevPelangganUnRead(this.localStorage.getPeriodeY(), this.localStorage.getPeriodeM(), this.localStorage.getUserName(), str, this.blokId);
        if (prevPelangganUnRead != null) {
            this.pelanggan = prevPelangganUnRead;
            showInfoPelanggan(this.pelanggan);
        } else {
            prevPelanggan2(this.pelanggan.getWaktuCatat());
        }
    }

    private void prevPelanggan2(String str) {
        Pelanggan prevPelangganUnRead2 = this.dataBaseHelper.getPrevPelangganUnRead2(this.localStorage.getPeriodeY(), this.localStorage.getPeriodeM(), this.localStorage.getUserName(), str, this.blokId);
        if (prevPelangganUnRead2 != null) {
            this.pelanggan = prevPelangganUnRead2;
            showInfoPelanggan(this.pelanggan);
        } else {
            promtNextPage("Anda berada pada data awal");
        }
    }

    @OnClick({R.id.btn_setpermintaannourut})
    public void onClickGantiNoUrut() {
        Intent intent = new Intent(this, (Class<?>) GantiRuteActivity.class);
        intent.putExtra("cust-code", this.pelanggan.getCustCode123());
        intent.putExtra(GantiRuteActivity.EXTRA_NAME, this.pelanggan.getCustName());
        intent.putExtra(GantiRuteActivity.EXTRA_ADDRESS, this.pelanggan.getAlamat());
        intent.putExtra(GantiRuteActivity.EXTRA_NO_URUT, this.pelanggan.getBillNoUrutRute());
        intent.putExtra("blok-id", this.pelanggan.getBillBlId());
        startActivity(intent);
    }

    public void nextPelanggan(String str) {
        Pelanggan nextPelangganUnRead = this.dataBaseHelper.getNextPelangganUnRead(this.localStorage.getPeriodeY(), this.localStorage.getPeriodeM(), this.localStorage.getUserName(), str, this.blokId);
        if (nextPelangganUnRead != null) {
            this.pelanggan = nextPelangganUnRead;
            showInfoPelanggan(this.pelanggan);
        } else {
            nextPelanggan2(this.pelanggan.getWaktuCatat());
        }
    }

    public void nextPelanggan2(String str) {
        Pelanggan nextPelangganUnRead2 = this.dataBaseHelper.getNextPelangganUnRead2(this.localStorage.getPeriodeY(), this.localStorage.getPeriodeM(), this.localStorage.getUserName(), str, this.blokId);
        if (nextPelangganUnRead2 != null) {
            this.pelanggan = nextPelangganUnRead2;
            showInfoPelanggan(this.pelanggan);
        } else {
            promtNextPage("Anda berada pada data terakhir");
        }
    }

    @OnClick({R.id.btn_getmap})
    public void onClickShowMap() {
        if (!this.pelanggan.getBillLonglat().isEmpty() && !this.pelanggan.getBillLonglat().equals("kosong")) {
            Intent intent = new Intent("android.intent.action.VIEW", Uri.parse("google.navigation:q=" + this.pelanggan.getBillLonglat()));
            intent.setPackage("com.google.android.apps.maps");
            if (intent.resolveActivity(getPackageManager()) != null) {
                startActivity(intent);
                return;
            }
            return;
        }
        promtDataNotFound();
    }

    @OnClick({R.id.btn_call})
    public void onClickCall() {
        promtCall();
    }

    private void promtCall() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setItems(R.array.spinner_call, new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.infoPelangganUnread.InfoPelangganUnreadActivity.1
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i) {
                Log.i(InfoPelangganUnreadActivity.this.TAG, "dialogCall: " + i);
                switch (i) {
                    case 0:
                        if (InfoPelangganUnreadActivity.this.pelanggan.getNoHp().equals("0") || InfoPelangganUnreadActivity.this.pelanggan.getNoHp().isEmpty()) {
                            InfoPelangganUnreadActivity.this.promtDataNotFound();
                        } else {
                            String str = "tel:" + InfoPelangganUnreadActivity.this.pelanggan.getNoHp();
                            Intent intent = new Intent("android.intent.action.DIAL");
                            intent.setData(Uri.parse(str));
                            InfoPelangganUnreadActivity.this.startActivity(intent);
                        }
                        break;
                    case 1:
                        if (InfoPelangganUnreadActivity.this.pelanggan.getNoHp().equals("0") || InfoPelangganUnreadActivity.this.pelanggan.getNoHp().isEmpty()) {
                            InfoPelangganUnreadActivity.this.promtDataNotFound();
                        } else {
                            InfoPelangganUnreadActivity.this.startActivity(new Intent("android.intent.action.VIEW", Uri.parse("https://api.whatsapp.com/send?phone=" + InfoPelangganUnreadActivity.this.pelanggan.getNoHp())));
                        }
                        break;
                }
            }
        });
        builder.show();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void promtDataNotFound() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Data tidak tersedia");
        builder.setCancelable(false);
        builder.setPositiveButton("OK", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.infoPelangganUnread.InfoPelangganUnreadActivity.2
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i) {
            }
        });
        builder.show();
    }

    private void promtNextPage(String str) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle(str);
        builder.setCancelable(false);
        builder.setPositiveButton("OK", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.infoPelangganUnread.InfoPelangganUnreadActivity.3
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i) {
            }
        });
        builder.show();
    }

    public void showInfoPelanggan(Pelanggan pelanggan) {
        this.tvCustName.setText(pelanggan.getCustCode123() + " - " + pelanggan.getCustName());
        this.tvAlamat.setText("Alamat: " + pelanggan.getAlamat());
        this.tvTarif.setText("Tarif: " + pelanggan.getTarif());
        this.tvHp.setText("No Hp: " + pelanggan.getNoHp());
        this.tvWMSN.setText("WMSN: " + pelanggan.getBillKdWmsizeid() + "-" + pelanggan.getWmsn());
        ThreeMonth threeMonth = this.dataBaseHelper.getThreeMonth(pelanggan.getCustCode123());
        if (threeMonth != null) {
            this.txtUsage1.setText(threeMonth.getPeriod1Stand2() + " - " + threeMonth.getPeriod1Stand1() + " = " + threeMonth.getPeriod1Usage());
            this.tvPeriode1.setText(threeMonth.getPeriod1());
            this.txtHarga1.setText(FormatterHelper.addComma(Integer.valueOf(threeMonth.getPeriod1Tagihan() != null ? threeMonth.getPeriod1Tagihan() : "0").intValue()));
            this.txtUsage2.setText(threeMonth.getPeriod2Stand2() + " - " + threeMonth.getPeriod2Stand1() + " = " + threeMonth.getPeriod2Usage());
            this.tvPeriode2.setText(threeMonth.getPeriod2());
            this.txtHarga2.setText(FormatterHelper.addComma(Integer.valueOf(threeMonth.getPeriod2Tagihan() != null ? threeMonth.getPeriod2Tagihan() : "0").intValue()));
            this.txtUsage3.setText(threeMonth.getPeriod3Stand2() + " - " + threeMonth.getPeriod2Stand1() + " = " + threeMonth.getPeriod3Usage());
            this.tvPeriode3.setText(threeMonth.getPeriod3());
            if (threeMonth.getPeriod3Tagihan() != null && !threeMonth.getPeriod3Tagihan().equals("0")) {
                this.txtHarga3.setText(FormatterHelper.addComma(Integer.valueOf(threeMonth.getPeriod3Tagihan()).intValue()));
            } else {
                this.txtHarga3.setText("0");
            }
        }
    }
}
