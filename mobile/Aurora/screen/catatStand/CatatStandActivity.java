package com.aurora.bdg.screen.catatStand;

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
import com.aurora.bdg.model.DataMeter;
import com.aurora.bdg.screen.infoPelangganUnread.InfoPelangganUnreadActivity;
import com.google.android.material.tabs.TabLayout;
import java.util.ArrayList;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public class CatatStandActivity extends AppCompatActivity implements CatatStandFragment.OnFragmentCatatStandInteractionListener, CatatStandRecordVideoFragment.OnFragmentVideoInteractionListener {
    public static final String ARG_CUST_CODE_ID = "cust-code-id";
    public static final String ARG_RESULT_OCR = "result-ocr";
    public static final String ARG_STATUS_READ = "status-read";
    private String custCode;
    private String resultOcr;
    private String statusRead;

    @BindView(R.id.tl_tabs)
    TabLayout tabLayout;

    @BindView(R.id.vp_pager)
    ViewPager viewPager;

    @Override // com.aurora.bdg.screen.catatStand.CatatStandRecordVideoFragment.OnFragmentVideoInteractionListener
    public void onFragmentVideoInteraction(DataMeter dataMeter) {
    }

    @Override // androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setContentView(R.layout.activity_catat_stand);
        ButterKnife.bind(this);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setElevation(0.0f);
        this.statusRead = "0";
        if (getIntent() != null) {
            this.custCode = getIntent().getStringExtra(ARG_CUST_CODE_ID);
            this.resultOcr = getIntent().getStringExtra(ARG_RESULT_OCR);
            this.statusRead = getIntent().getStringExtra(ARG_STATUS_READ);
        }
        setSubtitle("Catat Stand");
        setViewPage(getIntent().getIntExtra("opened_tab", 0));
    }

    @Override // android.app.Activity
    public boolean onOptionsItemSelected(MenuItem menuItem) {
        if (menuItem.getItemId() == 16908332) {
            finish();
            return true;
        }
        return super.onOptionsItemSelected(menuItem);
    }

    public void setSubtitle(String str) {
        getSupportActionBar().setSubtitle(str);
    }

    private void setViewPage(int i) {
        setupViewPager(this.viewPager, i);
        this.tabLayout.setupWithViewPager(this.viewPager);
        this.tabLayout.addOnTabSelectedListener(new TabLayout.OnTabSelectedListener() { // from class: com.aurora.bdg.screen.catatStand.CatatStandActivity.1
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
                        CatatStandActivity.this.setSubtitle("Catat Stand");
                        break;
                    case 1:
                        CatatStandActivity.this.setSubtitle("Video");
                        break;
                }
            }
        });
    }

    private void setupViewPager(ViewPager viewPager, int i) {
        ViewPagerAdapter viewPagerAdapter = new ViewPagerAdapter(getSupportFragmentManager());
        viewPagerAdapter.addFragment(CatatStandFragment.newInstance(this.custCode, this.statusRead, this.resultOcr), "Catat Stand");
        viewPagerAdapter.addFragment(CatatStandRecordVideoFragment.newInstance(this.custCode, this.statusRead), "Video");
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

    @Override // com.aurora.bdg.screen.catatStand.CatatStandFragment.OnFragmentCatatStandInteractionListener
    public void onFragmentCatatStandInteraction(DataMeter dataMeter, String str) {
        if (dataMeter.getTglCatat().isEmpty()) {
            return;
        }
        Intent intent = new Intent();
        intent.putExtra(InfoPelangganUnreadActivity.ARG_WAKTU_CATAT, str);
        setResult(-1, intent);
        finish();
    }
}
