package com.aurora.bdg.screen.daftarReadUnread;

import android.view.View;
import androidx.annotation.CallSuper;
import androidx.annotation.UiThread;
import androidx.viewpager.widget.ViewPager;
import butterknife.Unbinder;
import butterknife.internal.Utils;
import com.aurora.bdg.R;
import com.google.android.material.tabs.TabLayout;

/* JADX INFO: loaded from: classes.dex */
public class DaftarReadUnreadActivity_ViewBinding implements Unbinder {
    private DaftarReadUnreadActivity target;

    @UiThread
    public DaftarReadUnreadActivity_ViewBinding(DaftarReadUnreadActivity daftarReadUnreadActivity) {
        this(daftarReadUnreadActivity, daftarReadUnreadActivity.getWindow().getDecorView());
    }

    @UiThread
    public DaftarReadUnreadActivity_ViewBinding(DaftarReadUnreadActivity daftarReadUnreadActivity, View view) {
        this.target = daftarReadUnreadActivity;
        daftarReadUnreadActivity.tabLayout = (TabLayout) Utils.findRequiredViewAsType(view, R.id.tl_tabs, "field 'tabLayout'", TabLayout.class);
        daftarReadUnreadActivity.viewPager = (ViewPager) Utils.findRequiredViewAsType(view, R.id.vp_pager, "field 'viewPager'", ViewPager.class);
    }

    @Override // butterknife.Unbinder
    @CallSuper
    public void unbind() {
        DaftarReadUnreadActivity daftarReadUnreadActivity = this.target;
        if (daftarReadUnreadActivity == null) {
            throw new IllegalStateException("Bindings already cleared.");
        }
        this.target = null;
        daftarReadUnreadActivity.tabLayout = null;
        daftarReadUnreadActivity.viewPager = null;
    }
}
