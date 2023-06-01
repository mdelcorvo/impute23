rule Cosmic_annotate:
    input:
        original=expand("results/{name}.original.vcf",name=NAME),
        imputed=expand("imputed/{name}.imputed.vcf",name=NAME),
        database=COSMIC,
        script = "scripts/COSMIC.R"
    output:
        original=temp(expand("results/{name}.original.COSMIC.vcf",name=NAME)),
        imputed=temp(expand("imputed/{name}.imputed.COSMIC.vcf",name=NAME)) 
    shell:
        "Rscript --vanilla {input.script} {input.original} {input.database} {output.original}; "
        "Rscript --vanilla {input.script} {input.imputed} {input.database} {output.imputed}; "

rule ClinVar_annotate:
    input:
        original=expand("results/{name}.original.COSMIC.vcf",name=NAME),
        imputed=expand("imputed/{name}.imputed.COSMIC.vcf",name=NAME),
        database=CLINVAR,
        script = "scripts/ClinVar.R"
    output:
        original=temp(expand("results/{name}.original.ClinVar.vcf",name=NAME)),
        imputed=temp(expand("imputed/{name}.imputed.ClinVar.vcf",name=NAME))
    shell:
        "Rscript --vanilla {input.script} {input.original} {input.database} {output.original}; "
        "Rscript --vanilla {input.script} {input.imputed} {input.database} {output.imputed}; "
        
rule gwas:
    input:
        original=expand("results/{name}.original.ClinVar.vcf",name=NAME),
        imputed=expand("imputed/{name}.imputed.ClinVar.vcf",name=NAME),
        database=GWAS,
        script = "scripts/GWAS.R"
    output:
        original=expand("results/{name}.original.Annot.vcf",name=NAME),
        imputed=expand("imputed/{name}.imputed.Annot.vcf",name=NAME) 
    shell:
        "Rscript --vanilla {input.script} {input.original} {input.database} {output.original}; "
        "Rscript --vanilla {input.script} {input.imputed} {input.database} {output.imputed}; "
