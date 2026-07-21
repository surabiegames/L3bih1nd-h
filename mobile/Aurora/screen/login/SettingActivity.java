package com.aurora.bdg.screen.login;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.view.MenuItem;
import android.widget.EditText;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.aurora.bdg.R;
import com.aurora.bdg.util.LocalStorage;

/* JADX INFO: loaded from: classes.dex */
public class SettingActivity extends AppCompatActivity {
    public static String KEY_PRIVILAGE = "PRIVILAGE";

    @BindView(R.id.et_ip_data_lokal)
    EditText etIpDataOffline;

    @BindView(R.id.et_ip_data_online)
    EditText etIpDataOnline;

    @BindView(R.id.et_ip_photo_offline)
    EditText etIpPhotoOffline;

    @BindView(R.id.et_ip_photo_online)
    EditText etIpPhotoOnline;
    String ipDataOffline;
    String ipDataOnline;
    String ipPhotoOffline;
    String ipPhotoOnline;
    boolean isEvaluasi;
    LocalStorage localStorage;

    @BindView(R.id.radio_status_data)
    RadioGroup rgGroupData;

    @BindView(R.id.radio_status_photo)
    RadioGroup rgGroupPhoto;
    boolean statusData;

    @BindView(R.id.status_data_offline)
    RadioButton statusDataOffline;

    @BindView(R.id.status_data_online)
    RadioButton statusDataOnline;
    boolean statusPhoto;

    @BindView(R.id.status_photo_offline)
    RadioButton statusPhotoOffline;

    @BindView(R.id.status_photo_online)
    RadioButton statusPhotoOnline;

