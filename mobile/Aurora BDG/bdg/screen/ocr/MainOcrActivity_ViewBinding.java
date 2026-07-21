package com.aurora.bdg.screen.ocr;

import android.view.View;
import android.widget.ImageButton;
import androidx.annotation.CallSuper;
import androidx.annotation.UiThread;
import butterknife.Unbinder;
import butterknife.internal.DebouncingOnClickListener;
import butterknife.internal.Utils;
import com.aurora.bdg.R;

/* JADX INFO: loaded from: classes.dex */
public class MainOcrActivity_ViewBinding implements Unbinder {
    private MainOcrActivity target;
    private View view7f09006d;

    @UiThread
    public MainOcrActivity_ViewBinding(MainOcrActivity mainOcrActivity) {
        this(mainOcrActivity, mainOcrActivity.getWindow().getDecorView());
    }

    @UiThread
    public MainOcrActivity_ViewBinding(final MainOcrActivity mainOcrActivity, View view) {
        this.target = mainOcrActivity;
        View viewFindRequiredView = Utils.findRequiredView(view, R.id.btn_flash, "field 'flashButton' and method 'onClickFlash'");
        mainOcrActivity.flashButton = (ImageButton) Utils.castView(viewFindRequiredView, R.id.btn_flash, "field 'flashButton'", ImageButton.class);
        this.view7f09006d = viewFindRequiredView;
        viewFindRequiredView.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.ocr.MainOcrActivity_ViewBinding.1
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                mainOcrActivity.onClickFlash();
            }
        });
    }

    @Override // butterknife.Unbinder
    @CallSuper
    public void unbind() {
        MainOcrActivity mainOcrActivity = this.target;
        if (mainOcrActivity == null) {
            throw new IllegalStateException("Bindings already cleared.");
        }
        this.target = null;
        mainOcrActivity.flashButton = null;
        this.view7f09006d.setOnClickListener(null);
        this.view7f09006d = null;
    }
}
