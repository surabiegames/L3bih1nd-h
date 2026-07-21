package com.aurora.bdg.model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

/* JADX INFO: loaded from: classes.dex */
public class PdamRincian {

    @SerializedName("NOMINAL")
    @Expose
    private String nOMINAL;

    @SerializedName("PERIODE")
    @Expose
    private String pERIODE;

    @SerializedName("PINALTI")
    @Expose
    private String pINALTI;

    public String getPERIODE() {
        return this.pERIODE;
    }

    public void setPERIODE(String str) {
        this.pERIODE = str;
    }

    public String getNOMINAL() {
        return this.nOMINAL;
    }

    public void setNOMINAL(String str) {
        this.nOMINAL = str;
    }

    public String getPINALTI() {
        return this.pINALTI;
    }

    public void setPINALTI(String str) {
        this.pINALTI = str;
    }
}
