process PREPARE_SUMSTATS {
    container 'ghcr.io/dennislarsson/stacks2-image:refs-tags-1.3.0-3f3dfa7'

    input:
    path ch_stacks_best_assembly
    path ch_popmap

    output:
        path('populations_R04/populations.sumstats.tsv'), emit: ch_sumstats

    script:
        """
        mkdir populations_R04
        populations --in-path $ch_stacks_best_assembly \
        --out-path populations_R04 \
        --popmap $ch_popmap \
        -R 0.4
        """
}