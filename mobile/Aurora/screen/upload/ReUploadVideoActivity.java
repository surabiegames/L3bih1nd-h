package com.aurora.bdg.screen.upload;

import android.app.ProgressDialog;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.aurora.bdg.R;
import com.aurora.bdg.api.ApiFactory;
import com.aurora.bdg.response.ResponseUploadFile;
import com.aurora.bdg.util.DataBaseHelper;
import com.aurora.bdg.util.DirUtil;
import com.aurora.bdg.util.LocalStorage;
import com.aurora.bdg.util.TimeUtil;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import okhttp3.MediaType;
import okhttp3.RequestBody;
import retrofit2.Response;

/* JADX INFO: loaded from: classes.dex */
public class ReUploadVideoActivity extends AppCompatActivity {
    private static final String VIDEO = "video";
    DataBaseHelper dataBaseHelper;
    DirUtil dirUtil;
    LocalStorage localStorage;
    private int numberOfUploadVideo;
    private int numberOfVideo;
    ProgressDialog progressDialog;
    TimeUtil timeUtil;

    @BindView(R.id.tv_number_of_video)
    TextView tvReUpload;
    private final String TAG = "ReUploadPhoto";
    ArrayList<String> listVideo = new ArrayList<>();

    static /* synthetic */ int access$108(ReUploadVideoActivity reUploadVideoActivity) {
        int i = reUploadVideoActivity.numberOfUploadVideo;
        reUploadVideoActivity.numberOfUploadVideo = i + 1;
        return i;
    }

    @Override // androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setContentView(R.layout.activity_re_upload_video);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setSubtitle("Upload ulang video");
        this.dirUtil = new DirUtil();
        this.timeUtil = new TimeUtil();
        this.localStorage = new LocalStorage(this);
        this.dataBaseHelper = DataBaseHelper.getInstance(this);
        this.progressDialog = new ProgressDialog(this);
        this.progressDialog.setCancelable(false);
        this.progressDialog.setCanceledOnTouchOutside(false);
        ButterKnife.bind(this);
        populateListUpload();
    }

    @OnClick({R.id.btn_upload_video})
    public void onClickUpload() {
        new UploadVideoAsynTask().execute(new Void[0]);
    }

    public void populateListUpload() {
        this.numberOfVideo = 0;
        populateVideo();
        this.tvReUpload.setText("Jumlah Video: " + String.valueOf(this.numberOfVideo));
    }

    private void populateVideo() {
        File[] fileArrListFiles = new File(this.dirUtil.getDirVideo()).listFiles();
        if (fileArrListFiles != null) {
            for (File file : fileArrListFiles) {
                this.listVideo.add(this.dirUtil.getDirVideo() + file.getName());
                this.numberOfVideo = this.numberOfVideo + 1;
            }
        }
    }

    public String getPath(String str, String str2) {
        return Environment.getExternalStorageDirectory() + File.separator + this.dirUtil.dirName + File.separator + str + File.separator + str2;
    }

    private class UploadVideoAsynTask extends AsyncTask<Void, Integer, ArrayList<ResponseUploadFile>> {
        ArrayList<ResponseUploadFile> responseUploadFiles;

        private UploadVideoAsynTask() {
            this.responseUploadFiles = new ArrayList<>();
        }

        @Override // android.os.AsyncTask
        protected void onPreExecute() {
            super.onPreExecute();
            ReUploadVideoActivity.this.progressDialog.show();
            ReUploadVideoActivity.this.progressDialog.setMessage("Upload Video");
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onPostExecute(ArrayList<ResponseUploadFile> arrayList) {
            super.onPostExecute(arrayList);
            ReUploadVideoActivity.this.progressDialog.dismiss();
            for (int i = 0; i < arrayList.size(); i++) {
                if (arrayList.get(i).getError().booleanValue()) {
                    Log.e("ReUploadPhoto", "onPostExecute: " + arrayList.get(i).getMessage());
                } else {
                    new File(ReUploadVideoActivity.this.getPath("video", arrayList.get(i).getFilePath())).delete();
                }
            }
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onProgressUpdate(Integer... numArr) {
            super.onProgressUpdate((Object[]) numArr);
            ReUploadVideoActivity.this.progressDialog.setMessage("Upload Video: " + numArr[0] + "/" + ReUploadVideoActivity.this.listVideo.size());
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public ArrayList<ResponseUploadFile> doInBackground(Void... voidArr) {
            ReUploadVideoActivity.this.numberOfUploadVideo = 0;
            for (int i = 0; i < ReUploadVideoActivity.this.listVideo.size(); i++) {
                RequestBody requestBodyCreate = RequestBody.create(MediaType.parse("text/plain"), ReUploadVideoActivity.this.localStorage.getPeriodeY());
                RequestBody requestBodyCreate2 = RequestBody.create(MediaType.parse("text/plain"), String.valueOf(Integer.parseInt(ReUploadVideoActivity.this.localStorage.getPeriodeM())));
                File file = new File(ReUploadVideoActivity.this.listVideo.get(i));
                HashMap map = new HashMap();
                map.put("image\"; filename=\"" + file.getName(), RequestBody.create(MediaType.parse("video/*"), file));
                try {
                    Response<ResponseUploadFile> responseExecute = ApiFactory.apiService(ReUploadVideoActivity.this.localStorage.getServerData()).postVideoFile(requestBodyCreate, requestBodyCreate2, map).execute();
                    if (responseExecute.isSuccessful() && responseExecute.body() != null) {
                        this.responseUploadFiles.add(responseExecute.body());
                        publishProgress(Integer.valueOf(ReUploadVideoActivity.access$108(ReUploadVideoActivity.this)));
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                    ReUploadVideoActivity.this.dirUtil.generateNoteOnSD("UploadData" + e.getMessage());
                }
            }
            return this.responseUploadFiles;
        }
    }
}
