package com.aurora.bdg.screen.login;

import android.view.View;
import android.widget.EditText;
import androidx.annotation.CallSuper;
import androidx.annotation.UiThread;
import butterknife.Unbinder;
import butterknife.internal.DebouncingOnClickListener;
import butterknife.internal.Utils;
import com.aurora.bdg.R;

/* JADX INFO: loaded from: classes.dex */
public class LoginActivity_ViewBinding implements Unbinder {
    private LoginActivity target;
    private View view7f090071;
    private View view7f09023f;
    private View view7f09025c;

    @UiThread
    public LoginActivity_ViewBinding(LoginActivity loginActivity) {
        this(loginActivity, loginActivity.getWindow().getDecorView());
    }

    @UiThread
    public LoginActivity_ViewBinding(final LoginActivity loginActivity, View view) {
        this.target = loginActivity;
        loginActivity.etUsername = (EditText) Utils.findRequiredViewAsType(view, R.id.et_username, "field 'etUsername'", EditText.class);
        loginActivity.etPassword = (EditText) Utils.findRequiredViewAsType(view, R.id.et_password, "field 'etPassword'", EditText.class);
        View viewFindRequiredView = Utils.findRequiredView(view, R.id.btn_login, "method 'onClickLogin'");
        this.view7f090071 = viewFindRequiredView;
        viewFindRequiredView.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.login.LoginActivity_ViewBinding.1
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                loginActivity.onClickLogin();
            }
        });
        View viewFindRequiredView2 = Utils.findRequiredView(view, R.id.tv_setting, "method 'onClickSetting'");
        this.view7f09025c = viewFindRequiredView2;
        viewFindRequiredView2.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.login.LoginActivity_ViewBinding.2
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                loginActivity.onClickSetting();
            }
        });
        View viewFindRequiredView3 = Utils.findRequiredView(view, R.id.tv_download_petugas, "method 'onClickDownloadData'");
        this.view7f09023f = viewFindRequiredView3;
        viewFindRequiredView3.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.login.LoginActivity_ViewBinding.3
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                loginActivity.onClickDownloadData();
            }
        });
    }

    @Override // butterknife.Unbinder
    @CallSuper
    public void unbind() {
        LoginActivity loginActivity = this.target;
        if (loginActivity == null) {
            throw new IllegalStateException("Bindings already cleared.");
        }
        this.target = null;
        loginActivity.etUsername = null;
        loginActivity.etPassword = null;
        this.view7f090071.setOnClickListener(null);
        this.view7f090071 = null;
        this.view7f09025c.setOnClickListener(null);
        this.view7f09025c = null;
        this.view7f09023f.setOnClickListener(null);
        this.view7f09023f = null;
    }
}
