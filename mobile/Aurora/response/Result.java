package com.aurora.bdg.response;

import com.aurora.bdg.util.LocalStorage;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

/* JADX INFO: loaded from: classes.dex */
public class Result {

    @SerializedName("act")
    @Expose
    private String act;

    @SerializedName("group_ref")
    @Expose
    private String groupRef;

    @SerializedName("param_1")
    @Expose
    private String param1;

    @SerializedName("param_2")
    @Expose
    private String param2;

    @SerializedName("param_3")
    @Expose
    private String param3;

    @SerializedName("param_4")
    @Expose
    private String param4;

    @SerializedName(LocalStorage.PASSWORD)
    @Expose
    private String password;

    @SerializedName(LocalStorage.USERNAME)
    @Expose
    private String username;

    public Result(String str, String str2, String str3) {
        this.username = str;
        this.password = str2;
        this.act = str3;
    }

    public String getUsername() {
        return this.username;
    }

    public void setUsername(String str) {
        this.username = str;
    }

    public String getPassword() {
        return this.password;
    }

    public void setPassword(String str) {
        this.password = str;
    }

    public String getAct() {
        return this.act;
    }

    public void setAct(String str) {
        this.act = str;
    }

    public String getGroupRef() {
        return this.groupRef;
    }

    public void setGroupRef(String str) {
        this.groupRef = str;
    }

    public String getParam1() {
        return this.param1;
    }

    public void setParam1(String str) {
        this.param1 = str;
    }

    public String getParam2() {
        return this.param2;
    }

    public void setParam2(String str) {
        this.param2 = str;
    }

    public String getParam3() {
        return this.param3;
    }

    public void setParam3(String str) {
        this.param3 = str;
    }

    public String getParam4() {
        return this.param4;
    }

    public void setParam4(String str) {
        this.param4 = str;
    }
}
