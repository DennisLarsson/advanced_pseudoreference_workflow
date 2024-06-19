params.samples_json = "samples.json"
params.popmap = "popmap"

Channel
    .fromPath(params.samples_json)
    .set { samples_json_ch }

Channel
    .fromPath(params.popmap)
    .set { popmap_ch }

process download_samples {
    container 'ghcr.io/dennislarsson/download-image:refs-tags-1.0.0-e2e677d'

    input:
    file samples_json from samples_json_ch
    file popmap from popmap_ch

    output:
    file(*.fq.gz) into samples_ch

    script:
    """
    while IFS= read -r line; do
        sample_name=$(echo "$line" | cut -f1)
        id=$(jq -r --arg key "${sample_name}.fq.gz" '.[$key]' $samples_json)
        if [[ $id == "null" ]]; then
            echo "Error: Sample ${sample_name}.fq.gz not found in samples.json" >&2
            exit 1
        else
            gdown $id --output "${sample_name}.fq.gz"
        fi
    done < $popmap
    """
}

workflow {
    download_samples
}
