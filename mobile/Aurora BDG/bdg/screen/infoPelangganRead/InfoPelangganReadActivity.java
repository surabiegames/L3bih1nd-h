package com.aurora.bdg.screen.infoPelangganRead;

import android.content.Intent;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.FileProvider;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.aurora.bdg.R;
import com.aurora.bdg.model.DataMeter;
import com.aurora.bdg.model.Pelanggan;
import com.aurora.bdg.model.ThreeMonth;
import com.aurora.bdg.screen.catatStand.CatatStandActivity;
import com.aurora.bdg.screen.mainmenu.MainMenuActivity;
import com.aurora.bdg.util.DataBaseHelper;
import com.aurora.bdg.util.DirUtil;
import com.aurora.bdg.util.FormatterHelper;
import com.aurora.bdg.util.LocalStorage;
import java.io.File;

/* JADX INFO: loaded from: classes.dex */
public class InfoPelangganReadActivity extends AppCompatActivity {
    public static final String ARG_BLOK_ID = "blok-id";
    public static final String ARG_CUST_CODE = "cust-code";
    public static final int RESPONSE_CATAT = 100;
    private static final String RUMAH = "rumah";
    private static final String SEGEL = "segel";
    private static final String STAND = "stand";
    private static String TAG = "InfoPelangganRead";
    private static final String VIDEO = "video";
    String blokId;

    @BindView(R.id.btn_lanjutkan)
    Button btnLanjutkan;
    String custCode;
    DataBaseHelper dataBaseHelper;
    DirUtil dirUtil = new DirUtil();

    @BindView(R.id.iv_rumah)
    ImageView ivRumah;

    @BindView(R.id.iv_segel)
    ImageView ivSegel;

    @BindView(R.id.iv_stand)
    ImageView ivStand;
    LocalStorage localStorage;
    Pelanggan pelanggan;
    String period;

    @BindView(R.id.txt_alamat)
    TextView tvAlamat;

    @BindView(R.id.txt_namacustcode)
    TextView tvCustName;

    @BindView(R.id.txt_kelainan)
    TextView tvKelainan;

    @BindView(R.id.txt_penggunaan)
    TextView tvPenggunaan;

    @BindView(R.id.txt_periode1)
    TextView tvPeriode1;

    @BindView(R.id.txt_periode2)
    TextView tvPeriode2;

    @BindView(R.id.txt_periode3)
    TextView tvPeriode3;

    @BindView(R.id.txt_tagihan)
    TextView tvTagihan;

    @BindView(R.id.txt_tarif)
    TextView tvTarif;

    @BindView(R.id.txt_waktu_catat)
    TextView tvWaktuCatat;

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
        setContentView(R.layout.activity_info_pelanggan_read);
        ButterKnife.bind(this);
        this.dataBaseHelper = DataBaseHelper.getInstance(this);
        this.localStorage = new LocalStorage(this);
        getSupportActionBar().setSubtitle("Info Pelanggan");
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        this.period = this.localStorage.getPeriodeY() + "" + this.localStorage.getPeriodeM();
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

    @OnClick({R.id.btn_lanjutkan})
    public void onClickLanjutkan() {
        if (this.pelanggan.getBillIsRequest().equals("1") || this.pelanggan.getIsUpload().equals("1")) {
            this.btnLanjutkan.setText("Baca Ulang");
            this.btnLanjutkan.setEnabled(true);
            Intent intent = new Intent(this, (Class<?>) CatatStandActivity.class);
            intent.putExtra(CatatStandActivity.ARG_STATUS_READ, getString(R.string.baca_ulang));
            intent.putExtra(CatatStandActivity.ARG_CUST_CODE_ID, this.pelanggan.getCustCode123());
            startActivityForResult(intent, 100);
        }
    }

    @OnClick({R.id.btn_prev})
    public void onClickPrev() {
        Pelanggan prevPelangganRead = this.dataBaseHelper.getPrevPelangganRead(this.localStorage.getPeriodeY(), this.localStorage.getPeriodeM(), this.localStorage.getUserName(), this.pelanggan.getWaktuCatat(), this.blokId);
        if (prevPelangganRead != null) {
            this.pelanggan = prevPelangganRead;
            showInfoPelanggan(this.pelanggan);
        }
    }

    @OnClick({R.id.btn_next})
    public void onClickNext() {
        nextPelanggan(this.pelanggan.getWaktuCatat());
    }

    @OnClick({R.id.cv_stand})
    public void onClickPreviewStand() {
        File file = new File(getDirPath(), getImagePath2("stand"));
        if (file.exists()) {
            Uri uriForFile = FileProvider.getUriForFile(this, "com.aurora.bdg.fileprovider", file);
            Intent intent = new Intent();
            intent.setAction("android.intent.action.VIEW");
            intent.setDataAndType(uriForFile, "image/*");
            intent.addFlags(3);
            startActivity(intent);
        }
    }

