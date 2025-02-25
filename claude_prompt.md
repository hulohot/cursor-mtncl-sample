# MTNCL Circuit Development Environment

This environment is set up for structural Multi-Threshold Null Convention Logic (MTNCL) circuit design and verification in VHDL with cocotb testbenches.

## Architecture Knowledge

MTNCL circuits are asynchronous, dual-rail designs that operate based on NULL/DATA wavefronts rather than clock signals. The typical structure consists of a combinational circuit sandwiched between two Delay Insensitive (DI) registers. 

Each signal in dual-rail logic is represented by two physical wires (RAIL0 and RAIL1):
- NULL state: Both RAIL0 and RAIL1 are 0
- DATA1 state: RAIL1 = 1, RAIL0 = 0
- DATA0 state: RAIL1 = 0, RAIL0 = 1
- Invalid state: Both RAIL1 and RAIL0 are 1

## Common Components

You have access to the following libraries in the `/common` directory:

- **NCL_signals.vhd**: Defines fundamental types including `dual_rail_logic`, `dual_rail_logic_vector`, `quad_rail_logic`, and `quad_rail_logic_vector`
- **NCL_functions.vhd**: Contains utility functions (`is_null`, `is_data`, `to_DR`, `to_SL`, `Int_to_DR`, etc.)
- **MTNCL_gates.vhd**: Defines threshold gates (`th12m_a`, `th22m_a`, etc.)
- **MTNCL_package.vhd**: Package declaration for all MTNCL gates
- **MTNCL_completion.vhd**: Completion detection components (`andtreem`, `compm`, etc.)
- **MTNCL_registers.vhd**: Register components (`regm`, `regdm`, `genregm`, etc.)

## File Structure

Use the following file naming conventions:
- Design files: `MTNCL_***.vhd`
- Testbench files: `MTNCL_***_tb.py` (cocotb)
- Test vectors: Place in a `vectors` directory
- Simulation results: Output to a `run` directory 

## Templates

### Template for Combinational MTNCL Circuit

```vhdl
---------------------------------------------------------------------------
-- MTNCL_ComponentName.vhd
-- 
-- Author: [Your Name]
-- Date: [Date]
--
-- Description:
-- [Brief description of the component]
---------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.MTNCL_gates.all;
use work.NCL_signals.all;

entity MTNCL_ComponentName is
    generic (
        bitwidth : integer := 8
    );
    port (
        input1  : in dual_rail_logic_vector(bitwidth-1 downto 0);
        input2  : in dual_rail_logic_vector(bitwidth-1 downto 0);
        sleep   : in std_logic;
        output  : out dual_rail_logic_vector(bitwidth-1 downto 0)
    );
end entity;

architecture structural of MTNCL_ComponentName is
    -- Component signals
    signal th22_out : dual_rail_logic;
    signal th12_out : dual_rail_logic;
    
begin
    -- Combinational logic using threshold gates
    -- [Your implementation here]
    
    -- Example: Simple threshold gate usage
    gate_th22_1: th22m_a
        port map(
            a => input1(0).rail1,
            b => input2(0).rail1,
            s => sleep,
            z => th22_out.rail1
        );
        
    gate_th12_1: th12m_a
        port map(
            a => input1(0).rail0,
            b => input2(0).rail0,
            s => sleep,
            z => th12_out.rail0
        );
    
    -- Output assignments
    output(0).rail1 <= th22_out.rail1;
    output(0).rail0 <= th12_out.rail0;
end architecture;
```

### Template for Complete MTNCL Pipeline Stage

```vhdl
---------------------------------------------------------------------------
-- MTNCL_PipelineStage.vhd
-- 
-- Author: [Your Name]
-- Date: [Date]
--
-- Description:
-- Complete pipeline stage with input register, combinational logic, and
-- output register with completion detection.
---------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.MTNCL_gates.all;
use work.NCL_signals.all;

entity MTNCL_PipelineStage is
    generic (
        bitwidth : integer := 8
    );
    port (
        input  : in dual_rail_logic_vector(bitwidth-1 downto 0);
        ki     : in std_logic;
        sleep  : in std_logic;
        ko     : out std_logic;
        output : out dual_rail_logic_vector(bitwidth-1 downto 0)
    );
end entity;

architecture structural of MTNCL_PipelineStage is
    -- Component signals
    signal input_reg_out : dual_rail_logic_vector(bitwidth-1 downto 0);
    signal comb_out : dual_rail_logic_vector(bitwidth-1 downto 0);
    signal ko_temp : std_logic;
    
begin
    -- Input register
    input_reg : entity work.genregm
        generic map (
            width => bitwidth
        )
        port map (
            a => input,
            s => sleep,
            z => input_reg_out
        );
    
    -- Combinational logic section
    -- Instantiate your combinational circuit here
    comb_logic : entity work.MTNCL_ComponentName
        generic map (
            bitwidth => bitwidth
        )
        port map (
            input1 => input_reg_out,
            input2 => input_reg_out,  -- Just an example, connect as needed
            sleep => sleep,
            output => comb_out
        );
    
    -- Output register
    output_reg : entity work.genregm
        generic map (
            width => bitwidth
        )
        port map (
            a => comb_out,
            s => sleep,
            z => output
        );
    
    -- Completion detection
    comp : entity work.compm
        generic map (
            width => bitwidth
        )
        port map (
            a => output,
            ki => ki,
            ko => ko_temp
        );
    
    ko <= ko_temp;
end architecture;
```

