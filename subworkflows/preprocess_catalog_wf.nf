include { PREPARE_WHITELIST     } from '../modules/preprocess_catalog/prepare_whitelist'
include { FILTER_CATALOG        } from '../modules/preprocess_catalog/filter_catalog'
include { BLAST                 } from '../modules/preprocess_catalog/blast'
include { FILTER_NONPLANT_LOCI  } from '../modules/preprocess_catalog/filter_nonplant_loci'

workflow PREPROCESS_CATALOG {
    take:
        ch_catalog
        ch_sumstats
    
    main:
        PREPARE_WHITELIST (
            ch_sumstats
        )

        ch_whitelist = PREPARE_WHITELIST.out.ch_whitelist

        FILTER_CATALOG (
            ch_catalog,
            ch_whitelist
        )

        ch_catalog_filtered = FILTER_CATALOG.out.ch_catalog_filtered

        BLAST (
            ch_catalog_filtered
        )

        ch_blast_results = BLAST.out.ch_blast_results

        FILTER_NONPLANT_LOCI (
            ch_catalog_filtered,
            ch_blast_results
        )

    emit:
        ch_catalog_final = FILTER_NONPLANT_LOCI.out.ch_catalog_final
}