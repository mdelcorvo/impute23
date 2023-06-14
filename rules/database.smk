##### Download databases #####

rule download_database:
    output:
        multiext("{db}/{ref}", "ClinVar.vcf.gz", "COSMIC.vcf.gz")
    params:
        cosmic = get_cosmic,
	    clinvar = get_clinvar
    shell:
        """
        curl -k -L  '{params.cosmic}' > {db}/{ref}/COSMIC.vcf.gz;
        curl -k -L  '{params.clinvar}' > {db}/{ref}/ClinVar.vcf.gz;
     
        """

rule tabix_Cosmic:
    input:
        "{db}/{ref}/COSMIC.vcf.gz"
    output:
        "{db}/{ref}/COSMIC.vcf.gz.tbi"
    params:
        "-p vcf"
    wrapper:
        "v1.32.0/bio/tabix/index" 
        
rule download_reference:
    output:
        map= "{db}/{ref}/ALL_1000G_phase1integrated_v3_impute/ALL_1000G_phase1integrated_v3_chr{chrs}_combined_b37.txt",
        hap= "{db}/{ref}/ALL_1000G_phase1integrated_v3_impute/ALL_1000G_phase1integrated_v3_chr{chrs}_impute.hap.gz",
        legend= "{db}/{ref}/ALL_1000G_phase1integrated_v3_impute/ALL_1000G_phase1integrated_v3_chr{chrs}_impute.legend.gz"
    params:
	    reference = get_reference
    shell:
        """
        curl -k -L  '{params.reference}' > {db}/{ref}/ALL_1000G_phase1integrated_v3_impute.tgz;
        tar zxvf {db}/{ref}/ALL_1000G_phase1integrated_v3_impute.tgz -C {db}/{ref};
        rm {db}/{ref}/ALL_1000G_phase1integrated_v3_impute.tgz
        
        mv {db}/{ref}/ALL_1000G_phase1integrated_v3_impute/genetic_map_chrX_nonPAR_combined_b37.txt \
        {db}/{ref}/ALL_1000G_phase1integrated_v3_impute/genetic_map_chrX_combined_b37.txt
        
        mv {db}/{ref}/ALL_1000G_phase1integrated_v3_impute/ALL_1000G_phase1integrated_v3_chrX_nonPAR_impute.hap.gz \
        {db}/{ref}/ALL_1000G_phase1integrated_v3_impute/ALL_1000G_phase1integrated_v3_chrX_impute.hap.gz
        
        mv {db}/{ref}/ALL_1000G_phase1integrated_v3_impute/ALL_1000G_phase1integrated_v3_chrX_nonPAR_impute.legend.gz \
        {db}/{ref}/ALL_1000G_phase1integrated_v3_impute/ALL_1000G_phase1integrated_v3_chrX_impute.legend.gz
        
        """              
