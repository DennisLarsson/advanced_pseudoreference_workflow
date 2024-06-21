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
    ./download_samples.sh $samples_json $popmap samples
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
    download_samples.out.samples_ch.view()
}
