package com.aurora.bdg.screen.auroraCamera;

import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;
import android.view.KeyEvent;
import android.widget.ImageButton;
import androidx.appcompat.app.AppCompatActivity;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.aurora.bdg.R;
import com.aurora.bdg.util.ImageUtility;
import com.otaliastudios.cameraview.CameraListener;
import com.otaliastudios.cameraview.CameraUtils;
import com.otaliastudios.cameraview.CameraView;
import com.otaliastudios.cameraview.Flash;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

/* JADX INFO: loaded from: classes.dex */
public class AuroraCameraPictureActivity extends AppCompatActivity {
    public static final String EXTRA_CUST_CODE = "cust-code";
    public static final String EXTRA_NAME = "dirName";
    public static final String EXTRA_PERIOD = "period";
    public static final String EXTRA_REQUEST_CODE = "request-code";
    public static String TAG = "AuroraCamera";

    @BindView(R.id.camera)
    CameraView camera;
    String custCode;
    String dirName;

    @BindView(R.id.btn_flash)
    ImageButton ibFlash;
    String period;
    String requestCode;
    boolean stateFlash = false;

    @Override // androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setContentView(R.layout.activity_aurora_camera);
        ButterKnife.bind(this);
        if (getIntent() != null) {
            this.requestCode = getIntent().getStringExtra("request-code");
            this.custCode = getIntent().getStringExtra("cust-code");
            this.dirName = getIntent().getStringExtra("dirName");
            this.period = getIntent().getStringExtra("period");
        }
        this.camera.addCameraListener(new CameraListener() { // from class: com.aurora.bdg.screen.auroraCamera.AuroraCameraPictureActivity.1
            @Override // com.otaliastudios.cameraview.CameraListener
            public void onPictureTaken(byte[] bArr) {
                AuroraCameraPictureActivity.this.onPicture(bArr);
            }
        });
    }

    @Override // androidx.fragment.app.FragmentActivity, android.app.Activity
    protected void onResume() {
        super.onResume();
        this.camera.start();
        setStateFlash();
    }

    @Override // androidx.fragment.app.FragmentActivity, android.app.Activity
    protected void onPause() {
        super.onPause();
        this.camera.stop();
    }

    @OnClick({R.id.btn_take_picture})
    public void onTakePicture() {
        this.camera.capturePicture();
    }

    @OnClick({R.id.btn_flash})
    public void toggleFlash() {
        setStateFlash();
    }

    @Override // androidx.appcompat.app.AppCompatActivity, android.app.Activity, android.view.KeyEvent.Callback
    public boolean onKeyDown(int i, KeyEvent keyEvent) {
        int action = keyEvent.getAction();
        switch (i) {
            case 24:
                if (action == 0) {
                    this.camera.capturePicture();
                }
                break;
            case 25:
                if (action == 0) {
                    this.camera.capturePicture();
                }
                break;
            default:
                this.camera.capturePicture();
                break;
        }
        return true;
    }

    private void setStateFlash() {
        if (this.stateFlash) {
            this.camera.setFlash(Flash.TORCH);
            this.ibFlash.setBackground(getDrawable(R.drawable.ic_lampu_rotate));
            this.stateFlash = false;
        } else {
            this.camera.setFlash(Flash.OFF);
            this.ibFlash.setBackground(getDrawable(R.drawable.ic_lampu_rotate_disable));
            this.stateFlash = true;
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void onPicture(byte[] bArr) {
        Log.i(TAG, "onPicture: ");
        CameraUtils.decodeBitmap(bArr, new CameraUtils.BitmapCallback() { // from class: com.aurora.bdg.screen.auroraCamera.AuroraCameraPictureActivity.2
            @Override // com.otaliastudios.cameraview.CameraUtils.BitmapCallback
            public void onBitmapReady(Bitmap bitmap) {
                AuroraCameraPictureActivity.this.saveFile(bitmap);
                AuroraCameraPictureActivity.this.setResult(-1, new Intent());
                AuroraCameraPictureActivity.this.finish();
            }
        });
    }

    public void saveFile(Bitmap bitmap) {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.JPEG, 80, byteArrayOutputStream);
        File file = new File(getImagePath(this.dirName));
        try {
            file.createNewFile();
        } catch (IOException e) {
            e.printStackTrace();
        }
        FileOutputStream fileOutputStream = null;
        try {
            fileOutputStream = new FileOutputStream(file);
        } catch (FileNotFoundException e2) {
            e2.printStackTrace();
        }
        if (fileOutputStream != null) {
            try {
                fileOutputStream.write(byteArrayOutputStream.toByteArray());
            } catch (IOException e3) {
                e3.printStackTrace();
            }
        }
        try {
            fileOutputStream.close();
        } catch (IOException e4) {
            e4.printStackTrace();
        }
    }

    public String getImagePath(String str) {
        return Environment.getExternalStorageDirectory() + File.separator + ImageUtility.dirUtil.dirName + File.separator + str + File.separator + (this.period + "_" + str + "_" + this.custCode) + ".jpg";
    }
}
