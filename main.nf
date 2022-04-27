$HOSTNAME = ""
params.outdir = 'results'  


if (!params.genome){params.genome = ""} 
if (!params.reads){params.reads = ""} 

g_2_genome_g_0 = file(params.genome, type: 'any')
Channel.fromPath(params.reads, type: 'any').map{ file -> tuple(file.baseName, file) }.set{g_5_reads_g_0}


process minimap2 {

input:
 file genome from g_2_genome_g_0
 set val(name), file(reads) from g_5_reads_g_0

output:
 set val(name), file("*sorted_mapped.bam*")  into g_0_mapped_reads0_g_1

script:
"""
	minimap2 --eqx -ax splice -t 1 ${genome} ${reads} > ${name}.sam
	samtools view -bS ${name}.sam > ${name}.bam
	samtools sort ${name}.bam > ${name}.sorted_mapped.bam
	samtools index ${name}.sorted_mapped.bam
"""
}


process Summarize_AAV_alignment {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /.*.csv$/) "cvsout/$filename"}
publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /.*.pdf$/) "reports/$filename"}
input:
 set val(name),  file(bam), file(bai) from g_0_mapped_reads0_g_1

output:
 file "*.csv"  into g_1_csvout00
 file "*.pdf"  into g_1_outputFilePdf11

script:
"""
    . /opt/conda/etc/profile.d/conda.sh
    conda activate dolphinnext
	summarize_AAV_alignment.py ${bam} ${name}
	Rscript plotAAVreport.R ${name}
      
"""
}


workflow.onComplete {
println "##Pipeline execution summary##"
println "---------------------------"
println "##Completed at: $workflow.complete"
println "##Duration: ${workflow.duration}"
println "##Success: ${workflow.success ? 'OK' : 'failed' }"
println "##Exit status: ${workflow.exitStatus}"
}
