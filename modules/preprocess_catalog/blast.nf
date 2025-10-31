process BLAST {
    container 'ghcr.io/dennislarsson/preprocess_catalog:refs-tags-1.1.0-a2d6a3a'
    
    input:
        path ch_catalog_filtered
    
    output:
        path('results.out'), emit: ch_blast_results
    
    script:
    """
    blastn -db nt_euk \
      -query $ch_catalog_filtered \
      -task blastn \
      -max_target_seqs 1 \
      -evalue 5 \
      -outfmt "10 delim=@ qseqid qlen sscinames sblastnames sskingdoms stitle evalue bitscore score length nident qcovs" \
      -out results.out -remote
    """
    stub:
    """
    echo "stub" > results.out
    """
}
