#!/bin/bash

# Usage function
usage() {
    echo "Usage: $0 <program_name> [program_args...]"
    echo "Analyzes the program for the number of malloc calls and tests malloc failures progressively with provided arguments."
    exit 1
}

# Function to check and print memory leaks
check_memory_leaks() {
    local output_file="$1"
    # Check for all kinds of memory leaks and ensure default values if no matches are found
    local definitely_lost=$(grep "definitely lost:" "$output_file" | awk '{print $4}')
    local indirectly_lost=$(grep "indirectly lost:" "$output_file" | awk '{print $4}' )
    local possibly_lost=$(grep "possibly lost:" "$output_file" | awk '{print $4}')
    local still_reachable=$(grep "still reachable:" "$output_file" | awk '{print $4}')

    # Ensure the variables are not empty and set them to zero if they are
    definitely_lost=${definitely_lost:-0}
    indirectly_lost=${indirectly_lost:-0}
    possibly_lost=${possibly_lost:-0}
    still_reachable=${still_reachable:-0}

    # Summarize and check for any leaks
    if [ "$definitely_lost" != "0" ] || [ "$indirectly_lost" != "0" ] || [ "$possibly_lost" != "0" ] || [ "$still_reachable" != "0" ]; then
        echo "Memory leak summary from $output_file:"
        echo "Definitely lost: $definitely_lost bytes"
        echo "Indirectly lost: $indirectly_lost bytes"
        echo "Possibly lost: $possibly_lost bytes"
        echo "Still reachable: $still_reachable bytes"
        return 1
    else
        echo "No memory leaks detected in $output_file."
        return 0
    fi
}

# Function to run the program with Valgrind
run_valgrind() {
    local valgind_output_file="$OUTPUT_DIR/valgrind_output_$1.txt"
    local programm_output_file="$OUTPUT_DIR/program_output_$1.txt"
    shift
    valgrind --leak-check=full --show-leak-kinds=all --log-file="$valgind_output_file" ./$PROGRAM_NAME "$@" > "$programm_output_file" 2>&1
}

# Check if at least the program name was provided
if [ "$#" -lt 1 ]; then
    usage
fi

PROGRAM_NAME=$1
shift  # Remove the first argument, which is the program name

# Directory for Valgrind outputs
OUTPUT_DIR="valgrind_reports"
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Initial run with Valgrind
run_valgrind "0" "$@"
cat $OUTPUT_DIR/valgrind_output_0.txt

# Extract and display total allocations
count_mallocs=$(grep "total heap usage" $OUTPUT_DIR/valgrind_output_0.txt | awk '{print $5}')
echo "Total allocation requests (approx. mallocs): $count_mallocs"

# Check memory leaks on initial run
check_memory_leaks "$OUTPUT_DIR/valgrind_output_0.txt"
initial_leak_status=$?

# Step 2: Fail each malloc call progressively
for ((i = 1; i <= count_mallocs; i++)); do
    echo "Run $i: Failing the $i-th malloc call"
    run_valgrind "$i" "$@"
    check_memory_leaks "$OUTPUT_DIR/valgrind_output_$i.txt"
done

exit $initial_leak_status
