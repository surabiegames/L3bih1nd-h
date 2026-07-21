package com.aurora.bdg.model;

import android.os.Parcel;
import android.os.Parcelable;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;
import java.util.ArrayList;

/* JADX INFO: loaded from: classes.dex */
public class Pdam implements Parcelable {
    public static final Parcelable.Creator<Pdam> CREATOR = new Parcelable.Creator<Pdam>() { // from class: com.aurora.bdg.model.Pdam.1
        /* JADX WARN: Can't rename method to resolve collision */
        @Override // android.os.Parcelable.Creator
        public Pdam createFromParcel(Parcel parcel) {
            return new Pdam(parcel);
        }

        /* JADX WARN: Can't rename method to resolve collision */
        @Override // android.os.Parcelable.Creator
        public Pdam[] newArray(int i) {
            return new Pdam[i];
        }
    };

    @SerializedName("ADMIN")
    @Expose
    private Integer aDMIN;

    @SerializedName("ALAMAT")
    @Expose
    private String aLAMAT;

    @SerializedName("BILLER_REF")
    @Expose
    private String bILLERREF;

    @SerializedName("DENDA")
    @Expose
    private Integer dENDA;

    @SerializedName("JATUH_TEMPO")
    @Expose
    private String jATUHTEMPO;

    @SerializedName("KETERANGAN")
    @Expose
    private String kETERANGAN;

    @SerializedName("KODE_TARIF")
    @Expose
    private String kODETARIF;

    @SerializedName("NAMA")
    @Expose
    private String nAMA;

    @SerializedName("NAMA_PAM")
    @Expose
    private String nAMAPAM;

    @SerializedName("NO_PELANGGAN")
    @Expose
    private String nOPELANGGAN;

    @SerializedName("NO_RESI")
    @Expose
    private String nORESI;

    @SerializedName("PEMAKAIAN")
    @Expose
    private String pEMAKAIAN;

    @SerializedName("RETRIBUSI")
    @Expose
    private Integer rETRIBUSI;

    @SerializedName("RINCIAN_TAGIHAN")
    @Expose
    private ArrayList<PdamRincian> rINCIANTAGIHAN;

    @SerializedName("STAND_METER")
    @Expose
    private String sTANDMETER;

    @SerializedName("STATUS")
    @Expose
    private String sTATUS;

    @SerializedName("session_id")
    @Expose
    private String sessionId;

    @SerializedName("TANGGAL")
    @Expose
    private String tANGGAL;

    @SerializedName("TANGGAL_REPRINT")
    @Expose
    private String tANGGALREPRINT;

    @SerializedName("TANGGAL_TRX")
    @Expose
    private String tANGGALTRX;

    @SerializedName("TERBILANG")
    @Expose
    private String tERBILANG;

    @SerializedName("TOTAL_TAGIHAN")
    @Expose
    private Integer tOTALTAGIHAN;

    @Override // android.os.Parcelable
    public int describeContents() {
        return 0;
    }

    public String getbILLERREF() {
        return this.bILLERREF;
    }

    public void setbILLERREF(String str) {
        this.bILLERREF = str;
    }

    public String getSessionId() {
        return this.sessionId;
    }

    public void setSessionId(String str) {
        this.sessionId = str;
    }

    public String gettANGGAL() {
        return this.tANGGAL;
    }

    public void settANGGAL(String str) {
        this.tANGGAL = str;
    }

    public String getnORESI() {
        return this.nORESI;
    }

    public void setnORESI(String str) {
        this.nORESI = str;
    }

    public String getnAMAPAM() {
        return this.nAMAPAM;
    }

    public void setnAMAPAM(String str) {
        this.nAMAPAM = str;
    }

    public String getnOPELANGGAN() {
        return this.nOPELANGGAN;
    }

    public void setnOPELANGGAN(String str) {
        this.nOPELANGGAN = str;
    }

    public String getsTANDMETER() {
        return this.sTANDMETER;
    }

    public void setsTANDMETER(String str) {
        this.sTANDMETER = str;
    }

    public String getkODETARIF() {
        return this.kODETARIF;
    }

    public void setkODETARIF(String str) {
        this.kODETARIF = str;
    }

    public String getjATUHTEMPO() {
        return this.jATUHTEMPO;
    }

    public void setjATUHTEMPO(String str) {
        this.jATUHTEMPO = str;
    }

    public String getnAMA() {
        return this.nAMA;
    }

    public void setnAMA(String str) {
        this.nAMA = str;
    }

    public String getaLAMAT() {
        return this.aLAMAT;
    }

    public void setaLAMAT(String str) {
        this.aLAMAT = str;
    }

