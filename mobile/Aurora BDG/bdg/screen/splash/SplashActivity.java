package com.aurora.bdg.screen.splash;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import androidx.appcompat.app.AppCompatActivity;
import com.aurora.bdg.R;
import com.aurora.bdg.screen.main.MainActivity;

/* JADX INFO: loaded from: classes.dex */
public class SplashActivity extends AppCompatActivity {
    @Override // androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setContentView(R.layout.activity_splash);
        new Handler().postDelayed(new Runnable() { // from class: com.aurora.bdg.screen.splash.-$$Lambda$SplashActivity$VZ9uHjptvZdKZ9MTxdFaUIXbFsE
            @Override // java.lang.Runnable
            public final void run() {
                SplashActivity.lambda$onCreate$0(this.f$0);
            }
        }, 1000L);
    }

    public static /* synthetic */ void lambda$onCreate$0(SplashActivity splashActivity) {
        splashActivity.startActivity(new Intent(splashActivity, (Class<?>) MainActivity.class));
        splashActivity.finish();
    }
}
