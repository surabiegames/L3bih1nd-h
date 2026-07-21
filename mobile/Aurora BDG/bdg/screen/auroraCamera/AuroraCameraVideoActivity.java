package com.aurora.bdg.screen.auroraCamera;

import android.content.Intent;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.util.Log;
import android.widget.ImageButton;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.aurora.bdg.R;
import com.aurora.bdg.util.ImageUtility;
import com.otaliastudios.cameraview.Audio;
import com.otaliastudios.cameraview.CameraListener;
import com.otaliastudios.cameraview.CameraView;
import com.otaliastudios.cameraview.Flash;
import com.otaliastudios.cameraview.SessionType;
import java.io.File;
import java.io.IOException;

/* JADX INFO: loaded from: classes.dex */
public class AuroraCameraVideoActivity extends AppCompatActivity {
    public static final String EXTRA_CUST_CODE = "cust-code";
    public static final String EXTRA_NAME = "dirName";
    public static final String EXTRA_PERIOD = "period";
    public static final String EXTRA_REQUEST_CODE = "request-code";
    public static String TAG = "AuroraCamera";

    @BindView(R.id.btn_take_video)
    ImageButton btnTakeVideo;

    @BindView(R.id.camera)
    CameraView camera;
    String custCode;
    String dirName;

    @BindView(R.id.btn_flash)
    ImageButton ibFlash;
    String period;
    String requestCode;

    @BindView(R.id.tv_countDownVideo)
    TextView tvCountDown;
    boolean stateFlash = false;
    boolean isRecord = true;
    int countDown = 11;
    Handler handler = new Handler();
    private Runnable runnableCode = new Runnable() { // from class: com.aurora.bdg.screen.auroraCamera.AuroraCameraVideoActivity.1
        @Override // java.lang.Runnable
        public void run() {
            AuroraCameraVideoActivity.this.tvCountDown.setText("Merekam Video");
            if (AuroraCameraVideoActivity.this.tvCountDown.getVisibility() == 0) {
                AuroraCameraVideoActivity.this.tvCountDown.setVisibility(4);
            } else {
                AuroraCameraVideoActivity.this.tvCountDown.setVisibility(0);
            }
            AuroraCameraVideoActivity.this.handler.postDelayed(this, 1000L);
        }
    };

    @Override // androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setContentView(R.layout.activity_aurora_camera_video);
        ButterKnife.bind(this);
        if (getIntent() != null) {
            this.requestCode = getIntent().getStringExtra("request-code");
            this.custCode = getIntent().getStringExtra("cust-code");
            this.dirName = getIntent().getStringExtra("dirName");
            this.period = getIntent().getStringExtra("period");
        }
        this.camera.setSessionType(SessionType.VIDEO);
        this.camera.setAudio(Audio.ON);
        this.camera.addCameraListener(new CameraListener() { // from class: com.aurora.bdg.screen.auroraCamera.AuroraCameraVideoActivity.2
            @Override // com.otaliastudios.cameraview.CameraListener
            public void onVideoTaken(File file) {
                super.onVideoTaken(file);
                AuroraCameraVideoActivity.this.handler.removeCallbacks(AuroraCameraVideoActivity.this.runnableCode);
                AuroraCameraVideoActivity.this.setResult(-1, new Intent());
                AuroraCameraVideoActivity.this.finish();
                Log.i(AuroraCameraVideoActivity.TAG, "onVideoTaken: " + file.getAbsolutePath());
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

    @OnClick({R.id.btn_take_video})
    public void onTakeVideo() {
        if (this.isRecord) {
            try {
                File fileCreateVideoFile = createVideoFile(this.dirName);
                if (fileCreateVideoFile != null) {
                    this.camera.startCapturingVideo(fileCreateVideoFile, 11000L);
                    this.camera.postDelayed(new Runnable() { // from class: com.aurora.bdg.screen.auroraCamera.AuroraCameraVideoActivity.3
                        @Override // java.lang.Runnable
                        public void run() {
                            AuroraCameraVideoActivity.this.camera.stopCapturingVideo();
                        }
                    }, 11000L);
                    this.handler.post(this.runnableCode);
                    this.btnTakeVideo.setBackground(getDrawable(R.drawable.ic_icon_stop));
                    this.isRecord = false;
                    return;
                }
                return;
            } catch (IOException e) {
                e.printStackTrace();
                return;
            }
        }
        this.camera.stopCapturingVideo();
        this.btnTakeVideo.setBackground(getDrawable(R.drawable.ic_icon_record));
        this.isRecord = true;
    }

    @OnClick({R.id.btn_flash})
    public void toggleFlash() {
        setStateFlash();
    }

    private void setStateFlash() {
        if (this.stateFlash) {
            this.camera.setFlash(Flash.ON);
            this.ibFlash.setBackground(getDrawable(R.drawable.ic_lampu_rotate));
            this.stateFlash = false;
        } else {
            this.camera.setFlash(Flash.OFF);
            this.ibFlash.setBackground(getDrawable(R.drawable.ic_lampu_rotate_disable));
            this.stateFlash = true;
        }
    }

    private File createVideoFile(String str) throws IOException {
        return new File(getVideoPath(str));
    }

    public String getVideoPath(String str) {
        return Environment.getExternalStorageDirectory() + File.separator + ImageUtility.dirUtil.dirName + File.separator + str + File.separator + (this.period + "_" + str + "_" + this.custCode) + ".mp4";
    }
}
