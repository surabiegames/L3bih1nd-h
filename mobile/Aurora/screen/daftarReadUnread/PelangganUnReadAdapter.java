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
public class PelangganUnReadAdapter extends RecyclerView.Adapter<ViewHolder> {
    private List<Pelanggan> listPelanggan;
    private PelangganUnreadFragment.OnListFragmentUnReadInteractionListener mListener;

    public class ViewHolder_ViewBinding implements Unbinder {
        private ViewHolder target;

        @UiThread
        public ViewHolder_ViewBinding(ViewHolder viewHolder, View view) {
            this.target = viewHolder;
            viewHolder.tvNumber = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_number, "field 'tvNumber'", TextView.class);
            viewHolder.tvNama = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_nama, "field 'tvNama'", TextView.class);
            viewHolder.tvAlamat = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_alamat, "field 'tvAlamat'", TextView.class);
            viewHolder.tvTarif = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_trf, "field 'tvTarif'", TextView.class);
            viewHolder.tvWMSN = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_wmsn, "field 'tvWMSN'", TextView.class);
            viewHolder.tvNoUrut = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_nourut, "field 'tvNoUrut'", TextView.class);
            viewHolder.tvWaktuCatat = (TextView) Utils.findRequiredViewAsType(view, R.id.txt_waktu_catat, "field 'tvWaktuCatat'", TextView.class);
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
            viewHolder.tvWMSN = null;
            viewHolder.tvNoUrut = null;
            viewHolder.tvWaktuCatat = null;
        }
    }

    public void setData(List<Pelanggan> list, PelangganUnreadFragment.OnListFragmentUnReadInteractionListener onListFragmentUnReadInteractionListener) {
        this.listPelanggan = list;
        this.mListener = onListFragmentUnReadInteractionListener;
    }

    @Override // androidx.recyclerview.widget.RecyclerView.Adapter
    public ViewHolder onCreateViewHolder(ViewGroup viewGroup, int i) {
        return new ViewHolder(LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.fragment_pelanggan_unread, viewGroup, false));
    }

    @Override // androidx.recyclerview.widget.RecyclerView.Adapter
    public void onBindViewHolder(ViewHolder viewHolder, int i) {
        final Pelanggan pelanggan = this.listPelanggan.get(i);
        viewHolder.tvNumber.setText(String.valueOf(i + 1));
        viewHolder.tvNama.setText(pelanggan.getCustCode123() + " " + pelanggan.getCustName());
        viewHolder.tvAlamat.setText(pelanggan.getAlamat());
        viewHolder.tvTarif.setText(pelanggan.getTarif());
        viewHolder.tvNoUrut.setText(pelanggan.getBillNoUrutRute());
        viewHolder.tvWMSN.setText(pelanggan.getBillKdWmsizeid() + "-" + pelanggan.getWmsn());
        viewHolder.tvWaktuCatat.setText(pelanggan.getWaktuCatat());
        viewHolder.mView.setOnClickListener(new View.OnClickListener() { // from class: com.aurora.bdg.screen.daftarReadUnread.PelangganUnReadAdapter.1
            @Override // android.view.View.OnClickListener
            public void onClick(View view) {
                if (PelangganUnReadAdapter.this.mListener != null) {
                    PelangganUnReadAdapter.this.mListener.onListFragmentUnReadInteraction(pelanggan);
                }
            }
        });
    }

    @Override // androidx.recyclerview.widget.RecyclerView.Adapter
    public int getItemCount() {
        return this.listPelanggan.size();
    }

    public void update(ArrayList<Pelanggan> arrayList) {
        this.listPelanggan = new ArrayList();
        this.listPelanggan.addAll(arrayList);
        notifyDataSetChanged();
    }

    public class ViewHolder extends RecyclerView.ViewHolder {
        public View mView;

        @BindView(R.id.txt_alamat)
        TextView tvAlamat;

        @BindView(R.id.txt_nama)
        TextView tvNama;

        @BindView(R.id.txt_nourut)
        TextView tvNoUrut;

        @BindView(R.id.txt_number)
        TextView tvNumber;

        @BindView(R.id.txt_trf)
        TextView tvTarif;

        @BindView(R.id.txt_wmsn)
        TextView tvWMSN;

        @BindView(R.id.txt_waktu_catat)
        TextView tvWaktuCatat;

        public ViewHolder(View view) {
            super(view);
            this.mView = view;
            ButterKnife.bind(this, view);
        }

        @Override // androidx.recyclerview.widget.RecyclerView.ViewHolder
        public String toString() {
            return super.toString() + " '" + ((Object) this.tvAlamat.getText()) + "'";
        }
    }
}