    public String getpEMAKAIAN() {
        return this.pEMAKAIAN;
    }

    public void setpEMAKAIAN(String str) {
        this.pEMAKAIAN = str;
    }

    public ArrayList<PdamRincian> getrINCIANTAGIHAN() {
        return this.rINCIANTAGIHAN;
    }

    public void setrINCIANTAGIHAN(ArrayList<PdamRincian> arrayList) {
        this.rINCIANTAGIHAN = arrayList;
    }

    public Integer getdENDA() {
        return this.dENDA;
    }

    public void setdENDA(Integer num) {
        this.dENDA = num;
    }

    public Integer getaDMIN() {
        return this.aDMIN;
    }

    public void setaDMIN(Integer num) {
        this.aDMIN = num;
    }

    public Integer getrETRIBUSI() {
        return this.rETRIBUSI;
    }

    public void setrETRIBUSI(Integer num) {
        this.rETRIBUSI = num;
    }

    public Integer gettOTALTAGIHAN() {
        return this.tOTALTAGIHAN;
    }

    public void settOTALTAGIHAN(Integer num) {
        this.tOTALTAGIHAN = num;
    }

    public String gettERBILANG() {
        return this.tERBILANG;
    }

    public void settERBILANG(String str) {
        this.tERBILANG = str;
    }

    public String getsTATUS() {
        return this.sTATUS;
    }

    public void setsTATUS(String str) {
        this.sTATUS = str;
    }

    public String getkETERANGAN() {
        return this.kETERANGAN;
    }

    public void setkETERANGAN(String str) {
        this.kETERANGAN = str;
    }

    public String gettANGGALREPRINT() {
        return this.tANGGALREPRINT;
    }

    public void settANGGALREPRINT(String str) {
        this.tANGGALREPRINT = str;
    }

    public String gettANGGALTRX() {
        return this.tANGGALTRX;
    }

    public void settANGGALTRX(String str) {
        this.tANGGALTRX = str;
    }

    @Override // android.os.Parcelable
    public void writeToParcel(Parcel parcel, int i) {
        parcel.writeString(this.bILLERREF);
        parcel.writeString(this.sessionId);
        parcel.writeString(this.tANGGAL);
        parcel.writeString(this.nORESI);
        parcel.writeString(this.nAMAPAM);
        parcel.writeString(this.nOPELANGGAN);
        parcel.writeString(this.sTANDMETER);
        parcel.writeString(this.kODETARIF);
        parcel.writeString(this.jATUHTEMPO);
        parcel.writeString(this.nAMA);
        parcel.writeString(this.aLAMAT);
        parcel.writeString(this.pEMAKAIAN);
        parcel.writeList(this.rINCIANTAGIHAN);
        parcel.writeValue(this.dENDA);
        parcel.writeValue(this.aDMIN);
        parcel.writeValue(this.rETRIBUSI);
        parcel.writeValue(this.tOTALTAGIHAN);
        parcel.writeString(this.tERBILANG);
        parcel.writeString(this.sTATUS);
        parcel.writeString(this.kETERANGAN);
        parcel.writeString(this.tANGGALREPRINT);
        parcel.writeString(this.tANGGALTRX);
    }

    public Pdam() {
        this.rINCIANTAGIHAN = null;
    }

    protected Pdam(Parcel parcel) {
        this.rINCIANTAGIHAN = null;
        this.bILLERREF = parcel.readString();
        this.sessionId = parcel.readString();
        this.tANGGAL = parcel.readString();
        this.nORESI = parcel.readString();
        this.nAMAPAM = parcel.readString();
        this.nOPELANGGAN = parcel.readString();
        this.sTANDMETER = parcel.readString();
        this.kODETARIF = parcel.readString();
        this.jATUHTEMPO = parcel.readString();
        this.nAMA = parcel.readString();
        this.aLAMAT = parcel.readString();
        this.pEMAKAIAN = parcel.readString();
        this.rINCIANTAGIHAN = new ArrayList<>();
        parcel.readList(this.rINCIANTAGIHAN, PdamRincian.class.getClassLoader());
        this.dENDA = (Integer) parcel.readValue(Integer.class.getClassLoader());
        this.aDMIN = (Integer) parcel.readValue(Integer.class.getClassLoader());
        this.rETRIBUSI = (Integer) parcel.readValue(Integer.class.getClassLoader());
        this.tOTALTAGIHAN = (Integer) parcel.readValue(Integer.class.getClassLoader());
        this.tERBILANG = parcel.readString();
        this.sTATUS = parcel.readString();
        this.kETERANGAN = parcel.readString();
        this.tANGGALREPRINT = parcel.readString();
        this.tANGGALTRX = parcel.readString();
    }
}
