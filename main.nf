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

process optimization {
    container 'ghcr.io/dennislarsson/stacks2-image:refs-tags-1.1.1-4480f63'
    
    input:
    file samples from samples_ch.collect()
    file popmap from popmap_ch

// Make sure that all files are available and create the popmap file or download it. 
// Perhaps input it as a parameter?
    script:
    """
    ./parameter_optimization.py --popmap popmap_test --samples /test_samples/ --min_val 1 --max_val 3
    """
}

process preprocessing {
    container 'preprocessing'
    "./preprocessing.py"
}

process pseudoreference {
    container 'pseudoreference'
    "./pseudoreference.py"
}

process postprocessing {
    container 'stacks2'
    "./postprocessing"
}

workflow {
    download_samples
}
