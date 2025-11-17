process REFMAP {
    container 'ghcr.io/dennislarsson/pseudo-refmap:refs-tags-1.0.0-7346ed5'

    input:
        path(ch_mapped_samples, stageAs: "realigned/*")
        path(ch_popmap)
    
    output:
        path "populations/populations.snps.vcf", emit: vcf_file
    script:
        """
        ls realigned/

        mkdir ref_map

        ref_map.pl --popmap $ch_popmap -o ref_map --samples realigned/

        cat ref_map/populations.sumstats.tsv | \
        grep -v "^#" | \
        cut -f 1,4 | \
        sort -n | \
        uniq | \
        cut -f 1 | \
        uniq -c | \
        awk '\$1 <= 10 {print \$2}' > whitelist_refmap

        mkdir populations

        populations --in-path ref_map/ \
        --out-path populations/ \
        --popmap $ch_popmap \
        -R 0.5 \
        --min-mac 3 \
        --vcf \
        --write-random-snp \
        -W whitelist_refmap
        """ 
}