    @OnClick({R.id.cv_segel})
    public void onClickPreviewSegel() {
        File file = new File(getDirPath(), getImagePath2("segel"));
        if (file.exists()) {
            Uri uriForFile = FileProvider.getUriForFile(this, "com.aurora.bdg.fileprovider", file);
            Intent intent = new Intent();
            intent.setAction("android.intent.action.VIEW");
            intent.setDataAndType(uriForFile, "image/*");
            intent.addFlags(3);
            startActivity(intent);
        }
    }

    @OnClick({R.id.cv_rumah})
    public void onClickPreviewRumah() {
        File file = new File(getDirPath(), getImagePath2("rumah"));
        if (file.exists()) {
            Uri uriForFile = FileProvider.getUriForFile(this, "com.aurora.bdg.fileprovider", file);
            Intent intent = new Intent();
            intent.setAction("android.intent.action.VIEW");
            intent.setDataAndType(uriForFile, "image/*");
            intent.addFlags(3);
            startActivity(intent);
        }
    }

    @OnClick({R.id.cv_video})
    public void onClickPreview() {
        File file = new File(getVideoPath("video"));
        if (file.exists()) {
            Intent intent = new Intent();
            intent.setAction("android.intent.action.VIEW");
            intent.setDataAndType(Uri.parse("file://" + file.getAbsoluteFile()), "video/*");
            startActivity(intent);
        }
    }

    private void nextPelanggan(String str) {
        Pelanggan nextPelangganRead = this.dataBaseHelper.getNextPelangganRead(this.localStorage.getPeriodeY(), this.localStorage.getPeriodeM(), this.localStorage.getUserName(), str, this.blokId);
        if (nextPelangganRead != null) {
            this.pelanggan = nextPelangganRead;
            showInfoPelanggan(this.pelanggan);
        }
    }

    public void showInfoPelanggan(Pelanggan pelanggan) {
        this.tvCustName.setText(pelanggan.getCustCode123() + " - " + pelanggan.getCustName());
        this.tvAlamat.setText("Alamat: " + pelanggan.getAlamat());
        this.tvTarif.setText("Tarif: " + pelanggan.getTarif());
        if (this.pelanggan.getBillIsRequest().equals("1") || this.pelanggan.getIsUpload().equals("1")) {
            this.btnLanjutkan.setText("Baca Ulang");
            this.btnLanjutkan.setEnabled(true);
        } else {
            this.btnLanjutkan.setText("");
            this.btnLanjutkan.setEnabled(false);
        }
        loadThreeMonth(pelanggan);
        loadCurrentMonth();
        setTakenPhoto();
    }

    private void loadCurrentMonth() {
        DataMeter currentMonth = this.dataBaseHelper.getCurrentMonth(this.custCode);
        if (!currentMonth.getBillUangadm().equals("")) {
            Integer.parseInt(currentMonth.getBillUangadm());
        }
        int i = (!currentMonth.getBillUangair().equals("") ? Integer.parseInt(currentMonth.getBillUangair()) : 0) + 0 + (!currentMonth.getBillUangtax().equals("") ? Integer.parseInt(currentMonth.getBillUangtax()) : 0);
        this.tvPenggunaan.setText(currentMonth.getBillStand2() + "-" + currentMonth.getBillStand1() + "=" + currentMonth.getBillPakai());
        this.tvTagihan.setText(FormatterHelper.addComma(i));
        this.tvWaktuCatat.setText(currentMonth.getWaktuCatat().substring(0, 5));
        this.tvKelainan.setText(currentMonth.getBillAlname());
    }

    private void loadThreeMonth(Pelanggan pelanggan) {
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

    public void setTakenPhoto() {
        File file = new File(getImagePath("stand"));
        if (file.exists()) {
            this.ivStand.setImageBitmap(BitmapFactory.decodeFile(file.getAbsolutePath()));
        }
        File file2 = new File(getImagePath("segel"));
        if (file2.exists()) {
            this.ivSegel.setImageBitmap(BitmapFactory.decodeFile(file2.getAbsolutePath()));
        }
        File file3 = new File(getImagePath("rumah"));
        if (file3.exists()) {
            this.ivRumah.setImageBitmap(BitmapFactory.decodeFile(file3.getAbsolutePath()));
        }
    }

    public String getDirPath() {
        return Environment.getExternalStorageDirectory() + File.separator + this.dirUtil.dirName + File.separator;
    }

    public String getImagePath2(String str) {
        return str + File.separator + (this.period + "_" + str + "_" + this.custCode) + ".jpg";
    }

    public String getImagePath(String str) {
        return Environment.getExternalStorageDirectory() + File.separator + this.dirUtil.dirName + File.separator + str + File.separator + (this.period + "_" + str + "_" + this.pelanggan.getCustCode123()) + ".jpg";
    }

    public String getVideoPath(String str) {
        return Environment.getExternalStorageDirectory() + File.separator + this.dirUtil.dirName + File.separator + str + File.separator + (this.period + "_" + str + "_" + this.custCode) + ".mp4";
    }
}
