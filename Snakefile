# Snakefile workflow for the imputation and annotation of SNPs
# of 23andMe genotyping files

# Copyright 2023 Marcello Del Corvo.
# Licensed under the MIT license (http://opensource.org/licenses/MIT)
# This file may not be copied, modified, or distributed
# except according to those terms.

import pandas as pd
from snakemake.utils import validate
from snakemake.utils import min_version
samples = pd.read_table(config["input"], dtype=str).set_index(["sample"], drop=False)


configfile: 'config/config.yaml'
db = config['db']
ref = config["ref"]["build"]
chrs = tuple( str(chr) for chr in range(1, 22)) + ('X', 'Y', 'M')


rule all:
    input:
        expand("resources/database/{ref}/COSMIC.vcf.gz.tbi", ref=config["ref"]["build"]),
        expand("imputed/{sample}.imputed.vcf",sample=samples['sample']) 
        
##### Modules #####
include: "rules/common.smk"
include: "rules/database.smk"
#include: "rules/annotation.smk"

if config['impute']:
    include: "rules/impute.smk"

