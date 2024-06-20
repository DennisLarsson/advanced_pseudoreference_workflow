params.samples_json = "samples.json"
params.popmap = "popmap"

Channel
    .fromPath(params.samples_json)
    .set { samples_json_ch }

Channel
    .fromPath(params.popmap)
    .set { popmap_ch }

process download_samples {
    container 'ghcr.io/dennislarsson/download-image:download-into-folder-4ed51e5'

    input:
    path samples_json from samples_json_ch
    path popmap from popmap_ch

    output:
    file('samples') into samples_ch

    script:
    """
    echo "Running download_samples"
    mkdir -p samples
    ./download_samples.sh $samples_json $popmap samples
    """
}

workflow {
    download_samples
}
