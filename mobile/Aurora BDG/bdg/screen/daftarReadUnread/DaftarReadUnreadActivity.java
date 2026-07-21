package com.aurora.bdg.screen.daftarReadUnread;

import android.content.Intent;
import android.os.Bundle;
import android.view.MenuItem;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentPagerAdapter;
import androidx.viewpager.widget.ViewPager;
import butterknife.BindView;
import butterknife.ButterKnife;
import com.aurora.bdg.R;
import com.aurora.bdg.model.Pelanggan;
import com.aurora.bdg.screen.infoPelangganRead.InfoPelangganReadActivity;
import com.aurora.bdg.screen.infoPelangganUnread.InfoPelangganUnreadActivity;
import com.google.android.material.tabs.TabLayout;
import java.util.ArrayList;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public class DaftarReadUnreadActivity extends AppCompatActivity implements PelangganReadFragment.OnListFragmentReadInteractionListener, PelangganUnreadFragment.OnListFragmentUnReadInteractionListener {
    public static final String ARG_BLOK_ID = "blokId";
    private String blokId;

    @BindView(R.id.tl_tabs)
    TabLayout tabLayout;

    @BindView(R.id.vp_pager)
    ViewPager viewPager;

    @Override // androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setContentView(R.layout.activity_daftar_read_unread);
        ButterKnife.bind(this);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setElevation(0.0f);
        this.blokId = getIntent().getStringExtra(ARG_BLOK_ID);
        setViewPage(getIntent().getIntExtra("opened_tab", 0));
    }

    public void setSubtitle(String str) {
        getSupportActionBar().setSubtitle(str);
    }

    private void setViewPage(int i) {
        setupViewPager(this.viewPager, i);
        this.tabLayout.setupWithViewPager(this.viewPager);
        this.tabLayout.addOnTabSelectedListener(new TabLayout.OnTabSelectedListener() { // from class: com.aurora.bdg.screen.daftarReadUnread.DaftarReadUnreadActivity.1
            @Override // com.google.android.material.tabs.TabLayout.BaseOnTabSelectedListener
            public void onTabReselected(TabLayout.Tab tab) {
            }

            @Override // com.google.android.material.tabs.TabLayout.BaseOnTabSelectedListener
            public void onTabUnselected(TabLayout.Tab tab) {
            }

            @Override // com.google.android.material.tabs.TabLayout.BaseOnTabSelectedListener
            public void onTabSelected(TabLayout.Tab tab) {
                switch (tab.getPosition()) {
                    case 0:
                        DaftarReadUnreadActivity.this.setSubtitle("Belum dibaca");
                        break;
                    case 1:
                        DaftarReadUnreadActivity.this.setSubtitle("Sudah dibaca");
                        break;
                }
            }
        });
    }

    @Override // android.app.Activity
    public boolean onOptionsItemSelected(MenuItem menuItem) {
        if (menuItem.getItemId() == 16908332) {
            finish();
            return true;
        }
        return super.onOptionsItemSelected(menuItem);
    }

    private void setupViewPager(ViewPager viewPager, int i) {
        ViewPagerAdapter viewPagerAdapter = new ViewPagerAdapter(getSupportFragmentManager());
        viewPagerAdapter.addFragment(PelangganUnreadFragment.newInstance(this.blokId), "BELUM DIBACA");
        viewPagerAdapter.addFragment(PelangganReadFragment.newInstance(this.blokId), "SUDAH DIBACA");
        viewPager.setAdapter(viewPagerAdapter);
        viewPager.setCurrentItem(i);
    }

    private class ViewPagerAdapter extends FragmentPagerAdapter {
        private final List<Fragment> mFragmentList;
        private final List<String> mFragmentTitleList;

        public ViewPagerAdapter(FragmentManager fragmentManager) {
            super(fragmentManager);
            this.mFragmentList = new ArrayList();
            this.mFragmentTitleList = new ArrayList();
        }

        @Override // androidx.fragment.app.FragmentPagerAdapter
        public Fragment getItem(int i) {
            return this.mFragmentList.get(i);
        }

        @Override // androidx.viewpager.widget.PagerAdapter
        public int getCount() {
            return this.mFragmentList.size();
        }

        public void addFragment(Fragment fragment, String str) {
            this.mFragmentList.add(fragment);
            this.mFragmentTitleList.add(str);
        }

        @Override // androidx.viewpager.widget.PagerAdapter
        public CharSequence getPageTitle(int i) {
            return this.mFragmentTitleList.get(i);
        }
    }

    @Override // com.aurora.bdg.screen.daftarReadUnread.PelangganUnreadFragment.OnListFragmentUnReadInteractionListener
    public void onListFragmentUnReadInteraction(Pelanggan pelanggan) {
        Intent intent = new Intent(this, (Class<?>) InfoPelangganUnreadActivity.class);
        intent.putExtra("cust-code", pelanggan.getCustCode123());
        intent.putExtra("blok-id", this.blokId);
        startActivity(intent);
    }

    @Override // com.aurora.bdg.screen.daftarReadUnread.PelangganReadFragment.OnListFragmentReadInteractionListener
    public void onListFragmentReadInteraction(Pelanggan pelanggan) {
        Intent intent = new Intent(this, (Class<?>) InfoPelangganReadActivity.class);
        intent.putExtra("cust-code", pelanggan.getCustCode123());
        intent.putExtra("blok-id", this.blokId);
        startActivity(intent);
    }
}
