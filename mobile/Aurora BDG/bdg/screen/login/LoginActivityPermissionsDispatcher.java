package com.aurora.bdg.screen.login;

import androidx.core.app.ActivityCompat;
import permissions.dispatcher.PermissionUtils;

/* JADX INFO: loaded from: classes.dex */
final class LoginActivityPermissionsDispatcher {
    private static final String[] PERMISSION_REQUESTPERMISSION = {"android.permission.CAMERA", "android.permission.ACCESS_FINE_LOCATION", "android.permission.ACCESS_COARSE_LOCATION", "android.permission.RECORD_AUDIO", "android.permission.WRITE_EXTERNAL_STORAGE", "android.permission.READ_EXTERNAL_STORAGE"};
    private static final int REQUEST_REQUESTPERMISSION = 0;

    private LoginActivityPermissionsDispatcher() {
    }

    static void requestPermissionWithPermissionCheck(LoginActivity loginActivity) {
        if (PermissionUtils.hasSelfPermissions(loginActivity, PERMISSION_REQUESTPERMISSION)) {
            loginActivity.requestPermission();
        } else {
            ActivityCompat.requestPermissions(loginActivity, PERMISSION_REQUESTPERMISSION, 0);
        }
    }

    static void onRequestPermissionsResult(LoginActivity loginActivity, int i, int[] iArr) {
        if (i == 0 && PermissionUtils.verifyPermissions(iArr)) {
            loginActivity.requestPermission();
        }
    }
}
