package com.aurora.bdg.model;

/* JADX INFO: loaded from: classes.dex */
public class Petugas {
    private Long id;
    private String wrId;
    private String wrIsLogin;
    private String wrName;
    private String wrPass;
    private String wrUserName;

    public Petugas(Long l, String str, String str2, String str3, String str4, String str5) {
        this.id = l;
        this.wrId = str;
        this.wrUserName = str2;
        this.wrName = str3;
        this.wrPass = str4;
        this.wrIsLogin = str5;
    }

    public Petugas() {
    }

    public Long getId() {
        return this.id;
    }

    public void setId(Long l) {
        this.id = l;
    }

    public String getWrId() {
        return this.wrId;
    }

    public void setWrId(String str) {
        this.wrId = str;
    }

    public String getWrUserName() {
        return this.wrUserName;
    }

    public void setWrUserName(String str) {
        this.wrUserName = str;
    }

    public String getWrName() {
        return this.wrName;
    }

    public void setWrName(String str) {
        this.wrName = str;
    }

    public String getWrPass() {
        return this.wrPass;
    }

    public void setWrPass(String str) {
        this.wrPass = str;
    }

    public String getWrIsLogin() {
        return this.wrIsLogin;
    }

    public void setWrIsLogin(String str) {
        this.wrIsLogin = str;
    }
}
