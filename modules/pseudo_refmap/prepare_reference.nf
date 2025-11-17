process PREPARE_REFERENCE {
    container 'ghcr.io/dennislarsson/pseudo-refmap:refs-tags-1.0.0-7346ed5'

    input:
        path ch_catalog
    
    output:
        path('reference'), emit: ch_reference
    
    script:
        """
        mkdir reference
        cp $ch_catalog reference/catalog.fa.gz
        samtools faidx reference/catalog.fa.gz
        
        picard CreateSequenceDictionary \
        -R reference/catalog.fa.gz \
        -O reference/catalog.dict
        
        bowtie2-build reference/catalog.fa.gz reference/catalog.fa.gz
        """
}