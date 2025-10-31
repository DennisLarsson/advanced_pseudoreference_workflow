process FILTER_CATALOG {
    container 'ghcr.io/dennislarsson/preprocess_catalog:refs-tags-1.1.0-a2d6a3a'
    
    input:
        path ch_catalog
        path ch_whitelist
    
    output:
        path('catalog_R04_max10snp.fa'), emit: ch_catalog_filtered
    
    script:
    """
    gunzip $ch_catalog -c > catalog.fa
    
    /filter_catalog.py \
      --catalog catalog.fa \
      --whitelist $ch_whitelist \
      > catalog_R04_max10snp.fa
    """
}
