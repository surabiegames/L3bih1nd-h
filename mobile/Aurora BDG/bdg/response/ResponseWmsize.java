package com.aurora.bdg.response;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

/* JADX INFO: loaded from: classes.dex */
public class ResponseWmsize {

    @SerializedName("bi_pemel")
    @Expose
    private String biPemel;

    @SerializedName("wmz_code")
    @Expose
    private String wmzCode;

    @SerializedName("wmz_id")
    @Expose
    private String wmzId;

    @SerializedName("wmz_size")
    @Expose
    private String wmzSize;

    public String getWmzId() {
        return this.wmzId;
    }

    public void setWmzId(String str) {
        this.wmzId = str;
    }

    public String getWmzSize() {
        return this.wmzSize;
    }

    public void setWmzSize(String str) {
        this.wmzSize = str;
    }

    public String getWmzCode() {
        return this.wmzCode;
    }

    public void setWmzCode(String str) {
        this.wmzCode = str;
    }

    public String getBiPemel() {
        return this.biPemel;
    }

    public void setBiPemel(String str) {
        this.biPemel = str;
    }
}
