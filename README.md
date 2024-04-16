# Memory Analysis Tool

This script automates the analysis of memory allocation and leak detection in C programs using Valgrind. It helps identify issues by simulating memory allocation failures and provides a clean environment to manage output from multiple test runs.

## Features

- **Automated Memory Leak Detection**: Detects leaks with Valgrind.
- **Progressive Malloc Failure Testing**: Simulates malloc failures to test error handling.
- **Clean Output Management**: Redirects outputs to dedicated directories.

## Prerequisites

- **Valgrind**: Ensure Valgrind is installed on your system.
- **Bash Shell**: This script requires Bash.
- **Executable Program**: Your target C program must be compiled.

## Usage

Run the script by passing the name of your compiled program and any required arguments:

```bash
./test_mallocs.sh <program_name> [program_args...]
