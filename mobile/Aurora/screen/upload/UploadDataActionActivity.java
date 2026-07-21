package com.aurora.bdg.screen.upload;

import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Button;
import android.widget.TextView;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.aurora.bdg.R;
import com.aurora.bdg.api.ApiFactory;
import com.aurora.bdg.model.DataMeter;
import com.aurora.bdg.model.ProgressRequestBody;
import com.aurora.bdg.response.ResponseUploadData;
import com.aurora.bdg.response.ResponseUploadFile;
import com.aurora.bdg.screen.mainmenu.MainMenuActivity;
import com.aurora.bdg.util.DataBaseHelper;
import com.aurora.bdg.util.DirUtil;
import com.aurora.bdg.util.ImageUtility;
import com.aurora.bdg.util.LocalStorage;
import com.aurora.bdg.util.TimeUtil;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

/* JADX INFO: loaded from: classes.dex */
public class UploadDataActionActivity extends AppCompatActivity implements ProgressRequestBody.UploadCallbacks {
    public static final String ARG_LIST_BLOK = "blok-list";
    private static final String RUMAH = "rumah";
    private static final String SEGEL = "segel";
    private static final String STAND = "stand";
    public static final String TAG = "UploaData";
    private static final String VIDEO = "video";
    ProgressDialog backupDialog;

    @BindView(R.id.btn_upload)
    Button btnUpload;
    DataBaseHelper dataBaseHelper;
    DirUtil dirUtil;
    String listBlok;
    LocalStorage localStorage;
    int numberOfUploadRumah;
    int numberOfUploadSegel;
    int numberOfUploadStand;
    int numberOfUploadVideo;
    String period;
    ProgressDialog progressDialog;
    TimeUtil timeUtil;
    int totalUpload;

    @BindView(R.id.txt_notuploaded)
    TextView tvNotUpload;
    ArrayList<DataMeter> listDataUpload = new ArrayList<>();
    ArrayList<String> listPhotoStand = new ArrayList<>();
    ArrayList<String> listPhotoRumah = new ArrayList<>();
    ArrayList<String> listPhotoSegel = new ArrayList<>();
    ArrayList<String> listVideo = new ArrayList<>();

    @Override // com.aurora.bdg.model.ProgressRequestBody.UploadCallbacks
    public void onError() {
    }

    @Override // com.aurora.bdg.model.ProgressRequestBody.UploadCallbacks
    public void onFinish() {
    }

