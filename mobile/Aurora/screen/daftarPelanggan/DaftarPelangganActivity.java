package com.aurora.bdg.screen.daftarPelanggan;

import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.SearchView;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import butterknife.BindView;
import butterknife.ButterKnife;
import com.aurora.bdg.R;
import com.aurora.bdg.model.Rute;
import com.aurora.bdg.screen.daftarReadUnread.DaftarReadUnreadActivity;
import com.aurora.bdg.util.DataBaseHelper;
import com.aurora.bdg.util.LocalStorage;
import java.util.ArrayList;

/* JADX INFO: loaded from: classes.dex */
public class DaftarPelangganActivity extends AppCompatActivity {
    DaftarPelangganAdapter daftarPelangganAdapter;
    DataBaseHelper dataBaseHelper;
    LocalStorage localStorage;

    @BindView(R.id.rv_list_rute)
    RecyclerView rvListRute;
    public String TAG = "DaftarPelanggan";
    ArrayList<Rute> listRute = new ArrayList<>();

    @Override // androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setContentView(R.layout.activity_daftar_pelanggan);
        ButterKnife.bind(this);
        getSupportActionBar().setSubtitle("Daftar Blok");
        this.localStorage = new LocalStorage(this);
        this.dataBaseHelper = DataBaseHelper.getInstance(this);
    }

    @Override // androidx.fragment.app.FragmentActivity, android.app.Activity
    protected void onResume() {
        super.onResume();
        showRute();
    }

    @Override // android.app.Activity
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.daftar_pelanggan_menu, menu);
        MenuItem menuItemFindItem = menu.findItem(R.id.action_search);
        menuItemFindItem.setOnActionExpandListener(new MenuItem.OnActionExpandListener() { // from class: com.aurora.bdg.screen.daftarPelanggan.DaftarPelangganActivity.1
            @Override // android.view.MenuItem.OnActionExpandListener
            public boolean onMenuItemActionCollapse(MenuItem menuItem) {
                return true;
            }

            @Override // android.view.MenuItem.OnActionExpandListener
            public boolean onMenuItemActionExpand(MenuItem menuItem) {
                return true;
            }
        });
        ((SearchView) menuItemFindItem.getActionView()).setOnQueryTextListener(new SearchView.OnQueryTextListener() { // from class: com.aurora.bdg.screen.daftarPelanggan.DaftarPelangganActivity.2
            @Override // androidx.appcompat.widget.SearchView.OnQueryTextListener
            public boolean onQueryTextSubmit(String str) {
                return false;
            }

            @Override // androidx.appcompat.widget.SearchView.OnQueryTextListener
            public boolean onQueryTextChange(String str) {
                DaftarPelangganActivity.this.daftarPelangganAdapter.update(DaftarPelangganActivity.this.filterRute(str));
                return true;
            }
        });
        return super.onCreateOptionsMenu(menu);
    }

    @Override // android.app.Activity
    public boolean onOptionsItemSelected(MenuItem menuItem) {
        int itemId = menuItem.getItemId();
        if (itemId == R.id.action_home) {
            finish();
            return true;
        }
        if (itemId == R.id.action_show_hide) {
            showHideRute();
            return true;
        }
        return super.onOptionsItemSelected(menuItem);
    }

    public void showRute() {
        getRute();
        this.daftarPelangganAdapter = new DaftarPelangganAdapter(this.listRute);
        this.rvListRute.setLayoutManager(new LinearLayoutManager(this));
        this.rvListRute.setAdapter(this.daftarPelangganAdapter);
        this.daftarPelangganAdapter.setOnItemClickListener(new DaftarPelangganAdapter.OnItemClickListener() { // from class: com.aurora.bdg.screen.daftarPelanggan.DaftarPelangganActivity.3
            @Override // com.aurora.bdg.screen.daftarPelanggan.DaftarPelangganAdapter.OnItemClickListener
            public void onItemClick(Rute rute, int i) {
                Intent intent = new Intent(DaftarPelangganActivity.this, (Class<?>) DaftarReadUnreadActivity.class);
                intent.putExtra(DaftarReadUnreadActivity.ARG_BLOK_ID, rute.getRuteId());
                DaftarPelangganActivity.this.startActivity(intent);
            }
        });
    }

    private void getRute() {
        this.listRute.clear();
        this.listRute.addAll(this.dataBaseHelper.getListRute(this.localStorage.getUserName(), this.localStorage.getPeriodeY(), this.localStorage.getPeriodeM()));
    }

    /* JADX INFO: Access modifiers changed from: private */
    public ArrayList<Rute> filterRute(String str) {
        ArrayList<Rute> arrayList = new ArrayList<>();
        String lowerCase = str.toLowerCase();
        for (Rute rute : this.listRute) {
            if (rute.getRuteId().toLowerCase().contains(lowerCase)) {
                arrayList.add(rute);
            }
        }
        return arrayList;
    }

    public void showHideRute() {
        if (this.daftarPelangganAdapter.getItemCount() != this.listRute.size()) {
            this.daftarPelangganAdapter.update(this.listRute);
        } else {
            this.daftarPelangganAdapter.update(hideFinishRute());
        }
    }

    private ArrayList<Rute> hideFinishRute() {
        ArrayList<Rute> arrayList = new ArrayList<>();
        for (Rute rute : this.listRute) {
            if (Integer.valueOf(rute.getRead()).intValue() != Integer.valueOf(rute.getAktif()).intValue()) {
                arrayList.add(rute);
            }
        }
        return arrayList;
    }
}
