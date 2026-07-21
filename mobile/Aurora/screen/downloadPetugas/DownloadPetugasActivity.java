package com.aurora.bdg.screen.downloadPetugas;

import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.widget.Toast;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.exifinterface.media.ExifInterface;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.aurora.bdg.App;
import com.aurora.bdg.R;
import com.aurora.bdg.api.ApiFactory;
import com.aurora.bdg.model.DaoSession;
import com.aurora.bdg.model.Petugas;
import com.aurora.bdg.model.PetugasDao;
import com.aurora.bdg.response.ResponseUser;
import com.aurora.bdg.util.LocalStorage;
import java.io.IOException;
import java.util.ArrayList;
import retrofit2.Response;

/* JADX INFO: loaded from: classes.dex */
public class DownloadPetugasActivity extends AppCompatActivity {
    private String TAG = "Download";
    DaoSession daoSession;
    LocalStorage localStorage;
    PetugasDao petugasDao;
    ProgressDialog progressDialog;

    @Override // androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setContentView(R.layout.activity_download_petugas);
        getSupportActionBar().setSubtitle("Download Data");
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        ButterKnife.bind(this);
        this.localStorage = new LocalStorage(this);
        this.daoSession = ((App) getApplication()).getDaoSession();
        this.petugasDao = this.daoSession.getPetugasDao();
        this.progressDialog = new ProgressDialog(this);
        this.progressDialog.setMessage(getString(R.string.progress_dialog_message));
        this.progressDialog.setCancelable(false);
        this.progressDialog.setCanceledOnTouchOutside(false);
    }

    @Override // android.app.Activity
    public boolean onOptionsItemSelected(MenuItem menuItem) {
        if (menuItem.getItemId() == 16908332) {
            finish();
            return true;
        }
        return super.onOptionsItemSelected(menuItem);
    }

    @OnClick({R.id.btn_download_data})
    public void onClickDownloadData() {
        if (this.petugasDao.count() > 0) {
            promtReplaceData();
        } else {
            new DownloadPetugasAsynTask().execute(new Void[0]);
        }
    }

    public void promtReplaceData() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Data sudah tersedia");
        builder.setMessage("Tekan Ya untuk memperbaharui data ");
        builder.setPositiveButton("Ya", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.downloadPetugas.DownloadPetugasActivity.1
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i) {
                DownloadPetugasActivity.this.petugasDao.deleteAll();
                new DownloadPetugasAsynTask().execute(new Void[0]);
            }
        });
        builder.setNegativeButton("Tidak", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.downloadPetugas.DownloadPetugasActivity.2
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i) {
            }
        });
        builder.show();
    }

    private class DownloadPetugasAsynTask extends AsyncTask<Void, Integer, ArrayList<ResponseUser>> {
        ArrayList<ResponseUser> listPetugas;

        private DownloadPetugasAsynTask() {
            this.listPetugas = null;
        }

        @Override // android.os.AsyncTask
        protected void onPreExecute() {
            super.onPreExecute();
            DownloadPetugasActivity.this.progressDialog.show();
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onProgressUpdate(Integer... numArr) {
            super.onProgressUpdate((Object[]) numArr);
            DownloadPetugasActivity.this.progressDialog.setMessage("Download Data: " + numArr[0] + "/" + this.listPetugas.size());
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onPostExecute(ArrayList<ResponseUser> arrayList) {
            super.onPostExecute(arrayList);
            DownloadPetugasActivity.this.progressDialog.dismiss();
            if (arrayList != null) {
                Toast.makeText(DownloadPetugasActivity.this, "Sukses Download " + arrayList.size(), 0).show();
                return;
            }
            Toast.makeText(DownloadPetugasActivity.this, "IP tidak valid", 0).show();
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public ArrayList<ResponseUser> doInBackground(Void... voidArr) {
            try {
                Response<ArrayList<ResponseUser>> responseExecute = ApiFactory.apiService(DownloadPetugasActivity.this.localStorage.getServerData()).getDataUser().execute();
                if (responseExecute.isSuccessful() && responseExecute != null) {
                    this.listPetugas = new ArrayList<>();
                    this.listPetugas.addAll(responseExecute.body());
                    int i = 0;
                    for (ResponseUser responseUser : this.listPetugas) {
                        if (responseUser.getVarId().equals(ExifInterface.GPS_MEASUREMENT_2D)) {
                            Petugas petugas = new Petugas();
                            petugas.setWrId(responseUser.getParam1());
                            petugas.setWrUserName(responseUser.getParam2());
                            petugas.setWrName(responseUser.getParam3());
                            petugas.setWrPass(responseUser.getParam4());
                            DownloadPetugasActivity.this.petugasDao.insert(petugas);
                            int i2 = i + 1;
                            publishProgress(Integer.valueOf(i));
                            i = i2;
                        }
                    }
                }
            } catch (IOException e) {
                e.printStackTrace();
                Log.e(DownloadPetugasActivity.this.TAG, "IOException: " + e.getMessage());
            }
            return this.listPetugas;
        }
    }
}
