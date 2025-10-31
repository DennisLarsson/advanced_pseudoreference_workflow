include { PARAMETER_OPTIMIZATION    } from '../modules/parameter_optimization/parameter_optimization'
include { PREPARE_SUMSTATS          } from '../modules/parameter_optimization/prepare_sumstats'

workflow PARAMETER_OPTIMIZATION_WF {
    take:
        ch_samples
        ch_popmap
        ch_parameter_min_val
        ch_parameter_max_val

    main:
        PARAMETER_OPTIMIZATION (
            ch_samples,
            ch_popmap,
            ch_parameter_min_val,
            ch_parameter_max_val
        )

        ch_best_assembly = PARAMETER_OPTIMIZATION.out.ch_best_assembly

        PREPARE_SUMSTATS (
            ch_best_assembly,
            ch_popmap
        )
    
    emit:
        ch_sumstats = PREPARE_SUMSTATS.out.ch_sumstats
        ch_catalog = PARAMETER_OPTIMIZATION.out.ch_catalog

}