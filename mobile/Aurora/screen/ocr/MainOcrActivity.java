package com.aurora.bdg.screen.ocr;

import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;
import android.widget.ImageButton;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.aurora.bdg.R;
import com.aurora.bdg.model.Pelanggan;
import com.aurora.bdg.model.ThreeMonth;
import com.aurora.bdg.screen.catatStand.CatatStandActivity;
import com.aurora.bdg.util.DataBaseHelper;
import com.aurora.bdg.util.ImageUtility;
import com.aurora.bdg.util.LocalStorage;
import com.aurora.bdg.util.barcodeScanner.ZBarConstants;
import com.googlecode.tesseract.android.TessBaseAPI;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;
import java.util.List;
import net.sourceforge.zbar.Image;
import net.sourceforge.zbar.ImageScanner;
import net.sourceforge.zbar.Symbol;
import org.opencv.android.BaseLoaderCallback;
import org.opencv.android.CameraBridgeViewBase;
import org.opencv.android.OpenCVLoader;
import org.opencv.android.Utils;
import org.opencv.core.Core;
import org.opencv.core.CvType;
import org.opencv.core.Mat;
import org.opencv.core.MatOfPoint;
import org.opencv.core.Point;
import org.opencv.core.Rect;
import org.opencv.core.Scalar;
import org.opencv.imgcodecs.Imgcodecs;
import org.opencv.imgproc.Imgproc;

/* JADX INFO: loaded from: classes.dex */
public class MainOcrActivity extends AppCompatActivity implements CameraBridgeViewBase.CvCameraViewListener2, ZBarConstants {
    public static final String ARG_CUST_CODE123 = "cust-code";
    public static final String ARG_SCAN_QRCODE = "scan-qrcode";
    private static final String OCR = "OCR";
    private static final String STAND = "stand";
    private static final String TAG = "OCR";
    String barcode;
    String custCode;
    DataBaseHelper dataBaseHelper;

    @BindView(R.id.btn_flash)
    ImageButton flashButton;
    Mat globMat;
    Bitmap indexMeter;
    LocalStorage localStorage;
    private PDAMCameraView mOpenCvCameraView;
    private ImageScanner mScanner;
    private TessBaseAPI mTess;
    Pelanggan pelanggan;
    String period;
    String language = "eng";
    private final int TIME_OUT = 5;
    private final int MIN_WIDTH = 20;
    private final int MAX_WIDTH = 35;
    private final int MIN_HEIGHT = 9;
    private final int MAX_HEIGHT = 31;
    private final int MIN_DISTANCE = 20;
    private final int MAX_DISTANCE = 30;
    private final int MIN_LINE = Imgproc.COLOR_BGRA2YUV_YV12;
    private final int MAX_LINE = 140;
    String datapath = "";
    boolean scanQrcode = true;
    boolean stateFlash = false;
    Handler handler = new Handler();
    private Runnable runnableCode = new Runnable() { // from class: com.aurora.bdg.screen.ocr.MainOcrActivity.1
        @Override // java.lang.Runnable
        public void run() {
            if (MainOcrActivity.this.custCode != null) {
                Imgcodecs.imwrite(MainOcrActivity.this.getImagePath("stand"), MainOcrActivity.this.globMat);
                MainOcrActivity.this.stateFail();
            }
        }
    };
    private BaseLoaderCallback mLoaderCallback = new BaseLoaderCallback(this) { // from class: com.aurora.bdg.screen.ocr.MainOcrActivity.4
        @Override // org.opencv.android.BaseLoaderCallback, org.opencv.android.LoaderCallbackInterface
        public void onManagerConnected(int i) {
            if (i == 0) {
                MainOcrActivity.this.mOpenCvCameraView.setMaxFrameSize(720, 480);
                MainOcrActivity.this.mOpenCvCameraView.enableView();
                MainOcrActivity.this.mOpenCvCameraView.disableFpsMeter();
                MainOcrActivity.this.mOpenCvCameraView.setFocusDelay();
                return;
            }
            super.onManagerConnected(i);
        }
    };

    private char convertNumber(char c) {
        char c2 = (c == '&' || c == 'A') ? '4' : ' ';
        if (c == 'b') {
            c2 = '5';
        }
        if (c == 'Z') {
            return '2';
        }
        return c2;
    }