### Template for cocotb Testbench

```python
# MTNCL_ComponentName_tb.py
#
# Author: [Your Name]
# Date: [Date]
#
# Description:
# Testbench for MTNCL_ComponentName

import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock
from cocotb.regression import TestFactory
import os
import csv
from pathlib import Path

# Add path to common functions
import sys
sys.path.append(os.path.join(os.path.dirname(__file__), 'common'))
from mtncl_utils import *

# Test parameters
RUN_DIR = Path('./run')
VECTOR_FILE = Path('./vectors/component_test_vectors.csv')

async def initialize_dut(dut):
    """Initialize the DUT with reset values"""
    dut.sleep.value = 1  # Start with sleep active
    if hasattr(dut, 'ki'):
        dut.ki.value = 1     # Allow data to flow
    await Timer(10, units='ns')

async def cycle_sleep(dut, sleep_time=20):
    """Generate a complete DATA/NULL cycle"""
    # Set to active mode (allow combinational logic to work)
    dut.sleep.value = 0
    await Timer(sleep_time, units='ns')
    
    # Check for DATA on output
    while await is_null(dut.output):
        await Timer(1, units='ns')
    
    # If this is a pipeline stage with ki/ko signals
    if hasattr(dut, 'ki'):
        # Wait for downstream component to acknowledge
        dut.ki.value = 0
        await Timer(sleep_time, units='ns')
    
    # Sleep for NULL wavefront
    dut.sleep.value = 1
    await Timer(sleep_time, units='ns')
    
    # Check for NULL on output
    while not await is_null(dut.output):
        await Timer(1, units='ns')
    
    # Ready for next DATA if pipeline stage
    if hasattr(dut, 'ki'):
        dut.ki.value = 1
        await Timer(sleep_time, units='ns')

@cocotb.test()
async def test_mtncl_component(dut):
    """Test the MTNCL component with vectors from file"""
    # Create run directory if it doesn't exist
    RUN_DIR.mkdir(exist_ok=True)
    
    # Initialize DUT
    await initialize_dut(dut)
    
    # Open test vector file
    with open(VECTOR_FILE, mode='r') as f:
        reader = csv.DictReader(f)
        
        # Open results file
        with open(RUN_DIR / 'results.csv', mode='w') as results_file:
            fieldnames = ['test_case', 'input1', 'input2', 'expected', 'actual', 'status']
            writer = csv.DictWriter(results_file, fieldnames=fieldnames)
            writer.writeheader()
            
            # Process each test vector
            for i, row in enumerate(reader):
                test_case = f"Vector {i}"
                
                # Set input values
                input1_value = int(row['input1'])
                await set_dual_rail(dut.input1, input1_value, dut.bitwidth.value)
                
                if hasattr(dut, 'input2'):
                    input2_value = int(row['input2'])
                    await set_dual_rail(dut.input2, input2_value, dut.bitwidth.value)
                else:
                    input2_value = "N/A"
                
                # Run a DATA/NULL cycle
                await cycle_sleep(dut)
                
                # Check output
                actual = await get_dual_rail_value(dut.output, dut.bitwidth.value)
                expected = int(row['expected'])
                status = "PASS" if actual == expected else "FAIL"
                
                # Log results
                writer.writerow({
                    'test_case': test_case,
                    'input1': input1_value,
                    'input2': input2_value,
                    'expected': expected,
                    'actual': actual,
                    'status': status
                })
                
                if status == "FAIL":
                    dut._log.error(f"Test case {test_case} failed: expected {expected}, got {actual}")
                else:
                    dut._log.info(f"Test case {test_case} passed")
```

## Common MTNCL Utility Functions

Create a file named `mtncl_utils.py` in your `common` directory with these helper functions:

```python
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
```

## Threshold Gate Usage Patterns

### 1. Basic Logic Functions

