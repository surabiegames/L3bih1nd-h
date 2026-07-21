package com.aurora.bdg.screen.catatStand;

import android.app.Dialog;
import android.graphics.BitmapFactory;
import android.os.Build;
import android.os.Bundle;
import android.os.VibrationEffect;
import android.os.Vibrator;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.cardview.widget.CardView;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.DialogFragment;
import com.aurora.bdg.R;
import com.aurora.bdg.util.FormatterHelper;

/* JADX INFO: loaded from: classes.dex */
public class CatatConfirmDialogFragment extends DialogFragment {
    private static final String ARG_ADMIN = "ADMIN";
    private static final String ARG_AIR = "AIR";
    private static final String ARG_KELAINAN = "param4";
    private static final String ARG_M3 = "param2";
    private static final String ARG_PEMELIHARAAN = "PEMELIHARAAN";
    private static final String ARG_PHOTO_STAND = "param3";
    private static final String ARG_STAND_AKHIR = "param1";
    private static final String ARG_TOTAL = "TOTAL";
    private static final String ARG_TYPE = "param5";
    private int admin;
    private int air;
    Button btnCancel;
    Button btnSave;
    CardView cvForm;
    ImageView ivStand;
    private String kelainan;
    private OnConfirmDialogListener listener;
    private String m3;
    private int pemeliharaan;
    private String photoStand;
    private String standAkhir;
    private int total;
    TextView tvAdmin;
    TextView tvAir;
    TextView tvKelainan;
    TextView tvM3;
    TextView tvPemeliharaan;
    TextView tvStand;
    TextView tvTotal;
    private int type;

    interface OnConfirmDialogListener {
        void onSaveConfirmDialog();
    }

    @Override // androidx.fragment.app.DialogFragment
    public Dialog onCreateDialog(Bundle bundle) {
        Dialog dialogOnCreateDialog = super.onCreateDialog(bundle);
        dialogOnCreateDialog.getWindow().requestFeature(1);
        return dialogOnCreateDialog;
    }

    public static CatatConfirmDialogFragment newInstance(String str, String str2, String str3, String str4, int i, int i2, int i3, int i4, int i5) {
        CatatConfirmDialogFragment catatConfirmDialogFragment = new CatatConfirmDialogFragment();
        Bundle bundle = new Bundle();
        bundle.putString(ARG_STAND_AKHIR, str);
        bundle.putString(ARG_M3, str2);
        bundle.putString(ARG_PHOTO_STAND, str3);
        bundle.putString(ARG_KELAINAN, str4);
        bundle.putInt(ARG_TYPE, i);
        bundle.putInt(ARG_AIR, i2);
        bundle.putInt(ARG_ADMIN, i3);
        bundle.putInt(ARG_PEMELIHARAAN, i4);
        bundle.putInt(ARG_TOTAL, i5);
        catatConfirmDialogFragment.setArguments(bundle);
        return catatConfirmDialogFragment;
    }

