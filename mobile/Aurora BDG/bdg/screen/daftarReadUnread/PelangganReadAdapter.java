package com.aurora.bdg.screen.daftarReadUnread;

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
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public class PelangganReadAdapter extends RecyclerView.Adapter<ViewHolder> {
    private List<Pelanggan> listPelangganRead;
    private PelangganReadFragment.OnListFragmentReadInteractionListener mListener;

    public class ViewHolder_ViewBinding implements Unbinder {
        private ViewHolder target;

        @UiThread
        public ViewHolder_ViewBinding(ViewHolder viewHolder, View view) {
            this.target = viewHolder;
            viewHolder.tvNumber = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_number, "field 'tvNumber'", TextView.class);
            viewHolder.tvNama = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_nama, "field 'tvNama'", TextView.class);
            viewHolder.tvAlamat = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_alamat, "field 'tvAlamat'", TextView.class);
            viewHolder.tvTarif = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_trf, "field 'tvTarif'", TextView.class);
            viewHolder.tvTglCatat = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_tglcatat, "field 'tvTglCatat'", TextView.class);
            viewHolder.tvPemakaian = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_pemakaian, "field 'tvPemakaian'", TextView.class);
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
            viewHolder.tvTarif = null;
            viewHolder.tvTglCatat = null;
            viewHolder.tvPemakaian = null;
        }
    }

    public void setData(List<Pelanggan> list, PelangganReadFragment.OnListFragmentReadInteractionListener onListFragmentReadInteractionListener) {
        this.listPelangganRead = list;
        this.mListener = onListFragmentReadInteractionListener;
    }

    @Override // androidx.recyclerview.widget.RecyclerView.Adapter
    public ViewHolder onCreateViewHolder(ViewGroup viewGroup, int i) {
        return new ViewHolder(LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.fragment_pelanggan_read, viewGroup, false));
    }

    @Override // androidx.recyclerview.widget.RecyclerView.Adapter
    public void onBindViewHolder(ViewHolder viewHolder, int i) {
        final Pelanggan pelanggan = this.listPelangganRead.get(i);
        viewHolder.tvNumber.setText(String.valueOf(i + 1));
        viewHolder.tvNama.setText(pelanggan.getCustCode123() + " " + pelanggan.getCustName());
        viewHolder.tvAlamat.setText(pelanggan.getAlamat());
        viewHolder.tvTarif.setText(pelanggan.getTarif());
        viewHolder.tvTglCatat.setText(pelanggan.getBillDate());
        viewHolder.tvPemakaian.setText(String.valueOf(Integer.parseInt(pelanggan.getBillStand2()) - Integer.parseInt(pelanggan.getBillStand1())));
        viewHolder.mView.setOnClickListener(new View.OnClickListener() { // from class: com.aurora.bdg.screen.daftarReadUnread.PelangganReadAdapter.1
            @Override // android.view.View.OnClickListener
            public void onClick(View view) {
                if (PelangganReadAdapter.this.mListener != null) {
                    PelangganReadAdapter.this.mListener.onListFragmentReadInteraction(pelanggan);
                }
            }
        });
    }

    public void update(ArrayList<Pelanggan> arrayList) {
        this.listPelangganRead = new ArrayList();
        this.listPelangganRead.addAll(arrayList);
        notifyDataSetChanged();
    }

    @Override // androidx.recyclerview.widget.RecyclerView.Adapter
    public int getItemCount() {
        return this.listPelangganRead.size();
    }

    public class ViewHolder extends RecyclerView.ViewHolder {
        public final View mView;

        @BindView(R.id.txt_alamat)
        public TextView tvAlamat;

        @BindView(R.id.txt_nama)
        public TextView tvNama;

        @BindView(R.id.txt_number)
        public TextView tvNumber;

        @BindView(R.id.txt_pemakaian)
        public TextView tvPemakaian;

        @BindView(R.id.txt_trf)
        public TextView tvTarif;

        @BindView(R.id.txt_tglcatat)
        public TextView tvTglCatat;

        public ViewHolder(View view) {
            super(view);
            this.mView = view;
            ButterKnife.bind(this, view);
        }
    }
}
