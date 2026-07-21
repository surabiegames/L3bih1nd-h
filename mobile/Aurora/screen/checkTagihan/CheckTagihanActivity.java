package com.aurora.bdg.screen.checkTagihan;

import android.app.ProgressDialog;
import android.os.AsyncTask;
import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import androidx.cardview.widget.CardView;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.aurora.bdg.R;
import com.aurora.bdg.api.ApiFactory;
import com.aurora.bdg.model.Pdam;
import com.aurora.bdg.model.PdamRincian;
import com.aurora.bdg.response.ResponseJson;
import com.aurora.bdg.response.ResponsePdam;
import com.aurora.bdg.response.Result;
import com.aurora.bdg.util.MCrypt;
import java.io.IOException;
import java.util.Iterator;
import retrofit2.Response;

/* JADX INFO: loaded from: classes.dex */
public class CheckTagihanActivity extends AppCompatActivity {

    @BindView(R.id.btn_inquiry_pdam)
    Button btnInquiry;
    String customerId;

    @BindView(R.id.layout_result)
    CardView cvLayoutResult;

    @BindView(R.id.et_pelanggan_id)
    EditText etIdPelanggan;
    MCrypt mCrypt = new MCrypt();
    ProgressDialog progressDialog;

    @BindView(R.id.table_list_inquiry)
    TableLayout tableLayout;

    @BindView(R.id.tr_denda)
    TableRow trDenda;

    @BindView(R.id.tv_pdam_alamat)
    TextView tvAlamat;

    @BindView(R.id.tv_pdam_alamat_title)
    TextView tvAlamatTitle;

    @BindView(R.id.tv_pdam_date)
    TextView tvDate;

    @BindView(R.id.tv_pdam_denda)
    TextView tvDenda;

    @BindView(R.id.tv_pdam_nama_pdam)
    TextView tvNamaPdam;

    @BindView(R.id.tv_pdam_nama)
    TextView tvNamaPelanggan;

    @BindView(R.id.tv_pdam_no_pelanggan)
    TextView tvNoPelanggan;

    @BindView(R.id.tv_pdam_no_resi)
    TextView tvNoResi;

    @BindView(R.id.tv_pdam_pemakaian)
    TextView tvPemakaian;

    @BindView(R.id.tv_pdam_pemakaian_title)
    TextView tvPemakaianTitle;

    @BindView(R.id.tv_pdam_tagihan)
    TextView tvTagihan;

    @BindView(R.id.tv_pdam_total)
    TextView tvTotal;

