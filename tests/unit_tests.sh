#!/bin/bash

function test_dummy {
    # Example of a simple condition test in Bash
    expected=1
    actual=1
    if [ "$actual" -eq "$expected" ]; then
        echo "Test passed."
    else
        echo "Test failed."
        exit 1  # Exits the script with an error code of 1
    fi
}

test_dummy  # Call the function to execute the test
