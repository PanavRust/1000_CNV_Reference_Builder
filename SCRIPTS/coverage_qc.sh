#!/bin/bash

###############################################################
# 1000G CNV Reference Builder
# Coverage QC for downloaded CRAM files
#
# Author: Panav Rustagi
###############################################################

set -euo pipefail

############################
# HELP FUNCTION
############################

usage() {
cat << EOF

Usage:
    ./coverage_qc.sh \
        -i cram_directory \
        -o coverage_summary.tsv

Required arguments:
    -i    Directory containing CRAM files
    -o    Output summary file

Optional arguments:
    -t    Number of threads (default: 4)

Example:
    ./coverage_qc.sh \
        -i /DATADR/Panav_Rust/cnv_baseline/cram \
        -o coverage_summary.tsv

EOF
exit 1
}

############################
# DEFAULTS
############################

THREADS=4

############################
# ARGUMENT PARSING
############################

while getopts "i:o:t:h" opt; do
    case $opt in
        i) INPUT_DIR="$OPTARG" ;;
        o) OUTPUT_FILE="$OPTARG" ;;
        t) THREADS="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

############################
# VALIDATION
############################

if [[ -z "${INPUT_DIR:-}" ]] || \
   [[ -z "${OUTPUT_FILE:-}" ]]; then
    usage
fi

if [[ ! -d "$INPUT_DIR" ]]; then
    echo "[ERROR] Input directory not found: $INPUT_DIR"
    exit 1
fi

CRAM_COUNT=$(find "$INPUT_DIR" -name "*.cram" | wc -l)

if [[ "$CRAM_COUNT" -eq 0 ]]; then
    echo "[ERROR] No CRAM files found in $INPUT_DIR"
    exit 1
fi

############################
# START
############################

echo "=============================================="
echo "🧬 Coverage QC"
echo "=============================================="
echo "Input Directory : $INPUT_DIR"
echo "Output File     : $OUTPUT_FILE"
echo "CRAM Files      : $CRAM_COUNT"
echo "Threads         : $THREADS"
echo "=============================================="

############################
# OUTPUT HEADER
############################

echo -e "Sample\tMean_Coverage" > "$OUTPUT_FILE"

############################
# COVERAGE CALCULATION
############################

for cram in "$INPUT_DIR"/*.cram; do

    SAMPLE=$(basename "$cram" .cram)

    echo "[INFO] Processing: $SAMPLE"

    COVERAGE=$(samtools depth -@ "$THREADS" -a "$cram" | \
        awk '{sum+=$3} END {printf "%.2f", sum/NR}')

    echo -e "${SAMPLE}\t${COVERAGE}" >> "$OUTPUT_FILE"

done

############################
# SORT OUTPUT
############################

{
    head -n 1 "$OUTPUT_FILE"
    tail -n +2 "$OUTPUT_FILE" | sort -k2,2nr
} > "${OUTPUT_FILE}.tmp"

mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"

############################
# SUMMARY
############################

echo ""
echo "=============================================="
echo "✅ Coverage QC Complete"
echo "=============================================="

echo "Saved output:"
echo "$OUTPUT_FILE"

echo ""
echo "Top samples by coverage:"
head "$OUTPUT_FILE"

echo "=============================================="
