package com.aurora.bdg.model;

/* JADX INFO: loaded from: classes.dex */
public class RuteUpload {
    String belumUpload;
    String blockCode;
    String blockId;
    String blockName;
    Integer nomor;
    boolean selected;
    String totalCatat;

    public String getBlockId() {
        return this.blockId;
    }

    public void setBlockId(String str) {
        this.blockId = str;
    }

    public Integer getNomor() {
        return this.nomor;
    }

    public void setNomor(Integer num) {
        this.nomor = num;
    }

    public String getBlockName() {
        return this.blockName;
    }

    public void setBlockName(String str) {
        this.blockName = str;
    }

    public String getBlockCode() {
        return this.blockCode;
    }

    public void setBlockCode(String str) {
        this.blockCode = str;
    }

    public String getTotalCatat() {
        return this.totalCatat;
    }

    public void setTotalCatat(String str) {
        this.totalCatat = str;
    }

    public String getBelumUpload() {
        return this.belumUpload;
    }

    public void setBelumUpload(String str) {
        this.belumUpload = str;
    }

    public boolean isSelected() {
        return this.selected;
    }

    public void setSelected(boolean z) {
        this.selected = z;
    }
}
