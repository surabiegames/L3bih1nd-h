package com.aurora.bdg.screen.catatStand;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.VideoView;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.core.content.FileProvider;
import androidx.fragment.app.Fragment;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.aurora.bdg.R;
import com.aurora.bdg.model.DataMeter;
import com.aurora.bdg.model.Pelanggan;
import com.aurora.bdg.screen.auroraCamera.AuroraCameraVideoActivity;
import com.aurora.bdg.util.DataBaseHelper;
import com.aurora.bdg.util.DirUtil;
import com.aurora.bdg.util.LocalStorage;
import java.io.File;
import java.io.IOException;

/* JADX INFO: loaded from: classes.dex */
public class CatatStandRecordVideoFragment extends Fragment {
    private static final String ARG_CUST_CODE = "cust-code";
    private static final String ARG_STATUS_READ = "status-read";
    private static final int REQUEST_AURORA_VIDEO = 300;
    private static final int REQUEST_VIDEO_RECORD = 200;
    private static final String VIDEO = "video";

    @BindView(R.id.btn_delete_video)
    Button btnDeleteVideo;
    private String custCode;
    DataBaseHelper dataBaseHelper;

    @BindView(R.id.video_box)
    ImageView ivNoVideo;
    LocalStorage localStorage;
    private OnFragmentVideoInteractionListener mListener;
    private String mParam2;
    Pelanggan pelanggan;
    String period;

    @BindView(R.id.video_thumbnail)
    VideoView videoThumbnail;
    private String TAG = "CatatStandRecordVideo";
    DirUtil dirUtil = new DirUtil();

    public interface OnFragmentVideoInteractionListener {
        void onFragmentVideoInteraction(DataMeter dataMeter);
    }

    public static CatatStandRecordVideoFragment newInstance(String str, String str2) {
        CatatStandRecordVideoFragment catatStandRecordVideoFragment = new CatatStandRecordVideoFragment();
        Bundle bundle = new Bundle();
        bundle.putString("cust-code", str);
        bundle.putString("status-read", str2);
        catatStandRecordVideoFragment.setArguments(bundle);
        return catatStandRecordVideoFragment;
    }

