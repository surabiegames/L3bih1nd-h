package com.aurora.bdg.screen.checkTagihan;

import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.TextView;
import androidx.annotation.CallSuper;
import androidx.annotation.UiThread;
import androidx.cardview.widget.CardView;
import butterknife.Unbinder;
import butterknife.internal.DebouncingOnClickListener;
import butterknife.internal.Utils;
import com.aurora.bdg.R;

/* JADX INFO: loaded from: classes.dex */
public class CheckTagihanActivity_ViewBinding implements Unbinder {
    private CheckTagihanActivity target;
    private View view7f09006f;

    @UiThread
    public CheckTagihanActivity_ViewBinding(CheckTagihanActivity checkTagihanActivity) {
        this(checkTagihanActivity, checkTagihanActivity.getWindow().getDecorView());
    }

    @UiThread
    public CheckTagihanActivity_ViewBinding(final CheckTagihanActivity checkTagihanActivity, View view) {
        this.target = checkTagihanActivity;
        checkTagihanActivity.etIdPelanggan = (EditText) Utils.findRequiredViewAsType(view, R.id.et_pelanggan_id, "field 'etIdPelanggan'", EditText.class);
        checkTagihanActivity.tvNamaPdam = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_pdam_nama_pdam, "field 'tvNamaPdam'", TextView.class);
        checkTagihanActivity.tvNoPelanggan = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_pdam_no_pelanggan, "field 'tvNoPelanggan'", TextView.class);
        checkTagihanActivity.tvNamaPelanggan = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_pdam_nama, "field 'tvNamaPelanggan'", TextView.class);
        checkTagihanActivity.tvAlamatTitle = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_pdam_alamat_title, "field 'tvAlamatTitle'", TextView.class);
        checkTagihanActivity.tvAlamat = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_pdam_alamat, "field 'tvAlamat'", TextView.class);
        checkTagihanActivity.tvPemakaian = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_pdam_pemakaian, "field 'tvPemakaian'", TextView.class);
        checkTagihanActivity.tvNoResi = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_pdam_no_resi, "field 'tvNoResi'", TextView.class);
        checkTagihanActivity.tvDate = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_pdam_date, "field 'tvDate'", TextView.class);
        checkTagihanActivity.tvPemakaianTitle = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_pdam_pemakaian_title, "field 'tvPemakaianTitle'", TextView.class);
        checkTagihanActivity.tvTagihan = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_pdam_tagihan, "field 'tvTagihan'", TextView.class);
        checkTagihanActivity.tvTotal = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_pdam_total, "field 'tvTotal'", TextView.class);
        checkTagihanActivity.trDenda = (TableRow) Utils.findRequiredViewAsType(view, R.id.tr_denda, "field 'trDenda'", TableRow.class);
        checkTagihanActivity.tvDenda = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_pdam_denda, "field 'tvDenda'", TextView.class);
        checkTagihanActivity.cvLayoutResult = (CardView) Utils.findRequiredViewAsType(view, R.id.layout_result, "field 'cvLayoutResult'", CardView.class);
        checkTagihanActivity.tableLayout = (TableLayout) Utils.findRequiredViewAsType(view, R.id.table_list_inquiry, "field 'tableLayout'", TableLayout.class);
        View viewFindRequiredView = Utils.findRequiredView(view, R.id.btn_inquiry_pdam, "field 'btnInquiry' and method 'onClickInquery'");
        checkTagihanActivity.btnInquiry = (Button) Utils.castView(viewFindRequiredView, R.id.btn_inquiry_pdam, "field 'btnInquiry'", Button.class);
        this.view7f09006f = viewFindRequiredView;
        viewFindRequiredView.setOnClickListener(new DebouncingOnClickListener() { // from class: com.aurora.bdg.screen.checkTagihan.CheckTagihanActivity_ViewBinding.1
            @Override // butterknife.internal.DebouncingOnClickListener
            public void doClick(View view2) {
                checkTagihanActivity.onClickInquery();
            }
        });
    }

    @Override // butterknife.Unbinder
    @CallSuper
    public void unbind() {
        CheckTagihanActivity checkTagihanActivity = this.target;
        if (checkTagihanActivity == null) {
            throw new IllegalStateException("Bindings already cleared.");
        }
        this.target = null;
        checkTagihanActivity.etIdPelanggan = null;
        checkTagihanActivity.tvNamaPdam = null;
        checkTagihanActivity.tvNoPelanggan = null;
        checkTagihanActivity.tvNamaPelanggan = null;
        checkTagihanActivity.tvAlamatTitle = null;
        checkTagihanActivity.tvAlamat = null;
        checkTagihanActivity.tvPemakaian = null;
        checkTagihanActivity.tvNoResi = null;
        checkTagihanActivity.tvDate = null;
        checkTagihanActivity.tvPemakaianTitle = null;
        checkTagihanActivity.tvTagihan = null;
        checkTagihanActivity.tvTotal = null;
        checkTagihanActivity.trDenda = null;
        checkTagihanActivity.tvDenda = null;
        checkTagihanActivity.cvLayoutResult = null;
        checkTagihanActivity.tableLayout = null;
        checkTagihanActivity.btnInquiry = null;
        this.view7f09006f.setOnClickListener(null);
        this.view7f09006f = null;
    }
}
