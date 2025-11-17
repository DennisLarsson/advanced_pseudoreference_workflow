process MAP_SAMPLES {
    container 'ghcr.io/dennislarsson/pseudo-refmap:refs-tags-1.0.0-7346ed5'

    input:
        tuple path(ch_sample_file), path(ch_reference)
    
    output:
        path ("${ch_sample_file.name.replaceAll(/(?i)(\.fastq|\.fq)(\.gz)?$/, '')}.bam"), emit: sample_mapped

    script:
        def sample_name = ch_sample_file.name.replaceAll(/(?i)(\.fastq|\.fq)(\.gz)?$/, '')
        """
            set -eo pipefail

            bowtie2 --omit-sec-seq \
            --met-file ${sample_name}.log \
            -x ${ch_reference}/catalog.fa.gz \
            -U $ch_sample_file \
            -S ${sample_name}_mapped.sam

        picard SortSam \
            -I ${sample_name}_mapped.sam \
            -O ${sample_name}_sorted.bam \
            -SO coordinate
        
        picard AddOrReplaceReadGroups \
            -I ${sample_name}_sorted.bam \
            -O ${sample_name}_RG.bam \
            -RGID ${sample_name}.bam \
            -RGLB ${sample_name}.bam \
            -RGPL illumina \
            -RGPU ${sample_name}.bam \
            -RGSM ${sample_name}.bam
            
        samtools index ${sample_name}_RG.bam

        gatk LeftAlignIndels \
            -R ${ch_reference}/catalog.fa.gz \
            -I ${sample_name}_RG.bam \
            -O ${sample_name}.bam
        """ 
}