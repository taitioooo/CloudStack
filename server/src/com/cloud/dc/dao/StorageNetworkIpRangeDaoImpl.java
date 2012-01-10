package com.cloud.dc.dao;

import java.util.List;
import java.util.Map;

import javax.ejb.Local;
import javax.naming.ConfigurationException;

import com.cloud.dc.StorageNetworkIpRangeVO;
import com.cloud.utils.db.DB;
import com.cloud.utils.db.Filter;
import com.cloud.utils.db.GenericDaoBase;
import com.cloud.utils.db.GenericSearchBuilder;
import com.cloud.utils.db.SearchBuilder;
import com.cloud.utils.db.SearchCriteria;
import com.cloud.utils.db.SearchCriteria2;
import com.cloud.utils.db.SearchCriteriaService;
import com.cloud.utils.db.SearchCriteria.Func;
import com.cloud.utils.db.SearchCriteria.Op;

@Local(value={StorageNetworkIpRangeDao.class})
@DB(txn=false)
public class StorageNetworkIpRangeDaoImpl extends GenericDaoBase<StorageNetworkIpRangeVO, Long> implements StorageNetworkIpRangeDao {
	protected final GenericSearchBuilder<StorageNetworkIpRangeVO, Long> countRanges;
	
	protected StorageNetworkIpRangeDaoImpl() {
		countRanges = createSearchBuilder(Long.class);
		countRanges.select(null, Func.COUNT, null);
		countRanges.done();
	}
	
	@Override
    public List<StorageNetworkIpRangeVO> listByPodId(long podId) {
		SearchCriteriaService<StorageNetworkIpRangeVO, StorageNetworkIpRangeVO> sc = SearchCriteria2.create(StorageNetworkIpRangeVO.class);
	    sc.addAnd(sc.getEntity().getPodId(), Op.EQ, podId);
		return sc.list();
    }

	@Override
    public List<StorageNetworkIpRangeVO> listByRangeId(long rangeId) {
		SearchCriteriaService<StorageNetworkIpRangeVO, StorageNetworkIpRangeVO> sc = SearchCriteria2.create(StorageNetworkIpRangeVO.class);
	    sc.addAnd(sc.getEntity().getId(), Op.EQ, rangeId);
		return sc.list();
    }

	@Override
    public List<StorageNetworkIpRangeVO> listByDataCenterId(long dcId) {
		SearchCriteriaService<StorageNetworkIpRangeVO, StorageNetworkIpRangeVO> sc = SearchCriteria2.create(StorageNetworkIpRangeVO.class);
	    sc.addAnd(sc.getEntity().getDataCenterId(), Op.EQ, dcId);
		return sc.list();
    }
	
	@Override
	public long countRanges() {
		SearchCriteria<Long> sc = countRanges.create();
		return customSearch(sc, null).get(0);
	}

}
