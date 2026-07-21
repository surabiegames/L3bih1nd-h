package com.aurora.bdg.api;

import com.google.gson.GsonBuilder;
import java.util.concurrent.TimeUnit;
import okhttp3.OkHttpClient;
import okhttp3.logging.HttpLoggingInterceptor;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

/* JADX INFO: loaded from: classes.dex */
public class ApiFactory {
    private static final int HTTP_CONNECT_TIMEOUT = 360;
    private static final int HTTP_READ_TIMEOUT = 360;

    public static ApiService apiService(String str) {
        return (ApiService) new Retrofit.Builder().baseUrl(str).addConverterFactory(GsonConverterFactory.create(new GsonBuilder().setLenient().create())).client(makeOkHttpClient()).build().create(ApiService.class);
    }

    private static OkHttpClient makeOkHttpClient() {
        HttpLoggingInterceptor httpLoggingInterceptor = new HttpLoggingInterceptor();
        httpLoggingInterceptor.setLevel(HttpLoggingInterceptor.Level.BASIC);
        OkHttpClient.Builder builderNewBuilder = new OkHttpClient().newBuilder();
        builderNewBuilder.networkInterceptors().add(httpLoggingInterceptor);
        builderNewBuilder.connectTimeout(360L, TimeUnit.SECONDS);
        builderNewBuilder.readTimeout(360L, TimeUnit.SECONDS);
        return builderNewBuilder.build();
    }
}
