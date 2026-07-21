package com.aurora.bdg.screen.catatStand;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.location.Location;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.Spinner;
import android.widget.SpinnerAdapter;
import android.widget.TextView;
import android.widget.Toast;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.core.content.FileProvider;
import androidx.exifinterface.media.ExifInterface;
import androidx.fragment.app.Fragment;
import androidx.vectordrawable.graphics.drawable.PathInterpolatorCompat;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.aurora.bdg.App;
import com.aurora.bdg.R;
import com.aurora.bdg.model.Alasan;
import com.aurora.bdg.model.AlasanDao;
import com.aurora.bdg.model.DaoSession;
import com.aurora.bdg.model.DataMeter;
import com.aurora.bdg.model.Pelanggan;
import com.aurora.bdg.model.Tarif;
import com.aurora.bdg.model.TarifDao;
import com.aurora.bdg.model.WaterTarif;
import com.aurora.bdg.model.WaterTarifDao;
import com.aurora.bdg.model.Wmsize;
import com.aurora.bdg.model.WmsizeDao;
import com.aurora.bdg.screen.downloadData.DownloadDataActivity;
import com.aurora.bdg.screen.ocr.MainOcrActivity;
import com.aurora.bdg.screen.upload.UploadMenuActivity;
import com.aurora.bdg.util.DataBaseHelper;
import com.aurora.bdg.util.DirUtil;
import com.aurora.bdg.util.GPSTracker;
import com.aurora.bdg.util.ImageUtility;
import com.aurora.bdg.util.LocalStorage;
import com.aurora.bdg.util.TimeUtil;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import org.greenrobot.greendao.query.WhereCondition;

/* JADX INFO: loaded from: classes.dex */
public class CatatStandFragment extends Fragment implements CatatConfirmDialogFragment.OnConfirmDialogListener {
    private static final String ARG_CUST_CODE = "cust-code";
    private static final String ARG_RESULT_OCR = "result-ocr";
    private static final String ARG_STATUS_READ = "status-read";
    static final int REQUEST_CAPTURE_ARORA = 1;
    static final int REQUEST_IMAGE_CAPTURE = 1;
    private static final String RUMAH = "rumah";
    private static final String SEGEL = "segel";
    private static final String STAND = "stand";
    private static String TAG = "CatatStand";
    private String alasan;
    AlasanDao alasanDao;
    private String alasanId;
    private int bebanTetap;
    private int biayaUkuranPipa;
    private String custCode;
    DaoSession daoSession;
    DataBaseHelper dataBaseHelper;

    @BindView(R.id.txt_kubikasi)
    EditText etKubikasi;

    @BindView(R.id.txt_nohp)
    EditText etNoHp;

    @BindView(R.id.txt_standakhir)
    EditText etStandAkhir;

    @BindView(R.id.txt_standawal)
    EditText etStandAwal;
    private int grandTotal;
    private String isSegel;

    @BindView(R.id.iv_rumah)
    ImageView ivRumah;

    @BindView(R.id.iv_segel)
    ImageView ivSegel;

    @BindView(R.id.iv_stand)
    ImageView ivStand;
    LocalStorage localStorage;
    String longlat;
    private OnFragmentCatatStandInteractionListener mListener;
    private String noHp;
    Pelanggan pelanggan;
    String period;
    private String perubahan;
    private String resultOcr;

    @BindView(R.id.sp_kelainan)
    Spinner spListAlasan;

    @BindView(R.id.sp_perubahan)
    Spinner spPerubahan;

    @BindView(R.id.sp_issegel)
    Spinner spSegel;
    private int stand1;
    private int stand2;
    private String standAkhir;
    private String statusRead;
    TarifDao tarifDao;
    String tempWaktuCatat;
    private int totalAir;
    private int totalHarga1;
    private int totalHarga2;
    private int totalHarga3;
    private int totalHarga4;

    @BindView(R.id.tv_pelanggan_address)
    TextView tvAddress;

    @BindView(R.id.tv_pelanggan_gol_tarif)
    TextView tvGolonganTarif;