    @Override // androidx.fragment.app.Fragment
    public void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        if (getArguments() != null) {
            this.custCode = getArguments().getString("cust-code");
            this.mParam2 = getArguments().getString("status-read");
        }
        this.localStorage = new LocalStorage(getActivity());
        this.dataBaseHelper = DataBaseHelper.getInstance(getActivity());
    }

    @Override // androidx.fragment.app.Fragment
    public View onCreateView(LayoutInflater layoutInflater, ViewGroup viewGroup, Bundle bundle) {
        View viewInflate = layoutInflater.inflate(R.layout.fragment_catat_stand_record_video, viewGroup, false);
        ButterKnife.bind(this, viewInflate);
        return viewInflate;
    }

    @Override // androidx.fragment.app.Fragment
    public void onViewCreated(View view, @Nullable Bundle bundle) {
        super.onViewCreated(view, bundle);
        this.pelanggan = this.dataBaseHelper.getPelanggan(this.custCode);
        this.period = this.localStorage.getPeriodeY() + "" + this.localStorage.getPeriodeM();
        showVideoTaken();
    }

    @Override // androidx.fragment.app.Fragment
    public void onActivityResult(int i, int i2, Intent intent) {
        super.onActivityResult(i, i2, intent);
        if (i == 200 && i2 == -1) {
            if (intent != null) {
                this.videoThumbnail.setVideoURI(intent.getData());
                this.videoThumbnail.setVisibility(0);
                this.ivNoVideo.setVisibility(8);
                this.btnDeleteVideo.setVisibility(0);
                return;
            }
            return;
        }
        if (i == 300 && i2 == -1) {
            File file = new File(getVideoPath("video"));
            if (file.exists()) {
                this.videoThumbnail.setVideoURI(Uri.parse(file.getAbsolutePath()));
                this.videoThumbnail.setVisibility(0);
                this.ivNoVideo.setVisibility(8);
                this.btnDeleteVideo.setVisibility(0);
            }
        }
    }

    @OnClick({R.id.btn_video})
    public void onClickRecordeVideo() {
        Intent intent = new Intent(getActivity(), (Class<?>) AuroraCameraVideoActivity.class);
        intent.putExtra("period", this.period);
        intent.putExtra("cust-code", this.custCode);
        intent.putExtra("dirName", "video");
        startActivityForResult(intent, 300);
    }

    @OnClick({R.id.btn_delete_video})
    public void onClickDeleteVideo() {
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        builder.setCancelable(false);
        builder.setTitle("Konfirmasi");
        builder.setMessage("Apakah anda yakin menghapus video?");
        builder.setPositiveButton("Ya", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.catatStand.CatatStandRecordVideoFragment.1
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i) {
                CatatStandRecordVideoFragment.this.deleteVideo();
            }
        });
        builder.setNegativeButton("Tidak", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.catatStand.CatatStandRecordVideoFragment.2
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i) {
            }
        });
        builder.show();
    }

    public void deleteVideo() {
        File file = new File(getVideoPath("video"));
        if (file.exists()) {
            file.delete();
            this.ivNoVideo.setVisibility(0);
            this.videoThumbnail.setVisibility(8);
            this.btnDeleteVideo.setVisibility(8);
        }
    }

    public void showVideoTaken() {
        File file = new File(getVideoPath("video"));
        if (file.exists()) {
            this.videoThumbnail.setVideoURI(Uri.parse(file.getAbsolutePath()));
            this.videoThumbnail.setVisibility(0);
            this.ivNoVideo.setVisibility(8);
            this.btnDeleteVideo.setVisibility(0);
        }
    }

    @OnClick({R.id.cv_video})
    public void onClickPreview() {
        File file = new File(getDirPath(), getImagePath2("video"));
        if (file.exists()) {
            Uri uriForFile = FileProvider.getUriForFile(getActivity(), "com.aurora.bdg.fileprovider", file);
            Intent intent = new Intent();
            intent.setAction("android.intent.action.VIEW");
            intent.setDataAndType(uriForFile, "video/*");
            intent.addFlags(3);
            startActivity(intent);
        }
    }

    public void onButtonPressed(DataMeter dataMeter) {
        if (this.mListener != null) {
            this.mListener.onFragmentVideoInteraction(dataMeter);
        }
    }

    /* JADX WARN: Multi-variable type inference failed */
    @Override // androidx.fragment.app.Fragment
    public void onAttach(Context context) {
        super.onAttach(context);
        if (context instanceof OnFragmentVideoInteractionListener) {
            this.mListener = (OnFragmentVideoInteractionListener) context;
            return;
        }
        throw new RuntimeException(context.toString() + " must implement OnFragmentCatatStandInteractionListener");
    }

    @Override // androidx.fragment.app.Fragment
    public void onDetach() {
        super.onDetach();
        this.mListener = null;
    }

    public void recordVideo() throws IOException {
        try {
            Intent intent = new Intent("android.media.action.VIDEO_CAPTURE");
            intent.putExtra("android.intent.extra.videoQuality", 0);
            intent.putExtra("android.intent.extra.durationLimit", 10);
            File fileCreateVideoFile = null;
            try {
                fileCreateVideoFile = createVideoFile("video");
            } catch (IOException e) {
                e.printStackTrace();
                this.dirUtil.generateNoteOnSD("ActivityCatatStand VideoRecord" + e.getMessage());
            }
            if (fileCreateVideoFile != null) {
                intent.putExtra("output", FileProvider.getUriForFile(getActivity(), "com.aurora.bdg.fileprovider", fileCreateVideoFile));
                startActivityForResult(intent, 200);
            }
        } catch (Exception e2) {
            e2.printStackTrace();
            this.dirUtil.generateNoteOnSD("ActivityCatatStand VideoRecord : " + e2.getMessage());
        }
    }

    public String getDirPath() {
        return Environment.getExternalStorageDirectory() + File.separator + this.dirUtil.dirName + File.separator;
    }

    public String getImagePath2(String str) {
        return str + File.separator + (this.period + "_" + str + "_" + this.custCode) + ".jpg";
    }

    private File createVideoFile(String str) throws IOException {
        return new File(getVideoPath(str));
    }

    public String getVideoPath(String str) {
        return Environment.getExternalStorageDirectory() + File.separator + this.dirUtil.dirName + File.separator + str + File.separator + (this.period + "_" + str + "_" + this.custCode) + ".mp4";
    }
}
