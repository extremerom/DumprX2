#!/usr/bin/env bash

# organize_system_files.sh
# Helper script to organize large system directory dumps into manageable commits
# This avoids git push errors when dealing with large firmware extractions

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_DIR="${1:-system}"

echo "==========================================="
echo "System Files Organization Helper"
echo "==========================================="
echo ""

if [ ! -d "$SYSTEM_DIR" ]; then
    echo "Error: System directory '$SYSTEM_DIR' not found!"
    echo "Usage: $0 [system_directory_path]"
    exit 1
fi

cd "$SCRIPT_DIR"

# Check if Git LFS is installed
if ! command -v git-lfs &> /dev/null; then
    echo "Warning: Git LFS is not installed!"
    echo "Installing Git LFS is recommended for handling large binary files."
    echo "Install with: sudo apt-get install git-lfs && git lfs install"
    echo ""
    read -p "Continue without Git LFS? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo "✓ Git LFS is installed"
    # Track .spv files with Git LFS if .gitattributes exists
    if [ -f ".gitattributes" ]; then
        echo "✓ Git LFS tracking configured in .gitattributes"
    fi
fi

echo ""
echo "Analyzing system directory..."

# Count total files
TOTAL_FILES=$(find "$SYSTEM_DIR" -type f | wc -l)
echo "Total files found: $TOTAL_FILES"

# Count and analyze .spv files specifically
SPV_COUNT=$(find "$SYSTEM_DIR" -name "*.spv" -type f | wc -l)
if [ "$SPV_COUNT" -gt 0 ]; then
    SPV_SIZE=$(find "$SYSTEM_DIR" -name "*.spv" -type f -exec du -ch {} + | grep total$ | awk '{print $1}')
    echo "SPV files found: $SPV_COUNT (total size: $SPV_SIZE)"
fi

# Calculate directory size
TOTAL_SIZE=$(du -sh "$SYSTEM_DIR" | awk '{print $1}')
echo "Total directory size: $TOTAL_SIZE"

echo ""
echo "==========================================="
echo "Recommendation:"
echo "==========================================="

if [ "$SPV_COUNT" -gt 0 ]; then
    echo ""
    echo "1. Commit .spv files separately (binary shader files)"
    echo "   These files are tracked by Git LFS to avoid size limits"
    echo ""
    echo "   git add $SYSTEM_DIR/**/*.spv"
    echo "   git commit -m 'Add SPV shader binary files'"
    echo ""
fi

echo "2. Split remaining system files into logical parts:"
echo ""
echo "   Part 1: Configuration files (etc/)"
echo "   git add $SYSTEM_DIR/**/etc/**/*.xml"
echo "   git add $SYSTEM_DIR/**/etc/**/*.conf"
echo "   git add $SYSTEM_DIR/**/etc/**/*.txt"
echo "   git commit -m 'Add system configuration files (Part 1/5)'"
echo ""

echo "   Part 2: Certificate files"
echo "   git add $SYSTEM_DIR/**/etc/epdg/certificates/"
echo "   git commit -m 'Add certificate files (Part 2/5)'"
echo ""

echo "   Part 3: Init and service files"
echo "   git add $SYSTEM_DIR/**/etc/init/"
echo "   git commit -m 'Add init and service files (Part 3/5)'"
echo ""

echo "   Part 4: Font and display configuration"
echo "   git add $SYSTEM_DIR/**/etc/font*"
echo "   git add $SYSTEM_DIR/**/etc/display*"
echo "   git commit -m 'Add font and display configuration (Part 4/5)'"
echo ""

echo "   Part 5: Remaining system files"
echo "   git add $SYSTEM_DIR"
echo "   git commit -m 'Add remaining system files (Part 5/5)'"
echo ""

echo "==========================================="
echo "Alternative: Use Git LFS for all large files"
echo "==========================================="
echo ""
echo "If you continue to have issues, ensure all large binary files"
echo "are tracked by Git LFS by updating .gitattributes"
echo ""

echo "Note: After organizing files, push with:"
echo "  git push origin <branch-name>"
echo ""
