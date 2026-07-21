package com.aurora.bdg.screen.daftarPencarian;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.Spinner;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.view.ViewCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.aurora.bdg.R;
import com.aurora.bdg.model.Pelanggan;
import com.aurora.bdg.screen.infoPelangganRead.InfoPelangganReadActivity;
import com.aurora.bdg.screen.infoPelangganUnread.InfoPelangganUnreadActivity;
import com.aurora.bdg.util.DataBaseHelper;
import com.aurora.bdg.util.LocalStorage;
import java.util.ArrayList;

/* JADX INFO: loaded from: classes.dex */
public class DaftarPencarianActivity extends AppCompatActivity {
    DaftarPencarianAdapter daftarPelangganAdapter;
    DataBaseHelper dataBaseHelper;
    int jenis;

    @BindView(R.id.rv_list_pelanggan)
    RecyclerView listData;
    ArrayList<Pelanggan> listRute = new ArrayList<>();
    LocalStorage localStorage;

    @BindView(R.id.spinner_filter)
    Spinner spnFilter;

    @BindView(R.id.tv_periode)
    TextView tvPeriode;

    @BindView(R.id.tv_user_name)
    TextView tvUsername;

    @BindView(R.id.txt_keyword)
    TextView txtKeyword;

    @Override // androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setContentView(R.layout.activity_daftar_pencarian);
        ButterKnife.bind(this);
        getSupportActionBar().setSubtitle("Daftar Pencarian");
        this.localStorage = new LocalStorage(this);
        this.dataBaseHelper = DataBaseHelper.getInstance(this);
        this.tvUsername.setText(this.localStorage.getUserName());
        this.tvPeriode.setText(this.localStorage.getPeriodeY() + "" + this.localStorage.getPeriodeM());
        this.spnFilter.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() { // from class: com.aurora.bdg.screen.daftarPencarian.DaftarPencarianActivity.1
            @Override // android.widget.AdapterView.OnItemSelectedListener
            public void onNothingSelected(AdapterView<?> adapterView) {
            }

            @Override // android.widget.AdapterView.OnItemSelectedListener
            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long j) {
                ((TextView) adapterView.getChildAt(0)).setTextColor(ViewCompat.MEASURED_STATE_MASK);
                ((TextView) adapterView.getChildAt(0)).setGravity(17);
                DaftarPencarianActivity.this.jenis = i;
                String string = adapterView.getItemAtPosition(i).toString();
                if (string.equals("Permintaan Catat Ulang")) {
                    DaftarPencarianActivity.this.txtKeyword.setVisibility(8);
                    return;
                }
                DaftarPencarianActivity.this.txtKeyword.setVisibility(0);
                if (string.equals("Berdasarkan : Nama") || string.equals("Berdasarkan : Alamat")) {
                    DaftarPencarianActivity.this.txtKeyword.setInputType(1);
                } else {
                    DaftarPencarianActivity.this.txtKeyword.setInputType(2);
                }
            }
        });
    }

    @OnClick({R.id.btn_cari})
    public void cariPelanggan() {
        showPelanggan();
    }

    public void showPelanggan() {
        getData();
        this.daftarPelangganAdapter = new DaftarPencarianAdapter(this.listRute);
        this.listData.setLayoutManager(new LinearLayoutManager(this));
        this.listData.setAdapter(this.daftarPelangganAdapter);
        this.daftarPelangganAdapter.setOnItemClickListener(new DaftarPencarianAdapter.OnItemClickListener() { // from class: com.aurora.bdg.screen.daftarPencarian.DaftarPencarianActivity.2
            @Override // com.aurora.bdg.screen.daftarPencarian.DaftarPencarianAdapter.OnItemClickListener
            public void onItemClick(Pelanggan pelanggan, int i) {
                if (pelanggan.getBillStand2() == null || pelanggan.getBillStand2().equals("")) {
                    Intent intent = new Intent(DaftarPencarianActivity.this, (Class<?>) InfoPelangganUnreadActivity.class);
                    intent.putExtra("cust-code", pelanggan.getCustCode123());
                    intent.putExtra("blok-id", pelanggan.getBillBlId());
                    DaftarPencarianActivity.this.startActivity(intent);
                    return;
                }
                Intent intent2 = new Intent(DaftarPencarianActivity.this, (Class<?>) InfoPelangganReadActivity.class);
                intent2.putExtra("cust-code", pelanggan.getCustCode123());
                intent2.putExtra("blok-id", pelanggan.getBillBlId());
                DaftarPencarianActivity.this.startActivity(intent2);
            }
        });
    }

    private void getData() {
        this.listRute.clear();
        this.listRute.addAll(this.dataBaseHelper.getListDataCari(this.txtKeyword.getText().toString(), this.jenis));
    }
}
