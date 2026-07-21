package com.aurora.bdg.model;

/* JADX INFO: loaded from: classes.dex */
public class Alasan {
    private String alId;
    private String alName;
    private Long id;

    public Alasan(Long l, String str, String str2) {
        this.id = l;
        this.alId = str;
        this.alName = str2;
    }

    public Alasan() {
    }

    public Long getId() {
        return this.id;
    }

    public void setId(Long l) {
        this.id = l;
    }

    public String getAlId() {
        return this.alId;
    }

    public void setAlId(String str) {
        this.alId = str;
    }

    public String getAlName() {
        return this.alName;
    }

    public void setAlName(String str) {
        this.alName = str;
    }

    public String toString() {
        return getAlName();
    }
}
