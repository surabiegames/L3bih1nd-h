package com.aurora.bdg.screen.daftarPencarian;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.CallSuper;
import androidx.annotation.UiThread;
import androidx.recyclerview.widget.RecyclerView;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.Unbinder;
import butterknife.internal.Utils;
import com.aurora.bdg.R;
import com.aurora.bdg.model.Pelanggan;
import java.util.ArrayList;

/* JADX INFO: loaded from: classes.dex */
public class DaftarPencarianAdapter extends RecyclerView.Adapter<ViewHolder> {
    ArrayList<Pelanggan> listRute;
    private OnItemClickListener listener;

    public interface OnItemClickListener {
        void onItemClick(Pelanggan pelanggan, int i);
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
            viewHolder.tvNama = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_nama, "field 'tvNama'", TextView.class);
            viewHolder.tvAlamat = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_alamat, "field 'tvAlamat'", TextView.class);
            viewHolder.tvTrf = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_trf, "field 'tvTrf'", TextView.class);
            viewHolder.tvStatusBaca = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_statusbaca, "field 'tvStatusBaca'", TextView.class);
            viewHolder.tvBillId = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_billid, "field 'tvBillId'", TextView.class);
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
            viewHolder.tvNama = null;
            viewHolder.tvAlamat = null;
            viewHolder.tvTrf = null;
            viewHolder.tvStatusBaca = null;
            viewHolder.tvBillId = null;
        }
    }

    class ViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.txt_alamat)
        TextView tvAlamat;

        @BindView(R.id.txt_billid)
        TextView tvBillId;

        @BindView(R.id.txt_nama)
        TextView tvNama;

        @BindView(R.id.txt_number)
        TextView tvNumber;

        @BindView(R.id.txt_statusbaca)
        TextView tvStatusBaca;

        @BindView(R.id.txt_trf)
        TextView tvTrf;

        public ViewHolder(View view) {
            super(view);
            ButterKnife.bind(this, view);
            view.setOnClickListener(new View.OnClickListener() { // from class: com.aurora.bdg.screen.daftarPencarian.DaftarPencarianAdapter.ViewHolder.1
                @Override // android.view.View.OnClickListener
                public void onClick(View view2) {
                    int adapterPosition;
                    if (DaftarPencarianAdapter.this.listener == null || (adapterPosition = ViewHolder.this.getAdapterPosition()) == -1) {
                        return;
                    }
                    DaftarPencarianAdapter.this.listener.onItemClick(DaftarPencarianAdapter.this.listRute.get(adapterPosition), adapterPosition);
                }
            });
        }
    }

    public DaftarPencarianAdapter(ArrayList<Pelanggan> arrayList) {
        this.listRute = new ArrayList<>();
        this.listRute = arrayList;
    }

    @Override // androidx.recyclerview.widget.RecyclerView.Adapter
    public ViewHolder onCreateViewHolder(ViewGroup viewGroup, int i) {
        return new ViewHolder(LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.cardview_pencarian, viewGroup, false));
    }

    @Override // androidx.recyclerview.widget.RecyclerView.Adapter
    public void onBindViewHolder(ViewHolder viewHolder, int i) {
        Pelanggan pelanggan = this.listRute.get(i);
        viewHolder.tvNumber.setText(String.valueOf(i + 1));
        viewHolder.tvNama.setText(pelanggan.getCustCode123() + " " + pelanggan.getCustName());
        viewHolder.tvAlamat.setText(pelanggan.getAlamat());
        viewHolder.tvTrf.setText("Tarif: " + pelanggan.getTarif());
        if (pelanggan.getBillStand2() == null || pelanggan.getBillStand2().equals("")) {
            viewHolder.tvStatusBaca.setText("BELUM");
        } else {
            viewHolder.tvStatusBaca.setText("SUDAH");
        }
        viewHolder.tvBillId.setText(pelanggan.getBillBlId());
    }

    @Override // androidx.recyclerview.widget.RecyclerView.Adapter
    public int getItemCount() {
        return this.listRute.size();
    }

    public void setOnItemClickListener(OnItemClickListener onItemClickListener) {
        this.listener = onItemClickListener;
    }
}
