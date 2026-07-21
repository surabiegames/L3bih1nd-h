package com.aurora.bdg.api;

import com.aurora.bdg.model.DataMeter;
import com.aurora.bdg.model.Tarif;
import com.aurora.bdg.model.WaterTarif;
import com.aurora.bdg.response.ResponseAlasan;
import com.aurora.bdg.response.ResponsePdam;
import com.aurora.bdg.response.ResponseUploadData;
import com.aurora.bdg.response.ResponseUploadFile;
import com.aurora.bdg.response.ResponseUser;
import com.aurora.bdg.response.ResponseWmsize;
import com.aurora.bdg.util.LocalStorage;
import java.util.ArrayList;
import java.util.Map;
import okhttp3.MultipartBody;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.http.Field;
import retrofit2.http.FormUrlEncoded;
import retrofit2.http.GET;
import retrofit2.http.Multipart;
import retrofit2.http.POST;
import retrofit2.http.Part;
import retrofit2.http.PartMap;
import retrofit2.http.Query;

/* JADX INFO: loaded from: classes.dex */
public interface ApiService {
    @GET("aurora_api/data_alasan.php")
    Call<ArrayList<ResponseAlasan>> getAlasan();

    @GET("aurora_api/dev/download_datameter.php")
    Call<ArrayList<DataMeter>> getDataMeter(@Query(LocalStorage.PERIODE) String str, @Query("writer_id") String str2);

    @GET("aurora_api/data_user.php")
    Call<ArrayList<ResponseUser>> getDataUser();

    @GET("aurora_api/dev/download_tarif.php")
    Call<ArrayList<Tarif>> getTarif();

    @GET("aurora_api/dev/download_watertarif.php")
    Call<ArrayList<WaterTarif>> getWaterTarif();

    @GET("aurora_api/dev/download_wmsize.php")
    Call<ArrayList<ResponseWmsize>> getWmsize();

    @FormUrlEncoded
    @POST("?")
    Call<ResponsePdam> pdam(@Field("api_key") String str, @Field("data") String str2, @Field("id") String str3);

    @FormUrlEncoded
    @POST("aurora_api/sync/dev_store_data.php")
    Call<ArrayList<ResponseUploadData>> postDataMeter(@Field("usersJSON") String str);

    @POST("aurora_api/upload_home.php")
    @Multipart
    Call<ResponseUploadFile> postHomeFile(@Part("tahun") RequestBody requestBody, @Part("bulan") RequestBody requestBody2, @Part MultipartBody.Part part);

    @POST("aurora_api/upload_segel.php")
    @Multipart
    Call<ResponseUploadFile> postSegelFile(@Part("tahun") RequestBody requestBody, @Part("bulan") RequestBody requestBody2, @Part MultipartBody.Part part);

    @POST("aurora_api/upload_stand.php")
    @Multipart
    Call<ResponseUploadFile> postStandFile(@Part("tahun") RequestBody requestBody, @Part("bulan") RequestBody requestBody2, @Part MultipartBody.Part part);

    @POST("aurora_api/upload_video.php")
    @Multipart
    Call<ResponseUploadFile> postVideoFile(@Part("tahun") RequestBody requestBody, @Part("bulan") RequestBody requestBody2, @PartMap Map<String, RequestBody> map);
}
