package com.aurora.bdg.firebase;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Intent;
import android.os.Build;
import androidx.core.app.NotificationCompat;
import com.aurora.bdg.R;
import com.aurora.bdg.screen.main.MainActivity;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

/* JADX INFO: loaded from: classes.dex */
public class MyFirebaseMessagingService extends FirebaseMessagingService {
    public static String TAG = "Message";

    @Override // android.app.Service
    public void onCreate() {
        super.onCreate();
    }

    @Override // com.google.firebase.messaging.FirebaseMessagingService
    public void onMessageReceived(RemoteMessage remoteMessage) {
        Intent intent = new Intent(this, (Class<?>) MainActivity.class);
        intent.addFlags(67108864);
        NotificationCompat.Builder contentIntent = new NotificationCompat.Builder(this, "AuroraBdg").setSmallIcon(R.drawable.aurora_85).setContentTitle(remoteMessage.getNotification().getTitle()).setContentText(remoteMessage.getNotification().getBody()).setAutoCancel(true).setContentIntent(PendingIntent.getActivity(this, 0, intent, 1073741824));
        NotificationManager notificationManager = (NotificationManager) getSystemService("notification");
        if (Build.VERSION.SDK_INT >= 26) {
            notificationManager.createNotificationChannel(new NotificationChannel("AuroraBdg", "AuroraBdg channel", 3));
        }
        notificationManager.notify(0, contentIntent.build());
    }
}
