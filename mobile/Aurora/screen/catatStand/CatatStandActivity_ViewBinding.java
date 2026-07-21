package com.aurora.bdg.screen.catatStand;

import android.view.View;
import androidx.annotation.CallSuper;
import androidx.annotation.UiThread;
import androidx.viewpager.widget.ViewPager;
import butterknife.Unbinder;
import butterknife.internal.Utils;
import com.aurora.bdg.R;
import com.google.android.material.tabs.TabLayout;

/* JADX INFO: loaded from: classes.dex */
public class CatatStandActivity_ViewBinding implements Unbinder {
    private CatatStandActivity target;

    @UiThread
    public CatatStandActivity_ViewBinding(CatatStandActivity catatStandActivity) {
        this(catatStandActivity, catatStandActivity.getWindow().getDecorView());
    }

    @UiThread
    public CatatStandActivity_ViewBinding(CatatStandActivity catatStandActivity, View view) {
        this.target = catatStandActivity;
        catatStandActivity.tabLayout = (TabLayout) Utils.findRequiredViewAsType(view, R.id.tl_tabs, "field 'tabLayout'", TabLayout.class);
        catatStandActivity.viewPager = (ViewPager) Utils.findRequiredViewAsType(view, R.id.vp_pager, "field 'viewPager'", ViewPager.class);
    }

    @Override // butterknife.Unbinder
    @CallSuper
    public void unbind() {
        CatatStandActivity catatStandActivity = this.target;
        if (catatStandActivity == null) {
            throw new IllegalStateException("Bindings already cleared.");
        }
        this.target = null;
        catatStandActivity.tabLayout = null;
        catatStandActivity.viewPager = null;
    }
}
