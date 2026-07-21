package com.aurora.bdg.screen.login;

import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.widget.EditText;
import android.widget.Toast;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.aurora.bdg.App;
import com.aurora.bdg.R;
import com.aurora.bdg.model.PetugasDao;
import com.aurora.bdg.screen.downloadPetugas.DownloadPetugasActivity;
import com.aurora.bdg.screen.mainmenu.MainMenuActivity;
import com.aurora.bdg.util.LocalStorage;
import com.aurora.bdg.util.TimeUtil;
import permissions.dispatcher.NeedsPermission;
import permissions.dispatcher.RuntimePermissions;

/* JADX INFO: loaded from: classes.dex */
@RuntimePermissions
public class LoginActivity extends AppCompatActivity {

    @BindView(R.id.et_password)
    EditText etPassword;

    @BindView(R.id.et_username)
    EditText etUsername;
    LocalStorage localStorage;
    String password;
    TimeUtil timeUtil = new TimeUtil();
    String username;

    @NeedsPermission({"android.permission.CAMERA", "android.permission.ACCESS_FINE_LOCATION", "android.permission.ACCESS_COARSE_LOCATION", "android.permission.RECORD_AUDIO", "android.permission.WRITE_EXTERNAL_STORAGE", "android.permission.READ_EXTERNAL_STORAGE"})
    public void requestPermission() {
    }

    @Override // androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setContentView(R.layout.activity_login);
        ButterKnife.bind(this);
        this.localStorage = new LocalStorage(this);
        LoginActivityPermissionsDispatcher.requestPermissionWithPermissionCheck(this);
    }

    @OnClick({R.id.btn_login})
    public void onClickLogin() {
        this.username = this.etUsername.getText().toString();
        this.password = this.etPassword.getText().toString();
        if (isValidForm()) {
            if (attemptLogin(this.username, this.password)) {
                this.localStorage.createLoginSession(this.username, this.password);
                Intent intent = new Intent(this, (Class<?>) MainMenuActivity.class);
                intent.setFlags(67108864);
                startActivity(intent);
                finish();
                return;
            }
            Toast.makeText(this, "Login Gagal", 0).show();
        }
    }

    @OnClick({R.id.tv_setting})
    public void onClickSetting() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Key Aps");
        final EditText editText = new EditText(this);
        editText.setInputType(129);
        builder.setView(editText);
        builder.setPositiveButton("OK", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.login.LoginActivity.1
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i) {
                if (editText.getText().toString().equals("aurora") || editText.getText().toString().equals("evaluasi")) {
                    boolean zEquals = editText.getText().toString().equals("evaluasi");
                    Intent intent = new Intent(LoginActivity.this, (Class<?>) SettingActivity.class);
                    intent.putExtra(SettingActivity.KEY_PRIVILAGE, zEquals);
                    LoginActivity.this.startActivity(intent);
                }
            }
        });
        builder.show();
    }

    @OnClick({R.id.tv_download_petugas})
    public void onClickDownloadData() {
        startActivity(new Intent(this, (Class<?>) DownloadPetugasActivity.class));
    }

    public boolean attemptLogin(String str, String str2) {
        return ((App) getApplication()).getDaoSession().getPetugasDao().queryBuilder().where(PetugasDao.Properties.WrUserName.eq(str), PetugasDao.Properties.WrPass.eq(str2)).list().size() == 1;
    }

    public boolean isValidForm() {
        boolean z;
        if (this.etUsername.getText().toString().isEmpty()) {
            this.etUsername.setText(getString(R.string.error_empty_field));
            z = false;
        } else {
            z = true;
        }
        if (!this.etPassword.getText().toString().isEmpty()) {
            return z;
        }
        this.etPassword.setText(getString(R.string.error_empty_field));
        return false;
    }
}
