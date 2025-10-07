# Pseudoreference workflow
This Nextflow workflow automates a **population genomics pipeline**, focusing on **sample processing, parameter optimization, catalog preprocessing, and SNP calling** using the `stacks` workflow and related tools. The workflow is containerized for reproducibility.

---

## Parameters

| Parameter            | Description                                      |
|----------------------|--------------------------------------------------|
| `samples_json`       | Path to a JSON file listing samples.             |
| `popmap`             | Path to a population map file.                   |
| `parameter_min_val`  | Minimum value for parameter optimization.        |
| `parameter_max_val`  | Maximum value for parameter optimization.        |

---

## Workflow Overview

### 1. `download_samples`
- **Purpose**: Downloads and organizes sample data.
- **Inputs**: `samples_json`, `popmap`.
- **Output**: Directory `samples/` containing sample files.
- **Script**: Runs a custom script (`download_samples.sh`) to fetch samples into the `samples/` directory.

### 2. `parameter_optimization`
- **Purpose**: Optimizes parameters for the `stacks` assembly.
- **Inputs**: Sample data, `popmap`, and parameter bounds.
- **Outputs**:
  - `best_params_path.txt`: Path to the best assembly.
  - `param_vals_nm.txt`: Parameter values.
  - `stacks_best_assembly/`: Best assembly directory.
- **Script**:
  - Runs `parameter_optimization.py` to find optimal parameters.
  - Copies the best assembly and runs `populations` (from `stacks`) with `-R 0.4` to generate population-level statistics.

### 3. `preprocess_catalog`
- **Purpose**: Filters and annotates the catalog of loci.
- **Input**: Best assembly from `parameter_optimization`.
- **Output**: Filtered, BLASTed catalog (`catalog_R04_max10snp_blasted.fa.gz`).
- **Script**:
  - Filters loci with ≤10 SNPs.
  - BLASTs loci against a database (`nt_euk`) to remove non-plant sequences.
  - Compresses the final catalog.

### 4. `pseudo_refmap`
- **Purpose**: Aligns samples to the reference catalog and calls SNPs.
- **Inputs**: Sample data, `popmap`, preprocessed catalog.
- **Output**: Directory `populations/` with SNP calls.
- **Script**:
  - Prepares a reference (indexes, creates dictionaries).
  - Aligns each sample to the catalog using `bowtie2`.
  - Processes alignments (sorting, adding read groups, indexing, realigning indels).
  - Runs `ref_map.pl` and `populations` (from `stacks`) to generate SNP calls, filtering for loci with ≤10 SNPs and requiring a minimum allele count of 3.

---

## Workflow Execution
1. **Channels**: Passes parameters and files between processes.
2. **Process Order**:
   `download_samples` → `parameter_optimization` → `preprocess_catalog` → `pseudo_refmap`
3. **Output**: Final SNP calls in `populations/`.

---

## Key Tools/Libraries
- **Containers**: Each process runs in a Docker container for reproducibility.
- **Stacks**: Used for population genomics (assembly, SNP calling).
- **BLAST**: Filters non-plant loci.
- **Bowtie2, Picard, GATK, Samtools**: For alignment and processing.

---
