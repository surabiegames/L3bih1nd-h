package com.aurora.bdg.response;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

/* JADX INFO: loaded from: classes.dex */
public class ResponseUploadFile {

    @SerializedName("error")
    @Expose
    private Boolean error;

    @SerializedName("file_name")
    @Expose
    private String filePath;

    @SerializedName("message")
    @Expose
    private String message;

    public String getMessage() {
        return this.message;
    }

    public void setMessage(String str) {
        this.message = str;
    }

    public Boolean getError() {
        return this.error;
    }

    public void setError(Boolean bool) {
        this.error = bool;
    }

    public String getFilePath() {
        return this.filePath;
    }

    public void setFilePath(String str) {
        this.filePath = str;
    }
}
