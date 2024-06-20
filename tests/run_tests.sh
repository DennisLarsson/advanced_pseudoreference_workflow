#! /bin/bash

nextflow run main.nf --samples_json test_samples.json --popmap popmap_test

while IFS= read -r LINE; do
    FILE=$(echo "$LINE" | cut -f 1)
    test -f ${FILE}.fq.gz || { echo "${FILE}.fq.gz not found" && exit 1; }
done < popmap_test