```vhdl
-- AND function using threshold gates
-- a AND b = th22(a.rail1, b.rail1) | th12(a.rail0, b.rail0)
and_gate_rail1: th22m_a
    port map(a => input1.rail1, b => input2.rail1, s => sleep, z => output.rail1);
and_gate_rail0: th12m_a
    port map(a => input1.rail0, b => input2.rail0, s => sleep, z => output.rail0);

-- OR function using threshold gates
-- a OR b = th12(a.rail1, b.rail1) | th22(a.rail0, b.rail0)
or_gate_rail1: th12m_a
    port map(a => input1.rail1, b => input2.rail1, s => sleep, z => output.rail1);
or_gate_rail0: th22m_a
    port map(a => input1.rail0, b => input2.rail0, s => sleep, z => output.rail0);

-- XOR function using threshold gates
-- a XOR b = th22(a.rail1, b.rail0) | th22(a.rail0, b.rail1)
xor_gate_rail1: th22m_a
    port map(a => input1.rail1, b => input2.rail0, s => sleep, z => output.rail1);
xor_gate_rail0: th22m_a
    port map(a => input1.rail0, b => input2.rail1, s => sleep, z => output.rail0);
```

### 2. Full Adder Implementation

```vhdl
-- 1-bit MTNCL Full Adder

-- Sum bit calculation
-- sum.rail1 = (a.rail1 AND b.rail0 AND cin.rail0) OR (a.rail0 AND b.rail1 AND cin.rail0) OR 
--             (a.rail0 AND b.rail0 AND cin.rail1) OR (a.rail1 AND b.rail1 AND cin.rail1);
-- Implementation using th33 gates and th12 for OR
sum_th33_1: th33m_a
    port map(a => a.rail1, b => b.rail0, c => cin.rail0, s => sleep, z => sum_t1);
    
sum_th33_2: th33m_a
    port map(a => a.rail0, b => b.rail1, c => cin.rail0, s => sleep, z => sum_t2);
    
sum_th33_3: th33m_a
    port map(a => a.rail0, b => b.rail0, c => cin.rail1, s => sleep, z => sum_t3);
    
sum_th33_4: th33m_a
    port map(a => a.rail1, b => b.rail1, c => cin.rail1, s => sleep, z => sum_t4);
    
sum_or_gate: th14m_a
    port map(a => sum_t1, b => sum_t2, c => sum_t3, d => sum_t4, s => sleep, z => sum.rail1);

-- Similar approach for sum.rail0 and carry outputs
```

### 3. Completion Detection Example

```vhdl
-- Completion detection for a 4-bit signal
-- First level of the tree (pairs of bits)
comp_th22_1: th22m_a
    port map(a => data(0).rail0, b => data(0).rail1, s => '0', z => comp_lvl1(0));
    
comp_th22_2: th22m_a
    port map(a => data(1).rail0, b => data(1).rail1, s => '0', z => comp_lvl1(1));
    
comp_th22_3: th22m_a
    port map(a => data(2).rail0, b => data(2).rail1, s => '0', z => comp_lvl1(2));
    
comp_th22_4: th22m_a
    port map(a => data(3).rail0, b => data(3).rail1, s => '0', z => comp_lvl1(3));
    
-- Second level of the tree
comp_th22_lvl2_1: th22m_a
    port map(a => comp_lvl1(0), b => comp_lvl1(1), s => '0', z => comp_lvl2(0));
    
comp_th22_lvl2_2: th22m_a
    port map(a => comp_lvl1(2), b => comp_lvl1(3), s => '0', z => comp_lvl2(1));
    
-- Final output
comp_th22_final: th22m_a
    port map(a => comp_lvl2(0), b => comp_lvl2(1), s => '0', z => comp_out);
    
-- Invert for ko signal
comp_inv: invm_a
    port map(a => comp_out, s => '0', z => ko);
```

## Simulation Setup

Configure your simulation environment for both open-source and commercial simulators:

### Makefile Example

