package com.aurora.bdg.model;

import java.util.Map;
import org.greenrobot.greendao.AbstractDao;
import org.greenrobot.greendao.AbstractDaoSession;
import org.greenrobot.greendao.database.Database;
import org.greenrobot.greendao.identityscope.IdentityScopeType;
import org.greenrobot.greendao.internal.DaoConfig;

/* JADX INFO: loaded from: classes.dex */
public class DaoSession extends AbstractDaoSession {
    private final AlasanDao alasanDao;
    private final DaoConfig alasanDaoConfig;
    private final DataMeterDao dataMeterDao;
    private final DaoConfig dataMeterDaoConfig;
    private final PetugasDao petugasDao;
    private final DaoConfig petugasDaoConfig;
    private final TarifDao tarifDao;
    private final DaoConfig tarifDaoConfig;
    private final WaterTarifDao waterTarifDao;
    private final DaoConfig waterTarifDaoConfig;
    private final WmsizeDao wmsizeDao;
    private final DaoConfig wmsizeDaoConfig;

    public DaoSession(Database database, IdentityScopeType identityScopeType, Map<Class<? extends AbstractDao<?, ?>>, DaoConfig> map) {
        super(database);
        this.alasanDaoConfig = map.get(AlasanDao.class).clone();
        this.alasanDaoConfig.initIdentityScope(identityScopeType);
        this.dataMeterDaoConfig = map.get(DataMeterDao.class).clone();
        this.dataMeterDaoConfig.initIdentityScope(identityScopeType);
        this.petugasDaoConfig = map.get(PetugasDao.class).clone();
        this.petugasDaoConfig.initIdentityScope(identityScopeType);
        this.tarifDaoConfig = map.get(TarifDao.class).clone();
        this.tarifDaoConfig.initIdentityScope(identityScopeType);
        this.waterTarifDaoConfig = map.get(WaterTarifDao.class).clone();
        this.waterTarifDaoConfig.initIdentityScope(identityScopeType);
        this.wmsizeDaoConfig = map.get(WmsizeDao.class).clone();
        this.wmsizeDaoConfig.initIdentityScope(identityScopeType);
        this.alasanDao = new AlasanDao(this.alasanDaoConfig, this);
        this.dataMeterDao = new DataMeterDao(this.dataMeterDaoConfig, this);
        this.petugasDao = new PetugasDao(this.petugasDaoConfig, this);
        this.tarifDao = new TarifDao(this.tarifDaoConfig, this);
        this.waterTarifDao = new WaterTarifDao(this.waterTarifDaoConfig, this);
        this.wmsizeDao = new WmsizeDao(this.wmsizeDaoConfig, this);
        registerDao(Alasan.class, this.alasanDao);
        registerDao(DataMeter.class, this.dataMeterDao);
        registerDao(Petugas.class, this.petugasDao);
        registerDao(Tarif.class, this.tarifDao);
        registerDao(WaterTarif.class, this.waterTarifDao);
        registerDao(Wmsize.class, this.wmsizeDao);
    }

    public void clear() {
        this.alasanDaoConfig.clearIdentityScope();
        this.dataMeterDaoConfig.clearIdentityScope();
        this.petugasDaoConfig.clearIdentityScope();
        this.tarifDaoConfig.clearIdentityScope();
        this.waterTarifDaoConfig.clearIdentityScope();
        this.wmsizeDaoConfig.clearIdentityScope();
    }

    public AlasanDao getAlasanDao() {
        return this.alasanDao;
    }

    public DataMeterDao getDataMeterDao() {
        return this.dataMeterDao;
    }

    public PetugasDao getPetugasDao() {
        return this.petugasDao;
    }

    public TarifDao getTarifDao() {
        return this.tarifDao;
    }

    public WaterTarifDao getWaterTarifDao() {
        return this.waterTarifDao;
    }

    public WmsizeDao getWmsizeDao() {
        return this.wmsizeDao;
    }
}
