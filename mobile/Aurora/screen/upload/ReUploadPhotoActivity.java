package com.aurora.bdg.screen.upload;

import android.app.ProgressDialog;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;
import android.view.MenuItem;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.aurora.bdg.R;
import com.aurora.bdg.api.ApiFactory;
import com.aurora.bdg.model.ProgressRequestBody;
import com.aurora.bdg.response.ResponseUploadFile;
import com.aurora.bdg.util.DataBaseHelper;
import com.aurora.bdg.util.DirUtil;
import com.aurora.bdg.util.ImageUtility;
import com.aurora.bdg.util.LocalStorage;
import com.aurora.bdg.util.TimeUtil;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.RequestBody;
import retrofit2.Response;

/* JADX INFO: loaded from: classes.dex */
public class ReUploadPhotoActivity extends AppCompatActivity implements ProgressRequestBody.UploadCallbacks {
    private static final String RUMAH = "rumah";
    private static final String SEGEL = "segel";
    private static final String STAND = "stand";
    ProgressDialog backupDialog;
    DataBaseHelper dataBaseHelper;
    DirUtil dirUtil;
    LocalStorage localStorage;
    int numberOfUploadRumah;
    int numberOfUploadSegel;
    int numberOfUploadStand;
    ProgressDialog progressDialog;
    TimeUtil timeUtil;

    @BindView(R.id.tv_number_of_photo)
    TextView tvReUpload;
    private final String TAG = "ReUploadPhoto";
    ArrayList<String> listPhotoStand = new ArrayList<>();
    ArrayList<String> listPhotoRumah = new ArrayList<>();
    ArrayList<String> listPhotoSegel = new ArrayList<>();
    int jumlahPhoto = 0;

    @Override // com.aurora.bdg.model.ProgressRequestBody.UploadCallbacks
    public void onError() {
    }

    @Override // com.aurora.bdg.model.ProgressRequestBody.UploadCallbacks
    public void onFinish() {
    }

