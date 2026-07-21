package com.aurora.bdg.screen.upload;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.aurora.bdg.R;
import com.aurora.bdg.util.DataBaseHelper;
import com.aurora.bdg.util.ImageUtility;
import com.aurora.bdg.util.LocalStorage;
import java.io.File;

/* JADX INFO: loaded from: classes.dex */
public class UploadMenuActivity extends AppCompatActivity {
    DataBaseHelper dataBaseHelper;
    private int jumlahPhoto = 0;
    LocalStorage localStorage;

    @BindView(R.id.tv_periode)
    TextView tvPeriode;

    @BindView(R.id.tv_upload_data)
    TextView tvUploadData;

    @BindView(R.id.tv_upload_foto)
    TextView tvUploadFoto;

    @BindView(R.id.tv_user_name)
    TextView tvUsername;

    @BindView(R.id.jdl_txtupload)
    TextView txt_judulupload;

    @Override // androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setContentView(R.layout.activity_upload_menu);
        this.localStorage = new LocalStorage(this);
        this.dataBaseHelper = DataBaseHelper.getInstance(this);
        ButterKnife.bind(this);
        this.tvUsername.setText(this.localStorage.getUserName());
        this.tvPeriode.setText(this.localStorage.getPeriodeY() + "" + this.localStorage.getPeriodeM());
        blink();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void blink() {
        final Handler handler = new Handler();
        new Thread(new Runnable() { // from class: com.aurora.bdg.screen.upload.UploadMenuActivity.1
            @Override // java.lang.Runnable
            public void run() {
                try {
                    Thread.sleep(200);
                } catch (Exception unused) {
                }
                handler.post(new Runnable() { // from class: com.aurora.bdg.screen.upload.UploadMenuActivity.1.1
                    @Override // java.lang.Runnable
                    public void run() {
                        if (UploadMenuActivity.this.txt_judulupload.getVisibility() == 0) {
                            UploadMenuActivity.this.txt_judulupload.setVisibility(4);
                        } else {
                            UploadMenuActivity.this.txt_judulupload.setVisibility(0);
                        }
                        UploadMenuActivity.this.blink();
                    }
                });
            }
        }).start();
    }

    @Override // androidx.fragment.app.FragmentActivity, android.app.Activity
    protected void onResume() {
        super.onResume();
        showInfoUpload();
    }

    @OnClick({R.id.btn_uploaddata})
    public void uploadDataFoto() {
        startActivity(new Intent(this, (Class<?>) UploadDataDaftarRuteActivity.class));
    }

    @OnClick({R.id.btn_reupload_photo})
    public void reuploadPhoto() {
        startActivity(new Intent(this, (Class<?>) ReUploadPhotoActivity.class));
    }

    @OnClick({R.id.btn_reupload_video})
    public void reuploadVideo() {
        startActivity(new Intent(this, (Class<?>) ReUploadVideoActivity.class));
    }

    private void showInfoUpload() {
        int notUpload = this.dataBaseHelper.getNotUpload(this.localStorage.getUserName());
        this.tvUploadData.setText("Upload Data: " + String.valueOf(notUpload));
        populateListPhoto();
    }

    public void populateListPhoto() {
        this.jumlahPhoto = 0;
        populateStand();
        populateRumah();
        populateSegel();
        this.tvUploadFoto.setText("Upload Foto: " + String.valueOf(this.jumlahPhoto));
    }

    private void populateStand() {
        File[] fileArrListFiles = new File(ImageUtility.dirUtil.getDirStand()).listFiles();
        if (fileArrListFiles != null) {
            for (File file : fileArrListFiles) {
                if (!file.getName().equals(".nomedia")) {
                    this.jumlahPhoto++;
                }
            }
        }
    }

    private void populateRumah() {
        File[] fileArrListFiles = new File(ImageUtility.dirUtil.getDirHome()).listFiles();
        if (fileArrListFiles != null) {
            for (File file : fileArrListFiles) {
                if (!file.getName().equals(".nomedia")) {
                    this.jumlahPhoto++;
                }
            }
        }
    }

    private void populateSegel() {
        File[] fileArrListFiles = new File(ImageUtility.dirUtil.getDirSegel()).listFiles();
        if (fileArrListFiles != null) {
            for (File file : fileArrListFiles) {
                if (!file.getName().equals(".nomedia")) {
                    this.jumlahPhoto++;
                }
            }
        }
    }
}
