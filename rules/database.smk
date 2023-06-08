##### Download database #####

rule download_database:
    output:
        multiext("{db}/{ref}", "ClinVar.vcf.gz", "COSMIC.vcf.gz")
    params:
        cosmic = get_cosmic,
	    clinvar = get_clinvar,
	    reference = get_reference
    shell:
        "curl -k -L  '{params.cosmic}' > {db}/{ref}/COSMIC.vcf.gz; "
        "curl -k -L  '{params.clinvar}' > {db}/{ref}/ClinVar.vcf.gz; "
        "curl -k -L  '{params.reference}' > {db}/{ref}/ALL_1000G_phase1integrated_v3_impute.tgz; "
        "tar zxvf {db}/{ref}/ALL_1000G_phase1integrated_v3_impute.tgz -C {db}/{ref}; "
                
##########################

rule tabix_Cosmic:
    input:
        "database/{ref}/COSMIC.vcf.gz"
    output:
        "database/{ref}/COSMIC.vcf.gz.tbi"
    params:
        "-p vcf"
    wrapper:
        "v1.32.0/bio/tabix/index" 
