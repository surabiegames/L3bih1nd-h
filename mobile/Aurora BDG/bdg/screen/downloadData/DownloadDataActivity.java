package com.aurora.bdg.screen.downloadData;

import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.os.AsyncTask;
import android.os.Bundle;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.aurora.bdg.App;
import com.aurora.bdg.R;
import com.aurora.bdg.api.ApiFactory;
import com.aurora.bdg.model.Alasan;
import com.aurora.bdg.model.AlasanDao;
import com.aurora.bdg.model.DaoSession;
import com.aurora.bdg.model.DataMeter;
import com.aurora.bdg.model.DataMeterDao;
import com.aurora.bdg.model.Tarif;
import com.aurora.bdg.model.TarifDao;
import com.aurora.bdg.model.WaterTarif;
import com.aurora.bdg.model.WaterTarifDao;
import com.aurora.bdg.model.Wmsize;
import com.aurora.bdg.model.WmsizeDao;
import com.aurora.bdg.response.ResponseAlasan;
import com.aurora.bdg.response.ResponseWmsize;
import com.aurora.bdg.util.DirUtil;
import com.aurora.bdg.util.LocalStorage;
import com.aurora.bdg.util.TimeUtil;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import retrofit2.Response;

/* JADX INFO: loaded from: classes.dex */
public class DownloadDataActivity extends AppCompatActivity {
    AlasanDao alasanDao;
    DaoSession daoSession;
    DataMeterDao dataMeterDao;
    DirUtil dirUtil;
    int jumlahPhoto;
    LocalStorage localStorage;
    int numberOfDeletedRumah;
    int numberOfDeletedSegel;
    int numberOfDeletedStand;
    int numberOfDeletedVideo;
    ProgressDialog progressDialog;
    TarifDao tarifDao;

    @BindView(R.id.tv_periode)
    TextView tvPeriode;

    @BindView(R.id.tv_user_name)
    TextView tvUsername;
    WaterTarifDao waterTarifDao;
    WmsizeDao wmsizeDao;
    TimeUtil timeUtil = new TimeUtil();
    ArrayList<String> listBackupPhotoStand = new ArrayList<>();
    ArrayList<String> listBackupPhotoRumah = new ArrayList<>();
    ArrayList<String> listBackupPhotoSegel = new ArrayList<>();
    ArrayList<String> listBackupVideo = new ArrayList<>();

