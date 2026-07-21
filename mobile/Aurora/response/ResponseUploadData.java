package com.aurora.bdg.response;

import androidx.core.app.NotificationCompat;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

/* JADX INFO: loaded from: classes.dex */
public class ResponseUploadData {

    @SerializedName("id")
    @Expose
    private String id;

    @SerializedName(NotificationCompat.CATEGORY_STATUS)
    @Expose
    private String status;

    public String getId() {
        return this.id;
    }

    public void setId(String str) {
        this.id = str;
    }

    public String getStatus() {
        return this.status;
    }

    public void setStatus(String str) {
        this.status = str;
    }
}
