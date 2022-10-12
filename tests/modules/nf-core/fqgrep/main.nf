#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

params.refSeq = "AAAGCA"
params.altSeq = "TAAGCA"

include { FQGREP } from '../../../../modules/nf-core/fqgrep/main.nf' addParams(options: [args: ''])

workflow test_fqgrep {
    
    input = [
        [ id:'test_1' ],
            [ file(params.test_data['sarscov2']['illumina']['test_1_fastq_gz'], checkIfExists: true),
                        file(params.test_data['sarscov2']['illumina']['test_2_fastq_gz'], checkIfExists: true) ]
                                    
        ]

    FQGREP ( input, "${params.refSeq}","${params.altSeq}" )
}
