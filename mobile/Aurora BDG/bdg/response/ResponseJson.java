package com.aurora.bdg.response;

import com.google.gson.GsonBuilder;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

/* JADX INFO: loaded from: classes.dex */
public class ResponseJson {

    @SerializedName("result")
    @Expose
    private Result result;

    public Result getResult() {
        return this.result;
    }

    public void setResult(Result result) {
        this.result = result;
    }

    public String toString() {
        return new GsonBuilder().create().toJson(this, ResponseJson.class);
    }
}
