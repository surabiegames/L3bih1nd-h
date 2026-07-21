package com.aurora.bdg.response;

import com.aurora.bdg.model.Pdam;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

/* JADX INFO: loaded from: classes.dex */
public class ResponsePdam {

    @SerializedName("data")
    @Expose
    private Pdam data;

    @SerializedName("error")
    @Expose
    private String error;

    @SerializedName("message")
    @Expose
    private String message;

    public String getError() {
        return this.error;
    }

    public void setError(String str) {
        this.error = str;
    }

    public String getMessage() {
        return this.message;
    }

    public void setMessage(String str) {
        this.message = str;
    }

    public Pdam getData() {
        return this.data;
    }

    public void setData(Pdam pdam) {
        this.data = pdam;
    }
}
