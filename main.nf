$HOSTNAME = ""
params.outdir = 'results'  





process minimap2 {

input:

output:
 set val(name), file("*sorted_mapped.bam*")  into g_0_mapped_reads0_g_1

script:
"""
	minimap2 --eqx -ax splice -t 1 ${genome} ${reads} | samtools sort > ${name}.sorted_mapped.bam
	samtools index ${name}.sorted_mapped.bam
"""
}


process Summarize_AAV_alignment {

input:
 set val(name),  file(bam) from g_0_mapped_reads0_g_1

output:
 file "*.csv"  into g_1_csvout00
 file "*.pdf"  into g_1_outputFilePdf11

script:
"""
	python summarize_AAV_alignment.py 
	   ${bam} ${name}
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