```makefile
# Makefile for MTNCL simulations

# Default simulator
SIM ?= iverilog

# Common paths
COMMON_DIR = /common
RUN_DIR = ./run
VECTOR_DIR = ./vectors

# MTNCL component name (used for file naming)
COMPONENT ?= FullAdder

# Design files
SOURCES = $(COMMON_DIR)/NCL_signals.vhd \
          $(COMMON_DIR)/NCL_functions.vhd \
          $(COMMON_DIR)/MTNCL_gates.vhd \
          $(COMMON_DIR)/MTNCL_package.vhd \
          $(COMMON_DIR)/MTNCL_completion.vhd \
          $(COMMON_DIR)/MTNCL_registers.vhd \
          ./MTNCL_$(COMPONENT).vhd

# Testbench
TB = MTNCL_$(COMPONENT)_tb.py
TB_TOP = MTNCL_$(COMPONENT)

# Enable waveform generation
WAVES ?= 0
ifeq ($(WAVES), 1)
    COCOTB_RESULTS_FILE = $(RUN_DIR)/results.xml
    COCOTB_HOOK = $(RUN_DIR)/waveforms.hook.py
    PLUSARGS += -fst
    PLUSARGS += +fsdb+functions
    PLUSARGS += -debug-all
endif

# Targets for different simulators
ifeq ($(SIM), iverilog)
	COCOTB_HDL_TIMEUNIT = 1ns
	COCOTB_HDL_TIMEPRECISION = 1ps
	SIM_BUILD = $(RUN_DIR)/sim_build_iverilog
	COMPILE_ARGS = -g2012
	VHDL_SOURCES = $(SOURCES)
	TOPLEVEL_LANG = vhdl
endif

ifeq ($(SIM), verilator)
	COCOTB_HDL_TIMEUNIT = 1ns
	COCOTB_HDL_TIMEPRECISION = 1ps
	SIM_BUILD = $(RUN_DIR)/sim_build_verilator
	COMPILE_ARGS = --timing
	VHDL_SOURCES = $(SOURCES)
	TOPLEVEL_LANG = vhdl
endif

ifeq ($(SIM), questa)
	COCOTB_HDL_TIMEUNIT = 1ns
	COCOTB_HDL_TIMEPRECISION = 1ps
	SIM_BUILD = $(RUN_DIR)/sim_build_questa
	VSIM_ARGS = -voptargs=+acc
	VHDL_SOURCES = $(SOURCES)
	TOPLEVEL_LANG = vhdl
endif

ifeq ($(SIM), vcs)
	COCOTB_HDL_TIMEUNIT = 1ns
	COCOTB_HDL_TIMEPRECISION = 1ps
	SIM_BUILD = $(RUN_DIR)/sim_build_vcs
	COMPILE_ARGS = -debug_pp
	VHDL_SOURCES = $(SOURCES)
	TOPLEVEL_LANG = vhdl
endif

# Waveform hook file
$(RUN_DIR)/waveforms.hook.py:
	mkdir -p $(RUN_DIR)
	echo "import cocotb" > $@
	echo "from cocotb.triggers import Timer" >> $@
	echo "@cocotb.hook()" >> $@
	echo "def setup_dumpfile(sim):" >> $@
	echo "    sim.write_vcd('$(RUN_DIR)/waveform.vcd')" >> $@

# Targets
.PHONY: all clean waves vectors

all: $(RUN_DIR)/results.csv

$(RUN_DIR)/results.csv: $(TB) $(if $(filter 1,$(WAVES)),$(COCOTB_HOOK),)
	mkdir -p $(RUN_DIR)
	PYTHONPATH=$(PYTHONPATH):$(PWD):$(COMMON_DIR) make -f $(shell cocotb-config --makefiles)/Makefile.sim \
		SIM=$(SIM) TOPLEVEL=$(TB_TOP) MODULE=$(TB:%.py=%)

waves: WAVES=1
waves: all
	@echo "Waveform generated at $(RUN_DIR)/waveform.vcd"
	@if command -v gtkwave >/dev/null 2>&1; then \
		gtkwave $(RUN_DIR)/waveform.vcd & \
	else \
		echo "GTKWave not found. Install it to view the waveform."; \
	fi

vectors:
	mkdir -p $(VECTOR_DIR)
	python -c "from mtncl_utils import generate_test_vectors; generate_test_vectors(20, 8, '$(VECTOR_DIR)/$(COMPONENT)_test_vectors.csv')"

clean:
	rm -rf $(RUN_DIR)
```

## Design Rules and Best Practices

1. **Structural Design**
   - Always use the provided MTNCL components from the common directory
   - For testing, create purely combinational circuits first
   - For full designs, maintain the MTNCL pattern: input register → combinational logic → output register

2. **Signal Handling**
   - Always check if output is DATA or NULL to determine when to sleep the next component
   - Ensure proper NULL/DATA wavefront propagation
   - Never leave dual-rail signals in invalid states (both rails high)

3. **Testbench Guidelines**
   - Load test vectors from file and save outputs to a run directory
   - Implement thorough NULL/DATA cycle tests
   - Check completion detection functionality

4. **Documentation**
   - Use header blocks for file documentation
   - Comment on complex sections and threshold gate usage
   - Document the purpose of each component and its interface

5. **Simulation Practices**
   - Test with multiple simulators (iverilog, verilator, QuestaSim, VCS)
   - Verify both functional correctness and NULL/DATA wavefront propagation
   - Test corner cases and boundary conditions
   - Use waveform generation when needed for debugging