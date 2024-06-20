params.samples_json = "samples.json"
params.popmap = "popmap"

Channel
    .fromPath(params.samples_json)
    .set { samples_json_ch }

Channel
    .fromPath(params.popmap)
    .set { popmap_ch }

process download_samples {
    container 'ghcr.io/dennislarsson/download-image:refs-tags-1.1.0-474f9e'

    input:
    file samples_json from samples_json_ch
    file popmap from popmap_ch

    script:
    """
    ./download_samples.sh $samples_json $popmap
    """
}

workflow {
    download_samples
}
