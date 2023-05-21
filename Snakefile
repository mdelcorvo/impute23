'''Snakefile for Lifebit Biotech Ltd - Coding Challenge'''

configfile: 'config/config.yaml'
SAMPLE = config['SAMPLE']
NAME = config['NAME']
DATAIN = config['DATAIN']
DATAOUT = config['DATAOUT']
CHR = config['CHR']

## File extensions
COSMIC =  config['COSMIC']
CLINVAR =  config['CLINVAR']
GWAS =  config['GWAS']

rule all:
    input:
        expand("results/{name}.original.Annot.vcf",name=NAME),
        expand("results/{name}.imputed.Annot.vcf",name=NAME)
        
rule plink_editing:
    input:
        raw_data = expand("{datain}/{sample}",datain=DATAIN,sample=SAMPLE),
        script = "scripts/edit_plink.R"
    params:
        name= expand("{name}",name=NAME)
    output:
        bim= expand("{dataout}/{name}.bim",dataout=DATAOUT,name=NAME),
        original=expand("results/{name}.original.vcf",name=NAME)
    conda:
        "envs/plink.yaml"
    shell:
        "plink --23file {input.raw_data} --list-duplicate-vars;"
	"plink --23file {input.raw_data} {params.name} {params.name} --make-bed --out results/{params.name} --snps-only just-acgt --exclude plink.dupvar;"
	"Rscript --vanilla {input.script} results/{params.name};"
	"plink --bfile results/{params.name} --recode vcf --out results/{params.name}.original;"

# Chromosome 1-22
rule plink2oxford:
    input:
        bim= "results/{name}.bim"
    params:
        chr = "{chr}",
        name= "{name}"
    output:
        gen= temp("results/{name}.{chr}.gen")
    conda:
        "envs/plink.yaml"
    shell:
	    "plink --bfile results/{params.name} --out results/{params.name}.{params.chr} --snps-only just-acgt --chr {params.chr} --export oxford; "

# Chromosome X has been deactivated
rule plink2oxfordX:
    input:
        gen= expand("results/{name}.{chr}.gen",name=NAME,chr=CHR),
        bim= expand("results/{name}.bim",name=NAME)
    params:
        name= expand("{name}",name=NAME)
    output:
        genX= expand("results/{name}.23.gen",name=NAME)
    conda:
        "envs/plink.yaml"
    shell:
	    "plink --bfile results/{params.name} --out results/{params.name}.23 --snps-only just-acgt --chr 23 --export oxford; "
	    	    
rule impute:
    input:
        gen= "results/{name}.{chr}.gen",
        map= "resources/ReferencePanel/genetic_map_chr{chr}_combined_b37.txt",
        hap= "resources/ReferencePanel/ALL_1000G_phase1integrated_v3_chr{chr}_impute.hap.gz",
        legend= "resources/ReferencePanel/ALL_1000G_phase1integrated_v3_chr{chr}_impute.legend.gz"
    params:
        chr = "{chr}",
        name= "{name}" 
    output:
        imputed= temp("results/{name}.{chr}.impute2")
    conda:
        "envs/impute2.yaml"
    shell:
        "impute2 -m {input.map} -h {input.hap} -l {input.legend} -g {input.gen} -int 20.4e6 20.5e6 -Ne 20000 -k 100 -iter 100 -o {output.imputed};"

rule imputeX:
    input:
        genX= "results/{name}.23.gen",
        mapX= "resources/ReferencePanel/genetic_map_chrX_nonPAR_combined_b37.txt",
        hapX= "resources/ReferencePanel/ALL_1000G_phase1integrated_v3_chrX_nonPAR_impute.hap.gz", 
        legendX= "resources/ReferencePanel/ALL_1000G_phase1integrated_v3_chrX_nonPAR_impute.legend.gz"
    params:
        name= "{name}"  
    output:
        imputedx= "results/{name}.23.impute2"
    conda:
        "envs/impute2.yaml"	
    shell:
        "impute2 -chrX -m {input.mapX} -h {input.hapX} -l {input.legendX} -g {input.genX} -int 20.4e6 20.5e6 -Ne 20000 -o {output.imputedx};"         

rule Fix2vcf:
    input:
        imputed= "results/{name}.{chr}.impute2",
    output:
        imputed_fixed= temp("results/{name}.{chr}.chrfix.impute2"),
        vcf= temp("results/{name}.{chr}.vcf") 
    params:
        chr= "{chr}",
        name= "{name}"
    shell:
        "awk '{{$1 = {params.chr}; print}}' {input.imputed} > {output.imputed_fixed};"
        "plink --gen results/{params.name}.{params.chr}.chrfix.impute2 --sample results/{params.name}.{params.chr}.sample --hard-call-threshold 0.49 --keep-allele-order --recode vcf --out results/{params.name}.{params.chr}; "
        
