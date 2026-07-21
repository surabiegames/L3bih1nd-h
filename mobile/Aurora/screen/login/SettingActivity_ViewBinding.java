package com.aurora.bdg.screen.login;

import android.view.View;
import android.widget.EditText;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import androidx.annotation.CallSuper;
import androidx.annotation.UiThread;
import butterknife.Unbinder;
import butterknife.internal.DebouncingOnClickListener;
import butterknife.internal.Utils;
import com.aurora.bdg.R;

/* JADX INFO: loaded from: classes.dex */
public class SettingActivity_ViewBinding implements Unbinder {
    private SettingActivity target;
    private View view7f090078;

    @UiThread
    public SettingActivity_ViewBinding(SettingActivity settingActivity) {
        this(settingActivity, settingActivity.getWindow().getDecorView());
    }

    @UiThread
    public SettingActivity_ViewBinding(final SettingActivity settingActivity, View view) {
        this.target = settingActivity;
        settingActivity.etIpDataOnline = (EditText) Utils.findRequiredViewAsType(view, R.id.et_ip_data_online, "field 'etIpDataOnline'", EditText.class);
        settingActivity.etIpDataOffline = (EditText) Utils.findRequiredViewAsType(view, R.id.et_ip_data_lokal, "field 'etIpDataOffline'", EditText.class);
        settingActivity.etIpPhotoOnline = (EditText) Utils.findRequiredViewAsType(view, R.id.et_ip_photo_online, "field 'etIpPhotoOnline'", EditText.class);
        settingActivity.etIpPhotoOffline = (EditText) Utils.findRequiredViewAsType(view, R.id.et_ip_photo_offline, "field 'etIpPhotoOffline'", EditText.class);
        settingActivity.rgGroupData = (RadioGroup) Utils.findRequiredViewAsType(view, R.id.radio_status_data, "field 'rgGroupData'", RadioGroup.class);
        settingActivity.rgGroupPhoto = (RadioGroup) Utils.findRequiredViewAsType(view, R.id.radio_status_photo, "field 'rgGroupPhoto'", RadioGroup.class);
        settingActivity.statusDataOnline = (RadioButton) Utils.findRequiredViewAsType(view, R.id.status_data_online, "field 'statusDataOnline'", RadioButton.class);
        settingActivity.statusDataOffline = (RadioButton) Utils.findRequiredViewAsType(view, R.id.status_data_offline, "field 'statusDataOffline'", RadioButton.class);
        settingActivity.statusPhotoOnline = (RadioButton) Utils.findRequiredViewAsType(view, R.id.status_photo_online, "field 'statusPhotoOnline'", RadioButton.class);
        settingActivity.statusPhotoOffline = (RadioButton) Utils.findRequiredViewAsType(view, R.id.status_photo_offline, "field 'statusPhotoOffline'", RadioButton.class);
        View viewFindRequiredView = Utils.findRequiredView(view, R.id.btn_submit, "method 'onClickSubmitSetting'");
        this.view7f090078 = viewFindRequiredView;
        viewFindRequiredView.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.login.SettingActivity_ViewBinding.1
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                settingActivity.onClickSubmitSetting();
            }
        });
    }

    @Override // butterknife.Unbinder
    @CallSuper
    public void unbind() {
        SettingActivity settingActivity = this.target;
        if (settingActivity == null) {
            throw new IllegalStateException("Bindings already cleared.");
        }
        this.target = null;
        settingActivity.etIpDataOnline = null;
        settingActivity.etIpDataOffline = null;
        settingActivity.etIpPhotoOnline = null;
        settingActivity.etIpPhotoOffline = null;
        settingActivity.rgGroupData = null;
        settingActivity.rgGroupPhoto = null;
        settingActivity.statusDataOnline = null;
        settingActivity.statusDataOffline = null;
        settingActivity.statusPhotoOnline = null;
        settingActivity.statusPhotoOffline = null;
        this.view7f090078.setOnClickListener(null);
        this.view7f090078 = null;
    }
}