    @Override // androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setContentView(R.layout.activity_check_tagihan);
        this.progressDialog = new ProgressDialog(this);
        getSupportActionBar().setSubtitle("Cek Tagihan");
        ButterKnife.bind(this);
    }

    @OnClick({R.id.btn_inquiry_pdam})
    public void onClickInquery() {
        this.customerId = this.etIdPelanggan.getText().toString();
        if (this.customerId.isEmpty()) {
            return;
        }
        new InqueryPdamAsynTask().execute(new Void[0]);
    }

    private class InqueryPdamAsynTask extends AsyncTask<Void, Integer, ResponsePdam> {
        private InqueryPdamAsynTask() {
        }

        @Override // android.os.AsyncTask
        protected void onPreExecute() {
            super.onPreExecute();
            CheckTagihanActivity.this.progressDialog.setMessage(CheckTagihanActivity.this.getString(R.string.progess_dialog_title));
            CheckTagihanActivity.this.progressDialog.show();
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public void onPostExecute(ResponsePdam responsePdam) {
            int iIntValue;
            super.onPostExecute(responsePdam);
            CheckTagihanActivity.this.progressDialog.dismiss();
            if (responsePdam != null && responsePdam.getError().equals("0")) {
                if (responsePdam.getData().getsTATUS().equals("00")) {
                    Pdam data = responsePdam.getData();
                    CheckTagihanActivity.this.cvLayoutResult.setVisibility(0);
                    CheckTagihanActivity.this.tvDate.setText(": " + data.gettANGGAL());
                    CheckTagihanActivity.this.tvNoResi.setText(": " + data.getnORESI());
                    CheckTagihanActivity.this.tvNamaPdam.setText(": " + data.getnAMAPAM());
                    CheckTagihanActivity.this.tvNoPelanggan.setText(": " + data.getnOPELANGGAN());
                    CheckTagihanActivity.this.tvNamaPelanggan.setText(": " + data.getnAMA());
                    if (data.getaLAMAT().length() == 0) {
                        CheckTagihanActivity.this.tvAlamat.setVisibility(8);
                        CheckTagihanActivity.this.tvAlamatTitle.setVisibility(8);
                    } else {
                        CheckTagihanActivity.this.tvAlamat.setText(": " + data.getaLAMAT());
                    }
                    if (data.getpEMAKAIAN().equals("0 M3")) {
                        CheckTagihanActivity.this.tvPemakaian.setVisibility(8);
                        CheckTagihanActivity.this.tvPemakaianTitle.setVisibility(8);
                    } else {
                        CheckTagihanActivity.this.tvPemakaian.setText(": " + data.getpEMAKAIAN());
                    }
                    Iterator<PdamRincian> it = data.getrINCIANTAGIHAN().iterator();
                    int iIntValue2 = 0;
                    while (it.hasNext()) {
                        iIntValue2 += Integer.valueOf(it.next().getNOMINAL()).intValue();
                    }
                    Double dValueOf = Double.valueOf(Double.parseDouble(String.valueOf(iIntValue2)));
                    CheckTagihanActivity.this.tvTagihan.setText(": Rp." + String.format("%,.0f", dValueOf));
                    if (data.getdENDA().intValue() != 0) {
                        Double dValueOf2 = Double.valueOf(Double.parseDouble(String.valueOf(data.getdENDA())));
                        CheckTagihanActivity.this.tvDenda.setText(": Rp." + String.format("%,.0f", dValueOf2));
                        CheckTagihanActivity.this.trDenda.setVisibility(0);
                        iIntValue = data.getdENDA().intValue();
                    } else {
                        iIntValue = 0;
                    }
                    int i = iIntValue2 + iIntValue;
                    Double dValueOf3 = Double.valueOf(Double.parseDouble(String.valueOf(data.getdENDA())));
                    CheckTagihanActivity.this.tvDenda.setText(": Rp." + String.format("%,.0f", dValueOf3));
                    Double dValueOf4 = Double.valueOf(Double.parseDouble(String.valueOf(i)));
                    CheckTagihanActivity.this.tvTotal.setText(": Rp." + String.format("%,.0f", dValueOf4));
                    return;
                }
                Toast.makeText(CheckTagihanActivity.this, responsePdam.getData().getkETERANGAN(), 0).show();
                CheckTagihanActivity.this.cvLayoutResult.setVisibility(8);
                return;
            }
            Toast.makeText(CheckTagihanActivity.this, "Error", 0).show();
        }

        /* JADX INFO: Access modifiers changed from: protected */
        @Override // android.os.AsyncTask
        public ResponsePdam doInBackground(Void... voidArr) {
            Result result = new Result("pdambandung", "296e82f8257a87ce0115cfc53900914c", "inquery");
            result.setGroupRef("WABDG");
            result.setParam1(CheckTagihanActivity.this.customerId);
            ResponseJson responseJson = new ResponseJson();
            responseJson.setResult(result);
            String str = "";
            try {
                MCrypt mCrypt = CheckTagihanActivity.this.mCrypt;
                str = new String(MCrypt.bytesToHex(CheckTagihanActivity.this.mCrypt.encrypt(responseJson.toString())));
            } catch (Exception e) {
                e.printStackTrace();
            }
            try {
                Response<ResponsePdam> responseExecute = ApiFactory.apiService(CheckTagihanActivity.this.getString(R.string.app_base_url)).pdam(CheckTagihanActivity.this.getString(R.string.api_secret_key), str, "0").execute();
                if (!responseExecute.isSuccessful() || responseExecute.body() == null) {
                    return null;
                }
                return responseExecute.body();
            } catch (IOException e2) {
                e2.printStackTrace();
                CheckTagihanActivity.this.progressDialog.dismiss();
                return null;
            }
        }
    }
}
