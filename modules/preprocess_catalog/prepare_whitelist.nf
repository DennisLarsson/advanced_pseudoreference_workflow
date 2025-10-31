process PREPARE_WHITELIST {
    container 'ghcr.io/dennislarsson/preprocess_catalog:refs-tags-1.1.0-a2d6a3a'
    
    input:
        path ch_sumstats
    
    output:
        path('whitelist_R04_max10snp'), emit: ch_whitelist
    
    script:
    """
    cat $ch_sumstats | \
      grep -v "^#" | \
      cut -f 1,4 | \
      sort -n | \
      uniq | \
      cut -f 1 | \
      uniq -c | \
      awk '\$1 <= 10 {print \$2}' > whitelist_R04_max10snp
    """
}
