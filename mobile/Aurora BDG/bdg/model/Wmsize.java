package com.aurora.bdg.model;

/* JADX INFO: loaded from: classes.dex */
public class Wmsize {
    private String biPemel;
    private Long id;
    private String wmzCode;
    private String wmzId;
    private String wmzSize;

    public Wmsize() {
    }

    public Wmsize(Long l, String str, String str2, String str3, String str4) {
        this.id = l;
        this.wmzId = str;
        this.wmzSize = str2;
        this.wmzCode = str3;
        this.biPemel = str4;
    }

    public Long getId() {
        return this.id;
    }

    public void setId(Long l) {
        this.id = l;
    }

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