    @Override // androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setContentView(R.layout.activity_upload_data_action);
        ButterKnife.bind(this);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setSubtitle("UPLOAD");
        this.localStorage = new LocalStorage(this);
        this.dataBaseHelper = DataBaseHelper.getInstance(this);
        this.backupDialog = new ProgressDialog(this);
        this.backupDialog.setMessage(getString(R.string.progress_dialog_message));
        this.backupDialog.setCancelable(false);
        this.backupDialog.setCanceledOnTouchOutside(false);
        this.progressDialog = new ProgressDialog(this);
        this.progressDialog.setCancelable(false);
        this.backupDialog.setMessage(getString(R.string.progress_dialog_message));
        this.progressDialog.setProgressStyle(1);
        this.progressDialog.setCanceledOnTouchOutside(false);
        this.dirUtil = new DirUtil();
        this.timeUtil = new TimeUtil();
        this.period = this.localStorage.getPeriodeY() + "" + this.localStorage.getPeriodeM();
        if (getIntent() != null) {
            this.listBlok = getIntent().getStringExtra(ARG_LIST_BLOK);
        }
        if (this.listBlok.isEmpty()) {
            return;
        }
        populateDataUload();
    }

    @Override // android.app.Activity
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.home_menu, menu);
        return super.onCreateOptionsMenu(menu);
    }

    @Override // android.app.Activity
    public boolean onOptionsItemSelected(MenuItem menuItem) {
        int itemId = menuItem.getItemId();
        if (itemId == 16908332) {
            finish();
            return true;
        }
        if (itemId == R.id.action_home) {
            Intent intent = new Intent(this, (Class<?>) MainMenuActivity.class);
            intent.setFlags(67108864);
            startActivity(intent);
            finish();
        }
        return super.onOptionsItemSelected(menuItem);
    }

    @OnClick({R.id.btn_upload})
    public void onClickButtonUpload() {
        if (this.listDataUpload.size() > 0) {
            uploadData(this.listDataUpload);
            this.btnUpload.setVisibility(8);
        }
    }

    public void populateDataUload() {
        this.listDataUpload = this.dataBaseHelper.getDataMeterUpload(this.localStorage.getPeriodeY(), this.localStorage.getPeriodeM(), this.localStorage.getUserName(), this.listBlok);
        if (this.listDataUpload.size() > 0) {
            populateListFile();
        }
        this.tvNotUpload.setText(String.valueOf(this.listDataUpload.size()));
    }

    public void populateListFile() {
        for (DataMeter dataMeter : this.listDataUpload) {
            this.listPhotoStand.add(getImagePath("stand", dataMeter.getCustCode123()));
            this.listPhotoRumah.add(getImagePath("rumah", dataMeter.getCustCode123()));
            this.listPhotoSegel.add(getImagePath("segel", dataMeter.getCustCode123()));
            if (new File(getVideoPath("video", dataMeter.getCustCode123())).exists()) {
                this.listVideo.add(getVideoPath("video", dataMeter.getCustCode123()));
            }
        }
    }

    public String getImagePath(String str, String str2) {
        return Environment.getExternalStorageDirectory() + File.separator + this.dirUtil.dirName + File.separator + str + File.separator + (this.period + "_" + str + "_" + str2) + ".jpg";
    }

    public String getVideoPath(String str, String str2) {
        return Environment.getExternalStorageDirectory() + File.separator + this.dirUtil.dirName + File.separator + str + File.separator + (this.period + "_" + str + "_" + str2) + ".mp4";
    }

    public String getPath(String str, String str2) {
        return Environment.getExternalStorageDirectory() + File.separator + this.dirUtil.dirName + File.separator + str + File.separator + str2;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public boolean isUploadFotoDone() {
        return (this.numberOfUploadRumah == this.listPhotoRumah.size() && this.numberOfUploadSegel == this.listPhotoSegel.size() && this.numberOfUploadStand == this.listPhotoStand.size()) ? false : true;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void promtUploadStand(int i) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Upload Stand: " + i);
        builder.setCancelable(true);
        builder.setPositiveButton("OK", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.upload.UploadDataActionActivity.1
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i2) {
                UploadDataActionActivity.this.promtUploadRumah(UploadDataActionActivity.this.numberOfUploadRumah);
            }
        });
        builder.show();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void promtUploadVideo(int i) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Upload Video: " + i);
        builder.setCancelable(true);
        builder.setPositiveButton("OK", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.upload.UploadDataActionActivity.2
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i2) {
                UploadDataActionActivity.this.tvNotUpload.setText("0");
                if (UploadDataActionActivity.this.isUploadFotoDone()) {
                    UploadDataActionActivity.this.promtReUpload();
                }
            }
        });
        builder.show();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void promtUploadSegel(int i) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Upload Segel: " + i);
        builder.setCancelable(true);
        builder.setPositiveButton("OK", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.upload.UploadDataActionActivity.3
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i2) {
                UploadDataActionActivity.this.promtUploadVideo(UploadDataActionActivity.this.numberOfUploadVideo);
            }
        });
        builder.show();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void promtUploadRumah(int i) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Upload Rumah: " + i);
        builder.setCancelable(true);
        builder.setPositiveButton("OK", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.upload.UploadDataActionActivity.4
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i2) {
                UploadDataActionActivity.this.promtUploadSegel(UploadDataActionActivity.this.numberOfUploadSegel);
            }
        });
        builder.show();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void promtReUpload() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Upload foto belum selsai");
        builder.setMessage("Silahkan Upload ulang");
        builder.setCancelable(true);
        builder.setPositiveButton("UPLOAD ULANG", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.upload.UploadDataActionActivity.5
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i) {
                Intent intent = new Intent(UploadDataActionActivity.this, (Class<?>) ReUploadPhotoActivity.class);
                intent.setFlags(67108864);
                UploadDataActionActivity.this.startActivity(intent);
                UploadDataActionActivity.this.finish();
            }
        });
        builder.show();
    }

    @Override // com.aurora.bdg.model.ProgressRequestBody.UploadCallbacks
    public void onProgressUpdate(int i) {
        this.progressDialog.setProgress(i);
    }

    public void uploadData(ArrayList<DataMeter> arrayList) {
        this.progressDialog.setMessage("Upload Data");
        this.progressDialog.show();
        ApiFactory.apiService(this.localStorage.getServerData()).postDataMeter(this.dataBaseHelper.getStringListPelanggan(this.localStorage.getPeriodeY(), this.localStorage.getPeriodeM(), this.localStorage.getUserName(), this.listBlok)).enqueue(new Callback<ArrayList<ResponseUploadData>>() { // from class: com.aurora.bdg.screen.upload.UploadDataActionActivity.6
            @Override // retrofit2.Callback
            public void onResponse(Call<ArrayList<ResponseUploadData>> call, Response<ArrayList<ResponseUploadData>> response) {
                if (response.isSuccessful()) {
                    for (ResponseUploadData responseUploadData : response.body()) {
                        UploadDataActionActivity.this.dataBaseHelper.updateSyncStatus(Integer.valueOf(Integer.parseInt(responseUploadData.getId())), Integer.valueOf(Integer.parseInt(responseUploadData.getStatus())));
                        UploadDataActionActivity.this.totalUpload++;
                    }
                    new UploadPhotoStandAsynTask().execute(new Void[0]);
                }
            }

            @Override // retrofit2.Callback
            public void onFailure(Call<ArrayList<ResponseUploadData>> call, Throwable th) {
                UploadDataActionActivity.this.progressDialog.dismiss();
                Log.e(UploadDataActionActivity.TAG, "onFailure: " + th.getMessage());
            }
        });
    }

    private class UploadPhotoStandAsynTask extends AsyncTask<Void, Integer, ArrayList<ResponseUploadFile>> {
        ArrayList<ResponseUploadFile> responseUploadFiles;

        private UploadPhotoStandAsynTask() {
            this.responseUploadFiles = new ArrayList<>();
        }

        @Override // android.os.AsyncTask
        protected void onPreExecute() {
            super.onPreExecute();
            UploadDataActionActivity.this.progressDialog.setMessage("Upload Stand: 0/" + UploadDataActionActivity.this.listPhotoStand.size());
            UploadDataActionActivity.this.progressDialog.show();
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onPostExecute(ArrayList<ResponseUploadFile> arrayList) {
            super.onPostExecute(arrayList);
            UploadDataActionActivity.this.progressDialog.dismiss();
            if (arrayList.size() > 0) {
                UploadDataActionActivity.this.new BackupStandAsynTask(arrayList).execute(new Void[0]);
            } else {
                new UploadPhotoRumahAsynTask().execute(new Void[0]);
            }
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onProgressUpdate(Integer... numArr) {
            super.onProgressUpdate((Object[]) numArr);
            UploadDataActionActivity.this.progressDialog.setMessage("Upload Stand: " + numArr[0] + "/" + UploadDataActionActivity.this.listPhotoStand.size());
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public ArrayList<ResponseUploadFile> doInBackground(Void... voidArr) {
            UploadDataActionActivity.this.numberOfUploadStand = 0;
            for (int i = 0; i < UploadDataActionActivity.this.listPhotoStand.size(); i++) {
                RequestBody requestBodyCreate = RequestBody.create(MediaType.parse("text/plain"), UploadDataActionActivity.this.localStorage.getPeriodeY());
                RequestBody requestBodyCreate2 = RequestBody.create(MediaType.parse("text/plain"), String.valueOf(Integer.parseInt(UploadDataActionActivity.this.localStorage.getPeriodeM())));
                File file = new File(UploadDataActionActivity.this.listPhotoStand.get(i));
                try {
                    Response<ResponseUploadFile> responseExecute = ApiFactory.apiService(UploadDataActionActivity.this.localStorage.getServerData()).postStandFile(requestBodyCreate, requestBodyCreate2, MultipartBody.Part.createFormData("image", file.getName(), new ProgressRequestBody(file, UploadDataActionActivity.this))).execute();
                    if (responseExecute.isSuccessful() && responseExecute.body() != null) {
                        this.responseUploadFiles.add(responseExecute.body());
                        UploadDataActionActivity uploadDataActionActivity = UploadDataActionActivity.this;
                        int i2 = uploadDataActionActivity.numberOfUploadStand;
                        uploadDataActionActivity.numberOfUploadStand = i2 + 1;
                        publishProgress(Integer.valueOf(i2));
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            return this.responseUploadFiles;
        }
    }

    private class BackupStandAsynTask extends AsyncTask<Void, Integer, Integer> {
        ArrayList<ResponseUploadFile> responseUploadFiles;

        public BackupStandAsynTask(ArrayList<ResponseUploadFile> arrayList) {
            this.responseUploadFiles = new ArrayList<>();
            this.responseUploadFiles = arrayList;
        }

        @Override // android.os.AsyncTask
        protected void onPreExecute() {
            super.onPreExecute();
            UploadDataActionActivity.this.progressDialog.dismiss();
            UploadDataActionActivity.this.backupDialog.show();
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onPostExecute(Integer num) {
            super.onPostExecute(num);
            UploadDataActionActivity.this.backupDialog.dismiss();
            new UploadPhotoRumahAsynTask().execute(new Void[0]);
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public Integer doInBackground(Void... voidArr) {
            for (int i = 0; i < this.responseUploadFiles.size(); i++) {
                if (this.responseUploadFiles.get(i) != null) {
                    UploadDataActionActivity.this.dirUtil.generateNoteOnSD(this.responseUploadFiles.get(i).getMessage() + "| " + this.responseUploadFiles.get(i).getFilePath() + "| " + this.responseUploadFiles.get(i).getError() + "| ");
                    if (this.responseUploadFiles.get(i).getError().booleanValue()) {
                        Log.e(UploadDataActionActivity.TAG, "onPostExecute: " + this.responseUploadFiles.get(i).getMessage());
                    } else {
                        ImageUtility.compressPhoto(UploadDataActionActivity.this.getPath("stand", this.responseUploadFiles.get(i).getFilePath()));
                        DirUtil.copyFile(UploadDataActionActivity.this.getPath("stand", this.responseUploadFiles.get(i).getFilePath()), this.responseUploadFiles.get(i).getFilePath(), UploadDataActionActivity.this.dirUtil.getDirBackupStand());
                        new File(UploadDataActionActivity.this.getPath("stand", this.responseUploadFiles.get(i).getFilePath())).delete();
                    }
                }
            }
            return null;
        }
    }

    private class UploadPhotoRumahAsynTask extends AsyncTask<Void, Integer, ArrayList<ResponseUploadFile>> {
        ArrayList<ResponseUploadFile> responseUploadFiles;

        private UploadPhotoRumahAsynTask() {
            this.responseUploadFiles = new ArrayList<>();
        }

        @Override // android.os.AsyncTask
        protected void onPreExecute() {
            super.onPreExecute();
            UploadDataActionActivity.this.progressDialog.setMessage("Upload Rumah: 0/" + UploadDataActionActivity.this.listPhotoRumah.size());
            UploadDataActionActivity.this.progressDialog.show();
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onPostExecute(ArrayList<ResponseUploadFile> arrayList) {
            super.onPostExecute(arrayList);
            if (arrayList.size() > 0) {
                UploadDataActionActivity.this.new BackupHomeAsynTask(arrayList).execute(new Void[0]);
            } else {
                new UploadPhotoSegelAsynTask().execute(new Void[0]);
            }
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onProgressUpdate(Integer... numArr) {
            super.onProgressUpdate((Object[]) numArr);
            UploadDataActionActivity.this.progressDialog.setMessage("Upload Rumah: " + numArr[0] + "/" + UploadDataActionActivity.this.listPhotoRumah.size());
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public ArrayList<ResponseUploadFile> doInBackground(Void... voidArr) {
            UploadDataActionActivity.this.numberOfUploadRumah = 0;
            for (int i = 0; i < UploadDataActionActivity.this.listPhotoRumah.size(); i++) {
                RequestBody requestBodyCreate = RequestBody.create(MediaType.parse("text/plain"), UploadDataActionActivity.this.localStorage.getPeriodeY());
                RequestBody requestBodyCreate2 = RequestBody.create(MediaType.parse("text/plain"), String.valueOf(Integer.parseInt(UploadDataActionActivity.this.localStorage.getPeriodeM())));
                File file = new File(UploadDataActionActivity.this.listPhotoRumah.get(i));
                try {
                    Response<ResponseUploadFile> responseExecute = ApiFactory.apiService(UploadDataActionActivity.this.localStorage.getServerData()).postHomeFile(requestBodyCreate, requestBodyCreate2, MultipartBody.Part.createFormData("image", file.getName(), new ProgressRequestBody(file, UploadDataActionActivity.this))).execute();
                    if (responseExecute.isSuccessful() && responseExecute.body() != null) {
                        this.responseUploadFiles.add(responseExecute.body());
                        UploadDataActionActivity uploadDataActionActivity = UploadDataActionActivity.this;
                        int i2 = uploadDataActionActivity.numberOfUploadRumah;
                        uploadDataActionActivity.numberOfUploadRumah = i2 + 1;
                        publishProgress(Integer.valueOf(i2));
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            return this.responseUploadFiles;
        }
    }

    private class BackupHomeAsynTask extends AsyncTask<Void, Integer, Integer> {
        ArrayList<ResponseUploadFile> responseUploadFiles;

        public BackupHomeAsynTask(ArrayList<ResponseUploadFile> arrayList) {
            this.responseUploadFiles = new ArrayList<>();
            this.responseUploadFiles = arrayList;
        }

        @Override // android.os.AsyncTask
        protected void onPreExecute() {
            super.onPreExecute();
            UploadDataActionActivity.this.progressDialog.dismiss();
            UploadDataActionActivity.this.backupDialog.show();
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onPostExecute(Integer num) {
            super.onPostExecute(num);
            UploadDataActionActivity.this.backupDialog.dismiss();
            new UploadPhotoSegelAsynTask().execute(new Void[0]);
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public Integer doInBackground(Void... voidArr) {
            for (int i = 0; i < this.responseUploadFiles.size(); i++) {
                if (this.responseUploadFiles.get(i) != null) {
                    UploadDataActionActivity.this.dirUtil.generateNoteOnSD(this.responseUploadFiles.get(i).getMessage() + "| " + this.responseUploadFiles.get(i).getFilePath() + "| " + this.responseUploadFiles.get(i).getError() + "| ");
                    if (this.responseUploadFiles.get(i).getError().booleanValue()) {
                        Log.e(UploadDataActionActivity.TAG, "onPostExecute: " + this.responseUploadFiles.get(i).getMessage());
                    } else {
                        ImageUtility.compressPhoto(UploadDataActionActivity.this.getPath("rumah", this.responseUploadFiles.get(i).getFilePath()));
                        DirUtil.copyFile(UploadDataActionActivity.this.getPath("rumah", this.responseUploadFiles.get(i).getFilePath()), this.responseUploadFiles.get(i).getFilePath(), UploadDataActionActivity.this.dirUtil.getDirBackupHome());
                        new File(UploadDataActionActivity.this.getPath("rumah", this.responseUploadFiles.get(i).getFilePath())).delete();
                    }
                }
            }
            return null;
        }
    }

    private class UploadPhotoSegelAsynTask extends AsyncTask<Void, Integer, ArrayList<ResponseUploadFile>> {
        ArrayList<ResponseUploadFile> responseUploadFiles;

        private UploadPhotoSegelAsynTask() {
            this.responseUploadFiles = new ArrayList<>();
        }

        @Override // android.os.AsyncTask
        protected void onPreExecute() {
            super.onPreExecute();
            UploadDataActionActivity.this.progressDialog.setMessage("Upload Segel: 0/" + UploadDataActionActivity.this.listPhotoSegel.size());
            UploadDataActionActivity.this.progressDialog.show();
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onProgressUpdate(Integer... numArr) {
            super.onProgressUpdate((Object[]) numArr);
            UploadDataActionActivity.this.progressDialog.setMessage("Upload Segel: " + numArr[0] + "/" + UploadDataActionActivity.this.listPhotoSegel.size());
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onPostExecute(ArrayList<ResponseUploadFile> arrayList) {
            super.onPostExecute(arrayList);
            if (arrayList.size() > 0) {
                UploadDataActionActivity.this.new BackupSegelAsynTask(arrayList).execute(new Void[0]);
            } else {
                new UploadVideoAsynTask().execute(new Void[0]);
            }
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public ArrayList<ResponseUploadFile> doInBackground(Void... voidArr) {
            UploadDataActionActivity.this.numberOfUploadSegel = 0;
            for (int i = 0; i < UploadDataActionActivity.this.listPhotoSegel.size(); i++) {
                RequestBody requestBodyCreate = RequestBody.create(MediaType.parse("text/plain"), UploadDataActionActivity.this.localStorage.getPeriodeY());
                RequestBody requestBodyCreate2 = RequestBody.create(MediaType.parse("text/plain"), String.valueOf(Integer.parseInt(UploadDataActionActivity.this.localStorage.getPeriodeM())));
                File file = new File(UploadDataActionActivity.this.listPhotoSegel.get(i));
                try {
                    Response<ResponseUploadFile> responseExecute = ApiFactory.apiService(UploadDataActionActivity.this.localStorage.getServerData()).postSegelFile(requestBodyCreate, requestBodyCreate2, MultipartBody.Part.createFormData("image", file.getName(), new ProgressRequestBody(file, UploadDataActionActivity.this))).execute();
                    if (responseExecute.isSuccessful() && responseExecute.body() != null) {
                        this.responseUploadFiles.add(responseExecute.body());
                        UploadDataActionActivity uploadDataActionActivity = UploadDataActionActivity.this;
                        int i2 = uploadDataActionActivity.numberOfUploadSegel;
                        uploadDataActionActivity.numberOfUploadSegel = i2 + 1;
                        publishProgress(Integer.valueOf(i2));
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            return this.responseUploadFiles;
        }
    }

    private class BackupSegelAsynTask extends AsyncTask<Void, Integer, Integer> {
        ArrayList<ResponseUploadFile> responseUploadFiles;

        public BackupSegelAsynTask(ArrayList<ResponseUploadFile> arrayList) {
            this.responseUploadFiles = new ArrayList<>();
            this.responseUploadFiles = arrayList;
        }

        @Override // android.os.AsyncTask
        protected void onPreExecute() {
            super.onPreExecute();
            UploadDataActionActivity.this.progressDialog.dismiss();
            UploadDataActionActivity.this.backupDialog.show();
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onPostExecute(Integer num) {
            super.onPostExecute(num);
            UploadDataActionActivity.this.backupDialog.dismiss();
            new UploadVideoAsynTask().execute(new Void[0]);
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public Integer doInBackground(Void... voidArr) {
            for (int i = 0; i < this.responseUploadFiles.size(); i++) {
                if (this.responseUploadFiles.get(i) != null) {
                    UploadDataActionActivity.this.dirUtil.generateNoteOnSD(this.responseUploadFiles.get(i).getMessage() + "| " + this.responseUploadFiles.get(i).getFilePath() + "| " + this.responseUploadFiles.get(i).getError() + "| ");
                    if (this.responseUploadFiles.get(i).getError().booleanValue()) {
                        Log.e(UploadDataActionActivity.TAG, "onPostExecute: " + this.responseUploadFiles.get(i).getMessage());
                    } else {
                        ImageUtility.compressPhoto(UploadDataActionActivity.this.getPath("segel", this.responseUploadFiles.get(i).getFilePath()));
                        DirUtil.copyFile(UploadDataActionActivity.this.getPath("segel", this.responseUploadFiles.get(i).getFilePath()), this.responseUploadFiles.get(i).getFilePath(), UploadDataActionActivity.this.dirUtil.getDirBackupSegel());
                        new File(UploadDataActionActivity.this.getPath("segel", this.responseUploadFiles.get(i).getFilePath())).delete();
                    }
                }
            }
            return null;
        }
    }

    private class UploadVideoAsynTask extends AsyncTask<Void, Integer, ArrayList<ResponseUploadFile>> {
        ArrayList<ResponseUploadFile> responseUploadFiles;

        private UploadVideoAsynTask() {
            this.responseUploadFiles = new ArrayList<>();
        }

        @Override // android.os.AsyncTask
        protected void onPreExecute() {
            super.onPreExecute();
            UploadDataActionActivity.this.progressDialog.setMessage("Upload Video");
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onPostExecute(ArrayList<ResponseUploadFile> arrayList) {
            super.onPostExecute(arrayList);
            UploadDataActionActivity.this.progressDialog.dismiss();
            if (arrayList.size() <= 0) {
                UploadDataActionActivity.this.promtUploadStand(UploadDataActionActivity.this.numberOfUploadStand);
            } else {
                UploadDataActionActivity.this.new DeleteVideoAsynTask(arrayList).execute(new Void[0]);
            }
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onProgressUpdate(Integer... numArr) {
            super.onProgressUpdate((Object[]) numArr);
            UploadDataActionActivity.this.progressDialog.setMessage("Upload Video: " + numArr[0] + "/" + UploadDataActionActivity.this.listVideo.size());
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public ArrayList<ResponseUploadFile> doInBackground(Void... voidArr) {
            UploadDataActionActivity.this.numberOfUploadVideo = 0;
            for (int i = 0; i < UploadDataActionActivity.this.listVideo.size(); i++) {
                RequestBody requestBodyCreate = RequestBody.create(MediaType.parse("text/plain"), UploadDataActionActivity.this.localStorage.getPeriodeY());
                RequestBody requestBodyCreate2 = RequestBody.create(MediaType.parse("text/plain"), String.valueOf(Integer.parseInt(UploadDataActionActivity.this.localStorage.getPeriodeM())));
                File file = new File(UploadDataActionActivity.this.listVideo.get(i));
                HashMap map = new HashMap();
                map.put("image\"; filename=\"" + file.getName(), RequestBody.create(MediaType.parse("video/*"), file));
                try {
                    Response<ResponseUploadFile> responseExecute = ApiFactory.apiService(UploadDataActionActivity.this.localStorage.getServerData()).postVideoFile(requestBodyCreate, requestBodyCreate2, map).execute();
                    if (responseExecute.isSuccessful() && responseExecute.body() != null) {
                        this.responseUploadFiles.add(responseExecute.body());
                        UploadDataActionActivity uploadDataActionActivity = UploadDataActionActivity.this;
                        int i2 = uploadDataActionActivity.numberOfUploadVideo;
                        uploadDataActionActivity.numberOfUploadVideo = i2 + 1;
                        publishProgress(Integer.valueOf(i2));
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                    UploadDataActionActivity.this.dirUtil.generateNoteOnSD("UploadData" + e.getMessage());
                }
            }
            return this.responseUploadFiles;
        }
    }

    private class DeleteVideoAsynTask extends AsyncTask<Void, Integer, Integer> {
        ArrayList<ResponseUploadFile> responseUploadFiles;

        public DeleteVideoAsynTask(ArrayList<ResponseUploadFile> arrayList) {
            this.responseUploadFiles = new ArrayList<>();
            this.responseUploadFiles = arrayList;
        }

        @Override // android.os.AsyncTask
        protected void onPreExecute() {
            super.onPreExecute();
            UploadDataActionActivity.this.progressDialog.dismiss();
            UploadDataActionActivity.this.backupDialog.show();
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onPostExecute(Integer num) {
            super.onPostExecute(num);
            UploadDataActionActivity.this.backupDialog.dismiss();
            UploadDataActionActivity.this.promtUploadStand(UploadDataActionActivity.this.numberOfUploadStand);
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public Integer doInBackground(Void... voidArr) {
            for (int i = 0; i < this.responseUploadFiles.size(); i++) {
                if (this.responseUploadFiles.get(i) != null) {
                    UploadDataActionActivity.this.dirUtil.generateNoteOnSD(this.responseUploadFiles.get(i).getMessage() + "| " + this.responseUploadFiles.get(i).getFilePath() + "| " + this.responseUploadFiles.get(i).getError() + "| ");
                    if (this.responseUploadFiles.get(i).getError().booleanValue()) {
                        Log.e(UploadDataActionActivity.TAG, "onPostExecute: " + this.responseUploadFiles.get(i).getMessage());
                    } else {
                        new File(UploadDataActionActivity.this.getPath("video", this.responseUploadFiles.get(i).getFilePath())).delete();
                    }
                }
            }
            return null;
        }
    }
}