    @BindView(R.id.tv_pelanggan_nama)
    TextView tvName;

    @BindView(R.id.tv_range_location)
    TextView tvRangeLocation;
    String typePhoto;
    private int usage;
    private int usageTemp;
    WaterTarifDao waterTarifDao;
    WmsizeDao wmsizeDao;
    DirUtil dirUtil = new DirUtil();
    TimeUtil timeUtil = new TimeUtil();
    ArrayList<Alasan> listAlasan = new ArrayList<>();
    private int marginMeter = 0;
    private int tax = 0;

    public interface OnFragmentCatatStandInteractionListener {
        void onFragmentCatatStandInteraction(DataMeter dataMeter, String str);
    }

    public static CatatStandFragment newInstance(String str, String str2, String str3) {
        CatatStandFragment catatStandFragment = new CatatStandFragment();
        Bundle bundle = new Bundle();
        bundle.putString("status-read", str2);
        bundle.putString("cust-code", str);
        bundle.putString("result-ocr", str3);
        catatStandFragment.setArguments(bundle);
        return catatStandFragment;
    }

    @Override // androidx.fragment.app.Fragment
    public void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        if (getArguments() != null) {
            this.custCode = getArguments().getString("cust-code");
            this.statusRead = getArguments().getString("status-read");
            this.resultOcr = getArguments().getString("result-ocr");
        }
        this.localStorage = new LocalStorage(getActivity());
        this.dataBaseHelper = DataBaseHelper.getInstance(getActivity());
        this.daoSession = ((App) getActivity().getApplication()).getDaoSession();
        this.alasanDao = this.daoSession.getAlasanDao();
        this.wmsizeDao = this.daoSession.getWmsizeDao();
        this.waterTarifDao = this.daoSession.getWaterTarifDao();
        this.tarifDao = this.daoSession.getTarifDao();
        this.pelanggan = this.dataBaseHelper.getPelanggan(this.custCode);
        if (this.pelanggan != null) {
            this.tempWaktuCatat = this.pelanggan.getWaktuCatat();
        }
        this.period = this.localStorage.getPeriodeY() + "" + this.localStorage.getPeriodeM();
    }

    @Override // androidx.fragment.app.Fragment
    public View onCreateView(LayoutInflater layoutInflater, ViewGroup viewGroup, Bundle bundle) {
        View viewInflate = layoutInflater.inflate(R.layout.fragment_catat_stand, viewGroup, false);
        ButterKnife.bind(this, viewInflate);
        return viewInflate;
    }

    @Override // androidx.fragment.app.Fragment
    public void onViewCreated(View view, @Nullable Bundle bundle) {
        super.onViewCreated(view, bundle);
        getLocation();
        if (isMaxReading()) {
            promtMaxUpload();
        }
        populateDataKelainan();
        if (isEmptyAlasan()) {
            promtEmptyAlasan();
        }
        if (this.pelanggan != null) {
            showInfoPelanggan();
        }
        setTakenPhoto();
        this.etStandAkhir.addTextChangedListener(new TextWatcher() { // from class: com.aurora.bdg.screen.catatStand.CatatStandFragment.1
            @Override // android.text.TextWatcher
            public void afterTextChanged(Editable editable) {
            }

            @Override // android.text.TextWatcher
            public void beforeTextChanged(CharSequence charSequence, int i, int i2, int i3) {
            }

            @Override // android.text.TextWatcher
            public void onTextChanged(CharSequence charSequence, int i, int i2, int i3) {
                if (CatatStandFragment.this.pelanggan.getBillStand1() != null && !charSequence.toString().equals("")) {
                    String string = CatatStandFragment.this.etStandAwal.getText().toString();
                    if (string.equals("")) {
                        string = "";
                    }
                    CatatStandFragment.this.etKubikasi.setText(String.valueOf(Long.valueOf(charSequence.toString()).longValue() - Long.valueOf(string).longValue()).replace("-", ""));
                    return;
                }
                CatatStandFragment.this.etKubikasi.setText("0");
            }
        });
    }

    @Override // androidx.fragment.app.Fragment
    public void onActivityResult(int i, int i2, Intent intent) {
        if (i == 1 && i2 == -1) {
            previewPhoto();
        } else if (i == 1 && i2 == -1) {
            previewPhoto();
        } else {
            Toast.makeText(getActivity(), "Gagal Memotret", 1).show();
            this.dirUtil.generateNoteOnSD("Gagal memotret");
        }
    }

    @Override // androidx.fragment.app.Fragment
    public void onResume() {
        super.onResume();
        if (this.pelanggan.getBillStand2() != null && !this.pelanggan.getBillStand2().equals("")) {
            this.etKubikasi.setText(String.valueOf(Integer.valueOf(this.pelanggan.getBillStand2()).intValue() - Integer.valueOf(this.pelanggan.getBillStand1()).intValue()).replace("-", ""));
        }
        checkGPS();
    }

    /* JADX WARN: Multi-variable type inference failed */
    @Override // androidx.fragment.app.Fragment
    public void onAttach(Context context) {
        super.onAttach(context);
        if (context instanceof OnFragmentCatatStandInteractionListener) {
            this.mListener = (OnFragmentCatatStandInteractionListener) context;
            return;
        }
        throw new RuntimeException(context.toString() + " must implement OnFragmentCatatStandInteractionListener");
    }

    @Override // androidx.fragment.app.Fragment
    public void onDetach() {
        super.onDetach();
        this.mListener = null;
    }

    @OnClick({R.id.btn_simpan})
    public void onClickSubmit() {
        if (isValidPhoto()) {
            this.standAkhir = this.etStandAkhir.getText().toString();
            this.noHp = this.etNoHp.getText().toString();
            this.alasan = this.listAlasan.get(this.spListAlasan.getSelectedItemPosition()).getAlName();
            this.alasanId = this.listAlasan.get(this.spListAlasan.getSelectedItemPosition()).getAlId();
            this.isSegel = this.spSegel.getSelectedItem().toString();
            this.perubahan = this.spPerubahan.getSelectedItem().toString();
            this.stand1 = Integer.parseInt(this.pelanggan.getBillStand1());
            if (isFilledStand2()) {
                this.stand2 = Integer.parseInt(this.standAkhir);
            } else if (this.alasanId.equals("-") && this.alasanId.equals(ExifInterface.GPS_MEASUREMENT_2D)) {
                this.stand2 = 0;
            }
            this.usage = this.stand2 - this.stand1;
            this.usageTemp = this.stand2 - this.stand1;
            calculateTagihan();
            if (!isFilledStand2()) {
                promtSaveWithoutStand2();
                return;
            }
            if (this.stand2 < this.stand1) {
                promtSaveStandNormal(2);
                return;
            } else if (this.stand2 >= this.stand1 + 100) {
                promtSaveStandNormal(1);
                return;
            } else {
                promtSaveStandNormal(0);
                return;
            }
        }
        Toast.makeText(getActivity(), "Silahkan lengkapi data/foto", 0).show();
    }

    @OnClick({R.id.btn_camera_ocr})
    public void onClickCameraOcr() {
        Intent intent = new Intent(getActivity(), (Class<?>) MainOcrActivity.class);
        intent.putExtra("cust-code", this.pelanggan.getCustCode123());
        intent.putExtra(MainOcrActivity.ARG_SCAN_QRCODE, false);
        intent.setFlags(67108864);
        startActivity(intent);
    }

    @OnClick({R.id.btn_camera_stand})
    public void onClickCameraStand() {
        this.typePhoto = "stand";
        dispatchTakePictureIntent("stand");
    }

    @OnClick({R.id.btn_camera_segel})
    public void onClickCameraSegel() {
        this.typePhoto = "segel";
        dispatchTakePictureIntent("segel");
    }

    @OnClick({R.id.btn_camera_rumah})
    public void onClickCameraRumah() {
        this.typePhoto = "rumah";
        dispatchTakePictureIntent("rumah");
    }

    @OnClick({R.id.cv_stand})
    public void onClickPreviewStand() {
        File file = new File(getDirPath(), getImagePath2("stand"));
        if (file.exists()) {
            Uri uriForFile = FileProvider.getUriForFile(getActivity(), "com.aurora.bdg.fileprovider", file);
            Intent intent = new Intent();
            intent.setAction("android.intent.action.VIEW");
            intent.setDataAndType(uriForFile, "image/*");
            intent.addFlags(3);
            startActivity(intent);
        }
    }

    @OnClick({R.id.cv_segel})
    public void onClickPreviewSegel() {
        File file = new File(getDirPath(), getImagePath2("segel"));
        if (file.exists()) {
            Uri uriForFile = FileProvider.getUriForFile(getActivity(), "com.aurora.bdg.fileprovider", file);
            Intent intent = new Intent();
            intent.setAction("android.intent.action.VIEW");
            intent.setDataAndType(uriForFile, "image/*");
            intent.addFlags(3);
            startActivity(intent);
        }
    }

    @OnClick({R.id.cv_rumah})
    public void onClickPreviewRumah() {
        File file = new File(getDirPath(), getImagePath2("rumah"));
        if (file.exists()) {
            Uri uriForFile = FileProvider.getUriForFile(getActivity(), "com.aurora.bdg.fileprovider", file);
            Intent intent = new Intent();
            intent.setAction("android.intent.action.VIEW");
            intent.setDataAndType(uriForFile, "image/*");
            intent.addFlags(3);
            startActivity(intent);
        }
    }

    public void promtSaveWithoutStand2() {
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        builder.setCancelable(false);
        builder.setTitle("Konfirmasi");
        builder.setMessage("Stand meteran tidak terisi, apakah anda akan tetap menyimpan? ");
        builder.setPositiveButton("Ya", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.catatStand.CatatStandFragment.2
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i) {
                CatatStandFragment.this.saveData();
            }
        });
        builder.setNegativeButton("Tidak", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.catatStand.CatatStandFragment.3
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i) {
            }
        });
        builder.show();
    }

    public void promtSaveStandNormal(int i) {
        CatatConfirmDialogFragment catatConfirmDialogFragmentNewInstance = CatatConfirmDialogFragment.newInstance(String.valueOf(this.stand2), String.valueOf(this.usageTemp), getImagePath("stand"), this.alasan, i, this.totalAir, this.bebanTetap, this.biayaUkuranPipa, this.grandTotal);
        catatConfirmDialogFragmentNewInstance.setTargetFragment(this, 100);
        catatConfirmDialogFragmentNewInstance.show(getFragmentManager(), "dialogConfirm");
    }

    public boolean isFilledStand2() {
        return !this.etStandAkhir.getText().toString().isEmpty();
    }

    public String getDirPath() {
        return Environment.getExternalStorageDirectory() + File.separator + this.dirUtil.dirName + File.separator;
    }

    public String getImagePath2(String str) {
        return str + File.separator + (this.period + "_" + str + "_" + this.custCode) + ".jpg";
    }

    public boolean isValidPhoto() {
        boolean zExists = new File(getImagePath("stand")).exists();
        if (!new File(getImagePath("segel")).exists()) {
            zExists = false;
        }
        if (new File(getImagePath("rumah")).exists()) {
            return zExists;
        }
        return false;
    }

    private void dispatchTakePictureIntent(String str) {
        File fileCreateImageFile;
        Intent intent = new Intent("android.media.action.IMAGE_CAPTURE");
        if (intent.resolveActivity(getActivity().getPackageManager()) != null) {
            try {
                fileCreateImageFile = createImageFile(str);
            } catch (IOException e) {
                e.printStackTrace();
                this.dirUtil.generateNoteOnSD("takePicture " + e.getMessage());
                fileCreateImageFile = null;
            }
            if (fileCreateImageFile != null) {
                intent.putExtra("output", FileProvider.getUriForFile(getActivity(), "com.aurora.bdg.fileprovider", fileCreateImageFile));
                startActivityForResult(intent, 1);
            } else {
                this.dirUtil.generateNoteOnSD("takePicture photoIsNull");
            }
        }
    }

    /* JADX WARN: Code duplicated, block: B:18:0x0034  */
    public void previewPhoto() {
        switch (this.typePhoto) {
            case "stand":
                editPhoto("stand");
                this.ivStand.setImageBitmap(BitmapFactory.decodeFile(getImagePath("stand")));
                break;
            case "segel":
                editPhoto("segel");
                this.ivSegel.setImageBitmap(BitmapFactory.decodeFile(getImagePath("segel")));
                break;
            case "rumah":
                editPhoto("rumah");
                this.ivRumah.setImageBitmap(BitmapFactory.decodeFile(getImagePath("rumah")));
                break;
        }
    }

    public void showInfoPelanggan() {
        this.tvName.setText(this.pelanggan.getCustCode123() + " - " + this.pelanggan.getCustName());
        this.tvAddress.setText(this.pelanggan.getAlamat());
        this.etNoHp.setText(this.pelanggan.getNoHp());
        this.tvGolonganTarif.setText(this.pelanggan.getTarif());
        this.etStandAwal.setText(this.pelanggan.getBillStand1());
        if (this.pelanggan.getBillStand2() != null) {
            this.etStandAkhir.setText(this.pelanggan.getBillStand2());
        }
        if (this.resultOcr != null) {
            this.etStandAkhir.setText(String.valueOf(Integer.valueOf(this.resultOcr).intValue()));
        }
    }

    public void setTakenPhoto() {
        File file = new File(getImagePath("stand"));
        if (file.exists()) {
            editPhoto("stand");
            this.ivStand.setImageBitmap(BitmapFactory.decodeFile(file.getAbsolutePath()));
        }
        File file2 = new File(getImagePath("segel"));
        if (file2.exists()) {
            this.ivSegel.setImageBitmap(BitmapFactory.decodeFile(file2.getAbsolutePath()));
        }
        File file3 = new File(getImagePath("rumah"));
        if (file3.exists()) {
            this.ivRumah.setImageBitmap(BitmapFactory.decodeFile(file3.getAbsolutePath()));
        }
    }

    private File createImageFile(String str) throws IOException {
        return new File(getImagePath(str));
    }

    public String getImagePath(String str) {
        return Environment.getExternalStorageDirectory() + File.separator + this.dirUtil.dirName + File.separator + str + File.separator + (this.period + "_" + str + "_" + this.custCode) + ".jpg";
    }

    public void editPhoto(String str) {
        ImageUtility.compressPhoto(getActivity(), getImagePath(str), this.localStorage.getUserName());
    }

    public void saveData() {
        DataMeter dataMeter = new DataMeter();
        dataMeter.setTglCatat(this.timeUtil.dateNow());
        dataMeter.setWaktuCatat(this.timeUtil.timeNow());
        dataMeter.setBillStand1(this.pelanggan.getBillStand1());
        dataMeter.setBillStand2(String.valueOf(this.stand2));
        dataMeter.setBillPakai(String.valueOf(this.usage));
        dataMeter.setBillUangair(String.valueOf(this.totalAir));
        dataMeter.setBillUangadm(String.valueOf(this.biayaUkuranPipa));
        dataMeter.setBillUangtax(String.valueOf(0));
        dataMeter.setBillNohp(this.noHp);
        dataMeter.setParam1(this.statusRead);
        dataMeter.setBillAlCode(this.alasanId);
        dataMeter.setBillAlname(this.alasan);
        dataMeter.setBillWrUsername(this.localStorage.getUserName());
        dataMeter.setBillIsUpload("1");
        dataMeter.setBillIsrequest(ExifInterface.GPS_MEASUREMENT_2D);
        dataMeter.setBillLonglat(this.longlat);
        dataMeter.setBill_issegel(this.isSegel);
        dataMeter.setBill_perubahan(this.perubahan);
        dataMeter.setBillNourutrute(this.pelanggan.getBillNoUrutRute());
        dataMeter.setMarginMeter(String.valueOf(this.marginMeter));
        if (this.dataBaseHelper.updateStandNormal(dataMeter, this.pelanggan.getBillId())) {
            Toast.makeText(getActivity(), "Catat Berhasil", 0).show();
            this.dirUtil.catatTxt(this.custCode + "|" + this.pelanggan.getBillId() + "|" + this.stand2 + "|" + this.alasanId + "|" + this.localStorage.getUserName() + "|" + this.longlat + "|" + this.timeUtil.timeNow() + "|");
            onButtonPressed(dataMeter, this.tempWaktuCatat);
            return;
        }
        Toast.makeText(getActivity(), "Fail", 0).show();
        this.dirUtil.generateNoteOnSD("catatStand: Gagal mencatat");
    }

    public void calculateTagihan() {
        WaterTarif waterTarif = this.waterTarifDao.queryBuilder().where(WaterTarifDao.Properties.TrfTypeId.eq(this.pelanggan.getTarif()), new WhereCondition[0]).list().get(0);
        List<Tarif> list = this.tarifDao.queryBuilder().where(TarifDao.Properties.TrfCode.eq(this.pelanggan.getTarif()), new WhereCondition[0]).list();
        if (list.size() > 0) {
            list.get(0);
        }
        Wmsize wmsize = null;
        List<Wmsize> list2 = this.pelanggan.getBillKdWmsizeid() != null ? this.wmsizeDao.queryBuilder().where(WmsizeDao.Properties.WmzCode.eq(this.pelanggan.getBillKdWmsizeid()), new WhereCondition[0]).list() : null;
        if (list2 != null && list2.size() > 0) {
            wmsize = list2.get(0);
        }
        int i = Integer.parseInt(waterTarif.getWtCost1());
        int i2 = Integer.parseInt(waterTarif.getWtCost2());
        int i3 = Integer.parseInt(waterTarif.getWtCost3());
        int i4 = Integer.parseInt(waterTarif.getWtCost4());
        int i5 = Integer.parseInt(waterTarif.getWtTop1());
        int i6 = Integer.parseInt(waterTarif.getWtTop2());
        int i7 = Integer.parseInt(waterTarif.getWtTop3());
        int i8 = Integer.parseInt(waterTarif.getWtTop4());
        this.bebanTetap = 0;
        if (wmsize != null) {
            this.biayaUkuranPipa = Integer.parseInt(wmsize.getBiPemel());
        } else {
            this.biayaUkuranPipa = 0;
        }
        if (this.usage <= i5) {
            this.totalHarga1 = this.usage * i;
            this.totalHarga2 = 0;
            this.totalHarga3 = 0;
            this.totalHarga4 = 0;
        } else if (this.usage <= i6) {
            this.totalHarga1 = i * i5;
            this.totalHarga2 = i2 * (this.usage - i5);
            this.totalHarga3 = 0;
            this.totalHarga4 = 0;
        } else if (this.usage <= i7) {
            this.totalHarga1 = i * i5;
            this.totalHarga2 = i2 * (i6 - i5);
            this.totalHarga3 = i3 * (this.usage - i6);
            this.totalHarga4 = 0;
        } else if (this.usage <= i8) {
            this.totalHarga1 = i * i5;
            this.totalHarga2 = i2 * (i6 - i5);
            this.totalHarga3 = i3 * (i7 - i6);
            this.totalHarga4 = i4 * (this.usage - i7);
        }
        this.totalAir = this.totalHarga1 + this.totalHarga2 + this.totalHarga3 + this.totalHarga4;
        this.grandTotal = this.totalAir + this.bebanTetap + this.biayaUkuranPipa;
        if (this.grandTotal > 1000000) {
            this.tax = 6000;
        } else if (this.grandTotal > 250000) {
            this.tax = PathInterpolatorCompat.MAX_NUM_POINTS;
        }
        this.grandTotal += this.tax;
    }

    public void populateDataKelainan() {
        this.listAlasan.addAll(this.alasanDao.loadAll());
        this.spListAlasan.setAdapter((SpinnerAdapter) new ArrayAdapter(getActivity(), android.R.layout.simple_list_item_1, this.listAlasan));
        this.spListAlasan.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() { // from class: com.aurora.bdg.screen.catatStand.CatatStandFragment.4
            @Override // android.widget.AdapterView.OnItemSelectedListener
            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long j) {
            }

            @Override // android.widget.AdapterView.OnItemSelectedListener
            public void onNothingSelected(AdapterView<?> adapterView) {
            }
        });
    }

    private void promtMaxUpload() {
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        builder.setCancelable(false);
        builder.setTitle("Jumlah Catat Melebihi 500");
        builder.setMessage("Silahkan UPLOAD untuk melanjutkan pencatatan");
        builder.setPositiveButton("Upload", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.catatStand.CatatStandFragment.5
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i) {
                Intent intent = new Intent(CatatStandFragment.this.getActivity(), (Class<?>) UploadMenuActivity.class);
                intent.setFlags(67141632);
                CatatStandFragment.this.startActivity(intent);
                CatatStandFragment.this.getActivity().finish();
            }
        });
        builder.show();
    }

    public boolean isMaxReading() {
        return this.dataBaseHelper.getNotUpload(this.localStorage.getUserName()) > 500;
    }

    private boolean isEmptyAlasan() {
        return this.alasanDao.count() == 0;
    }

    private void promtEmptyAlasan() {
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        builder.setTitle("Kelainan Kosong");
        builder.setMessage("Silahkan Download Kelainan");
        builder.setPositiveButton("Download Kelainan", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.catatStand.CatatStandFragment.6
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i) {
                Intent intent = new Intent(CatatStandFragment.this.getActivity(), (Class<?>) DownloadDataActivity.class);
                intent.setFlags(67108864);
                CatatStandFragment.this.startActivity(intent);
                CatatStandFragment.this.getActivity().finish();
            }
        });
        builder.setCancelable(false);
        builder.show();
    }

    public void checkGPS() {
        GPSTracker gPSTracker = new GPSTracker(getActivity());
        if (gPSTracker.canGetLocation()) {
            return;
        }
        gPSTracker.showSettingsAlert();
    }

    public void getLocation() {
        GPSTracker gPSTracker = new GPSTracker(getActivity());
        if (gPSTracker.canGetLocation()) {
            this.longlat = gPSTracker.getLatitude() + "," + gPSTracker.getLongitude();
            return;
        }
        gPSTracker.showSettingsAlert();
    }

    private void calculateRangeLocation(double d, double d2) {
        Location location = new Location("currentLocation");
        location.setLatitude(d);
        location.setLongitude(d2);
        String[] strArrSplit = this.pelanggan.getBillLonglat().split(",");
        Location location2 = new Location("prevLocation");
        location2.setLongitude(Double.parseDouble(strArrSplit[1]));
        location2.setLatitude(Double.parseDouble(strArrSplit[0]));
        Log.i(TAG, "calculateRangeLocation: " + d + " " + d2);
        float fDistanceTo = location.distanceTo(location2);
        this.marginMeter = Math.round(fDistanceTo);
        Log.i(TAG, "calculateRangeLocation: distanc e" + fDistanceTo + " meter" + this.marginMeter);
        StringBuilder sb = new StringBuilder();
        sb.append(this.marginMeter);
        sb.append(" Meter(selisih jarak)");
        this.tvRangeLocation.setText(sb.toString());
    }

    public void onButtonPressed(DataMeter dataMeter, String str) {
        if (this.mListener != null) {
            this.mListener.onFragmentCatatStandInteraction(dataMeter, str);
        }
    }

    @Override // com.aurora.bdg.screen.catatStand.CatatConfirmDialogFragment.OnConfirmDialogListener
    public void onSaveConfirmDialog() {
        saveData();
    }
}
