# mtncl_utils.py
#
# Utility functions for MTNCL testbenches

import cocotb
from cocotb.triggers import Timer
import random

# Basic dual-rail signal manipulation
async def is_null(signal):
    """Check if a dual-rail signal is NULL"""
    for i in range(len(signal)):
        if signal[i].rail0.value == 1 or signal[i].rail1.value == 1:
            return False
    return True

async def is_data(signal):
    """Check if a dual-rail signal is DATA"""
    return not await is_null(signal)

async def is_valid_dual_rail(signal):
    """Check if dual-rail signal has valid encoding (no both rails high)"""
    for i in range(len(signal)):
        if signal[i].rail0.value == 1 and signal[i].rail1.value == 1:
            return False
    return True

# Signal setting functions
async def set_dual_rail(signal, value, width):
    """Set a dual-rail signal to represent an integer value"""
    for i in range(width):
        bit = (value >> i) & 1
        if bit == 0:
            signal[i].rail0.value = 1
            signal[i].rail1.value = 0
        else:
            signal[i].rail0.value = 0
            signal[i].rail1.value = 1

async def set_null(signal, width):
    """Set a dual-rail signal to NULL state"""
    for i in range(width):
        signal[i].rail0.value = 0
        signal[i].rail1.value = 0

# Signal reading functions
async def get_dual_rail_value(signal, width):
    """Get integer value from dual-rail signal"""
    value = 0
    for i in range(width):
        if signal[i].rail1.value == 1:
            value |= (1 << i)
    return value

# Wavefront tracking
async def wait_for_value(signal, expected_value, width, timeout=1000):
    """Wait until the signal holds the expected value"""
    for _ in range(timeout):
        current = await get_dual_rail_value(signal, width)
        if current == expected_value:
            return True
        await Timer(1, units='ns')
    return False

async def wait_for_null(signal, timeout=1000):
    """Wait until the signal is NULL"""
    for _ in range(timeout):
        if await is_null(signal):
            return True
        await Timer(1, units='ns')
    return False

async def wait_for_data(signal, timeout=1000):
    """Wait until the signal has valid DATA"""
    for _ in range(timeout):
        if await is_data(signal):
            return True
        await Timer(1, units='ns')
    return False

# Test vector generation
def generate_test_vectors(count, width, filepath):
    """Generate random test vectors for MTNCL testing"""
    import csv
    
    max_value = (1 << width) - 1
    
    with open(filepath, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['input1', 'input2', 'expected'])
        
        for _ in range(count):
            a = random.randint(0, max_value)
            b = random.randint(0, max_value)
            
            # Default operation: addition
            result = (a + b) & max_value
            
            writer.writerow([a, b, result])
    
    return filepath

# Pipeline flow control helpers
async def manage_pipeline_flow(dut, num_cycles=10, sleep_time=20):
    """Handle pipeline flow control for multi-stage MTNCL circuits"""
    for cycle in range(num_cycles):
        # Sleep all stages
        dut.sleep.value = 1
        await Timer(sleep_time, units='ns')
        
        # Wake up for DATA wavefront
        dut.sleep.value = 0
        await Timer(sleep_time, units='ns')
        
        # Wait for completion detection
        while dut.ko.value != 0:
            await Timer(1, units='ns')
            
        # Acknowledge from downstream
        dut.ki.value = 0
        await Timer(sleep_time, units='ns')
        
        # Sleep for NULL wavefront
        dut.sleep.value = 1
        await Timer(sleep_time, units='ns')
        
        # Wait for NULL completion
        while dut.ko.value != 1:
            await Timer(1, units='ns')
            
        # Ready for next DATA
        dut.ki.value = 1
        await Timer(sleep_time, units='ns') 