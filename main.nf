//def parameters = new groovy.json.JsonSlurper().parseText(file(params.parameters).text)

params.samples_json = "samples.json"
params.popmap = "popmap"
params.parameter_min_val = "1"
params.parameter_max_val = "3"

process download_samples {
    container 'ghcr.io/dennislarsson/download-image:refs-tags-1.3.0-c2c2cd0'

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
    container 'ghcr.io/dennislarsson/stacks2-image:refs-tags-1.3.0-3f3dfa7'

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

    mkdir stacks_best_assembly/populations_R04
    populations --in-path stacks_best_assembly \
      --out-path stacks_best_assembly/populations_R04 \
      --popmap $popmap \
      -R 0.4
    """
    // Figure out how to set the threads
}

process preprocess_catalog {
    container 'ghcr.io/dennislarsson/preprocess_catalog:refs-tags-1.0.0-b7d7fbc'

    input:
    path best_assembly

    output:
    path('catalog_R04_max10snp_blasted.fa.gz'), emit: preprocessed_catalog_ch

    script:
    """
    cat $best_assembly/populations_R04/populations.sumstats.tsv | \
      grep -v "^#" | \
      cut -f 1,4 | \
      sort -n | \
      uniq | \
      cut -f 1 | \
      uniq -c | \
      awk '\$1 <= 10 {print \$2}' > whitelist_R04_max10snp

    gunzip $best_assembly/catalog.fa.gz
    
    /filter_catalog.py \
      --catalog $best_assembly/catalog.fa \
      --whitelist whitelist_R04_max10snp \
      > catalog_R04_max10snp.fa

    blastn -db nt_euk \
      -query catalog_R04_max10snp.fa \
      -task blastn \
      -max_target_seqs 1 \
      -evalue 5 \
      -outfmt "10 delim=@ qseqid qlen sscinames sblastnames sskingdoms stitle evalue bitscore score length nident qcovs" \
      -out results.out -remote

    /filter_nonplant_loci.py \
      -b results.out \
      -c catalog_R04_max10snp.fa \
      -o catalog_R04_max10snp_blasted.fa
    
    gzip catalog_R04_max10snp_blasted.fa
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

    preprocess_catalog(parameter_optimization.out.best_assembly_ch)
}
