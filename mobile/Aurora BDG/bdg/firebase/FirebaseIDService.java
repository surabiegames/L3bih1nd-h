package com.aurora.bdg.firebase;

import android.util.Log;
import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.iid.FirebaseInstanceIdService;

/* JADX INFO: loaded from: classes.dex */
public class FirebaseIDService extends FirebaseInstanceIdService {
    private static final String TAG = "FirebaseIDService";

    private void sendRegistrationToServer(String str) {
    }

    @Override // android.app.Service
    public void onCreate() {
        super.onCreate();
    }

    @Override // com.google.firebase.iid.FirebaseInstanceIdService
    public void onTokenRefresh() {
        String token = FirebaseInstanceId.getInstance().getToken();
        Log.d(TAG, "Refreshed token: " + token);
        sendRegistrationToServer(token);
    }
}
