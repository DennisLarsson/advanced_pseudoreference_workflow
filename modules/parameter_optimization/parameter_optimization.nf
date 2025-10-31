process PARAMETER_OPTIMIZATION {    
    container 'ghcr.io/dennislarsson/stacks2-image:refs-tags-1.3.0-3f3dfa7'

    input:
        path ch_samples
        path ch_popmap
        val ch_param_min_val
        val ch_param_max_val

    output:
        path('stacks_best_assembly'), emit: ch_best_assembly
        path('stacks_best_assembly/catalog.fa.gz'), emit: ch_catalog
    
    script:
        """
        /parameter_optimization.py \
            --popmap $ch_popmap \
            --samples $ch_samples/ \
            --min_val $ch_param_min_val \
            --max_val $ch_param_max_val
        
        PATH_BEST_ASSEMBLY=\$(cat best_params_path.txt)
        cp -r \${PATH_BEST_ASSEMBLY}/ stacks_best_assembly/
        """

}