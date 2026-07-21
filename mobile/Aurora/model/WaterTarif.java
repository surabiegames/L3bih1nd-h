package com.aurora.bdg.model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

/* JADX INFO: loaded from: classes.dex */
public class WaterTarif {
    private Long id;

    @SerializedName("trfType_id")
    @Expose
    private String trfTypeId;

    @SerializedName("wt_bottom1")
    @Expose
    private String wtBottom1;

    @SerializedName("wt_bottom2")
    @Expose
    private String wtBottom2;

    @SerializedName("wt_bottom3")
    @Expose
    private String wtBottom3;

    @SerializedName("wt_bottom4")
    @Expose
    private String wtBottom4;

    @SerializedName("wt_cost1")
    @Expose
    private String wtCost1;

    @SerializedName("wt_cost2")
    @Expose
    private String wtCost2;

    @SerializedName("wt_cost3")
    @Expose
    private String wtCost3;

    @SerializedName("wt_cost4")
    @Expose
    private String wtCost4;

    @SerializedName("wt_id")
    @Expose
    private String wtId;

    @SerializedName("wt_top1")
    @Expose
    private String wtTop1;

    @SerializedName("wt_top2")
    @Expose
    private String wtTop2;

    @SerializedName("wt_top3")
    @Expose
    private String wtTop3;

    @SerializedName("wt_top4")
    @Expose
    private String wtTop4;

    public WaterTarif(Long l, String str, String str2, String str3, String str4, String str5, String str6, String str7, String str8, String str9, String str10, String str11, String str12, String str13, String str14) {
        this.id = l;
        this.wtId = str;
        this.trfTypeId = str2;
        this.wtBottom1 = str3;
        this.wtTop1 = str4;
        this.wtCost1 = str5;
        this.wtBottom2 = str6;
        this.wtTop2 = str7;
        this.wtCost2 = str8;
        this.wtBottom3 = str9;
        this.wtTop3 = str10;
        this.wtCost3 = str11;
        this.wtBottom4 = str12;
        this.wtTop4 = str13;
        this.wtCost4 = str14;
    }

    public WaterTarif() {
    }

    public Long getId() {
        return this.id;
    }

    public void setId(Long l) {
        this.id = l;
    }

    public String getWtId() {
        return this.wtId;
    }

    public void setWtId(String str) {
        this.wtId = str;
    }

    public String getTrfTypeId() {
        return this.trfTypeId;
    }

    public void setTrfTypeId(String str) {
        this.trfTypeId = str;
    }

    public String getWtBottom1() {
        return this.wtBottom1;
    }

    public void setWtBottom1(String str) {
        this.wtBottom1 = str;
    }

    public String getWtTop1() {
        return this.wtTop1;
    }

    public void setWtTop1(String str) {
        this.wtTop1 = str;
    }

    public String getWtCost1() {
        return this.wtCost1;
    }

    public void setWtCost1(String str) {
        this.wtCost1 = str;
    }

    public String getWtBottom2() {
        return this.wtBottom2;
    }

    public void setWtBottom2(String str) {
        this.wtBottom2 = str;
    }

    public String getWtTop2() {
        return this.wtTop2;
    }

    public void setWtTop2(String str) {
        this.wtTop2 = str;
    }

    public String getWtCost2() {
        return this.wtCost2;
    }

    public void setWtCost2(String str) {
        this.wtCost2 = str;
    }

    public String getWtBottom3() {
        return this.wtBottom3;
    }

    public void setWtBottom3(String str) {
        this.wtBottom3 = str;
    }

    public String getWtTop3() {
        return this.wtTop3;
    }

    public void setWtTop3(String str) {
        this.wtTop3 = str;
    }

    public String getWtCost3() {
        return this.wtCost3;
    }

    public void setWtCost3(String str) {
        this.wtCost3 = str;
    }

    public String getWtBottom4() {
        return this.wtBottom4;
    }

    public void setWtBottom4(String str) {
        this.wtBottom4 = str;
    }

    public String getWtTop4() {
        return this.wtTop4;
    }

    public void setWtTop4(String str) {
        this.wtTop4 = str;
    }

    public String getWtCost4() {
        return this.wtCost4;
    }

    public void setWtCost4(String str) {
        this.wtCost4 = str;
    }
}
