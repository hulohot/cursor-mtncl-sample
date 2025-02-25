# MTNCL Common Files Context

## NCL_signals.vhd
- Defines fundamental data types for NCL (Null Convention Logic) and MTNCL (Multi-Threshold NCL)
- Contains definitions for:
  - `dual_rail_logic`: Record with RAIL1 and RAIL0 std_logic fields
  - `dual_rail_logic_vector`: Array of dual_rail_logic
  - `quad_rail_logic`: Record with RAIL3, RAIL2, RAIL1, RAIL0 std_logic fields
  - `quad_rail_logic_vector`: Array of quad_rail_logic

## NCL_functions.vhd
- Contains utility functions for testbenches (not for synthesis)
- Provides functions for:
  - Checking if signals are null or data (`is_null`, `is_data`)
  - Converting between standard logic and dual-rail logic (`to_DR`, `to_SL`)
  - Converting between standard logic and quad-rail logic (`to_QR`)
  - Converting between dual-rail and quad-rail logic
  - Converting integers to dual-rail logic vectors (`Int_to_DR`)

## MTNCL_gates.vhd
- Defines component declarations for MTNCL threshold gates
- Contains various threshold gate components with different configurations:
  - Basic gates: `bufm_a`, `invm_a`
  - Threshold gates: `th12m_a`, `th22m_a`, `th33m_a`, `th44m_a`, etc.
  - Weighted threshold gates: `th24w22m_a`, `th34w32m_a`, etc.
  - Reset variants: `th12dm_a`, `th12nm_a`

## MTNCL_package.vhd
- Contains the `MTNCL_gates` package declaration
- Defines interfaces for all MTNCL threshold gates
- Includes component declarations for various threshold gates with sleep signal inputs

## MTNCL_completion.vhd
- Provides completion detection components for MTNCL circuits
- Contains:
  - `tree_funcs` package: Helper functions for tree structures
  - `andtreem`: Generic AND tree for completion detection
  - `compm`: Completion block with high reset
  - `compdm`: Completion block with low reset
  - `comp1m`: Completion block with additional Ki signal and high reset
  - `comp1dm`: Completion block with additional Ki signal and low reset

## MTNCL_registers.vhd
- Defines register components for MTNCL designs
- Contains:
  - `regm`: Basic register without reset
  - `regdm`: Register with high reset
  - `regnm`: Register with low reset
  - `regnullm`: Register that resets to null
  - `genregm`: Generic-sized register without reset
  - `genregrstm`: Generic-sized register with configurable reset
  - `PipeRegm`: Register for pipelining
  - `Eregm`: Register with even stages
  - `ShiftRegMTNCL`: Pattern-delay shift register