rule Fix2vcfX:
    input:
        imputed= expand("results/{name}.23.impute2",name=NAME)  
    output:
        imputed_fixed= expand("results/{name}.X.chrfix.impute2",name=NAME),
        vcf= expand("results/{name}.X.vcf",name=NAME)
    params:
        chr = expand("{chr}",chr=CHR),
        name= expand("{name}",name=NAME)      
    conda:
        "envs/plink.yaml"
    shell:
        "awk '{{$1 = 'X'; print}}' {input.imputed} > {output.imputed_fixed};"
        "plink --gen results/{params.name}.X.chrfix.impute2 --sample results/{params.name}.X.sample --hard-call-threshold 0.49 --keep-allele-order --recode vcf --out results/{params.name}.X; "

rule oxford2vcf:
    input:
        gen= "results/{name}.{chr}.chrfix.impute2",
        vcf= "results/{name}.{chr}.vcf"
    params:
        chr = "{chr}",
        name= "{name}"    
    output:
        vcf= temp("results/{name}.{chr}.vcf")
    conda:
        "envs/plink.yaml"
    shell:
        "plink --gen {input.gen} --sample results/{params.name}.{params.chr}.sample --hard-call-threshold 0.49 --keep-allele-order --recode vcf --out results/{params.name}.{params.chr}; "


rule oxford2vcfX:
    input:
        vcf= expand("results/{name}.X.vcf",name=NAME) ,
        genx= expand("results/{name}.X.chrfix.impute2",name=NAME)
    params:
        name= expand("{name}",name=NAME)       
    output:
        vcfx=  expand("results/{name}.X.vcf",name=NAME)
    conda:
        "envs/plink.yaml"
    shell:
        "plink --gen {input.genx} --sample results/{params.name}.X.sample --hard-call-threshold 0.49 --keep-allele-order --recode vcf --out results/{params.name}.X; "

rule bcftools_concat:
    input:
        vcf= expand("results/{name}.{chr}.vcf",name=NAME,chr=CHR),
    output:
        list= temp("results/vcf_list.txt"),
        vcf= temp(expand("results/{name}.imputed.vcf",name=NAME))
    params:
        name= expand("{name}",name=NAME)    
    conda:
        "envs/bcftools.yaml"    
    shell:
        "ls {input.vcf} > {output.list};"
        "bcftools concat --file-list {output.list} -o {output.vcf};"    

rule Cosmic_annotate:
    input:
        original=expand("results/{name}.original.vcf",name=NAME),
        imputed=expand("results/{name}.imputed.vcf",name=NAME),
        database=COSMIC,
        script = "scripts/COSMIC.R"
    output:
        original=temp(expand("results/{name}.original.COSMIC.vcf",name=NAME)),
        imputed=temp(expand("results/{name}.imputed.COSMIC.vcf",name=NAME)) 
    shell:
        "Rscript --vanilla {input.script} {input.original} {input.database} {output.original}; "
        "Rscript --vanilla {input.script} {input.imputed} {input.database} {output.imputed}; "

rule ClinVar_annotate:
    input:
        original=expand("results/{name}.original.COSMIC.vcf",name=NAME),
        imputed=expand("results/{name}.imputed.COSMIC.vcf",name=NAME),
        database=CLINVAR,
        script = "scripts/ClinVar.R"
    output:
        original=temp(expand("results/{name}.original.ClinVar.vcf",name=NAME)),
        imputed=temp(expand("results/{name}.imputed.ClinVar.vcf",name=NAME))
    shell:
        "Rscript --vanilla {input.script} {input.original} {input.database} {output.original}; "
        "Rscript --vanilla {input.script} {input.imputed} {input.database} {output.imputed}; "
        
rule gwas:
    input:
        original=expand("results/{name}.original.ClinVar.vcf",name=NAME),
        imputed=expand("results/{name}.imputed.ClinVar.vcf",name=NAME),
        database=GWAS,
        script = "scripts/GWAS.R"
    output:
        original=expand("results/{name}.original.Annot.vcf",name=NAME),
        imputed=expand("results/{name}.imputed.Annot.vcf",name=NAME) 
    shell:
        "Rscript --vanilla {input.script} {input.original} {input.database} {output.original}; "
        "Rscript --vanilla {input.script} {input.imputed} {input.database} {output.imputed}; "
