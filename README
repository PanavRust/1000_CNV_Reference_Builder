![Bash](https://img.shields.io/badge/Bash-Scripting-green)
![WGS](https://img.shields.io/badge/WGS-30x-blue)
![Genome](https://img.shields.io/badge/Genome-GRCh38-orange)
![CNV](https://img.shields.io/badge/CNV-CNVkit-purple)
![Status](https://img.shields.io/badge/status-active-brightgreen)

# 🧬 1000G CNV Reference Builder

## 📌 Overview

This repository contains a reproducible bioinformatics workflow for constructing a **high-quality Whole Genome Sequencing (WGS) CNV reference cohort** using the **1000 Genomes Project high-coverage (~30×) GRCh38 dataset**.

The workflow demonstrates practical handling of large-scale public genomic datasets including **sample selection, CRAM acquisition, batch processing, quality control, and reference cohort preparation** for downstream **copy number variation (CNV)** analysis.

This project is designed as a **portfolio-ready implementation** inspired by real-world genomics workflows used in research and clinical sequencing environments.

---

## ⚙️ Workflow

```text
1000 Genomes High Coverage Dataset
                ↓
Founder / Unrelated Sample Selection
                ↓
Random Sample Selection
                ↓
Batch Generation
                ↓
CRAM + CRAI Download
                ↓
Coverage Quality Control
                ↓
Reference Cohort Selection
                ↓
CNVkit Panel of Normals (PoN)
```

---

## 🧩 Repository Architecture

```text
1000G-CNV-Reference-Builder
│
├── download_1000G_crams.sh
├── make_batches.sh
├── coverage_qc.sh
│
├── example
│   ├── sample_ids.txt
│   └── batch1.txt
│
├── logs
│
└── README.md
```

The workflow is implemented using modular Bash scripts to enable reproducibility and scalability for large WGS datasets.

---

## 🛠️ Tools & Technologies

- Bash / Linux
- samtools
- wget
- awk
- 1000 Genomes Project
- ENA FTP
- CNVkit
- CRAM / CRAI
- WGS Data Processing

---

## ▶️ Running the Workflow

### Step 1 — Generate Founder Sample IDs

```bash
awk 'NR>1 && $2==0 && $3==0 {print $1}' \
1000G_30x_samples.tsv \
> unrelated_ids.txt
```

---

### Step 2 — Select Samples

```bash
shuf unrelated_ids.txt | head -40 > sample_ids.txt
```

---

### Step 3 — Create Download Batches

```bash
./make_batches.sh
```

Example output:

```text
batch1.txt
batch2.txt
batch3.txt
```

---

### Step 4 — Download CRAM Files

```bash
./download_1000G_crams.sh
```

The workflow supports:

- Resume-safe downloading
- Automatic CRAM URL extraction
- CRAI index downloading
- Integrity checks
- Failure logging

---

### Step 5 — Coverage QC

Estimate average sequencing coverage:

```bash
samtools depth -a sample.cram | \
awk '{sum+=$3} END {print sum/NR}'
```

Recommended coverage threshold:

```text
28×–35×
```

---

## 📊 Outputs

The workflow generates:

- High-coverage WGS CRAM files
- CRAI index files
- Download logs
- Coverage QC summaries
- Candidate CNV reference cohort

---

## 🎯 Skills Demonstrated

- Public genomic data acquisition
- WGS data handling
- Bash scripting & automation
- Large-scale genomic data management
- Quality control (QC)
- Reproducible bioinformatics workflows
- CNV reference cohort generation
- Linux / HPC workflow management

---

## ⚠️ Disclaimer

This workflow is intended for **research and educational purposes** and demonstrates a reproducible approach for constructing a CNV reference cohort using public WGS datasets.

It is **not intended for clinical use**.

---

## 👨‍💻 Author

**Panav Rustagi**  
Bioinformatics Graduate – University of Bristol  

Experience in **genomic data analysis, NGS pipelines, and bioinformatics workflow development**