    @Override // androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setContentView(R.layout.activity_download_data);
        this.localStorage = new LocalStorage(this);
        this.dirUtil = new DirUtil();
        this.progressDialog = new ProgressDialog(this);
        this.progressDialog.setMessage(getString(R.string.progress_dialog_message));
        this.progressDialog.setCanceledOnTouchOutside(false);
        this.progressDialog.setCancelable(false);
        this.daoSession = ((App) getApplication()).getDaoSession();
        this.alasanDao = this.daoSession.getAlasanDao();
        this.wmsizeDao = this.daoSession.getWmsizeDao();
        this.waterTarifDao = this.daoSession.getWaterTarifDao();
        this.tarifDao = this.daoSession.getTarifDao();
        this.dataMeterDao = this.daoSession.getDataMeterDao();
        ButterKnife.bind(this);
        populateListBackupFiles();
        this.tvUsername.setText(this.localStorage.getUserName());
        this.tvPeriode.setText(this.localStorage.getPeriodeY() + "" + this.localStorage.getPeriodeM());
    }

    @OnClick({R.id.btn_download_kelainan})
    public void onClickDownloadAlasan() {
        if (this.alasanDao.count() > 0) {
            AlertDialog.Builder builder = new AlertDialog.Builder(this);
            builder.setTitle("Data sudah tersedia");
            builder.setMessage("Tekan Ya untuk memperbaharui data ");
            builder.setPositiveButton("Ya", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.downloadData.DownloadDataActivity.1
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialogInterface, int i) {
                    DownloadDataActivity.this.alasanDao.deleteAll();
                    new DownloadAlasanAsynTask().execute(new Void[0]);
                }
            });
            builder.setNegativeButton("Tidak", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.downloadData.DownloadDataActivity.2
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialogInterface, int i) {
                }
            });
            builder.show();
            return;
        }
        new DownloadAlasanAsynTask().execute(new Void[0]);
    }

    @OnClick({R.id.btn_download_data})
    public void onClickDownloadData() {
        if (isDataAvailable()) {
            promtReplaceData();
        } else {
            downloadData();
        }
    }

    public void promtReplaceData() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Data sudah tersedia");
        builder.setMessage("Tekan Ya untuk memperbaharui data ");
        builder.setPositiveButton("Ya", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.downloadData.DownloadDataActivity.3
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i) {
                DownloadDataActivity.this.downloadData();
            }
        });
        builder.setNegativeButton("Tidak", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.downloadData.DownloadDataActivity.4
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i) {
            }
        });
        builder.show();
    }

    public void downloadData() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Password");
        builder.setMessage("Silahkan masukan password petugas");
        final EditText editText = new EditText(this);
        editText.setInputType(129);
        builder.setView(editText);
        builder.setPositiveButton("Download", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.downloadData.DownloadDataActivity.5
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i) {
                if (editText.getText().toString().equals(DownloadDataActivity.this.localStorage.getPassword())) {
                    DownloadDataActivity.this.deleteAllData();
                    new DownloadWmsizeAsynTask().execute(new Void[0]);
                }
            }
        });
        builder.setNegativeButton("Batal", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.downloadData.DownloadDataActivity.6
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i) {
                dialogInterface.dismiss();
            }
        });
        builder.show();
    }

    public boolean isDataAvailable() {
        return this.wmsizeDao.count() > 0 || this.waterTarifDao.count() > 0 || this.tarifDao.count() > 0 || this.dataMeterDao.count() > 0;
    }

    public void deleteAllData() {
        this.wmsizeDao.deleteAll();
        this.waterTarifDao.deleteAll();
        this.tarifDao.deleteAll();
        this.dataMeterDao.deleteAll();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void promtSuccesDownload(int i) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Sukses Download: " + i);
        builder.setPositiveButton("OK", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.downloadData.DownloadDataActivity.7
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i2) {
            }
        });
        builder.show();
    }

    private void promtSuccesDelete() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Sukses Menghapus data: ");
        builder.setPositiveButton("OK", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.downloadData.DownloadDataActivity.8
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i) {
            }
        });
        builder.show();
    }

    private void populateListBackupFiles() {
        populateBackupPhotoStand();
        populateBackupPhotoSegel();
        populateBackupPhotoHome();
    }

    private void populateBackupPhotoStand() {
        File[] fileArrListFiles = new File(this.dirUtil.getDir("backup_stand")).listFiles();
        if (fileArrListFiles != null) {
            for (File file : fileArrListFiles) {
                this.listBackupPhotoStand.add(this.dirUtil.getDir("backup_stand") + file.getName());
                this.jumlahPhoto = this.jumlahPhoto + 1;
            }
        }
    }

    private void populateBackupPhotoSegel() {
        File[] fileArrListFiles = new File(this.dirUtil.getDir("backup_segel")).listFiles();
        if (fileArrListFiles != null) {
            for (File file : fileArrListFiles) {
                this.listBackupPhotoSegel.add(this.dirUtil.getDir("backup_segel") + file.getName());
                this.jumlahPhoto = this.jumlahPhoto + 1;
            }
        }
    }

    private void populateBackupPhotoHome() {
        File[] fileArrListFiles = new File(this.dirUtil.getDir("backup_rumah")).listFiles();
        if (fileArrListFiles != null) {
            for (File file : fileArrListFiles) {
                this.listBackupPhotoRumah.add(this.dirUtil.getDir("backup_rumah") + file.getName());
                this.jumlahPhoto = this.jumlahPhoto + 1;
            }
        }
    }

    private class DeleteFolderBackUp extends AsyncTask<Void, Integer, Integer> {
        private DeleteFolderBackUp() {
        }

        @Override // android.os.AsyncTask
        protected void onPreExecute() {
            super.onPreExecute();
            DownloadDataActivity.this.progressDialog.show();
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onPostExecute(Integer num) {
            super.onPostExecute(num);
            DownloadDataActivity.this.progressDialog.dismiss();
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public Integer doInBackground(Void... voidArr) {
            Integer numValueOf = 0;
            Iterator<String> it = DownloadDataActivity.this.listBackupPhotoStand.iterator();
            while (it.hasNext()) {
                File file = new File(it.next());
                if (file.exists()) {
                    file.delete();
                    numValueOf = Integer.valueOf(numValueOf.intValue() + 1);
                } else {
                    DownloadDataActivity.this.dirUtil.generateNoteOnSD(file.getAbsolutePath() + " NotFound");
                }
            }
            Iterator<String> it2 = DownloadDataActivity.this.listBackupPhotoSegel.iterator();
            while (it2.hasNext()) {
                File file2 = new File(it2.next());
                if (file2.exists()) {
                    file2.delete();
                    numValueOf = Integer.valueOf(numValueOf.intValue() + 1);
                } else {
                    DownloadDataActivity.this.dirUtil.generateNoteOnSD(file2.getAbsolutePath() + " NotFound");
                }
            }
            Iterator<String> it3 = DownloadDataActivity.this.listBackupPhotoRumah.iterator();
            while (it3.hasNext()) {
                File file3 = new File(it3.next());
                if (file3.exists()) {
                    file3.delete();
                    numValueOf = Integer.valueOf(numValueOf.intValue() + 1);
                } else {
                    DownloadDataActivity.this.dirUtil.generateNoteOnSD(file3.getAbsolutePath() + " NotFound");
                }
            }
            return numValueOf;
        }
    }

    private class DownloadDataMeterAsynTask extends AsyncTask<Void, Integer, ArrayList<DataMeter>> {
        ArrayList<DataMeter> listDataMeter;

        private DownloadDataMeterAsynTask() {
            this.listDataMeter = new ArrayList<>();
        }

        @Override // android.os.AsyncTask
        protected void onPreExecute() {
            super.onPreExecute();
            DownloadDataActivity.this.progressDialog.show();
            DownloadDataActivity.this.progressDialog.setTitle("Data Meter");
            DownloadDataActivity.this.progressDialog.setMessage(DownloadDataActivity.this.getString(R.string.progress_dialog_message));
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onPostExecute(ArrayList<DataMeter> arrayList) {
            super.onPostExecute(arrayList);
            DownloadDataActivity.this.progressDialog.dismiss();
            DownloadDataActivity.this.promtSuccesDownload(this.listDataMeter.size());
            new DeleteFolderBackUp().execute(new Void[0]);
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onProgressUpdate(Integer... numArr) {
            super.onProgressUpdate((Object[]) numArr);
            DownloadDataActivity.this.progressDialog.setMessage("Download Data: " + numArr[0] + "/" + this.listDataMeter.size());
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public ArrayList<DataMeter> doInBackground(Void... voidArr) {
            try {
                Response<ArrayList<DataMeter>> responseExecute = ApiFactory.apiService(DownloadDataActivity.this.localStorage.getServerData()).getDataMeter(DownloadDataActivity.this.timeUtil.timeNowYm(), "'" + DownloadDataActivity.this.localStorage.getUserName() + "'").execute();
                if (responseExecute.isSuccessful() && responseExecute.body() != null) {
                    this.listDataMeter.addAll(responseExecute.body());
                    Iterator<DataMeter> it = this.listDataMeter.iterator();
                    int i = 0;
                    while (it.hasNext()) {
                        DownloadDataActivity.this.dataMeterDao.insert(it.next());
                        int i2 = i + 1;
                        publishProgress(Integer.valueOf(i));
                        i = i2;
                    }
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
            return this.listDataMeter;
        }
    }

    private class DownloadTarifAsynTask extends AsyncTask<Void, Integer, ArrayList<Tarif>> {
        ArrayList<Tarif> listTarif;

        private DownloadTarifAsynTask() {
            this.listTarif = new ArrayList<>();
        }

        @Override // android.os.AsyncTask
        protected void onPreExecute() {
            super.onPreExecute();
            DownloadDataActivity.this.progressDialog.show();
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onPostExecute(ArrayList<Tarif> arrayList) {
            super.onPostExecute(arrayList);
            DownloadDataActivity.this.progressDialog.dismiss();
            new DownloadDataMeterAsynTask().execute(new Void[0]);
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onProgressUpdate(Integer... numArr) {
            super.onProgressUpdate((Object[]) numArr);
            DownloadDataActivity.this.progressDialog.setMessage("Download Tarif: " + numArr[0] + "/" + this.listTarif.size());
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public ArrayList<Tarif> doInBackground(Void... voidArr) {
            try {
                Response<ArrayList<Tarif>> responseExecute = ApiFactory.apiService(DownloadDataActivity.this.localStorage.getServerData()).getTarif().execute();
                if (!responseExecute.isSuccessful() || responseExecute.body() == null) {
                    return null;
                }
                this.listTarif.addAll(responseExecute.body());
                Iterator<Tarif> it = this.listTarif.iterator();
                int i = 0;
                while (it.hasNext()) {
                    DownloadDataActivity.this.tarifDao.insert(it.next());
                    int i2 = i + 1;
                    publishProgress(Integer.valueOf(i));
                    i = i2;
                }
                return null;
            } catch (IOException e) {
                e.printStackTrace();
                return null;
            }
        }
    }

    private class DownloadWaterTarif extends AsyncTask<Void, Integer, ArrayList<WaterTarif>> {
        private ArrayList<WaterTarif> listWaterTarif;

        private DownloadWaterTarif() {
            this.listWaterTarif = new ArrayList<>();
        }

        @Override // android.os.AsyncTask
        protected void onPreExecute() {
            super.onPreExecute();
            DownloadDataActivity.this.progressDialog.show();
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onPostExecute(ArrayList<WaterTarif> arrayList) {
            super.onPostExecute(arrayList);
            DownloadDataActivity.this.progressDialog.dismiss();
            new DownloadTarifAsynTask().execute(new Void[0]);
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onProgressUpdate(Integer... numArr) {
            super.onProgressUpdate((Object[]) numArr);
            DownloadDataActivity.this.progressDialog.setMessage("Download Wmsize: " + numArr[0] + "/" + this.listWaterTarif.size());
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public ArrayList<WaterTarif> doInBackground(Void... voidArr) {
            try {
                Response<ArrayList<WaterTarif>> responseExecute = ApiFactory.apiService(DownloadDataActivity.this.localStorage.getServerData()).getWaterTarif().execute();
                if (responseExecute.isSuccessful()) {
                    this.listWaterTarif.addAll(responseExecute.body());
                    if (this.listWaterTarif.size() > 0) {
                        Iterator<WaterTarif> it = this.listWaterTarif.iterator();
                        int i = 0;
                        while (it.hasNext()) {
                            DownloadDataActivity.this.waterTarifDao.insert(it.next());
                            int i2 = i + 1;
                            publishProgress(Integer.valueOf(i));
                            i = i2;
                        }
                    }
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
            return this.listWaterTarif;
        }
    }

    private class DownloadWmsizeAsynTask extends AsyncTask<Void, Integer, ArrayList<ResponseWmsize>> {
        ArrayList<ResponseWmsize> listWmsize;

        private DownloadWmsizeAsynTask() {
            this.listWmsize = new ArrayList<>();
        }

        @Override // android.os.AsyncTask
        protected void onPreExecute() {
            super.onPreExecute();
            DownloadDataActivity.this.progressDialog.show();
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onPostExecute(ArrayList<ResponseWmsize> arrayList) {
            super.onPostExecute(arrayList);
            DownloadDataActivity.this.progressDialog.dismiss();
            new DownloadWaterTarif().execute(new Void[0]);
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onProgressUpdate(Integer... numArr) {
            super.onProgressUpdate((Object[]) numArr);
            DownloadDataActivity.this.progressDialog.setMessage("Download Wmsize: " + numArr[0] + "/" + this.listWmsize.size());
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public ArrayList<ResponseWmsize> doInBackground(Void... voidArr) {
            try {
                Response<ArrayList<ResponseWmsize>> responseExecute = ApiFactory.apiService(DownloadDataActivity.this.localStorage.getServerData()).getWmsize().execute();
                if (!responseExecute.isSuccessful()) {
                    return null;
                }
                this.listWmsize.addAll(responseExecute.body());
                int i = 0;
                for (ResponseWmsize responseWmsize : this.listWmsize) {
                    Wmsize wmsize = new Wmsize();
                    wmsize.setWmzId(responseWmsize.getWmzId());
                    wmsize.setWmzCode(responseWmsize.getWmzCode());
                    wmsize.setBiPemel(responseWmsize.getBiPemel());
                    wmsize.setWmzSize(responseWmsize.getWmzSize());
                    DownloadDataActivity.this.wmsizeDao.insert(wmsize);
                    int i2 = i + 1;
                    publishProgress(Integer.valueOf(i));
                    i = i2;
                }
                return null;
            } catch (IOException e) {
                e.printStackTrace();
                return null;
            }
        }
    }

    private class DownloadAlasanAsynTask extends AsyncTask<Void, Integer, ArrayList<ResponseAlasan>> {
        ArrayList<ResponseAlasan> listAlasan;

        private DownloadAlasanAsynTask() {
            this.listAlasan = new ArrayList<>();
        }

        @Override // android.os.AsyncTask
        protected void onPreExecute() {
            super.onPreExecute();
            DownloadDataActivity.this.progressDialog.show();
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onPostExecute(ArrayList<ResponseAlasan> arrayList) {
            super.onPostExecute(arrayList);
            DownloadDataActivity.this.progressDialog.dismiss();
            if (arrayList.size() > 0) {
                Toast.makeText(DownloadDataActivity.this, "Sukses Download: " + arrayList.size(), 0).show();
                return;
            }
            Toast.makeText(DownloadDataActivity.this, "0 Data", 0).show();
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onProgressUpdate(Integer... numArr) {
            super.onProgressUpdate((Object[]) numArr);
            DownloadDataActivity.this.progressDialog.setMessage("Download Alasan: " + numArr[0] + "/" + this.listAlasan.size());
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public ArrayList<ResponseAlasan> doInBackground(Void... voidArr) {
            try {
                Response<ArrayList<ResponseAlasan>> responseExecute = ApiFactory.apiService(DownloadDataActivity.this.localStorage.getServerData()).getAlasan().execute();
                if (responseExecute.isSuccessful()) {
                    this.listAlasan.addAll(responseExecute.body());
                    if (this.listAlasan.size() > 0) {
                        int i = 0;
                        for (ResponseAlasan responseAlasan : this.listAlasan) {
                            Alasan alasan = new Alasan();
                            alasan.setAlId(responseAlasan.getParam1());
                            alasan.setAlName(responseAlasan.getParam2());
                            if (responseAlasan.getVarId().equals("0")) {
                                DownloadDataActivity.this.alasanDao.insert(alasan);
                                int i2 = i + 1;
                                publishProgress(Integer.valueOf(i));
                                i = i2;
                            }
                        }
                    }
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
            return this.listAlasan;
        }
    }
}
