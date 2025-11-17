include { PREPARE_REFERENCE } from '../modules/pseudo_refmap/prepare_reference'
include { MAP_SAMPLES       } from '../modules/pseudo_refmap/map_samples'
include { REFMAP            } from '../modules/pseudo_refmap/refmap'

workflow PSEUDO_REFMAP_WF {
    take:
        ch_samples_files
        ch_popmap
        ch_catalog
    
    main:
        PREPARE_REFERENCE (
            ch_catalog
        )

        ch_reference = PREPARE_REFERENCE.out.ch_reference

        ch_samples_files_flat = ch_samples_files.flatten()

        MAP_SAMPLES (
            ch_samples_files_flat
            .combine(ch_reference)
        )

        ch_mapped_samples = MAP_SAMPLES.out.sample_mapped.collect()

        REFMAP (
            ch_mapped_samples,
            ch_popmap
        )
}