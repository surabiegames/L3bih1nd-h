package com.aurora.bdg.screen.upload;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.TextView;
import androidx.annotation.CallSuper;
import androidx.annotation.UiThread;
import androidx.recyclerview.widget.RecyclerView;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.Unbinder;
import butterknife.internal.Utils;
import com.aurora.bdg.R;
import com.aurora.bdg.model.RuteUpload;
import java.util.ArrayList;
import java.util.Iterator;

/* JADX INFO: loaded from: classes.dex */
public class UploadDataDaftarRuteAdapter extends RecyclerView.Adapter<ViewHolder> {
    ArrayList<RuteUpload> listRuteUpload;

    @Override // androidx.recyclerview.widget.RecyclerView.Adapter
    public int getItemViewType(int i) {
        return i;
    }

    public class ViewHolder_ViewBinding implements Unbinder {
        private ViewHolder target;

        @UiThread
        public ViewHolder_ViewBinding(ViewHolder viewHolder, View view) {
            this.target = viewHolder;
            viewHolder.txtNumber = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_number, "field 'txtNumber'", TextView.class);
            viewHolder.txtTotalCatat = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_totalcatat, "field 'txtTotalCatat'", TextView.class);
            viewHolder.txtBelumUpload = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_belumupload, "field 'txtBelumUpload'", TextView.class);
            viewHolder.chkData = (CheckBox) Utils.findRequiredViewAsType(view, R.id.chk_data, "field 'chkData'", CheckBox.class);
            viewHolder.txtBlockId = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_blockid, "field 'txtBlockId'", TextView.class);
        }

        @Override // butterknife.Unbinder
        @CallSuper
        public void unbind() {
            ViewHolder viewHolder = this.target;
            if (viewHolder == null) {
                throw new IllegalStateException("Bindings already cleared.");
            }
            this.target = null;
            viewHolder.txtNumber = null;
            viewHolder.txtTotalCatat = null;
            viewHolder.txtBelumUpload = null;
            viewHolder.chkData = null;
            viewHolder.txtBlockId = null;
        }
    }

    public UploadDataDaftarRuteAdapter(ArrayList<RuteUpload> arrayList) {
        this.listRuteUpload = new ArrayList<>();
        this.listRuteUpload = arrayList;
    }

    public class ViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.chk_data)
        CheckBox chkData;

        @BindView(R.id.txt_belumupload)
        TextView txtBelumUpload;

        @BindView(R.id.txt_blockid)
        TextView txtBlockId;

        @BindView(R.id.txt_number)
        TextView txtNumber;

        @BindView(R.id.txt_totalcatat)
        TextView txtTotalCatat;

        public ViewHolder(View view) {
            super(view);
            ButterKnife.bind(this, view);
        }
    }

    @Override // androidx.recyclerview.widget.RecyclerView.Adapter
    public ViewHolder onCreateViewHolder(ViewGroup viewGroup, int i) {
        return new ViewHolder(LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.cardview_upload_rute, viewGroup, false));
    }

    @Override // androidx.recyclerview.widget.RecyclerView.Adapter
    public void onBindViewHolder(ViewHolder viewHolder, int i) {
        final RuteUpload ruteUpload = this.listRuteUpload.get(i);
        viewHolder.txtNumber.setText(String.valueOf(i + 1));
        viewHolder.txtTotalCatat.setText("Total Catat : " + ruteUpload.getTotalCatat());
        viewHolder.txtBelumUpload.setText("Belum Upload : " + ruteUpload.getBelumUpload());
        viewHolder.txtBlockId.setText(ruteUpload.getBlockId() + "");
        viewHolder.chkData.setText(ruteUpload.getBlockCode() + " " + ruteUpload.getBlockName());
        viewHolder.chkData.setChecked(ruteUpload.isSelected());
        viewHolder.chkData.setTag(ruteUpload);
        viewHolder.chkData.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() { // from class: com.aurora.bdg.screen.upload.UploadDataDaftarRuteAdapter.1
            @Override // android.widget.CompoundButton.OnCheckedChangeListener
            public void onCheckedChanged(CompoundButton compoundButton, boolean z) {
                if (z) {
                    ruteUpload.setSelected(true);
                } else {
                    ruteUpload.setSelected(false);
                }
            }
        });
    }

    public void checkedAll() {
        Iterator<RuteUpload> it = this.listRuteUpload.iterator();
        while (it.hasNext()) {
            it.next().setSelected(true);
        }
        notifyDataSetChanged();
    }

    public void unSelectAll() {
        Iterator<RuteUpload> it = this.listRuteUpload.iterator();
        while (it.hasNext()) {
            it.next().setSelected(false);
        }
        notifyDataSetChanged();
    }

    @Override // androidx.recyclerview.widget.RecyclerView.Adapter
    public int getItemCount() {
        return this.listRuteUpload.size();
    }
}
