rule plink_editing:
    input:
        raw_data = "input/{sample}.txt",
        script = "scripts/edit_plink.R"
    params:
        name= "{sample}"    
    output:
        bim= "results/{sample}.bim",
        original="results/{sample}.original.vcf"
    conda:"../envs/plink.yaml"
	shell:
         """
         plink --23file {input.raw_data} --list-duplicate-vars
         
         plink --23file {input.raw_data} \
         --make-bed --out results/{params.name} \
         --snps-only just-acgt --exclude plink.dupvar
         
         Rscript --vanilla {input.script} results/{params.name}
         
         plink --bfile results/{params.name} --recode vcf --out results/{params.name}.original
         rm plink.dupvar
         rm plink.log
         """
         
rule plink2oxford:
    input:
        bim= "results/{sample}.bim"
    params:
        chr = "{chrs}",
        name= "{sample}"
    output:
        gen= "results/{sample}.{chrs}.gen"
    conda:
        "../envs/plink.yaml"
    shell:
         """
	     plink --bfile results/{params.name} \
	     --out results/{params.name}.{params.chr} \
	     --snps-only just-acgt --chr {params.chr} --export oxford
         """

rule impute:
    input:
        gen= "results/{sample}.{chrs}.gen",
        map= "resources/database/{ref}/ALL_1000G_phase1integrated_v3_impute/ALL_1000G_phase1integrated_v3_chr{chrs}_combined_b37.txt",
        hap= "resources/database/{ref}/ALL_1000G_phase1integrated_v3_impute/ALL_1000G_phase1integrated_v3_chr{chrs}_impute.hap.gz",
        legend= "resources/database/{ref}/ALL_1000G_phase1integrated_v3_impute/ALL_1000G_phase1integrated_v3_chr{chrs}_impute.legend.gz"
    params:
        chr = "{chrs}",
        name= "{sample}"
    output:
        imputed= temp("results/{sample}.{chrs}.impute2")
    conda:
        "../envs/impute2.yaml"
    shell:
         """
         impute2 -m {input.map} -h {input.hap} \
        -l {input.legend} -g {input.gen} \
        -int 20.4e6 20.5e6 -Ne 20000 -k 100 \
        -iter 100 -o {output.imputed};
         """

rule Fix2vcf:
    input:
        imputed= "results/{sample}.{chrs}.impute2",
    output:
        imputed_fixed= temp("results/{sample}.{chrs}.chrfix.impute2"),
        vcf= temp("results/{sample}.{chrs}.vcf") 
    params:
        chr= "{chrs}",
        name= "{sample}"
    shell:
         """
         awk '{{$1 = {params.chr}; print}}' {input.imputed} > {output.imputed_fixed};
         plink --gen results/{params.name}.{params.chr}.chrfix.impute2 \
         --sample results/{params.name}.{params.chr}.sample \
         --hard-call-threshold 0.49 --keep-allele-order \
         --recode vcf --out results/{params.name}.{params.chr};
         
         """
        
rule oxford2vcf:
    input:
        gen= "results/{sample}.{chrs}.chrfix.impute2",
        vcf= "results/{sample}.{chrs}.vcf"
    params:
        chr = "{chrs}",
        name= "{sample}"    
    output:
        vcf= temp("imputed/{sample}.{chrs}.vcf")
    conda:
        "../envs/plink.yaml"
    shell:
         """
         plink --gen {input.gen} --sample results/{params.name}.{params.chr}.sample \
         --hard-call-threshold 0.49 --keep-allele-order \
         --recode vcf --out results/{params.name}.{params.chr}
         
         ls {output.vcf} > "results/vcf_list.txt"
         
         """
         
rule bcftools_concat:
    input:
        vcf= expand("imputed/{sample}.{chrs}.vcf",sample=samples['sample'],chrs=chrs),
    output:
        list= temp("results/vcf_list.txt"),
        vcf= expand("imputed/{sample}.imputed.vcf",sample=samples['sample'])  
    conda:
        "../envs/bcftools.yaml"    
    shell:
         """
         ls {input.vcf} > {output.list};
         bcftools concat --file-list {output.list} -o {output.vcf};
         
         """
