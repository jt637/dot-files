#!/usr/bin/env bash

# Function to display help
show_help() {
    echo "Usage: $(basename "$0") [options]"
    echo
    echo "Options:"
    echo "  -h, --help        Show this help message"
    echo "  -v, --verbose     Enable verbose mode"
}

# Parse arguments using case statement
while [[ $# -gt 0 ]]; do
    case "$1" in
    -h|--help)
        show_help
        exit 0
        ;;
    -v|--verbose)
        set -x

        shift
        ;;
    *)
        echo "Error: Unknown option '$1'"
        show_help
        exit 1
        ;;
    esac
done
