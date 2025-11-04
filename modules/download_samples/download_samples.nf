process DOWNLOAD_SAMPLES {
    container 'ghcr.io/dennislarsson/download-image:refs-tags-1.3.0-c2c2cd0'

    input:
        path ch_samples_json 
        path ch_popmap 

    output:
        path('samples'), emit: ch_samples_folder
        path('samples/*.fq.gz'), emit: ch_samples_files

    script:
        """
        mkdir -p samples
        /download_samples.sh $ch_samples_json $ch_popmap samples
        """
}