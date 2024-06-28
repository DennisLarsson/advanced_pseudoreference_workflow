//def parameters = new groovy.json.JsonSlurper().parseText(file(params.parameters).text)

params.samples_json = "samples.json"
params.popmap = "popmap"

process download_samples {
    container 'ghcr.io/dennislarsson/download-image:download-into-folder-4ed51e5'

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
    container 'ghcr.io/dennislarsson/stacks2-image:refs-tags-1.1.1-4480f63'

    input:
    path samples
    path popmap

    output:
    path('best_params.txt'), emit: best_parameters_ch

    script:
    """
    /parameter_optimization.py --popmap /$popmap --samples /$samples/ --min_val 1 --max_val 3
    """
}

workflow {

    Channel
        .fromPath(params.samples_json)
        .set { samples_json_ch }

    Channel
        .fromPath(params.popmap)
        .set { popmap_ch }
    
    download_samples(samples_json_ch, popmap_ch)

    parameter_optimization(download_samples.out.samples_ch, popmap_ch)

    parameter_optimization.out.best_parameters_ch.view()
}
