# MTNCL Full Adder Example

This directory contains an example implementation of a 1-bit Full Adder using Multi-Threshold Null Convention Logic (MTNCL).

## Components

- `MTNCL_FullAdder.vhd`: A combinational 1-bit full adder implemented using MTNCL threshold gates
- `MTNCL_FullAdder_Stage.vhd`: A complete pipeline stage with input registers, full adder, and output registers with completion detection
- `MTNCL_FullAdder_tb.py`: Cocotb testbench for the combinational full adder
- `MTNCL_FullAdder_Stage_tb.py`: Cocotb testbench for the full adder pipeline stage

## Directory Structure

- `vectors/`: Contains test vectors for simulation
- `run/`: Contains simulation results and waveforms

## Running Simulations

### Generate Test Vectors

```bash
make vectors
```

### Run Combinational Full Adder Simulation

```bash
make
```

### Run Pipeline Stage Simulation

```bash
make stage
```

### Generate Waveforms

```bash
make waves        # For combinational full adder
make stage_waves  # For pipeline stage
```

### Clean Up

```bash
make clean
```

## Design Details

### Full Adder

The full adder implements the following logic:

- Sum = A ⊕ B ⊕ Cin
- Cout = (A·B) + (A·Cin) + (B·Cin)

In MTNCL, each signal is represented by two physical wires (RAIL0 and RAIL1). The implementation uses threshold gates to compute the sum and carry outputs.

### Pipeline Stage

The pipeline stage wraps the combinational full adder with:

1. Input registers for A, B, and Cin
2. Output registers for Sum and Cout
3. Completion detection logic for handshaking

## NULL/DATA Wavefront Propagation

The MTNCL design operates based on NULL/DATA wavefronts:

1. Initially, all signals are in NULL state
2. When sleep is deasserted, DATA propagates through the circuit
3. Completion detection signals when all outputs have valid DATA
4. When sleep is asserted, NULL propagates through the circuit
5. Completion detection signals when all outputs have returned to NULL

This cycle repeats for each computation. 