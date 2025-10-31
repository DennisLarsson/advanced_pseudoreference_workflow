include { DOWNLOAD_SAMPLES } from '../modules/download_samples/download_samples'

workflow DOWNLOAD_SAMPLES_WF {
    take: 
        ch_samples_json
        ch_popmap
    
    main:
        DOWNLOAD_SAMPLES (
            ch_samples_json,
            ch_popmap
        )

    emit:
        samples = DOWNLOAD_SAMPLES.out.ch_samples
}