process FILTER_NONPLANT_LOCI {
    container 'ghcr.io/dennislarsson/preprocess_catalog:refs-tags-1.1.0-a2d6a3a'
    
    input:
        path ch_catalog_filtered
        path ch_blast_results
    
    output:
        path('catalog_R04_max10snp_blasted.fa.gz'), emit: ch_catalog_final
    
    script:
    """
    /filter_nonplant_loci.py \
      -b $ch_blast_results \
      -c $ch_catalog_filtered \
      -o catalog_R04_max10snp_blasted.fa
    
    bgzip catalog_R04_max10snp_blasted.fa
    """
    stub:
    """
    cp $ch_catalog_filtered catalog_R04_max10snp_blasted.fa
    bgzip catalog_R04_max10snp_blasted.fa
    """
}
