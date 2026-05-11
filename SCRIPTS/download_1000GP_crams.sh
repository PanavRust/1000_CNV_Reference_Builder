#!/bin/bash

###############################################################
# 1000G CNV Reference Builder
# Download high-coverage (~30x) WGS CRAMs from
# 1000 Genomes Project using sequence index
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
    ./download_1000G_crams.sh \
        -i sample_ids.txt \
        -s 1000G_2504_high_coverage.sequence.index \
        -o output_directory

Required arguments:
    -i    Sample ID file (one sample per line)
    -s    1000 Genomes sequence index file
    -o    Output directory

Example:
    ./download_1000G_crams.sh \
        -i sample_ids.txt \
        -s 1000G_2504_high_coverage.sequence.index \
        -o cnv_reference

EOF
exit 1
}

############################
# ARGUMENT PARSING
############################

while getopts "i:s:o:h" opt; do
    case $opt in
        i) INPUT_SAMPLE_LIST="$OPTARG" ;;
        s) SEQUENCE_INDEX="$OPTARG" ;;
        o) OUTPUT_DIR="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

############################
# VALIDATION
############################

if [[ -z "${INPUT_SAMPLE_LIST:-}" ]] || \
   [[ -z "${SEQUENCE_INDEX:-}" ]] || \
   [[ -z "${OUTPUT_DIR:-}" ]]; then
    usage
fi

if [[ ! -f "$INPUT_SAMPLE_LIST" ]]; then
    echo "[ERROR] Sample list not found: $INPUT_SAMPLE_LIST"
    exit 1
fi

if [[ ! -f "$SEQUENCE_INDEX" ]]; then
    echo "[ERROR] Sequence index not found: $SEQUENCE_INDEX"
    exit 1
fi

############################
# CREATE OUTPUT STRUCTURE
############################

mkdir -p "${OUTPUT_DIR}"/{cram,crai,logs}

FAILED_LOG="${OUTPUT_DIR}/logs/failed_downloads.log"
SUCCESS_LOG="${OUTPUT_DIR}/logs/successful_downloads.log"

touch "$FAILED_LOG"
touch "$SUCCESS_LOG"

############################
# START MESSAGE
############################

echo "=============================================="
echo "🧬 1000G CNV Reference Downloader"
echo "=============================================="
echo "Sample List    : $INPUT_SAMPLE_LIST"
echo "Sequence Index : $SEQUENCE_INDEX"
echo "Output Folder  : $OUTPUT_DIR"
echo "=============================================="

############################
# DOWNLOAD LOOP
############################

while read -r SAMPLE || [[ -n "$SAMPLE" ]]; do

    echo ""
    echo "----------------------------------------------"
    echo "[INFO] Processing sample: $SAMPLE"
    echo "----------------------------------------------"

    ############################
    # FIND CRAM URL
    ############################

    CRAM_URL=$(grep -w "$SAMPLE" "$SEQUENCE_INDEX" \
        | grep "final.cram" \
        | cut -f1 \
        | head -1)

    if [[ -z "$CRAM_URL" ]]; then
        echo "[ERROR] URL not found for $SAMPLE"
        echo "$SAMPLE : URL not found" >> "$FAILED_LOG"
        continue
    fi

    CRAI_URL="${CRAM_URL}.crai"

    ############################
    # OUTPUT FILE PATHS
    ############################

    CRAM_OUT="${OUTPUT_DIR}/cram/${SAMPLE}.cram"
    CRAI_OUT="${OUTPUT_DIR}/crai/${SAMPLE}.cram.crai"

    ############################
    # DOWNLOAD CRAM
    ############################

    echo "[INFO] Downloading CRAM..."
    echo "$CRAM_URL"

    if wget -c -O "$CRAM_OUT" "$CRAM_URL"; then
        echo "[SUCCESS] CRAM downloaded"
    else
        echo "[ERROR] CRAM failed for $SAMPLE"
        echo "$SAMPLE : CRAM failed" >> "$FAILED_LOG"
        continue
    fi

    ############################
    # DOWNLOAD CRAI
    ############################

    echo "[INFO] Downloading CRAI..."

    if wget -c -O "$CRAI_OUT" "$CRAI_URL"; then
        echo "[SUCCESS] CRAI downloaded"
    else
        echo "[ERROR] CRAI failed for $SAMPLE"
        echo "$SAMPLE : CRAI failed" >> "$FAILED_LOG"
        continue
    fi

    ############################
    # FILE INTEGRITY CHECK
    ############################

    echo "[INFO] Checking CRAM integrity..."

    if samtools quickcheck "$CRAM_OUT"; then
        echo "[SUCCESS] Integrity check passed"
    else
        echo "[ERROR] Corrupt CRAM: $SAMPLE"
        echo "$SAMPLE : Corrupt CRAM" >> "$FAILED_LOG"
        continue
    fi

    ############################
    # SUCCESS LOG
    ############################

    echo "$SAMPLE" >> "$SUCCESS_LOG"

    echo "[DONE] $SAMPLE completed successfully"

done < "$INPUT_SAMPLE_LIST"

############################
# SUMMARY
############################

echo ""
echo "=============================================="
echo "✅ DOWNLOAD COMPLETE"
echo "=============================================="

echo "Successful downloads:"
wc -l "$SUCCESS_LOG"

echo "Failed downloads:"
wc -l "$FAILED_LOG"

echo ""
echo "Downloaded CRAM files:"
ls "${OUTPUT_DIR}/cram" | wc -l

echo "=============================================="
