#Snakefile for Imputation - Functional annotation - Correlation 
# with somatic/disease database of 23andMe genotyping files

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


rule all:
    input:
        expand("database/{ref}/COSMIC.vcf.gz.tbi", ref=config["ref"]["build"])
        

##### Modules #####
include: "rules/common.smk"
include: "rules/database.smk"

