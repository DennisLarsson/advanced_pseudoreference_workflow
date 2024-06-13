params.samples_json = "samples.json"

Channel
    .fromPath(params.samples_json)
    .set { samples_json_ch }

process download_samples {
    container 'ghcr.io/dennislarsson/download-image:refs-tags-1.0.0-e2e677d'

    input:
    file samples_json from samples_json_ch

    output:
    file(*.fq.gz) into samples_ch

    """
    for key in $(jq -r 'keys[]' $samples_json); 
    do
        id=$(jq -r ".$key" $samples_json)
        gdown $id --output $key
    done
    """
}

process optimization {
    container 'ghcr.io/dennislarsson/stacks2-image:refs-tags-1.1.1-4480f63'
    
    input:
    file samples from samples_ch.collect()

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
    optimization | preprocessing | pseudoreference | postprocessing
}
