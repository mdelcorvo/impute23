#Snakefile for Imputation - Functional annotation - Correlation 
# with somatic/disease database of 23andMe genotyping files

# Copyright 2023 Marcello Del Corvo.
# Licensed under the MIT license (http://opensource.org/licenses/MIT)
# This file may not be copied, modified, or distributed
# except according to those terms.


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
        
        
        
##### Modules #####

include: "rules/impute.smk"
include: "rules/annotation.smk"
