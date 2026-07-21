package com.aurora.bdg.screen.daftarPelanggan;

import android.annotation.TargetApi;
import android.graphics.PorterDuff;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ProgressBar;
import android.widget.TextView;
import androidx.annotation.CallSuper;
import androidx.annotation.UiThread;
import androidx.recyclerview.widget.RecyclerView;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.Unbinder;
import butterknife.internal.Utils;
import com.aurora.bdg.R;
import com.aurora.bdg.model.Rute;
import java.util.ArrayList;

/* JADX INFO: loaded from: classes.dex */
public class DaftarPelangganAdapter extends RecyclerView.Adapter<ViewHolder> {
    ArrayList<Rute> listRute;
    private OnItemClickListener listener;

    public interface OnItemClickListener {
        void onItemClick(Rute rute, int i);
    }

    @Override // androidx.recyclerview.widget.RecyclerView.Adapter
    public int getItemViewType(int i) {
        return i;
    }

    public class ViewHolder_ViewBinding implements Unbinder {
        private ViewHolder target;

        @UiThread
        public ViewHolder_ViewBinding(ViewHolder viewHolder, View view) {
            this.target = viewHolder;
            viewHolder.tvNumber = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_number, "field 'tvNumber'", TextView.class);
            viewHolder.tvRuteId = (TextView) Utils.findRequiredViewAsType(view, R.id.tv_rute_id, "field 'tvRuteId'", TextView.class);
            viewHolder.tvJumlah = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_jumlah, "field 'tvJumlah'", TextView.class);
            viewHolder.tvProgress = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_progress, "field 'tvProgress'", TextView.class);
            viewHolder.rvRead = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_read, "field 'rvRead'", TextView.class);
            viewHolder.tvUnread = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_unread, "field 'tvUnread'", TextView.class);
            viewHolder.progressBar = (ProgressBar) Utils.findRequiredViewAsType(view, R.id.progress, "field 'progressBar'", ProgressBar.class);
            viewHolder.tvProgressbar = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_progressbar_memory, "field 'tvProgressbar'", TextView.class);
        }

        @Override // butterknife.Unbinder
        @CallSuper
        public void unbind() {
            ViewHolder viewHolder = this.target;
            if (viewHolder == null) {
                throw new IllegalStateException("Bindings already cleared.");
            }
            this.target = null;
            viewHolder.tvNumber = null;
            viewHolder.tvRuteId = null;
            viewHolder.tvJumlah = null;
            viewHolder.tvProgress = null;
            viewHolder.rvRead = null;
            viewHolder.tvUnread = null;
            viewHolder.progressBar = null;
            viewHolder.tvProgressbar = null;
        }
    }

    class ViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.progress)
        ProgressBar progressBar;

        @BindView(R.id.txt_read)
        TextView rvRead;

        @BindView(R.id.txt_jumlah)
        TextView tvJumlah;

        @BindView(R.id.txt_number)
        TextView tvNumber;

        @BindView(R.id.txt_progress)
        TextView tvProgress;

        @BindView(R.id.txt_progressbar_memory)
        TextView tvProgressbar;

        @BindView(R.id.tv_rute_id)
        TextView tvRuteId;

        @BindView(R.id.txt_unread)
        TextView tvUnread;

        public ViewHolder(View view) {
            super(view);
            ButterKnife.bind(this, view);
            view.setOnClickListener(new View.OnClickListener() { // from class: com.aurora.bdg.screen.daftarPelanggan.DaftarPelangganAdapter.ViewHolder.1
                @Override // android.view.View.OnClickListener
                public void onClick(View view2) {
                    int adapterPosition;
                    if (DaftarPelangganAdapter.this.listener == null || (adapterPosition = ViewHolder.this.getAdapterPosition()) == -1) {
                        return;
                    }
                    DaftarPelangganAdapter.this.listener.onItemClick(DaftarPelangganAdapter.this.listRute.get(adapterPosition), adapterPosition);
                }
            });
        }
    }

    public DaftarPelangganAdapter(ArrayList<Rute> arrayList) {
        this.listRute = new ArrayList<>();
        this.listRute = arrayList;
    }

    @Override // androidx.recyclerview.widget.RecyclerView.Adapter
    public ViewHolder onCreateViewHolder(ViewGroup viewGroup, int i) {
        return new ViewHolder(LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.cardview_dp, viewGroup, false));
    }

    @Override // androidx.recyclerview.widget.RecyclerView.Adapter
    @TargetApi(21)
    public void onBindViewHolder(ViewHolder viewHolder, int i) {
        Rute rute = this.listRute.get(i);
        viewHolder.tvNumber.setText(String.valueOf(i + 1));
        viewHolder.tvRuteId.setText(rute.getRuteId());
        viewHolder.tvJumlah.setText("Jumlah: " + rute.getAktif());
        viewHolder.rvRead.setText("Read: " + rute.getRead());
        viewHolder.tvUnread.setText("Unread: " + rute.getUnRead());
        int iIntValue = Integer.valueOf(rute.getRead()).intValue();
        int iIntValue2 = Integer.valueOf(rute.getAktif()).intValue();
        double dFloor = Math.floor((((double) (iIntValue * 100)) / ((double) iIntValue2)) * 100.0d) / 100.0d;
        if (rute.getRead().equals(rute.getAktif())) {
            viewHolder.progressBar.getProgressDrawable().setColorFilter(-16711936, PorterDuff.Mode.SRC_IN);
        } else {
            viewHolder.progressBar.getProgressDrawable().setColorFilter(855638016, PorterDuff.Mode.OVERLAY);
        }
        viewHolder.tvProgress.setText("Progress: " + dFloor + " %");
        viewHolder.tvProgressbar.setText(iIntValue + "/" + iIntValue2 + "  ( " + dFloor + "% )");
        viewHolder.progressBar.setProgress((int) dFloor);
    }

    @Override // androidx.recyclerview.widget.RecyclerView.Adapter
    public int getItemCount() {
        return this.listRute.size();
    }

    public void update(ArrayList<Rute> arrayList) {
        this.listRute = new ArrayList<>();
        this.listRute.addAll(arrayList);
        notifyDataSetChanged();
    }

    public void update2(ArrayList<Rute> arrayList) {
        this.listRute.clear();
        this.listRute.addAll(arrayList);
        notifyDataSetChanged();
    }

    public void setOnItemClickListener(OnItemClickListener onItemClickListener) {
        this.listener = onItemClickListener;
    }
}
