
process FQGREP {
    tag "$meta.id"
    label 'process_single'

    if (params.singularity_pull_docker_container ){
        exit 1, "singularity or docker cannot be used while using fqgrep, please use conda."
    }

    conda (params.enable_conda ? "bioconda::fqgrep=0.1.0" : null)


    

    input:
        tuple val(meta), path(reads)
        val(refSeq)
        val(altSeq)

    output:
    tuple val(meta), path("REF_${meta.id}.{R1,R2}.fastq.gz"),                  emit: refSeqPairedFastq
    tuple val(meta), path("ALT_${meta.id}.{R1,R2}.fastq.gz"),                  emit: altSeqPairedFastq
    tuple val(meta), path("BOTH_${meta.id}.{R1,R2}.fastq.gz"),            emit: bothSeqPairedFastq
    tuple val(meta), path("fqgrep_stats_${meta.id}.tsv"), emit: tsvReport
    path "fqgrep.version.txt"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def (forwardReads, reverseReads) = reads
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    
    """
    fqgrep -1 ${forwardReads} -2 ${reverseReads} -r ${refSeq} -a ${altSeq} -o output

    cp "output/BOTH_${prefix}.fastq.g.R1.fastq.gz" "BOTH_${prefix}.R1.fastq.gz"
    cp "output/BOTH_${prefix}.fastq.g.R2.fastq.gz" "BOTH_${prefix}.R2.fastq.gz"
    cp "output/REF_${prefix}.fastq.g.R1.fastq.gz" "REF_${prefix}.R1.fastq.gz"
    cp "output/REF_${prefix}.fastq.g.R2.fastq.gz" "REF_${prefix}.R2.fastq.gz"
    cp "output/ALT_${prefix}.fastq.g.R1.fastq.gz" "ALT_${prefix}.R1.fastq.gz"
    cp "output/ALT_${prefix}.fastq.g.R2.fastq.gz" "ALT_${prefix}.R2.fastq.gz"
    cp "output/fqgrep_stats.tsv" "fqgrep_stats_${prefix}.tsv"

    fqgrep --version > fqgrep.version.txt
    

    
    """
}