    @Override // androidx.fragment.app.DialogFragment, androidx.fragment.app.Fragment
    public void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        if (getArguments() != null) {
            this.standAkhir = getArguments().getString(ARG_STAND_AKHIR);
            this.m3 = getArguments().getString(ARG_M3);
            this.photoStand = getArguments().getString(ARG_PHOTO_STAND);
            this.kelainan = getArguments().getString(ARG_KELAINAN);
            this.type = getArguments().getInt(ARG_TYPE);
            this.air = getArguments().getInt(ARG_AIR);
            this.admin = getArguments().getInt(ARG_ADMIN);
            this.pemeliharaan = getArguments().getInt(ARG_PEMELIHARAAN);
            this.total = getArguments().getInt(ARG_TOTAL);
        }
        this.listener = (OnConfirmDialogListener) getTargetFragment();
    }

    @Override // androidx.fragment.app.Fragment
    public void onResume() {
        WindowManager.LayoutParams attributes = getDialog().getWindow().getAttributes();
        ((ViewGroup.LayoutParams) attributes).width = -1;
        getDialog().getWindow().setAttributes(attributes);
        super.onResume();
    }

    @Override // androidx.fragment.app.Fragment
    public View onCreateView(LayoutInflater layoutInflater, ViewGroup viewGroup, Bundle bundle) {
        return layoutInflater.inflate(R.layout.fragment_catat_confirm_dialog, viewGroup, false);
    }

    @Override // androidx.fragment.app.Fragment
    public void onViewCreated(@NonNull View view, @Nullable Bundle bundle) {
        super.onViewCreated(view, bundle);
        this.tvStand = (TextView) view.findViewById(R.id.tvStand);
        this.tvKelainan = (TextView) view.findViewById(R.id.tvKelainan);
        this.tvM3 = (TextView) view.findViewById(R.id.tvKubik);
        this.tvAir = (TextView) view.findViewById(R.id.tvAir);
        this.tvAdmin = (TextView) view.findViewById(R.id.tvAdmin);
        this.tvPemeliharaan = (TextView) view.findViewById(R.id.tvPemeliharaan);
        this.tvTotal = (TextView) view.findViewById(R.id.tvTotal);
        this.ivStand = (ImageView) view.findViewById(R.id.ivMeter);
        this.cvForm = (CardView) view.findViewById(R.id.cvForm);
        this.btnSave = (Button) view.findViewById(R.id.btnSave);
        this.btnCancel = (Button) view.findViewById(R.id.btnCancel);
        this.btnSave.setOnClickListener(new View.OnClickListener() { // from class: com.aurora.bdg.screen.catatStand.-$$Lambda$CatatConfirmDialogFragment$K4N9_5upMa9FCFcVGYnQD1Mb-ag
            @Override // android.view.View.OnClickListener
            public final void onClick(View view2) {
                CatatConfirmDialogFragment.lambda$onViewCreated$0(this.f$0, view2);
            }
        });
        this.btnCancel.setOnClickListener(new View.OnClickListener() { // from class: com.aurora.bdg.screen.catatStand.-$$Lambda$CatatConfirmDialogFragment$L-leLRlQnq2dqqh5sZG76m3Epxw
            @Override // android.view.View.OnClickListener
            public final void onClick(View view2) {
                this.f$0.dismiss();
            }
        });
        this.tvStand.setText(this.standAkhir);
        this.tvM3.setText(this.m3);
        this.tvKelainan.setText(this.kelainan);
        this.tvAir.setText(FormatterHelper.addComma(this.air));
        this.tvAdmin.setText(FormatterHelper.addComma(this.admin));
        this.tvPemeliharaan.setText(FormatterHelper.addComma(this.pemeliharaan));
        this.tvTotal.setText(FormatterHelper.addComma(this.total));
        this.ivStand.setImageBitmap(BitmapFactory.decodeFile(this.photoStand));
        switch (this.type) {
            case 1:
                this.cvForm.setCardBackgroundColor(ContextCompat.getColor(getActivity(), R.color.yellow50));
                startVibrate();
                break;
            case 2:
                startVibrate();
                this.cvForm.setCardBackgroundColor(ContextCompat.getColor(getActivity(), R.color.red50));
                break;
        }
    }

    public static /* synthetic */ void lambda$onViewCreated$0(CatatConfirmDialogFragment catatConfirmDialogFragment, View view) {
        catatConfirmDialogFragment.listener.onSaveConfirmDialog();
        catatConfirmDialogFragment.dismiss();
    }

    private void startVibrate() {
        Vibrator vibrator = (Vibrator) getActivity().getSystemService("vibrator");
        if (Build.VERSION.SDK_INT >= 26) {
            vibrator.vibrate(VibrationEffect.createOneShot(200L, -1));
        } else {
            vibrator.vibrate(2000L);
        }
    }
}
