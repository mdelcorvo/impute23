def get_cosmic(wildcards):
    if {ref} == 'hg38':
        return config["database_url"]["GRCh38"]["Cosmic"]
    else:
        return config["database_url"]["GRCh37"]["Cosmic"]
        
def get_clinvar(wildcards):
    if {ref} == 'hg38':
        return config["database_url"]["GRCh38"]["ClinVar"]
    else:
        return config["database_url"]["GRCh37"]["ClinVar"]
        
def get_reference(wildcards):
    if {ref} == 'hg38':
        return config["database_url"]["GRCh38"]["reference_data"] # needs to be added
    else:
        return config["database_url"]["GRCh37"]["reference_data"]       