    @Override // androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setContentView(R.layout.activity_re_upload_photo);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setSubtitle("Upload Ulang Photo");
        this.dirUtil = new DirUtil();
        this.timeUtil = new TimeUtil();
        this.localStorage = new LocalStorage(this);
        this.dataBaseHelper = DataBaseHelper.getInstance(this);
        this.progressDialog = new ProgressDialog(this);
        this.progressDialog.setCancelable(false);
        this.progressDialog.setProgressStyle(1);
        this.progressDialog.setCanceledOnTouchOutside(false);
        this.backupDialog = new ProgressDialog(this);
        this.backupDialog.setCancelable(false);
        this.backupDialog.setMessage(getString(R.string.progress_dialog_message));
        this.backupDialog.setCancelable(false);
        ButterKnife.bind(this);
        populateListPhoto();
    }

    @Override // android.app.Activity
    public boolean onOptionsItemSelected(MenuItem menuItem) {
        if (menuItem.getItemId() == 16908332) {
            finish();
        }
        return super.onOptionsItemSelected(menuItem);
    }

    @OnClick({R.id.btn_upload_photo})
    public void onClickUpload() {
        new UploadPhotoStandAsynTask().execute(new Void[0]);
    }

    public void populateListPhoto() {
        this.jumlahPhoto = 0;
        populateStand();
        populateSegel();
        populateRumah();
        this.tvReUpload.setText("Jumlah Photo: " + String.valueOf(this.jumlahPhoto));
    }

    private void populateStand() {
        File[] fileArrListFiles = new File(this.dirUtil.getDirStand()).listFiles();
        if (fileArrListFiles != null) {
            for (int i = 0; i < fileArrListFiles.length; i++) {
                if (!fileArrListFiles[i].getName().equals(".nomedia")) {
                    this.listPhotoStand.add(this.dirUtil.getDirStand() + fileArrListFiles[i].getName());
                    this.jumlahPhoto = this.jumlahPhoto + 1;
                }
            }
        }
    }

    private void populateSegel() {
        File[] fileArrListFiles = new File(this.dirUtil.getDirSegel()).listFiles();
        if (fileArrListFiles != null) {
            for (int i = 0; i < fileArrListFiles.length; i++) {
                if (!fileArrListFiles[i].getName().equals(".nomedia")) {
                    this.listPhotoSegel.add(this.dirUtil.getDirSegel() + fileArrListFiles[i].getName());
                    this.jumlahPhoto = this.jumlahPhoto + 1;
                }
            }
        }
    }

    private void populateRumah() {
        File[] fileArrListFiles = new File(this.dirUtil.getDirHome()).listFiles();
        if (fileArrListFiles != null) {
            for (int i = 0; i < fileArrListFiles.length; i++) {
                if (!fileArrListFiles[i].getName().equals(".nomedia")) {
                    this.listPhotoRumah.add(this.dirUtil.getDirHome() + fileArrListFiles[i].getName());
                    this.jumlahPhoto = this.jumlahPhoto + 1;
                }
            }
        }
    }

    @Override // com.aurora.bdg.model.ProgressRequestBody.UploadCallbacks
    public void onProgressUpdate(int i) {
        this.progressDialog.setProgress(i);
    }

    private class UploadPhotoStandAsynTask extends AsyncTask<Void, Integer, ArrayList<ResponseUploadFile>> {
        ArrayList<ResponseUploadFile> responseUploadFiles;

        private UploadPhotoStandAsynTask() {
            this.responseUploadFiles = new ArrayList<>();
        }

        @Override // android.os.AsyncTask
        protected void onPreExecute() {
            super.onPreExecute();
            ReUploadPhotoActivity.this.progressDialog.setMessage("Upload Stand: 0/" + ReUploadPhotoActivity.this.listPhotoStand.size());
            ReUploadPhotoActivity.this.progressDialog.show();
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onPostExecute(ArrayList<ResponseUploadFile> arrayList) {
            super.onPostExecute(arrayList);
            if (arrayList.size() > 0) {
                ReUploadPhotoActivity.this.new BackupStandAsynTask(arrayList).execute(new Void[0]);
            } else {
                new UploadPhotoRumahAsynTask().execute(new Void[0]);
            }
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onProgressUpdate(Integer... numArr) {
            super.onProgressUpdate((Object[]) numArr);
            ReUploadPhotoActivity.this.progressDialog.setMessage("Upload Stand: " + numArr[0] + "/" + ReUploadPhotoActivity.this.listPhotoStand.size());
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public ArrayList<ResponseUploadFile> doInBackground(Void... voidArr) {
            ReUploadPhotoActivity.this.numberOfUploadStand = 0;
            for (int i = 0; i < ReUploadPhotoActivity.this.listPhotoStand.size(); i++) {
                RequestBody requestBodyCreate = RequestBody.create(MediaType.parse("text/plain"), ReUploadPhotoActivity.this.localStorage.getPeriodeY());
                RequestBody requestBodyCreate2 = RequestBody.create(MediaType.parse("text/plain"), String.valueOf(Integer.parseInt(ReUploadPhotoActivity.this.localStorage.getPeriodeM())));
                File file = new File(ReUploadPhotoActivity.this.listPhotoStand.get(i));
                try {
                    Response<ResponseUploadFile> responseExecute = ApiFactory.apiService(ReUploadPhotoActivity.this.localStorage.getServerData()).postStandFile(requestBodyCreate, requestBodyCreate2, MultipartBody.Part.createFormData("image", file.getName(), new ProgressRequestBody(file, ReUploadPhotoActivity.this))).execute();
                    if (responseExecute.isSuccessful() && responseExecute.body() != null) {
                        this.responseUploadFiles.add(responseExecute.body());
                        ReUploadPhotoActivity reUploadPhotoActivity = ReUploadPhotoActivity.this;
                        int i2 = reUploadPhotoActivity.numberOfUploadStand + 1;
                        reUploadPhotoActivity.numberOfUploadStand = i2;
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
            ReUploadPhotoActivity.this.progressDialog.dismiss();
            ReUploadPhotoActivity.this.backupDialog.show();
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onPostExecute(Integer num) {
            super.onPostExecute(num);
            ReUploadPhotoActivity.this.backupDialog.dismiss();
            new UploadPhotoRumahAsynTask().execute(new Void[0]);
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public Integer doInBackground(Void... voidArr) {
            for (int i = 0; i < this.responseUploadFiles.size(); i++) {
                if (this.responseUploadFiles.get(i) != null) {
                    ReUploadPhotoActivity.this.dirUtil.generateNoteOnSD(this.responseUploadFiles.get(i).getMessage() + "| " + this.responseUploadFiles.get(i).getFilePath() + "| " + this.responseUploadFiles.get(i).getError() + "| ");
                    if (this.responseUploadFiles.get(i).getError().booleanValue()) {
                        Log.e("ReUploadPhoto", "onPostExecute: " + this.responseUploadFiles.get(i).getMessage());
                    } else {
                        ImageUtility.compressPhoto(ReUploadPhotoActivity.this.getPath("stand", this.responseUploadFiles.get(i).getFilePath()));
                        DirUtil.copyFile(ReUploadPhotoActivity.this.getPath("stand", this.responseUploadFiles.get(i).getFilePath()), this.responseUploadFiles.get(i).getFilePath(), ReUploadPhotoActivity.this.dirUtil.getDirBackupStand());
                        new File(ReUploadPhotoActivity.this.getPath("stand", this.responseUploadFiles.get(i).getFilePath())).delete();
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
            ReUploadPhotoActivity.this.progressDialog.show();
            ReUploadPhotoActivity.this.progressDialog.setMessage("Upload Rumah: 0/" + ReUploadPhotoActivity.this.listPhotoRumah.size());
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onPostExecute(ArrayList<ResponseUploadFile> arrayList) {
            super.onPostExecute(arrayList);
            if (arrayList.size() > 0) {
                ReUploadPhotoActivity.this.new BackupHomeAsynTask(arrayList).execute(new Void[0]);
            } else {
                new UploadPhotoSegelAsynTask().execute(new Void[0]);
            }
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onProgressUpdate(Integer... numArr) {
            super.onProgressUpdate((Object[]) numArr);
            ReUploadPhotoActivity.this.progressDialog.setMessage("Upload Rumah: " + numArr[0] + "/" + ReUploadPhotoActivity.this.listPhotoRumah.size());
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public ArrayList<ResponseUploadFile> doInBackground(Void... voidArr) {
            ReUploadPhotoActivity.this.numberOfUploadRumah = 0;
            for (int i = 0; i < ReUploadPhotoActivity.this.listPhotoRumah.size(); i++) {
                RequestBody requestBodyCreate = RequestBody.create(MediaType.parse("text/plain"), ReUploadPhotoActivity.this.localStorage.getPeriodeY());
                RequestBody requestBodyCreate2 = RequestBody.create(MediaType.parse("text/plain"), String.valueOf(Integer.parseInt(ReUploadPhotoActivity.this.localStorage.getPeriodeM())));
                File file = new File(ReUploadPhotoActivity.this.listPhotoRumah.get(i));
                try {
                    Response<ResponseUploadFile> responseExecute = ApiFactory.apiService(ReUploadPhotoActivity.this.localStorage.getServerData()).postHomeFile(requestBodyCreate, requestBodyCreate2, MultipartBody.Part.createFormData("image", file.getName(), new ProgressRequestBody(file, ReUploadPhotoActivity.this))).execute();
                    if (responseExecute.isSuccessful() && responseExecute.body() != null) {
                        this.responseUploadFiles.add(responseExecute.body());
                        ReUploadPhotoActivity reUploadPhotoActivity = ReUploadPhotoActivity.this;
                        int i2 = reUploadPhotoActivity.numberOfUploadRumah + 1;
                        reUploadPhotoActivity.numberOfUploadRumah = i2;
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
            ReUploadPhotoActivity.this.progressDialog.dismiss();
            ReUploadPhotoActivity.this.backupDialog.show();
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onPostExecute(Integer num) {
            super.onPostExecute(num);
            ReUploadPhotoActivity.this.backupDialog.dismiss();
            new UploadPhotoSegelAsynTask().execute(new Void[0]);
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public Integer doInBackground(Void... voidArr) {
            for (int i = 0; i < this.responseUploadFiles.size(); i++) {
                if (this.responseUploadFiles.get(i) != null) {
                    ReUploadPhotoActivity.this.dirUtil.generateNoteOnSD(this.responseUploadFiles.get(i).getMessage() + "| " + this.responseUploadFiles.get(i).getFilePath() + "| " + this.responseUploadFiles.get(i).getError() + "| ");
                    if (this.responseUploadFiles.get(i).getError().booleanValue()) {
                        Log.e("ReUploadPhoto", "onPostExecute: " + this.responseUploadFiles.get(i).getMessage());
                    } else {
                        ImageUtility.compressPhoto(ReUploadPhotoActivity.this.getPath("rumah", this.responseUploadFiles.get(i).getFilePath()));
                        DirUtil.copyFile(ReUploadPhotoActivity.this.getPath("rumah", this.responseUploadFiles.get(i).getFilePath()), this.responseUploadFiles.get(i).getFilePath(), ReUploadPhotoActivity.this.dirUtil.getDirBackupHome());
                        new File(ReUploadPhotoActivity.this.getPath("rumah", this.responseUploadFiles.get(i).getFilePath())).delete();
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
            ReUploadPhotoActivity.this.progressDialog.show();
            ReUploadPhotoActivity.this.progressDialog.setMessage("Upload Segel: 0/" + ReUploadPhotoActivity.this.listPhotoSegel.size());
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onProgressUpdate(Integer... numArr) {
            super.onProgressUpdate((Object[]) numArr);
            ReUploadPhotoActivity.this.progressDialog.setMessage("Upload Segel: " + numArr[0] + "/" + ReUploadPhotoActivity.this.listPhotoSegel.size());
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public ArrayList<ResponseUploadFile> doInBackground(Void... voidArr) {
            ReUploadPhotoActivity reUploadPhotoActivity = ReUploadPhotoActivity.this;
            int i = reUploadPhotoActivity.numberOfUploadSegel;
            reUploadPhotoActivity.numberOfUploadSegel = i + 1;
            publishProgress(Integer.valueOf(i));
            for (int i2 = 0; i2 < ReUploadPhotoActivity.this.listPhotoSegel.size(); i2++) {
                RequestBody requestBodyCreate = RequestBody.create(MediaType.parse("text/plain"), ReUploadPhotoActivity.this.localStorage.getPeriodeY());
                RequestBody requestBodyCreate2 = RequestBody.create(MediaType.parse("text/plain"), String.valueOf(Integer.parseInt(ReUploadPhotoActivity.this.localStorage.getPeriodeM())));
                File file = new File(ReUploadPhotoActivity.this.listPhotoSegel.get(i2));
                try {
                    Response<ResponseUploadFile> responseExecute = ApiFactory.apiService(ReUploadPhotoActivity.this.localStorage.getServerData()).postSegelFile(requestBodyCreate, requestBodyCreate2, MultipartBody.Part.createFormData("image", file.getName(), new ProgressRequestBody(file, ReUploadPhotoActivity.this))).execute();
                    if (responseExecute.isSuccessful() && responseExecute.body() != null) {
                        this.responseUploadFiles.add(responseExecute.body());
                        ReUploadPhotoActivity reUploadPhotoActivity2 = ReUploadPhotoActivity.this;
                        int i3 = reUploadPhotoActivity2.numberOfUploadSegel;
                        reUploadPhotoActivity2.numberOfUploadSegel = i3 + 1;
                        publishProgress(Integer.valueOf(i3));
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            return this.responseUploadFiles;
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onPostExecute(ArrayList<ResponseUploadFile> arrayList) {
            super.onPostExecute(arrayList);
            if (arrayList.size() > 0) {
                ReUploadPhotoActivity.this.new BackupSegelAsynTask(arrayList).execute(new Void[0]);
            }
            ReUploadPhotoActivity.this.progressDialog.dismiss();
            ReUploadPhotoActivity.this.populateListPhoto();
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
            ReUploadPhotoActivity.this.progressDialog.dismiss();
            ReUploadPhotoActivity.this.backupDialog.show();
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onPostExecute(Integer num) {
            super.onPostExecute(num);
            ReUploadPhotoActivity.this.backupDialog.dismiss();
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public Integer doInBackground(Void... voidArr) {
            for (int i = 0; i < this.responseUploadFiles.size(); i++) {
                if (this.responseUploadFiles.get(i) != null) {
                    ReUploadPhotoActivity.this.dirUtil.generateNoteOnSD(this.responseUploadFiles.get(i).getMessage() + "| " + this.responseUploadFiles.get(i).getFilePath() + "| " + this.responseUploadFiles.get(i).getError() + "| ");
                    if (this.responseUploadFiles.get(i).getError().booleanValue()) {
                        Log.e("ReUploadPhoto", "onPostExecute: " + this.responseUploadFiles.get(i).getMessage());
                    } else {
                        ImageUtility.compressPhoto(ReUploadPhotoActivity.this.getPath("segel", this.responseUploadFiles.get(i).getFilePath()));
                        DirUtil.copyFile(ReUploadPhotoActivity.this.getPath("segel", this.responseUploadFiles.get(i).getFilePath()), this.responseUploadFiles.get(i).getFilePath(), ReUploadPhotoActivity.this.dirUtil.getDirBackupSegel());
                        new File(ReUploadPhotoActivity.this.getPath("segel", this.responseUploadFiles.get(i).getFilePath())).delete();
                    }
                }
            }
            return null;
        }
    }

    public String getPath(String str, String str2) {
        return Environment.getExternalStorageDirectory() + File.separator + this.dirUtil.dirName + File.separator + str + File.separator + str2;
    }
}
