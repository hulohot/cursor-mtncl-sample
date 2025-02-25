#!/usr/bin/env python3
# generate_vectors.py
#
# Simple script to generate test vectors for MTNCL Full Adder

import csv
import random
import os
from pathlib import Path

def generate_test_vectors(count, width, filepath):
    """Generate random test vectors for MTNCL testing"""
    max_value = (1 << width) - 1
    
    # Create directory if it doesn't exist
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    
    with open(filepath, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['a', 'b', 'cin', 'sum', 'cout'])
        
        for _ in range(count):
            a = random.randint(0, max_value)
            b = random.randint(0, max_value)
            cin = random.randint(0, 1)
            
            # Default operation: addition
            sum_out = (a + b + cin) & 1  # Get LSB for sum
            cout_out = 1 if (a + b + cin) > 1 else 0  # Generate carry if sum > 1
            
            writer.writerow([a, b, cin, sum_out, cout_out])
    
    print(f"Generated {count} test vectors in {filepath}")
    return filepath

if __name__ == "__main__":
    # Generate vectors for full adder
    generate_test_vectors(20, 1, './vectors/full_adder_test_vectors.csv')
    
    # Generate vectors for full adder stage
    generate_test_vectors(20, 1, './vectors/full_adder_stage_test_vectors.csv') 