    private boolean isValidNumber(char c) {
        return c == '1' || c == '2' || c == '3' || c == '4' || c == '5' || c == '6' || c == '7' || c == '8' || c == '9' || c == '0';
    }

    @Override // org.opencv.android.CameraBridgeViewBase.CvCameraViewListener2
    public void onCameraViewStarted(int i, int i2) {
    }

    @Override // org.opencv.android.CameraBridgeViewBase.CvCameraViewListener2
    public void onCameraViewStopped() {
    }

    @Override // androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setContentView(R.layout.activity_main_ocr);
        ButterKnife.bind(this);
        this.scanQrcode = true;
        if (getIntent() != null) {
            Intent intent = getIntent();
            this.custCode = intent.getStringExtra("cust-code");
            this.scanQrcode = intent.getBooleanExtra(ARG_SCAN_QRCODE, true);
        }
        setupScanner();
        this.dataBaseHelper = DataBaseHelper.getInstance(this);
        this.localStorage = new LocalStorage(this);
        getWindow().getDecorView().setSystemUiVisibility(4);
        this.mOpenCvCameraView = (PDAMCameraView) findViewById(R.id.tutorial1_activity_java_surface_view);
        this.mOpenCvCameraView.setVisibility(0);
        this.mOpenCvCameraView.setCvCameraViewListener(this);
        this.period = this.localStorage.getPeriodeY() + "" + this.localStorage.getPeriodeM();
        this.handler.postDelayed(this.runnableCode, 5000L);
    }

    @Override // androidx.fragment.app.FragmentActivity, android.app.Activity
    public void onPause() {
        super.onPause();
        if (this.mOpenCvCameraView != null) {
            this.mOpenCvCameraView.disableView();
        }
    }

    @Override // androidx.fragment.app.FragmentActivity, android.app.Activity
    public void onResume() {
        super.onResume();
        if (!OpenCVLoader.initDebug()) {
            Log.d("OCR", "Internal OpenCV library not found. Using OpenCV Manager for initialization");
            OpenCVLoader.initAsync(OpenCVLoader.OPENCV_VERSION_3_0_0, this, this.mLoaderCallback);
        } else {
            Log.d("OCR", "OpenCV library found inside package. Using it!");
            this.mLoaderCallback.onManagerConnected(0);
        }
    }

    @OnClick({R.id.btn_flash})
    public void onClickFlash() {
        if (this.stateFlash) {
            this.mOpenCvCameraView.flashOn();
            this.stateFlash = false;
            this.flashButton.setBackground(getDrawable(R.drawable.ic_lampu_rotate_disable));
        } else {
            this.mOpenCvCameraView.flashOff();
            this.stateFlash = true;
            this.flashButton.setBackground(getDrawable(R.drawable.ic_lampu_rotate));
        }
    }

    @Override // androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, android.app.Activity
    public void onDestroy() {
        super.onDestroy();
        if (this.mOpenCvCameraView != null) {
            this.mOpenCvCameraView.disableView();
        }
        this.handler.removeCallbacks(this.runnableCode);
    }

    private File createImageFile(String str) throws IOException {
        return new File(getImagePath(str));
    }

    public String getImagePath(String str) {
        return Environment.getExternalStorageDirectory() + File.separator + ImageUtility.dirUtil.dirName + File.separator + str + File.separator + (this.period + "_" + str + "_" + this.custCode) + ".jpg";
    }

    private File createImageTemp(String str) throws IOException {
        return new File(getImagePath(getImagePathTemp(str)));
    }

    public String getImagePathTemp(String str) {
        return Environment.getExternalStorageDirectory() + File.separator + ImageUtility.dirUtil.dirName + File.separator + str + File.separator + (this.period + "_" + str + "_" + this.custCode) + "_ocr.jpg";
    }

    private int loadThreeMonth(String str) {
        ThreeMonth threeMonth = this.dataBaseHelper.getThreeMonth(str);
        if (threeMonth == null) {
            return 0;
        }
        int iIntValue = Integer.valueOf(threeMonth.getPeriod1Usage()).intValue();
        int iIntValue2 = Integer.valueOf(threeMonth.getPeriod2Usage()).intValue();
        return Integer.valueOf(threeMonth.getPeriod1Stand2()).intValue() + (((iIntValue + iIntValue2) + Integer.valueOf(threeMonth.getPeriod3Usage()).intValue()) / 3);
    }

    /* JADX WARN: Unreachable blocks removed: 2, instructions: 2 */
    @Override // org.opencv.android.CameraBridgeViewBase.CvCameraViewListener2
    public Mat onCameraFrame(CameraBridgeViewBase.CvCameraViewFrame cvCameraViewFrame) {
        int i;
        System.gc();
        Mat matClone = cvCameraViewFrame.rgba().clone();
        Imgproc.cvtColor(matClone, matClone, 2);
        this.globMat = matClone;
        Core.rotate(matClone, matClone, 0);
        Mat matClone2 = cvCameraViewFrame.gray().clone();
        Mat matClone3 = cvCameraViewFrame.rgba().clone();
        if (this.scanQrcode) {
            byte[] bArr = new byte[(int) (matClone2.total() * ((long) matClone2.channels()))];
            matClone2.get(0, 0, bArr);
            Image image = new Image(matClone2.width(), matClone2.height(), "Y800");
            image.setData(bArr);
            if (this.mScanner.scanImage(image) != 0) {
                Iterator<Symbol> it = this.mScanner.getResults().iterator();
                while (it.hasNext()) {
                    String data = it.next().getData();
                    if (!TextUtils.isEmpty(data)) {
                        this.custCode = data;
                        Log.i("OCR", "barcode: " + data);
                        break;
                    }
                }
            }
        }
        Imgproc.rectangle(matClone3, new Point(100.0d, 90.0d), new Point(175.0d, 390.0d), new Scalar(255.0d, 255.0d, 255.0d), 2);
        int i2 = 90;
        int i3 = 100;
        Mat matClone4 = matClone2.submat(90, 390, 100, 175).clone();
        Imgproc.Laplacian(matClone4, matClone4, CvType.CV_8UC3);
        Imgproc.threshold(matClone4, matClone4, 19.0d, 255.0d, 0);
        ArrayList arrayList = new ArrayList();
        ArrayList arrayList2 = new ArrayList();
        Imgproc.findContours(matClone4, arrayList, new Mat(), 0, 1);
        ArrayList arrayList3 = new ArrayList();
        Iterator it2 = arrayList.iterator();
        int i4 = 0;
        while (it2.hasNext()) {
            Rect rectBoundingRect = Imgproc.boundingRect((MatOfPoint) it2.next());
            int i5 = rectBoundingRect.x + i3;
            int i6 = rectBoundingRect.y + i2;
            if (rectBoundingRect.height <= 9 || rectBoundingRect.height >= 31 || rectBoundingRect.width <= 20 || rectBoundingRect.width >= 35 || rectBoundingRect.width <= rectBoundingRect.height) {
                i = i4;
            } else {
                arrayList3.add(rectBoundingRect);
                arrayList2.add(arrayList.get(i4));
                i = i4;
                Imgproc.rectangle(matClone3, new Point(i5, i6), new Point(i5 + rectBoundingRect.width, i6 + rectBoundingRect.height), new Scalar(128.0d, 255.0d, 0.0d, 0.0d), 1, 8, 0);
            }
            i4 = i + 1;
            arrayList3 = arrayList3;
            arrayList2 = arrayList2;
            arrayList = arrayList;
            i2 = 90;
            i3 = 100;
        }
        ArrayList arrayList4 = arrayList2;
        boolean z = true;
        List<Rect> listSortRects = sortRects(arrayList3);
        ArrayList arrayList5 = new ArrayList();
        for (int i7 = 0; i7 < listSortRects.size(); i7++) {
            arrayList5.add(Integer.valueOf(listSortRects.get(i7).y + (listSortRects.get(i7).width / 2)));
        }
        if (arrayList5.size() < 4) {
            z = false;
            break;
        }
        int i8 = 0;
        while (i8 < 3) {
            int i9 = i8 + 1;
            if (((Integer) arrayList5.get(i9)).intValue() - ((Integer) arrayList5.get(i8)).intValue() < 20 || ((Integer) arrayList5.get(i9)).intValue() - ((Integer) arrayList5.get(i8)).intValue() > 30) {
                z = false;
                break;
            }
            i8 = i9;
        }
        Iterator it3 = arrayList4.iterator();
        int i10 = 0;
        while (it3.hasNext()) {
            Rect rectBoundingRect2 = Imgproc.boundingRect((MatOfPoint) it3.next());
            int i11 = rectBoundingRect2.x + 100;
            if (134 > i11 && i11 + rectBoundingRect2.width > 140) {
                i10++;
            }
        }
        Mat matZeros = Mat.zeros(matClone4.rows() + 2, matClone4.cols() + 2, 0);
        Imgproc.drawContours(matZeros, arrayList4, -1, new Scalar(255.0d, 255.0d, 255.0d));
        if (i10 >= 4 && z) {
            try {
                createImageFile("stand");
            } catch (IOException e) {
                e.printStackTrace();
            }
            try {
                createImageTemp("OCR");
            } catch (IOException e2) {
                e2.printStackTrace();
            }
            Core.rotate(matZeros, matZeros, 0);
            this.indexMeter = Bitmap.createBitmap(matZeros.width(), matZeros.height(), Bitmap.Config.ARGB_8888);
            Utils.matToBitmap(matZeros, this.indexMeter);
            Imgcodecs.imwrite(getImagePath("stand"), matClone);
            Imgcodecs.imwrite(getImagePathTemp("OCR"), matZeros);
            new Handler(Looper.getMainLooper()).post(new Runnable() { // from class: com.aurora.bdg.screen.ocr.MainOcrActivity.2
                @Override // java.lang.Runnable
                public void run() {
                    MainOcrActivity.this.mOpenCvCameraView.disableView();
                    if (MainOcrActivity.this.isAvailableCustomer(MainOcrActivity.this.custCode)) {
                        MainOcrActivity.this.matchingReceiver();
                        return;
                    }
                    try {
                        new File(MainOcrActivity.this.getImagePath("stand")).delete();
                    } catch (Exception e3) {
                        e3.printStackTrace();
                    }
                    MainOcrActivity.this.promtPelangganNotFound();
                }
            });
        }
        return matClone3;
    }

    public static List<Rect> sortRects(List<Rect> list) {
        Collections.sort(list, new Comparator<Rect>() { // from class: com.aurora.bdg.screen.ocr.MainOcrActivity.3
            @Override // java.util.Comparator
            public int compare(Rect rect, Rect rect2) {
                return rect.y - rect2.y;
            }
        });
        return list;
    }

    public void matchingReceiver() {
        Bitmap bitmap = this.indexMeter;
        this.datapath = getFilesDir() + "/";
        this.mTess = new TessBaseAPI();
        this.mTess.setVariable(TessBaseAPI.VAR_CHAR_BLACKLIST, "!?@#$%&*()<>_-+=/:;'\"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz");
        this.mTess.setVariable(TessBaseAPI.VAR_CHAR_WHITELIST, ".,0123456789");
        checkFile(new File(this.datapath + "tessdata/"));
        this.mTess.init(this.datapath, this.language);
        this.mTess.setImage(bitmap);
        String uTF8Text = this.mTess.getUTF8Text();
        Log.i("OCR", "matchingReceiver: resultOriginal:" + uTF8Text);
        String string = convertString(uTF8Text).toString();
        Log.i("OCR", "matchingReceiver: convertString:" + string);
        String strValidateNumber = validateNumber(string);
        Log.i("OCR", "matchingReceiver: final:" + strValidateNumber);
        ImageUtility.dirUtil.generateOcr("original: " + uTF8Text);
        ImageUtility.dirUtil.generateOcr("convert: " + string);
        ImageUtility.dirUtil.generateOcr("final: " + strValidateNumber);
        if (strValidateNumber.length() >= 4) {
            stateSuccess(strValidateNumber);
        } else {
            stateFail();
        }
    }

    public boolean isAvailableCustomer(String str) {
        this.pelanggan = this.dataBaseHelper.searchPelanggan(this.localStorage.getUserName(), this.custCode, this.localStorage.getPeriodeY(), this.localStorage.getPeriodeM());
        return this.pelanggan != null;
    }

    public void stateSuccess(String str) {
        this.handler.removeCallbacks(this.runnableCode);
        Intent intent = new Intent(this, (Class<?>) CatatStandActivity.class);
        intent.putExtra(CatatStandActivity.ARG_CUST_CODE_ID, this.pelanggan.getCustCode123());
        intent.putExtra(CatatStandActivity.ARG_STATUS_READ, getString(R.string.onestep));
        intent.putExtra(CatatStandActivity.ARG_RESULT_OCR, str);
        intent.setFlags(67108864);
        startActivity(intent);
        finish();
    }

    public void stateFail() {
        int iLoadThreeMonth = loadThreeMonth(this.custCode);
        this.handler.removeCallbacks(this.runnableCode);
        Intent intent = new Intent(this, (Class<?>) CatatStandActivity.class);
        intent.putExtra(CatatStandActivity.ARG_CUST_CODE_ID, this.custCode);
        intent.putExtra(CatatStandActivity.ARG_RESULT_OCR, String.valueOf(iLoadThreeMonth));
        intent.setFlags(67108864);
        startActivity(intent);
        finish();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void promtPelangganNotFound() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Silahkan Scan ulang");
        builder.setCancelable(false);
        builder.setPositiveButton("Scan ulang", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.ocr.MainOcrActivity.5
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i) {
                MainOcrActivity.this.mOpenCvCameraView.enableView();
            }
        });
        builder.setNegativeButton("Keluar", new DialogInterface.OnClickListener() { // from class: com.aurora.bdg.screen.ocr.MainOcrActivity.6
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialogInterface, int i) {
                MainOcrActivity.this.finish();
            }
        });
        builder.show();
    }

    private String validateNumber(String str) {
        String str2 = "";
        for (int i = 0; i < str.length(); i++) {
            if (isValidNumber(str.charAt(i))) {
                str2 = str2 + str.charAt(i);
            }
        }
        return str2;
    }

    private StringBuilder convertString(String str) {
        char c;
        StringBuilder sb = new StringBuilder(str);
        for (int i = 0; i < str.length(); i++) {
            char cCharAt = str.charAt(i);
            if (cCharAt == '&' || cCharAt == 'A') {
                c = '4';
            } else if (cCharAt == 'b') {
                c = '5';
            } else {
                c = cCharAt == 'Z' ? '2' : ' ';
            }
            if (c != ' ') {
                sb.setCharAt(i, c);
            }
        }
        return sb;
    }

    public void setupScanner() {
        this.mScanner = new ImageScanner();
        this.mScanner.setConfig(0, 256, 3);
        this.mScanner.setConfig(0, 257, 3);
        int[] intArrayExtra = getIntent().getIntArrayExtra(ZBarConstants.SCAN_MODES);
        if (intArrayExtra != null) {
            this.mScanner.setConfig(0, 0, 0);
            for (int i : intArrayExtra) {
                this.mScanner.setConfig(i, 0, 1);
            }
        }
    }

    private void checkFile(File file) {
        if (!file.exists() && file.mkdirs()) {
            copyFiles();
        }
        if (file.exists()) {
            if (new File(this.datapath + "/tessdata/" + this.language + ".traineddata").exists()) {
                return;
            }
            copyFiles();
        }
    }

    private void copyFiles() {
        try {
            String str = this.datapath + "/tessdata/" + this.language + ".traineddata";
            InputStream inputStreamOpen = getAssets().open("tessdata/" + this.language + ".traineddata");
            FileOutputStream fileOutputStream = new FileOutputStream(str);
            byte[] bArr = new byte[1024];
            while (true) {
                int i = inputStreamOpen.read(bArr);
                if (i == -1) {
                    break;
                } else {
                    fileOutputStream.write(bArr, 0, i);
                }
            }
            fileOutputStream.flush();
            fileOutputStream.close();
            inputStreamOpen.close();
            if (new File(str).exists()) {
            } else {
                throw new FileNotFoundException();
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e2) {
            e2.printStackTrace();
        }
    }
}