    @Override // androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setContentView(R.layout.activity_setting);
        if (getIntent() != null) {
            this.isEvaluasi = getIntent().getBooleanExtra(KEY_PRIVILAGE, false);
        }
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setSubtitle("Pengaturan aplikasi");
        ButterKnife.bind(this);
        this.localStorage = new LocalStorage(this);
        initialSetting();
        hiddenEvaluasiField(this.isEvaluasi);
        this.rgGroupData.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() { // from class: com.aurora.bdg.screen.login.SettingActivity.1
            @Override // android.widget.RadioGroup.OnCheckedChangeListener
            public void onCheckedChanged(RadioGroup radioGroup, int i) {
                switch (i) {
                    case R.id.status_data_offline /* 2131296748 */:
                        SettingActivity.this.statusData = false;
                        break;
                    case R.id.status_data_online /* 2131296749 */:
                        SettingActivity.this.statusData = true;
                        break;
                }
            }
        });
        this.rgGroupPhoto.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() { // from class: com.aurora.bdg.screen.login.SettingActivity.2
            @Override // android.widget.RadioGroup.OnCheckedChangeListener
            public void onCheckedChanged(RadioGroup radioGroup, int i) {
                switch (i) {
                    case R.id.status_photo_offline /* 2131296750 */:
                        SettingActivity.this.statusPhoto = false;
                        break;
                    case R.id.status_photo_online /* 2131296751 */:
                        SettingActivity.this.statusPhoto = true;
                        break;
                }
            }
        });
    }

    @Override // android.app.Activity
    public boolean onOptionsItemSelected(MenuItem menuItem) {
        if (menuItem.getItemId() == 16908332) {
            finish();
            return true;
        }
        return super.onOptionsItemSelected(menuItem);
    }

    @OnClick({R.id.btn_submit})
    public void onClickSubmitSetting() {
        this.ipDataOnline = this.etIpDataOnline.getText().toString();
        this.ipDataOffline = this.etIpDataOffline.getText().toString();
        this.ipPhotoOnline = this.etIpPhotoOnline.getText().toString();
        this.ipPhotoOffline = this.etIpPhotoOffline.getText().toString();
        if (this.statusData && isValidFormOnline()) {
            setSettingOnline();
        } else if (isValidFormOffline()) {
            setSettingOffline();
        }
    }

    private void promtSuccesSave(String str) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this, 2131820556);
        builder.setTitle("Sukses menyimpan data " + str);
        builder.setPositiveButton("OK", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.login.SettingActivity.3
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i) {
                SettingActivity.this.finish();
            }
        });
        builder.show();
    }

    public boolean isValidFormOnline() {
        boolean z;
        if (this.ipDataOnline.isEmpty()) {
            this.etIpDataOnline.setError(getString(R.string.error_empty_field));
            z = false;
        } else {
            z = true;
        }
        if (this.ipDataOnline.matches("^(http|https|ftp):\\/\\/.*\\/$")) {
            this.etIpDataOnline.setError("invalid");
            Toast.makeText(this, "URL harus tidak mengandung 'http://' dan di akhiri '/'", 0).show();
            z = false;
        }
        if (this.ipPhotoOnline.isEmpty()) {
            this.etIpPhotoOnline.setError(getString(R.string.error_empty_field));
            z = false;
        }
        if (!this.ipPhotoOnline.matches("^(http|https|ftp):\\/\\/.*\\/$")) {
            return z;
        }
        this.etIpPhotoOffline.setError("invalid");
        Toast.makeText(this, "URL harus tidak mengandung 'http://' dan di akhiri '/'", 0).show();
        return false;
    }

    private boolean isValidFormOffline() {
        boolean z;
        if (this.ipDataOffline.isEmpty()) {
            this.etIpDataOffline.setError(getString(R.string.error_empty_field));
            z = false;
        } else {
            z = true;
        }
        if (this.ipDataOffline.matches("^(http|https|ftp):\\/\\/.*\\/$")) {
            this.etIpDataOffline.setError("invalid");
            Toast.makeText(this, "URL harus tidak mengandung 'http://' dan di akhiri '/'", 0).show();
            z = false;
        }
        if (this.ipPhotoOffline.isEmpty()) {
            this.etIpPhotoOffline.setError(getString(R.string.error_empty_field));
            z = false;
        }
        if (!this.ipPhotoOffline.matches("^(http|https|ftp):\\/\\/.*\\/$")) {
            return z;
        }
        this.etIpPhotoOffline.setError("invalid");
        Toast.makeText(this, "URL harus tidak mengandung 'http://' dan di akhiri '/'", 0).show();
        return false;
    }

    public void initialSetting() {
        if (!this.localStorage.getServerDataOnline().isEmpty()) {
            this.etIpDataOnline.setText(this.localStorage.getServerDataOnline().replaceAll("^(http|https|ftp):\\/\\/", "").replaceAll("\\/$", ""));
        }
        if (!this.localStorage.getServerDataOffline().isEmpty()) {
            this.etIpDataOffline.setText(this.localStorage.getServerDataOffline().replaceAll("^(http|https|ftp):\\/\\/", "").replaceAll("\\/$", ""));
        }
        if (!this.localStorage.getServerPhotoOnline().isEmpty()) {
            this.etIpPhotoOnline.setText(this.localStorage.getServerPhotoOnline().replaceAll("^(http|https|ftp):\\/\\/", "").replaceAll("\\/$", ""));
        }
        if (!this.localStorage.getServerPhotoOffline().isEmpty()) {
            this.etIpPhotoOffline.setText(this.localStorage.getServerPhotoOffline().replaceAll("^(http|https|ftp):\\/\\/", "").replaceAll("\\/$", ""));
        }
        if (this.localStorage.isStatusData()) {
            this.statusDataOnline.setChecked(true);
            this.statusDataOffline.setChecked(false);
        } else {
            this.statusDataOffline.setChecked(true);
            this.statusDataOnline.setChecked(false);
        }
        if (this.localStorage.isStatusPhoto()) {
            this.statusPhotoOnline.setChecked(true);
            this.statusPhotoOffline.setChecked(false);
        } else {
            this.statusPhotoOffline.setChecked(true);
            this.statusPhotoOnline.setChecked(false);
        }
    }

    public void setSettingOnline() {
        this.localStorage.setServerDataOnline(this.ipDataOnline);
        this.localStorage.setServerPhotoOnline(this.ipPhotoOnline);
        this.localStorage.setStatusData(this.statusData);
        this.localStorage.setStatusPhoto(this.statusPhoto);
        promtSuccesSave("ONLINE");
    }

    public void setSettingOffline() {
        this.localStorage.setServerDataOffline(this.ipDataOffline);
        this.localStorage.setServerPhotoOffline(this.ipPhotoOffline);
        this.localStorage.setStatusData(this.statusData);
        this.localStorage.setStatusPhoto(this.statusPhoto);
        promtSuccesSave("LOKAL");
    }

    public void hiddenEvaluasiField(boolean z) {
        if (z) {
            return;
        }
        this.etIpDataOnline.setFocusable(false);
        this.etIpDataOffline.setFocusable(false);
        this.etIpPhotoOnline.setFocusable(false);
        this.etIpPhotoOffline.setFocusable(false);
    }
}
