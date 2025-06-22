#!/bin/bash

validate_name() {
    [[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]
}


trim() {
    echo "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}


get_column_index() {
    local col="$1"
    local meta_file="$2"

    if [ ! -f "$meta_file" ]; then
        echo "Error: Metadata file '$meta_file' not found." >&2
        return 1
    fi

    local line_num=0
    while IFS='|' read -r col_name _ _; do
        line_num=$((line_num + 1))
        if [[ "$col_name" == "$col" ]]; then
            echo "$line_num"
            return 0
        fi
    done < "$meta_file"

    # If not found
    return 1
}
