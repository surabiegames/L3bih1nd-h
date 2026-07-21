package com.aurora.bdg.screen.ScanAndGet;

import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;
import android.widget.ImageButton;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.aurora.bdg.R;
import com.aurora.bdg.util.ImageUtility;
import com.aurora.bdg.util.LocalStorage;
import com.aurora.bdg.util.barcodeScanner.ZBarConstants;
import com.otaliastudios.cameraview.CameraListener;
import com.otaliastudios.cameraview.CameraUtils;
import com.otaliastudios.cameraview.CameraView;
import com.otaliastudios.cameraview.Flash;
import com.otaliastudios.cameraview.Frame;
import com.otaliastudios.cameraview.FrameProcessor;
import com.otaliastudios.cameraview.Size;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import net.sourceforge.zbar.Image;
import net.sourceforge.zbar.ImageScanner;
import net.sourceforge.zbar.Symbol;

/* JADX INFO: loaded from: classes.dex */
public class ScanNgetCameraActivity extends AppCompatActivity {
    public static final String EXTRA_REQUEST_CODE = "request-code";
    private static final String STAND = "stand";
    public static String TAG = "AuroraCamera";

    @BindView(R.id.camera)
    CameraView camera;
    String custCode;
    String dirName;

    @BindView(R.id.btn_flash)
    ImageButton ibFlash;
    LocalStorage localStorage;
    private ImageScanner mScanner;
    String period;
    String requestCode;
    boolean stateFlash = false;
    public Symbol symbol;

    @Override // androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setContentView(R.layout.activity_scan_nget_camera);
        ButterKnife.bind(this);
        this.localStorage = new LocalStorage(this);
        if (getIntent() != null) {
            this.requestCode = getIntent().getStringExtra("request-code");
        }
        this.custCode = "";
        this.dirName = "stand";
        this.period = this.localStorage.getPeriodeY() + "" + this.localStorage.getPeriodeM();
        setupScanner();
        this.camera.addFrameProcessor(new FrameProcessor() { // from class: com.aurora.bdg.screen.ScanAndGet.ScanNgetCameraActivity.1
            @Override // com.otaliastudios.cameraview.FrameProcessor
            public void process(@NonNull Frame frame) {
                Size size = frame.getSize();
                byte[] data = frame.getData();
                Image image = new Image(size.getWidth(), size.getHeight(), "Y800");
                image.setData(data);
                if (ScanNgetCameraActivity.this.mScanner.scanImage(image) != 0) {
                    for (final Symbol symbol : ScanNgetCameraActivity.this.mScanner.getResults()) {
                        String data2 = symbol.getData();
                        if (!TextUtils.isEmpty(data2)) {
                            ScanNgetCameraActivity.this.custCode = data2;
                            Log.i(ScanNgetCameraActivity.TAG, "barcode: " + data2);
                            if (!ScanNgetCameraActivity.this.custCode.equals("")) {
                                new Handler(Looper.getMainLooper()).post(new Runnable() { // from class: com.aurora.bdg.screen.ScanAndGet.ScanNgetCameraActivity.1.1
                                    @Override // java.lang.Runnable
                                    public void run() {
                                        ScanNgetCameraActivity.this.symbol = symbol;
                                        ScanNgetCameraActivity.this.camera.capturePicture();
                                    }
                                });
                                return;
                            }
                        }
                    }
                }
            }
        });
        this.camera.addCameraListener(new CameraListener() { // from class: com.aurora.bdg.screen.ScanAndGet.ScanNgetCameraActivity.2
            @Override // com.otaliastudios.cameraview.CameraListener
            public void onPictureTaken(byte[] bArr) {
                ScanNgetCameraActivity.this.onPicture(bArr);
            }
        });
    }

    public void setupScanner() {
        this.mScanner = new ImageScanner();
        this.mScanner.setConfig(0, 256, 3);
        this.mScanner.setConfig(0, 257, 3);
        int[] intArrayExtra = getIntent().getIntArrayExtra(ZBarConstants.SCAN_MODES);
        if (intArrayExtra != null) {
            this.mScanner.setConfig(0, 0, 0);
            for (int i : intArrayExtra) {
                this.mScanner.setConfig(i, 0, 1);
            }
        }
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

    @OnClick({R.id.btn_flash})
    public void toggleFlash() {
        setStateFlash();
    }

    private void setStateFlash() {
        if (this.stateFlash) {
            this.camera.setFlash(Flash.TORCH);
            this.ibFlash.setBackground(getDrawable(R.drawable.ic_flash_on_white_24dp));
            this.stateFlash = false;
        } else {
            this.camera.setFlash(Flash.OFF);
            this.ibFlash.setBackground(getDrawable(R.drawable.ic_flash_off_white_24dp));
            this.stateFlash = true;
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void onPicture(byte[] bArr) {
        Log.i(TAG, "onPicture: ");
        CameraUtils.decodeBitmap(bArr, new CameraUtils.BitmapCallback() { // from class: com.aurora.bdg.screen.ScanAndGet.ScanNgetCameraActivity.3
            @Override // com.otaliastudios.cameraview.CameraUtils.BitmapCallback
            public void onBitmapReady(Bitmap bitmap) {
                ScanNgetCameraActivity.this.saveFile(bitmap);
                Intent intent = new Intent();
                intent.putExtra(ZBarConstants.SCAN_RESULT, ScanNgetCameraActivity.this.symbol.getData());
                intent.putExtra(ZBarConstants.SCAN_RESULT_TYPE, ScanNgetCameraActivity.this.symbol.getType());
                ScanNgetCameraActivity.this.setResult(-1, intent);
                ScanNgetCameraActivity.this.finish();
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
