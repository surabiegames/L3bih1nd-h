package com.aurora.bdg.model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

/* JADX INFO: loaded from: classes.dex */
public class Tarif {
    private Long id;

    @SerializedName("trf_adm")
    @Expose
    private String trfAdm;

    @SerializedName("trf_code")
    @Expose
    private String trfCode;

    @SerializedName("trf_id")
    @Expose
    private String trfId;

    @SerializedName("trf_init")
    @Expose
    private String trfInit;

    @SerializedName("trf_name")
    @Expose
    private String trfName;

    public Tarif(Long l, String str, String str2, String str3, String str4, String str5) {
        this.id = l;
        this.trfId = str;
        this.trfCode = str2;
        this.trfName = str3;
        this.trfInit = str4;
        this.trfAdm = str5;
    }

    public Tarif() {
    }

    public Long getId() {
        return this.id;
    }

    public void setId(Long l) {
        this.id = l;
    }

    public String getTrfId() {
        return this.trfId;
    }

    public void setTrfId(String str) {
        this.trfId = str;
    }

    public String getTrfCode() {
        return this.trfCode;
    }

    public void setTrfCode(String str) {
        this.trfCode = str;
    }

    public String getTrfName() {
        return this.trfName;
    }

    public void setTrfName(String str) {
        this.trfName = str;
    }

    public String getTrfInit() {
        return this.trfInit;
    }

    public void setTrfInit(String str) {
        this.trfInit = str;
    }

    public String getTrfAdm() {
        return this.trfAdm;
    }

    public void setTrfAdm(String str) {
        this.trfAdm = str;
    }
}
