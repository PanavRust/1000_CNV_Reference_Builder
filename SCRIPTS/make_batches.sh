#!/bin/bash

###############################################################
# 1000G CNV Reference Builder
# Create batch files from sample list
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
    ./make_batches.sh \
        -i sample_ids.txt \
        -b 5

Required arguments:
    -i    Sample ID file (one sample per line)
    -b    Batch size

Optional arguments:
    -o    Output directory (default: current directory)

Example:
    ./make_batches.sh \
        -i sample_ids.txt \
        -b 5 \
        -o batches/

EOF
exit 1
}

############################
# DEFAULTS
############################

OUTPUT_DIR="."

############################
# ARGUMENT PARSING
############################

while getopts "i:b:o:h" opt; do
    case $opt in
        i) INPUT_FILE="$OPTARG" ;;
        b) BATCH_SIZE="$OPTARG" ;;
        o) OUTPUT_DIR="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

############################
# VALIDATION
############################

if [[ -z "${INPUT_FILE:-}" ]] || \
   [[ -z "${BATCH_SIZE:-}" ]]; then
    usage
fi

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "[ERROR] Input file not found: $INPUT_FILE"
    exit 1
fi

if ! [[ "$BATCH_SIZE" =~ ^[0-9]+$ ]]; then
    echo "[ERROR] Batch size must be numeric"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

############################
# START
############################

echo "=============================================="
echo "🧬 Batch File Generator"
echo "=============================================="
echo "Input File : $INPUT_FILE"
echo "Batch Size : $BATCH_SIZE"
echo "Output Dir : $OUTPUT_DIR"
echo "=============================================="

############################
# CLEAN OLD BATCH FILES
############################

rm -f "${OUTPUT_DIR}"/batch*.txt

############################
# GENERATE BATCHES
############################

batch_num=1
count=0

while read -r SAMPLE || [[ -n "$SAMPLE" ]]; do

    echo "$SAMPLE" >> "${OUTPUT_DIR}/batch${batch_num}.txt"

    ((count++))

    if (( count == BATCH_SIZE )); then
        ((batch_num++))
        count=0
    fi

done < "$INPUT_FILE"

############################
# SUMMARY
############################

echo ""
echo "=============================================="
echo "✅ Batch creation complete"
echo "=============================================="

TOTAL_BATCHES=$(ls "${OUTPUT_DIR}"/batch*.txt 2>/dev/null | wc -l)

echo "Total batches created: $TOTAL_BATCHES"
echo ""

for file in "${OUTPUT_DIR}"/batch*.txt; do
    num_samples=$(wc -l < "$file")
    echo "$(basename "$file") : $num_samples samples"
done

echo "=============================================="
