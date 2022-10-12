
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
    tuple val(meta), path("REF_*.{R1,R2}.fastq.gz"),                  emit: refSeqPairedFastq
    tuple val(meta), path("ALT_*.{R1,R2}.fastq.gz"),                  emit: altSeqPairedFastq
    tuple val(meta), path("BOTH_*.{R1,R2}.fastq.gz"),            emit: bothSeqPairedFastq
    tuple val(meta), path("fqgrep_*.tsv"), emit: tsvReport
    path "fqgrep.version.txt"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def (forwardReads, reverseReads) = reads
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    
    """
    fqgrep -1 ${forwardReads} -2 ${reverseReads} -r ${refSeq} -a ${altSeq} -o output

    cp ./output/* .

    fqgrep --version > fqgrep.version.txt
    

    
    """
}
