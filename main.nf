//def parameters = new groovy.json.JsonSlurper().parseText(file(params.parameters).text)

params.samples_json = "samples.json"
params.popmap = "popmap"
params.parameter_min_val = "1"
params.parameter_max_val = "3"

process download_samples {
    container 'ghcr.io/dennislarsson/download-image:refs-tags-1.2.0-43ecb89'

    input:
    path samples_json 
    path popmap 

    output:
    path('samples'), emit: samples_ch

    script:
    """
    mkdir -p samples
    /download_samples.sh $samples_json $popmap samples
    """
}

process parameter_optimization {
    container 'ghcr.io/dennislarsson/stacks2-image:refs-tags-1.2.0-5f371f7'

    input:
    path samples
    path popmap
    val param_min_val
    val param_max_val

    output:
    path('best_params_path.txt'), emit: best_parameters_ch
    path('param_vals_nm.txt'), emit: param_vals_nm_ch
    path('stacks_best_assembly'), emit: best_assembly_ch

    script:
    """
    /parameter_optimization.py \
        --popmap $popmap \
        --samples $samples/ \
        --min_val $param_min_val \
        --max_val $param_max_val
    
    PATH_BEST_ASSEMBLY=\$(cat best_params_path.txt)
    cp -r \${PATH_BEST_ASSEMBLY}/ stacks_best_assembly/
    """
}

workflow {

    println("samples_json: ${params.samples_json}")
    println("popmap: ${params.popmap}")
    println("parameter_min_val: ${params.parameter_min_val}")
    println("parameter_max_val: ${params.parameter_max_val}")

    Channel
        .fromPath(params.samples_json)
        .set { samples_json_ch }

    Channel
        .fromPath(params.popmap)
        .set { popmap_ch }

    Channel
        .value(params.parameter_min_val)
        .set { parameter_min_val_ch }
    
    Channel
        .value(params.parameter_max_val)
        .set { parameter_max_val_ch }
    

    
    download_samples(samples_json_ch, popmap_ch)

    parameter_optimization(
        download_samples.out.samples_ch, 
        popmap_ch, 
        parameter_min_val_ch, 
        parameter_max_val_ch
    )

    parameter_optimization.out.best_parameters_ch.view { file -> return file.text }
    parameter_optimization.out.param_vals_nm_ch.view { file -> return file.text }
}
