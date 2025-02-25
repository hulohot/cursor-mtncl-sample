# MTNCL_FullAdder_tb.py
#
# Author: Claude
# Date: February 25, 2024
#
# Description:
# Testbench for MTNCL_FullAdder

import cocotb
from cocotb.triggers import Timer
import os
import csv
from pathlib import Path

# Add path to common functions
import sys
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
from mtncl_utils import *

# Test parameters
RUN_DIR = Path('./run')
VECTOR_FILE = Path('./vectors/full_adder_test_vectors.csv')

async def initialize_dut(dut):
    """Initialize the DUT with reset values"""
    dut.sleep.value = 1  # Start with sleep active
    await Timer(10, units='ns')

async def cycle_sleep(dut, sleep_time=20):
    """Generate a complete DATA/NULL cycle"""
    # Set to active mode (allow combinational logic to work)
    dut.sleep.value = 0
    await Timer(sleep_time, units='ns')
    
    # Check for DATA on output
    while await is_null(dut.sum) or await is_null(dut.cout):
        await Timer(1, units='ns')
    
    # Sleep for NULL wavefront
    dut.sleep.value = 1
    await Timer(sleep_time, units='ns')
    
    # Check for NULL on output
    while not (await is_null(dut.sum) and await is_null(dut.cout)):
        await Timer(1, units='ns')

@cocotb.test()
async def test_mtncl_full_adder(dut):
    """Test the MTNCL Full Adder with vectors from file"""
    # Create run directory if it doesn't exist
    RUN_DIR.mkdir(exist_ok=True)
    
    # Initialize DUT
    await initialize_dut(dut)
    
    # Generate test vectors if they don't exist
    if not VECTOR_FILE.exists():
        VECTOR_FILE.parent.mkdir(exist_ok=True)
        generate_test_vectors(20, 1, VECTOR_FILE)
    
    # Open test vector file
    with open(VECTOR_FILE, mode='r') as f:
        reader = csv.DictReader(f)
        
        # Open results file
        with open(RUN_DIR / 'results.csv', mode='w') as results_file:
            fieldnames = ['test_case', 'a', 'b', 'cin', 'expected_sum', 'expected_cout', 'actual_sum', 'actual_cout', 'status']
            writer = csv.DictWriter(results_file, fieldnames=fieldnames)
            writer.writeheader()
            
            # Process each test vector
            for i, row in enumerate(reader):
                test_case = f"Vector {i}"
                
                # Set input values
                a_value = int(row['a']) & 1
                b_value = int(row['b']) & 1
                cin_value = int(row['cin']) & 1
                
                # For a full adder, we need to derive cin from the test vector
                # For simplicity, we'll use the LSB of expected as cin
                expected_sum = int(row['sum'])
                expected_cout = int(row['cout'])
                
                # Calculate expected outputs for a full adder
                expected_sum = (a_value + b_value + cin_value) & 1
                expected_cout = 1 if (a_value + b_value + cin_value) > 1 else 0
                
                # Set dual-rail inputs
                if a_value == 0:
                    dut.a.rail0.value = 1
                    dut.a.rail1.value = 0
                else:
                    dut.a.rail0.value = 0
                    dut.a.rail1.value = 1
                
                if b_value == 0:
                    dut.b.rail0.value = 1
                    dut.b.rail1.value = 0
                else:
                    dut.b.rail0.value = 0
                    dut.b.rail1.value = 1
                
                if cin_value == 0:
                    dut.cin.rail0.value = 1
                    dut.cin.rail1.value = 0
                else:
                    dut.cin.rail0.value = 0
                    dut.cin.rail1.value = 1
                
                # Run a DATA/NULL cycle
                await cycle_sleep(dut)
                
                # Check output
                actual_sum = 1 if dut.sum.rail1.value == 1 else 0
                actual_cout = 1 if dut.cout.rail1.value == 1 else 0
                
                status = "PASS" if (actual_sum == expected_sum and actual_cout == expected_cout) else "FAIL"
                
                # Log results
                writer.writerow({
                    'test_case': test_case,
                    'a': a_value,
                    'b': b_value,
                    'cin': cin_value,
                    'expected_sum': expected_sum,
                    'expected_cout': expected_cout,
                    'actual_sum': actual_sum,
                    'actual_cout': actual_cout,
                    'status': status
                })
                
                if status == "FAIL":
                    dut._log.error(f"Test case {test_case} failed: expected sum={expected_sum}, cout={expected_cout}, got sum={actual_sum}, cout={actual_cout}")
                else:
                    dut._log.info(f"Test case {test_case} passed") 