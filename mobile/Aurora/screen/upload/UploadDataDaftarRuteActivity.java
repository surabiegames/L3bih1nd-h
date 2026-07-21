package com.aurora.bdg.screen.upload;

import android.content.Intent;
import android.os.Bundle;
import android.view.MenuItem;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.aurora.bdg.R;
import com.aurora.bdg.model.RuteUpload;
import com.aurora.bdg.util.DataBaseHelper;
import com.aurora.bdg.util.LocalStorage;
import java.util.ArrayList;

/* JADX INFO: loaded from: classes.dex */
public class UploadDataDaftarRuteActivity extends AppCompatActivity {

    @BindView(R.id.cb_select_all)
    CheckBox cbSelectAll;
    DataBaseHelper dataBaseHelper;
    LocalStorage localStorage;

    @BindView(R.id.rv_list_jalan)
    RecyclerView rvListJalan;
    UploadDataDaftarRuteAdapter uploadDataDaftarRuteAdapter;
    ArrayList<RuteUpload> listRuteUpload = new ArrayList<>();
    StringBuilder listSelectedRute = new StringBuilder();
    int numberOfSelectedRute = 0;

    @Override // androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setContentView(R.layout.activity_upload_data_daftar_rute);
        ButterKnife.bind(this);
        getSupportActionBar().setSubtitle("Daftar Rute Upload");
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        this.localStorage = new LocalStorage(this);
        this.dataBaseHelper = DataBaseHelper.getInstance(this);
        this.rvListJalan.setLayoutManager(new LinearLayoutManager(this));
        this.cbSelectAll.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() { // from class: com.aurora.bdg.screen.upload.UploadDataDaftarRuteActivity.1
            @Override // android.widget.CompoundButton.OnCheckedChangeListener
            public void onCheckedChanged(CompoundButton compoundButton, boolean z) {
                if (z) {
                    UploadDataDaftarRuteActivity.this.uploadDataDaftarRuteAdapter.checkedAll();
                } else {
                    UploadDataDaftarRuteActivity.this.uploadDataDaftarRuteAdapter.unSelectAll();
                }
            }
        });
    }

    @Override // androidx.fragment.app.FragmentActivity, android.app.Activity
    protected void onResume() {
        super.onResume();
        showRute();
    }

    @Override // android.app.Activity
    public boolean onOptionsItemSelected(MenuItem menuItem) {
        if (menuItem.getItemId() == 16908332) {
            startActivity(new Intent(this, (Class<?>) UploadMenuActivity.class));
            finish();
            return true;
        }
        return super.onOptionsItemSelected(menuItem);
    }

    @OnClick({R.id.btn_upload_rute})
    public void checkUpload() {
        getSelectedRute();
        if (this.numberOfSelectedRute > 0) {
            Intent intent = new Intent(this, (Class<?>) UploadDataActionActivity.class);
            intent.putExtra(UploadDataActionActivity.ARG_LIST_BLOK, this.listSelectedRute.toString());
            startActivity(intent);
            return;
        }
        Toast.makeText(this, "Silahkan pilih salahsatu rute", 0).show();
    }

    public void getSelectedRute() {
        int i = 0;
        for (RuteUpload ruteUpload : this.listRuteUpload) {
            if (ruteUpload.isSelected()) {
                if (i > 0) {
                    this.listSelectedRute.append(",");
                }
                this.listSelectedRute.append(ruteUpload.getBlockId());
                this.numberOfSelectedRute++;
            }
            i++;
        }
    }

    public void showRute() {
        getRute();
        this.uploadDataDaftarRuteAdapter = new UploadDataDaftarRuteAdapter(this.listRuteUpload);
        this.rvListJalan.setAdapter(this.uploadDataDaftarRuteAdapter);
        this.cbSelectAll.setChecked(true);
        this.uploadDataDaftarRuteAdapter.checkedAll();
    }

    private void getRute() {
        this.listRuteUpload.clear();
        this.listRuteUpload.addAll(this.dataBaseHelper.getListRuteUpload(this.localStorage.getPeriodeY(), this.localStorage.getPeriodeM()));
    }
}
