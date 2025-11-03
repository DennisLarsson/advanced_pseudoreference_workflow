include { DOWNLOAD_SAMPLES_WF       } from './subworkflows/download_samples_wf'
include { PARAMETER_OPTIMIZATION_WF } from './subworkflows/parameter_optimization_wf'
include { PREPROCESS_CATALOG        } from './subworkflows/preprocess_catalog_wf'

workflow {
    Channel.fromPath(params.samples_json).set { ch_samples_json }
    Channel.fromPath(params.popmap).set { ch_popmap }
    Channel.value(params.parameter_min_val).set { ch_parameter_min_val }
    Channel.value(params.parameter_max_val).set { ch_parameter_max_val }

    DOWNLOAD_SAMPLES_WF (
        ch_samples_json,
        ch_popmap
        )

        ch_samples_folders = DOWNLOAD_SAMPLES_WF.out.samples_folders
        ch_samples_files = DOWNLOAD_SAMPLES_WF.out.samples_files
    
    PARAMETER_OPTIMIZATION_WF (
        ch_samples_folders,
        ch_popmap,
        ch_parameter_min_val,
        ch_parameter_max_val
        )
    
    ch_catalog = PARAMETER_OPTIMIZATION_WF.out.ch_catalog
    ch_sumstats = PARAMETER_OPTIMIZATION_WF.out.ch_sumstats

    PREPROCESS_CATALOG (
        ch_catalog,
        ch_sumstats
    )

    ch_catalog_processed = PREPROCESS_CATALOG.out.ch_catalog_final
}
